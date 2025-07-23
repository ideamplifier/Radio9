import Foundation
import AVFoundation
import Combine
import ShazamKit
import UIKit

@MainActor
class RadioViewModel: NSObject, ObservableObject {
    @Published var currentStation: RadioStation?
    @Published var isPlaying = false
    @Published var volume: Float = 1.0  // Max volume for testing
    @Published var stations: [RadioStation] = RadioStation.sampleStations
    @Published var currentFrequency: Double = 89.1
    @Published var selectedCountry: Country = Country.defaultCountry()
    @Published var isCountrySelectionMode = false
    @Published var countrySelectionIndex: Double = 0
    @Published var isLoading = false
    @Published var selectedGenre: StationGenre = .all
    @Published var filteredStations: [RadioStation] = []
    @Published var fastestStations: [RadioStation] = []
    @Published var favoriteStations: [RadioStation?] = Array(repeating: nil, count: 9)
    
    private var player: AVPlayer?
    private var isObserving = false
    private var observedPlayerItem: AVPlayerItem?  // Track which item we're observing
    private var stationLoadTimes: [String: TimeInterval] = [:]
    private var loadStartTime: Date?
    private var loadTimeoutTask: Task<Void, Never>?
    
    // Performance optimization
    private var preloadedPlayers: [String: AVPlayer] = [:]
    private var connectionPool: [String: URLSession] = [:]
    private let maxPreloadedPlayers = 3
    private var networkReachability = true
    private var stationHealthScores: [String: Double] = [:]
    private var streamAnalyzer = StreamAnalyzer()
    private var connectionWarmer: Timer?
    private var songRecognitionService = SongRecognitionService()
    
    private func stationKey(_ station: RadioStation) -> String {
        return "\(station.name)_\(station.frequency)"
    }
    
    override init() {
        super.init()
        setupAudioSession()
        setupNetworkMonitoring()
        loadStationsForCountry()
        updateFilteredStations()
        updateFastestStations()
        loadFavorites()
        preloadFavoriteStations()
        startConnectionWarming()
    }
    
    private func setupAudioSession() {
        do {
            // 백그라운드 재생 지원 및 최적화
            try AVAudioSession.sharedInstance().setCategory(.playback, 
                                                           mode: .default, 
                                                           options: [.mixWithOthers, .allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
            
            // 오디오 세션 최적화 - 버퍼 크기를 더 현실적으로 설정
            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(0.02) // 20ms buffer (more realistic)
            print("Audio session setup successful")
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func setupNetworkMonitoring() {
        // Monitor network changes for smooth transitions
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNetworkChange),
            name: .AVPlayerItemFailedToPlayToEndTime,
            object: nil
        )
    }
    
    private func removeNetworkMonitoring() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
    }
    
    @objc private func handleNetworkChange() {
        // Reconnect if network changes
        if currentStation != nil, isPlaying {
            print("Network changed, reconnecting...")
            play()
        }
    }
    
    private func preloadFavoriteStations() {
        // Preload favorite stations for instant playback
        Task {
            for station in favoriteStations.prefix(3) {
                guard let station = station else { continue }
                await preloadStation(station)
            }
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
    
    private func preloadStation(_ station: RadioStation) async {
        guard let url = URL(string: station.streamURL) else { return }
        
        // Create optimized session for this station
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 3.0  // Even faster timeout
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        config.httpMaximumConnectionsPerHost = 2
        config.multipathServiceType = .handover  // Use best available network
        
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
        guard let url = URL(string: station.streamURL) else { return }
        
        await MainActor.run {
            let asset = AVURLAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            
            // Ultra-aggressive buffering
            playerItem.preferredForwardBufferDuration = 0.1  // Absolute minimum
            playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
            
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
        // Auto-play when selecting a station
        play()
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    private func play() {
        guard let station = currentStation,
              let url = URL(string: station.streamURL) else { return }
        
        // Use preloaded player if available
        if let preloadedPlayer = preloadedPlayers[stationKey(station)] {
            player = preloadedPlayer
            player?.volume = volume  // Restore volume
            player?.play()
            isPlaying = true
            isLoading = false
            print("Using preloaded player for \(station.name)")
            
            // Preload next likely station
            Task {
                await predictAndPreloadNextStation()
            }
            return
        }
        
        // Clean up existing player
        removeObserver()
        player?.pause()
        player = nil  // Clear the player reference
        loadTimeoutTask?.cancel()
        isLoading = true
        loadStartTime = Date()
        
        // Set ultra-short timeout and try fallback
        loadTimeoutTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            if self.isLoading {
                print("Station load timeout after 3 seconds, trying fallback...")
                // Try alternative stream or lower quality
                self.tryAlternativeStream(for: station)
            }
        }
        
        // Handle different stream types
        if station.streamURL.contains(".m3u8") {
            // HLS stream with optimized settings
            let asset = AVURLAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            
            // Optimized for instant playback
            playerItem.preferredForwardBufferDuration = 1.0 // Balance between speed and stability
            playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
            
            if #available(iOS 15.0, *) {
                playerItem.preferredPeakBitRate = 192000 // Optimal bitrate
                playerItem.preferredMaximumResolution = .zero // Audio only
            }
            
            // Configure for low latency
            if #available(iOS 13.0, *) {
                playerItem.configuredTimeOffsetFromLive = CMTime(seconds: 0.5, preferredTimescale: 1)
            }
            
            player = AVPlayer(playerItem: playerItem)
            player?.automaticallyWaitsToMinimizeStalling = false  // Don't wait for buffer
            player?.rate = 1.0
            player?.volume = volume
            player?.play()
            
            // Force immediate playback
            if #available(iOS 12.0, *) {
                player?.playImmediately(atRate: 1.0)
            }
            
            print("Playing HLS stream: \(station.streamURL)")
            addObserver()
            // Ensure state update on main thread
            Task { @MainActor in
                self.isPlaying = true
            }
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
                }
            }
        } else {
            // Direct stream (MP3, AAC, etc) with aggressive optimization
            let asset = AVURLAsset(url: url)
            
            // Configure asset for fast loading
            if #available(iOS 10.0, *) {
                asset.resourceLoader.preloadsEligibleContentKeys = true
            }
            
            let playerItem = AVPlayerItem(asset: asset)
            
            // Ultra-fast buffering for instant playback
            playerItem.preferredForwardBufferDuration = 0.5 // Minimal buffer
            playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
            
            if #available(iOS 15.0, *) {
                playerItem.preferredPeakBitRate = 192000 // Optimal bitrate
                playerItem.preferredMaximumResolution = .zero // Audio only
            }
            
            player = AVPlayer(playerItem: playerItem)
            player?.automaticallyWaitsToMinimizeStalling = false  // Don't wait for buffer
            player?.rate = 1.0
            player?.volume = volume
            player?.play()
            
            // Force immediate playback
            if #available(iOS 12.0, *) {
                player?.playImmediately(atRate: 1.0)
            }
            
            print("Playing direct stream: \(station.streamURL)")
            addObserver()
            // Ensure state update on main thread
            Task { @MainActor in
                self.isPlaying = true
            }
        }
    }
    
    private func pause() {
        isPlaying = false
        loadTimeoutTask?.cancel()
        isLoading = false
        removeObserver()
        player?.pause()
        player = nil  // Clear player reference
    }
    
    private func addObserver() {
        guard let playerItem = player?.currentItem, !isObserving else { return }
        
        // Remove any existing observer first
        if observedPlayerItem != nil && observedPlayerItem !== playerItem {
            removeObserver()
        }
        
        playerItem.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
        observedPlayerItem = playerItem
        isObserving = true
        print("Observer added")
    }
    
    private func removeObserver() {
        guard isObserving, let observedItem = observedPlayerItem else { 
            isObserving = false
            observedPlayerItem = nil
            return 
        }
        
        // Only remove observer from the exact item we added it to
        observedItem.removeObserver(self, forKeyPath: "status", context: nil)
        isObserving = false
        observedPlayerItem = nil
        print("Observer removed successfully")
    }
    
    func adjustVolume(_ newVolume: Float) {
        volume = newVolume
        player?.volume = volume
    }
    
    func recognizeCurrentSong() {
        guard isPlaying, let player = player else { return }
        
        Task {
            // Try to get metadata from player first
            if let songInfo = await songRecognitionService.extractMetadataFromPlayer(player) {
                await MainActor.run {
                    NotificationCenter.default.post(
                        name: .songRecognized,
                        object: nil,
                        userInfo: ["songInfo": songInfo]
                    )
                }
            } else if let station = currentStation,
                      let url = URL(string: station.streamURL),
                      let songInfo = await songRecognitionService.extractMetadataFromStream(url) {
                // Try stream metadata
                await MainActor.run {
                    NotificationCenter.default.post(
                        name: .songRecognized,
                        object: nil,
                        userInfo: ["songInfo": songInfo]
                    )
                }
            } else {
                // Fall back to Shazam if no metadata
                await MainActor.run {
                    // Show alert that metadata is not available
                    print("No metadata available from stream. Shazam recognition requires microphone permission.")
                    // For now, try Shazam but it may fail without proper permissions
                    self.songRecognitionService.startShazamRecognition()
                }
                
                // Stop recognition after 10 seconds
                Task {
                    try? await Task.sleep(nanoseconds: 10_000_000_000)
                    await MainActor.run {
                        self.songRecognitionService.stopShazamRecognition()
                    }
                }
            }
        }
    }
    
    func tuneToFrequency(_ frequency: Double) {
        currentFrequency = frequency
        if let station = filteredStations.first(where: { abs($0.frequency - frequency) < 0.1 }) {
            // 다이얼 돌릴 때는 station만 설정, 재생하지 않음
            if currentStation?.id != station.id {
                currentStation = station
            }
        } else {
            if currentStation != nil {
                currentStation = nil
                pause()
            }
        }
    }
    
    // MARK: - Station Navigation
    func selectNextStation() {
        guard let currentStation = currentStation,
              let currentIndex = filteredStations.firstIndex(where: { $0.id == currentStation.id }),
              currentIndex < filteredStations.count - 1 else { return }
        
        let nextStation = filteredStations[currentIndex + 1]
        selectStation(nextStation)
    }
    
    func selectPreviousStation() {
        guard let currentStation = currentStation,
              let currentIndex = filteredStations.firstIndex(where: { $0.id == currentStation.id }),
              currentIndex > 0 else { return }
        
        let previousStation = filteredStations[currentIndex - 1]
        selectStation(previousStation)
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
        isCountrySelectionMode.toggle()
        if isCountrySelectionMode {
            // Find current country index
            if let index = Country.countries.firstIndex(where: { $0.code == selectedCountry.code }) {
                countrySelectionIndex = Double(index)
            }
        }
    }
    
    func selectCountryByIndex(_ index: Double) {
        let countries = Country.countries
        let clampedIndex = Int(max(0, min(index, Double(countries.count - 1))))
        selectedCountry = countries[clampedIndex]
        loadStationsForCountry()
    }
    
    private func loadStationsForCountry() {
        // 먼저 기본 스테이션 로드
        stations = RadioStation.stations(for: selectedCountry.code)
        updateFilteredStations()
        updateFastestStations()
        
        // API에서 실제 스테이션 가져오기
        Task {
            let apiStations = await RadioBrowserAPI.shared.fetchStations(for: selectedCountry.code)
            
            await MainActor.run {
                if !apiStations.isEmpty {
                    self.stations = apiStations
                    self.updateFilteredStations()
                    self.updateFastestStations()
                    
                    // 현재 주파수 근처 스테이션 찾기 (자동 재생 없이)
                    if let nearbyStation = self.filteredStations.first(where: { abs($0.frequency - self.currentFrequency) < 2.0 }) {
                        self.currentStation = nearbyStation
                        self.currentFrequency = nearbyStation.frequency
                    }
                }
            }
        }
        
        // 초기 스테이션 선택 (자동 재생 없이)
        if let nearbyStation = filteredStations.first(where: { abs($0.frequency - currentFrequency) < 2.0 }) {
            currentStation = nearbyStation
            currentFrequency = nearbyStation.frequency
        } else if let firstStation = filteredStations.first {
            currentStation = firstStation
            currentFrequency = firstStation.frequency
        } else {
            currentStation = nil
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
    func saveFavorite(station: RadioStation, at index: Int) {
        guard index >= 0 && index < 9 else { return }
        favoriteStations[index] = station
        saveFavorites()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    func removeFavorite(at index: Int) {
        guard index >= 0 && index < 9 else { return }
        favoriteStations[index] = nil
        saveFavorites()
    }
    
    private func saveFavorites() {
        let encoder = JSONEncoder()
        var favoritesData: [Data] = []
        
        for (index, station) in favoriteStations.enumerated() {
            if let station = station {
                if let data = try? encoder.encode(station) {
                    // Store index and data as a dictionary
                    let dict: [String: Any] = ["index": index, "data": data]
                    if let dictData = try? JSONSerialization.data(withJSONObject: dict) {
                        favoritesData.append(dictData)
                    }
                }
            }
        }
        
        UserDefaults.standard.set(favoritesData, forKey: "favoriteStations")
    }
    
    private func loadFavorites() {
        guard let favoritesData = UserDefaults.standard.object(forKey: "favoriteStations") as? [Data] else { return }
        
        let decoder = JSONDecoder()
        var loadedFavorites: [RadioStation?] = Array(repeating: nil, count: 9)
        
        for dictData in favoritesData {
            if let dict = try? JSONSerialization.jsonObject(with: dictData) as? [String: Any],
               let index = dict["index"] as? Int,
               let data = dict["data"] as? Data,
               index >= 0 && index < 9 {
                loadedFavorites[index] = try? decoder.decode(RadioStation.self, from: data)
            }
        }
        
        favoriteStations = loadedFavorites
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if let playerItem = object as? AVPlayerItem {
                switch playerItem.status {
                case .failed:
                    print("Player failed: \(playerItem.error?.localizedDescription ?? "Unknown error")")
                    isPlaying = false
                    isLoading = false
                    loadTimeoutTask?.cancel()
                    
                    // 재생 실패 - 사용자가 다시 선택하도록 함
                    print("Station failed to load - let user try another")
                case .readyToPlay:
                    print("Player ready to play")
                    isLoading = false
                    loadTimeoutTask?.cancel()
                    
                    // Record load time for this station
                    if let startTime = loadStartTime, let station = currentStation {
                        let loadTime = Date().timeIntervalSince(startTime)
                        stationLoadTimes[stationKey(station)] = loadTime
                        print("Station \(station.name) loaded in \(loadTime) seconds")
                        updateFastestStations()
                    }
                    
                    // Force play again if not playing
                    if player?.rate == 0 {
                        player?.play()
                        print("Forcing play after ready state")
                    }
                    // Ensure isPlaying is set to true
                    isPlaying = true
                case .unknown:
                    print("Player status unknown")
                default:
                    break
                }
            }
        }
    }
    
    private func tryNextStation() {
        guard let currentStation = currentStation,
              let currentIndex = filteredStations.firstIndex(where: { $0.id == currentStation.id }) else { return }
        
        // 다음 스테이션 찾기
        let nextIndex = (currentIndex + 1) % filteredStations.count
        if nextIndex != currentIndex {
            selectStation(filteredStations[nextIndex])
        }
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
        isPlaying = false
        
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
    
    deinit {
        // Clean up timer on deinit
        connectionWarmer?.invalidate()
        // Ensure observer is removed from the exact item
        if isObserving, let observedItem = observedPlayerItem {
            observedItem.removeObserver(self, forKeyPath: "status", context: nil)
            isObserving = false
            observedPlayerItem = nil
        }
        // Clean up network monitoring
        NotificationCenter.default.removeObserver(self)
    }
}