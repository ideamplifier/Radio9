import Foundation

struct RadioStation: Identifiable, Codable, Equatable {
    let id = UUID()
    let name: String
    let frequency: Double
    let streamURL: String
    let genre: String?
    
    var formattedFrequency: String {
        String(format: "%.1f", frequency)
    }
}

extension RadioStation {
    static let sampleStations = [
        RadioStation(
            name: "KBS Cool FM",
            frequency: 89.1,
            streamURL: "https://example.com/kbs-cool",
            genre: "Pop"
        ),
        RadioStation(
            name: "MBC FM",
            frequency: 91.9,
            streamURL: "https://example.com/mbc-fm",
            genre: "Various"
        ),
        RadioStation(
            name: "SBS Power FM",
            frequency: 107.7,
            streamURL: "https://example.com/sbs-power",
            genre: "Pop/Rock"
        )
    ]
}