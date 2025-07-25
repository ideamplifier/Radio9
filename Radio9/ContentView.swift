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
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        ZStack {
            // Full screen background
            Color(red: 0.98, green: 0.98, blue: 0.98)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with menu
                HStack {
                    VStack(alignment: .leading, spacing: -1.5) {
                        Text("HOSONO")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.2, green: 0.17, blue: 0.0).opacity(0.92))
                            .shadow(color: Color.white.opacity(0.1), radius: 2)
                            .tracking(-0.3)
                        
                        Text("ラジオ")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
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
                SpeakerGrillView()
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                
                // Station Display with Skeuomorphic LCD
                StationDisplayView(
                    station: viewModel.currentStation,
                    frequency: viewModel.currentFrequency,
                    isPlaying: viewModel.isPlaying,
                    viewModel: viewModel,
                    isDialInteracting: isDialInteracting
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
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
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
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
                        isInteracting: $isDialInteracting
                    )
                    .frame(width: 228, height: 228)
                    .offset(y: -10)
                }
                
                Spacer()
                    .frame(height: 40)
            }
            
            
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
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
        }
        .overlay(
            // 우측 하단 세로 캡슐
            Capsule()
                .fill(Color(red: 0.15, green: 0.12, blue: 0.0).opacity(0.95))
                .frame(width: 30, height: 80)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)
                .padding(.trailing, 30)
                .padding(.bottom, 40),
            alignment: .bottomTrailing
        )
        .sheet(isPresented: $showFavoritesModal) {
            FavoritesModalView(viewModel: viewModel)
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