import Foundation
import Combine

/// Owns the `caffeinate` process and publishes the app's caffeinated state.
final class CaffeineManager: ObservableObject {

    static let shared = CaffeineManager()

    /// Posted whenever `isCaffeinated` changes, so the AppKit-based status
    /// item (which does not observe `@Published` directly) can refresh its
    /// icon and menu.
    static let stateDidChangeNotification = Notification.Name("CaffeineManager.stateDidChange")

    /// `true` while `/usr/bin/caffeinate` is running and keeping the
    /// display and system awake.
    @Published private(set) var isCaffeinated = false {
        didSet {
            NotificationCenter.default.post(name: Self.stateDidChangeNotification, object: nil)
        }
    }

    private var caffeinateProcess: Process?

    private init() {}

    /// Starts `caffeinate -d -i`, which indefinitely prevents the display
    /// and system from sleeping until it is terminated.
    func caffeinate() {
        guard caffeinateProcess == nil else { return }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        process.arguments = ["-d", "-i"]

        process.terminationHandler = { [weak self] _ in
            DispatchQueue.main.async {
                self?.caffeinateProcess = nil
                self?.isCaffeinated = false
            }
        }

        do {
            try process.run()
            caffeinateProcess = process
            isCaffeinated = true
        } catch {
            NSLog("Cortado: failed to start caffeinate — \(error.localizedDescription)")
        }
    }

    /// Stops the running `caffeinate` process, letting the display and
    /// system sleep normally again.
    func decaffeinate() {
        stopCaffeinateProcess()
    }

    private func stopCaffeinateProcess() {
        guard let process = caffeinateProcess else { return }
        process.terminationHandler = nil
        if process.isRunning {
            process.terminate()
        }
        caffeinateProcess = nil
        isCaffeinated = false
    }
}
