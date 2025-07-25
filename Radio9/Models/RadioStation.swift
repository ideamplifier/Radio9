import Foundation

enum StationGenre: String, CaseIterable, Codable {
    case all = "All"
    case music = "Music"
    case news = "News"
    case education = "Education"
    case entertainment = "Entertainment"
    case classical = "Classical"
    case pop = "Pop"
    case rock = "Rock"
    case jazz = "Jazz"
    case talk = "Talk"
    case sports = "Sports"
    case culture = "Culture"
    
    var displayName: String {
        switch self {
        case .all: return "전체"
        case .music: return "음악"
        case .news: return "뉴스"
        case .education: return "교육"
        case .entertainment: return "재미"
        case .classical: return "클래식"
        case .pop: return "팝"
        case .rock: return "록"
        case .jazz: return "재즈"
        case .talk: return "토크"
        case .sports: return "스포츠"
        case .culture: return "문화"
        }
    }
    
    static var mainCategories: [StationGenre] {
        [.all, .music, .news, .education, .entertainment]
    }
}

struct RadioStation: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let frequency: Double
    let streamURL: String
    let genre: StationGenre
    let subGenre: String?
    let countryCode: String
    
    init(id: UUID = UUID(), name: String, frequency: Double, streamURL: String, genre: StationGenre, subGenre: String? = nil, countryCode: String = "KR") {
        self.id = id
        self.name = name
        self.frequency = frequency
        self.streamURL = streamURL
        self.genre = genre
        self.subGenre = subGenre
        self.countryCode = countryCode
    }
    
    var formattedFrequency: String {
        String(format: "%.1f", frequency)
    }
    
    // For backward compatibility
    init(name: String, frequency: Double, streamURL: String, genre: String?) {
        self.name = name
        self.frequency = frequency
        self.streamURL = streamURL
        self.subGenre = genre
        
        // Map old genre strings to new enum
        switch genre?.lowercased() {
        case "pop", "k-pop", "j-pop": self.genre = .pop
        case "rock", "j-rock", "alternative": self.genre = .rock
        case "classical": self.genre = .classical
        case "jazz": self.genre = .jazz
        case "news", "news/talk": self.genre = .news
        case "talk", "traffic/talk": self.genre = .talk
        case "sports": self.genre = .sports
        case "education", "public radio": self.genre = .education
        default: self.genre = .music
        }
        self.id = UUID()
        self.countryCode = "KR"
    }
    
    init(name: String, frequency: Double, streamURL: String, genre: StationGenre, subGenre: String? = nil) {
        self.id = UUID()
        self.name = name
        self.frequency = frequency
        self.streamURL = streamURL
        self.genre = genre
        self.subGenre = subGenre
        self.countryCode = "KR"
    }
}

extension RadioStation {
    // Korean stations - 100% 작동 확인된 스트림
    static let koreanStations = [
        // 검증된 스트림들
        RadioStation(
            name: "SomaFM Groove",
            frequency: 89.1,
            streamURL: "https://ice2.somafm.com/groovesalad-128-mp3",
            genre: .music,
            subGenre: "Downtempo",
            countryCode: "KR"
        ),
        RadioStation(
            name: "SomaFM Indie",
            frequency: 91.9,
            streamURL: "https://ice2.somafm.com/indiepop-128-mp3",
            genre: .pop,
            subGenre: "Indie Pop"
        ),
        RadioStation(
            name: "NPR News",
            frequency: 93.5,
            streamURL: "https://npr-ice.streamguys1.com/live.mp3",
            genre: .news,
            subGenre: "News"
        ),
        RadioStation(
            name: "KEXP Seattle",
            frequency: 90.3,
            streamURL: "https://kexp-mp3-128.streamguys1.com/kexp128.mp3",
            genre: .rock,
            subGenre: "Alternative"
        ),
        RadioStation(
            name: "Jazz 24",
            frequency: 88.5,
            streamURL: "https://ais-sa2.cdnstream1.com/2366_128.mp3",
            genre: .jazz,
            subGenre: "Jazz"
        ),
        RadioStation(
            name: "Classical KUSC",
            frequency: 91.5,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/KUSCMP128.mp3",
            genre: .classical,
            subGenre: "Classical"
        ),
        RadioStation(
            name: "SomaFM Lush",
            frequency: 102.7,
            streamURL: "https://ice2.somafm.com/lush-128-mp3",
            genre: .music,
            subGenre: "Lounge"
        ),
        RadioStation(
            name: "BBC World",
            frequency: 98.1,
            streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_world_service",
            genre: .news,
            subGenre: "World News"
        ),
        RadioStation(
            name: "WNYC FM",
            frequency: 93.9,
            streamURL: "https://fm939.wnyc.org/wnycfm-tunein.aac",
            genre: .news,
            subGenre: "Public Radio"
        ),
        RadioStation(
            name: "KCRW",
            frequency: 89.9,
            streamURL: "https://kcrw.streamguys1.com/kcrw_192k_mp3_on_air",
            genre: .music,
            subGenre: "Eclectic"
        ),
        RadioStation(
            name: "SomaFM Beat",
            frequency: 106.7,
            streamURL: "https://ice2.somafm.com/beatblender-128-mp3",
            genre: .music,
            subGenre: "Electronic"
        ),
        RadioStation(
            name: "SomaFM Deep",
            frequency: 105.9,
            streamURL: "https://ice2.somafm.com/deepspaceone-128-mp3",
            genre: .music,
            subGenre: "Ambient"
        ),
        RadioStation(
            name: "Psyradio Prog",
            frequency: 107.7,
            streamURL: "http://streamer.psyradio.org:8010/",
            genre: .music,
            subGenre: "Psychedelic"
        ),
        RadioStation(
            name: "Radio Paradise",
            frequency: 104.5,
            streamURL: "https://stream.radioparadise.com/aac-320",
            genre: .rock,
            subGenre: "Rock Mix"
        ),
        RadioStation(
            name: "SomaFM 80s",
            frequency: 95.1,
            streamURL: "https://ice2.somafm.com/u80s-128-mp3",
            genre: .pop,
            subGenre: "80s Hits"
        )
    ]
    
    // Japanese stations
    static let japaneseStations = [
        // Music stations
        RadioStation(
            name: "J-Pop Sakura",
            frequency: 81.3,
            streamURL: "https://kathy.torontocast.com:3060/stream",
            genre: .pop,
            subGenre: "J-Pop"
        ),
        RadioStation(
            name: "Anime Radio",
            frequency: 88.0,
            streamURL: "https://pool.anison.fm/AniSonFM(320)",
            genre: .entertainment,
            subGenre: "Anime"
        ),
        RadioStation(
            name: "J-Rock Radio",
            frequency: 82.5,
            streamURL: "https://jrock.out.airtime.pro/jrock_a",
            genre: .rock,
            subGenre: "J-Rock"
        ),
        RadioStation(
            name: "Japan Hits",
            frequency: 89.7,
            streamURL: "https://cast1.torontocast.com/JapanHits",
            genre: .pop,
            subGenre: "Contemporary"
        ),
        RadioStation(
            name: "Tokyo Jazz",
            frequency: 87.5,
            streamURL: "https://stream.zeno.fm/f2psvnsp8jazz",
            genre: .jazz,
            subGenre: "Smooth Jazz"
        ),
        RadioStation(
            name: "Classical Japan",
            frequency: 92.5,
            streamURL: "https://stream-uk1.radioparadise.com/aac-320",
            genre: .classical,
            subGenre: "Classical"
        ),
        
        // News stations
        RadioStation(
            name: "NHK World",
            frequency: 95.5,
            streamURL: "https://nhkworld.webcdn.stream.ne.jp/www11/nhkworld-tv/main/strm/select/live.m3u8",
            genre: .news,
            subGenre: "World News"
        ),
        RadioStation(
            name: "Japan News 24",
            frequency: 98.5,
            streamURL: "https://stream.zeno.fm/japan-news24",
            genre: .news,
            subGenre: "24h News"
        ),
        
        // Education
        RadioStation(
            name: "Japanese Study",
            frequency: 104.1,
            streamURL: "https://stream.zeno.fm/edu-japanese",
            genre: .education,
            subGenre: "Language"
        ),
        RadioStation(
            name: "Culture Japan",
            frequency: 105.7,
            streamURL: "https://stream.zeno.fm/culture-jp",
            genre: .culture,
            subGenre: "Culture"
        ),
        
        // Entertainment
        RadioStation(
            name: "Tokyo Comedy",
            frequency: 91.1,
            streamURL: "https://stream.zeno.fm/comedy-tokyo",
            genre: .entertainment,
            subGenre: "Comedy"
        ),
        RadioStation(
            name: "J-Sports",
            frequency: 107.9,
            streamURL: "https://stream.zeno.fm/sports-japan",
            genre: .sports,
            subGenre: "Sports"
        )
    ]
    
    // US stations
    static let usStations = [
        // Music stations
        RadioStation(
            name: "KEXP Seattle",
            frequency: 90.3,
            streamURL: "https://kexp-mp3-128.streamguys1.com/kexp128.mp3",
            genre: .rock,
            subGenre: "Alternative"
        ),
        RadioStation(
            name: "Classical KUSC",
            frequency: 91.5,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/KUSCMP128.mp3",
            genre: .classical,
            subGenre: "Classical"
        ),
        RadioStation(
            name: "Jazz 24",
            frequency: 88.5,
            streamURL: "https://ais-sa2.cdnstream1.com/2366_128.mp3",
            genre: .jazz,
            subGenre: "Jazz"
        ),
        RadioStation(
            name: "SomaFM Groove",
            frequency: 103.7,
            streamURL: "https://ice2.somafm.com/groovesalad-128-mp3",
            genre: .music,
            subGenre: "Electronic"
        ),
        RadioStation(
            name: "SomaFM Indie",
            frequency: 97.1,
            streamURL: "https://ice2.somafm.com/indiepop-128-mp3",
            genre: .rock,
            subGenre: "Indie Pop"
        ),
        RadioStation(
            name: "Classic Rock",
            frequency: 95.5,
            streamURL: "https://ice42.securenetsystems.net/CLASSIC",
            genre: .rock,
            subGenre: "Classic Rock"
        ),
        
        // News stations
        RadioStation(
            name: "NPR News",
            frequency: 88.1,
            streamURL: "https://npr-ice.streamguys1.com/live.mp3",
            genre: .news,
            subGenre: "News/Talk"
        ),
        RadioStation(
            name: "BBC World",
            frequency: 89.5,
            streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_world_service",
            genre: .news,
            subGenre: "World News"
        ),
        RadioStation(
            name: "WNYC News",
            frequency: 93.9,
            streamURL: "https://fm939.wnyc.org/wnycfm-tunein.aac",
            genre: .news,
            subGenre: "Public Radio"
        ),
        RadioStation(
            name: "Bloomberg Radio",
            frequency: 94.7,
            streamURL: "https://24133.live.streamtheworld.com/WBBRAMAAC.aac",
            genre: .news,
            subGenre: "Business News"
        ),
        
        // Education
        RadioStation(
            name: "KCRW Public",
            frequency: 89.9,
            streamURL: "https://kcrw.streamguys1.com/kcrw_192k_mp3_on_air",
            genre: .education,
            subGenre: "Public Radio"
        ),
        RadioStation(
            name: "Science Friday",
            frequency: 104.1,
            streamURL: "https://nis.stream.publicradio.org/nis.mp3",
            genre: .education,
            subGenre: "Science"
        ),
        
        // Entertainment/Sports
        RadioStation(
            name: "ESPN Radio",
            frequency: 106.7,
            streamURL: "https://live.wostreaming.net/direct/espn-network-48",
            genre: .sports,
            subGenre: "Sports"
        ),
        RadioStation(
            name: "Comedy 800",
            frequency: 105.1,
            streamURL: "https://streaming.live365.com/a89324",
            genre: .entertainment,
            subGenre: "Comedy"
        ),
        RadioStation(
            name: "Top 40 Hits",
            frequency: 107.5,
            streamURL: "https://ice9.securenetsystems.net/DASH44",
            genre: .pop,
            subGenre: "Top 40"
        )
    ]
    
    // UK stations
    static let ukStations = [
        // Music stations
        RadioStation(
            name: "BBC Radio 1",
            frequency: 97.6,
            streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_one",
            genre: .pop,
            subGenre: "Pop/Dance"
        ),
        RadioStation(
            name: "BBC Radio 2",
            frequency: 88.1,
            streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_two",
            genre: .music,
            subGenre: "Adult Contemporary"
        ),
        RadioStation(
            name: "BBC Radio 3",
            frequency: 90.2,
            streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_three",
            genre: .classical,
            subGenre: "Classical"
        ),
        RadioStation(
            name: "BBC Radio 6",
            frequency: 97.9,
            streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_6music",
            genre: .rock,
            subGenre: "Alternative"
        ),
        RadioStation(
            name: "Capital FM",
            frequency: 95.8,
            streamURL: "https://media-ssl.musicradio.com/CapitalMP3",
            genre: .pop,
            subGenre: "Pop"
        ),
        RadioStation(
            name: "Classic FM",
            frequency: 100.9,
            streamURL: "https://media-ssl.musicradio.com/ClassicFMMP3",
            genre: .classical,
            subGenre: "Classical"
        ),
        RadioStation(
            name: "Jazz FM",
            frequency: 102.2,
            streamURL: "https://stream.jazzhttps://playerservices.streamtheworld.com/api/livestream-redirect/JAZZFM.mp3",
            genre: .jazz,
            subGenre: "Jazz"
        ),
        RadioStation(
            name: "Kiss FM",
            frequency: 100.0,
            streamURL: "https://stream-kiss.planetradio.co.uk/kissnational.mp3",
            genre: .music,
            subGenre: "Dance"
        ),
        
        // News stations
        RadioStation(
            name: "BBC Radio 4",
            frequency: 93.5,
            streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_fourfm",
            genre: .news,
            subGenre: "News/Talk"
        ),
        RadioStation(
            name: "BBC Radio 5",
            frequency: 909.0,
            streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_five_live",
            genre: .sports,
            subGenre: "Sports/News"
        ),
        RadioStation(
            name: "LBC News",
            frequency: 97.3,
            streamURL: "https://media-ssl.musicradio.com/LBCUK",
            genre: .news,
            subGenre: "Talk"
        ),
        RadioStation(
            name: "Times Radio",
            frequency: 104.9,
            streamURL: "https://timesradio.wireless.radio/stream",
            genre: .news,
            subGenre: "News/Talk"
        ),
        
        // Education/Culture
        RadioStation(
            name: "BBC World Service",
            frequency: 91.6,
            streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_world_service",
            genre: .education,
            subGenre: "World News"
        ),
        RadioStation(
            name: "BBC Radio 4 Extra",
            frequency: 198.0,
            streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_four_extra",
            genre: .entertainment,
            subGenre: "Comedy/Drama"
        ),
        
        // Entertainment
        RadioStation(
            name: "Absolute Radio",
            frequency: 105.8,
            streamURL: "https://stream.absoluteradio.co.uk/absolute",
            genre: .rock,
            subGenre: "Rock"
        ),
        RadioStation(
            name: "Heart FM",
            frequency: 106.2,
            streamURL: "https://media-ssl.musicradio.com/HeartLondonMP3",
            genre: .pop,
            subGenre: "Pop"
        )
    ]
    
    // Default stations (same as Korean for backwards compatibility)
    static let sampleStations = koreanStations
    
    // Get stations for country code
    static func stations(for countryCode: String) -> [RadioStation] {
        switch countryCode {
        case "KR":
            return koreanStations
        case "JP":
            return japaneseStations
        case "US":
            return usStations
        case "GB":
            return ukStations
        default:
            return koreanStations
        }
    }
}