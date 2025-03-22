import SwiftUI

struct OutputLine: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let type: OutputType
    
    static func == (lhs: OutputLine, rhs: OutputLine) -> Bool {
        return lhs.id == rhs.id && lhs.text == rhs.text && lhs.type == rhs.type
    }
    
    enum OutputType {
        case system
        case command
        case output
        case error
        
        var color: Color {
            switch self {
            case .system: return .gray
            case .command: return .green
            case .output: return .white
            case .error: return .red
            }
        }
    }
}


