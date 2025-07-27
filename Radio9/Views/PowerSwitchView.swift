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
                                Color(red: 0.25, green: 0.22, blue: 0.05).opacity(0.9),
                                Color(red: 0.23, green: 0.2, blue: 0.03).opacity(0.8)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 5, height: geometry.size.height * 0.5)  // Shorter groove
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
                    .fill(Color.white)
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
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    isPowerOn.toggle()
                    
                    // Single haptic feedback
                    HapticManager.shared.impact(style: .light, intensity: 0.83)
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