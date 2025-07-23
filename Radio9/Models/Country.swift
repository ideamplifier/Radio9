import Foundation

struct Country: Identifiable, Equatable {
    let id = UUID()
    let code: String
    let name: String
    let flag: String
    
    static let countries = [
        Country(code: "AU", name: "Australia", flag: "🇦🇺"),
        Country(code: "BR", name: "Brazil", flag: "🇧🇷"),
        Country(code: "CA", name: "Canada", flag: "🇨🇦"),
        Country(code: "CN", name: "China", flag: "🇨🇳"),
        Country(code: "FR", name: "France", flag: "🇫🇷"),
        Country(code: "DE", name: "Germany", flag: "🇩🇪"),
        Country(code: "IN", name: "India", flag: "🇮🇳"),
        Country(code: "ID", name: "Indonesia", flag: "🇮🇩"),
        Country(code: "IT", name: "Italy", flag: "🇮🇹"),
        Country(code: "JP", name: "Japan", flag: "🇯🇵"),
        Country(code: "KR", name: "South Korea", flag: "🇰🇷"),
        Country(code: "MX", name: "Mexico", flag: "🇲🇽"),
        Country(code: "NL", name: "Netherlands", flag: "🇳🇱"),
        Country(code: "RU", name: "Russia", flag: "🇷🇺"),
        Country(code: "ES", name: "Spain", flag: "🇪🇸"),
        Country(code: "SE", name: "Sweden", flag: "🇸🇪"),
        Country(code: "CH", name: "Switzerland", flag: "🇨🇭"),
        Country(code: "TH", name: "Thailand", flag: "🇹🇭"),
        Country(code: "TR", name: "Turkey", flag: "🇹🇷"),
        Country(code: "GB", name: "United Kingdom", flag: "🇬🇧"),
        Country(code: "US", name: "United States", flag: "🇺🇸"),
        Country(code: "VN", name: "Vietnam", flag: "🇻🇳")
    ].sorted { $0.name < $1.name }
    
    static func defaultCountry() -> Country {
        let locale = Locale.current
        let countryCode = locale.region?.identifier ?? "US"
        return countries.first { $0.code == countryCode } ?? countries.first { $0.code == "US" }!
    }
}