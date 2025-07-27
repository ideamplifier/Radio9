import SwiftUI

struct GenreSelectorView: View {
    @ObservedObject var viewModel: RadioViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(StationGenre.mainCategories, id: \.self) { genre in
                    GenreButton(
                        genre: genre,
                        isSelected: viewModel.selectedGenre == genre,
                        action: {
                            viewModel.selectGenre(genre)
                            HapticManager.shared.impact(style: .light)
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 40)
    }
}

struct GenreButton: View {
    let genre: StationGenre
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(genre.displayName)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(isSelected ? .white : .black.opacity(0.6))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.orange : Color.gray.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.orange : Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}