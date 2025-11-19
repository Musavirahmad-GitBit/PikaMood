import Foundation

enum TagType: String, CaseIterable, Identifiable, Codable {
    case alone
    case partner
    case friends
    case family
    case work
    case study

    var id: String { rawValue }

    var label: String {
        switch self {
        case .alone: return "ひとり"
        case .partner: return "パートナー"
        case .friends: return "友だち"
        case .family: return "家族"
        case .work: return "仕事"
        case .study: return "勉強"
        }
    }

    var emoji: String {
        switch self {
        case .alone: return "🌙"
        case .partner: return "💞"
        case .friends: return "👯‍♂️"
        case .family: return "🏡"
        case .work: return "💼"
        case .study: return "📚"
        }
    }
}
