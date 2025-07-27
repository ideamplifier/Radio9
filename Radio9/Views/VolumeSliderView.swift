import SwiftUI

struct VolumeSliderView: View {
    @Binding var volume: Float
    @State private var isDragging = false
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "speaker.fill")
                .font(.system(size: 12))
                .foregroundColor(.gray.opacity(0.6))
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 4)
                    
                    // Fill
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.red)
                        .frame(width: geometry.size.width * CGFloat(volume), height: 4)
                    
                    // Knob
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                        .scaleEffect(isDragging ? 1.15 : 1.0)
                        .offset(x: geometry.size.width * CGFloat(volume) - 10)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if !isDragging {
                                        isDragging = true
                                        HapticManager.shared.impact(style: .light)
                                    }
                                    let newVolume = Float(value.location.x / geometry.size.width)
                                    volume = min(max(newVolume, 0), 1)
                                }
                                .onEnded { _ in
                                    isDragging = false
                                }
                        )
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isDragging)
            }
            .frame(height: 20)
            
            Image(systemName: "speaker.wave.3.fill")
                .font(.system(size: 12))
                .foregroundColor(.gray.opacity(0.6))
        }
        .frame(maxWidth: 240)
    }
}