import SwiftUI

@main
struct MyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // No windows — the menu bar item is built and managed directly by
        // AppDelegate using AppKit, which gives reliable control over the
        // icon's size (SwiftUI's MenuBarExtra ignores frame sizing on its
        // label image).
        Settings {
            EmptyView()
        }
    }
}
