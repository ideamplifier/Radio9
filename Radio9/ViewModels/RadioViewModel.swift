import Foundation
import AVFoundation
import Combine

@MainActor
class RadioViewModel: ObservableObject {
    @Published var currentStation: RadioStation?
    @Published var isPlaying = false
    @Published var volume: Float = 0.7
    @Published var stations: [RadioStation] = RadioStation.sampleStations
    @Published var currentFrequency: Double = 89.1
    
    private var player: AVPlayer?
    
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
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
        
        player?.pause()
        player = AVPlayer(url: url)
        player?.volume = volume
        player?.play()
        isPlaying = true
    }
    
    private func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func adjustVolume(_ newVolume: Float) {
        volume = newVolume
        player?.volume = volume
    }
    
    func tuneToFrequency(_ frequency: Double) {
        currentFrequency = frequency
        if let station = stations.first(where: { abs($0.frequency - frequency) < 0.1 }) {
            selectStation(station)
        } else {
            currentStation = nil
            pause()
        }
    }
}