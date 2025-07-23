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
                    Text("Radio9")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                    
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
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                
                // Control Section
                VStack(spacing: 20) {
                    // Playback Controls
                    HStack(spacing: 30) {
                        Button(action: {}) {
                            Image(systemName: "pause.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.gray.opacity(0.3))
                                .frame(width: 44, height: 44)
                        }
                        .disabled(true)
                        
                        // Main Play/Pause Button
                        Button(action: { 
                            viewModel.togglePlayPause()
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }) {
                            ZStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                                } else {
                                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.orange)
                                        .offset(x: viewModel.isPlaying ? 0 : 2)
                                }
                            }
                        }
                        .disabled(viewModel.currentStation == nil || viewModel.isLoading)
                        .opacity(viewModel.currentStation == nil ? 0.5 : 1.0)
                        
                        Button(action: {}) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.gray.opacity(0.3))
                                .frame(width: 44, height: 44)
                        }
                        .disabled(true)
                    }
                    
                    // Frequency Dial
                    FrequencyDialView(
                        frequency: $viewModel.currentFrequency,
                        viewModel: viewModel
                    )
                    .frame(width: 240, height: 240)
                    .onChange(of: viewModel.currentFrequency) { newValue in
                        if !viewModel.isCountrySelectionMode {
                            viewModel.tuneToFrequency(newValue)
                        }
                    }
                }
                
                Spacer()
                
                // Bottom Controls - 9 preset buttons (favorites)
                HStack(spacing: 14) {
                    ForEach(0..<9) { index in
                        ZStack {
                            // Short capsule shape
                            Capsule()
                                .fill(viewModel.favoriteStations[index] != nil && 
                                     viewModel.currentStation?.id == viewModel.favoriteStations[index]?.id 
                                     ? Color.orange : 
                                     viewModel.favoriteStations[index] != nil 
                                     ? Color.gray.opacity(0.3) 
                                     : Color.gray.opacity(0.15))
                                .frame(width: 16, height: 12)
                        }
                        .onTapGesture {
                            if let station = viewModel.favoriteStations[index] {
                                viewModel.selectStation(station)
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                        }
                        .onLongPressGesture(minimumDuration: 0.5) {
                            if let currentStation = viewModel.currentStation {
                                viewModel.saveFavorite(station: currentStation, at: index)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
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