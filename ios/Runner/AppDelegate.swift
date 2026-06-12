import Flutter
import UIKit

// UIScene lifecycle (required by Apple after iOS 26):
//  * Plugin registration moved from application:didFinishLaunchingWithOptions:
//    to didInitializeImplicitFlutterEngine (FlutterImplicitEngineDelegate).
//  * The old "tiny_finder/tts" method channel block was removed — the Dart
//    side migrated to the flutter_tts plugin long ago, and under UIScene the
//    window/rootViewController is nil at launch so that code could never run.
@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
