import SwiftUI

class TerminalDropDelegate: DropDelegate {
    static let shared = TerminalDropDelegate()
    @Published var droppedPath: String?
    
    func performDrop(info: DropInfo) -> Bool {
        guard let item = info.itemProviders(for: [.fileURL]).first else { return false }
        item.loadObject(ofClass: URL.self) { url, _ in
            if let url = url as? URL {
                DispatchQueue.main.async {
                    self.droppedPath = url.path
                }
            }
        }
        return true
    }
}

