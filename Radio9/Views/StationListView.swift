import SwiftUI

struct StationListView: View {
    let stations: [RadioStation]
    let currentStation: RadioStation?
    let onSelect: (RadioStation) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 16)
            
            // Station list
            VStack(spacing: 0) {
                ForEach(stations) { station in
                    Button(action: { onSelect(station) }) {
                        HStack(spacing: 16) {
                            // Radio icon
                            ZStack {
                                Circle()
                                    .fill(currentStation?.id == station.id ? Color.red : Color.gray.opacity(0.1))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: "radio")
                                    .font(.system(size: 18))
                                    .foregroundColor(currentStation?.id == station.id ? .white : .gray)
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(station.name)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                
                                HStack(spacing: 8) {
                                    Text("\(station.formattedFrequency) FM")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                    
                                    if let genre = station.genre {
                                        Text("•")
                                            .font(.system(size: 13))
                                            .foregroundColor(.gray.opacity(0.5))
                                        
                                        Text(genre)
                                            .font(.system(size: 13))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            if currentStation?.id == station.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(currentStation?.id == station.id ? Color.red.opacity(0.05) : Color.clear)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if station.id != stations.last?.id {
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 1)
                            .padding(.leading, 76)
                    }
                }
            }
        }
        .background(Color.white)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: -5)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}