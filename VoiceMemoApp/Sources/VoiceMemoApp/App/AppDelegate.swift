import AppKit
import KeyboardShortcuts
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    let menuBarManager = MenuBarManager()
    let audioRecorder = AudioRecorder()
    let settings = SettingsManager()
    private var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        menuBarManager.configure(
            onToggleRecording: { [weak self] in self?.toggleRecording() },
            onOpenSettings: { [weak self] in self?.openSettings() }
        )

        KeyboardShortcuts.onKeyDown(for: .toggleRecording) { [weak self] in
            self?.toggleRecording()
        }
    }

    func toggleRecording() {
        if audioRecorder.isRecording {
            stopRecordingAndTranscribe()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        do {
            try audioRecorder.startRecording()
            menuBarManager.setState(.recording)
        } catch {
            showAlert(title: "Fehler", message: "Aufnahme konnte nicht gestartet werden: \(error.localizedDescription)")
        }
    }

    private func stopRecordingAndTranscribe() {
        guard let fileURL = audioRecorder.stopRecording() else {
            menuBarManager.setState(.idle)
            return
        }
        menuBarManager.setState(.processing)

        let apiKey = settings.apiKey
        let language = settings.languageCode

        guard !apiKey.isEmpty else {
            showAlert(title: "Fehler", message: "Kein API Key konfiguriert. Bitte in den Einstellungen hinterlegen.")
            menuBarManager.setState(.idle)
            audioRecorder.cleanup()
            return
        }

        Task {
            do {
                let text = try await TranscriptionService.transcribe(
                    audioFileURL: fileURL,
                    apiKey: apiKey,
                    languageCode: language
                )
                await MainActor.run {
                    ClipboardManager.copy(text)
                    menuBarManager.setState(.idle)
                    NSSound.beep()
                }
            } catch {
                await MainActor.run {
                    menuBarManager.setState(.idle)
                    showAlert(title: "Fehler", message: error.localizedDescription)
                }
            }
            audioRecorder.cleanup()
        }
    }

    private func openSettings() {
        // Temporarily become a regular app so the window can receive keyboard focus
        NSApp.setActivationPolicy(.regular)

        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 280),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "VoiceMemo – Einstellungen"
        window.contentView = NSHostingView(rootView: SettingsView(settings: settings))
        window.center()
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow = window
    }

    func windowWillClose(_ notification: Notification) {
        // Revert to accessory app (no dock icon) when settings window closes
        NSApp.setActivationPolicy(.accessory)
    }

    private func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.runModal()
    }
}
