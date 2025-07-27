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
    // Korean stations - 검증된 실제 작동 방송국들만 포함
    static let koreanStations = [
        // 올드팝카페 - 가장 빠른 연결속도
        RadioStation(
            name: "올드팝카페",
            frequency: 92.4,
            streamURL: "http://cast.oldpopcafe.net:7080/",
            genre: .pop,
            subGenre: "Oldies",
            countryCode: "KR"
        ),
        // TBN 교통방송 (실제 작동)
        RadioStation(
            name: "TBN 부산교통방송",
            frequency: 94.9,
            streamURL: "http://radio2.tbn.or.kr:1935/busan/myStream/playlist.m3u8",
            genre: .news,
            subGenre: "Traffic/News",
            countryCode: "KR"
        ),
        RadioStation(
            name: "TBN 교통방송",
            frequency: 96.4,
            streamURL: "http://radio2.tbn.or.kr:1935/gyeongin/myStream/playlist.m3u8",
            genre: .news,
            subGenre: "Traffic/News",
            countryCode: "KR"
        ),
        RadioStation(
            name: "TBN 대구교통방송",
            frequency: 102.3,
            streamURL: "http://radio2.tbn.or.kr:1935/daegu/myStream/playlist.m3u8",
            genre: .news,
            subGenre: "Traffic/News",
            countryCode: "KR"
        ),
        RadioStation(
            name: "TBN 울산교통방송",
            frequency: 105.6,
            streamURL: "http://radio2.tbn.or.kr:1935/ulsan/myStream/playlist.m3u8",
            genre: .news,
            subGenre: "Traffic/News",
            countryCode: "KR"
        ),
        
        // 실제 작동하는 방송국들
        RadioStation(
            name: "SBS Love FM",
            frequency: 95.6,
            streamURL: "https://radiolive.sbs.co.kr/lovepc/lovefm.stream/playlist.m3u8",
            genre: .music,
            subGenre: "Music",
            countryCode: "KR"
        ),
        RadioStation(
            name: "Classic Odyssey",
            frequency: 96.8,
            streamURL: "http://live07.inlive.co.kr:21110/",
            genre: .classical,
            subGenre: "Classical",
            countryCode: "KR"
        ),
        RadioStation(
            name: "평양FM",
            frequency: 97.6,
            streamURL: "https://listen7.myradio24.com/69366",
            genre: .culture,
            subGenre: "North Korean Music",
            countryCode: "KR"
        ),
        RadioStation(
            name: "OBS 라디오",
            frequency: 98.0,
            streamURL: "https://vod3.obs.co.kr:444/live/obsstream1/radio.stream/playlist.m3u8",
            genre: .music,
            subGenre: "Regional",
            countryCode: "KR"
        ),
        RadioStation(
            name: "Arirang Radio",
            frequency: 88.1,
            streamURL: "http://amdlive-ch01.ctnd.com.edgesuite.net/arirang_1ch/smil:arirang_1ch.smil/playlist.m3u8",
            genre: .education,
            subGenre: "English/International",
            countryCode: "KR"
        ),
        RadioStation(
            name: "Arirang TV",
            frequency: 98.4,
            streamURL: "http://amdlive.ctnd.com.edgesuite.net/arirang_1ch/smil:arirang_1ch.smil/playlist.m3u8",
            genre: .education,
            subGenre: "Korean Culture",
            countryCode: "KR"
        ),
        RadioStation(
            name: "BBS 불교방송",
            frequency: 101.9,
            streamURL: "http://bbslive.clouducs.com:1935/bbsradio-live/livestream/playlist.m3u8",
            genre: .culture,
            subGenre: "Buddhist",
            countryCode: "KR"
        ),
        RadioStation(
            name: "EBS FM",
            frequency: 104.5,
            streamURL: "http://ebsonairiosaod.ebs.co.kr/fmradiofamilypc/familypc1m/playlist.m3u8",
            genre: .education,
            subGenre: "Education",
            countryCode: "KR"
        ),
        RadioStation(
            name: "EBS TV-Kids",
            frequency: 104.8,
            streamURL: "http://ebsonairios.ebs.co.kr/ebsufamilypc/familypc1m/playlist.m3u8",
            genre: .education,
            subGenre: "Kids Education",
            countryCode: "KR"
        ),
        RadioStation(
            name: "SoneFM (SuwonFM)",
            frequency: 106.4,
            streamURL: "http://115.85.182.39/sonefm",
            genre: .music,
            subGenre: "Local FM",
            countryCode: "KR"
        ),
        
        // 온라인 전용 K-Pop 방송국들
        RadioStation(
            name: "비전트로트",
            frequency: 95.2,
            streamURL: "http://pb1.inlive.co.kr:10070/",
            genre: .music,
            subGenre: "Trot",
            countryCode: "KR"
        ),
        RadioStation(
            name: "K-Pop 24/7",
            frequency: 88.7,
            streamURL: "https://streams.radio.co/s2c5c6a7a5/listen",
            genre: .pop,
            subGenre: "K-Pop",
            countryCode: "KR"
        ),
        RadioStation(
            name: "Korean Ballad Radio",
            frequency: 90.0,
            streamURL: "https://listen.openstream.co/6393/audio",
            genre: .pop,
            subGenre: "K-Ballad",
            countryCode: "KR"
        ),
        RadioStation(
            name: "Traditional Korean Music",
            frequency: 99.1,
            streamURL: "https://streamer.radio.co/s5aae3c2e8/listen",
            genre: .culture,
            subGenre: "Traditional",
            countryCode: "KR"
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
            subGenre: "J-Pop",
            countryCode: "JP"
        ),
        RadioStation(
            name: "BOX : Japan City Pop",
            frequency: 90.0,
            streamURL: "https://boxradio-edge-00.streamafrica.net/jpopchill",
            genre: .pop,
            subGenre: "City Pop",
            countryCode: "JP"
        ),
        RadioStation(
            name: "J-Rock Powerplay",
            frequency: 82.5,
            streamURL: "https://kathy.torontocast.com:3450/stream",
            genre: .rock,
            subGenre: "J-Rock",
            countryCode: "JP"
        ),
        RadioStation(
            name: "Japan Hits",
            frequency: 89.7,
            streamURL: "https://cast1.torontocast.com/JapanHits",
            genre: .pop,
            subGenre: "Contemporary",
            countryCode: "JP"
        ),
        RadioStation(
            name: "J1 HITS Radio",
            frequency: 87.5,
            streamURL: "https://jenny.torontocast.com:8062/stream",
            genre: .pop,
            subGenre: "J-Pop Hits",
            countryCode: "JP"
        ),
        RadioStation(
            name: "Classical Japan",
            frequency: 92.5,
            streamURL: "https://stream-uk1.radioparadise.com/aac-320",
            genre: .classical,
            subGenre: "Classical",
            countryCode: "JP"
        ),
        
        // Education
        RadioStation(
            name: "Shonan Beach FM",
            frequency: 105.7,
            streamURL: "http://shonanbeachfm.out.airtime.pro:8000/shonanbeachfm_a",
            genre: .music,
            subGenre: "Beach Music",
            countryCode: "JP"
        ),
        
        // Entertainment
        RadioStation(
            name: "J-Pop Powerplay",
            frequency: 92.1,
            streamURL: "https://kathy.torontocast.com:3560/",
            genre: .pop,
            subGenre: "Top J-Pop",
            countryCode: "JP"
        ),
        RadioStation(
            name: "Jazz Sakura",
            frequency: 88.8,
            streamURL: "http://kathy.torontocast.com:3330/stream/1/",
            genre: .jazz,
            subGenre: "Jazz",
            countryCode: "JP"
        ),
        RadioStation(
            name: "J-Pop Sakura 懐かしい",
            frequency: 92.8,
            streamURL: "https://cast1.torontocast.com:2170/stream",
            genre: .pop,
            subGenre: "Nostalgic J-Pop",
            countryCode: "JP"
        ),
        RadioStation(
            name: "Gensokyo Radio",
            frequency: 89.2,
            streamURL: "https://stream.gensokyoradio.net/3/",
            genre: .entertainment,
            subGenre: "Game Music",
            countryCode: "JP"
        ),
        RadioStation(
            name: "R/a/dio",
            frequency: 91.2,
            streamURL: "https://relay0.r-a-d.io/main.mp3",
            genre: .entertainment,
            subGenre: "Anime/Game",
            countryCode: "JP"
        ),
        RadioStation(
            name: "Retro PC GAME MUSIC",
            frequency: 96.0,
            streamURL: "http://gyusyabu.ddo.jp:8000/;",
            genre: .entertainment,
            subGenre: "Retro Game",
            countryCode: "JP"
        ),
        RadioStation(
            name: "J-Club Club Bandstand",
            frequency: 105.2,
            streamURL: "https://kathy.torontocast.com:3250/stream",
            genre: .music,
            subGenre: "J-Club",
            countryCode: "JP"
        ),
        RadioStation(
            name: "CGNTV日本台",
            frequency: 107.6,
            streamURL: "https://cgntvlive-944.acs.wecandeo.com/ms/2850/944/index_1.m3u8",
            genre: .culture,
            subGenre: "Christian",
            countryCode: "JP"
        ),
        RadioStation(
            name: "BAN-BANラジオ",
            frequency: 90.4,
            streamURL: "https://mtist.as.smartstream.ne.jp/30078/livestream/playlist.m3u8",
            genre: .music,
            subGenre: "Local",
            countryCode: "JP"
        ),
        RadioStation(
            name: "かわさきＦＭ",
            frequency: 103.2,
            streamURL: "https://mtist.as.smartstream.ne.jp/30053/livestream/playlist.m3u8",
            genre: .music,
            subGenre: "Kawasaki Local",
            countryCode: "JP"
        ),
        RadioStation(
            name: "FM那覇",
            frequency: 103.6,
            streamURL: "https://mtist.as.smartstream.ne.jp/30047/livestream/playlist.m3u8",
            genre: .music,
            subGenre: "Okinawa Local",
            countryCode: "JP"
        ),
        RadioStation(
            name: "FMおたる",
            frequency: 98.8,
            streamURL: "https://mtist.as.smartstream.ne.jp/30026/livestream/playlist.m3u8",
            genre: .music,
            subGenre: "Otaru Local",
            countryCode: "JP"
        ),
        RadioStation(
            name: "エフエム椿台",
            frequency: 100.4,
            streamURL: "https://mtist.as.smartstream.ne.jp/30025/livestream/playlist.m3u8",
            genre: .music,
            subGenre: "Local FM",
            countryCode: "JP"
        ),
        RadioStation(
            name: "775ライブリーFM",
            frequency: 99.2,
            streamURL: "https://mtist.as.smartstream.ne.jp/30023/livestream/playlist.m3u8",
            genre: .music,
            subGenre: "Community Radio",
            countryCode: "JP"
        ),
        RadioStation(
            name: "Kamakura FM",
            frequency: 97.2,
            streamURL: "https://mtist.as.smartstream.ne.jp/30030/livestream/playlist.m3u8",
            genre: .music,
            subGenre: "Kamakura Local",
            countryCode: "JP"
        ),
        RadioStation(
            name: "99.1 HD3 - J1 HD",
            frequency: 98.0,
            streamURL: "https://jenny.torontocast.com:8062/stream",
            genre: .pop,
            subGenre: "J-Pop HD",
            countryCode: "JP"
        ),
        RadioStation(
            name: "J1 Radio Japan",
            frequency: 101.0,
            streamURL: "https://listen.j1fm.com/j1japan",
            genre: .pop,
            subGenre: "J-Pop",
            countryCode: "JP"
        ),
        RadioStation(
            name: "J-Pop Project Radio",
            frequency: 103.5,
            streamURL: "https://kathy.torontocast.com:3000/stream",
            genre: .pop,
            subGenre: "J-Pop",
            countryCode: "JP"
        ),
        RadioStation(
            name: "J-Club Powerplay HipHop",
            frequency: 104.7,
            streamURL: "https://kathy.torontocast.com:3210/stream",
            genre: .music,
            subGenre: "J-HipHop",
            countryCode: "JP"
        ),
        RadioStation(
            name: "KPOP Way Radio",
            frequency: 106.3,
            streamURL: "https://listen.radioking.com/radio/314534/stream/365614",
            genre: .pop,
            subGenre: "K-Pop/J-Pop",
            countryCode: "JP"
        )
    ]
    
    // US stations
    static let usStations = [
        // Soft Classic Rock Radio - Fast connection
        RadioStation(
            name: "Soft Classic Rock Radio",
            frequency: 106.4,
            streamURL: "http://cast.oldpopcafe.net:7080/",  // Same reliable server as 올드팝카페
            genre: .rock,
            subGenre: "Classic Rock",
            countryCode: "US"
        ),
        // Music stations
        RadioStation(
            name: "Classical KUSC",
            frequency: 91.5,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/KUSCMP128.mp3",
            genre: .classical,
            subGenre: "Classical",
            countryCode: "US"
        ),
        RadioStation(
            name: "Smooth Jazz",
            frequency: 88.5,
            streamURL: "https://smoothjazz.cdnstream1.com/2585_320.mp3",
            genre: .jazz,
            subGenre: "Smooth Jazz",
            countryCode: "US"
        ),
        RadioStation(
            name: "SomaFM Groove",
            frequency: 103.7,
            streamURL: "https://ice2.somafm.com/groovesalad-128-mp3",
            genre: .music,
            subGenre: "Electronic",
            countryCode: "US"
        ),
        RadioStation(
            name: "SomaFM DEF CON",
            frequency: 89.3,
            streamURL: "https://ice2.somafm.com/defcon-128-mp3",
            genre: .music,
            subGenre: "Hacker/Electronic",
            countryCode: "US"
        ),
        RadioStation(
            name: "SomaFM Indie",
            frequency: 97.1,
            streamURL: "https://ice2.somafm.com/indiepop-128-mp3",
            genre: .rock,
            subGenre: "Indie Pop",
            countryCode: "US"
        ),
        
        // News stations
        RadioStation(
            name: "WNYC News",
            frequency: 93.9,
            streamURL: "https://fm939.wnyc.org/wnycfm-tunein.aac",
            genre: .news,
            subGenre: "Public Radio",
            countryCode: "US"
        ),
        
        // Education
        RadioStation(
            name: "Science Friday",
            frequency: 104.1,
            streamURL: "https://nis.stream.publicradio.org/nis.mp3",
            genre: .education,
            subGenre: "Science",
            countryCode: "US"
        ),
        
        // Entertainment/Sports
        RadioStation(
            name: "KQED San Francisco",
            frequency: 88.5,
            streamURL: "https://streams.kqed.org/kqedradio",
            genre: .education,
            subGenre: "Public Radio",
            countryCode: "US"
        ),
        RadioStation(
            name: "WBEZ Chicago",
            frequency: 91.5,
            streamURL: "https://stream.wbez.org/wbez128.mp3",
            genre: .education,
            subGenre: "Public Radio",
            countryCode: "US"
        ),
        RadioStation(
            name: "The Current Minnesota",
            frequency: 89.3,
            streamURL: "https://current.stream.publicradio.org/current.mp3",
            genre: .rock,
            subGenre: "Alternative/Indie",
            countryCode: "US"
        ),
        RadioStation(
            name: "WWOZ New Orleans",
            frequency: 90.7,
            streamURL: "https://wwoz-sc.streamguys1.com/wwoz-hi.mp3",
            genre: .jazz,
            subGenre: "Jazz/Blues",
            countryCode: "US"
        ),
        RadioStation(
            name: "KUTX Austin",
            frequency: 98.9,
            streamURL: "https://kut.streamguys1.com/kutx-web",
            genre: .rock,
            subGenre: "Alternative/Indie",
            countryCode: "US"
        ),
        
        // Additional genre-specific US stations
        RadioStation(
            name: "SomaFM Underground 80s",
            frequency: 104.9,
            streamURL: "https://ice2.somafm.com/u80s-128-mp3",
            genre: .rock,
            subGenre: "80s Underground",
            countryCode: "US"
        ),
        RadioStation(
            name: "KCRW Eclectic24",
            frequency: 89.9,
            streamURL: "https://kcrw.streamguys1.com/kcrw_192k_mp3_e24",
            genre: .music,
            subGenre: "Eclectic/Indie",
            countryCode: "US"
        ),
        RadioStation(
            name: "Radio Paradise Main",
            frequency: 96.7,
            streamURL: "https://stream.radioparadise.com/aac-320",
            genre: .rock,
            subGenre: "Eclectic Rock",
            countryCode: "US"
        ),
        RadioStation(
            name: "Radio Paradise Mellow",
            frequency: 88.6,
            streamURL: "https://stream.radioparadise.com/mellow-320",
            genre: .music,
            subGenre: "Mellow Mix",
            countryCode: "US"
        ),
        RadioStation(
            name: "Radio Paradise Rock",
            frequency: 98.2,
            streamURL: "https://stream.radioparadise.com/rock-320",
            genre: .rock,
            subGenre: "Rock Mix",
            countryCode: "US"
        ),
        RadioStation(
            name: "K-LOVE",
            frequency: 107.5,
            streamURL: "https://emf.streamguys1.com/sk024_mp3_high_web",
            genre: .music,
            subGenre: "Contemporary Christian",
            countryCode: "US"
        ),
        RadioStation(
            name: "KCRW Los Angeles",
            frequency: 89.9,
            streamURL: "https://kcrw.streamguys1.com/kcrw_192k_mp3_on_air",
            genre: .music,
            subGenre: "Eclectic",
            countryCode: "US"
        ),
        RadioStation(
            name: "WFMU New Jersey",
            frequency: 91.1,
            streamURL: "https://stream0.wfmu.org/freeform-128k",
            genre: .rock,
            subGenre: "Freeform",
            countryCode: "US"
        ),
        RadioStation(
            name: "KEXP Seattle",
            frequency: 90.3,
            streamURL: "https://kexp-mp3-128.streamguys1.com/kexp128.mp3",
            genre: .rock,
            subGenre: "Alternative/Indie",
            countryCode: "US"
        ),
        RadioStation(
            name: "WBGO Newark Jazz",
            frequency: 88.3,
            streamURL: "https://wbgo.streamguys1.com/wbgo128",
            genre: .jazz,
            subGenre: "Jazz",
            countryCode: "US"
        ),
        RadioStation(
            name: "WXPN Philadelphia",
            frequency: 88.5,
            streamURL: "https://wxpnhi.xpn.org/xpnhi",
            genre: .rock,
            subGenre: "Adult Alternative",
            countryCode: "US"
        ),
        RadioStation(
            name: "KTRU Houston",
            frequency: 96.1,
            streamURL: "https://streaming.ktru.org/ktru",
            genre: .rock,
            subGenre: "College Radio",
            countryCode: "US"
        ),
        RadioStation(
            name: "WREK Atlanta",
            frequency: 91.1,
            streamURL: "https://streaming.wrek.org/wrek-hi",
            genre: .rock,
            subGenre: "College/Electronic",
            countryCode: "US"
        ),
        RadioStation(
            name: "KPFA Berkeley",
            frequency: 94.1,
            streamURL: "https://streams.kpfa.org/kpfa-stream",
            genre: .news,
            subGenre: "Community Radio",
            countryCode: "US"
        ),
        RadioStation(
            name: "WMSE Milwaukee",
            frequency: 91.7,
            streamURL: "https://wmse.streamguys1.com/wmse",
            genre: .rock,
            subGenre: "College Alternative",
            countryCode: "US"
        ),
        RadioStation(
            name: "WFUV New York",
            frequency: 90.7,
            streamURL: "https://wfuv.streamguys1.com/wfuv",
            genre: .rock,
            subGenre: "Adult Alternative",
            countryCode: "US"
        ),
        RadioStation(
            name: "KPSU Portland",
            frequency: 98.1,
            streamURL: "https://stream.kpsu.org/kpsu.mp3",
            genre: .rock,
            subGenre: "College Radio",
            countryCode: "US"
        ),
    ]
    
    // UK stations
    static let ukStations = [
        // Music stations
        RadioStation(
            name: "BBC Radio 1",
            frequency: 97.6,
            streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_one",
            genre: .pop,
            subGenre: "Pop/Dance",
            countryCode: "UK"
        ),
        RadioStation(
            name: "BBC Radio 2",
            frequency: 88.1,
            streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_two",
            genre: .music,
            subGenre: "Adult Contemporary",
            countryCode: "UK"
        ),
        RadioStation(
            name: "BBC Radio 3",
            frequency: 90.2,
            streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_three",
            genre: .classical,
            subGenre: "Classical",
            countryCode: "UK"
        ),
        RadioStation(
            name: "BBC Radio 6",
            frequency: 97.9,
            streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_6music",
            genre: .rock,
            subGenre: "Alternative",
            countryCode: "UK"
        ),
        RadioStation(
            name: "Capital FM",
            frequency: 95.8,
            streamURL: "https://media-ssl.musicradio.com/CapitalMP3",
            genre: .pop,
            subGenre: "Pop",
            countryCode: "UK"
        ),
        RadioStation(
            name: "Classic FM",
            frequency: 100.9,
            streamURL: "https://media-ssl.musicradio.com/ClassicFMMP3",
            genre: .classical,
            subGenre: "Classical",
            countryCode: "UK"
        ),
        RadioStation(
            name: "Jazz FM",
            frequency: 102.2,
            streamURL: "https://edge-bauerall-01-gos2.sharp-stream.com/jazzfm.mp3",
            genre: .jazz,
            subGenre: "Jazz",
            countryCode: "UK"
        ),
        RadioStation(
            name: "Kiss FM",
            frequency: 100.0,
            streamURL: "https://stream-kiss.planetradio.co.uk/kissnational.mp3",
            genre: .music,
            subGenre: "Dance",
            countryCode: "UK"
        ),
        
        // News stations
        RadioStation(
            name: "BBC Radio 4",
            frequency: 93.5,
            streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_fourfm",
            genre: .news,
            subGenre: "News/Talk",
            countryCode: "UK"
        ),
        RadioStation(
            name: "BBC Radio 5",
            frequency: 909.0,
            streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_five_live",
            genre: .sports,
            subGenre: "Sports/News",
            countryCode: "UK"
        ),
        RadioStation(
            name: "LBC News",
            frequency: 97.3,
            streamURL: "https://media-ssl.musicradio.com/LBCUK",
            genre: .news,
            subGenre: "Talk",
            countryCode: "UK"
        ),
        RadioStation(
            name: "Times Radio",
            frequency: 104.9,
            streamURL: "https://timesradio.wireless.radio/stream",
            genre: .news,
            subGenre: "News/Talk",
            countryCode: "UK"
        ),
        
        // Education/Culture
        RadioStation(
            name: "BBC World Service",
            frequency: 91.6,
            streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_world_service",
            genre: .education,
            subGenre: "World News",
            countryCode: "UK"
        ),
        RadioStation(
            name: "BBC Radio 4 Extra",
            frequency: 198.0,
            streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_four_extra",
            genre: .entertainment,
            subGenre: "Comedy/Drama",
            countryCode: "UK"
        ),
        
        // Entertainment
        RadioStation(
            name: "Absolute Radio",
            frequency: 105.8,
            streamURL: "https://stream.absoluteradio.co.uk/absolute",
            genre: .rock,
            subGenre: "Rock",
            countryCode: "UK"
        ),
        RadioStation(
            name: "Heart FM",
            frequency: 106.2,
            streamURL: "https://media-ssl.musicradio.com/HeartLondonMP3",
            genre: .pop,
            subGenre: "Pop",
            countryCode: "UK"
        ),
        RadioStation(
            name: "BBC Radio Scotland",
            frequency: 92.5,
            streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_scotland_fm",
            genre: .news,
            subGenre: "Regional",
            countryCode: "UK"
        ),
        RadioStation(
            name: "BBC Radio Wales",
            frequency: 95.2,
            streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_wales_fm",
            genre: .news,
            subGenre: "Regional",
            countryCode: "UK"
        ),
        RadioStation(
            name: "BBC Radio Ulster",
            frequency: 92.4,
            streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_ulster",
            genre: .news,
            subGenre: "Regional",
            countryCode: "UK"
        ),
        RadioStation(
            name: "Smooth Radio",
            frequency: 102.2,
            streamURL: "https://media-ice.musicradio.com/SmoothLondonMP3",
            genre: .music,
            subGenre: "Easy Listening",
            countryCode: "UK"
        ),
        RadioStation(
            name: "Magic Radio",
            frequency: 105.4,
            streamURL: "https://stream-mz.planetradio.co.uk/magicnational.mp3",
            genre: .music,
            subGenre: "Adult Contemporary",
            countryCode: "UK"
        ),
        RadioStation(
            name: "BBC Radio 1Xtra",
            frequency: 96.0,
            streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_1xtra",
            genre: .music,
            subGenre: "Hip Hop/R&B",
            countryCode: "UK"
        ),
        RadioStation(
            name: "Gold Radio",
            frequency: 104.9,
            streamURL: "https://media-ssl.musicradio.com/GoldLondonMP3",
            genre: .music,
            subGenre: "Oldies",
            countryCode: "UK"
        ),
        RadioStation(
            name: "LBC Radio",
            frequency: 97.3,
            streamURL: "https://media-ssl.musicradio.com/LBCUKMP3",
            genre: .talk,
            subGenre: "Talk Radio",
            countryCode: "UK"
        ),
        RadioStation(
            name: "Radio X",
            frequency: 104.9,
            streamURL: "https://stream-radiox.planetradio.co.uk/radiox.mp3",
            genre: .rock,
            subGenre: "Alternative Rock",
            countryCode: "UK"
        ),
        RadioStation(
            name: "Planet Rock",
            frequency: 105.6,
            streamURL: "https://stream-planetrock.planetradio.co.uk/planetrock.mp3",
            genre: .rock,
            subGenre: "Classic Rock",
            countryCode: "UK"
        ),
        RadioStation(
            name: "Kerrang! Radio",
            frequency: 105.2,
            streamURL: "https://stream-kerrang.planetradio.co.uk/kerrang.mp3",
            genre: .rock,
            subGenre: "Metal/Rock",
            countryCode: "UK"
        ),
        RadioStation(
            name: "BBC Asian Network",
            frequency: 94.6,
            streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_asian_network",
            genre: .music,
            subGenre: "Asian Music",
            countryCode: "UK"
        ),
        RadioStation(
            name: "Fun Kids",
            frequency: 106.7,
            streamURL: "https://stream.funkidslive.com/funkids.mp3",
            genre: .entertainment,
            subGenre: "Children's Radio",
            countryCode: "UK"
        ),
        RadioStation(
            name: "Rock FM",
            frequency: 97.4,
            streamURL: "https://stream.rockfm.co.uk/rockfm.mp3",
            genre: .rock,
            subGenre: "Rock Hits",
            countryCode: "UK"
        ),
        RadioStation(
            name: "BBC Radio Ulster",
            frequency: 94.5,
            streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_ulster",
            genre: .music,
            subGenre: "Northern Irish",
            countryCode: "UK"
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
            subGenre: "Pop Mix",
            countryCode: "BR"
        ),
        RadioStation(
            name: "Radio Bandeirantes",
            frequency: 90.9,
            streamURL: "https://evp.mm.uol.com.br/band_rodeio/band.m3u8",
            genre: .news,
            subGenre: "News/Talk",
            countryCode: "BR"
        ),
        RadioStation(
            name: "Antena 1",
            frequency: 94.7,
            streamURL: "https://antenaone.crossradio.com.br/stream/1",
            genre: .rock,
            subGenre: "Classic Rock",
            countryCode: "BR"
        ),
        RadioStation(
            name: "Alpha FM",
            frequency: 101.7,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/ALPHAFM_ADP.mp3",
            genre: .rock,
            subGenre: "Rock",
            countryCode: "BR"
        ),
        RadioStation(
            name: "Jovem Pan FM",
            frequency: 105.7,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/JP_SP.mp3",
            genre: .rock,
            subGenre: "Pop/Rock",
            countryCode: "BR"
        ),
        RadioStation(
            name: "Radio Transcontinental",
            frequency: 104.7,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/TRANSCONTINENTAL_FM.mp3",
            genre: .music,
            subGenre: "MPB",
            countryCode: "BR"
        ),
        RadioStation(
            name: "Nova Brasil FM",
            frequency: 89.7,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/NOVABRASILFMAAC.aac",
            genre: .music,
            subGenre: "Brazilian Music",
            countryCode: "BR"
        ),
        RadioStation(
            name: "Radio Nativa",
            frequency: 95.3,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/NATIVA_SP.mp3",
            genre: .music,
            subGenre: "Sertanejo",
            countryCode: "BR"
        ),
        RadioStation(
            name: "89 FM",
            frequency: 89.1,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/RADIO_89FM.mp3",
            genre: .rock,
            subGenre: "Rock",
            countryCode: "BR"
        )
    ]
    
    // Spain stations
    static let spainStations = [
        RadioStation(
            name: "Los 40",
            frequency: 104.3,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/LOS40.mp3",
            genre: .pop,
            subGenre: "Top 40",
            countryCode: "ES"
        ),
        RadioStation(
            name: "Kiss FM",
            frequency: 102.7,
            streamURL: "https://kissfm.kissfmradio.cires21.com/kissfm.mp3",
            genre: .music,
            subGenre: "Dance",
            countryCode: "ES"
        ),
        RadioStation(
            name: "Cadena SER",
            frequency: 105.4,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/CADENASER.mp3",
            genre: .news,
            subGenre: "News/Talk",
            countryCode: "ES"
        ),
        RadioStation(
            name: "COPE",
            frequency: 106.3,
            streamURL: "https://net1-cope-rrcast.flumotion.com/cope/net1.mp3",
            genre: .news,
            subGenre: "News/Talk",
            countryCode: "ES"
        ),
        RadioStation(
            name: "Rock FM",
            frequency: 101.7,
            streamURL: "https://rockfm-cope.flumotion.com/playlist.m3u8",
            genre: .rock,
            subGenre: "Rock",
            countryCode: "ES"
        ),
        RadioStation(
            name: "Radio Marca",
            frequency: 103.5,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/RADIOMARCA_NACIONAL.mp3",
            genre: .sports,
            subGenre: "Sports",
            countryCode: "ES"
        ),
        RadioStation(
            name: "Catalunya Radio",
            frequency: 102.8,
            streamURL: "https://shoutcast.ccma.cat/ccma/catalunyaradioHD.mp3",
            genre: .news,
            subGenre: "Public Radio",
            countryCode: "ES"
        ),
        RadioStation(
            name: "Melodia FM",
            frequency: 98.4,
            streamURL: "https://icecast-streaming.nice264.com/melodiafm",
            genre: .music,
            subGenre: "Adult Contemporary",
            countryCode: "ES"
        ),
        RadioStation(
            name: "Los 40 Principales",
            frequency: 93.9,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/LOS40_SC",
            genre: .pop,
            subGenre: "Top 40",
            countryCode: "ES"
        ),
        RadioStation(
            name: "Cadena Dial",
            frequency: 91.7,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/CADENADIAL_SC",
            genre: .pop,
            subGenre: "Spanish Pop",
            countryCode: "ES"
        ),
        RadioStation(
            name: "Europa FM",
            frequency: 91.3,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/EUROPAFM_SC",
            genre: .pop,
            subGenre: "Contemporary",
            countryCode: "ES"
        ),
        RadioStation(
            name: "Kiss FM España",
            frequency: 102.7,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/KISSFM_SC",
            genre: .music,
            subGenre: "Dance/Electronic",
            countryCode: "ES"
        ),
        RadioStation(
            name: "Rock FM España",
            frequency: 96.3,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/ROCKFM_SC",
            genre: .rock,
            subGenre: "Rock",
            countryCode: "ES"
        ),
        RadioStation(
            name: "Radio Nacional",
            frequency: 88.2,
            streamURL: "https://rtvehlsvodlive.secure2.footprint.net/rtvehls/rne1_main.m3u8",
            genre: .news,
            subGenre: "Public Radio",
            countryCode: "ES"
        ),
        RadioStation(
            name: "COPE",
            frequency: 100.7,
            streamURL: "https://flucast-m04-06.flumotion.com/cope/net1.mp3",
            genre: .news,
            subGenre: "News/Talk",
            countryCode: "ES"
        ),
        RadioStation(
            name: "Onda Cero",
            frequency: 89.6,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/ONDACERO_SC",
            genre: .news,
            subGenre: "News/Talk",
            countryCode: "ES"
        ),
        RadioStation(
            name: "esRadio",
            frequency: 107.6,
            streamURL: "https://libertaddigital-radio-live1.flumotion.com/libertaddigital/radio.mp3",
            genre: .news,
            subGenre: "Talk Radio",
            countryCode: "ES"
        ),
        RadioStation(
            name: "Radio Clásica",
            frequency: 96.5,
            streamURL: "https://rtvehlsvodlive.secure2.footprint.net/rtvehls/radioclasica_main.m3u8",
            genre: .classical,
            subGenre: "Classical",
            countryCode: "ES"
        ),
        RadioStation(
            name: "Radio 3",
            frequency: 93.2,
            streamURL: "https://rtvehlsvodlive.secure2.footprint.net/rtvehls/radio3_main.m3u8",
            genre: .music,
            subGenre: "Alternative/Indie",
            countryCode: "ES"
        ),
        RadioStation(
            name: "M80 Radio",
            frequency: 89.0,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/M80_SC",
            genre: .rock,
            subGenre: "80s Rock",
            countryCode: "ES"
        ),
        RadioStation(
            name: "Máxima FM",
            frequency: 104.2,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/MAXIMAFM_SC",
            genre: .music,
            subGenre: "Electronic/Dance",
            countryCode: "ES"
        ),
        RadioStation(
            name: "Canal Fiesta Radio",
            frequency: 88.6,
            streamURL: "https://streaming.enacast.com/canalfiesta",
            genre: .music,
            subGenre: "Latin/Party",
            countryCode: "ES"
        ),
        RadioStation(
            name: "Loca FM",
            frequency: 90.2,
            streamURL: "https://streaming.locafm.com/stream",
            genre: .music,
            subGenre: "Dance/Electronic",
            countryCode: "ES"
        ),
        RadioStation(
            name: "Radio Marca",
            frequency: 103.2,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/RADIOMARCA_SC",
            genre: .sports,
            subGenre: "Sports",
            countryCode: "ES"
        ),
        RadioStation(
            name: "Hit FM",
            frequency: 103.9,
            streamURL: "https://streaming.hitfm.es/hitfm",
            genre: .pop,
            subGenre: "Top Hits",
            countryCode: "ES"
        ),
    ]
    
    // France stations
    static let franceStations = [
        RadioStation(
            name: "NRJ",
            frequency: 100.3,
            streamURL: "https://scdn.nrjaudio.fm/adwz2/fr/30001/mp3_128.mp3",
            genre: .pop,
            subGenre: "Hit Music",
            countryCode: "FR"
        ),
        RadioStation(
            name: "RTL",
            frequency: 104.3,
            streamURL: "https://streaming.radio.rtl.fr/rtl-1-44-128",
            genre: .news,
            subGenre: "News/Talk",
            countryCode: "FR"
        ),
        RadioStation(
            name: "Europe 1",
            frequency: 104.7,
            streamURL: "https://europe1.lmn.fm/europe1.mp3",
            genre: .news,
            subGenre: "News",
            countryCode: "FR"
        ),
        RadioStation(
            name: "Nostalgie",
            frequency: 105.1,
            streamURL: "https://scdn.nrjaudio.fm/adwz2/fr/30601/mp3_128.mp3",
            genre: .pop,
            subGenre: "Oldies",
            countryCode: "FR"
        ),
        RadioStation(
            name: "FIP",
            frequency: 105.1,
            streamURL: "https://icecast.radiofrance.fr/fip-hifi.aac",
            genre: .music,
            subGenre: "Eclectic",
            countryCode: "FR"
        ),
        RadioStation(
            name: "France Inter",
            frequency: 87.8,
            streamURL: "https://icecast.radiofrance.fr/franceinter-hifi.aac",
            genre: .news,
            subGenre: "News/Talk",
            countryCode: "FR"
        ),
        RadioStation(
            name: "RFM",
            frequency: 103.9,
            streamURL: "https://ais-live.cloud-services.paris/rfm.mp3",
            genre: .pop,
            subGenre: "Pop/Rock",
            countryCode: "FR"
        ),
        RadioStation(
            name: "Skyrock",
            frequency: 96.0,
            streamURL: "https://icecast.skyrock.net/s/natio_mp3_128k",
            genre: .music,
            subGenre: "Hip Hop/R&B",
            countryCode: "FR"
        ),
        RadioStation(
            name: "Virgin Radio France",
            frequency: 103.5,
            streamURL: "https://stream.virginradio.fr/virgin.mp3",
            genre: .rock,
            subGenre: "Rock/Pop",
            countryCode: "FR"
        ),
        RadioStation(
            name: "Chérie FM",
            frequency: 91.3,
            streamURL: "https://scdn.nrjaudio.fm/fr/30201/mp3_128.mp3",
            genre: .pop,
            subGenre: "Adult Contemporary",
            countryCode: "FR"
        ),
        RadioStation(
            name: "RMC",
            frequency: 103.1,
            streamURL: "https://chai5she.cdn.dvmr.fr/rmcinfo",
            genre: .news,
            subGenre: "News/Talk",
            countryCode: "FR"
        ),
        RadioStation(
            name: "France Culture",
            frequency: 91.7,
            streamURL: "https://icecast.radiofrance.fr/franceculture-hifi.aac",
            genre: .culture,
            subGenre: "Culture/Education",
            countryCode: "FR"
        ),
        RadioStation(
            name: "Mouv'",
            frequency: 92.1,
            streamURL: "https://icecast.radiofrance.fr/mouv-hifi.aac",
            genre: .music,
            subGenre: "Urban/Hip Hop",
            countryCode: "FR"
        ),
        RadioStation(
            name: "Fun Radio",
            frequency: 101.9,
            streamURL: "https://streaming.radio.funradio.fr/fun-1-44-128",
            genre: .music,
            subGenre: "Dance/Electronic",
            countryCode: "FR"
        ),
        RadioStation(
            name: "RTL 2",
            frequency: 105.9,
            streamURL: "https://streaming.radio.rtl2.fr/rtl2-1-44-128",
            genre: .pop,
            subGenre: "Pop Rock",
            countryCode: "FR"
        ),
        RadioStation(
            name: "France Musique",
            frequency: 91.7,
            streamURL: "https://icecast.radiofrance.fr/francemusique-hifi.aac",
            genre: .classical,
            subGenre: "Classical",
            countryCode: "FR"
        ),
        RadioStation(
            name: "France Info",
            frequency: 105.5,
            streamURL: "https://icecast.radiofrance.fr/franceinfo-hifi.aac",
            genre: .news,
            subGenre: "News",
            countryCode: "FR"
        ),
        RadioStation(
            name: "Rire & Chansons",
            frequency: 97.4,
            streamURL: "https://scdn.nrjaudio.fm/adwz2/fr/30401/mp3_128.mp3",
            genre: .entertainment,
            subGenre: "Comedy/Music",
            countryCode: "FR"
        ),
        RadioStation(
            name: "Radio Nova",
            frequency: 101.5,
            streamURL: "https://novazz.ice.infomaniak.ch/novazz-128.mp3",
            genre: .music,
            subGenre: "Alternative",
            countryCode: "FR"
        ),
        RadioStation(
            name: "TSF Jazz",
            frequency: 89.9,
            streamURL: "https://tsfjazz.ice.infomaniak.ch/tsfjazz-high.mp3",
            genre: .jazz,
            subGenre: "Jazz",
            countryCode: "FR"
        ),
        RadioStation(
            name: "M Radio",
            frequency: 88.6,
            streamURL: "https://mfm.ice.infomaniak.ch/mfm-128.mp3",
            genre: .pop,
            subGenre: "French Hits",
            countryCode: "FR"
        ),
        RadioStation(
            name: "Oui FM",
            frequency: 102.3,
            streamURL: "https://ouifm.ice.infomaniak.ch/ouifm-high.mp3",
            genre: .rock,
            subGenre: "Rock",
            countryCode: "FR"
        ),
        RadioStation(
            name: "Radio Classique",
            frequency: 101.1,
            streamURL: "https://radioclassique.ice.infomaniak.ch/radioclassique-high.mp3",
            genre: .classical,
            subGenre: "Classical",
            countryCode: "FR"
        ),
        RadioStation(
            name: "BFM Business",
            frequency: 96.4,
            streamURL: "https://bfmbusiness.scdn.arkena.com/bfmbusiness.mp3",
            genre: .news,
            subGenre: "Business News",
            countryCode: "FR"
        ),
        RadioStation(
            name: "Sud Radio",
            frequency: 99.4,
            streamURL: "https://start-sud.ice.infomaniak.ch/start-sud-high.mp3",
            genre: .news,
            subGenre: "Regional News",
            countryCode: "FR"
        ),
        RadioStation(
            name: "Radio FG",
            frequency: 98.2,
            streamURL: "https://radiofg.impek.com/fg",
            genre: .music,
            subGenre: "Electronic/Dance",
            countryCode: "FR"
        ),
        RadioStation(
            name: "Contact FM",
            frequency: 99.9,
            streamURL: "https://radio-contact.ice.infomaniak.ch/radio-contact-high.mp3",
            genre: .pop,
            subGenre: "French Pop",
            countryCode: "FR"
        ),
        RadioStation(
            name: "Voltage",
            frequency: 92.6,
            streamURL: "https://voltage.ice.infomaniak.ch/voltage-high.mp3",
            genre: .rock,
            subGenre: "Hard Rock/Metal",
            countryCode: "FR"
        )
    ]
    
    // Germany stations
    static let germanyStations = [
        RadioStation(
            name: "Antenne Bayern",
            frequency: 103.7,
            streamURL: "https://s1-webradio.webradio.de/antenne",
            genre: .pop,
            subGenre: "Pop/Rock",
            countryCode: "DE"
        ),
        RadioStation(
            name: "Bayern 3",
            frequency: 97.3,
            streamURL: "https://dispatcher.rndfnk.com/br/br3/live/mp3/mid",
            genre: .pop,
            subGenre: "Pop",
            countryCode: "DE"
        ),
        RadioStation(
            name: "WDR 2",
            frequency: 99.2,
            streamURL: "https://wdr-wdr2-ruhrgebiet.icecastssl.wdr.de/wdr/wdr2/ruhrgebiet/mp3/128/stream.mp3",
            genre: .pop,
            subGenre: "Adult Contemporary",
            countryCode: "DE"
        ),
        RadioStation(
            name: "Deutschlandfunk",
            frequency: 97.7,
            streamURL: "https://st01.sslstream.dlf.de/dlf/01/high/aac/stream.aac",
            genre: .news,
            subGenre: "Public Radio",
            countryCode: "DE"
        ),
        RadioStation(
            name: "SWR3",
            frequency: 96.4,
            streamURL: "https://liveradio.swr.de/sw282p3/swr3/play.mp3",
            genre: .pop,
            subGenre: "Pop/Rock",
            countryCode: "DE"
        ),
        RadioStation(
            name: "1LIVE",
            frequency: 106.7,
            streamURL: "https://wdr-1live-live.icecastssl.wdr.de/wdr/1live/live/mp3/128/stream.mp3",
            genre: .pop,
            subGenre: "Youth/Pop",
            countryCode: "DE"
        ),
        RadioStation(
            name: "NDR 2",
            frequency: 87.6,
            streamURL: "https://www.ndr.de/resources/metadaten/audio/m3u/ndr2.m3u",
            genre: .rock,
            subGenre: "Pop/Rock",
            countryCode: "DE"
        ),
        RadioStation(
            name: "Radio FFH",
            frequency: 105.9,
            streamURL: "https://mp3.ffh.de/radioffh/hqlivestream.mp3",
            genre: .pop,
            subGenre: "Hit Music",
            countryCode: "DE"
        ),
        RadioStation(
            name: "Radio Energy",
            frequency: 103.4,
            streamURL: "https://stream.104.6rtl.com/rtl-live/mp3-128",
            genre: .music,
            subGenre: "Dance/Electronic",
            countryCode: "DE"
        ),
        RadioStation(
            name: "Radio Eins",
            frequency: 95.8,
            streamURL: "https://radioeins.de/stream",
            genre: .rock,
            subGenre: "Alternative/Indie",
            countryCode: "DE"
        ),
        RadioStation(
            name: "bigFM",
            frequency: 89.0,
            streamURL: "https://streams.bigfm.de/bigfm-deutschland-128-mp3",
            genre: .pop,
            subGenre: "Hit Music",
            countryCode: "DE"
        ),
        RadioStation(
            name: "BR Klassik",
            frequency: 103.2,
            streamURL: "https://dispatcher.rndfnk.com/br/brklassik/live/mp3/128/stream.mp3",
            genre: .classical,
            subGenre: "Classical",
            countryCode: "DE"
        ),
        RadioStation(
            name: "HR3",
            frequency: 89.9,
            streamURL: "https://dispatcher.rndfnk.com/hr/hr3/live/mp3/128/stream.mp3",
            genre: .pop,
            subGenre: "Pop Hits",
            countryCode: "DE"
        ),
        RadioStation(
            name: "SWR1 Baden-Württemberg",
            frequency: 95.1,
            streamURL: "https://liveradio.swr.de/sw282p3/swr1bw/play.mp3",
            genre: .music,
            subGenre: "Adult Contemporary",
            countryCode: "DE"
        ),
        RadioStation(
            name: "RBB Fritz",
            frequency: 102.6,
            streamURL: "https://dispatcher.rndfnk.com/rbb/fritz/live/mp3/mid",
            genre: .rock,
            subGenre: "Alternative",
            countryCode: "DE"
        ),
        RadioStation(
            name: "Radio Regenbogen",
            frequency: 102.8,
            streamURL: "https://streams.regenbogen.de/rr-mannheim-128-mp3",
            genre: .pop,
            subGenre: "Pop Hits",
            countryCode: "DE"
        ),
        RadioStation(
            name: "sunshine live",
            frequency: 103.8,
            streamURL: "https://stream.sunshine-live.de/hq/mp3-192/radioplayer/",
            genre: .music,
            subGenre: "Electronic/Dance",
            countryCode: "DE"
        ),
        RadioStation(
            name: "Energy Deutschland",
            frequency: 104.2,
            streamURL: "https://streams.nrjaudio.fm/adwz1/de/55148/mp3_128.mp3",
            genre: .music,
            subGenre: "Dance/Pop",
            countryCode: "DE"
        ),
        RadioStation(
            name: "Rock Antenne",
            frequency: 107.1,
            streamURL: "https://stream.rockantenne.de/rockantenne/stream/mp3",
            genre: .rock,
            subGenre: "Rock",
            countryCode: "DE"
        ),
        RadioStation(
            name: "89.0 RTL",
            frequency: 89.0,
            streamURL: "https://streams.89.0rtl.de/rtl-live/mp3-128/konsole/",
            genre: .pop,
            subGenre: "Pop Hits",
            countryCode: "DE"
        ),
        RadioStation(
            name: "Radio PSR",
            frequency: 103.4,
            streamURL: "https://streams.radiopsr.de/psr-live/mp3-192/radioplayer/",
            genre: .pop,
            subGenre: "Saxony Pop",
            countryCode: "DE"
        ),
        RadioStation(
            name: "Hit Radio FFH",
            frequency: 105.9,
            streamURL: "https://mp3.ffh.de/radioffh/hqlivestream.mp3",
            genre: .pop,
            subGenre: "Hit Radio",
            countryCode: "DE"
        ),
        RadioStation(
            name: "planet radio",
            frequency: 100.5,
            streamURL: "https://streams.planetradio.de/planetradio/mp3-192/radioplayer/",
            genre: .pop,
            subGenre: "Youth Radio",
            countryCode: "DE"
        )
    ]
    
    // Italy stations
    static let italyStations = [
        RadioStation(
            name: "Radio Italia",
            frequency: 105.0,
            streamURL: "https://radioitaliasmi.akamaized.net/hls/live/2093120/RISMI/master.m3u8",
            genre: .pop,
            subGenre: "Italian Pop",
            countryCode: "IT"
        ),
        RadioStation(
            name: "RTL 102.5",
            frequency: 102.5,
            streamURL: "https://streamingv2.shoutcast.com/rtl-1025",
            genre: .pop,
            subGenre: "Hit Radio",
            countryCode: "IT"
        ),
        RadioStation(
            name: "Radio Deejay",
            frequency: 106.0,
            streamURL: "https://radiodeejay-lh.akamaihd.net/i/RadioDeejay_Live_1@189857/master.m3u8",
            genre: .pop,
            subGenre: "Dance",
            countryCode: "IT"
        ),
        RadioStation(
            name: "Virgin Radio",
            frequency: 104.5,
            streamURL: "https://icecast.unitedradio.it/Virgin.mp3",
            genre: .rock,
            subGenre: "Rock",
            countryCode: "IT"
        ),
        RadioStation(
            name: "RDS",
            frequency: 103.3,
            streamURL: "https://icstream.rds.radio/rds",
            genre: .pop,
            subGenre: "Pop",
            countryCode: "IT"
        ),
        RadioStation(
            name: "Radio 105",
            frequency: 105.0,
            streamURL: "https://icecast.unitedradio.it/Radio105.mp3",
            genre: .pop,
            subGenre: "Hit Music",
            countryCode: "IT"
        ),
        RadioStation(
            name: "Rai Radio 1",
            frequency: 89.7,
            streamURL: "https://icestreaming.rai.it/1.mp3",
            genre: .news,
            subGenre: "News/Talk",
            countryCode: "IT"
        ),
        RadioStation(
            name: "Radio Capital",
            frequency: 95.1,
            streamURL: "https://streamingv2.shoutcast.com/radiocapital",
            genre: .rock,
            subGenre: "Rock/Alternative",
            countryCode: "IT"
        ),
        RadioStation(
            name: "Radio m2o",
            frequency: 90.5,
            streamURL: "https://streamingv2.shoutcast.com/m2o",
            genre: .music,
            subGenre: "Dance/Electronic",
            countryCode: "IT"
        ),
        RadioStation(
            name: "Radio Kiss Kiss",
            frequency: 97.6,
            streamURL: "https://kisskiss.fluidstream.eu/KissKiss.aac",
            genre: .pop,
            subGenre: "Pop",
            countryCode: "IT"
        ),
        RadioStation(
            name: "Virgin Radio Italy",
            frequency: 104.5,
            streamURL: "https://icy.unitedradio.it/Virgin.mp3",
            genre: .rock,
            subGenre: "Rock",
            countryCode: "IT"
        ),
        RadioStation(
            name: "RDS",
            frequency: 107.0,
            streamURL: "https://stream.rds.it/RDS_mp3",
            genre: .pop,
            subGenre: "Contemporary",
            countryCode: "IT"
        ),
        RadioStation(
            name: "Radio Zeta",
            frequency: 102.3,
            streamURL: "https://live-radio02.mediahubaustralia.com/2RNW/mp3/",
            genre: .music,
            subGenre: "Easy Listening",
            countryCode: "IT"
        ),
        RadioStation(
            name: "M2O",
            frequency: 90.2,
            streamURL: "https://radiom2o-lh.akamaihd.net/i/m2oradio_1@568748/master.m3u8",
            genre: .music,
            subGenre: "Electronic/Dance",
            countryCode: "IT"
        ),
        RadioStation(
            name: "Radio Capital",
            frequency: 101.2,
            streamURL: "https://radiocapital-lh.akamaihd.net/i/RadioCapital_Live_1@196312/master.m3u8",
            genre: .rock,
            subGenre: "Classic Rock",
            countryCode: "IT"
        ),
        RadioStation(
            name: "Radio Dimensione Suono",
            frequency: 100.7,
            streamURL: "https://www.radiosmorfiadigitale.com/player/rds.m3u",
            genre: .pop,
            subGenre: "Italian Hits",
            countryCode: "IT"
        ),
        RadioStation(
            name: "Rai Radio 2",
            frequency: 91.7,
            streamURL: "https://radiodue-lh.akamaihd.net/i/radiodue_1@325223/master.m3u8",
            genre: .music,
            subGenre: "Variety",
            countryCode: "IT"
        ),
        RadioStation(
            name: "Radio 24",
            frequency: 103.0,
            streamURL: "https://shoutcast.radio24.it:8010/",
            genre: .news,
            subGenre: "Business News",
            countryCode: "IT"
        ),
        RadioStation(
            name: "Radio Popolare",
            frequency: 107.6,
            streamURL: "https://live.radiopop.it:8010/radiopop.mp3",
            genre: .news,
            subGenre: "Alternative News",
            countryCode: "IT"
        ),
        RadioStation(
            name: "Radio Freccia",
            frequency: 100.8,
            streamURL: "https://radiofreccia-lh.akamaihd.net/i/RadioFreccia_1@196312/master.m3u8",
            genre: .rock,
            subGenre: "Classic Rock",
            countryCode: "IT"
        ),
        RadioStation(
            name: "Radio Bruno",
            frequency: 93.3,
            streamURL: "https://onair15.xdevel.com:8007/stream",
            genre: .pop,
            subGenre: "Regional Pop",
            countryCode: "IT"
        )
    ]
    
    // Australia stations
    static let australiaStations = [
        RadioStation(
            name: "Triple J",
            frequency: 104.1,
            streamURL: "https://live-radio02.mediahubaustralia.com/2TJW/mp3/",
            genre: .rock,
            subGenre: "Alternative",
            countryCode: "AU"
        ),
        RadioStation(
            name: "Nova 96.9",
            frequency: 96.9,
            streamURL: "https://streaming.novaentertainment.com.au/nova969",
            genre: .pop,
            subGenre: "Hit Music",
            countryCode: "AU"
        ),
        RadioStation(
            name: "2GB Sydney",
            frequency: 873.0,
            streamURL: "https://21363.live.streamtheworld.com/2GB.mp3",
            genre: .news,
            subGenre: "Talk",
            countryCode: "AU"
        ),
        RadioStation(
            name: "KIIS 106.5",
            frequency: 106.5,
            streamURL: "https://kiis1065.akamaized.net/hls/live/2111556/KIIS1065/master.m3u8",
            genre: .pop,
            subGenre: "Top 40",
            countryCode: "AU"
        ),
        RadioStation(
            name: "ABC Classic",
            frequency: 92.9,
            streamURL: "https://live-radio01.mediahubaustralia.com/2FMW/mp3/",
            genre: .classical,
            subGenre: "Classical",
            countryCode: "AU"
        ),
        RadioStation(
            name: "smooth 91.5",
            frequency: 91.5,
            streamURL: "https://21293.live.streamtheworld.com/SMOOTH915.mp3",
            genre: .music,
            subGenre: "Easy Listening",
            countryCode: "AU"
        ),
        RadioStation(
            name: "Gold 104.3",
            frequency: 104.3,
            streamURL: "https://21353.live.streamtheworld.com/GOLD1043.mp3",
            genre: .pop,
            subGenre: "Classic Hits",
            countryCode: "AU"
        ),
        RadioStation(
            name: "Fox FM",
            frequency: 101.9,
            streamURL: "https://21353.live.streamtheworld.com/FOX_1019.mp3",
            genre: .pop,
            subGenre: "Hit Music",
            countryCode: "AU"
        ),
        RadioStation(
            name: "3AW",
            frequency: 693.0,
            streamURL: "https://21363.live.streamtheworld.com/3AW.mp3",
            genre: .news,
            subGenre: "News/Talk",
            countryCode: "AU"
        ),
        RadioStation(
            name: "Double J",
            frequency: 105.7,
            streamURL: "https://live-radio02.mediahubaustralia.com/DJDW/mp3/",
            genre: .rock,
            subGenre: "Alternative",
            countryCode: "AU"
        )
    ]
    
    // Canada stations
    static let canadaStations = [
        RadioStation(
            name: "Virgin Radio",
            frequency: 99.9,
            streamURL: "https://rogers-hls.leanstream.co/rogers/tor999.stream/playlist.m3u8",
            genre: .pop,
            subGenre: "Hit Music",
            countryCode: "CA"
        ),
        RadioStation(
            name: "CBC Radio One",
            frequency: 99.1,
            streamURL: "https://cbcliveradio-lh.akamaihd.net/i/CBCR1_TOR@118420/master.m3u8",
            genre: .news,
            subGenre: "Public Radio",
            countryCode: "CA"
        ),
        RadioStation(
            name: "CHUM FM",
            frequency: 104.5,
            streamURL: "https://rogers-hls.leanstream.co/rogers/tor1045.stream/playlist.m3u8",
            genre: .pop,
            subGenre: "Adult Contemporary",
            countryCode: "CA"
        ),
        RadioStation(
            name: "Q107",
            frequency: 107.0,
            streamURL: "https://corus.leanstream.co/CILQFM-MP3",
            genre: .rock,
            subGenre: "Classic Rock",
            countryCode: "CA"
        ),
        RadioStation(
            name: "98.1 CHFI",
            frequency: 98.1,
            streamURL: "https://rogers-hls.leanstream.co/rogers/tor981.stream/playlist.m3u8",
            genre: .pop,
            subGenre: "Adult Contemporary",
            countryCode: "CA"
        ),
        RadioStation(
            name: "CJAD 800",
            frequency: 800.0,
            streamURL: "https://corus.leanstream.co/CJADAMMP3",
            genre: .news,
            subGenre: "News/Talk",
            countryCode: "CA"
        ),
        RadioStation(
            name: "The Beat 92.5",
            frequency: 92.5,
            streamURL: "https://rogers-hls.leanstream.co/rogers/mtl925.stream/playlist.m3u8",
            genre: .music,
            subGenre: "Urban/Hip Hop",
            countryCode: "CA"
        ),
        RadioStation(
            name: "Boom 97.3",
            frequency: 97.3,
            streamURL: "https://stingray.leanstream.co/CFGQFM-MP3",
            genre: .pop,
            subGenre: "Classic Hits",
            countryCode: "CA"
        ),
        RadioStation(
            name: "TSN Radio",
            frequency: 1050.0,
            streamURL: "https://rogers-hls.leanstream.co/rogers/tor1050.stream/playlist.m3u8",
            genre: .sports,
            subGenre: "Sports",
            countryCode: "CA"
        ),
        RadioStation(
            name: "Ici Musique",
            frequency: 100.7,
            streamURL: "https://cbcicemusique.akamaized.net/hls/live/2038302/CBCFX_WEB/master.m3u8",
            genre: .music,
            subGenre: "French Music",
            countryCode: "CA"
        )
    ]
    
    // Mexico stations
    static let mexicoStations = [
        RadioStation(
            name: "Los 40 Mexico",
            frequency: 104.3,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/LOS40_MEXICO.mp3",
            genre: .pop,
            subGenre: "Top 40",
            countryCode: "MX"
        ),
        RadioStation(
            name: "Exa FM",
            frequency: 104.9,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/XHEXA_FM.mp3",
            genre: .pop,
            subGenre: "Pop",
            countryCode: "MX"
        ),
        RadioStation(
            name: "Radio Fórmula",
            frequency: 103.3,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/XERFR_AM.mp3",
            genre: .news,
            subGenre: "News/Talk",
            countryCode: "MX"
        ),
        RadioStation(
            name: "Stereo Cien",
            frequency: 100.1,
            streamURL: "https://stream.zeno.fm/stereocien",
            genre: .music,
            subGenre: "Mexican Music",
            countryCode: "MX"
        ),
        RadioStation(
            name: "La Z",
            frequency: 107.3,
            streamURL: "https://stream.zeno.fm/laz1073",
            genre: .music,
            subGenre: "Regional Mexican",
            countryCode: "MX"
        ),
        RadioStation(
            name: "Radio Felicidad",
            frequency: 1180.0,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/XEPH_AM.mp3",
            genre: .music,
            subGenre: "Traditional Mexican",
            countryCode: "MX"
        ),
        RadioStation(
            name: "Reactor 105.7",
            frequency: 105.7,
            streamURL: "https://reactor.radiomiled.com/stream",
            genre: .rock,
            subGenre: "Rock",
            countryCode: "MX"
        ),
        RadioStation(
            name: "Beat 100.9",
            frequency: 100.9,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/XHSON_FM.mp3",
            genre: .music,
            subGenre: "Electronic/Dance",
            countryCode: "MX"
        ),
        RadioStation(
            name: "Universal Stereo",
            frequency: 92.1,
            streamURL: "https://stream.zeno.fm/universal921",
            genre: .pop,
            subGenre: "Pop",
            countryCode: "MX"
        ),
        RadioStation(
            name: "Radio UNAM",
            frequency: 96.1,
            streamURL: "https://www.radioperu.pe/radio/8000/radio_1639098698.m3u8",
            genre: .culture,
            subGenre: "Cultural",
            countryCode: "MX"
        )
    ]
    
    // Swedish stations
    static let swedishStations = [
        RadioStation(
            name: "P3 Sveriges Radio",
            frequency: 92.4,
            streamURL: "https://sverigesradio.se/topsy/direkt/164-hi-mp3.m3u",
            genre: .music,
            subGenre: "Pop/Rock",
            countryCode: "SE"
        ),
        RadioStation(
            name: "Mix Megapol",
            frequency: 104.3,
            streamURL: "https://live-bauerse-fm.sharp-stream.com/mixmegapol_instream_se_mp3",
            genre: .pop,
            subGenre: "Hit Music",
            countryCode: "SE"
        ),
        RadioStation(
            name: "NRJ Sweden",
            frequency: 105.1,
            streamURL: "https://live-bauerse-fm.sharp-stream.com/nrj_instreamtest_se_mp3",
            genre: .pop,
            subGenre: "Contemporary",
            countryCode: "SE"
        ),
        RadioStation(
            name: "P1 Sveriges Radio",
            frequency: 92.8,
            streamURL: "https://sverigesradio.se/topsy/direkt/132-hi-mp3.m3u",
            genre: .news,
            subGenre: "News/Talk",
            countryCode: "SE"
        ),
        RadioStation(
            name: "P2 Sveriges Radio",
            frequency: 93.8,
            streamURL: "https://sverigesradio.se/topsy/direkt/163-hi-mp3.m3u",
            genre: .classical,
            subGenre: "Classical/Jazz",
            countryCode: "SE"
        ),
        RadioStation(
            name: "P4 Stockholm",
            frequency: 103.3,
            streamURL: "https://sverigesradio.se/topsy/direkt/701-hi-mp3.m3u",
            genre: .music,
            subGenre: "Local/Music",
            countryCode: "SE"
        ),
    ]
    
    // Finnish stations
    static let finnishStations = [
        RadioStation(
            name: "Yle Radio Suomi",
            frequency: 94.0,
            streamURL: "https://yleradiolive.akamaized.net/hls/live/2027672/in-YleRadio1/master.m3u8",
            genre: .music,
            subGenre: "Finnish Music",
            countryCode: "FI"
        ),
        RadioStation(
            name: "Radio Nova",
            frequency: 106.2,
            streamURL: "https://stream.bauermedia.fi/radionova/radionova_64.aac",
            genre: .pop,
            subGenre: "Hit Music",
            countryCode: "FI"
        ),
        RadioStation(
            name: "YleX",
            frequency: 91.5,
            streamURL: "https://yleradiolive.akamaized.net/hls/live/2027674/in-YleX/master.m3u8",
            genre: .rock,
            subGenre: "Alternative",
            countryCode: "FI"
        ),
        RadioStation(
            name: "Radio Rock",
            frequency: 103.0,
            streamURL: "https://ms-live-radiorock.nm-elemental.nelonenmedia.fi/master.m3u8",
            genre: .rock,
            subGenre: "Rock",
            countryCode: "FI"
        ),
        RadioStation(
            name: "Yle Puhe",
            frequency: 93.4,
            streamURL: "https://yleradiolive.akamaized.net/hls/live/2027677/in-YlePuhe/master.m3u8",
            genre: .talk,
            subGenre: "Talk",
            countryCode: "FI"
        ),
        RadioStation(
            name: "Radio Suomipop",
            frequency: 101.2,
            streamURL: "https://ms-live-suomipop.nm-elemental.nelonenmedia.fi/master.m3u8",
            genre: .pop,
            subGenre: "Finnish Pop",
            countryCode: "FI"
        ),
        RadioStation(
            name: "Radio City",
            frequency: 100.0,
            streamURL: "https://stream.bauermedia.fi/radiocity/radiocity_64.aac",
            genre: .pop,
            subGenre: "Urban",
            countryCode: "FI"
        ),
        RadioStation(
            name: "Loop",
            frequency: 102.4,
            streamURL: "https://ms-live-loop.nm-elemental.nelonenmedia.fi/master-256000.m3u8",
            genre: .music,
            subGenre: "Dance",
            countryCode: "FI"
        )
    ]
    
    // Thai stations
    static let thaiStations = [
        RadioStation(
            name: "Cool Fahrenheit",
            frequency: 93.0,
            streamURL: "https://coolism-web.cdn.byteark.com/coolism.m3u8",
            genre: .pop,
            subGenre: "Thai Pop",
            countryCode: "TH"
        ),
        RadioStation(
            name: "Virgin Hitz",
            frequency: 95.5,
            streamURL: "https://prsmedia-virginhitz.cdn.byteark.com/virginhitz/virginhitz.m3u8",
            genre: .pop,
            subGenre: "Hit Music",
            countryCode: "TH"
        ),
        RadioStation(
            name: "EFM",
            frequency: 94.0,
            streamURL: "https://efm.rs-station.com/efm",
            genre: .pop,
            subGenre: "International",
            countryCode: "TH"
        ),
        RadioStation(
            name: "Green Wave",
            frequency: 106.5,
            streamURL: "https://radio.siamha.com/greenwave",
            genre: .music,
            subGenre: "Easy Listening",
            countryCode: "TH"
        ),
        RadioStation(
            name: "Cat Radio",
            frequency: 100.8,
            streamURL: "https://catradio.rs-station.com/cat",
            genre: .rock,
            subGenre: "Alternative",
            countryCode: "TH"
        ),
        RadioStation(
            name: "Met 107",
            frequency: 107.0,
            streamURL: "https://metradio1.metroaudio1.stream.prd.go.th/Metro",
            genre: .rock,
            subGenre: "Rock",
            countryCode: "TH"
        ),
        RadioStation(
            name: "FM One",
            frequency: 103.5,
            streamURL: "https://fmone.rs-station.com/fmone",
            genre: .pop,
            subGenre: "Thai Hits",
            countryCode: "TH"
        ),
        RadioStation(
            name: "Chill FM",
            frequency: 89.0,
            streamURL: "https://chillfm.rs-station.com/chill",
            genre: .music,
            subGenre: "Chill",
            countryCode: "TH"
        ),
        RadioStation(
            name: "JS100",
            frequency: 100.0,
            streamURL: "https://js100.rs-station.com/js100",
            genre: .news,
            subGenre: "News/Talk",
            countryCode: "TH"
        ),
        RadioStation(
            name: "Eazy FM",
            frequency: 105.5,
            streamURL: "https://eazyfm.rs-station.com/eazy",
            genre: .music,
            subGenre: "Oldies",
            countryCode: "TH"
        )
    ]
    
    // Icelandic stations
    static let icelandicStations = [
        RadioStation(
            name: "Rás 1",
            frequency: 92.4,
            streamURL: "http://netradio.ruv.is/ras1.m3u",
            genre: .news,
            subGenre: "News/Culture",
            countryCode: "IS"
        ),
        RadioStation(
            name: "Rás 2",
            frequency: 90.1,
            streamURL: "http://netradio.ruv.is/ras2.m3u",
            genre: .music,
            subGenre: "Pop/Rock",
            countryCode: "IS"
        ),
        RadioStation(
            name: "Bylgjan",
            frequency: 98.9,
            streamURL: "http://stream.radio.is/Bylgjan",
            genre: .pop,
            subGenre: "Hit Music",
            countryCode: "IS"
        ),
        RadioStation(
            name: "FM957",
            frequency: 95.7,
            streamURL: "http://stream.radio.is/FM957",
            genre: .pop,
            subGenre: "Contemporary",
            countryCode: "IS"
        ),
        RadioStation(
            name: "X977",
            frequency: 97.7,
            streamURL: "http://stream.radio.is/X977",
            genre: .rock,
            subGenre: "Rock/Alternative",
            countryCode: "IS"
        ),
        RadioStation(
            name: "K100",
            frequency: 100.5,
            streamURL: "http://stream.radio.is/K100",
            genre: .music,
            subGenre: "Various",
            countryCode: "IS"
        ),
        RadioStation(
            name: "Létt Bylgjan",
            frequency: 96.7,
            streamURL: "http://stream.radio.is/LettBylgjan",
            genre: .music,
            subGenre: "Easy Listening",
            countryCode: "IS"
        ),
        RadioStation(
            name: "Útvarp Saga",
            frequency: 99.4,
            streamURL: "http://stream.radio.is/Saga",
            genre: .talk,
            subGenre: "Talk Radio",
            countryCode: "IS"
        ),
        RadioStation(
            name: "Rondo",
            frequency: 88.0,
            streamURL: "http://netradio.ruv.is/rondo.m3u",
            genre: .classical,
            subGenre: "Classical",
            countryCode: "IS"
        ),
        RadioStation(
            name: "Retro FM",
            frequency: 103.0,
            streamURL: "http://stream.radio.is/Retro",
            genre: .music,
            subGenre: "Retro Hits",
            countryCode: "IS"
        )
    ]
    
    // Mongolian stations
    static let mongolianStations = [
        RadioStation(
            name: "MNB Radio",
            frequency: 99.0,
            streamURL: "http://103.14.38.107:8000/stream",
            genre: .music,
            subGenre: "National Radio",
            countryCode: "MN"
        ),
        RadioStation(
            name: "Ulaanbaatar Radio",
            frequency: 102.5,
            streamURL: "http://103.14.38.107:8002/stream",
            genre: .music,
            subGenre: "Local",
            countryCode: "MN"
        ),
        RadioStation(
            name: "Radio Mongolia",
            frequency: 105.5,
            streamURL: "http://radio.mnb.mn:8000/mn.mp3",
            genre: .music,
            subGenre: "Traditional",
            countryCode: "MN"
        ),
        RadioStation(
            name: "M Radio",
            frequency: 107.1,
            streamURL: "http://69.73.243.251:8020/stream",
            genre: .pop,
            subGenre: "Pop Music",
            countryCode: "MN"
        ),
        RadioStation(
            name: "Wind FM",
            frequency: 98.5,
            streamURL: "http://103.14.38.179:9000/wind.mp3",
            genre: .rock,
            subGenre: "Rock/Alternative",
            countryCode: "MN"
        ),
        RadioStation(
            name: "Hit Radio",
            frequency: 88.1,
            streamURL: "http://202.131.237.4:8002/hit",
            genre: .pop,
            subGenre: "Hit Music",
            countryCode: "MN"
        ),
        RadioStation(
            name: "Royal Radio",
            frequency: 95.5,
            streamURL: "http://103.14.38.179:9000/royal.mp3",
            genre: .classical,
            subGenre: "Classical/Traditional",
            countryCode: "MN"
        ),
        RadioStation(
            name: "Traffic Radio",
            frequency: 103.9,
            streamURL: "http://202.131.237.4:8004/traffic",
            genre: .news,
            subGenre: "Traffic/News",
            countryCode: "MN"
        ),
        RadioStation(
            name: "Business Radio",
            frequency: 92.1,
            streamURL: "http://103.14.38.179:9000/business.mp3",
            genre: .news,
            subGenre: "Business News",
            countryCode: "MN"
        ),
        RadioStation(
            name: "Voice of Mongolia",
            frequency: 96.9,
            streamURL: "http://202.131.237.4:8006/voice",
            genre: .education,
            subGenre: "International",
            countryCode: "MN"
        )
    ]
    
    
    // Taiwanese stations
    static let taiwaneseStations = [
        RadioStation(
            name: "ICRT",
            frequency: 100.7,
            streamURL: "https://stream.rcs.revma.com/7mnq8rt7k5zuv",
            genre: .pop,
            subGenre: "English Pop",
            countryCode: "TW"
        ),
        RadioStation(
            name: "Hit FM Taiwan",
            frequency: 90.1,
            streamURL: "http://n09.rcs.revma.com/aw9uqyxy2tzuv",
            genre: .pop,
            subGenre: "Mandopop",
            countryCode: "TW"
        ),
        RadioStation(
            name: "Kiss Radio Taiwan",
            frequency: 99.9,
            streamURL: "https://onair.rcs.revma.com/4hckq6b0h5zuv",
            genre: .pop,
            subGenre: "Pop/Dance",
            countryCode: "TW"
        ),
        RadioStation(
            name: "UFO Radio",
            frequency: 92.1,
            streamURL: "http://n11.rcs.revma.com/8wv7xp7x5heuv",
            genre: .rock,
            subGenre: "Rock/Alternative",
            countryCode: "TW"
        ),
        RadioStation(
            name: "Taiwan Indigenous Radio",
            frequency: 96.3,
            streamURL: "https://cast.iradio.live:8000/iradio",
            genre: .culture,
            subGenre: "Indigenous",
            countryCode: "TW"
        ),
        RadioStation(
            name: "News98",
            frequency: 98.1,
            streamURL: "http://19523.live.streamtheworld.com/NEWS98_PREM.mp3",
            genre: .news,
            subGenre: "News/Talk",
            countryCode: "TW"
        ),
        RadioStation(
            name: "Taiwan Classical",
            frequency: 99.7,
            streamURL: "https://stream.superfm99-7.com.tw:8555/live.mp3",
            genre: .classical,
            subGenre: "Classical",
            countryCode: "TW"
        ),
        RadioStation(
            name: "BestRadio",
            frequency: 95.1,
            streamURL: "http://stream.superfm99-7.com.tw:8554/stream",
            genre: .pop,
            subGenre: "Adult Contemporary",
            countryCode: "TW"
        ),
        RadioStation(
            name: "Apple Line",
            frequency: 98.7,
            streamURL: "http://stream.rcs.revma.com/044q3p7xq9zuv",
            genre: .music,
            subGenre: "Various",
            countryCode: "TW"
        ),
        RadioStation(
            name: "Voice of Taipei",
            frequency: 93.1,
            streamURL: "https://stream.ginnet.cloud/live0130lo-yfyo/_definst_/fm/playlist.m3u8",
            genre: .talk,
            subGenre: "Local",
            countryCode: "TW"
        )
    ]
    
    // Indian stations
    static let indianStations = [
        RadioStation(
            name: "Radio City Hindi",
            frequency: 91.1,
            streamURL: "https://prclive1.listenon.in/Hindi",
            genre: .pop,
            subGenre: "Bollywood",
            countryCode: "IN"
        ),
        RadioStation(
            name: "Radio Mirchi",
            frequency: 98.3,
            streamURL: "https://radioindia.net/radio/mirchi98/icecast.audio",
            genre: .pop,
            subGenre: "Bollywood Hits",
            countryCode: "IN"
        ),
        RadioStation(
            name: "Big FM",
            frequency: 92.7,
            streamURL: "https://stream-al.planetradio.co.uk/bigindi.mp3",
            genre: .music,
            subGenre: "Hindi Music",
            countryCode: "IN"
        ),
        RadioStation(
            name: "Suryan FM",
            frequency: 93.5,
            streamURL: "https://radioindia.net/radio/suryanfm/icecast.audio",
            genre: .pop,
            subGenre: "Tamil Hits",
            countryCode: "IN"
        ),
        RadioStation(
            name: "Club FM",
            frequency: 94.3,
            streamURL: "https://eu10.fastcast4u.com/clubfmuae",
            genre: .pop,
            subGenre: "Malayalam Hits",
            countryCode: "IN"
        ),
        RadioStation(
            name: "All India Radio",
            frequency: 100.1,
            streamURL: "https://air.pc.cdn.bitgravity.com/air/live/pbaudio001/playlist.m3u8",
            genre: .news,
            subGenre: "Public Radio",
            countryCode: "IN"
        ),
        RadioStation(
            name: "Radio One",
            frequency: 94.3,
            streamURL: "https://stream.radiojar.com/2r69ty5k8heuv",
            genre: .rock,
            subGenre: "International",
            countryCode: "IN"
        ),
        RadioStation(
            name: "Suno 1024",
            frequency: 102.4,
            streamURL: "https://playerservices.streamtheworld.com/api/livestream-redirect/SUNO917.mp3",
            genre: .music,
            subGenre: "Hindi Retro",
            countryCode: "IN"
        ),
        RadioStation(
            name: "Vividh Bharati",
            frequency: 102.9,
            streamURL: "https://air.pc.cdn.bitgravity.com/air/live/pbaudio088/playlist.m3u8",
            genre: .culture,
            subGenre: "Classical/Folk",
            countryCode: "IN"
        ),
        RadioStation(
            name: "Red FM",
            frequency: 93.5,
            streamURL: "https://stream.zeno.fm/vp3mz2a9qchvv",
            genre: .pop,
            subGenre: "Contemporary",
            countryCode: "IN"
        )
    ]
    
    // Russian stations
    static let russianStations = [
        RadioStation(
            name: "Europa Plus",
            frequency: 106.2,
            streamURL: "https://ep128.hostingradio.ru:8030/ep128",
            genre: .pop,
            subGenre: "Top 40",
            countryCode: "RU"
        ),
        RadioStation(
            name: "Radio Record",
            frequency: 106.3,
            streamURL: "https://radiorecord.hostingradio.ru/rr_main96.aacp",
            genre: .music,
            subGenre: "Dance/Electronic",
            countryCode: "RU"
        ),
        RadioStation(
            name: "Русское Радио",
            frequency: 105.7,
            streamURL: "https://rusradio.hostingradio.ru/rusradio96.aacp",
            genre: .pop,
            subGenre: "Russian Pop",
            countryCode: "RU"
        ),
        RadioStation(
            name: "Наше Радио",
            frequency: 101.7,
            streamURL: "https://nashe1.hostingradio.ru/nashespb128.mp3",
            genre: .rock,
            subGenre: "Russian Rock",
            countryCode: "RU"
        ),
        RadioStation(
            name: "DFM",
            frequency: 101.2,
            streamURL: "https://dfm.hostingradio.ru/dfm96.aacp",
            genre: .music,
            subGenre: "Dance",
            countryCode: "RU"
        ),
        RadioStation(
            name: "Авторадио",
            frequency: 90.3,
            streamURL: "https://pub0302.101.ru:8443/stream/air/aac/64/100",
            genre: .pop,
            subGenre: "Hits",
            countryCode: "RU"
        ),
        RadioStation(
            name: "Love Radio",
            frequency: 106.6,
            streamURL: "https://pub0302.101.ru:8443/stream/air/aac/64/16",
            genre: .pop,
            subGenre: "Love Songs",
            countryCode: "RU"
        ),
        RadioStation(
            name: "Retro FM",
            frequency: 88.3,
            streamURL: "https://retroserver.streamr.ru:8043/retro128.mp3",
            genre: .pop,
            subGenre: "Retro Hits",
            countryCode: "RU"
        ),
        RadioStation(
            name: "Business FM",
            frequency: 87.5,
            streamURL: "https://bfmstream.bfm.ru:8004/fm32",
            genre: .news,
            subGenre: "Business News",
            countryCode: "RU"
        ),
        RadioStation(
            name: "Echo Moscow",
            frequency: 91.2,
            streamURL: "https://stream.echo.msk.ru:9000/stream",
            genre: .news,
            subGenre: "News/Talk",
            countryCode: "RU"
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
        case "SE":
            return swedishStations
        case "FI":
            return finnishStations
        case "TH":
            return thaiStations
        case "IS":
            return icelandicStations
        case "MN":
            return mongolianStations
        case "TW":
            return taiwaneseStations
        case "IN":
            return indianStations
        case "RU":
            return russianStations
        default:
            // 그 외 국가들은 일단 미국 스테이션 사용
            return usStations
        }
    }
}