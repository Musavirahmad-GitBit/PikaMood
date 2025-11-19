import Foundation

struct SuggestionEngine {
    static func suggestion(for mood: MoodType) -> String {
        switch mood {

        case .veryHappy:
            return "素敵な気分を一緒にお祝いしましょう！🌟"

        case .happy:
            return "うれしい気分を共有してあげましょう！🎉"

        case .okay:
            return "今日の様子を優しく聞いてみませんか？🙂"

        case .sad:
            return "優しいメッセージを送ってみませんか？💌"

        case .angry:
            return "少しスペースをあげるのがいいかもしれません 🫶"

        case .tired:
            return "「ゆっくり休んでね」と声をかけてあげましょう 😴🤍"

        case .calm:
            return "落ち着いた気分を一緒に楽しみましょう 🌿😌"
        }
    }
}
