import Foundation
import Combine

class TerminalViewModel: ObservableObject {
    @Published var outputLines: [OutputLine] = []
    @Published var needsPassword = false
    @Published var sudoPassword = ""
    @Published var currentDirectory = FileManager.default.currentDirectoryPath {
        didSet {
            currentDirectoryPrompt = "\(URL(fileURLWithPath: currentDirectory).lastPathComponent) $ "
        }
    }
    @Published var currentDirectoryPrompt = "\(URL(fileURLWithPath: FileManager.default.currentDirectoryPath).lastPathComponent) $ "
    
    let settings = TerminalSettings.shared
    private var task: Process?
    private var cancellables = Set<AnyCancellable>()
    private var pendingSudoCommand: String?
    
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
        outputLines.append(OutputLine(text: asciiArt + "\nWelcome to TermiX! Current version - 2.0. Made by KickedStorm\n", type: .system))
    }
    
    func executeCommand(_ command: String) {
        if command.trimmingCharacters(in: .whitespaces).hasPrefix("cd ") {
            let path = command.replacingOccurrences(of: "cd ", with: "").trimmingCharacters(in: .whitespaces)
            changeDirectory(to: path)
            return
        }
        
        if command.contains("sudo") {
            pendingSudoCommand = command
            needsPassword = true
            return
        }
        
        runCommand(command)
    }
    
    func executeSudoCommand() {
        guard let sudoCommand = pendingSudoCommand else { return }
        let fullCommand = "echo \(sudoPassword) | sudo -S \(sudoCommand)"
        runCommand(fullCommand)
        sudoPassword = ""
        needsPassword = false
        pendingSudoCommand = nil
    }
    
    private func runCommand(_ command: String) {
        outputLines.append(OutputLine(text: "\(currentDirectoryPrompt)\(command)\n", type: .command))
        
        let task = Process()
        let pipe = Pipe()
        
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.arguments = ["-c", "cd \(currentDirectory) && \(command)"]
        task.standardOutput = pipe
        task.standardError = pipe
        task.environment = ProcessInfo.processInfo.environment
        
        let outputHandler = pipe.fileHandleForReading
        outputHandler.readabilityHandler = { [weak self] handle in
            guard let self = self else { return }
            let data = handle.availableData
            if let output = String(data: data, encoding: .utf8), !output.isEmpty {
                DispatchQueue.main.async {
                    self.outputLines.append(OutputLine(text: output, type: output.contains("error") ? .error : .output))
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
    
    private func changeDirectory(to path: String) {
        let newPath = path.hasPrefix("/") ? path : "\(currentDirectory)/\(path)"
        if FileManager.default.fileExists(atPath: newPath) {
            currentDirectory = newPath
        } else {
            outputLines.append(OutputLine(text: "cd: no such file or directory: \(path)\n", type: .error))
        }
    }
    
    func getPathForPicker(from command: String) -> String {
        if command.hasPrefix("/") || command.contains("/") {
            let components = command.split(separator: "/")
            if components.isEmpty { return "/" }
            let path = "/" + components.dropLast().joined(separator: "/")
            return FileManager.default.fileExists(atPath: path) ? path : currentDirectory
        } else if command.contains("cd ") {
            let path = command.replacingOccurrences(of: "cd ", with: "").trimmingCharacters(in: .whitespaces)
            return path.isEmpty ? currentDirectory : (path.hasPrefix("/") ? path : "\(currentDirectory)/\(path)")
        }
        return currentDirectory
    }
    
    private func setupSettingsObserver() {
        NotificationCenter.default.publisher(for: TerminalSettings.settingsChangedNotification)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}




