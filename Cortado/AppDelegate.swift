import AppKit

/// Drives the menu bar item directly with AppKit.
///
/// SwiftUI's `MenuBarExtra` label ignores explicit `.frame()` sizing on its
/// image, so its rendered icon can't be reliably resized. Managing the
/// `NSStatusItem` ourselves gives full, predictable control over the icon's
/// size via `NSImage.size`.
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
        updateStatusItem()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(caffeineStateChanged),
            name: CaffeineManager.stateDidChangeNotification,
            object: nil
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Never leave an orphaned caffeinate process running after Cortado quits.
        CaffeineManager.shared.decaffeinate()
    }

    @objc private func caffeineStateChanged() {
        updateStatusItem()
    }

    private func updateStatusItem() {
        let isCaffeinated = CaffeineManager.shared.isCaffeinated
        statusItem.button?.image = isCaffeinated ? caffeinatedImage : squareImage

        let menu = NSMenu()

        if isCaffeinated {
            menu.addItem(
                NSMenuItem(title: "Decaffeinate", action: #selector(decaffeinateTapped), keyEquivalent: "")
            )
        } else {
            menu.addItem(
                NSMenuItem(title: "Caffeinate", action: #selector(caffeinateTapped), keyEquivalent: "")
            )
        }

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitTapped), keyEquivalent: "q"))

        for item in menu.items {
            item.target = self
        }

        statusItem.menu = menu
    }

    @objc private func caffeinateTapped() {
        CaffeineManager.shared.caffeinate()
    }

    @objc private func decaffeinateTapped() {
        CaffeineManager.shared.decaffeinate()
    }

    @objc private func quitTapped() {
        NSApplication.shared.terminate(nil)
    }
}
