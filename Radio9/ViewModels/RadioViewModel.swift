import Foundation
import AVFoundation
import AVKit
import Combine
import ShazamKit
import UIKit
import MediaPlayer

@MainActor
class RadioViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var currentStation: RadioStation?
    @Published var isPlaying = false
    @Published var volume: Float = 1.0  // Max volume for testing
    @Published var stations: [RadioStation] = RadioStation.stations(for: Country.defaultCountry().code)
    @Published var currentFrequency: Double = Country.defaultCountry().defaultFrequency
    @Published var selectedCountry: Country = Country.defaultCountry()
    @Published var isCountrySelectionMode = false
    @Published var countrySelectionIndex: Double = 0
    private var tempSelectedCountry: Country?  // 임시 선택 국가
    @Published var isLoading = false
    @Published var selectedGenre: StationGenre = .all
    @Published var filteredStations: [RadioStation] = []
    @Published var fastestStations: [RadioStation] = []
    @Published var favoriteStations: [RadioStation] = []
    @Published var showAddedToFavoritesMessage = false
    @Published var showFavoritesDotAnimation = false
    @Published var showComingSoonMessage = false
    
    // Sleep Timer
    @Published var isSleepTimerActive = false
    @Published var sleepTimerMinutes: Int = 0
    @Published var sleepTimerRemainingTime: Int? = nil
    @Published var sleepTimerMessage: String? = nil
    private var sleepTimer: Timer?
    
    // Audio analyzer for equalizer
    let audioAnalyzer = AudioAnalyzer()
    
    // Computed property for current country's favorites
    var currentCountryFavorites: [RadioStation] {
        favoriteStations.filter { station in
            station.countryCode == selectedCountry.code
        }
    }
    
    // 국가 선택 모드에서 표시할 국가
    var displayCountry: Country {
        if isCountrySelectionMode, let temp = tempSelectedCountry {
            return temp
        }
        return selectedCountry
    }
    @Published var latestSongInfo: SongInfo?
    
    private var player: AVPlayer?  // For streaming
    private var audioPlayer: AVAudioPlayer?  // For local files (nature sounds)
    private var isObserving = false
    private var observedPlayerItem: AVPlayerItem?  // Track which item we're observing
    private var stationLoadTimes: [String: TimeInterval] = [:]
    private var loadTimeoutTask: Task<Void, Never>?
    
    // Performance optimization
    private var preloadedPlayers: [String: AVPlayer] = [:]
    private var connectionPool: [String: URLSession] = [:]
    private let maxPreloadedPlayers = 5  // 인접 5개 스테이션 프리로드
    private var networkReachability = true
    private var stationHealthScores: [String: Double] = [:]
    private var streamAnalyzer = StreamAnalyzer()
    private var connectionWarmer: Timer?
    // Track recently failed stations to avoid repeated attempts
    private var recentlyFailedStations: Set<String> = []
    private var failedStationResetTimer: Timer?
    private var failedStationCounts: [String: Int] = [:] // Track failure counts
    private var songRecognitionService = SongRecognitionService()
    
    // Background task for audio playback
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    
    // 프리로드 우선순위 큐
    private let preloadQueue = DispatchQueue(label: "radio9.preload", qos: .userInitiated)
    
    // DNS prefetch cache
    private var dnsCache: [String: String] = [:]
    private let dnsQueue = DispatchQueue(label: "radio9.dns", qos: .userInitiated, attributes: .concurrent)
    
    // CDN edge selection
    private var fastestServers: [String: String] = [:]  // station key -> fastest URL
    private let serverTestQueue = DispatchQueue(label: "radio9.servertest", qos: .userInitiated, attributes: .concurrent)
    
    // Audio buffer caching - 최근 재생 오디오 캐싱
    private var audioBufferCache: [String: Data] = [:]  // station key -> last 5 seconds of audio
    private let maxCachedStations = 5
    private let cacheBufferDuration: TimeInterval = 5.0  // 5초 캐싱
    private var bufferCaptureTimers: [String: Timer] = [:]
    
    private func stationKey(_ station: RadioStation) -> String {
        return "\(station.name)_\(station.frequency)"
    }
    
    override init() {
        super.init()
        
        // Initialize with default data first based on system country
        let defaultCountry = Country.defaultCountry()
        let countryStations = RadioStation.stations(for: defaultCountry.code)
        self.filteredStations = countryStations
        self.stations = countryStations
        
        // Perform heavy operations asynchronously
        Task { @MainActor in
            setupAudioSession()
            setupNetworkMonitoring()
            loadStationsForCountry(isInitialLoad: true)
            updateFilteredStations()
            updateFastestStations()
            loadFavorites()
            
            // 프리로드 활성화 - 빠른 채널 전환
            Task {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1초 후
                await preloadNearbyStations(frequency: currentFrequency)
            }
            // Connection warming은 일단 비활성화
            // startConnectionWarming()
        }
    }
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            // 백그라운드 재생을 위한 설정
            // Set category for background playback
            try audioSession.setCategory(.playback, mode: .default)
            
            // Activate session
            try audioSession.setActive(true)
            print("✅ Audio session setup successful")
            print("   Category: \(audioSession.category.rawValue)")
            print("   Mode: \(audioSession.mode.rawValue)")
            
            // Setup Remote Control Center
            setupRemoteControls()
            
            // Enable background audio
            UIApplication.shared.beginReceivingRemoteControlEvents()
        } catch {
            print("❌ Audio session setup error: \(error)")
            print("   Error code: \((error as NSError).code)")
            print("   Error domain: \((error as NSError).domain)")
        }
    }
    
    private func setupRemoteControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Play command
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }
        
        // Pause command
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        
        // Next track
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.selectNextStation()
            return .success
        }
        
        // Previous track
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.selectPreviousStation()
            return .success
        }
        
        // Update Now Playing info
        updateNowPlayingInfo()
    }
    
    private func updateNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
        
        if let station = currentStation {
            nowPlayingInfo[MPMediaItemPropertyTitle] = station.name
            nowPlayingInfo[MPMediaItemPropertyArtist] = "FM \(station.formattedFrequency)"
            
            if let songInfo = latestSongInfo {
                nowPlayingInfo[MPMediaItemPropertyTitle] = songInfo.title
                nowPlayingInfo[MPMediaItemPropertyArtist] = songInfo.artist
                nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = station.name
            }
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] = MPNowPlayingInfoMediaType.audio.rawValue
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func setupNetworkMonitoring() {
        // Monitor network changes for smooth transitions
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNetworkChange),
            name: .AVPlayerItemFailedToPlayToEndTime,
            object: nil
        )
        
        // Monitor audio interruptions (phone calls, etc)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
        
        // Monitor route changes (headphones plugged/unplugged)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
        
        // Monitor app state changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    private func removeNetworkMonitoring() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func handleNetworkChange() {
        // Reconnect if network changes
        if currentStation != nil, isPlaying {
            print("Network changed, reconnecting...")
            play()
        }
    }
    
    @objc private func handleAudioInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            // Interruption began, save state and pause
            print("Audio interruption began")
            // Don't change isPlaying state - we'll resume after interruption
            
        case .ended:
            // Interruption ended, resume if we were playing
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) && isPlaying {
                    print("Audio interruption ended, resuming playback")
                    Task { @MainActor in
                        // Wait a bit before resuming to avoid conflicts
                        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                        
                        do {
                            let audioSession = AVAudioSession.sharedInstance()
                            try audioSession.setActive(true)
                            self.player?.play()
                            if #available(iOS 12.0, *) {
                                self.player?.playImmediately(atRate: 1.0)
                            }
                            print("✅ Resumed after interruption")
                        } catch {
                            print("❌ Failed to resume after interruption: \(error)")
                        }
                    }
                }
            }
            
        @unknown default:
            break
        }
    }
    
    @objc private func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        switch reason {
        case .oldDeviceUnavailable:
            // Headphones were unplugged, pause playback
            print("Audio route changed: old device unavailable")
            if isPlaying {
                pause()
            }
            
        case .newDeviceAvailable:
            // Headphones were plugged in
            print("Audio route changed: new device available")
            
        default:
            break
        }
    }
    
    @objc private func handleAppDidEnterBackground() {
        print("📱 App entered background (from ViewModel)")
        print("📱 App is in background - audio should continue playing")
        
        if isPlaying {
            print("✅ Audio is playing, should continue in background")
            
            // Ensure background task is active
            if backgroundTaskID == .invalid {
                backgroundTaskID = UIApplication.shared.beginBackgroundTask { [weak self] in
                    self?.endBackgroundTask()
                }
                print("📱 Started background task for ongoing playback")
            }
            
            // Re-activate audio session
            do {
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setActive(true)
                print("✅ Audio session re-activated for background")
            } catch {
                print("❌ Failed to re-activate audio session: \(error)")
            }
            
            // Force player to continue if it stopped
            Task { @MainActor in
                if let player = self.player {
                    if player.rate == 0 {
                        player.play()
                        print("▶️ Forced player to continue in background")
                    }
                    // Set audio session priority
                    player.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
                }
            }
        }
    }
    
    @objc private func handleAppWillEnterForeground() {
        print("📱 App will enter foreground")
        // Check player state and sync UI
        if let player = player {
            let playerRate = player.rate
            if playerRate > 0 {
                Task { @MainActor in
                    self.isPlaying = true
                }
            } else if isPlaying {
                // Player stopped while in background, restart
                player.play()
            }
        }
    }
    
    private func preloadFavoriteStations() async {
        // Preload favorite stations for instant playback
        for station in favoriteStations.prefix(3) {
            await preloadStation(station)
        }
    }
    
    private func startConnectionWarming() {
        // Warm connections for visible stations every 30 seconds
        Task { @MainActor in
            connectionWarmer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                Task {
                    await self.warmConnections()
                }
            }
        }
    }
    
    private func warmConnections() async {
        // Warm up connections for current and nearby stations
        let nearbyStations = filteredStations.filter { station in
            abs(station.frequency - currentFrequency) < 5.0
        }.prefix(5)
        
        for station in nearbyStations {
            if connectionPool[stationKey(station)] == nil {
                await preloadStation(station)
            }
        }
    }
    
    // DNS Prefetch for faster connection - DISABLED for performance
    private func prefetchDNS(for urlString: String) async {
        // DNS prefetching disabled - was causing performance issues
        return
    }
    
    nonisolated private func extractIPAddress(from addrinfo: addrinfo) -> String? {
        if addrinfo.ai_family == AF_INET {
            var addr = sockaddr_in()
            withUnsafeMutableBytes(of: &addr) { ptr in
                addrinfo.ai_addr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<sockaddr_in>.size) {
                    ptr.copyMemory(from: UnsafeRawBufferPointer(start: $0, count: MemoryLayout<sockaddr_in>.size))
                }
            }
            
            var buffer = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
            inet_ntop(AF_INET, &addr.sin_addr, &buffer, socklen_t(INET_ADDRSTRLEN))
            return String(cString: buffer)
        }
        return nil
    }
    
    // CDN 엣지 서버 테스트 - 가장 빠른 서버 찾기
    private func findFastestServer(for station: RadioStation) async -> String {
        // CDN 테스트를 비활성화하고 항상 원본 URL 반환
        return station.streamURL
    }
    
    // 가능한 CDN/미러 URL들 생성 - 비활성화
    private func generatePossibleURLs(for originalURL: String) -> [String] {
        // CDN 변형 생성을 비활성화하고 원본 URL만 반환
        return [originalURL]
    }
    
    
    private func preloadStation(_ station: RadioStation) async {
        // HTTPS 전용 URL 처리
        var urlString = station.streamURL
        if urlString.hasPrefix("https://") && urlString.contains(":443") {
            urlString = urlString.replacingOccurrences(of: ":443", with: "")
        }
        
        guard let url = URL(string: urlString) else { return }
        
        // DNS prefetch disabled for performance
        // await prefetchDNS(for: station.streamURL)
        
        // Create optimized session for this station
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 3.0  // Even faster timeout
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        config.httpMaximumConnectionsPerHost = 4  // More parallel connections
        config.multipathServiceType = .handover  // Use best available network
        config.httpShouldUsePipelining = true  // Enable HTTP pipelining
        config.allowsExpensiveNetworkAccess = true
        config.allowsConstrainedNetworkAccess = true
        
        // HTTP/3 (QUIC) 지원 - iOS 15+
        if #available(iOS 15.0, *) {
            // HTTP/3 support - removed as it's not available in iOS SDK
        }
        
        // DNS 캐시 활용을 위한 커스텀 프로토콜
        if let host = url.host, let cachedIP = dnsCache[host] {
            // IP 주소로 직접 연결하면 DNS 조회 시간 절약
            print("Using cached DNS for \(host): \(cachedIP)")
        }
        
        let session = URLSession(configuration: config)
        connectionPool[stationKey(station)] = session
        
        // Pre-warm the connection and test speed
        let startTime = Date()
        do {
            let (_, _) = try await session.data(from: url)
            let loadTime = Date().timeIntervalSince(startTime)
            
            // Calculate health score (0-1, higher is better)
            let healthScore = max(0, min(1, 2.0 / loadTime))  // 2 seconds = 1.0 score
            stationHealthScores[stationKey(station)] = healthScore
            
            // Pre-create player for high-scoring stations
            if healthScore > 0.7 && preloadedPlayers.count < maxPreloadedPlayers {
                await createPreloadedPlayer(for: station)
            }
        } catch {
            stationHealthScores[stationKey(station)] = 0.1  // Low score for failed stations
        }
    }
    
    private func createPreloadedPlayer(for station: RadioStation) async {
        // URL 처리 및 정규화
        var streamURL = station.streamURL
        
        // Listen.moe 특별 처리
        if let workingURL = ListenMoeURLs.getWorkingURL(for: streamURL) {
            streamURL = workingURL
        }
        
        // HTTPS:443 포트 제거
        if streamURL.hasPrefix("https://") && streamURL.contains(":443") {
            streamURL = streamURL.replacingOccurrences(of: ":443", with: "")
        }
        
        guard let url = URL(string: streamURL) else { return }
        
        await MainActor.run {
            let asset = AVURLAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            
            // Stable buffering for preloaded players
            playerItem.preferredForwardBufferDuration = 0.5  // 500ms - stable preload
            playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
            
            // 프리로드 최적화
            if #available(iOS 14.0, *) {
                playerItem.startsOnFirstEligibleVariant = true
                playerItem.preferredPeakBitRate = 64000 // 안정적인 비트레이트로 시작
            }
            
            let player = AVPlayer(playerItem: playerItem)
            player.automaticallyWaitsToMinimizeStalling = false  // Don't wait, just play
            player.volume = 0  // Mute preloaded players
            
            preloadedPlayers[stationKey(station)] = player
            
            // Clean up old preloaded players
            if preloadedPlayers.count > maxPreloadedPlayers {
                let sortedByHealth = preloadedPlayers.keys.sorted { key1, key2 in
                    (stationHealthScores[key1] ?? 0) > (stationHealthScores[key2] ?? 0)
                }
                
                if let keyToRemove = sortedByHealth.last {
                    preloadedPlayers[keyToRemove]?.pause()
                    preloadedPlayers.removeValue(forKey: keyToRemove)
                }
            }
        }
    }
    
    func selectStation(_ station: RadioStation) {
        currentStation = station
        currentFrequency = station.frequency
        // Clear cached song info when changing station
        latestSongInfo = nil
        // Update Now Playing info
        updateNowPlayingInfo()
        // 이미 재생 중이면 새 스테이션도 자동 재생
        if isPlaying {
            play()
        }
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            // 재생 시작
            isPlaying = true
            play()
        }
    }
    
    func play() {
        // Easter egg: 106.7 MHz - glitch1
        if abs(currentFrequency - 106.7) < 0.1 {
            playGlitchSound(fileName: "glitch1")
            return
        }
        
        // Easter egg: 102.8 MHz - glitch2
        if abs(currentFrequency - 102.8) < 0.1 {
            playGlitchSound(fileName: "glitch2")
            return
        }
        
        // If no station, play static noise
        guard let station = currentStation else {
            if isPlaying {
                playStaticNoise()
            }
            return
        }
        
        // If we have an audioPlayer AND it's the same station, just resume it
        if let audioPlayer = audioPlayer {
            let currentFile = audioPlayer.url?.lastPathComponent ?? "none"
            let newFile = station.streamURL.components(separatedBy: "/").last ?? "none"
            
            print("🔍 Current file: \(currentFile), New file: \(newFile)")
            
            if currentFile == newFile {
                audioPlayer.play()
                isPlaying = true
                isLoading = false
                print("▶️ Resuming same AVAudioPlayer for: \(currentFile)")
                return
            } else {
                print("🔄 Different file detected, will load new: \(newFile)")
                // Stop current player to load new file
                audioPlayer.stop()
                self.audioPlayer = nil
            }
        }
        
        // Remove from failed stations when trying again
        let key = stationKey(station)
        if recentlyFailedStations.contains(key) {
            recentlyFailedStations.remove(key)
            failedStationCounts[key] = 0
            print("🔄 Retrying previously failed station: \(station.name)")
        }
        
        // End previous background task if exists
        endBackgroundTask()
        
        // Start new background task for audio playback
        backgroundTaskID = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        print("📱 Started background task for audio playback")
        
        // Ensure audio session is active before playing
        do {
            let audioSession = AVAudioSession.sharedInstance()
            if audioSession.category != .playback {
                try audioSession.setCategory(.playback, mode: .default)
            }
            try audioSession.setActive(true)
            print("✅ Audio session activated for playback")
        } catch {
            print("❌ Failed to activate audio session: \(error)")
            print("   Error code: \((error as NSError).code)")
        }
        
        let _ = stationKey(station)
        
        // 캐시된 오디오 버퍼 임시 비활성화
        // if let cachedBuffer = audioBufferCache[key] {
        //     print("🎵 Playing from cache for \(station.name)")
        //     playFromCache(cachedBuffer, station: station)
        //     return
        // }
        
        // CDN 테스트 비활성화
        
        // 캐시된 빠른 서버가 있으면 사용, 없으면 원본 사용
        // URL 처리 및 정규화
        var streamURL = station.streamURL
        
        // Listen.moe 특별 처리
        if let workingURL = ListenMoeURLs.getWorkingURL(for: streamURL) {
            print("🎵 Listen.moe URL converted: \(streamURL) → \(workingURL)")
            streamURL = workingURL
        }
        
        // HTTPS:443 포트 제거
        if streamURL.hasPrefix("https://") && streamURL.contains(":443") {
            streamURL = streamURL.replacingOccurrences(of: ":443", with: "")
        }
        
        // 이중 슬래시 제거 (http:// 또는 https:// 뒤)
        streamURL = streamURL.replacingOccurrences(of: "://", with: ":/")
            .replacingOccurrences(of: ":/", with: "://")
        
        // Check if this is a podcast
        if station.isPodcast {
            print("🎧 Loading podcast: \(station.name)")
            isLoading = true
            
            // Simple regex-based parsing for now
            let feedURL = URL(string: streamURL)!
            URLSession.shared.dataTask(with: feedURL) { [weak self] data, response, error in
                guard let data = data else {
                    DispatchQueue.main.async {
                        self?.isLoading = false
                    }
                    return
                }
                
                if let xmlString = String(data: data, encoding: .utf8) {
                    // Find first enclosure URL
                    let pattern = #"<enclosure[^>]*url="([^"]+)"[^>]*>"#
                    
                    if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                        if let match = regex.firstMatch(in: xmlString, options: [], range: NSRange(location: 0, length: xmlString.count)) {
                            if let range = Range(match.range(at: 1), in: xmlString) {
                                let mp3URL = String(xmlString[range])
                                print("🎧 Found podcast MP3: \(mp3URL)")
                                
                                DispatchQueue.main.async {
                                    if let url = URL(string: mp3URL) {
                                        self?.playStreamURL(url, station: station)
                                    } else {
                                        self?.isLoading = false
                                    }
                                }
                                return
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    print("🚫 No MP3 found in podcast feed")
                    self?.isLoading = false
                }
            }.resume()
            return
        }
        
        guard let url = URL(string: streamURL) else { 
            print("🚫 Invalid URL: \(streamURL)")
            return 
        }
        
        // Preloaded player temporarily disabled due to issues
        // if let preloadedPlayer = preloadedPlayers[stationKey(station)] {
        //     player?.pause()
        //     removeObserver()
        //     
        //     player = preloadedPlayer
        //     player?.volume = volume
        //     player?.play()
        //     
        //     isPlaying = true
        //     isLoading = false
        //     
        //     addObserver()
        //     
        //     print("💨 Instant play using preloaded player for \(station.name)")
        //     
        //     startBufferCapture(for: station)
        //     
        //     Task {
        //         await preloadNearbyStations(frequency: station.frequency)
        //     }
        //     
        //     return
        // }
        
        // Clean up existing player
        removeObserver()
        player?.pause()
        player = nil  // Clear the player reference
        audioPlayer?.stop()
        audioPlayer = nil
        loadTimeoutTask?.cancel()
        
        // Check if this is a local file (nature sounds)
        let isLocalFile = station.streamURL.starts(with: "file://") || station.countryCode == "NATURE"
        
        if isLocalFile {
            // Use AVAudioPlayer for local files (perfect looping)
            playLocalFile(station: station)
        } else {
            // Use AVPlayer for streaming
            isLoading = true
            playStreamURL(url, station: station)
        }
    }
    
    private func playGlitchSound(fileName: String = "glitch1") {
        // Load glitch sound file from bundle
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("❌ Failed to find \(fileName).mp3 in bundle")
            return
        }
        
        // Stop any existing audio player
        audioPlayer?.stop()
        audioPlayer = nil
        
        do {
            // Create AVAudioPlayer for glitch sound
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.numberOfLoops = -1  // Infinite loop
            audioPlayer?.volume = volume * 0.12  // Lower volume for glitch (12%)
            audioPlayer?.prepareToPlay()
            
            // Start playback
            if audioPlayer?.play() == true {
                print("🎛 Playing easter egg \(fileName) sound")
                // Start glitch pattern animation
                audioAnalyzer.startAnalyzingForNature(stationName: "Glitch")
            } else {
                print("❌ Failed to start glitch sound")
            }
        } catch {
            print("❌ Error creating AVAudioPlayer for glitch: \(error)")
        }
    }
    
    private func playStaticNoise() {
        // Load static noise file from bundle
        guard let fileURL = Bundle.main.url(forResource: "static", withExtension: "mp3") else {
            print("❌ Failed to find static.mp3 in bundle")
            return
        }
        
        // Stop any existing audio player
        audioPlayer?.stop()
        audioPlayer = nil
        
        do {
            // Create AVAudioPlayer for static noise
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.numberOfLoops = -1  // Infinite loop
            audioPlayer?.volume = volume * 0.113  // Lower volume for static (11.3%, 기존 12.6%에서 -10%)
            audioPlayer?.prepareToPlay()
            
            // Start playback
            if audioPlayer?.play() == true {
                print("📻 Playing static noise for empty frequency")
                // Start static pattern animation
                audioAnalyzer.startAnalyzingForNature(stationName: "Static")
            } else {
                print("❌ Failed to start static noise")
            }
        } catch {
            print("❌ Error creating AVAudioPlayer for static: \(error)")
        }
    }
    
    private func playLocalFile(station: RadioStation) {
        // Extract file name from bundle URL
        let urlString = station.streamURL
        var resourceName = ""
        var fileExtension = "mp3"
        var volumeAdjustment: Float = 1.0  // Volume multiplier
        
        if urlString.contains("rain.mp3") && !urlString.contains("rain_rooftop.mp3") {
            resourceName = "rain"
            volumeAdjustment = 1.0  // Normal volume
        } else if urlString.contains("rain_rooftop.mp3") {
            resourceName = "rain_rooftop"
            volumeAdjustment = 0.4  // 40% volume for rooftop rain
        } else if urlString.contains("wave.mp3") {
            resourceName = "wave"
            volumeAdjustment = 0.55  // -45% volume (기존 60%에서 -5%)
        } else if urlString.contains("night.mp3") {
            resourceName = "night"
            volumeAdjustment = 0.2  // -80% volume (기존 30%에서 -10%)
        } else if urlString.contains("campfire.mp3") {
            resourceName = "campfire"
            volumeAdjustment = 1.3  // +30% volume (기존 120%에서 +10%, 최대 1.0으로 제한됨)
        } else if urlString.contains("bird.mp3") {
            resourceName = "bird"
            volumeAdjustment = 0.2  // -80% volume (20%)
        } else if urlString.contains("thunder.mp3") {
            resourceName = "thunder"
            volumeAdjustment = 0.75  // -25% volume (75%)
        } else if urlString.contains("drizzle.mp3") {
            resourceName = "drizzle"
            volumeAdjustment = 0.45  // -55% volume (45%)
        } else if urlString.contains("stream.mp3") {
            resourceName = "stream"
            volumeAdjustment = 0.25  // -75% volume (25%)
        } else if urlString.contains("thunder2.mp3") {
            resourceName = "thunder2"
            volumeAdjustment = 0.6  // 60% volume for epic thunder
        } else if urlString.contains("snowstorm.mp3") {
            resourceName = "snowstorm"
            volumeAdjustment = 0.3  // 30% volume for snowstorm
        } else if urlString.contains("debussy.mp3") {
            resourceName = "debussy"
            volumeAdjustment = 0.85  // 85% volume for classical piano
        } else if urlString.contains("grace.mp3") {
            resourceName = "grace"
            volumeAdjustment = 0.5  // 50% volume for hymn
        }
        
        // Load file from bundle
        guard let fileURL = Bundle.main.url(forResource: resourceName, withExtension: fileExtension) else {
            print("❌ Failed to find \(resourceName).\(fileExtension) in bundle")
            return
        }
        
        do {
            // Create AVAudioPlayer for perfect looping
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.delegate = self  // Set delegate to handle playback events
            audioPlayer?.numberOfLoops = -1  // Infinite loop
            audioPlayer?.volume = min(1.0, volume * volumeAdjustment)  // Apply volume adjustment (cap at 1.0)
            audioPlayer?.prepareToPlay()
            
            // Start playback
            if audioPlayer?.play() == true {
                print("🎵 Playing local file with AVAudioPlayer: \(resourceName).\(fileExtension)")
                print("🔄 Infinite looping enabled (gapless)")
                isPlaying = true
                isLoading = false
                
                // Start fake equalizer animation for nature sounds
                if let station = currentStation {
                    audioAnalyzer.startAnalyzingForNature(stationName: station.name)
                }
            } else {
                print("❌ Failed to start AVAudioPlayer")
                isPlaying = false
                isLoading = false
            }
        } catch {
            print("❌ Error creating AVAudioPlayer: \(error)")
            isPlaying = false
            isLoading = false
        }
    }
    
    private func playStreamURL(_ url: URL, station: RadioStation) {
        // Skip timeout for local files and nature sounds
        let isLocalFile = station.streamURL.starts(with: "file://") || station.countryCode == "NATURE"
        
        if !isLocalFile {
            let timeoutDuration: UInt64 = 3_000_000_000 // 3초
            loadTimeoutTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: timeoutDuration)
                if self.isLoading {
                    self.isLoading = false
                    self.player?.pause()
                    self.removeObserver()
                    
                    // 타임아웃 스테이션 기록
                    if let station = self.currentStation {
                        let key = self.stationKey(station)
                        self.stationHealthScores[key] = 0.3
                        
                        // Track timeout count  
                        self.failedStationCounts[key] = (self.failedStationCounts[key] ?? 0) + 1
                        let failureCount = self.failedStationCounts[key] ?? 1
                        
                        self.recentlyFailedStations.insert(key)
                        self.scheduleFailedStationReset()
                        
                        // 플레이어만 정지, isPlaying 상태는 유지
                        if failureCount == 1 || failureCount % 10 == 0 {
                            print("⏱️ Station timeout: \(station.name) (attempt #\(failureCount))")
                        }
                    }
                }
            }
        }
        
        // Handle different stream types
        if station.streamURL.contains(".m3u8") {
            // HLS stream with optimized settings
            var options: [String: Any] = [:]
            
            // Network optimization settings
            if #available(iOS 15.0, *) {
                options[AVURLAssetAllowsCellularAccessKey as String] = true
                options[AVURLAssetAllowsExpensiveNetworkAccessKey as String] = true
                options[AVURLAssetAllowsConstrainedNetworkAccessKey as String] = true
            }
            
            let asset = AVURLAsset(url: url, options: options)
            let playerItem = AVPlayerItem(asset: asset)
            
            // 빠른 시작을 위한 최소 버퍼
            playerItem.preferredForwardBufferDuration = 0.3 // 0.3초 버퍼
            playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
            
            // Enable background playback
            if #available(iOS 9.0, *) {
                playerItem.preferredForwardBufferDuration = TimeInterval(1.0)
            }
            
            // 버퍼 언더런 방지를 위한 설정
            if #available(iOS 14.0, *) {
                playerItem.startsOnFirstEligibleVariant = true // 첫 가능한 스트림으로 즉시 시작
            }
            
            if #available(iOS 15.0, *) {
                // Start with lower bitrate for stability
                playerItem.preferredPeakBitRate = 64000 // 64kbps for stable start
                playerItem.preferredMaximumResolution = .zero // Audio only
            }
            
            // Configure for ultra-low latency
            if #available(iOS 13.0, *) {
                playerItem.configuredTimeOffsetFromLive = CMTime(seconds: 0.1, preferredTimescale: 1) // 0.1초 지연
            }
            
            // Always use AVPlayer for streaming (nature sounds now use AVAudioPlayer)
            player = AVPlayer(playerItem: playerItem)
            player?.automaticallyWaitsToMinimizeStalling = false  // Don't wait for buffer
            player?.allowsExternalPlayback = true
            player?.usesExternalPlaybackWhileExternalScreenIsActive = true
            
            // Enable background playback
            if #available(iOS 15.0, *) {
                player?.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
            }
            
            // Prevent sleep and ensure background playback
            if #available(iOS 12.0, *) {
                player?.preventsDisplaySleepDuringVideoPlayback = false // We're audio only
            }
            
            player?.volume = volume
            player?.play()
            
            print("Playing HLS stream: \(station.streamURL)")
            addObserver()
            isPlaying = true
            
            // Start audio analysis
            if let player = player {
                audioAnalyzer.startAnalyzing(player: player)
            }
            
            // Start buffer capture for next instant replay
            startBufferCapture(for: station)
        } else if station.streamURL.contains(".pls") || station.streamURL.contains(".m3u") {
            // Playlist file - parse for actual stream URL
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let content = String(data: data, encoding: .utf8) {
                        var streamURLString: String?
                        
                        // Parse PLS format
                        if station.streamURL.contains(".pls") {
                            let lines = content.components(separatedBy: .newlines)
                            if let fileLine = lines.first(where: { $0.hasPrefix("File1=") }) {
                                streamURLString = fileLine.replacingOccurrences(of: "File1=", with: "")
                            }
                        } else {
                            // Parse M3U format
                            let lines = content.components(separatedBy: .newlines)
                            if let streamLine = lines.first(where: { $0.hasPrefix("http") && !$0.hasPrefix("#") }) {
                                streamURLString = streamLine
                            }
                        }
                        
                        if let streamURLString = streamURLString?.trimmingCharacters(in: .whitespacesAndNewlines),
                           let streamURL = URL(string: streamURLString) {
                            await MainActor.run {
                                self.player = AVPlayer(url: streamURL)
                                self.player?.volume = self.volume
                                self.player?.play()
                                self.addObserver()
                                self.isPlaying = true
                                
                                // Start audio analysis
                                if let player = self.player {
                                    self.audioAnalyzer.startAnalyzing(player: player)
                                }
                            }
                            return
                        }
                    }
                } catch {
                    print("Failed to load playlist file: \(error)")
                }
                
                // Fallback to direct URL
                await MainActor.run {
                    self.player = AVPlayer(url: url)
                    self.player?.volume = self.volume
                    self.player?.play()
                    self.isPlaying = true
                    self.addObserver()
                    
                    // Start audio analysis
                    if let player = self.player {
                        self.audioAnalyzer.startAnalyzing(player: player)
                    }
                }
            }
        } else {
            // Direct stream (MP3, AAC, etc) with aggressive optimization
            var options: [String: Any] = [:]
            
            // 특수 스트림 처리
            if station.streamURL.contains("listen.moe") || station.streamURL.contains("radioca.st") {
                // 특별한 처리가 필요한 스트림
                options[AVURLAssetReferenceRestrictionsKey as String] = 0
                options[AVURLAssetPreferPreciseDurationAndTimingKey as String] = false
            }
            
            // Network optimization settings
            if #available(iOS 15.0, *) {
                options[AVURLAssetAllowsCellularAccessKey as String] = true
                options[AVURLAssetAllowsExpensiveNetworkAccessKey as String] = true
                options[AVURLAssetAllowsConstrainedNetworkAccessKey as String] = true
            }
            
            let asset = AVURLAsset(url: url, options: options)
            
            // Configure asset for fast loading
            if #available(iOS 10.0, *) {
                asset.resourceLoader.preloadsEligibleContentKeys = true
            }
            
            let playerItem = AVPlayerItem(asset: asset)
            
            // 빠른 시작을 위한 최소 버퍼
            playerItem.preferredForwardBufferDuration = 0.3 // 0.3초 버퍼
            playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
            
            // Enable background playback
            if #available(iOS 9.0, *) {
                playerItem.preferredForwardBufferDuration = TimeInterval(1.0)
            }
            
            // 스트림 시작 최적화
            if #available(iOS 14.0, *) {
                playerItem.startsOnFirstEligibleVariant = true
            }
            
            if #available(iOS 15.0, *) {
                // Start with lower bitrate for stability
                playerItem.preferredPeakBitRate = 64000 // 64kbps for stable start
                playerItem.preferredMaximumResolution = .zero // Audio only
            }
            
            // Always use AVPlayer for streaming (nature sounds now use AVAudioPlayer)
            player = AVPlayer(playerItem: playerItem)
            player?.automaticallyWaitsToMinimizeStalling = false  // Don't wait for buffer
            player?.allowsExternalPlayback = true
            player?.usesExternalPlaybackWhileExternalScreenIsActive = true
            
            // Enable background playback
            if #available(iOS 15.0, *) {
                player?.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
            }
            
            // Prevent sleep and ensure background playback
            if #available(iOS 12.0, *) {
                player?.preventsDisplaySleepDuringVideoPlayback = false // We're audio only
            }
            
            player?.volume = volume
            player?.play()
            
            print("🎧 Playing direct stream: \(station.streamURL)")
            addObserver()
            isPlaying = true
            
            // Start audio analysis
            if let player = player {
                audioAnalyzer.startAnalyzing(player: player)
            }
            
            // Start buffer capture for next instant replay
            startBufferCapture(for: station)
        }
    }
    
    private func pause() {
        isPlaying = false
        loadTimeoutTask?.cancel()
        isLoading = false
        removeObserver()
        player?.pause()
        audioPlayer?.pause()  // Pause AVAudioPlayer for nature sounds
        // Don't clear player reference - keep it for background
        // player = nil
        // audioPlayer = nil
        
        // Stop audio analysis
        audioAnalyzer.stopAnalyzing()
        
        // Update Now Playing info
        updateNowPlayingInfo()
        
        // End background task when pausing
        endBackgroundTask()
    }
    
    private func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
            print("📱 Ended background task")
        }
    }
    
    private func addObserver() {
        guard let playerItem = player?.currentItem, !isObserving else { return }
        
        // Remove any existing observer first
        if observedPlayerItem != nil && observedPlayerItem !== playerItem {
            removeObserver()
        }
        
        playerItem.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
        playerItem.addObserver(self, forKeyPath: "timedMetadata", options: [.new], context: nil)
        
        // Also observe player rate to detect when playback stops
        player?.addObserver(self, forKeyPath: "rate", options: [.new], context: nil)
        player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.new], context: nil)
        
        observedPlayerItem = playerItem
        observedPlayer = player  // Track which player we're observing
        isObserving = true
        print("Observer added for status, timedMetadata, rate, and timeControlStatus")
    }
    
    private var observedPlayer: AVPlayer?  // Track which player we're observing
    
    private func setupLooping(for player: AVPlayer) {
        // Deprecated - now using AVAudioPlayer for local files
        print("⚠️ setupLooping called but now using AVAudioPlayer for local files")
    }
    
    private func removeObserver() {
        guard isObserving else { 
            isObserving = false
            observedPlayerItem = nil
            observedPlayer = nil
            return 
        }
        
        // Only remove observer from the exact item we added it to
        if let observedItem = observedPlayerItem {
            observedItem.removeObserver(self, forKeyPath: "status", context: nil)
            observedItem.removeObserver(self, forKeyPath: "timedMetadata", context: nil)
        }
        
        // Remove player observers only if we're observing this specific player
        if let observedPlayer = observedPlayer {
            observedPlayer.removeObserver(self, forKeyPath: "rate", context: nil)
            observedPlayer.removeObserver(self, forKeyPath: "timeControlStatus", context: nil)
        }
        
        isObserving = false
        observedPlayerItem = nil
        observedPlayer = nil
        print("Observer removed successfully")
    }
    
    func adjustVolume(_ newVolume: Float) {
        volume = newVolume
        player?.volume = volume
        audioPlayer?.volume = volume
    }
    
    func recognizeCurrentSong() {
        guard isPlaying else { return }
        
        // If we have cached metadata, show it immediately
        if let latestSongInfo = latestSongInfo {
            NotificationCenter.default.post(
                name: .songRecognized,
                object: nil,
                userInfo: ["songInfo": latestSongInfo]
            )
            return
        }
        
        // Otherwise, show a message with station info and web search suggestion
        let songInfo = SongInfo(
            title: currentStation?.name ?? "Radio Station",
            artist: "Song recognition not available",
            album: "Search '\(currentStation?.name ?? "radio") playlist' online",
            artworkURL: nil
        )
        
        NotificationCenter.default.post(
            name: .songRecognized,
            object: nil,
            userInfo: ["songInfo": songInfo]
        )
    }
    
    // 다이얼 회전 디바운싱을 위한 타이머
    private var tuneDebounceTimer: Timer?
    
    func tuneToFrequency(_ frequency: Double) {
        currentFrequency = frequency
        
        // Easter egg: 106.7 MHz - play glitch1 sound
        if abs(frequency - 106.7) < 0.1 {
            // Stop any existing playback
            currentStation = nil
            latestSongInfo = nil
            
            if player != nil {
                player?.pause()
                removeObserver()
                player = nil
                loadTimeoutTask?.cancel()
                isLoading = false
            }
            
            // Play glitch1 sound if playing
            if isPlaying {
                playGlitchSound(fileName: "glitch1")
            }
            
            tuneDebounceTimer?.invalidate()
            return
        }
        
        // Easter egg: 102.8 MHz - play glitch2 sound
        if abs(frequency - 102.8) < 0.1 {
            // Stop any existing playback
            currentStation = nil
            latestSongInfo = nil
            
            if player != nil {
                player?.pause()
                removeObserver()
                player = nil
                loadTimeoutTask?.cancel()
                isLoading = false
            }
            
            // Play glitch2 sound if playing
            if isPlaying {
                playGlitchSound(fileName: "glitch2")
            }
            
            tuneDebounceTimer?.invalidate()
            return
        }
        
        // 다이얼 회전 중에는 스테이션만 표시하고 재생은 지연
        if let station = filteredStations.first(where: { abs($0.frequency - frequency) < 0.1 }) {
            if currentStation?.id != station.id {
                currentStation = station
                latestSongInfo = nil
                
                // 다이얼 회전이 멈춘 후 재생 시도
                tuneDebounceTimer?.invalidate()
                tuneDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                    Task { @MainActor in
                        guard let self = self else { return }
                        // 사용자가 재생 중이었고 현재 스테이션이 있으면 재생
                        if self.isPlaying && self.currentStation != nil {
                            self.play()
                        }
                    }
                }
            }
        } else {
            // No station at this frequency - play static noise
            if currentStation != nil || audioPlayer?.url?.lastPathComponent != "static.mp3" {
                currentStation = nil
                latestSongInfo = nil
                
                // Stop any existing player
                if player != nil {
                    player?.pause()
                    removeObserver()
                    player = nil
                    loadTimeoutTask?.cancel()
                    isLoading = false
                }
                
                // Play static noise if user is playing
                if isPlaying {
                    playStaticNoise()
                }
                
                // 다이얼 타이머 취소
                tuneDebounceTimer?.invalidate()
            }
        }
    }
    
    // 현재 주파수 근처의 스테이션들을 프리로드
    private func preloadNearbyStations(frequency: Double) async {
        // 현재 주파수 ±1 MHz 범위의 스테이션들
        let nearbyStations = filteredStations.filter { station in
            abs(station.frequency - frequency) <= 1.0
        }.sorted { station1, station2 in
            // 현재 주파수에 가까운 순으로 정렬
            abs(station1.frequency - frequency) < abs(station2.frequency - frequency)
        }
        
        // 상위 7개 스테이션 프리로드
        for station in nearbyStations.prefix(maxPreloadedPlayers) {
            if preloadedPlayers[stationKey(station)] == nil {
                await createPreloadedPlayer(for: station)
            }
        }
        
        // 범위 밖의 오래된 프리로드 정리
        cleanupDistantPreloads(currentFrequency: frequency)
    }
    
    // 현재 주파수에서 멀리 떨어진 프리로드 정리
    private func cleanupDistantPreloads(currentFrequency: Double) {
        let keysToRemove = preloadedPlayers.compactMap { key, _ -> String? in
            // key에서 주파수 추출
            if let station = filteredStations.first(where: { stationKey($0) == key }),
               abs(station.frequency - currentFrequency) > 3.0 {
                return key
            }
            return nil
        }
        
        for key in keysToRemove {
            preloadedPlayers[key]?.pause()
            preloadedPlayers.removeValue(forKey: key)
            print("Cleaned up distant preload: \(key)")
        }
    }
    
    // MARK: - Station Navigation
    func selectNextStation() {
        // 주파수로 정렬된 스테이션 목록 (--- 이스터에그 제외)
        let sortedStations = filteredStations
            .filter { $0.name != "- - -" && $0.name != "---" }  // Easter egg 제외
            .sorted { $0.frequency < $1.frequency }
        
        guard !sortedStations.isEmpty else { return }
        
        print("📻 Current station: \(currentStation?.name ?? "nil") at \(currentStation?.frequency ?? 0) MHz")
        print("📻 Total stations: \(sortedStations.count)")
        
        // 현재 스테이션이 있을 경우 그 스테이션의 인덱스를 찾아서 다음 스테이션 선택
        if let currentStation = currentStation,
           let currentIndex = sortedStations.firstIndex(where: { $0.id == currentStation.id }) {
            let nextIndex = (currentIndex + 1) % sortedStations.count
            print("🔄 Current index: \(currentIndex), Next index: \(nextIndex)")
            print("🔄 Next station: \(sortedStations[nextIndex].name) at \(sortedStations[nextIndex].frequency) MHz")
            selectStation(sortedStations[nextIndex])
        } else {
            print("⚠️ Current station not found in list, using frequency-based selection")
            // 현재 스테이션이 없으면 현재 주파수보다 높은 첫 번째 스테이션
            if let nextStation = sortedStations.first(where: { $0.frequency > currentFrequency }) {
                selectStation(nextStation)
            } else if let firstStation = sortedStations.first {
                selectStation(firstStation)
            }
        }
    }
    
    func selectPreviousStation() {
        // 주파수로 정렬된 스테이션 목록 (--- 이스터에그 제외)
        let sortedStations = filteredStations
            .filter { $0.name != "- - -" && $0.name != "---" }  // Easter egg 제외
            .sorted { $0.frequency < $1.frequency }
        
        guard !sortedStations.isEmpty else { return }
        
        print("📻 Current station: \(currentStation?.name ?? "nil") at \(currentStation?.frequency ?? 0) MHz")
        print("📻 Total stations: \(sortedStations.count)")
        
        // 현재 스테이션이 있을 경우 그 스테이션의 인덱스를 찾아서 이전 스테이션 선택
        if let currentStation = currentStation,
           let currentIndex = sortedStations.firstIndex(where: { $0.id == currentStation.id }) {
            let previousIndex = currentIndex > 0 ? currentIndex - 1 : sortedStations.count - 1
            print("🔄 Current index: \(currentIndex), Previous index: \(previousIndex)")
            print("🔄 Previous station: \(sortedStations[previousIndex].name) at \(sortedStations[previousIndex].frequency) MHz")
            selectStation(sortedStations[previousIndex])
        } else {
            print("⚠️ Current station not found in list, using frequency-based selection")
            // 현재 스테이션이 없으면 현재 주파수보다 낮은 마지막 스테이션
            if let previousStation = sortedStations.last(where: { $0.frequency < currentFrequency }) {
                selectStation(previousStation)
            } else if let lastStation = sortedStations.last {
                selectStation(lastStation)
            }
        }
    }
    
    func hasNextStation() -> Bool {
        guard let currentStation = currentStation,
              let currentIndex = filteredStations.firstIndex(where: { $0.id == currentStation.id }) else { return false }
        return currentIndex < filteredStations.count - 1
    }
    
    func hasPreviousStation() -> Bool {
        guard let currentStation = currentStation,
              let currentIndex = filteredStations.firstIndex(where: { $0.id == currentStation.id }) else { return false }
        return currentIndex > 0
    }
    
    func toggleCountrySelectionMode() {
        // Always just show "Coming soon" message, never enter selection mode
        showComingSoonMessage = true
        
        // Hide message after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.showComingSoonMessage = false
        }
        
        // Don't enter country selection mode at all
        return
    }
    
    func selectCountryByIndex(_ index: Double) {
        let countries = Country.countries
        let clampedIndex = Int(max(0, min(index, Double(countries.count - 1))))
        tempSelectedCountry = countries[clampedIndex]  // 임시로만 저장
        // loadStationsForCountry() 호출하지 않음 - 재생 유지
    }
    
    private func loadStationsForCountry(isInitialLoad: Bool = false) {
        // 재생 상태 저장 - isPlaying이 변경되기 전에 저장
        let wasPlaying = isPlaying
        
        // 플레이어 정지 (isPlaying 상태는 유지)
        if player != nil {
            player?.pause()
            removeObserver()
            player = nil
        }
        
        // 국가 변경 시 즉시 모든 스테이션 정리
        currentStation = nil
        stations = []
        filteredStations = []
        fastestStations = []
        
        // 비동기로 스테이션 로드하여 UI 블로킹 방지
        Task { @MainActor in
            // 먼저 새 국가의 기본 스테이션 로드
            // 비동기로 스테이션 로드
            let countryCode = self.selectedCountry.code
            let newStations = RadioStation.stations(for: countryCode)
            
            // UI 업데이트는 메인 스레드에서
            self.stations = newStations
            self.updateFilteredStations()
            self.updateFastestStations()
            
            // 초기 스테이션 선택 - Musopen Radio만 있으므로 항상 첫번째 선택
            if let firstStation = self.filteredStations.first {
                self.currentStation = firstStation
                self.currentFrequency = firstStation.frequency
                print("✅ Initial station set to: \(firstStation.name) at \(firstStation.frequency) MHz")
            }
            
            // 국가 변경 전에 재생 중이었다면 새 스테이션도 자동 재생
            if wasPlaying && !isInitialLoad && self.currentStation != nil {
                // 약간의 지연을 주어 UI가 업데이트되도록 함
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1초
                self.play()
            }
        }
        
        // API 스테이션 로드 활성화 - 최대한 많은 채널 로드
        let enableAPIStations = false
        
        guard enableAPIStations else { return }
        
        // API에서 실제 스테이션 가져오기 (백그라운드에서)
        let loadingCountryCode = selectedCountry.code
        Task {
            let apiStations = await RadioBrowserAPI.shared.fetchStations(for: loadingCountryCode)
            
            await MainActor.run {
                // 사용자가 다른 국가로 변경하지 않았는지 확인
                if self.selectedCountry.code == loadingCountryCode && !apiStations.isEmpty {
                    // API 스테이션과 기본 스테이션을 병합
                    let defaultStations = self.stations // 현재 기본 스테이션들
                    
                    // 기본 스테이션이 없으면 API 스테이션만 사용
                    if defaultStations.isEmpty {
                        self.stations = apiStations
                    } else {
                        // 기본 스테이션이 있으면 병합
                        var mergedStations = defaultStations
                        
                        // API 스테이션 중 기본 스테이션과 중복되지 않는 것만 추가
                        for apiStation in apiStations {
                            // 주파수가 겹치지 않는 스테이션만 추가 (0.2 MHz 이내는 중복으로 간주)
                            let isDuplicate = mergedStations.contains { defaultStation in
                                abs(defaultStation.frequency - apiStation.frequency) < 0.2
                            }
                            
                            if !isDuplicate {
                                mergedStations.append(apiStation)
                            }
                        }
                        
                        // 주파수 순으로 정렬
                        mergedStations.sort { $0.frequency < $1.frequency }
                        self.stations = mergedStations
                    }
                    
                    self.updateFilteredStations()
                    self.updateFastestStations()
                    
                    print("📡 Merged stations: \(self.stations.count) total (\(defaultStations.count) default + \(self.stations.count - defaultStations.count) API)")
                }
            }
        }
    }
    
    func updateFilteredStations() {
        if selectedGenre == .all {
            filteredStations = stations
        } else {
            filteredStations = stations.filter { station in
                // Check main genre category
                switch selectedGenre {
                case .music:
                    return [.music, .pop, .rock, .jazz, .classical].contains(station.genre)
                case .news:
                    return [.news, .talk].contains(station.genre)
                case .education:
                    return [.education, .culture].contains(station.genre)
                case .entertainment:
                    return [.entertainment, .sports].contains(station.genre)
                default:
                    return station.genre == selectedGenre
                }
            }
        }
        updateFastestStations()
        
        // DNS prefetch disabled for performance - was causing delays
        // Task {
        //     await withTaskGroup(of: Void.self) { group in
        //         for station in filteredStations.prefix(5) {
        //             group.addTask {
        //                 await self.prefetchDNS(for: station.streamURL)
        //             }
        //         }
        //     }
        // }
    }
    
    private func updateFastestStations() {
        // Sort stations by load time (fastest first)
        let sortedStations = filteredStations.sorted { station1, station2 in
            let time1 = stationLoadTimes[stationKey(station1)] ?? Double.infinity
            let time2 = stationLoadTimes[stationKey(station2)] ?? Double.infinity
            return time1 < time2
        }
        
        // Get up to 9 fastest stations
        fastestStations = Array(sortedStations.prefix(9))
        
        // If we don't have enough stations with load times, fill with first available stations
        if fastestStations.count < 9 {
            let remainingStations = filteredStations.filter { station in
                !fastestStations.contains(where: { $0.id == station.id })
            }
            let additionalCount = min(9 - fastestStations.count, remainingStations.count)
            fastestStations.append(contentsOf: remainingStations.prefix(additionalCount))
        }
    }
    
    func selectGenre(_ genre: StationGenre) {
        selectedGenre = genre
        updateFilteredStations()
    }
    
    // MARK: - Favorites Management
    func addToFavorites(station: RadioStation) {
        // Check if station is already in favorites
        if !favoriteStations.contains(where: { $0.id == station.id }) {
            favoriteStations.append(station)
            saveFavorites()
            HapticManager.shared.impact(style: .medium)
            
            // Show feedback
            showAddedToFavoritesMessage = true
            
            // Hide message and start dot animation
            Task {
                // Start dot animation at 0.7 seconds
                try? await Task.sleep(nanoseconds: 700_000_000)
                showFavoritesDotAnimation = true
                
                // Hide message after 2 seconds total (2 - 0.7 = 1.3 seconds more)
                try? await Task.sleep(nanoseconds: 1_300_000_000)
                showAddedToFavoritesMessage = false
                
                // Stop dot animation after 3 blinks (about 2.4 seconds total)
                try? await Task.sleep(nanoseconds: 2_400_000_000)
                showFavoritesDotAnimation = false
            }
        }
    }
    
    func removeFromFavorites(station: RadioStation) {
        favoriteStations.removeAll { $0.id == station.id }
        saveFavorites()
    }
    
    func removeFavorites(at indexSet: IndexSet) {
        let stationsToRemove = currentCountryFavorites
        for index in indexSet {
            if index < stationsToRemove.count {
                let stationToRemove = stationsToRemove[index]
                favoriteStations.removeAll { $0.id == stationToRemove.id }
            }
        }
        saveFavorites()
    }
    
    // MARK: - Sleep Timer
    
    func setSleepTimer(minutes: Int) {
        // Cancel existing timer
        sleepTimer?.invalidate()
        
        // Set new timer
        sleepTimerMinutes = minutes
        isSleepTimerActive = true
        
        // Show "Timer On" message
        sleepTimerMessage = LocalizationHelper.getLocalizedString(for: "timer_on")
        
        // After 1.5 seconds, start showing the countdown
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            self.sleepTimerMessage = nil
            self.sleepTimerRemainingTime = minutes * 60
        }
        
        // Start countdown
        sleepTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if let remaining = self.sleepTimerRemainingTime {
                if remaining > 0 {
                    self.sleepTimerRemainingTime = remaining - 1
                } else {
                    // Timer finished - stop playback
                    self.pause()
                    self.cancelSleepTimer()
                }
            }
        }
    }
    
    func cancelSleepTimer() {
        sleepTimer?.invalidate()
        sleepTimer = nil
        isSleepTimerActive = false
        sleepTimerMinutes = 0
        sleepTimerRemainingTime = nil
        
        // Show "Timer Off" message
        sleepTimerMessage = LocalizationHelper.getLocalizedString(for: "timer_off")
        
        // Clear message after 1.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.sleepTimerMessage = nil
        }
    }
    
    func isFavorite(station: RadioStation) -> Bool {
        return favoriteStations.contains(where: { $0.id == station.id })
    }
    
    private func saveFavorites() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(favoriteStations) {
            UserDefaults.standard.set(data, forKey: "favoriteStations")
        }
    }
    
    private func loadFavorites() {
        guard let data = UserDefaults.standard.data(forKey: "favoriteStations"),
              let stations = try? JSONDecoder().decode([RadioStation].self, from: data) else { 
            favoriteStations = []
            return 
        }
        favoriteStations = stations
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rate" {
            if let player = object as? AVPlayer {
                print("🎵 Player rate changed to: \(player.rate)")
                Task { @MainActor in
                    // Update UI state based on actual player state
                    if player.rate > 0 && !self.isPlaying {
                        self.isPlaying = true
                        print("📡 Playback started")
                    } else if player.rate == 0 && self.isPlaying && !self.isLoading {
                        print("⚠️ Playback stopped unexpectedly")
                        // Stop audio analyzer when playback stops
                        self.audioAnalyzer.stopAnalyzing()
                    }
                }
            }
        } else if keyPath == "timeControlStatus" {
            if let player = object as? AVPlayer {
                if #available(iOS 10.0, *) {
                    switch player.timeControlStatus {
                    case .paused:
                        print("⏸ Player is paused")
                    case .waitingToPlayAtSpecifiedRate:
                        print("⏳ Player is waiting to play (buffering)")
                    case .playing:
                        print("▶️ Player is playing")
                        Task { @MainActor in
                            if !self.isPlaying {
                                self.isPlaying = true
                            }
                        }
                    @unknown default:
                        break
                    }
                }
            }
        } else if keyPath == "timedMetadata" {
            if let playerItem = object as? AVPlayerItem {
                // Safely handle timedMetadata - check if it's actually an array
                guard let timedMetadata = playerItem.timedMetadata else { return }
                
                // timedMetadata is already [AVMetadataItem], no need to cast
                let metadata = timedMetadata
                
                if !metadata.isEmpty {
                    // Parse metadata immediately when it arrives
                    Task {
                        if let songInfo = await songRecognitionService.parseTimedMetadata(metadata) {
                            await MainActor.run {
                                print("Real-time metadata found: \(songInfo.title)")
                                // Store the latest metadata
                                self.latestSongInfo = songInfo
                                // Update Now Playing info with song metadata
                                self.updateNowPlayingInfo()
                            }
                        }
                    }
                }
            }
        } else if keyPath == "status" {
            if let playerItem = object as? AVPlayerItem {
                switch playerItem.status {
                case .failed:
                    let error = playerItem.error
                    let errorCode = (error as NSError?)?.code ?? -1
                    print("🚫 Player failed for \(self.currentStation?.name ?? "Unknown")")
                    print("   Error: \(error?.localizedDescription ?? "Unknown error")")
                    print("   Error code: \(errorCode)")
                    print("   URL: \(self.currentStation?.streamURL ?? "No URL")")
                    
                    // Error -11828은 지원되지 않는 포맷
                    if errorCode == -11828 {
                        print("   💡 This appears to be an unsupported format error")
                    }
                    
                    // 플레이어 실패 시 재생 중지
                    self.isPlaying = false
                    isLoading = false
                    loadTimeoutTask?.cancel()
                    
                    // Stop audio analyzer
                    self.audioAnalyzer.stopAnalyzing()
                    
                    // 스테이션 건강도 업데이트
                    if let station = self.currentStation {
                        let key = self.stationKey(station)
                        self.stationHealthScores[key] = 0.1
                        
                        // Track failure count
                        self.failedStationCounts[key] = (self.failedStationCounts[key] ?? 0) + 1
                        
                        // Only log first failure or every 10th failure
                        let failureCount = self.failedStationCounts[key] ?? 1
                        if failureCount == 1 || failureCount % 10 == 0 {
                            print("⚠️ Station failed: \(station.name) (failure #\(failureCount))")
                        }
                        
                        self.recentlyFailedStations.insert(key)
                        self.scheduleFailedStationReset()
                    }
                    
                    // 사용자가 명시적으로 정지하지 않는 한 재생 의도는 유지
                    // isPlaying 상태는 유지
                    
                    // 프리로드된 플레이어 제거
                    if let station = self.currentStation {
                        let key = self.stationKey(station)
                        self.preloadedPlayers[key]?.pause()
                        self.preloadedPlayers.removeValue(forKey: key)
                    }
                case .readyToPlay:
                    print("Player ready to play")
                    isLoading = false
                    loadTimeoutTask?.cancel()
                    
                    // Record load time for this station
                    if let station = currentStation {
                        let loadTime = Date().timeIntervalSinceNow
                        if loadTime < 10 { // 적절한 로드 시간인 경우만 기록
                            stationLoadTimes[stationKey(station)] = abs(loadTime)
                            print("Station \(station.name) loaded in \(abs(loadTime)) seconds")
                            updateFastestStations()
                        }
                    }
                    
                    // Force play if not playing
                    if player?.rate == 0 {
                        player?.play()
                        print("Forcing play after ready state")
                    }
                    
                    // Ensure isPlaying is set to true on main thread
                    Task { @MainActor in
                        self.isPlaying = true
                    }
                case .unknown:
                    print("Player status unknown")
                default:
                    break
                }
            }
        }
    }
    
    private func tryNextStation() {
        // 자동으로 다음 스테이션을 시도하지 않음
        // 사용자가 직접 다른 스테이션을 선택하도록 함
        // isPlaying 상태는 유지 (사용자의 재생 의도 유지)
        print("❌ Station failed, please select another station")
    }
    
    private func predictAndPreloadNextStation() async {
        // Intelligent prediction based on user behavior
        guard let currentStation = currentStation else { return }
        
        // Find stations near current frequency
        let nearbyStations = filteredStations.filter { station in
            station.id != currentStation.id &&
            abs(station.frequency - currentStation.frequency) < 2.0
        }.sorted { station1, station2 in
            // Sort by health score and proximity
            let score1 = (stationHealthScores[stationKey(station1)] ?? 0.5) / (1 + abs(station1.frequency - currentStation.frequency))
            let score2 = (stationHealthScores[stationKey(station2)] ?? 0.5) / (1 + abs(station2.frequency - currentStation.frequency))
            return score1 > score2
        }
        
        // Preload top candidate
        if let nextStation = nearbyStations.first {
            await preloadStation(nextStation)
        }
    }
    
    private func tryAlternativeStream(for station: RadioStation) {
        // Try lower quality or alternative stream
        guard URL(string: station.streamURL) != nil else { return }
        
        // Reset and try with more aggressive settings
        isLoading = false
        // isPlaying 상태는 유지
        
        Task {
            // Mark this station as slow
            stationHealthScores[stationKey(station)] = 0.2
            
            // Try to find a better station
            if let betterStation = findBetterAlternative(to: station) {
                await MainActor.run {
                    self.selectStation(betterStation)
                }
            }
        }
    }
    
    private func findBetterAlternative(to station: RadioStation) -> RadioStation? {
        // Find similar station with better health score
        return filteredStations.filter { candidate in
            candidate.id != station.id &&
            candidate.genre == station.genre &&
            (stationHealthScores[stationKey(candidate)] ?? 0.5) > 0.6
        }.max { station1, station2 in
            (stationHealthScores[stationKey(station1)] ?? 0) < (stationHealthScores[stationKey(station2)] ?? 0)
        }
    }
    
    // Reset failed stations after 10 seconds for quicker retry
    private func scheduleFailedStationReset() {
        failedStationResetTimer?.invalidate()
        failedStationResetTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.recentlyFailedStations.removeAll()
                self?.failedStationCounts.removeAll() // Clear counts too
                // Silent clear without logging
            }
        }
    }
    
    // MARK: - Audio Buffer Caching
    
    private func playFromCache(_ cachedData: Data, station: RadioStation) {
        // 캐시 데이터가 있다는 것은 프리로드가 준비되었다는 의미
        let key = stationKey(station)
        
        if let preloadedPlayer = preloadedPlayers[key] {
            // 프리로드된 플레이어 즉시 사용
            player?.pause()
            removeObserver()
            
            player = preloadedPlayer
            player?.volume = volume
            player?.play()
            
            isPlaying = true
            isLoading = false
            
            addObserver()
            
            print("⚡ Ultra-fast playback using preloaded player for \(station.name)")
            
            // 다음 스테이션들 프리로드
            Task {
                await preloadNearbyStations(frequency: station.frequency)
            }
            
            // 버퍼 캡처 시작 (다음번을 위해)
            startBufferCapture(for: station)
        } else {
            // 프리로드가 없으면 일반 재생
            print("📡 No preload available, connecting to live stream")
            connectToLiveStream(station: station)
        }
    }
    
    private func connectToLiveStream(station: RadioStation) {
        // 프리로드가 없는 경우에만 새 플레이어 생성
        let _ = stationKey(station)
        // URL 처리 및 정규화
        var streamURL = station.streamURL
        
        // Listen.moe 특별 처리
        if let workingURL = ListenMoeURLs.getWorkingURL(for: streamURL) {
            print("🎵 Listen.moe URL converted: \(streamURL) → \(workingURL)")
            streamURL = workingURL
        }
        
        // HTTPS:443 포트 제거
        if streamURL.hasPrefix("https://") && streamURL.contains(":443") {
            streamURL = streamURL.replacingOccurrences(of: ":443", with: "")
        }
        
        // 이중 슬래시 제거 (http:// 또는 https:// 뒤)
        streamURL = streamURL.replacingOccurrences(of: "://", with: ":/")
            .replacingOccurrences(of: ":/", with: "://")
        
        guard let url = URL(string: streamURL) else { 
            print("🚫 Invalid URL: \(streamURL)")
            return 
        }
        
        // 기존 플레이어 정리
        player?.pause()
        removeObserver()
        
        let playerItem = AVPlayerItem(url: url)
        
        // 최적화 설정
        playerItem.preferredForwardBufferDuration = 0.5
        playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        
        if #available(iOS 14.0, *) {
            playerItem.startsOnFirstEligibleVariant = true
            playerItem.preferredPeakBitRate = 64000 // 64kbps로 시작
        }
        
        player = AVPlayer(playerItem: playerItem)
        player?.automaticallyWaitsToMinimizeStalling = false
        player?.volume = volume
        player?.play()
        
        // 상태 업데이트
        isPlaying = true
        isLoading = false
        
        addObserver()
        
        print("📡 Direct stream connection for \(station.name)")
        
        // 오디오 버퍼 캡처 시작
        startBufferCapture(for: station)
        
        // 다음 스테이션 프리로드
        Task {
            await preloadNearbyStations(frequency: station.frequency)
        }
    }
    
    private func startBufferCapture(for station: RadioStation) {
        let key = stationKey(station)
        
        // 기존 타이머 정리
        bufferCaptureTimers[key]?.invalidate()
        
        // 5초 후부터 버퍼 캡처 시작
        // 버퍼 캡처 비활성화 - 너무 많은 스테이션이 캐시되는 문제
        // bufferCaptureTimers[key] = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
        //     Task { @MainActor in
        //         self?.captureAudioBuffer(for: station)
        //     }
        // }
    }
    
    private func captureAudioBuffer(for station: RadioStation) {
        // 라이브 스트림은 AVAssetExportSession으로 캡처할 수 없으므로
        // 단순히 현재 스테이션 정보를 빠르게 로드할 수 있도록 표시
        let key = stationKey(station)
        
        print("📼 Marking \(station.name) as ready for instant replay")
        
        // 단순히 표시를 위해 빈 데이터 저장 (실제 오디오 대신)
        // 이렇게 하면 다음번 재생 시 프리로드된 플레이어를 사용할 수 있음
        if audioBufferCache.count >= maxCachedStations {
            if let oldestKey = audioBufferCache.keys.first {
                audioBufferCache.removeValue(forKey: oldestKey)
            }
        }
        
        // 빈 데이터로 표시 ("instant-ready" 플래그 역할)
        audioBufferCache[key] = Data()
        
        // 프리로드가 없으면 생성
        if preloadedPlayers[key] == nil {
            Task {
                await createPreloadedPlayer(for: station)
            }
        }
    }
    
    deinit {
        // Clean up timers on deinit
        connectionWarmer?.invalidate()
        bufferCaptureTimers.values.forEach { $0.invalidate() }
        tuneDebounceTimer?.invalidate()
        failedStationResetTimer?.invalidate()
        
        // Ensure observer is removed from the exact item
        if isObserving {
            if let observedItem = observedPlayerItem {
                observedItem.removeObserver(self, forKeyPath: "status", context: nil)
                observedItem.removeObserver(self, forKeyPath: "timedMetadata", context: nil)
            }
            // Remove player observers if player still exists
            if player != nil {
                player?.removeObserver(self, forKeyPath: "rate", context: nil)
                player?.removeObserver(self, forKeyPath: "timeControlStatus", context: nil)
            }
            isObserving = false
            observedPlayerItem = nil
        }
        // Clean up network monitoring
        NotificationCenter.default.removeObserver(self)
        
        // End background task
        if backgroundTaskID != .invalid {
            Task { @MainActor in
                UIApplication.shared.endBackgroundTask(backgroundTaskID)
                backgroundTaskID = .invalid
            }
        }
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // This shouldn't be called with numberOfLoops = -1, but just in case
        if !flag {
            print("⚠️ AVAudioPlayer stopped unexpectedly")
            isPlaying = false
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("❌ AVAudioPlayer decode error: \(error?.localizedDescription ?? "unknown")")
        isPlaying = false
    }
}