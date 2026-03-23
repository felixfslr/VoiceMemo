import AppKit

enum RecordingState {
    case idle
    case recording
    case processing
}

final class MenuBarManager {
    private let statusItem: NSStatusItem
    private var onToggleRecording: (() -> Void)?
    private var onOpenSettings: (() -> Void)?
    private var currentState: RecordingState = .idle

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        updateIcon(for: .idle)
        buildMenu()
    }

    func configure(onToggleRecording: @escaping () -> Void, onOpenSettings: @escaping () -> Void) {
        self.onToggleRecording = onToggleRecording
        self.onOpenSettings = onOpenSettings
        buildMenu()
    }

    func setState(_ state: RecordingState) {
        currentState = state
        updateIcon(for: state)
        buildMenu()
    }

    private func updateIcon(for state: RecordingState) {
        guard let button = statusItem.button else { return }
        let symbolName: String
        switch state {
        case .idle:
            symbolName = "mic"
        case .recording:
            symbolName = "mic.fill"
        case .processing:
            symbolName = "ellipsis.circle"
        }
        let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "VoiceMemo")
        image?.isTemplate = state != .recording
        if state == .recording {
            let config = NSImage.SymbolConfiguration(paletteColors: [.systemRed])
            button.image = image?.withSymbolConfiguration(config)
        } else {
            button.image = image
        }
    }

    private func buildMenu() {
        let menu = NSMenu()

        let recordTitle: String
        switch currentState {
        case .idle:
            recordTitle = "Aufnahme starten"
        case .recording:
            recordTitle = "Aufnahme stoppen"
        case .processing:
            recordTitle = "Transkribiere..."
        }
        let recordItem = NSMenuItem(title: recordTitle, action: #selector(toggleRecordingAction), keyEquivalent: "")
        recordItem.target = self
        recordItem.isEnabled = currentState != .processing
        menu.addItem(recordItem)

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: "Einstellungen...", action: #selector(openSettingsAction), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Beenden", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc private func toggleRecordingAction() {
        onToggleRecording?()
    }

    @objc private func openSettingsAction() {
        onOpenSettings?()
    }
}
