import Foundation

struct SuggestionEngine {
    static func suggestion(for mood: MoodType) -> String {
        switch mood {

        case .veryHappy:
            return NSLocalizedString("suggestion_very_happy", comment: "")

        case .happy:
            return NSLocalizedString("suggestion_happy", comment: "")

        case .okay:
            return NSLocalizedString("suggestion_okay", comment: "")

        case .sad:
            return NSLocalizedString("suggestion_sad", comment: "")

        case .angry:
            return NSLocalizedString("suggestion_angry", comment: "")

        case .tired:
            return NSLocalizedString("suggestion_tired", comment: "")

        case .calm:
            return NSLocalizedString("suggestion_calm", comment: "")
        }
    }
}
