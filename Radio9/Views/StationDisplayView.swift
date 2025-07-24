import SwiftUI

struct StationInfoModal: View {
    let station: RadioStation?
    let songInfo: SongInfo?
    let isPlaying: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("NOW PLAYING")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
                .padding(.top, 30)
            
            // Station Name
            if let station = station {
                VStack(spacing: 8) {
                    Text(station.name)
                        .font(.system(size: 20, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text("\(String(format: "%.1f", station.frequency)) MHz")
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            }
            
            Divider()
                .padding(.horizontal)
            
            // Current Song Info
            if let songInfo = songInfo {
                VStack(spacing: 12) {
                    Text(songInfo.title)
                        .font(.system(size: 18, weight: .medium))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text(songInfo.artist)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
            } else if isPlaying {
                Text("No song information available")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                Text("Radio is not playing")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .italic()
            }
            
            Spacer()
        }
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(30)
        .presentationBackground(.regularMaterial)
    }
}

struct StationDisplayView: View {
    let station: RadioStation?
    let frequency: Double
    let isPlaying: Bool
    @ObservedObject var viewModel: RadioViewModel
    let isDialInteracting: Bool
    @State private var showStationInfo = false
    
    var body: some View {
        ZStack {
            // Recessed display area - carved into the body
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.94, green: 0.94, blue: 0.94))
                .overlay(
                    // Top inner shadow - precise and thin
                    RoundedRectangle(cornerRadius: 20)
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
                    RoundedRectangle(cornerRadius: 20)
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
                    RoundedRectangle(cornerRadius: 20)
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
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.85))
                .padding(5)
                .overlay(
                    // Subtle inner shadow on the display
                    RoundedRectangle(cornerRadius: 14)
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
                    .cornerRadius(14)
                    .padding(5)
                )
            
            VStack(spacing: 0) {
                // Analog frequency scale
                FrequencyScaleView(frequency: frequency, isDialInteracting: isDialInteracting)
                    .frame(height: 45)
                    .padding(.horizontal, 15)
                    .padding(.top, 18)  // 2픽셀 위로 (20 -> 18)
                
                Spacer()
                
                // Station info with tube glow
                StationInfoView(
                    station: station,
                    frequency: frequency,
                    isPlaying: isPlaying,
                    isLoading: viewModel.isLoading,
                    viewModel: viewModel
                )
                .frame(height: 50)  // 고정 높이
                .id("\(station?.id.uuidString ?? "")_\(isPlaying)") // 상태별 고유 ID (로딩 상태 제외)
                
            }
            // Country selector button and info button - overlay로 위치 고정
            .overlay(
                HStack(spacing: 10) {
                    // Info button - 국가 선택 모드에서는 숨김
                    if viewModel.currentStation != nil && !viewModel.isCountrySelectionMode {
                        Button(action: {
                            showStationInfo.toggle()
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 1.0, green: 0.9, blue: 0.7))
                                .shadow(
                                    color: Color(red: 1.0, green: 0.7, blue: 0.3).opacity(0.5),
                                    radius: 4
                                )
                        }
                    }
                    
                    CountrySelectorButton(viewModel: viewModel)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 62),  // 2픽셀 더 위로 (60 -> 62)
                alignment: .bottomTrailing
            )
        }
        .frame(height: 160) // 고정 높이 (140 -> 160)
        .clipped() // 넘치는 내용 잘라내기
        .sheet(isPresented: $showStationInfo) {
            StationInfoModal(
                station: station,
                songInfo: viewModel.latestSongInfo,
                isPlaying: isPlaying
            )
        }
    }
}