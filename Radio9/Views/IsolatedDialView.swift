import SwiftUI

struct IsolatedDialView: View {
    @Binding var frequency: Double
    let isCountrySelectionMode: Bool
    let countrySelectionIndex: Double
    let onFrequencyChange: (Double) -> Void
    let onCountryIndexChange: (Double) -> Void
    
    @State private var dialAngle: Double = 0
    @State private var isInteracting = false
    @State private var startLocation: CGPoint = .zero
    @State private var startAngle: Double = 0
    
    let range: ClosedRange<Double> = 88.0...108.0
    
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
                
                // Center display area
                Circle()
                    .fill(Color.white)
                    .frame(width: dialSize * 0.65, height: dialSize * 0.65)
                    .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
            }
            .frame(width: dialSize, height: dialSize)
            .rotationEffect(.degrees(dialAngle))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !isInteracting {
                            isInteracting = true
                            startLocation = value.startLocation
                            startAngle = dialAngle
                            HapticManager.shared.impact(style: .light)
                        }
                        
                        // Calculate rotation based on drag
                        let center = CGPoint(x: dialSize/2, y: dialSize/2)
                        let startRadians = atan2(startLocation.y - center.y, startLocation.x - center.x)
                        let currentRadians = atan2(value.location.y - center.y, value.location.x - center.x)
                        
                        var angleDelta = (currentRadians - startRadians) * 180 / .pi
                        
                        // Handle angle wrap-around
                        if angleDelta > 180 {
                            angleDelta -= 360
                        } else if angleDelta < -180 {
                            angleDelta += 360
                        }
                        
                        // Update dial angle
                        dialAngle = startAngle + angleDelta
                        
                        // Calculate actual value change
                        if isCountrySelectionMode {
                            let countryCount = Double(Country.countries.count)
                            let normalizedAngle = dialAngle.truncatingRemainder(dividingBy: 360)
                            let positiveAngle = normalizedAngle < 0 ? normalizedAngle + 360 : normalizedAngle
                            let newIndex = (positiveAngle / 360.0) * countryCount
                            onCountryIndexChange(newIndex)
                        } else {
                            let normalizedAngle = dialAngle.truncatingRemainder(dividingBy: 360)
                            let positiveAngle = normalizedAngle < 0 ? normalizedAngle + 360 : normalizedAngle
                            let newFrequency = range.lowerBound + (positiveAngle / 360.0) * (range.upperBound - range.lowerBound)
                            onFrequencyChange(newFrequency)
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.easeOut(duration: 0.2)) {
                            isInteracting = false
                        }
                    }
            )
            .onAppear {
                // Initialize dial angle based on current value
                if isCountrySelectionMode {
                    dialAngle = (countrySelectionIndex / Double(Country.countries.count)) * 360
                } else {
                    let normalizedFrequency = (frequency - range.lowerBound) / (range.upperBound - range.lowerBound)
                    dialAngle = normalizedFrequency * 360
                }
            }
        }
    }
}