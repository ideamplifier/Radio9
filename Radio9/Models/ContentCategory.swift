import Foundation

enum ContentCategory: String, CaseIterable, Codable {
    case nature = "Nature"
    case radio = "Radio"
    case lofi = "Lo-Fi"
    case classical = "Classical"
    case podcast = "Podcast"
    
    var displayName: String {
        switch self {
        case .nature: return "자연의 소리"
        case .radio: return "라디오"
        case .lofi: return "Lo-Fi"
        case .classical: return "클래식"
        case .podcast: return "팟캐스트"
        }
    }
    
    var emoji: String {
        switch self {
        case .nature: return "🌿"
        case .radio: return "📻"
        case .lofi: return "🎵"
        case .classical: return "🎼"
        case .podcast: return "🎙️"
        }
    }
    
    var defaultFrequency: Double {
        return 88.1
    }
}

// ContentCategory extension - Station definitions are in RadioStation.swift