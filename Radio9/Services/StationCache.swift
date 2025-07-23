import Foundation

class StationCache {
    static let shared = StationCache()
    
    private let cacheQueue = DispatchQueue(label: "com.radio9.cache", attributes: .concurrent)
    private var memoryCache: [String: Any] = [:]
    private let maxCacheAge: TimeInterval = 3600 // 1 hour
    
    private init() {
        // Setup cache cleanup timer
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            self.cleanupExpiredCache()
        }
    }
    
    func cacheStationData(_ station: RadioStation, data: Data) {
        cacheQueue.async(flags: .barrier) {
            let key = "station_\(station.id)"
            self.memoryCache[key] = CacheEntry(data: data, timestamp: Date())
        }
    }
    
    func getCachedData(for station: RadioStation) -> Data? {
        cacheQueue.sync {
            let key = "station_\(station.id)"
            guard let entry = memoryCache[key] as? CacheEntry else { return nil }
            
            // Check if cache is still valid
            if Date().timeIntervalSince(entry.timestamp) < maxCacheAge {
                return entry.data
            }
            return nil
        }
    }
    
    func cacheStreamURL(_ originalURL: String, resolvedURL: String) {
        cacheQueue.async(flags: .barrier) {
            self.memoryCache["url_\(originalURL)"] = resolvedURL
        }
    }
    
    func getCachedStreamURL(for originalURL: String) -> String? {
        cacheQueue.sync {
            memoryCache["url_\(originalURL)"] as? String
        }
    }
    
    private func cleanupExpiredCache() {
        cacheQueue.async(flags: .barrier) {
            let now = Date()
            self.memoryCache = self.memoryCache.compactMapValues { value in
                if let entry = value as? CacheEntry {
                    return now.timeIntervalSince(entry.timestamp) < self.maxCacheAge ? value : nil
                }
                return value
            }
        }
    }
    
    private struct CacheEntry {
        let data: Data
        let timestamp: Date
    }
}