import SwiftUI

struct PathPickerView: View {
    let currentPath: String
    let onSelect: (String) -> Void
    @State private var contents: [URL] = []
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(contents, id: \.self) { url in
                    Button(action: {
                        onSelect(url.path)
                    }) {
                        Text(url.lastPathComponent)
                            .foregroundColor(.white)
                            .font(.system(.body, design: .monospaced))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .frame(maxHeight: 200)
        .onAppear {
            loadDirectoryContents()
        }
        .onChange(of: currentPath) { _ in
            loadDirectoryContents()
        }
    }
    
    private func loadDirectoryContents() {
        do {
            contents = try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: currentPath), includingPropertiesForKeys: nil)
                .filter { !$0.lastPathComponent.hasPrefix(".") }
                .sorted { $0.lastPathComponent < $1.lastPathComponent } // Сортировка для удобства
        } catch {
            print("Error loading directory: \(error)")
        }
    }
}



