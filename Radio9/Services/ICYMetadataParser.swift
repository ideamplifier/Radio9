import Foundation

class ICYMetadataParser: NSObject {
    private var metadataInterval: Int = 0
    private var bytesUntilMetadata: Int = 0
    private var isParsingMetadata = false
    private var metadataBuffer = Data()
    private var audioBuffer = Data()
    
    // Callback for metadata updates
    var onMetadataReceived: ((String) -> Void)?
    
    // Parse ICY headers from response
    func parseICYHeaders(from response: URLResponse?) -> Bool {
        guard let httpResponse = response as? HTTPURLResponse else { return false }
        
        // Check for ICY metadata interval
        if let intervalString = httpResponse.allHeaderFields["icy-metaint"] as? String,
           let interval = Int(intervalString) {
            metadataInterval = interval
            bytesUntilMetadata = interval
            print("ICY metadata interval: \(interval)")
            
            // Log other ICY headers
            httpResponse.allHeaderFields.forEach { key, value in
                if let key = key as? String, key.lowercased().hasPrefix("icy-") {
                    print("\(key): \(value)")
                }
            }
            
            return true
        }
        
        return false
    }
    
    // Process incoming data stream
    func processData(_ data: Data) -> Data {
        guard metadataInterval > 0 else {
            // No metadata in this stream
            return data
        }
        
        var processedData = Data()
        var currentIndex = 0
        
        while currentIndex < data.count {
            if isParsingMetadata {
                // We're currently parsing metadata
                let remainingData = data[currentIndex...]
                let (bytesConsumed, metadataComplete) = parseMetadataChunk(remainingData)
                currentIndex += bytesConsumed
                
                if metadataComplete {
                    isParsingMetadata = false
                    bytesUntilMetadata = metadataInterval
                }
            } else {
                // We're processing audio data
                let remainingBytes = data.count - currentIndex
                let bytesToProcess = min(bytesUntilMetadata, remainingBytes)
                
                // Add audio data to processed output
                let audioChunk = data[currentIndex..<currentIndex + bytesToProcess]
                processedData.append(audioChunk)
                
                currentIndex += bytesToProcess
                bytesUntilMetadata -= bytesToProcess
                
                // Check if we've reached metadata
                if bytesUntilMetadata == 0 {
                    isParsingMetadata = true
                    metadataBuffer.removeAll()
                }
            }
        }
        
        return processedData
    }
    
    private func parseMetadataChunk(_ data: Data) -> (bytesConsumed: Int, complete: Bool) {
        guard !data.isEmpty else { return (0, false) }
        
        if metadataBuffer.isEmpty {
            // First byte is the metadata length / 16
            let metadataLength = Int(data[0]) * 16
            
            if metadataLength == 0 {
                // No metadata in this block
                return (1, true)
            }
            
            // Start collecting metadata
            let availableBytes = min(metadataLength + 1, data.count)
            metadataBuffer.append(data[0..<availableBytes])
            
            if metadataBuffer.count >= metadataLength + 1 {
                // We have all the metadata
                parseCompleteMetadata()
                return (availableBytes, true)
            }
            
            return (availableBytes, false)
        } else {
            // Continue collecting metadata
            let metadataLength = Int(metadataBuffer[0]) * 16
            let bytesNeeded = metadataLength + 1 - metadataBuffer.count
            let availableBytes = min(bytesNeeded, data.count)
            
            metadataBuffer.append(data[0..<availableBytes])
            
            if metadataBuffer.count >= metadataLength + 1 {
                // We have all the metadata
                parseCompleteMetadata()
                return (availableBytes, true)
            }
            
            return (availableBytes, false)
        }
    }
    
    private func parseCompleteMetadata() {
        guard metadataBuffer.count > 1 else { return }
        
        let metadataLength = Int(metadataBuffer[0]) * 16
        guard metadataLength > 0 else { return }
        
        // Extract metadata string (skip first byte which is length)
        let metadataData = metadataBuffer[1..<min(metadataLength + 1, metadataBuffer.count)]
        
        if let metadataString = String(data: metadataData, encoding: .utf8) {
            // Parse metadata string (typically "StreamTitle='Artist - Title';")
            parseMetadataString(metadataString)
        } else if let metadataString = String(data: metadataData, encoding: .isoLatin1) {
            // Try ISO Latin 1 encoding as fallback
            parseMetadataString(metadataString)
        }
    }
    
    private func parseMetadataString(_ metadata: String) {
        // Clean up the metadata string
        let cleanedMetadata = metadata.trimmingCharacters(in: .whitespaces)
            .trimmingCharacters(in: CharacterSet(charactersIn: "\0"))
        
        print("Raw metadata: \(cleanedMetadata)")
        
        // Parse StreamTitle
        if let match = cleanedMetadata.range(of: "StreamTitle='([^']*)'", options: .regularExpression) {
            let titleMatch = String(cleanedMetadata[match])
            let title = titleMatch
                .replacingOccurrences(of: "StreamTitle='", with: "")
                .replacingOccurrences(of: "'", with: "")
            
            if !title.isEmpty {
                print("Parsed title: \(title)")
                onMetadataReceived?(title)
            }
        }
    }
}

// Extension to create URLSession that requests ICY metadata
extension URLSession {
    static func createICYSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Icy-MetaData": "1"]
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 30
        return URLSession(configuration: config)
    }
}