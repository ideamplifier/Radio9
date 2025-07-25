import Foundation

struct Country: Identifiable, Equatable {
    let id = UUID()
    let code: String
    let name: String
    let flag: String
    let defaultFrequency: Double
    
    static let countries = [
        Country(code: "AU", name: "Australia", flag: "🇦🇺", defaultFrequency: 104.1),  // Triple J
        Country(code: "BR", name: "Brazil", flag: "🇧🇷", defaultFrequency: 89.1),    // Radio Globo
        Country(code: "CA", name: "Canada", flag: "🇨🇦", defaultFrequency: 99.9),    // Virgin Radio
        Country(code: "CN", name: "China", flag: "🇨🇳", defaultFrequency: 88.7),     // CNR
        Country(code: "FR", name: "France", flag: "🇫🇷", defaultFrequency: 105.1),   // France Info
        Country(code: "DE", name: "Germany", flag: "🇩🇪", defaultFrequency: 103.7),   // Antenne Bayern
        Country(code: "IN", name: "India", flag: "🇮🇳", defaultFrequency: 93.5),     // Red FM
        Country(code: "ID", name: "Indonesia", flag: "🇮🇩", defaultFrequency: 87.6),  // Hard Rock FM
        Country(code: "IT", name: "Italy", flag: "🇮🇹", defaultFrequency: 105.0),    // Radio Italia
        Country(code: "JP", name: "Japan", flag: "🇯🇵", defaultFrequency: 89.7),     // Japan Hits
        Country(code: "KR", name: "South Korea", flag: "🇰🇷", defaultFrequency: 92.4), // 올드팝카페 OLDIES
        Country(code: "MX", name: "Mexico", flag: "🇲🇽", defaultFrequency: 104.3),   // Los 40
        Country(code: "NL", name: "Netherlands", flag: "🇳🇱", defaultFrequency: 100.7), // Radio 538
        Country(code: "RU", name: "Russia", flag: "🇷🇺", defaultFrequency: 103.0),   // Europa Plus
        Country(code: "ES", name: "Spain", flag: "🇪🇸", defaultFrequency: 100.0),    // Cadena 100
        Country(code: "SE", name: "Sweden", flag: "🇸🇪", defaultFrequency: 104.3),   // P3
        Country(code: "CH", name: "Switzerland", flag: "🇨🇭", defaultFrequency: 93.6), // Radio SRF
        Country(code: "TH", name: "Thailand", flag: "🇹🇭", defaultFrequency: 95.5),  // Virgin Hitz
        Country(code: "TR", name: "Turkey", flag: "🇹🇷", defaultFrequency: 97.4),    // Joy FM
        Country(code: "GB", name: "United Kingdom", flag: "🇬🇧", defaultFrequency: 95.8), // Capital FM
        Country(code: "US", name: "United States", flag: "🇺🇸", defaultFrequency: 90.3), // KEXP Seattle
        Country(code: "VN", name: "Vietnam", flag: "🇻🇳", defaultFrequency: 99.9)    // VOV3
    ].sorted { $0.name < $1.name }
    
    static func defaultCountry() -> Country {
        let locale = Locale.current
        let countryCode = locale.region?.identifier ?? "US"
        return countries.first { $0.code == countryCode } ?? countries.first { $0.code == "US" }!
    }
}