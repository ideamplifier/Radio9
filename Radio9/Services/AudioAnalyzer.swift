import Foundation
import AVFoundation

class AudioAnalyzer: ObservableObject {
    // 주파수 대역별 레벨 (0.0 ~ 1.0)
    @Published var frequencyBands: [Float] = Array(repeating: 0.0, count: 6)
    
    // 콘텐츠 타입 감지
    @Published var contentType: AudioContentType = .speech
    
    // 비트 감지
    @Published var beatDetected: Bool = false
    
    private var updateTimer: Timer?
    private var animationTimer: Timer?
    private var currentStation: String?
    
    // 이전 프레임 값들 (비트 감지용)
    private var beatHistory: [Float] = Array(repeating: 0.0, count: 30)
    private var beatHistoryIndex = 0
    
    enum AudioContentType {
        case speech
        case music
    }
    
    init() {
        // Initialize with demo animation
    }
    
    func startAnalyzing(player: AVPlayer) {
        // For now, we'll simulate the audio analysis with demo patterns
        // Real audio tap processing is complex on iOS for streaming content
        
        // Stop any existing timers
        stopAnalyzing()
        
        // Determine content type based on station (this would normally be done with real audio analysis)
        // For demo purposes, we'll randomly assign or you can check station metadata
        determineContentType()
        
        // Start appropriate animation
        startAnimation()
    }
    
    func stopAnalyzing() {
        updateTimer?.invalidate()
        animationTimer?.invalidate()
        updateTimer = nil
        animationTimer = nil
        
        // Clear bands
        DispatchQueue.main.async {
            self.frequencyBands = Array(repeating: 0.0, count: 6)
            self.beatDetected = false
        }
    }
    
    private func determineContentType() {
        // For demo, randomly determine or base on time of day
        // Real implementation would analyze audio characteristics
        let hour = Calendar.current.component(.hour, from: Date())
        
        // Morning/evening hours more likely to be talk radio
        if (6...9).contains(hour) || (17...19).contains(hour) {
            contentType = .speech
        } else {
            contentType = .music
        }
    }
    
    private func startAnimation() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if self.contentType == .speech {
                    self.animateSpeechPattern()
                } else {
                    self.animateMusicPattern()
                }
            }
        }
    }
    
    private func animateSpeechPattern() {
        // Gentle waves for speech - only bottom 3 rows
        let time = Date().timeIntervalSinceReferenceDate
        
        for i in 0..<6 {
            // Create smooth, slow waves
            let phase = Double(i) * 0.5
            let wave = sin(time * 2.0 + phase) * 0.3 + 0.2
            
            // Add some gentle randomness
            let randomness = Float.random(in: -0.05...0.05)
            
            // Limit to bottom 3 rows (0.5 max)
            frequencyBands[i] = min(0.5, Float(wave) + randomness)
        }
    }
    
    private func animateMusicPattern() {
        // Dynamic patterns for music
        let time = Date().timeIntervalSinceReferenceDate
        
        // Simulate bass kick (bands 0-1)
        let kickPattern = sin(time * 4.0) > 0.7
        if kickPattern {
            frequencyBands[0] = Float.random(in: 0.7...0.9)
            frequencyBands[1] = Float.random(in: 0.6...0.8)
            
            // Trigger beat detection
            if !beatDetected {
                beatDetected = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.beatDetected = false
                }
            }
        } else {
            frequencyBands[0] *= 0.85
            frequencyBands[1] *= 0.85
        }
        
        // Mid frequencies (bands 2-3) - melodic content
        for i in 2...3 {
            let phase = Double(i - 2) * 1.5
            let melody = sin(time * 3.0 + phase) * 0.4 + 0.3
            frequencyBands[i] = Float(melody) + Float.random(in: -0.1...0.1)
        }
        
        // High frequencies (bands 4-5) - hi-hats, cymbals
        for i in 4...5 {
            let hihat = sin(time * 8.0) > 0.5
            if hihat {
                frequencyBands[i] = Float.random(in: 0.3...0.5)
            } else {
                frequencyBands[i] *= 0.7
            }
        }
        
        // Ensure all values are in valid range
        for i in 0..<6 {
            frequencyBands[i] = max(0, min(1, frequencyBands[i]))
        }
    }
    
    deinit {
        stopAnalyzing()
    }
}