
import SwiftUI
import Combine

// Extension for custom corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct ContentView: View {
    @StateObject private var viewModel = RadioViewModel()
    @State private var showStationList = false
    @State private var isDialInteracting = false
    @State private var showFavoritesModal = false
    @State private var isPowerOn = false
    @State private var showSettingsModal = false
    @State private var showSleepTimerModal = false
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        ZStack {
            // Full screen background
            Color(red: 0.98, green: 0.98, blue: 0.98)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with menu
                HStack {
                    VStack(alignment: .leading, spacing: -1.3) {
                        Text("HOSONO")
                            .font(.system(size: 16.4, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.2, green: 0.17, blue: 0.0).opacity(0.92))
                            .shadow(color: Color.white.opacity(0.1), radius: 2)
                            .tracking(-0.3)
                        
                        Text("ラジオ")
                            .font(.system(size: 14.4, weight: .regular, design: .rounded))
                            .foregroundColor(.orange)
                            .shadow(color: Color.white.opacity(0.1), radius: 2)
                            .tracking(-0.2)
                    }
                    .offset(x: 2, y: -15)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 30)
                .padding(.bottom, 20)
                
                // Speaker Grill
                SpeakerGrillView(
                    isPowerOn: $isPowerOn, 
                    audioAnalyzer: viewModel.audioAnalyzer, 
                    isPlaying: viewModel.isPlaying && !viewModel.isLoading && viewModel.currentStation != nil
                )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                
                // Station Display with Skeuomorphic LCD
                StationDisplayView(
                    station: viewModel.currentStation,
                    frequency: viewModel.currentFrequency,
                    isPlaying: viewModel.isPlaying,
                    viewModel: viewModel,
                    isDialInteracting: isDialInteracting,
                    isPowerOn: $isPowerOn
                )
                .padding(.horizontal, 17)  // 좌우 1픽셀씩 더 늘려 (18 -> 17)
                .padding(.bottom, 30)
                .id("stationDisplay") // 고정 ID로 재렌더링 방지
                
                // Control Section
                VStack(spacing: 20) {
                    // Playback Controls
                    HStack(spacing: 30) {
                        // Previous Station Button
                        Button(action: {
                            viewModel.selectPreviousStation()
                            HapticManager.shared.impact(style: .light)
                        }) {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.2, green: 0.17, blue: 0.0).opacity(0.92))
                                .frame(width: 44, height: 44)
                        }
                        .disabled(false)
                        .id("previousButton")
                        
                        // Main Play/Pause Button
                        Button(action: { 
                            viewModel.togglePlayPause()
                            HapticManager.shared.impact(style: .medium)
                        }) {
                            Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.orange)
                                .offset(x: viewModel.isPlaying ? 0 : 2)
                        }
                        .disabled(false)
                        .opacity(1.0)
                        .id("playButton")
                        
                        // Next Station Button
                        Button(action: {
                            viewModel.selectNextStation()
                            HapticManager.shared.impact(style: .light)
                        }) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.2, green: 0.17, blue: 0.0).opacity(0.92))
                                .frame(width: 44, height: 44)
                        }
                        .disabled(false)
                        .id("nextButton")
                    }
                    .offset(y: -15)
                    .animation(.none, value: viewModel.currentStation)
                    
                    // Frequency Dial - Completely independent
                    IndependentDialView(
                        frequency: viewModel.currentFrequency,
                        isCountrySelectionMode: viewModel.isCountrySelectionMode,
                        countrySelectionIndex: viewModel.countrySelectionIndex,
                        onFrequencyChange: { newFrequency in
                            if !viewModel.isCountrySelectionMode {
                                viewModel.currentFrequency = newFrequency
                                viewModel.tuneToFrequency(newFrequency)
                            }
                        },
                        onCountryChange: { newIndex in
                            viewModel.countrySelectionIndex = newIndex
                            viewModel.selectCountryByIndex(newIndex)
                        },
                        onFavoritesButtonTap: {
                            showFavoritesModal = true
                        },
                        onDialLongPress: {
                            // Add current station to favorites if playing
                            if let station = viewModel.currentStation {
                                viewModel.addToFavorites(station: station)
                            }
                        },
                        isInteracting: $isDialInteracting,
                        showFavoritesDot: viewModel.showFavoritesDotAnimation
                    )
                    .frame(width: 228, height: 228)
                    .offset(y: -16)  // -14 -> -16 (아래로 2픽셀)
                }
                
                Spacer()
                    .frame(height: 40)
            }
            
            // Power Switch at bottom left
            .overlay(
                PowerSwitchView(isPowerOn: $isPowerOn)
                    .frame(width: 30, height: 70)
                    .padding(.leading, 25)
                    .padding(.bottom, -20),  // 20픽셀 더 아래로 (18 -> 20)
                alignment: .bottomLeading
            )
            
            // Sleep timer and Version plate at bottom right
            .overlay(
                HStack(spacing: 12) {
                    // Sleep Timer Button
                    Button(action: {
                        showSleepTimerModal = true
                        HapticManager.shared.impact(style: .light)
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    viewModel.isSleepTimerActive ?
                                    Color.gray.opacity(0.12) :
                                    Color.white.opacity(0.7)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
                                )
                            
                            Text("⏝ ⏝")
                                .font(.system(size: 10.5, weight: .medium))
                                .foregroundColor(Color.black.opacity(0.92))
                        }
                        .opacity(0.7)
                        .frame(width: 29, height: 24)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Version Button
                    VersionPlateView(showSettings: $showSettingsModal)
                }
                .padding(.trailing, 23)  // 25 -> 23 (오른쪽으로 2픽셀)
                .padding(.bottom, 12),  // 1픽셀 더 아래로 (13 -> 12)
                alignment: .bottomTrailing
            )
            
            
            // Station List Modal
            if showStationList {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showStationList = false
                    }
                
                VStack {
                    Spacer()
                    
                    StationListView(
                        stations: viewModel.filteredStations,
                        currentStation: viewModel.currentStation,
                        onSelect: { station in
                            viewModel.selectStation(station)
                            if !viewModel.isPlaying {
                                viewModel.play() // 재생 중이 아닐 때만 재생 시작
                            }
                            showStationList = false
                            HapticManager.shared.impact(style: .light)
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
        }
        .sheet(isPresented: $showFavoritesModal) {
            FavoritesModalView(viewModel: viewModel)
        }
        .sheet(isPresented: $showSettingsModal) {
            SettingsModalView(viewModel: viewModel)
        }
        .sheet(isPresented: $showSleepTimerModal) {
            SleepTimerModalView(viewModel: viewModel)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                print("📱 App is active")
            case .inactive:
                print("📱 App is inactive")
            case .background:
                print("📱 App is in background - audio should continue playing")
                // Ensure audio continues in background
                if viewModel.isPlaying {
                    print("✅ Audio is playing, should continue in background")
                }
            @unknown default:
                break
            }
        }
    }
}

#Preview {
    ContentView()
}
