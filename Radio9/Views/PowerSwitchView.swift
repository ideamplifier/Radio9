import SwiftUI

struct PowerSwitchView: View {
    @State private var isOn = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Switch groove/slot
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.black.opacity(0.7))
                    .frame(width: 6, height: geometry.size.height * 0.5)  // Shorter groove
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.black.opacity(0.4), lineWidth: 0.5)
                            .blur(radius: 0.5)
                            .offset(y: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: -1)
                
                // Switch handle
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.95, green: 0.95, blue: 0.95),
                                Color(red: 0.85, green: 0.85, blue: 0.85)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 20, height: 14)  // Smaller handle
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                    )
                .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 2)
                .shadow(color: .white.opacity(0.8), radius: 1, x: 0, y: -1)
                .offset(y: isOn ? -(geometry.size.height * 0.12) : (geometry.size.height * 0.12))
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isOn.toggle()
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
        }
    }
}

#Preview {
    PowerSwitchView()
        .frame(width: 30, height: 60)
        .padding()
        .background(Color.gray.opacity(0.2))
}