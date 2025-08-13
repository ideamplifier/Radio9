import Foundation

// Test podcast RSS parsing
class TestPodcast {
    static func testRebuildFM() {
        let url = URL(string: "https://feeds.rebuild.fm/rebuildfm")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            
            if let xmlString = String(data: data, encoding: .utf8) {
                // Find all enclosure tags
                let pattern = #"<enclosure[^>]*url="([^"]+)"[^>]*>"#
                
                if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                    let matches = regex.matches(in: xmlString, options: [], range: NSRange(location: 0, length: xmlString.count))
                    
                    for match in matches.prefix(3) {
                        if let range = Range(match.range(at: 1), in: xmlString) {
                            let url = String(xmlString[range])
                            print("Found MP3: \(url)")
                        }
                    }
                }
            }
        }.resume()
    }
}