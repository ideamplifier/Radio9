import Foundation
import AVFoundation
import Combine
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
    private var stationLoadTimes: [String: TimeInterval] = [:]
    private var loadStartTime: Date?
    private var loadTimeoutTask: Task<Void, Never>?
    
    private func stationKey(_ station: RadioStation) -> String {
        return "\(station.name)_\(station.frequency)"
    }
    
    override init() {
        super.init()
        setupAudioSession()
        loadStationsForCountry()
        updateFilteredStations()
        updateFastestStations()
        loadFavorites()
    }
    
    private func setupAudioSession() {
        do {
            // 백그라운드 재생 지원
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
            print("Audio session setup successful")
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func selectStation(_ station: RadioStation) {
        currentStation = station
        currentFrequency = station.frequency
        if isPlaying {
            play()
        }
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
        
        // Clean up existing player
        removeObserver()
        player?.pause()
        loadTimeoutTask?.cancel()
        isLoading = true
        loadStartTime = Date()
        
        // Set timeout for slow connections
        loadTimeoutTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds
            if self.isLoading {
                print("Station load timeout after 10 seconds")
                self.isLoading = false
                self.isPlaying = false
                // Don't automatically try next station - let user choose
            }
        }
        
        // Handle different stream types
        if station.streamURL.contains(".m3u8") {
            // HLS stream with optimized settings
            let asset = AVURLAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            
            // Aggressive optimization for fast loading
            playerItem.preferredForwardBufferDuration = 2.0 // Increase buffer for stability
            if #available(iOS 15.0, *) {
                playerItem.preferredPeakBitRate = 256000 // Increase bitrate for better quality
            }
            
            player = AVPlayer(playerItem: playerItem)
            player?.automaticallyWaitsToMinimizeStalling = true
            player?.rate = 1.0
            player?.volume = volume
            player?.play()
            
            print("Playing HLS stream: \(station.streamURL)")
            isPlaying = true
            addObserver()
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
                                self.isPlaying = true
                                self.addObserver()
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
            let playerItem = AVPlayerItem(url: url)
            
            // Balanced buffering for stability
            playerItem.preferredForwardBufferDuration = 2.0
            if #available(iOS 15.0, *) {
                playerItem.preferredPeakBitRate = 256000 // Good quality
            }
            
            player = AVPlayer(playerItem: playerItem)
            player?.automaticallyWaitsToMinimizeStalling = true
            player?.rate = 1.0
            player?.volume = volume
            player?.play()
            
            print("Playing direct stream: \(station.streamURL)")
            isPlaying = true
            addObserver()
        }
    }
    
    private func pause() {
        removeObserver()
        player?.pause()
        isPlaying = false
        loadTimeoutTask?.cancel()
        isLoading = false
    }
    
    private func addObserver() {
        guard !isObserving, player?.currentItem != nil else { return }
        player?.currentItem?.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
        isObserving = true
    }
    
    private func removeObserver() {
        guard isObserving, player?.currentItem != nil else { return }
        player?.currentItem?.removeObserver(self, forKeyPath: "status", context: nil)
        isObserving = false
    }
    
    func adjustVolume(_ newVolume: Float) {
        volume = newVolume
        player?.volume = volume
    }
    
    func tuneToFrequency(_ frequency: Double) {
        currentFrequency = frequency
        if let station = filteredStations.first(where: { abs($0.frequency - frequency) < 0.1 }) {
            selectStation(station)
        } else {
            currentStation = nil
            pause()
        }
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
                    
                    // 현재 주파수 근처 스테이션 찾기
                    if let nearbyStation = self.filteredStations.first(where: { abs($0.frequency - self.currentFrequency) < 2.0 }) {
                        self.selectStation(nearbyStation)
                    }
                }
            }
        }
        
        // 초기 스테이션 선택
        if let nearbyStation = filteredStations.first(where: { abs($0.frequency - currentFrequency) < 2.0 }) {
            selectStation(nearbyStation)
        } else if let firstStation = filteredStations.first {
            selectStation(firstStation)
        } else {
            currentStation = nil
            pause()
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
    
    deinit {
        // Observer is removed in pause() method when needed
        // No need to remove here as deinit is not on main actor
    }
}