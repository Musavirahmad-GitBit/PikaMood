import Foundation
import SwiftUI

// MARK: - Mood Types

enum MoodType: String, CaseIterable, Identifiable, Codable {
    case veryHappy
    case happy
    case okay
    case sad
    case angry
    case tired
    case calm

    var id: String { rawValue }

    // Japanese label + emoji
    var label: String {
        switch self {
        case .veryHappy: return NSLocalizedString("mood_veryHappy", comment: "")
        case .happy:     return NSLocalizedString("mood_happy", comment: "")
        case .okay:      return NSLocalizedString("mood_okay", comment: "")
        case .sad:       return NSLocalizedString("mood_sad", comment: "")
        case .angry:     return NSLocalizedString("mood_angry", comment: "")
        case .tired:     return NSLocalizedString("mood_tired", comment: "")
        case .calm:      return NSLocalizedString("mood_calm", comment: "")
        }
    }

    // Color hex string (for future UI)
    var colorHex: String {
        switch self {
        case .veryHappy: return "#FFE066" // pastel yellow
        case .happy:     return "#FFB7C5" // sakura pink
        case .okay:      return "#C4F3FF" // aqua
        case .sad:       return "#E6D8FF" // lavender
        case .angry:     return "#FF8A80" // soft red
        case .tired:     return "#D3D3D3" // light grey
        case .calm:      return "#C8F7C5" // mint
        }
    }
    
}

// MARK: - Mood Entry
struct MoodEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    var moodType: MoodType
    var journalText: String?

    // NEW FIELDS
    var weather: WeatherType?
    var tag: TagType?
    var intensity: Double?
    
    var ownerId: String?

    init(
        id: UUID = UUID(),
        date: Date,
        moodType: MoodType,
        journalText: String? = nil,
        weather: WeatherType? = nil,
        tag: TagType? = nil,
        intensity: Double? = nil,
        ownerId: String? = nil

    ) {
        self.id = id
        self.date = date
        self.moodType = moodType
        self.journalText = journalText
        self.weather = weather
        self.tag = tag
        self.intensity = intensity
        self.ownerId = ownerId
    }
}

extension MoodType {
    var emoji: String {
        switch self {
        case .veryHappy: return "😄"
        case .happy: return "😊"
        case .okay: return "😐"
        case .sad: return "😢"
        case .angry: return "😡"
        case .tired: return "😴"
        case .calm: return "😌"
        }
    }
}


extension MoodType {
    func pixelColor(intensity: Double) -> Color {
        let base: Color = {
            switch self {
            case .veryHappy: return Color(hex: "#FFE066") // pastel yellow
            case .happy:     return Color(hex: "#FFB7C5") // sakura pink
            case .okay:      return Color(hex: "#C4F3FF") // aqua
            case .sad:       return Color(hex: "#AFC0FF") // soft blue-lavender
            case .angry:     return Color(hex: "#FF8A80") // soft red
            case .tired:     return Color(hex: "#D3D3D3") // light grey
            case .calm:      return Color(hex: "#C8F7C5") // mint
            }
        }()

        // adjust brightness using intensity (0.0 → lighter, 1.0 → stronger)
        return base.opacity(0.4 + intensity * 0.6)
    }
    
}


extension MoodType {
    var notificationText: String {
        switch self {
        case .veryHappy:
            return "😄 とても幸せな気分です！ 共有しましょう！"
        case .happy:
            return "😊 嬉しい気分のようです！ 一緒に喜びましょう！"
        case .okay:
            return "🙂 普通の気分みたい。今日の様子を聞いてあげて。"
        case .sad:
            return "😢 悲しい気分のようです… 優しく声をかけてみて。"
        case .angry:
            return "😡 イライラしているみたい… 少しスペースをあげてあげよう。"
        case .tired:
            return "😴 つかれているようです… 励ましのメッセージを送ってみて。"
        case .calm:
            return "😌 落ち着いた気分のようです。いい感じですね！"
        }
    }
}
