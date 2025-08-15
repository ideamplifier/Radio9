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
    private var currentStationName: String = ""
    
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
    
    func startAnalyzingForNature(stationName: String) {
        // Stop any existing timers
        stopAnalyzing()
        
        // Store station name for pattern selection
        currentStationName = stationName
        contentType = .music
        
        // Start nature-specific animation
        startNatureAnimation()
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
    
    private func startNatureAnimation() {
        // Nature-specific patterns
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.animateNaturePattern()
            }
        }
    }
    
    private func animateNaturePattern() {
        let time = Date().timeIntervalSinceReferenceDate
        
        switch currentStationName {
        case "Tokyo Rain FM", "Drizzle FM":
            // Rain: Mid-frequency emphasis with random drops
            frequencyBands[0] = Float.random(in: 0.1...0.2)  // Sub-bass
            frequencyBands[1] = Float.random(in: 0.2...0.3)  // Bass
            frequencyBands[2] = Float.random(in: 0.4...0.6)  // Low-mid (rain hits)
            frequencyBands[3] = Float.random(in: 0.5...0.7)  // Mid (main rain)
            frequencyBands[4] = Float.random(in: 0.3...0.5)  // High-mid
            frequencyBands[5] = Float.random(in: 0.2...0.3)  // High
            
        case "Rooftop Rain FM":
            // Rooftop rain: More metallic/percussive sound
            frequencyBands[0] = Float.random(in: 0.05...0.15)  // Sub-bass (minimal)
            frequencyBands[1] = Float.random(in: 0.15...0.25)  // Bass
            frequencyBands[2] = Float.random(in: 0.3...0.5)  // Low-mid (impact)
            frequencyBands[3] = Float.random(in: 0.6...0.8)  // Mid (metallic hits)
            frequencyBands[4] = Float.random(in: 0.5...0.7)  // High-mid (splashing)
            frequencyBands[5] = Float.random(in: 0.4...0.6)  // High (roof resonance)
            
        case "Pacific Ocean FM":
            // Waves: Low frequency rolling pattern
            let wave = sin(time * 0.5) * 0.3 + 0.5
            frequencyBands[0] = Float(wave) + Float.random(in: -0.1...0.1)  // Sub-bass (deep waves)
            frequencyBands[1] = Float(wave * 0.8) + Float.random(in: -0.1...0.1)  // Bass
            frequencyBands[2] = Float(wave * 0.6) + Float.random(in: -0.05...0.05)  // Low-mid
            frequencyBands[3] = Float(wave * 0.4)  // Mid
            frequencyBands[4] = Float.random(in: 0.1...0.2)  // High-mid (foam)
            frequencyBands[5] = Float.random(in: 0.05...0.15)  // High
            
        case "Night Cricket FM":
            // Crickets: High frequency pulses
            let pulse = (sin(time * 8) + 1) * 0.5  // Fast pulse for cricket chirps
            frequencyBands[0] = Float.random(in: 0.05...0.1)  // Sub-bass
            frequencyBands[1] = Float.random(in: 0.05...0.1)  // Bass
            frequencyBands[2] = Float.random(in: 0.1...0.15)  // Low-mid
            frequencyBands[3] = Float.random(in: 0.15...0.25)  // Mid
            frequencyBands[4] = Float(pulse * 0.4) + Float.random(in: -0.05...0.05)  // High-mid
            frequencyBands[5] = Float(pulse * 0.6) + Float.random(in: -0.1...0.1)  // High (cricket chirps)
            
        case "Campfire Radio":
            // Fire: Random crackling across mid frequencies
            frequencyBands[0] = Float.random(in: 0.2...0.3)  // Sub-bass
            frequencyBands[1] = Float.random(in: 0.3...0.5)  // Bass (wood pops)
            frequencyBands[2] = Float.random(in: 0.3...0.6)  // Low-mid (crackling)
            frequencyBands[3] = Float.random(in: 0.4...0.7)  // Mid (main fire)
            frequencyBands[4] = Float.random(in: 0.2...0.4)  // High-mid
            frequencyBands[5] = Float.random(in: 0.1...0.2)  // High
            
        case "Thunder Storm FM":
            // Thunder: Occasional bass spikes
            let thunder = Int.random(in: 0...100) < 5  // 5% chance of thunder
            if thunder {
                frequencyBands[0] = Float.random(in: 0.7...0.9)  // Sub-bass (thunder rumble)
                frequencyBands[1] = Float.random(in: 0.6...0.8)  // Bass
            } else {
                frequencyBands[0] = Float.random(in: 0.2...0.3)  // Sub-bass
                frequencyBands[1] = Float.random(in: 0.2...0.3)  // Bass
            }
            frequencyBands[2] = Float.random(in: 0.3...0.5)  // Low-mid (rain)
            frequencyBands[3] = Float.random(in: 0.4...0.6)  // Mid (rain)
            frequencyBands[4] = Float.random(in: 0.3...0.4)  // High-mid
            frequencyBands[5] = Float.random(in: 0.2...0.3)  // High
            
        case "Morning Birds FM":
            // Birds: High frequency chirps
            let chirp = sin(time * 15 + Double.random(in: 0...2)) * 0.5 + 0.5
            frequencyBands[0] = Float.random(in: 0.05...0.1)  // Sub-bass
            frequencyBands[1] = Float.random(in: 0.05...0.1)  // Bass
            frequencyBands[2] = Float.random(in: 0.1...0.2)  // Low-mid
            frequencyBands[3] = Float.random(in: 0.2...0.3)  // Mid
            frequencyBands[4] = Float(chirp * 0.5) + Float.random(in: -0.1...0.1)  // High-mid
            frequencyBands[5] = Float(chirp * 0.7) + Float.random(in: -0.1...0.1)  // High (bird chirps)
            
        case "Mountain Stream FM":
            // Stream: Consistent mid-high frequency water flow
            let flow = sin(time * 2) * 0.1 + 0.4  // Gentle variation
            frequencyBands[0] = Float.random(in: 0.1...0.15)  // Sub-bass
            frequencyBands[1] = Float.random(in: 0.15...0.25)  // Bass
            frequencyBands[2] = Float(flow) + Float.random(in: -0.05...0.05)  // Low-mid
            frequencyBands[3] = Float(flow * 1.2) + Float.random(in: -0.1...0.1)  // Mid (water flow)
            frequencyBands[4] = Float(flow * 1.1) + Float.random(in: -0.1...0.1)  // High-mid (bubbling)
            frequencyBands[5] = Float.random(in: 0.3...0.4)  // High (splashing)
            
        case "Static":
            // Static: Random noise across all frequencies
            for i in 0..<6 {
                frequencyBands[i] = Float.random(in: 0.05...0.25)  // Low amplitude random
            }
            
        case "Glitch":
            // Glitch: Erratic spikes
            let glitch = Int.random(in: 0...100) < 20  // 20% chance of glitch spike
            if glitch {
                let band = Int.random(in: 0...5)
                frequencyBands[band] = Float.random(in: 0.6...0.9)
                // Other bands normal
                for i in 0..<6 where i != band {
                    frequencyBands[i] = Float.random(in: 0.1...0.2)
                }
            } else {
                for i in 0..<6 {
                    frequencyBands[i] = Float.random(in: 0.05...0.15)
                }
            }
            
        case "Epic Thunder FM":
            // Epic thunder: Deep rumbling with dramatic peaks
            let thunderStrike = Int.random(in: 0...100) < 15  // 15% chance of thunder strike
            if thunderStrike {
                // Thunder strike - all bands spike
                frequencyBands[0] = Float.random(in: 0.8...1.0)  // Sub-bass (massive rumble)
                frequencyBands[1] = Float.random(in: 0.7...0.95)  // Bass (deep thunder)
                frequencyBands[2] = Float.random(in: 0.6...0.85)  // Low-mid (power)
                frequencyBands[3] = Float.random(in: 0.5...0.75)  // Mid (crack)
                frequencyBands[4] = Float.random(in: 0.4...0.65)  // High-mid (echo)
                frequencyBands[5] = Float.random(in: 0.3...0.5)  // High (sizzle)
            } else {
                // Rolling thunder ambience
                frequencyBands[0] = Float.random(in: 0.3...0.5)  // Sub-bass (continuous rumble)
                frequencyBands[1] = Float.random(in: 0.25...0.45)  // Bass
                frequencyBands[2] = Float.random(in: 0.2...0.35)  // Low-mid
                frequencyBands[3] = Float.random(in: 0.15...0.25)  // Mid
                frequencyBands[4] = Float.random(in: 0.1...0.2)  // High-mid
                frequencyBands[5] = Float.random(in: 0.05...0.15)  // High
            }
            
        case "Hokkaido Blizzard FM":
            // Snowstorm: Howling wind with whistling highs
            let gust = Int.random(in: 0...100) < 30  // 30% chance of strong gust
            if gust {
                // Strong wind gust
                frequencyBands[0] = Float.random(in: 0.15...0.25)  // Sub-bass (minimal)
                frequencyBands[1] = Float.random(in: 0.2...0.35)  // Bass (low rumble)
                frequencyBands[2] = Float.random(in: 0.4...0.6)  // Low-mid (wind body)
                frequencyBands[3] = Float.random(in: 0.5...0.7)  // Mid (howling)
                frequencyBands[4] = Float.random(in: 0.6...0.85)  // High-mid (whistling)
                frequencyBands[5] = Float.random(in: 0.7...0.9)  // High (sharp whistle)
            } else {
                // Steady blizzard wind
                frequencyBands[0] = Float.random(in: 0.05...0.15)  // Sub-bass
                frequencyBands[1] = Float.random(in: 0.1...0.2)  // Bass
                frequencyBands[2] = Float.random(in: 0.25...0.4)  // Low-mid
                frequencyBands[3] = Float.random(in: 0.35...0.5)  // Mid
                frequencyBands[4] = Float.random(in: 0.4...0.55)  // High-mid
                frequencyBands[5] = Float.random(in: 0.45...0.6)  // High
            }
            
        default:
            // Default pattern for unknown stations
            for i in 0..<6 {
                frequencyBands[i] = Float.random(in: 0.1...0.3)
            }
        }
        
        // Ensure all values are within 0...1 range
        for i in 0..<6 {
            frequencyBands[i] = max(0, min(1, frequencyBands[i]))
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