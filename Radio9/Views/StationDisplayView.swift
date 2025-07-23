import SwiftUI

struct StationDisplayView: View {
    let station: RadioStation?
    let frequency: Double
    let isPlaying: Bool
    @ObservedObject var viewModel: RadioViewModel
    
    var body: some View {
        ZStack {
            // Recessed display area - carved into the body
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.94, green: 0.94, blue: 0.94))
                .overlay(
                    // Top inner shadow - precise and thin
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.2),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1.5
                        )
                        .blur(radius: 1)
                        .offset(y: 1)
                )
                .overlay(
                    // Left inner shadow
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.15),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                        .blur(radius: 1)
                        .offset(x: 1)
                )
                .overlay(
                    // Bottom/right highlight - subtle
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.white.opacity(0.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                        .offset(x: -0.5, y: -0.5)
                )
            
            // Display panel - the actual screen
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.85))
                .padding(5)
                .overlay(
                    // Subtle inner shadow on the display
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(Color.black.opacity(0.3), lineWidth: 0.5)
                        .blur(radius: 0.5)
                        .padding(5)
                )
                .overlay(
                    // Glass reflection
                    LinearGradient(
                        colors: [Color.white.opacity(0.05), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                    .cornerRadius(9)
                    .padding(5)
                )
            
            VStack(spacing: 0) {
                // Analog frequency scale or Country selection
                Group {
                    if viewModel.isCountrySelectionMode {
                        CountrySelectionDisplay(viewModel: viewModel)
                    } else {
                        FrequencyScaleView(frequency: frequency)
                    }
                }
                .frame(height: 45)
                .padding(.horizontal, 15)
                .padding(.top, 15)
                
                Spacer()
                
                // Station info with tube glow
                StationInfoView(
                    station: station,
                    frequency: frequency,
                    isPlaying: isPlaying
                )
                
                // Country selector button - bottom right
                CountrySelectorButton(viewModel: viewModel)
                    .position(x: UIScreen.main.bounds.width - 50, y: 90)
            }
        }
        .frame(height: 120)
    }
}