import Foundation

enum WeatherType: String, CaseIterable, Identifiable, Codable {
    case sunny
    case cloudy
    case rainy
    case snow
    case storm
    case windy

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .sunny: return "☀️"
        case .cloudy: return "☁️"
        case .rainy: return "🌧️"
        case .snow:  return "❄️"
        case .storm: return "⛈️"
        case .windy: return "🌬️"
        }
    }
}
