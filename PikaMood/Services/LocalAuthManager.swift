import LocalAuthentication
import Foundation

final class LocalAuthManager: ObservableObject {
    static let shared = LocalAuthManager()

    @Published var isUnlocked: Bool = false
    @Published var isLockEnabled: Bool = UserDefaults.standard.bool(forKey: "lock_enabled")

    private init() {}

    func authenticate() {
        guard isLockEnabled else {
            isUnlocked = true
            return
        }

        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: "PikaMoodロックを解除します") { success, _ in
                DispatchQueue.main.async {
                    self.isUnlocked = success
                }
            }
        } else {
            DispatchQueue.main.async {
                self.isUnlocked = false
            }
        }
    }

    func setLockEnabled(_ enabled: Bool) {
        isLockEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "lock_enabled")
    }
}
