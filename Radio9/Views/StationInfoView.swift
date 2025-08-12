import SwiftUI

struct StationInfoView: View {
    let station: RadioStation?
    let frequency: Double
    let isPlaying: Bool
    let isLoading: Bool
    @ObservedObject var viewModel: RadioViewModel
    @Binding var isPowerOn: Bool
    @State private var showEqualizerMessage = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Station name or Country selection
            VStack(alignment: .leading, spacing: 2) {
                if viewModel.isCountrySelectionMode {
                    // Country name
                    Text(viewModel.displayCountry.name)
                        .font(.system(size: 15.5, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(red: 1.0, green: 0.9, blue: 0.7))
                        .shadow(color: Color(red: 1.0, green: 0.7, blue: 0.3), radius: 6)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Select Country text
                    Text(LocalizationHelper.getLocalizedString(for: "turn_dial_select_country"))
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.5).opacity(0.7))
                        .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.5), radius: 2)
                        .frame(height: 12)  // 고정 높이
                        .offset(x: 1)  // 오른쪽으로 1픽셀
                } else {
                    // Check if current country has no stations (Coming soon)
                    let hasStations = !viewModel.stations.isEmpty
                    
                    // Station name or "Coming soon"
                    Text(hasStations ? (station?.name ?? "- - -") : "Coming soon")
                        .font(.system(size: 15.5, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(red: 1.0, green: 0.9, blue: 0.7))
                        .shadow(color: Color(red: 1.0, green: 0.7, blue: 0.3), radius: 6)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 하단 텍스트 영역 - 항상 높이 확보
                    Group {
                        if !hasStations {
                            // Show message for countries with no stations
                            Text("No stations available yet")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.5).opacity(0.7))
                                .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.5), radius: 2)
                        } else if showEqualizerMessage {
                            Text(LocalizationHelper.getLocalizedString(for: "equalizer_on"))
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.5).opacity(0.8))
                                .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.5), radius: 2)
                                .transition(.opacity)  // 줌아웃 효과 제거, opacity만
                        } else if viewModel.showAddedToFavoritesMessage {
                            Text(LocalizationHelper.getLocalizedString(for: "added_to_favorites"))
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.5).opacity(0.8))
                                .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.5), radius: 2)
                                .transition(.opacity.combined(with: .scale))
                        } else if isLoading {
                            Text(LocalizationHelper.getLocalizedString(for: "loading"))
                                .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                                .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.5).opacity(0.5))
                                .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.3), radius: 1)
                        } else if let subGenre = station?.subGenre {
                            Text(subGenre.uppercased())
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.5).opacity(0.7))
                                .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.5), radius: 2)
                        } else {
                            Text(" ")  // 빈 공간 확보
                                .font(.system(size: 10))
                        }
                    }
                    .frame(height: 12)  // 고정 높이
                    .offset(x: 1)  // 오른쪽으로 1픽셀
                }
            }
            .frame(maxWidth: .infinity)  // 너비 제한 제거
            .offset(y: -12)  // 2픽셀 더 위로 (-10 -> -12)
            
            if !viewModel.isCountrySelectionMode {
                Spacer()
            }
            
            // Digital frequency readout
            if !viewModel.isCountrySelectionMode {
                HStack(spacing: 8) {
                    FrequencyReadout(frequency: frequency, isCountrySelectionMode: viewModel.isCountrySelectionMode)
                }
                .frame(minWidth: 10, alignment: .trailing) // 최소 너비 축소
                .offset(y: 30)  // 10픽셀 위로 (40 -> 30)
            }
            
            // Power indicator
            PowerIndicator(isPlaying: isPlaying, isLoading: isLoading, hasStation: station != nil)
                .offset(x: 1, y: 31)  // 1픽셀 우측, 1픽셀 아래로
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 65)  // 30픽셀 더 위로 (35 -> 65)
        .onChange(of: isPowerOn) { newValue in
            if newValue {
                // Show equalizer message
                showEqualizerMessage = true
                
                // Hide after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showEqualizerMessage = false
                    }
                }
            }
        }
    }
}

struct FrequencyReadout: View {
    let frequency: Double
    let isCountrySelectionMode: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            HStack(spacing: 3) {
                // 주파수 숫자
                Text(String(format: "%.1f", frequency))
                    .font(.system(size: 22, weight: .light, design: .monospaced))
                    .foregroundColor(Color(red: 1.0, green: 0.95, blue: 0.8))
                    .shadow(color: Color(red: 1.0, green: 0.8, blue: 0.4), radius: 6)
                    .opacity(isCountrySelectionMode ? 0 : 1)
                    .animation(.easeInOut(duration: 0.3), value: isCountrySelectionMode)
                
                // MHz 텍스트 - 원래 크기
                Text("MHz")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.5).opacity(0.6))
                    .offset(y: 6)
                    .opacity(isCountrySelectionMode ? 0 : 1)
                    .animation(.easeInOut(duration: 0.3), value: isCountrySelectionMode)
            }
        }
        .fixedSize() // 절대 줄바꿈 방지
        .id("frequency") // 고정 ID로 재렌더링 방지
        .animation(.none, value: frequency) // 애니메이션 제거
    }
}

struct PowerIndicator: View {
    let isPlaying: Bool
    let isLoading: Bool
    let hasStation: Bool
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(hasStation ? (isLoading ? Color(red: 0.2, green: 0.76, blue: 0.2) : (isPlaying ? Color(red: 0.2, green: 0.76, blue: 0.2) : Color(red: 0.3, green: 0.3, blue: 0.3))) : Color(red: 0.3, green: 0.3, blue: 0.3))
                .frame(width: 9, height: 9)
                .opacity(isLoading && hasStation ? (pulseAnimation ? 0.3 : 0.7) : 1.0)
            
            if hasStation && (isPlaying || isLoading) {
                Circle()
                    .fill(isLoading ? Color(red: 0.38, green: 0.95, blue: 0.38) : Color(red: 0.38, green: 0.95, blue: 0.38))
                    .frame(width: 4.5, height: 4.5)
                    .blur(radius: 1)
                    .opacity(isLoading ? (pulseAnimation ? 0.2 : 0.7) : 1.0)
            }
        }
        .shadow(color: hasStation ? (isLoading ? Color.green : (isPlaying ? Color.green : Color.clear)) : Color.clear, radius: 8)
        .onAppear {
            if isLoading && hasStation {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    pulseAnimation = true
                }
            }
        }
        .onChange(of: isLoading) { newValue in
            if newValue && hasStation {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    pulseAnimation = true
                }
            } else {
                withAnimation(.default) {
                    pulseAnimation = false
                }
            }
        }
    }
}