import SwiftUI

struct CountrySelectorButton: View {
    @ObservedObject var viewModel: RadioViewModel
    
    var body: some View {
        Button(action: {
            viewModel.toggleCountrySelectionMode()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }) {
            ZStack {
                // Button background with warm glow when active
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.black.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(red: 1.0, green: 0.8, blue: 0.4).opacity(0.3), lineWidth: 0.5)
                    )
                    .shadow(
                        color: viewModel.isCountrySelectionMode ? 
                            Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.3) : 
                            Color.clear,
                        radius: 8
                    )
                
                // Country code display
                Text(viewModel.selectedCountry.code)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(Color(red: 1.0, green: 0.9, blue: 0.7))
                    .shadow(
                        color: viewModel.isCountrySelectionMode ?
                            Color(red: 1.0, green: 0.7, blue: 0.3) :
                            Color(red: 1.0, green: 0.7, blue: 0.3).opacity(0.5),
                        radius: viewModel.isCountrySelectionMode ? 6 : 3
                    )
            }
            .frame(width: 40, height: 24)
        }
    }
}