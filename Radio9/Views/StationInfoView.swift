import SwiftUI

struct StationInfoView: View {
    let station: RadioStation?
    let frequency: Double
    let isPlaying: Bool
    @State private var glowAnimation = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Station name
            VStack(alignment: .leading, spacing: 2) {
                Text(station?.name ?? "- - - -")
                    .font(.system(size: 18, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color(red: 1.0, green: 0.9, blue: 0.7))
                    .shadow(color: Color(red: 1.0, green: 0.7, blue: 0.3), radius: glowAnimation ? 8 : 5)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: glowAnimation)
                
                if let subGenre = station?.subGenre {
                    Text(subGenre.uppercased())
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.5).opacity(0.7))
                        .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.5), radius: 2)
                }
            }
            
            Spacer()
            
            // Digital frequency readout
            FrequencyReadout(frequency: frequency)
            
            // Power indicator
            PowerIndicator(isPlaying: isPlaying)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 15)
        .onAppear {
            glowAnimation = true
        }
    }
}

struct FrequencyReadout: View {
    let frequency: Double
    
    var body: some View {
        HStack(spacing: 4) {
            let frequencyString = String(format: "%05.1f", frequency)
            ForEach(Array(frequencyString.enumerated()), id: \.offset) { index, character in
                Text(String(character))
                    .font(.system(size: 22, weight: .light, design: .monospaced))
                    .foregroundColor(Color(red: 1.0, green: 0.95, blue: 0.8))
                    .shadow(color: Color(red: 1.0, green: 0.8, blue: 0.4), radius: 6)
                    .frame(width: character == "." ? 8 : 16)
            }
            Text("MHz")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.5).opacity(0.6))
                .offset(y: 6)
        }
    }
}

struct PowerIndicator: View {
    let isPlaying: Bool
    
    var body: some View {
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
}