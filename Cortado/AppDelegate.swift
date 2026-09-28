import AppKit

/// Handles app lifecycle concerns: keeping Cortado out of the Dock and
/// making sure the `caffeinate` process never outlives the app.
final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Belt-and-suspenders: keep Cortado out of the Dock and app switcher
        // even if the Info.plist LSUIElement key isn't picked up for some reason.
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Never leave an orphaned caffeinate process running after Cortado quits.
        CaffeineManager.shared.decaffeinate()
    }
}
