import SwiftUI

struct IndependentDialView: View {
    let frequency: Double
    let isCountrySelectionMode: Bool
    let countrySelectionIndex: Double
    let onFrequencyChange: (Double) -> Void
    let onCountryChange: (Double) -> Void
    let onFavoritesButtonTap: () -> Void
    let onDialLongPress: () -> Void
    @Binding var isInteracting: Bool
    let showFavoritesDot: Bool
    
    @State private var dialRotation: Double = 0
    @State private var lastAngle: Double = 0
    @State private var lastHapticRotation: Double = 0
    @State private var isLongPressing = false
    @State private var accumulatedRotation: Double = 0  // Total rotation accumulated
    @State private var isInitialized = false
    @State private var favoritesDotScale: CGFloat = 0.0
    @State private var favoritesDotOpacity: Double = 0.0
    
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .soft)
    private let hardStopHaptic = UIImpactFeedbackGenerator(style: .rigid)
    
    let range: ClosedRange<Double> = 88.0...108.0
    private let degreesPerMHz: Double = 36.0  // 720 degrees (2 full rotations) for 20MHz range
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            
            ZStack {
                // Background dial
                DialBackground(size: size, isInteracting: isInteracting)
                
                // Markers
                DialMarkers(size: size, isCountrySelectionMode: isCountrySelectionMode)
                    .rotationEffect(.degrees(dialRotation))
                    .onAppear {
                        if !isInitialized {
                            // Initialize accumulated rotation based on current frequency
                            let frequencyRange = range.upperBound - range.lowerBound
                            let normalizedFreq = (frequency - range.lowerBound) / frequencyRange
                            accumulatedRotation = normalizedFreq * frequencyRange * degreesPerMHz
                            dialRotation = accumulatedRotation
                            isInitialized = true
                        }
                    }
                
                // Center
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.65, height: size * 0.65)
                    .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
            }
            .frame(width: size, height: size)
            .contentShape(Circle())
            .gesture(
                SimultaneousGesture(
                    // Long press gesture for adding to favorites
                    LongPressGesture(minimumDuration: 0.5)
                        .onEnded { _ in
                            if !isCountrySelectionMode {
                                onDialLongPress()
                                isLongPressing = false
                            }
                        },
                    // Drag gesture for tuning
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
            )
            .onChange(of: showFavoritesDot) { show in
                if show {
                    // Blink 3 times with slower animation
                    favoritesDotScale = 1.0
                    
                    // First blink
                    withAnimation(.easeInOut(duration: 0.4)) {
                        favoritesDotOpacity = 0.9
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            favoritesDotOpacity = 0.0
                        }
                    }
                    
                    // Second blink
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            favoritesDotOpacity = 0.9
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            favoritesDotOpacity = 0.0
                        }
                    }
                    
                    // Third blink
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            favoritesDotOpacity = 0.9
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            favoritesDotOpacity = 0.0
                        }
                    }
                } else {
                    favoritesDotScale = 0.0
                    favoritesDotOpacity = 0.0
                }
            }
            .overlay(
                // Favorites button - Small skeuomorphic button
                Button(action: {
                    onFavoritesButtonTap()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white,
                                        Color(red: 0.95, green: 0.95, blue: 0.95)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 22, height: 22)
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
                            .shadow(color: .white.opacity(0.8), radius: 1, x: -0.5, y: -0.5)
                        
                        // Light gray dot always visible
                        Circle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(width: 7.26, height: 7.26)  // 10% larger (6.6 * 1.1)
                            .shadow(color: .black.opacity(0.1), radius: 0.5, x: 0, y: 0.5)
                        
                        // Orange dot for animation (matching play button)
                        if showFavoritesDot {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 7.26, height: 7.26)  // Same size as gray dot
                                .scaleEffect(favoritesDotScale)
                                .opacity(favoritesDotOpacity)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())  // Remove default button hover effects
                .offset(
                    x: 135,  // 5 pixels to the right
                    y: -115
                ),
                alignment: .center
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
            hardStopHaptic.prepare()
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
        
        let deltaDegrees = deltaAngle * 180 / .pi
        
        if !isCountrySelectionMode {
            // Calculate the new accumulated rotation
            let newAccumulatedRotation = accumulatedRotation + deltaDegrees
            
            // Calculate min and max rotation limits
            let minRotation = 0.0
            let maxRotation = (range.upperBound - range.lowerBound) * degreesPerMHz
            
            // Check if we're hitting the limits
            if newAccumulatedRotation < minRotation {
                // Hit lower limit
                hapticGenerator.impactOccurred(intensity: 0.5)
                accumulatedRotation = minRotation
                // Still allow visual rotation for realism
                dialRotation += deltaDegrees
                lastAngle = angle
                return
            } else if newAccumulatedRotation > maxRotation {
                // Hit upper limit
                hapticGenerator.impactOccurred(intensity: 0.5)
                accumulatedRotation = maxRotation
                // Still allow visual rotation for realism
                dialRotation += deltaDegrees
                lastAngle = angle
                return
            } else {
                // Normal rotation within limits
                accumulatedRotation = newAccumulatedRotation
            }
        }
        
        // Update visual rotation
        dialRotation += deltaDegrees
        lastAngle = angle
        
        // Haptic feedback every 5 degrees
        let rotationDiff = abs(dialRotation - lastHapticRotation)
        if rotationDiff >= 5.0 {
            hapticGenerator.impactOccurred(intensity: 0.7)
            lastHapticRotation = dialRotation
        }
        
        if isCountrySelectionMode {
            // Country selection remains unlimited
            let rotations = dialRotation / 360.0
            let countryCount = Double(Country.countries.count)
            var newIndex = (rotations.truncatingRemainder(dividingBy: 1) + 1) * countryCount
            if newIndex < 0 { newIndex += countryCount }
            onCountryChange(newIndex.truncatingRemainder(dividingBy: countryCount))
        } else {
            // Calculate frequency from accumulated rotation
            let frequencyRange = range.upperBound - range.lowerBound
            let newFrequency = range.lowerBound + (accumulatedRotation / degreesPerMHz / frequencyRange) * frequencyRange
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