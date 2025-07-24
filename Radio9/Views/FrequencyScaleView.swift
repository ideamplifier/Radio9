import SwiftUI

struct FrequencyScaleView: View {
    let frequency: Double
    let isDialInteracting: Bool
    let isCountrySelectionMode: Bool
    
    var body: some View {
        ZStack {
            // Scale container - slightly recessed
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.black.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.black.opacity(0.3), lineWidth: 1)
                        .blur(radius: 0.5)
                )
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: -1)
            
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Frequency labels
                    FrequencyLabels(isCountrySelectionMode: isCountrySelectionMode)
                        .frame(width: geometry.size.width)
                        .clipped()
                        .padding(.top, 3)
                    
                    // Scale marks
                    ScaleMarks(isCountrySelectionMode: isCountrySelectionMode)
                        .frame(width: geometry.size.width)
                        .clipped()
                        .padding(.vertical, 2)
                }
                
                // Tuning needle
                TuningNeedle(frequency: frequency, width: geometry.size.width, isDialInteracting: isDialInteracting)
                    .allowsHitTesting(false)
                    .opacity(isCountrySelectionMode ? 0 : 1)
                    .animation(.easeInOut(duration: 0.3), value: isCountrySelectionMode)
            }
        }
    }
}

struct FrequencyLabels: View {
    let isCountrySelectionMode: Bool
    
    var body: some View {
        HStack {
            ForEach([88, 92, 96, 100, 104, 108], id: \.self) { freq in
                Text("\(freq)")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.6))
                    .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.2), radius: 2)
                    .opacity(isCountrySelectionMode ? 0.3 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: isCountrySelectionMode)
                if freq != 108 {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 10)
    }
}

struct ScaleMarks: View {
    let isCountrySelectionMode: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<41) { index in
                Rectangle()
                    .fill(Color(red: 1.0, green: 0.75, blue: 0.4))
                    .frame(width: index % 5 == 0 ? 2 : 1,
                           height: index % 5 == 0 ? 12 : 8)
                    .opacity(isCountrySelectionMode ? 0.3 : (index % 5 == 0 ? 1 : 0.6))
                    .animation(.easeInOut(duration: 0.3), value: isCountrySelectionMode)
                if index < 40 {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 10)
    }
}

struct TuningNeedle: View {
    let frequency: Double
    let width: CGFloat
    let isDialInteracting: Bool
    
    var body: some View {
        ZStack {
            // 배경 (투명)
            Color.clear
                .frame(height: 45)
            
            // 바늘
            GeometryReader { geometry in
                // Fix: Use proper frequency range (88-108 = 20)
                let normalizedPosition = (frequency - 88.0) / 20.0
                let clampedPosition = max(0, min(1, normalizedPosition))
                let xPosition = 10 + (geometry.size.width - 20) * clampedPosition
                
                
                ZStack {
                    // 바늘 아래쪽 노란빛 효과
                    if isDialInteracting {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.8, blue: 0.4).opacity(0.2))
                            .frame(width: 30, height: 30)
                            .blur(radius: 8)
                    }
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.9, blue: 0.7),
                                    Color(red: 0.9, green: 0.7, blue: 0.4)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 3, height: 35)
                        .shadow(color: Color(red: 1.0, green: 0.8, blue: 0.4).opacity(isDialInteracting ? 1.0 : 0.8), radius: isDialInteracting ? 10 : 5)
                        .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.2).opacity(isDialInteracting ? 0.6 : 0), radius: 15)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                }
                .position(x: xPosition, y: geometry.size.height / 2)
            }
        }
        .frame(height: 45)
    }
}