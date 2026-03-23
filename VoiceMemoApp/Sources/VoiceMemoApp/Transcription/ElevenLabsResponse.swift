import Foundation

struct ElevenLabsResponse: Codable {
    let text: String?
    let transcription: Transcription?

    struct Transcription: Codable {
        let text: String?
    }

    var transcribedText: String? {
        text ?? transcription?.text
    }
}
