import SwiftUI

struct TerminalView: View {
    @StateObject private var viewModel = TerminalViewModel()
    @State private var command: String = ""
    
    var body: some View {
        VStack(spacing: 10) {
            ScrollView {
                ScrollViewReader { proxy in
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(viewModel.outputLines) { line in
                            Text(line.text)
                                .foregroundColor(line.type.color)
                                .font(.system(.body, design: .monospaced))
                                .textSelection(.enabled)
                        }
                    }
                    .onChange(of: viewModel.outputLines) {
                        proxy.scrollTo(viewModel.outputLines.last?.id)
                    }
                }
            }
            .padding()
            
            HStack {
                Text("$")
                    .foregroundColor(.green)
                    .font(.system(.body, design: .monospaced))
                
                TextField("Enter command...", text: $command, onCommit: {
                    if !command.isEmpty {
                        viewModel.executeCommand(command)
                        command = ""
                    }
                })
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(.body, design: .monospaced))
                .submitLabel(.go)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .preferredColorScheme(viewModel.settings.colorScheme.swiftUIScheme)
        .onAppear {
            viewModel.displayWelcomeMessage()
            // Настройка окна при появлении
            if let window = NSApplication.shared.windows.first {
                window.backgroundColor = .clear
                window.isOpaque = false
                window.titlebarAppearsTransparent = true
                window.styleMask.insert(.fullSizeContentView)
            }
        }
    }
}


