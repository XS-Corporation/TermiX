import Foundation
import Combine

class TerminalViewModel: ObservableObject {
    @Published var outputLines: [OutputLine] = []
    let settings = TerminalSettings.shared
    
    private var task: Process?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSettingsObserver()
    }
    
    func displayWelcomeMessage() {
        let asciiArt = """
        ░░░░░░░░░░░░░░░░
        ░░░█░░░░░░░░█░░░
        ░░░████░░░██░░░░
        ░░░░░░████░░░░░░
        ░░░░░░░████░░░░░
        ░░░░░██░░░██░░░░
        ░░░░██░░░░░█░░░░
        ░░░░█░░░░░░░░░░░
        ░░░░░░░░░░░░░░░░
        ░░░░░░░░░░░░░░░░
        """
        
        outputLines.append(OutputLine(text: asciiArt + "\nWelcome to TermiX! Current version - 1.0. Made by KickedStorm\n", type: .system))
    }
    
    func executeCommand(_ command: String) {
        outputLines.append(OutputLine(text: "$ \(command)\n", type: .command))
        
        let task = Process()
        let pipe = Pipe()
        
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.arguments = ["-c", command]
        task.standardOutput = pipe
        task.standardError = pipe
        
        task.environment = ProcessInfo.processInfo.environment
        
        let outputHandler = pipe.fileHandleForReading
        outputHandler.readabilityHandler = { [weak self] handle in
            guard let self = self else { return }
            let data = handle.availableData
            if let output = String(data: data, encoding: .utf8), !output.isEmpty {
                DispatchQueue.main.async {
                    self.outputLines.append(OutputLine(text: output, type: .output))
                }
            }
        }
        
        task.terminationHandler = { [weak self] _ in
            outputHandler.readabilityHandler = nil
            self?.task = nil
        }
        
        do {
            try task.run()
            self.task = task
        } catch {
            outputLines.append(OutputLine(text: "Error: \(error.localizedDescription)\n", type: .error))
        }
    }
    
    private func setupSettingsObserver() {
        NotificationCenter.default.publisher(for: TerminalSettings.settingsChangedNotification)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}



