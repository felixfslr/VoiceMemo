import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleRecording = Self("toggleRecording", default: .init(.r, modifiers: [.command, .shift]))
}

final class SettingsManager: ObservableObject {
    var apiKey: String {
        get { UserDefaults.standard.string(forKey: "elevenlabsApiKey") ?? "" }
        set {
            UserDefaults.standard.set(newValue.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "elevenlabsApiKey")
            objectWillChange.send()
        }
    }

    var languageCode: String {
        get { UserDefaults.standard.string(forKey: "languageCode") ?? "de" }
        set {
            UserDefaults.standard.set(newValue, forKey: "languageCode")
            objectWillChange.send()
        }
    }
}
