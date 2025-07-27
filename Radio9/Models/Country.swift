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
        Country(code: "FR", name: "France", flag: "🇫🇷", defaultFrequency: 105.1),   // NRJ
        Country(code: "FI", name: "Finland", flag: "🇫🇮", defaultFrequency: 94.0),   // Yle Radio Suomi
        Country(code: "DE", name: "Germany", flag: "🇩🇪", defaultFrequency: 103.7),   // Antenne Bayern
        Country(code: "IS", name: "Iceland", flag: "🇮🇸", defaultFrequency: 92.4),   // Rás 1
        Country(code: "IN", name: "India", flag: "🇮🇳", defaultFrequency: 91.1),     // Radio City Hindi
        Country(code: "IT", name: "Italy", flag: "🇮🇹", defaultFrequency: 105.0),    // Radio Italia
        Country(code: "JP", name: "Japan", flag: "🇯🇵", defaultFrequency: 89.7),     // Japan Hits
        Country(code: "KR", name: "South Korea", flag: "🇰🇷", defaultFrequency: 92.4), // 올드팝카페
        Country(code: "MX", name: "Mexico", flag: "🇲🇽", defaultFrequency: 104.3),   // Los 40
        Country(code: "MN", name: "Mongolia", flag: "🇲🇳", defaultFrequency: 99.0),  // MNB Radio
        Country(code: "RU", name: "Russia", flag: "🇷🇺", defaultFrequency: 106.2),   // Europa Plus
        Country(code: "ES", name: "Spain", flag: "🇪🇸", defaultFrequency: 100.0),    // Cadena 100
        Country(code: "SE", name: "Sweden", flag: "🇸🇪", defaultFrequency: 92.4),    // P3 Sveriges Radio
        Country(code: "TW", name: "Taiwan", flag: "🇹🇼", defaultFrequency: 100.7),   // ICRT
        Country(code: "TH", name: "Thailand", flag: "🇹🇭", defaultFrequency: 93.0),  // Cool Fahrenheit
        Country(code: "GB", name: "United Kingdom", flag: "🇬🇧", defaultFrequency: 95.8), // Capital FM
        Country(code: "US", name: "United States", flag: "🇺🇸", defaultFrequency: 106.4)  // Soft Classic Rock Radio
    ].sorted { $0.name < $1.name }
    
    static func defaultCountry() -> Country {
        let locale = Locale.current
        let countryCode = locale.region?.identifier ?? "US"
        return countries.first { $0.code == countryCode } ?? countries.first { $0.code == "US" }!
    }
}