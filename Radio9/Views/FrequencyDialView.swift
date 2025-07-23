import SwiftUI

struct FrequencyDialView: View {
    @Binding var frequency: Double
    @ObservedObject var viewModel: RadioViewModel
    let range: ClosedRange<Double> = 88.0...108.0
    @State private var isInteracting = false
    @State private var startLocation: CGPoint = .zero
    @State private var startFrequency: Double = 0
    @State private var startCountryIndex: Double = 0
    @State private var currentRotation: Double = 0
    
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
                
                // Center display area - simpler without frequency display
                Circle()
                    .fill(Color.white)
                    .frame(width: dialSize * 0.65, height: dialSize * 0.65)
                    .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
                
            }
            .frame(width: dialSize, height: dialSize)
            .rotationEffect(.degrees(currentRotation))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !isInteracting {
                            isInteracting = true
                            startLocation = value.startLocation
                            startFrequency = frequency
                            startCountryIndex = viewModel.countrySelectionIndex
                            currentRotation = normalizedAngle  // Reset to current angle
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                        
                        // Calculate rotation based on drag - moved center calculation outside
                        let center = CGPoint(x: geometry.size.width/2, y: geometry.size.height/2)
                        let startAngle = atan2(startLocation.y - center.y, startLocation.x - center.x)
                        let currentAngle = atan2(value.location.y - center.y, value.location.x - center.x)
                        
                        var angleDelta = (currentAngle - startAngle) * 180 / .pi
                        
                        // Handle angle wrap-around
                        if angleDelta > 180 {
                            angleDelta -= 360
                        } else if angleDelta < -180 {
                            angleDelta += 360
                        }
                        
                        // Update rotation immediately without affecting frequency
                        currentRotation += angleDelta
                        
                        if viewModel.isCountrySelectionMode {
                            // Country selection mode
                            let countryCount = Double(Country.countries.count)
                            let indexDelta = (angleDelta / 720.0) * countryCount
                            let newIndex = startCountryIndex + indexDelta
                            
                            let oldIndex = Int(viewModel.countrySelectionIndex)
                            viewModel.countrySelectionIndex = max(0, min(newIndex, countryCount - 1))
                            viewModel.selectCountryByIndex(viewModel.countrySelectionIndex)
                            
                            // Haptic feedback when changing country
                            if oldIndex != Int(viewModel.countrySelectionIndex) {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                        } else {
                            // Normal frequency tuning mode - allow multiple rotations
                            let rotations = angleDelta / 360.0
                            let frequencyRange = range.upperBound - range.lowerBound
                            let frequencyDelta = rotations * frequencyRange
                            var newFrequency = startFrequency + frequencyDelta
                            
                            // Handle wrap-around
                            while newFrequency > range.upperBound {
                                newFrequency -= frequencyRange
                            }
                            while newFrequency < range.lowerBound {
                                newFrequency += frequencyRange
                            }
                            
                            let oldFrequency = frequency
                            frequency = newFrequency
                            
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
            .onAppear {
                currentRotation = normalizedAngle
            }
            .onChange(of: frequency) { _ in
                if !isInteracting {
                    currentRotation = normalizedAngle
                }
            }
        }
    }
    
    private var normalizedAngle: Double {
        if viewModel.isCountrySelectionMode {
            // Country selection mode - use index
            let countryCount = Double(Country.countries.count)
            return (viewModel.countrySelectionIndex / countryCount) * 360
        } else {
            // Frequency mode
            let frequencyRange = range.upperBound - range.lowerBound
            let normalizedFrequency = (frequency - range.lowerBound) / frequencyRange
            return normalizedFrequency * 360
        }
    }
}