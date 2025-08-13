import Foundation

// Emotional descriptions for nature sound stations
struct StationDescriptions {
    static func getDescription(for station: RadioStation) -> String {
        switch station.name {
        case "Tokyo Rain FM":
            return """
            🌧️ Tokyo Rain FM - 88.1 MHz
            
            도쿄 시부야의 어느 조용한 골목,
            창문에 부딪히는 빗방울 소리.
            
            커피 한 잔과 함께 듣는
            도시의 고요한 빗소리는
            마음을 씻어내립니다.
            
            "Every raindrop carries a memory,
            every sound brings peace."
            
            24시간 송출되는 자연의 라디오
            """
            
        case "Pacific Ocean FM":
            return """
            🌊 Pacific Ocean FM - 90.3 MHz
            
            태평양의 파도가 전하는 메시지,
            끝없이 밀려오고 밀려가는 리듬.
            
            가마쿠라 해변의 새벽,
            첫 서퍼들이 나서기 전
            바다만이 들려주는 이야기.
            
            "The ocean remembers everything,
            and forgives everything."
            
            파도의 주파수로 연결되는 평온
            """
            
        case "Forest Morning FM":
            return """
            🌲 Forest Morning FM - 92.5 MHz
            
            교토 북쪽 산속,
            첫 햇살에 잠을 깬 새들의 합창.
            
            도시의 알람이 아닌
            자연의 모닝콜로 시작하는 하루.
            천 년의 숲이 매일 아침 방송하는
            생명의 소리.
            
            "Nature's original morning show,
            broadcasting since forever."
            """
            
        case "Campfire Radio":
            return """
            🔥 Campfire Radio - 94.7 MHz
            
            후지산 기슭의 캠프장,
            장작이 타들어가는 소리.
            
            별이 쏟아지는 밤하늘 아래
            모닥불이 들려주는 옛날이야기.
            인류의 가장 오래된 라디오.
            
            "Where stories begin,
            and worries end."
            """
            
        case "Storm Signal FM":
            return """
            ⛈️ Storm Signal FM - 96.9 MHz
            
            여름밤 오사카 상공,
            하늘이 보내는 긴급 방송.
            
            천둥의 드럼과 비의 멜로디,
            자연이 연주하는 심포니.
            불안을 잠재우는 역설적 평화.
            
            "In chaos, find calm.
            In storm, find shelter."
            """
            
        default:
            return """
            📻 Natural Frequency
            
            Tuning into nature's broadcast.
            자연이 송출하는 주파수에 맞춰보세요.
            """
        }
    }
    
    static func getShortDescription(for station: RadioStation) -> String {
        switch station.name {
        case "Tokyo Rain FM":
            return "도쿄의 빗소리 • Rainy Tokyo Vibes"
        case "Pacific Ocean FM":
            return "태평양의 파도 • Pacific Waves"
        case "Forest Morning FM":
            return "숲의 아침 • Forest Awakening"
        case "Campfire Radio":
            return "모닥불 이야기 • Fireside Stories"
        case "Storm Signal FM":
            return "여름밤 폭풍 • Summer Storm"
        default:
            return "Natural Broadcast"
        }
    }
}