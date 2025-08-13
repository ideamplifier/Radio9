import SwiftUI

struct StationInfoModal: View {
    let station: RadioStation?
    let songInfo: SongInfo?
    let isPlaying: Bool
    @Environment(\.dismiss) var dismiss
    
    private func openInAppleMusic(title: String, artist: String) {
        // Create search query
        let searchQuery = "\(title) \(artist)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Try Apple Music URL scheme first
        if let musicURL = URL(string: "music://music.apple.com/search?term=\(searchQuery)"),
           UIApplication.shared.canOpenURL(musicURL) {
            UIApplication.shared.open(musicURL)
        } else if let webURL = URL(string: "https://music.apple.com/search?term=\(searchQuery)") {
            // Fallback to web URL
            UIApplication.shared.open(webURL)
        }
    }
    
    private func getEmotionalDescription(for station: RadioStation) -> String? {
        // Nature sounds get special emotional descriptions
        if station.countryCode == "NATURE" {
            switch station.name {
            case "Tokyo Rain FM":
                return """
                🌧 시부야 골목, 오후 3시 47분
                
                창가에 앉아 커피 한 모금.
                유리창을 두드리는 빗방울이
                도시의 소음을 지워갑니다.
                
                이 빗소리는 1962년부터
                같은 주파수로 방송되고 있습니다.
                """
                
            case "Pacific Ocean FM":
                return """
                🌊 가마쿠라 해변, 새벽 5시
                
                첫 서퍼가 나서기 전,
                파도만이 말을 걸어옵니다.
                
                7초마다 밀려오는 파도.
                태평양이 직접 운영하는
                24시간 라디오 방송국.
                """
                
            case "Night Cricket FM":
                return """
                🦗 나라의 대나무 숲, 자정
                
                달빛이 대나무 잎을 비추고
                귀뚜라미들이 밤의 교향곡을 시작합니다.
                
                1초에 4번, 정확한 리듬.
                기온이 1도 올라가면 템포도 빨라집니다.
                자연의 온도계이자 시계, 그리고 라디오.
                
                천 년 전 헤이안 시대부터
                같은 주파수로 울려왔습니다.
                """
                
            case "Campfire Radio":
                return """
                🔥 홋카이도 설원, 겨울밤 10시
                
                영하 20도의 맑은 밤.
                오로라가 춤추는 하늘 아래
                통나무가 따뜻한 이야기를 들려줍니다.
                
                아이누 족이 천 년 전부터
                같은 자리에서 피워온 불.
                눈 속에서 타오르는 생명의 주파수.
                """
                
            case "Thunder Storm FM":
                return """
                ⛈ 오사카 상공, 여름밤
                
                하늘이 보내는 긴급 속보.
                천둥은 베이스, 비는 드럼.
                
                10km 떨어진 곳의 빗소리가
                7초 후 당신의 창문에 도착합니다.
                자연의 라이브 중계.
                """
                
            case "Drizzle FM":
                return """
                🌦 교토 정원, 오전 10시
                
                가랑비가 내립니다.
                연못 위로 동심원이 퍼집니다.
                
                우산 없이도 걸을 수 있는 비.
                대나무 잎 끝에 맺힌 물방울이
                똑, 똑, 떨어집니다.
                """
                
            case "Morning Birds FM":
                return """
                🐦 교토 아라시야마, 새벽 4시 30분
                
                첫 참새가 눈을 뜹니다.
                이어서 휘파람새, 지빠귀, 종달새.
                
                태양이 뜨기 한 시간 전,
                새들의 모닝콜이 시작됩니다.
                천 년간 이어진 아침 방송.
                """
                
            default:
                return nil
            }
        }
        return nil
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text(LocalizationHelper.getLocalizedString(for: "now_playing"))
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
            
            // Emotional description for nature sounds
            if let station = station,
               let description = getEmotionalDescription(for: station) {
                ScrollView(showsIndicators: false) {
                    Text(description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.primary.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
                .frame(maxHeight: 200)
            }
            // Current Song Info (for regular stations)
            else if let songInfo = songInfo {
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
                
                // Apple Music button
                Button(action: {
                    openInAppleMusic(title: songInfo.title, artist: songInfo.artist)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "music.note")
                            .font(.system(size: 14))
                        Text(LocalizationHelper.getLocalizedString(for: "view_in_apple_music"))
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.15, green: 0.12, blue: 0.0).opacity(0.95))
                    )
                }
                .padding(.top, 8)
            } else if isPlaying {
                Text(LocalizationHelper.getLocalizedString(for: "no_song_information"))
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
        .presentationDetents([.height(station?.countryCode == "NATURE" ? 400 : 300)])
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
    @Binding var isPowerOn: Bool
    @State private var showStationInfo = false
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
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
                FrequencyScaleView(frequency: frequency, isDialInteracting: isDialInteracting, isCountrySelectionMode: viewModel.isCountrySelectionMode, isPowerOn: $isPowerOn)
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
                    viewModel: viewModel,
                    isPowerOn: $isPowerOn
                )
                .frame(height: 50)  // 고정 높이
                .id("\(station?.id.uuidString ?? "")_\(isPlaying)") // 상태별 고유 ID (로딩 상태 제외)
                
            }
            // Sleep timer countdown or message at bottom left
            .overlay(
                Group {
                    if let message = viewModel.sleepTimerMessage {
                        Text(message)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(red: 1.0, green: 0.9, blue: 0.7).opacity(0.8))
                            .shadow(
                                color: Color(red: 1.0, green: 0.7, blue: 0.3).opacity(0.3),
                                radius: 2
                            )
                            .padding(.leading, 22)
                            .padding(.bottom, 18)
                    } else if let remainingTime = viewModel.sleepTimerRemainingTime {
                        Text(formatTime(remainingTime))
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(Color(red: 1.0, green: 0.9, blue: 0.7).opacity(0.8))
                            .shadow(
                                color: Color(red: 1.0, green: 0.7, blue: 0.3).opacity(0.3),
                                radius: 2
                            )
                            .padding(.leading, 22)
                            .padding(.bottom, 18)
                    }
                },
                alignment: .bottomLeading
            )
            // Country selector button and info button - overlay로 위치 고정
            .overlay(
                HStack(spacing: 10) {
                    // Info button - 국가 선택 모드에서는 숨김
                    if !viewModel.isCountrySelectionMode {
                        Button(action: {
                            if viewModel.currentStation != nil {
                                showStationInfo.toggle()
                                HapticManager.shared.impact(style: .light)
                            }
                        }) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 1.0, green: 0.9, blue: 0.7).opacity(0.95))
                                .shadow(
                                    color: Color(red: 1.0, green: 0.7, blue: 0.3).opacity(0.5),
                                    radius: 4
                                )
                                .offset(x: -5, y: 0)
                        }
                        .disabled(viewModel.currentStation == nil)
                    }
                    
                    CountrySelectorButton(viewModel: viewModel)
                        .offset(x: 1, y: 0)
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