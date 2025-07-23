import SwiftUI

struct StationListView: View {
    let stations: [RadioStation]
    let currentStation: RadioStation?
    let onSelect: (RadioStation) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            HandleBar()
            
            // Station list
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(stations) { station in
                        StationRow(
                            station: station,
                            isSelected: currentStation?.id == station.id,
                            isLast: station.id == stations.last?.id,
                            onSelect: { onSelect(station) }
                        )
                    }
                }
            }
        }
        .background(Color.white)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: -5)
    }
}

struct HandleBar: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .fill(Color.gray.opacity(0.3))
            .frame(width: 36, height: 5)
            .padding(.top, 8)
            .padding(.bottom, 16)
    }
}

struct StationRow: View {
    let station: RadioStation
    let isSelected: Bool
    let isLast: Bool
    let onSelect: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onSelect) {
                HStack(spacing: 16) {
                    // Radio icon
                    StationIcon(isSelected: isSelected)
                    
                    // Station info
                    StationInfo(station: station)
                    
                    Spacer()
                    
                    // Selection checkmark
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(isSelected ? Color.red.opacity(0.05) : Color.clear)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Separator
            if !isLast {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 1)
                    .padding(.leading, 76)
            }
        }
    }
}

struct StationIcon: View {
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.red : Color.gray.opacity(0.1))
                .frame(width: 40, height: 40)
            
            Image(systemName: "radio")
                .font(.system(size: 18))
                .foregroundColor(isSelected ? .white : .gray)
        }
    }
}

struct StationInfo: View {
    let station: RadioStation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(station.name)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
            
            HStack(spacing: 8) {
                Text("\(station.formattedFrequency) FM")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                
                if let subGenre = station.subGenre {
                    Text("•")
                        .font(.system(size: 13))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text(subGenre)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

