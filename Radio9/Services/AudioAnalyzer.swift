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
        // Always use music pattern for better visual effect
        // Real implementation would analyze audio characteristics
        contentType = .music
    }
    
    private func startAnimation() {
        // 업데이트 주기를 0.1초(10Hz)로 감소하여 rate-limit 문제 해결
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
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
        // Dynamic patterns for music - more varied and energetic
        let time = Date().timeIntervalSinceReferenceDate
        
        // Bass frequencies (bands 0-1) - strong beats
        let bassPhase = sin(time * 3.5)
        let kickPattern = bassPhase > 0.6 || sin(time * 7.0) > 0.8
        
        if kickPattern {
            frequencyBands[0] = Float.random(in: 0.6...1.0)
            frequencyBands[1] = Float.random(in: 0.5...0.9)
            
            // Trigger beat detection
            if !beatDetected && bassPhase > 0.8 {
                beatDetected = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    self.beatDetected = false
                }
            }
        } else {
            frequencyBands[0] = max(0.2, frequencyBands[0] * 0.88)
            frequencyBands[1] = max(0.15, frequencyBands[1] * 0.86)
        }
        
        // Mid-low frequencies (band 2) - groove
        let groove = sin(time * 5.0) * 0.3 + 0.4
        frequencyBands[2] = Float(groove) + Float.random(in: -0.1...0.2)
        
        // Mid frequencies (band 3) - melody range
        let melody = sin(time * 8.0 + 1.0) * 0.25 + cos(time * 3.0) * 0.15 + 0.35
        frequencyBands[3] = Float(melody) + Float.random(in: -0.05...0.15)
        
        // High-mid frequencies (band 4) - harmonics
        let harmonics = sin(time * 12.0) * 0.2 + cos(time * 6.5) * 0.15 + 0.3
        frequencyBands[4] = Float(harmonics) + Float.random(in: -0.1...0.2)
        
        // High frequencies (band 5) - shimmer
        let shimmer = abs(sin(time * 15.0)) * 0.3 + 0.2
        frequencyBands[5] = Float(shimmer) + Float.random(in: -0.05...0.25)
        
        // Ensure all bands stay within valid range
        for i in 0..<6 {
            frequencyBands[i] = min(1.0, max(0.0, frequencyBands[i]))
        }
    }
    
    deinit {
        stopAnalyzing()
    }
}