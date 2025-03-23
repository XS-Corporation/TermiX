import SwiftUI

@main
struct TerminalApp: App {
    var body: some Scene {
        WindowGroup {
            TerminalView()
                .frame(minWidth: 600, minHeight: 400)
                .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
                .onDrop(of: [.fileURL], delegate: TerminalDropDelegate.shared) // Добавляем поддержку drop
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowToolbarStyle(UnifiedWindowToolbarStyle())
    }
}




