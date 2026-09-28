import SwiftUI

@main
struct MyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var caffeineManager = CaffeineManager.shared

    var body: some Scene {
        MenuBarExtra {
            if caffeineManager.isCaffeinated {
                Button("Decaffeinate") {
                    caffeineManager.decaffeinate()
                }
            } else {
                Button("Caffeinate") {
                    caffeineManager.caffeinate()
                }
            }

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        } label: {
            Image(systemName: caffeineManager.isCaffeinated ? "triangle.fill" : "square.fill")
        }
        .menuBarExtraStyle(.menu)
    }
}
