import Foundation
import AVFoundation

class PodcastParser: NSObject, XMLParserDelegate {
    private var episodes: [PodcastEpisode] = []
    private var currentElement = ""
    private var currentTitle = ""
    private var currentAudioURL = ""
    private var currentDescription = ""
    private var currentPubDate = ""
    
    struct PodcastEpisode {
        let title: String
        let audioURL: String
        let description: String
        let pubDate: String
    }
    
    func parsePodcastFeed(from url: String, completion: @escaping ([PodcastEpisode]) -> Void) {
        guard let feedURL = URL(string: url) else {
            print("📻 Invalid podcast feed URL: \(url)")
            completion([])
            return
        }
        
        print("📻 Fetching podcast feed from: \(url)")
        
        let task = URLSession.shared.dataTask(with: feedURL) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("📻 Failed to fetch podcast feed: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            print("📻 Received data: \(data.count) bytes")
            
            // Try to print first 500 characters to debug
            if let content = String(data: data, encoding: .utf8) {
                let preview = String(content.prefix(500))
                print("📻 Feed preview: \(preview)")
            }
            
            let parser = XMLParser(data: data)
            parser.delegate = self
            self?.episodes = []
            
            if parser.parse() {
                print("📻 Successfully parsed \(self?.episodes.count ?? 0) episodes")
                completion(self?.episodes ?? [])
            } else {
                print("📻 Failed to parse podcast feed - Parser error")
                if let error = parser.parserError {
                    print("📻 Parser error: \(error)")
                }
                completion([])
            }
        }
        task.resume()
    }
    
    // MARK: - XMLParserDelegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        
        if elementName == "item" {
            currentTitle = ""
            currentAudioURL = ""
            currentDescription = ""
            currentPubDate = ""
        } else if elementName == "enclosure" {
            // Check for audio URL in enclosure tag
            if let url = attributeDict["url"] {
                // Accept any enclosure with URL (some podcasts don't specify type)
                currentAudioURL = url
                print("📻 Found enclosure URL: \(url)")
            }
        } else if elementName == "media:content" {
            // Some feeds use media:content instead
            if let url = attributeDict["url"], let medium = attributeDict["medium"], medium == "audio" {
                currentAudioURL = url
                print("📻 Found media:content URL: \(url)")
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch currentElement {
        case "title":
            currentTitle += trimmedString
        case "description", "itunes:summary":
            currentDescription += trimmedString
        case "pubDate":
            currentPubDate += trimmedString
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            if !currentTitle.isEmpty && !currentAudioURL.isEmpty {
                let episode = PodcastEpisode(
                    title: currentTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                    audioURL: currentAudioURL,
                    description: currentDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                    pubDate: currentPubDate.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                episodes.append(episode)
                print("📻 Found episode: \(episode.title) - \(episode.audioURL)")
            } else {
                print("📻 Incomplete episode - Title: '\(currentTitle)' URL: '\(currentAudioURL)'")
            }
        }
    }
    
    func getLatestEpisodeURL(from feedURL: String, completion: @escaping (String?) -> Void) {
        parsePodcastFeed(from: feedURL) { episodes in
            // Return the most recent episode's audio URL
            completion(episodes.first?.audioURL)
        }
    }
}