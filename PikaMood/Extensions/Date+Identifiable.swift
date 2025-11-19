import Foundation

// This lets Date be used in navigationDestination(item:)
extension Date: Identifiable {
    public var id: TimeInterval {
        self.timeIntervalSince1970
    }
}
