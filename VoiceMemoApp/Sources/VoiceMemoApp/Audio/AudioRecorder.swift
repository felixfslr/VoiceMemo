import AVFoundation
import Foundation

final class AudioRecorder: ObservableObject {
    @Published var isRecording = false

    private var recorder: AVAudioRecorder?
    private var recordingURL: URL?

    func startRecording() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder?.record()
        recordingURL = url
        isRecording = true
    }

    func stopRecording() -> URL? {
        recorder?.stop()
        recorder = nil
        isRecording = false
        return recordingURL
    }

    func cleanup() {
        guard let url = recordingURL else { return }
        try? FileManager.default.removeItem(at: url)
        recordingURL = nil
    }
}
