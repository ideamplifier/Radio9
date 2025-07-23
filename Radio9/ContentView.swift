import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var viewModel = RadioViewModel()
    @State private var showStationList = false
    
    var body: some View {
        ZStack {
            // Full screen background
            Color(red: 0.98, green: 0.98, blue: 0.98)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with menu
                HStack {
                    Text("POCKET")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // Song Recognition Button
                    if viewModel.isPlaying {
                        Button(action: {
                            viewModel.recognizeCurrentSong()
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }) {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 16))
                                .foregroundColor(.black.opacity(0.7))
                        }
                        .padding(.trailing, 16)
                    }
                    
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
                .padding(.top, 50)
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
                    viewModel: viewModel
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
                                .foregroundColor(viewModel.hasPreviousStation() ? .black : .gray.opacity(0.3))
                                .frame(width: 44, height: 44)
                        }
                        .disabled(!viewModel.hasPreviousStation())
                        
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
                        .disabled(viewModel.currentStation == nil || viewModel.isLoading)
                        .opacity(viewModel.currentStation == nil ? 0.5 : 1.0)
                        
                        // Next Station Button
                        Button(action: {
                            viewModel.selectNextStation()
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 16))
                                .foregroundColor(viewModel.hasNextStation() ? .black : .gray.opacity(0.3))
                                .frame(width: 44, height: 44)
                        }
                        .disabled(!viewModel.hasNextStation())
                    }
                    
                    // Frequency Dial - Completely independent
                    IndependentDialView(
                        frequency: $viewModel.currentFrequency,
                        isCountrySelectionMode: viewModel.isCountrySelectionMode,
                        countrySelectionIndex: viewModel.countrySelectionIndex,
                        onFrequencyChange: { newFrequency in
                            viewModel.currentFrequency = newFrequency
                            if !viewModel.isCountrySelectionMode {
                                viewModel.tuneToFrequency(newFrequency)
                            }
                        },
                        onCountryChange: { newIndex in
                            viewModel.countrySelectionIndex = newIndex
                            viewModel.selectCountryByIndex(newIndex)
                        }
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