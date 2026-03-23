import KeyboardShortcuts
import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: SettingsManager

    var body: some View {
        Form {
            Section("API-Konfiguration") {
                SecureField("ElevenLabs API Key", text: $settings.apiKey)
                    .textFieldStyle(.roundedBorder)
            }

            Section("Hotkey") {
                KeyboardShortcuts.Recorder("Aufnahme starten/stoppen:", name: .toggleRecording)
            }

            Section("Transkription") {
                Picker("Sprache", selection: $settings.languageCode) {
                    Text("Deutsch").tag("de")
                    Text("English").tag("en")
                    Text("Français").tag("fr")
                    Text("Español").tag("es")
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 280)
    }
}
