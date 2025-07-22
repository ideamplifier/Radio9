import SwiftUI

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
                    isPlaying: viewModel.isPlaying
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
                            Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.orange)
                                .offset(x: viewModel.isPlaying ? 0 : 2)
                        }
                        .disabled(viewModel.currentStation == nil)
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
                    FrequencyDialView(frequency: $viewModel.currentFrequency)
                        .frame(width: 240, height: 240)
                        .onChange(of: viewModel.currentFrequency) { _, newValue in
                            viewModel.tuneToFrequency(newValue)
                        }
                }
                
                Spacer()
                
                // Bottom Controls
                HStack {
                    // Menu Button
                    Button(action: {}) {
                        VStack(spacing: 3) {
                            ForEach(0..<3) { _ in
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Color.gray.opacity(0.4))
                                    .frame(width: 20, height: 2)
                            }
                        }
                    }
                    .padding(.leading, 30)
                    
                    Spacer()
                    
                    // Preset Stations
                    HStack(spacing: 16) {
                        ForEach(0..<3) { index in
                            Button(action: {
                                if index < viewModel.stations.count {
                                    viewModel.selectStation(viewModel.stations[index])
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }
                            }) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(index < viewModel.stations.count && 
                                         viewModel.currentStation?.id == viewModel.stations[index].id 
                                         ? Color.orange : Color.gray.opacity(0.2))
                                    .frame(width: 40, height: 6)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Shuffle Button
                    Button(action: {}) {
                        Image(systemName: "shuffle")
                            .font(.system(size: 18))
                            .foregroundColor(.orange)
                    }
                    .padding(.trailing, 30)
                }
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
                        stations: viewModel.stations,
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
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showStationList)
    }
}

#Preview {
    ContentView()
}