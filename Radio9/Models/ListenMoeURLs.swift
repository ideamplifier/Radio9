import Foundation

// Listen.moe 스트림 URL 매핑
struct ListenMoeURLs {
    static let jpopMP3 = "https://listen.moe/fallback"
    static let jpopOpus = "https://listen.moe/opus"
    static let kpopMP3 = "https://listen.moe/kpop/fallback"
    static let kpopOpus = "https://listen.moe/kpop/opus"
    
    // API에서 가져온 URL을 실제 작동하는 URL로 변환
    static func getWorkingURL(for originalURL: String) -> String? {
        if originalURL.contains("listen.moe") {
            if originalURL.contains("kpop") {
                return kpopMP3
            } else {
                return jpopMP3
            }
        }
        return nil
    }
}