import SwiftUI

struct FrequencyScaleView: View {
    let frequency: Double
    
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
                    FrequencyLabels()
                        .frame(width: geometry.size.width)
                        .clipped()
                        .padding(.top, 3)
                    
                    // Scale marks
                    ScaleMarks()
                        .frame(width: geometry.size.width)
                        .clipped()
                        .padding(.vertical, 2)
                }
                
                // Tuning needle
                TuningNeedle(frequency: frequency, width: geometry.size.width)
                    .allowsHitTesting(false)
            }
        }
    }
}

struct FrequencyLabels: View {
    var body: some View {
        HStack {
            ForEach([88, 92, 96, 100, 104, 108], id: \.self) { freq in
                Text("\(freq)")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.6))
                    .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.2), radius: 2)
                if freq != 108 {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 10)
    }
}

struct ScaleMarks: View {
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<41) { index in
                Rectangle()
                    .fill(Color(red: 1.0, green: 0.75, blue: 0.4))
                    .frame(width: index % 5 == 0 ? 2 : 1,
                           height: index % 5 == 0 ? 12 : 8)
                    .opacity(index % 5 == 0 ? 1 : 0.6)
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
                
                // Debug logging
                let _ = print("TuningNeedle - Freq: \(frequency), Normalized: \(normalizedPosition), XPos: \(xPosition), Width: \(geometry.size.width)")
                
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
                    .shadow(color: Color(red: 1.0, green: 0.8, blue: 0.4), radius: 5)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                    .position(x: xPosition, y: geometry.size.height / 2)
            }
        }
        .frame(height: 45)
    }
}