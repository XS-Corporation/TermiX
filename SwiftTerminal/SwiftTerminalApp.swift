import SwiftUI

@main
struct TerminalApp: App {
    var body: some Scene {
        WindowGroup {
            TerminalView()
                .frame(minWidth: 600, minHeight: 400)
                .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowToolbarStyle(UnifiedWindowToolbarStyle())
        .commands {
            CommandMenu("Terminal") {
                Button("Clear") {
                    // In future!
                }
            }
        }
    }
}



