import SwiftUI

struct FavoritesModalView: View {
    @ObservedObject var viewModel: RadioViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with minimal design
            VStack(spacing: 2) {
                Text("Favorites")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(viewModel.selectedCountry.name)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 30)
            .padding(.bottom, 12)
            
            if viewModel.currentCountryFavorites.isEmpty {
                // Empty state
                VStack(spacing: 20) {
                    Spacer()
                    
                    
                    Text("Tap & hold the dial to add your favorite stations")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .frame(maxHeight: .infinity)
            } else {
                // Favorites list
                List {
                    ForEach(viewModel.currentCountryFavorites) { station in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(station.name)
                                    .font(.system(size: 16, weight: .medium))
                                    .lineLimit(1)
                                
                                Text("\(String(format: "%.1f", station.frequency)) MHz")
                                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Play button
                            Button(action: {
                                viewModel.selectStation(station)
                                if !viewModel.isPlaying {
                                    viewModel.play()
                                }
                                dismiss()
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }) {
                                Image(systemName: viewModel.currentStation?.id == station.id && viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(.vertical, 8)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    }
                    .onDelete { indexSet in
                        viewModel.removeFavorites(at: indexSet)
                    }
                }
                .listStyle(PlainListStyle())
                .environment(\.defaultMinListRowHeight, 0)
                .scrollContentBackground(.hidden)
            }
        }
        .presentationDetents([.height(370)])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(30)
    }
}