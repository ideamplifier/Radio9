import SwiftUI

struct VersionPlateView: View {
    @Binding var showSettings: Bool
    
    var body: some View {
        Button(action: {
            showSettings = true
            HapticManager.shared.impact(style: .light)
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
                    )
                
                Text("1.1.1")
                    .font(.system(size: 10.5, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.black.opacity(0.65))
            }
            .opacity(0.7)
            .frame(width: 50, height: 24)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VersionPlateView(showSettings: .constant(false))
        .padding()
        .background(Color.gray.opacity(0.2))
}