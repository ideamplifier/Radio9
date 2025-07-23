import SwiftUI

struct IndependentDialView: View {
    let frequency: Double
    let isCountrySelectionMode: Bool
    let countrySelectionIndex: Double
    let onFrequencyChange: (Double) -> Void
    let onCountryChange: (Double) -> Void
    
    @State private var dialRotation: Double = 0
    @State private var isInteracting = false
    @State private var lastAngle: Double = 0
    @State private var lastHapticRotation: Double = 0
    
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .soft)
    
    let range: ClosedRange<Double> = 88.0...108.0
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            
            ZStack {
                // Background dial
                DialBackground(size: size, isInteracting: isInteracting)
                
                // Markers
                DialMarkers(size: size, isCountrySelectionMode: isCountrySelectionMode)
                    .rotationEffect(.degrees(dialRotation))
                    .animation(isInteracting ? .none : .easeInOut(duration: 0.3), value: dialRotation)
                
                // Center
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.65, height: size * 0.65)
                    .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
            }
            .frame(width: size, height: size)
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        handleDrag(value: value, in: geometry)
                    }
                    .onEnded { _ in
                        withAnimation(.easeOut(duration: 0.2)) {
                            isInteracting = false
                        }
                    }
            )
        }
    }
    
    private func handleDrag(value: DragGesture.Value, in geometry: GeometryProxy) {
        let center = CGPoint(x: geometry.size.width/2, y: geometry.size.height/2)
        let angle = atan2(value.location.y - center.y, value.location.x - center.x)
        
        if !isInteracting {
            isInteracting = true
            lastAngle = angle
            lastHapticRotation = dialRotation
            hapticGenerator.prepare()
            hapticGenerator.impactOccurred(intensity: 0.7)
            return
        }
        
        var deltaAngle = angle - lastAngle
        
        // Handle wrap around
        if deltaAngle > .pi {
            deltaAngle -= 2 * .pi
        } else if deltaAngle < -.pi {
            deltaAngle += 2 * .pi
        }
        
        // Update rotation
        dialRotation += deltaAngle * 180 / .pi
        lastAngle = angle
        
        // Haptic feedback every 5 degrees
        let rotationDiff = abs(dialRotation - lastHapticRotation)
        if rotationDiff >= 5.0 {
            hapticGenerator.impactOccurred(intensity: 0.7)
            lastHapticRotation = dialRotation
        }
        
        // Calculate value from rotation
        let rotations = dialRotation / 360.0
        
        if isCountrySelectionMode {
            let countryCount = Double(Country.countries.count)
            var newIndex = (rotations.truncatingRemainder(dividingBy: 1) + 1) * countryCount
            if newIndex < 0 { newIndex += countryCount }
            onCountryChange(newIndex.truncatingRemainder(dividingBy: countryCount))
        } else {
            let frequencyRange = range.upperBound - range.lowerBound
            var newFrequency = range.lowerBound + (rotations.truncatingRemainder(dividingBy: 1) + 1) * frequencyRange
            
            while newFrequency > range.upperBound {
                newFrequency -= frequencyRange
            }
            while newFrequency < range.lowerBound {
                newFrequency += frequencyRange
            }
            
            onFrequencyChange(newFrequency)
        }
    }
}

struct DialBackground: View {
    let size: CGFloat
    let isInteracting: Bool
    
    var body: some View {
        Circle()
            .fill(Color.white)
            .overlay(
                Circle()
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            )
            .shadow(
                color: isInteracting ? 
                    Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.2) : 
                    Color.black.opacity(0.08),
                radius: isInteracting ? 20 : 12,
                x: 0, y: 6
            )
        
        Circle()
            .stroke(Color.gray.opacity(0.15), lineWidth: 1)
            .padding(20)
    }
}

struct DialMarkers: View {
    let size: CGFloat
    let markerCount = 40
    let isCountrySelectionMode: Bool
    
    var body: some View {
        ZStack {
            ForEach(0..<markerCount, id: \.self) { index in
                Rectangle()
                    .fill(
                        isCountrySelectionMode ?
                        Color(red: 1.0, green: 0.8, blue: 0.4).opacity(index % 5 == 0 ? 0.8 : 0.5) :
                        Color.gray.opacity(index % 5 == 0 ? 0.7 : 0.4)
                    )
                    .frame(width: index % 5 == 0 ? 2 : 1, 
                           height: index % 5 == 0 ? 16 : 10)
                    .offset(y: -size/2 + 35)
                    .rotationEffect(.degrees(Double(index) * 360.0 / Double(markerCount)))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isCountrySelectionMode)
    }
}