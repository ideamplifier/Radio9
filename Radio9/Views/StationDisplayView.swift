import SwiftUI

struct StationDisplayView: View {
    let station: RadioStation?
    let frequency: Double
    let isPlaying: Bool
    @State private var glowAnimation = false
    
    var body: some View {
        ZStack {
            // Vintage radio window frame
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color(white: 0.15), Color(white: 0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color(white: 0.3), Color(white: 0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
            
            // Inner glass effect
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.8))
                .padding(4)
                .overlay(
                    LinearGradient(
                        colors: [Color.white.opacity(0.05), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                    .cornerRadius(10)
                    .padding(4)
                )
            
            VStack(spacing: 0) {
                // Analog frequency scale
                ZStack {
                    // Scale container with clipping
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.black.opacity(0.3))
                        .overlay(
                            // Warm backlight
                            Rectangle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color(red: 1.0, green: 0.5, blue: 0.1).opacity(0.15),
                                            Color.clear
                                        ],
                                        center: UnitPoint(x: normalizedFrequency, y: 0.5),
                                        startRadius: 20,
                                        endRadius: 100
                                    )
                                )
                                .blur(radius: 10)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        )
                    
                    GeometryReader { geometry in
                        VStack(spacing: 0) {
                            // Frequency labels
                            ZStack {
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
                            .frame(width: geometry.size.width)
                            .clipped()
                            .padding(.top, 3)
                            
                            // Scale marks
                            ZStack {
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
                            .frame(width: geometry.size.width)
                            .clipped()
                            .padding(.vertical, 2)
                        }
                        
                        // Tuning needle with realistic shadow
                        let position = (frequency - 88.0) / 20.0
                        VStack(spacing: 0) {
                            // Needle
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
                                .frame(width: 3, height: 25)
                                .shadow(color: Color(red: 1.0, green: 0.8, blue: 0.4), radius: 5)
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                            
                            // Needle base
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color(red: 0.8, green: 0.6, blue: 0.3),
                                            Color(red: 0.6, green: 0.4, blue: 0.2)
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 5
                                    )
                                )
                                .frame(width: 8, height: 8)
                                .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                        }
                        .offset(x: geometry.size.width * position - 4, y: 8)
                        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: frequency)
                    }
                }
                .frame(height: 45)
                .padding(.horizontal, 15)
                .padding(.top, 15)
                
                Spacer()
                
                // Station info with tube glow
                HStack(spacing: 15) {
                    // Station name
                    VStack(alignment: .leading, spacing: 2) {
                        Text(station?.name ?? "- - - -")
                            .font(.system(size: 18, weight: .semibold, design: .monospaced))
                            .foregroundColor(Color(red: 1.0, green: 0.9, blue: 0.7))
                            .shadow(color: Color(red: 1.0, green: 0.7, blue: 0.3), radius: glowAnimation ? 8 : 5)
                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: glowAnimation)
                        
                        if let genre = station?.genre {
                            Text(genre.uppercased())
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.5).opacity(0.7))
                                .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.5), radius: 2)
                        }
                    }
                    
                    Spacer()
                    
                    // Digital frequency readout
                    HStack(spacing: 4) {
                        ForEach(String(format: "%05.1f", frequency).map { String($0) }, id: \.self) { digit in
                            Text(digit)
                                .font(.system(size: 22, weight: .light, design: .monospaced))
                                .foregroundColor(Color(red: 1.0, green: 0.95, blue: 0.8))
                                .shadow(color: Color(red: 1.0, green: 0.8, blue: 0.4), radius: 6)
                                .frame(width: digit == "." ? 8 : 16)
                        }
                        Text("MHz")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.5).opacity(0.6))
                            .offset(y: 6)
                    }
                    
                    // Power indicator
                    ZStack {
                        Circle()
                            .fill(isPlaying ? Color(red: 0.2, green: 0.8, blue: 0.2) : Color(red: 0.3, green: 0.3, blue: 0.3))
                            .frame(width: 12, height: 12)
                        
                        if isPlaying {
                            Circle()
                                .fill(Color(red: 0.4, green: 1.0, blue: 0.4))
                                .frame(width: 6, height: 6)
                                .blur(radius: 1)
                        }
                    }
                    .shadow(color: isPlaying ? Color.green : Color.clear, radius: 8)
                    .animation(.easeInOut(duration: 0.5), value: isPlaying)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 15)
            }
            .onAppear {
                glowAnimation = true
            }
        }
        .frame(height: 120)
    }
    
    private var normalizedFrequency: CGFloat {
        CGFloat((frequency - 88.0) / 20.0)
    }
}