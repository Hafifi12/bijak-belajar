import AVFoundation
import AudioToolbox
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let speechSynthesizer = AVSpeechSynthesizer()
  private var correctPlayer: AVAudioPlayer?
  private var wrongPlayer: AVAudioPlayer?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "tiny_finder/tts",
        binaryMessenger: controller.binaryMessenger
      )

      channel.setMethodCallHandler { [weak self] call, result in
        switch call.method {
        case "speak":
          guard
            let arguments = call.arguments as? [String: Any],
            let text = arguments["text"] as? String
          else {
            result(nil)
            return
          }
          let locale = arguments["locale"] as? String ?? "en-US"
          self?.speak(text: text, locale: locale)
          result(nil)

        case "playEffect":
          let name = (call.arguments as? [String: Any])?["name"] as? String ?? "correct"
          self?.playEffect(name: name)
          result(nil)

        case "stop":
          self?.speechSynthesizer.stopSpeaking(at: .immediate)
          result(nil)

        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func speak(text: String, locale: String) {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return }

    speechSynthesizer.stopSpeaking(at: .immediate)

    let utterance = AVSpeechUtterance(string: trimmed)
    utterance.voice = AVSpeechSynthesisVoice(language: locale)
    // Slow, clear rate — like a kind kindergarten teacher reading aloud
    utterance.rate = 0.36
    // Bright, warm, child-friendly pitch (1.0 = normal adult, 1.3 = cheerful teacher)
    utterance.pitchMultiplier = 1.28
    // Full volume
    utterance.volume = 1.0
    // Small pause before speaking — feels more natural and engaging for kids
    utterance.preUtteranceDelay = 0.12
    speechSynthesizer.speak(utterance)
  }

  private func playEffect(name: String) {
    if name == "correct" {
      // Cheerful rising chime — system sound 1057 (Tink) feels rewarding for kids
      AudioServicesPlaySystemSound(1057)
      // Second chime slightly delayed for a "clap clap" feel
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
        AudioServicesPlaySystemSound(1057)
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.34) {
        AudioServicesPlaySystemSound(1057)
      }
    } else {
      // Soft low buzz for wrong — not scary, just a gentle nudge
      AudioServicesPlaySystemSound(1053)
    }
  }
}
