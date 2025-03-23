import SwiftUI

struct TerminalView: View {
    @StateObject private var viewModel = TerminalViewModel()
    @State private var command: String = ""
    @State private var showingPathPicker = false
    @FocusState private var isInputFocused: Bool
    
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
                        Color.clear
                            .frame(height: 0)
                            .id("bottomMarker")
                    }
                    .onChange(of: viewModel.outputLines) { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            withAnimation {
                                proxy.scrollTo("bottomMarker", anchor: .bottom)
                            }
                        }
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {}
            }
            .padding()
            .scrollDisabled(true) // Отключаем ручную прокрутку
            
            if showingPathPicker {
                PathPickerView(
                    currentPath: viewModel.getPathForPicker(from: command),
                    onSelect: { path in
                        command = path
                        showingPathPicker = false
                        isInputFocused = true
                    }
                )
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.8))
                .cornerRadius(8)
                .padding(.horizontal)
            }
            
            HStack {
                Text(viewModel.currentDirectoryPrompt)
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
                .focused($isInputFocused)
                .onChange(of: command) { newValue in
                    showingPathPicker = newValue.contains("cd ") || newValue.hasPrefix("/") || newValue.contains("/")
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .preferredColorScheme(viewModel.settings.colorScheme.swiftUIScheme)
        .onAppear {
            viewModel.displayWelcomeMessage()
            if let window = NSApplication.shared.windows.first {
                window.backgroundColor = .clear
                window.isOpaque = false
                window.titlebarAppearsTransparent = true
                window.styleMask.insert(.fullSizeContentView)
            }
            isInputFocused = true
        }
        .sheet(isPresented: $viewModel.needsPassword) {
            PasswordPromptView(password: $viewModel.sudoPassword, onSubmit: {
                viewModel.executeSudoCommand()
            })
        }
        .onChange(of: TerminalDropDelegate.shared.droppedPath) { newPath in
            if let path = newPath {
                command += path + " "
                TerminalDropDelegate.shared.droppedPath = nil
                isInputFocused = true
            }
        }
    }
}




