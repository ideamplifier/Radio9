import SwiftUI

struct FrequencyDialView: View {
    @Binding var frequency: Double
    let range: ClosedRange<Double> = 88.0...108.0
    @State private var isInteracting = false
    
    var body: some View {
        GeometryReader { geometry in
            let dialSize = min(geometry.size.width, geometry.size.height)
            let markerCount = 40
            
            ZStack {
                // Outer ring
                Circle()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                
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
            .scaleEffect(isInteracting ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isInteracting)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isInteracting {
                            isInteracting = true
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                        
                        let angle = atan2(value.location.x - dialSize/2, 
                                         dialSize/2 - value.location.y)
                        let degrees = angle * 180 / .pi
                        let normalizedDegrees = degrees < 0 ? degrees + 360 : degrees
                        
                        let frequencyRange = range.upperBound - range.lowerBound
                        let newFrequency = range.lowerBound + (normalizedDegrees / 360.0) * frequencyRange
                        
                        let oldFrequency = frequency
                        frequency = min(max(newFrequency, range.lowerBound), range.upperBound)
                        
                        // Haptic feedback at major frequencies
                        if Int(oldFrequency) != Int(frequency) {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
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