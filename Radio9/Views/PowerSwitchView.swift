import SwiftUI

struct PowerSwitchView: View {
    @Binding var isPowerOn: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Switch groove/slot
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.85),
                                Color.black.opacity(0.65)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 6, height: geometry.size.height * 0.5)  // Shorter groove
                    .overlay(
                        // Inner shadow effect - top edge
                        VStack {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.black.opacity(0.3),
                                            Color.clear
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: 3)
                                .blur(radius: 1)
                            Spacer()
                        }
                    )
                    .overlay(
                        // Subtle highlight at bottom
                        VStack {
                            Spacer()
                            RoundedRectangle(cornerRadius: 3)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.clear,
                                            Color.white.opacity(0.05)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: 3)
                                .blur(radius: 0.5)
                        }
                    )
                
                // Switch handle
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.97, green: 0.97, blue: 0.97),
                                Color(red: 0.92, green: 0.92, blue: 0.92)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 20, height: 14)  // Smaller handle
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                    )
                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1.5)
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2.5)
                .shadow(color: .white.opacity(0.3), radius: 0.5, x: 0, y: -0.5)
                .offset(y: isPowerOn ? -(geometry.size.height * 0.12) : (geometry.size.height * 0.12))
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isPowerOn.toggle()
                    
                    // Double haptic feedback for "click" feeling
                    let haptic = UIImpactFeedbackGenerator(style: .light)
                    haptic.prepare()
                    haptic.impactOccurred(intensity: 0.83)
                    
                    // Second haptic after a tiny delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                        haptic.impactOccurred(intensity: 0.83)
                    }
                }
            }
        }
    }
}

#Preview {
    PowerSwitchView(isPowerOn: .constant(false))
        .frame(width: 30, height: 60)
        .padding()
        .background(Color.gray.opacity(0.2))
}