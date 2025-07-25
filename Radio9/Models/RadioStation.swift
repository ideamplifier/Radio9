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
            name: "올드팝카페",
            frequency: 92.4,
            streamURL: "http://cast.oldpopcafe.net:7080/",
            genre: .pop,
            subGenre: "Oldies",
            countryCode: "KR"
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
            name: "Smooth Jazz",
            frequency: 88.5,
            streamURL: "https://smoothjazz.cdnstream1.com/2585_320.mp3",
            genre: .jazz,
            subGenre: "Smooth Jazz"
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
            streamURL: "https://media.kcrw.com/live/kcrwlive.m3u8",
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
        // Tokyo Comedy와 J-Sports는 URL이 작동하지 않아 제거됨
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
            name: "Smooth Jazz",
            frequency: 88.5,
            streamURL: "https://smoothjazz.cdnstream1.com/2585_320.mp3",
            genre: .jazz,
            subGenre: "Smooth Jazz"
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
            streamURL: "https://edge-bauerall-01-gos2.sharp-stream.com/jazzfm.mp3",
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
    
    // Brazil stations
    static let brazilStations = [
        RadioStation(
            name: "Radio Globo",
            frequency: 89.1,
            streamURL: "https://medias.sgr.globo.com/hls/aRGloboRJ/aRGloboRJ.m3u8",
            genre: .pop,
            subGenre: "Brazilian Pop",
            countryCode: "BR"
        ),
        RadioStation(
            name: "Mix FM",
            frequency: 106.3,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/MIXFM_SAOPAULO.mp3",
            genre: .pop,
            subGenre: "Pop Mix"
        ),
        RadioStation(
            name: "Radio Bandeirantes",
            frequency: 90.9,
            streamURL: "https://evp.mm.uol.com.br/band_rodeio/band.m3u8",
            genre: .news,
            subGenre: "News/Talk"
        ),
        RadioStation(
            name: "Antena 1",
            frequency: 94.7,
            streamURL: "https://antenaone.crossradio.com.br/stream/1",
            genre: .rock,
            subGenre: "Classic Rock"
        ),
        RadioStation(
            name: "Alpha FM",
            frequency: 101.7,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/ALPHAFM_ADP.mp3",
            genre: .rock,
            subGenre: "Rock"
        )
    ]
    
    // Spain stations
    static let spainStations = [
        RadioStation(
            name: "Cadena 100",
            frequency: 100.0,
            streamURL: "https://server8.emitironline.com:2020/stream",
            genre: .pop,
            subGenre: "Spanish Pop"
        ),
        RadioStation(
            name: "Los 40",
            frequency: 104.3,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/LOS40.mp3",
            genre: .pop,
            subGenre: "Top 40"
        ),
        RadioStation(
            name: "Europa FM",
            frequency: 91.0,
            streamURL: "https://livefastly-webs.europafm.com/europafm/audio/master.m3u8",
            genre: .pop,
            subGenre: "Dance"
        ),
        RadioStation(
            name: "RNE Radio Nacional",
            frequency: 88.2,
            streamURL: "https://dispatcher.rndfnk.com/rne/rne1/main/mp3/high",
            genre: .news,
            subGenre: "Public Radio"
        ),
        RadioStation(
            name: "Kiss FM",
            frequency: 102.7,
            streamURL: "https://kissfm.kissfmradio.cires21.com/kissfm.mp3",
            genre: .music,
            subGenre: "Dance"
        )
    ]
    
    // France stations
    static let franceStations = [
        RadioStation(
            name: "NRJ",
            frequency: 100.3,
            streamURL: "https://scdn.nrjaudio.fm/adwz2/fr/30001/mp3_128.mp3",
            genre: .pop,
            subGenre: "Hit Music"
        ),
        RadioStation(
            name: "RTL",
            frequency: 104.3,
            streamURL: "https://streaming.radio.rtl.fr/rtl-1-44-128",
            genre: .news,
            subGenre: "News/Talk"
        ),
        RadioStation(
            name: "Europe 1",
            frequency: 104.7,
            streamURL: "https://europe1.lmn.fm/europe1.mp3",
            genre: .news,
            subGenre: "News"
        ),
        RadioStation(
            name: "Nostalgie",
            frequency: 105.1,
            streamURL: "https://scdn.nrjaudio.fm/adwz2/fr/30601/mp3_128.mp3",
            genre: .pop,
            subGenre: "Oldies"
        ),
        RadioStation(
            name: "FIP",
            frequency: 105.1,
            streamURL: "https://icecast.radiofrance.fr/fip-hifi.aac",
            genre: .music,
            subGenre: "Eclectic"
        )
    ]
    
    // Germany stations
    static let germanyStations = [
        RadioStation(
            name: "Antenne Bayern",
            frequency: 103.7,
            streamURL: "https://s1-webradio.webradio.de/antenne",
            genre: .pop,
            subGenre: "Pop/Rock"
        ),
        RadioStation(
            name: "Bayern 3",
            frequency: 97.3,
            streamURL: "https://dispatcher.rndfnk.com/br/br3/live/mp3/mid",
            genre: .pop,
            subGenre: "Pop"
        ),
        RadioStation(
            name: "WDR 2",
            frequency: 99.2,
            streamURL: "https://wdr-wdr2-ruhrgebiet.icecastssl.wdr.de/wdr/wdr2/ruhrgebiet/mp3/128/stream.mp3",
            genre: .pop,
            subGenre: "Adult Contemporary"
        ),
        RadioStation(
            name: "Deutschlandfunk",
            frequency: 97.7,
            streamURL: "https://st01.sslstream.dlf.de/dlf/01/high/aac/stream.aac",
            genre: .news,
            subGenre: "Public Radio"
        ),
        RadioStation(
            name: "SWR3",
            frequency: 96.4,
            streamURL: "https://liveradio.swr.de/sw282p3/swr3/play.mp3",
            genre: .pop,
            subGenre: "Pop/Rock"
        )
    ]
    
    // Italy stations
    static let italyStations = [
        RadioStation(
            name: "Radio Italia",
            frequency: 105.0,
            streamURL: "https://radioitaliasmi.akamaized.net/hls/live/2093120/RISMI/master.m3u8",
            genre: .pop,
            subGenre: "Italian Pop"
        ),
        RadioStation(
            name: "RTL 102.5",
            frequency: 102.5,
            streamURL: "https://streamingv2.shoutcast.com/rtl-1025",
            genre: .pop,
            subGenre: "Hit Radio"
        ),
        RadioStation(
            name: "Radio Deejay",
            frequency: 106.0,
            streamURL: "https://radiodeejay-lh.akamaihd.net/i/RadioDeejay_Live_1@189857/master.m3u8",
            genre: .pop,
            subGenre: "Dance"
        ),
        RadioStation(
            name: "Virgin Radio",
            frequency: 104.5,
            streamURL: "https://icecast.unitedradio.it/Virgin.mp3",
            genre: .rock,
            subGenre: "Rock"
        ),
        RadioStation(
            name: "RDS",
            frequency: 103.3,
            streamURL: "https://icstream.rds.radio/rds",
            genre: .pop,
            subGenre: "Pop"
        )
    ]
    
    // Australia stations
    static let australiaStations = [
        RadioStation(
            name: "Triple J",
            frequency: 104.1,
            streamURL: "https://live-radio02.mediahubaustralia.com/2TJW/mp3/",
            genre: .rock,
            subGenre: "Alternative"
        ),
        RadioStation(
            name: "Nova 96.9",
            frequency: 96.9,
            streamURL: "https://streaming.novaentertainment.com.au/nova969",
            genre: .pop,
            subGenre: "Hit Music"
        ),
        RadioStation(
            name: "2GB Sydney",
            frequency: 873.0,
            streamURL: "https://21363.live.streamtheworld.com/2GB.mp3",
            genre: .news,
            subGenre: "Talk"
        ),
        RadioStation(
            name: "KIIS 106.5",
            frequency: 106.5,
            streamURL: "https://kiis1065.akamaized.net/hls/live/2111556/KIIS1065/master.m3u8",
            genre: .pop,
            subGenre: "Top 40"
        ),
        RadioStation(
            name: "ABC Classic",
            frequency: 92.9,
            streamURL: "https://live-radio01.mediahubaustralia.com/2FMW/mp3/",
            genre: .classical,
            subGenre: "Classical"
        )
    ]
    
    // Canada stations
    static let canadaStations = [
        RadioStation(
            name: "Virgin Radio",
            frequency: 99.9,
            streamURL: "https://rogers-hls.leanstream.co/rogers/tor999.stream/playlist.m3u8",
            genre: .pop,
            subGenre: "Hit Music"
        ),
        RadioStation(
            name: "CBC Radio One",
            frequency: 99.1,
            streamURL: "https://cbcliveradio-lh.akamaihd.net/i/CBCR1_TOR@118420/master.m3u8",
            genre: .news,
            subGenre: "Public Radio"
        ),
        RadioStation(
            name: "CHUM FM",
            frequency: 104.5,
            streamURL: "https://rogers-hls.leanstream.co/rogers/tor1045.stream/playlist.m3u8",
            genre: .pop,
            subGenre: "Adult Contemporary"
        ),
        RadioStation(
            name: "Q107",
            frequency: 107.0,
            streamURL: "https://corus.leanstream.co/CILQFM-MP3",
            genre: .rock,
            subGenre: "Classic Rock"
        ),
        RadioStation(
            name: "98.1 CHFI",
            frequency: 98.1,
            streamURL: "https://rogers-hls.leanstream.co/rogers/tor981.stream/playlist.m3u8",
            genre: .pop,
            subGenre: "Adult Contemporary"
        )
    ]
    
    // Mexico stations
    static let mexicoStations = [
        RadioStation(
            name: "Los 40 Mexico",
            frequency: 104.3,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/LOS40_MEXICO.mp3",
            genre: .pop,
            subGenre: "Top 40"
        ),
        RadioStation(
            name: "Exa FM",
            frequency: 104.9,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/XHEXA_FM.mp3",
            genre: .pop,
            subGenre: "Pop"
        ),
        RadioStation(
            name: "Radio Fórmula",
            frequency: 103.3,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/XERFR_AM.mp3",
            genre: .news,
            subGenre: "News/Talk"
        ),
        RadioStation(
            name: "Stereo Cien",
            frequency: 100.1,
            streamURL: "https://stream.zeno.fm/stereocien",
            genre: .music,
            subGenre: "Mexican Music"
        ),
        RadioStation(
            name: "La Z",
            frequency: 107.3,
            streamURL: "https://stream.zeno.fm/laz1073",
            genre: .music,
            subGenre: "Regional Mexican"
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
        case "BR":
            return brazilStations
        case "ES":
            return spainStations
        case "FR":
            return franceStations
        case "DE":
            return germanyStations
        case "IT":
            return italyStations
        case "AU":
            return australiaStations
        case "CA":
            return canadaStations
        case "MX":
            return mexicoStations
        default:
            // 그 외 국가들은 일단 미국 스테이션 사용
            return usStations
        }
    }
}