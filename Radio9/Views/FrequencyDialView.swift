import SwiftUI

struct FrequencyDialView: View {
    @Binding var frequency: Double
    let range: ClosedRange<Double> = 88.0...108.0
    @State private var isInteracting = false
    @State private var startLocation: CGPoint = .zero
    @State private var startFrequency: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            let dialSize = min(geometry.size.width, geometry.size.height)
            let markerCount = 40
            
            ZStack {
                // Outer ring with warm glow effect
                Circle()
                    .fill(Color.white)
                    .shadow(color: isInteracting ? 
                            Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.2) : 
                            Color.black.opacity(0.08), 
                            radius: isInteracting ? 20 : 12, x: 0, y: 6)
                    .animation(.easeInOut(duration: 0.3), value: isInteracting)
                
                // Inner ring border
                Circle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                    .padding(20)
                
                // Frequency markers
                ForEach(0..<markerCount, id: \.self) { index in
                    Rectangle()
                        .fill(Color.gray.opacity(index % 5 == 0 ? 0.7 : 0.4))
                        .frame(width: index % 5 == 0 ? 2 : 1, 
                               height: index % 5 == 0 ? 16 : 10)
                        .offset(y: -dialSize/2 + 35)
                        .rotationEffect(.degrees(Double(index) * 360.0 / Double(markerCount)))
                }
                
                // Center display area - simpler without frequency display
                Circle()
                    .fill(Color.white)
                    .frame(width: dialSize * 0.65, height: dialSize * 0.65)
                    .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
                
            }
            .frame(width: dialSize, height: dialSize)
            .rotationEffect(.degrees(normalizedAngle))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !isInteracting {
                            isInteracting = true
                            startLocation = value.startLocation
                            startFrequency = frequency
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                        
                        // Calculate rotation based on drag distance, not absolute position
                        if value.translation.width != 0 || value.translation.height != 0 {
                            let startAngle = atan2(startLocation.x - dialSize/2, 
                                                 dialSize/2 - startLocation.y)
                            let currentAngle = atan2(value.location.x - dialSize/2, 
                                                   dialSize/2 - value.location.y)
                            
                            var angleDelta = (currentAngle - startAngle) * 180 / .pi
                            
                            // Handle angle wrap-around
                            if angleDelta > 180 {
                                angleDelta -= 360
                            } else if angleDelta < -180 {
                                angleDelta += 360
                            }
                            
                            let frequencyRange = range.upperBound - range.lowerBound
                            let frequencyDelta = (angleDelta / 360.0) * frequencyRange
                            let newFrequency = startFrequency + frequencyDelta
                            
                            let oldFrequency = frequency
                            frequency = min(max(newFrequency, range.lowerBound), range.upperBound)
                            
                            // Haptic feedback at major frequencies
                            if Int(oldFrequency) != Int(frequency) {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                        }
                    }
                    .onEnded { _ in
                        isInteracting = false
                    }
            )
            .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.85), value: frequency)
        }
    }
    
    private var normalizedAngle: Double {
        let frequencyRange = range.upperBound - range.lowerBound
        let normalizedFrequency = (frequency - range.lowerBound) / frequencyRange
        return normalizedFrequency * 360
    }
}