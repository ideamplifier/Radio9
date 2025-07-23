import Foundation

class RadioBrowserAPI {
    static let shared = RadioBrowserAPI()
    
    // Radio Browser API - 완전 무료, 인증 불필요
    private let baseURL = "https://de1.api.radio-browser.info/json/stations"
    
    // 캐시된 스테이션들
    private var cachedStations: [String: [RadioStation]] = [:]
    
    // 국가별 인기 스테이션 가져오기
    func fetchStations(for countryCode: String) async -> [RadioStation] {
        // 캐시 확인
        if let cached = cachedStations[countryCode] {
            return cached
        }
        
        // 국가별 상위 100개 스테이션 가져오기
        let urlString = "\(baseURL)/bycountrycodeexact/\(countryCode.lowercased())?limit=100&order=clickcount&reverse=true&hidebroken=true"
        
        guard let url = URL(string: urlString) else { return getDefaultStations(for: countryCode) }
        
        do {
            var request = URLRequest(url: url)
            request.setValue("Radio9/1.0", forHTTPHeaderField: "User-Agent")
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let stations = try JSONDecoder().decode([RadioBrowserStation].self, from: data)
            
            let radioStations = stations.prefix(50).enumerated().compactMap { index, station -> RadioStation? in
                // 유효한 스트림 URL만 사용
                guard !station.url.isEmpty,
                      let streamURL = URL(string: station.url_resolved ?? station.url) else { return nil }
                
                // Distribute frequencies across full 88-108 range
                let frequency = 88.0 + (Double(index) / 50.0) * 20.0
                let genre = mapGenre(from: station.tags)
                
                return RadioStation(
                    name: station.name.trimmingCharacters(in: .whitespacesAndNewlines),
                    frequency: frequency,
                    streamURL: streamURL.absoluteString,
                    genre: genre,
                    subGenre: station.tags?.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
            
            // 캐시에 저장
            cachedStations[countryCode] = radioStations
            
            return radioStations.isEmpty ? getDefaultStations(for: countryCode) : radioStations
            
        } catch {
            print("API Error: \(error)")
            return getDefaultStations(for: countryCode)
        }
    }
    
    // 전세계 인기 스테이션
    func fetchTopStations() async -> [RadioStation] {
        let urlString = "\(baseURL)/topclick?limit=50&hidebroken=true"
        
        guard let url = URL(string: urlString) else { return [] }
        
        do {
            var request = URLRequest(url: url)
            request.setValue("Radio9/1.0", forHTTPHeaderField: "User-Agent")
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let stations = try JSONDecoder().decode([RadioBrowserStation].self, from: data)
            
            return stations.enumerated().compactMap { index, station -> RadioStation? in
                guard !station.url.isEmpty,
                      let streamURL = URL(string: station.url_resolved ?? station.url) else { return nil }
                
                // Distribute frequencies across full 88-108 range
                let frequency = 88.0 + (Double(index) / 50.0) * 20.0
                let genre = mapGenre(from: station.tags)
                
                return RadioStation(
                    name: station.name.trimmingCharacters(in: .whitespacesAndNewlines),
                    frequency: frequency,
                    streamURL: streamURL.absoluteString,
                    genre: genre,
                    subGenre: station.tags?.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
        } catch {
            print("API Error: \(error)")
            return []
        }
    }
    
    private func mapGenre(from tags: String?) -> StationGenre {
        guard let tags = tags?.lowercased() else { return .music }
        
        if tags.contains("news") || tags.contains("talk") { return .news }
        if tags.contains("pop") || tags.contains("top 40") { return .pop }
        if tags.contains("rock") || tags.contains("alternative") { return .rock }
        if tags.contains("jazz") { return .jazz }
        if tags.contains("classical") { return .classical }
        if tags.contains("sport") { return .sports }
        if tags.contains("education") || tags.contains("public") { return .education }
        if tags.contains("dance") || tags.contains("electronic") { return .music }
        
        return .music
    }
    
    // 기본 스테이션 (API 실패 시)
    private func getDefaultStations(for countryCode: String) -> [RadioStation] {
        // 검증된 기본 스테이션들 - 100% 작동하는 URL들
        return [
            RadioStation(name: "SomaFM Groove Salad", frequency: 88.1, streamURL: "http://ice2.somafm.com/groovesalad-128-mp3", genre: .music),
            RadioStation(name: "Radio Paradise Main", frequency: 90.3, streamURL: "http://stream.radioparadise.com/aac-128", genre: .rock),
            RadioStation(name: "KEXP Seattle", frequency: 89.1, streamURL: "http://live-mp3-128.kexp.org/", genre: .rock),
            RadioStation(name: "Classic FM", frequency: 93.5, streamURL: "http://media-ice.musicradio.com/ClassicFMMP3", genre: .classical),
            RadioStation(name: "Jazz24", frequency: 88.5, streamURL: "http://ais-sa2.cdnstream1.com/2366_128.mp3", genre: .jazz)
        ]
    }
}

// API 응답 모델
struct RadioBrowserStation: Codable {
    let name: String
    let url: String
    let url_resolved: String?
    let homepage: String?
    let favicon: String?
    let tags: String?
    let country: String?
    let countrycode: String?
    let language: String?
    let votes: Int?
    let codec: String?
    let bitrate: Int?
}