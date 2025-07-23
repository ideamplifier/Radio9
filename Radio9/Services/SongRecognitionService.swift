import Foundation
import ShazamKit
import AVFoundation

class SongRecognitionService: NSObject {
    private var session: SHSession?
    private var audioEngine: AVAudioEngine?
    private var isListening = false
    
    // Metadata from stream
    struct SongInfo {
        let title: String
        let artist: String
        let album: String?
        let artworkURL: String?
    }
    
    override init() {
        super.init()
        setupShazamSession()
    }
    
    private func setupShazamSession() {
        session = SHSession()
        session?.delegate = self
    }
    
    // MARK: - Method 1: Read Stream Metadata
    func extractMetadataFromStream(_ url: URL) async -> SongInfo? {
        // For Icecast/Shoutcast streams
        var request = URLRequest(url: url)
        request.setValue("1", forHTTPHeaderField: "Icy-MetaData")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               let icyMetaInt = httpResponse.value(forHTTPHeaderField: "icy-metaint") {
                // Parse metadata from stream
                return parseIcyMetadata(from: data, metaInt: Int(icyMetaInt) ?? 0)
            }
        } catch {
            print("Failed to extract metadata: \(error)")
        }
        
        return nil
    }
    
    // MARK: - Method 2: Shazam Recognition
    func startShazamRecognition() {
        guard !isListening else { return }
        
        // Check microphone permission first
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            guard granted else {
                print("Microphone permission denied")
                return
            }
            
            DispatchQueue.main.async {
                self?.setupAndStartRecognition()
            }
        }
    }
    
    private func setupAndStartRecognition() {
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }
        
        let inputNode = audioEngine.inputNode
        
        do {
            // Configure audio session for recording
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord,
                                                           mode: .default,
                                                           options: [.defaultToSpeaker, .mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Get the native format of the input node
            let nativeFormat = inputNode.inputFormat(forBus: 0)
            
            // Check if format is valid
            if nativeFormat.sampleRate == 0 || nativeFormat.channelCount == 0 {
                print("Invalid audio format")
                return
            }
            
            // Install tap with native format
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: nativeFormat) { [weak self] buffer, time in
                self?.session?.matchStreamingBuffer(buffer, at: time)
            }
            
            try audioEngine.start()
            isListening = true
            print("Shazam recognition started")
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    func stopShazamRecognition() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine = nil
        isListening = false
    }
    
    // MARK: - Method 3: Simple metadata extraction from HLS streams
    func extractMetadataFromPlayer(_ player: AVPlayer) async -> SongInfo? {
        guard let playerItem = player.currentItem else { return nil }
        
        // Check for metadata in the player item
        let metadata = playerItem.asset.metadata
        
        var title: String?
        var artist: String?
        
        for item in metadata {
            if let key = item.commonKey?.rawValue {
                switch key {
                case "title":
                    title = try? await item.load(.stringValue)
                case "artist":
                    artist = try? await item.load(.stringValue)
                default:
                    break
                }
            }
        }
        
        if let title = title {
            return SongInfo(
                title: title,
                artist: artist ?? "Unknown Artist",
                album: nil,
                artworkURL: nil
            )
        }
        
        return nil
    }
    
    private func parseIcyMetadata(from data: Data, metaInt: Int) -> SongInfo? {
        // Parse Icecast metadata format
        // Format: StreamTitle='Artist - Title';StreamUrl='URL';
        guard metaInt > 0 else { return nil }
        
        // This is simplified - actual implementation would need to parse the stream properly
        if let metadataString = String(data: data, encoding: .utf8),
           let titleRange = metadataString.range(of: "StreamTitle='"),
           let endRange = metadataString.range(of: "';", range: titleRange.upperBound..<metadataString.endIndex) {
            
            let fullTitle = String(metadataString[titleRange.upperBound..<endRange.lowerBound])
            let components = fullTitle.split(separator: "-", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
            
            if components.count >= 2 {
                return SongInfo(
                    title: components[1],
                    artist: components[0],
                    album: nil,
                    artworkURL: nil
                )
            }
        }
        
        return nil
    }
}

// MARK: - SHSessionDelegate
extension SongRecognitionService: SHSessionDelegate {
    func session(_ session: SHSession, didFind match: SHMatch) {
        guard let mediaItem = match.mediaItems.first else { return }
        
        let songInfo = SongInfo(
            title: mediaItem.title ?? "Unknown",
            artist: mediaItem.artist ?? "Unknown",
            album: nil,  // albumTitle is not available in SHMatchedMediaItem
            artworkURL: mediaItem.artworkURL?.absoluteString
        )
        
        // Post notification with song info
        NotificationCenter.default.post(
            name: .songRecognized,
            object: nil,
            userInfo: ["songInfo": songInfo]
        )
    }
    
    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        print("No match found: \(error?.localizedDescription ?? "Unknown error")")
    }
}

extension Notification.Name {
    static let songRecognized = Notification.Name("songRecognized")
}