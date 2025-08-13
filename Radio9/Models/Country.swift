import Foundation

struct Country: Identifiable, Equatable {
    let id = UUID()
    let code: String
    let name: String
    let flag: String
    let defaultFrequency: Double
    
    static let countries = [
        // Sound Categories (using Country struct for backward compatibility)
        Country(code: "NATURE", name: "Nature", flag: "🌿", defaultFrequency: 88.1),
        Country(code: "LOFI", name: "Lo-Fi", flag: "🎵", defaultFrequency: 88.1),
        Country(code: "CLASSIC", name: "Classic", flag: "🎼", defaultFrequency: 88.1),
        Country(code: "PODCAST", name: "Podcast", flag: "🎙️", defaultFrequency: 88.1),
        Country(code: "RADIO", name: "Radio", flag: "📻", defaultFrequency: 88.1),
    ]
    
    static func defaultCountry() -> Country {
        // Default to Nature sounds
        return countries.first { $0.code == "NATURE" }!
    }
}