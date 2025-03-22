import SwiftUI

class TerminalSettings {
    static let shared = TerminalSettings()
    static let settingsChangedNotification = Notification.Name("terminalSettingsChanged")
    
    enum ColorScheme {
        case dark
        case light
        case custom(colors: TerminalColors)
        
        var swiftUIScheme: SwiftUI.ColorScheme? {
            switch self {
            case .dark: return SwiftUI.ColorScheme.dark
            case .light: return SwiftUI.ColorScheme.light
            case .custom: return nil
            }
        }
        
        struct TerminalColors {
            let background: Color
            let text: Color
            let prompt: Color
        }
    }
    
    var colorScheme: ColorScheme = .dark {
        didSet {
            NotificationCenter.default.post(name: TerminalSettings.settingsChangedNotification, object: nil)
        }
    }
}


