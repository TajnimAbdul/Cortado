import AppKit

/// Drives the menu bar item directly with AppKit.
///
/// Cortado caffeinates the Mac for as long as it's running: it starts
/// `caffeinate` on launch and stops it on quit. There's no manual toggle —
/// the menu just offers Quit.
final class AppDelegate: NSObject, NSApplicationDelegate {

    /// The on-screen size (in points) of the menu bar icon.
    private let iconSize = NSSize(width: 16, height: 16)

    private var statusItem: NSStatusItem!

    private lazy var squareImage: NSImage = {
        let image = NSImage(systemSymbolName: "square.fill", accessibilityDescription: "Decaffeinated")
            ?? NSImage()
        image.isTemplate = true
        image.size = iconSize
        return image
    }()

    private lazy var caffeinatedImage: NSImage = {
        let image = NSImage(named: "CaffeinatedIcon") ?? NSImage()
        image.isTemplate = true
        image.size = iconSize
        return image
    }()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Keep Cortado out of the Dock and app switcher.
        NSApp.setActivationPolicy(.accessory)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitTapped), keyEquivalent: "q"))
        for item in menu.items {
            item.target = self
        }
        statusItem.menu = menu

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(caffeineStateChanged),
            name: CaffeineManager.stateDidChangeNotification,
            object: nil
        )

        updateIcon()

        // Caffeinate for as long as the app is running.
        CaffeineManager.shared.caffeinate()
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Stop caffeinating the moment Cortado quits.
        CaffeineManager.shared.decaffeinate()
    }

    @objc private func caffeineStateChanged() {
        updateIcon()
    }

    private func updateIcon() {
        statusItem.button?.image = CaffeineManager.shared.isCaffeinated ? caffeinatedImage : squareImage
    }

    @objc private func quitTapped() {
        NSApplication.shared.terminate(nil)
    }
}
