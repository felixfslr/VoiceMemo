import Foundation

enum TranscriptionError: LocalizedError {
    case noAPIKey
    case requestFailed(statusCode: Int)
    case noTranscriptionText

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "Kein API Key konfiguriert. Bitte in den Einstellungen hinterlegen."
        case .requestFailed(let code):
            return "Transkription fehlgeschlagen (HTTP \(code))."
        case .noTranscriptionText:
            return "Keine Transkription in der Antwort erhalten."
        }
    }
}

enum TranscriptionService {
    static func transcribe(audioFileURL: URL, apiKey: String, languageCode: String) async throws -> String {
        let url = URL(string: "https://api.elevenlabs.io/v1/speech-to-text")!
        let boundary = UUID().uuidString

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        request.timeoutInterval = 60

        let audioData = try Data(contentsOf: audioFileURL)
        var body = Data()

        body.appendFormField(boundary: boundary, name: "file", filename: "recording.m4a", mimeType: "audio/m4a", data: audioData)
        body.appendFormField(boundary: boundary, name: "model_id", value: "scribe_v2")
        body.appendFormField(boundary: boundary, name: "language_code", value: languageCode)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TranscriptionError.requestFailed(statusCode: 0)
        }
        guard httpResponse.statusCode == 200 else {
            throw TranscriptionError.requestFailed(statusCode: httpResponse.statusCode)
        }

        let result = try JSONDecoder().decode(ElevenLabsResponse.self, from: data)
        guard let text = result.transcribedText, !text.isEmpty else {
            throw TranscriptionError.noTranscriptionText
        }
        return text
    }
}

private extension Data {
    mutating func appendFormField(boundary: String, name: String, filename: String, mimeType: String, data: Data) {
        append("--\(boundary)\r\n".data(using: .utf8)!)
        append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        append(data)
        append("\r\n".data(using: .utf8)!)
    }

    mutating func appendFormField(boundary: String, name: String, value: String) {
        append("--\(boundary)\r\n".data(using: .utf8)!)
        append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
        append("\(value)\r\n".data(using: .utf8)!)
    }
}
