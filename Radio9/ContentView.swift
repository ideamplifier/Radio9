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
    
    var body: some View {
        ZStack {
            // Full screen background
            Color(red: 0.98, green: 0.98, blue: 0.98)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with menu
                HStack {
                    Text("HOSONO")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.1, green: 0.09, blue: 0.0).opacity(0.95))
                        .shadow(color: Color.white.opacity(0.8), radius: 0.5, x: 0, y: -1)
                        .shadow(color: Color.black.opacity(0.3), radius: 0.5, x: 0, y: 1)
                    
                    Spacer()
                    
                    Button(action: { 
                        showStationList.toggle()
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                    }
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
                                .foregroundColor(.black)
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
                                .foregroundColor(.black)
                                .frame(width: 44, height: 44)
                        }
                        .disabled(false)
                        .id("nextButton")
                    }
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
                        isInteracting: $isDialInteracting
                    )
                    .frame(width: 240, height: 240)
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
    }
}

#Preview {
    ContentView()
}