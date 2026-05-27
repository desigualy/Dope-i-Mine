import Flutter
import AVFoundation
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var cachedAudioPlayer: AVAudioPlayer?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as? FlutterViewController
    if let controller = controller {
      let channel = FlutterMethodChannel(
        name: "dope_i_mine/cached_audio",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { [weak self] call, result in
        switch call.method {
        case "playFile":
          guard
            let arguments = call.arguments as? [String: Any],
            let path = arguments["path"] as? String,
            !path.isEmpty
          else {
            result(FlutterError(
              code: "missing_path",
              message: "Audio file path is required.",
              details: nil
            ))
            return
          }

          do {
            self?.cachedAudioPlayer?.stop()
            self?.cachedAudioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            self?.cachedAudioPlayer?.prepareToPlay()
            self?.cachedAudioPlayer?.play()
            result(nil)
          } catch {
            result(FlutterError(
              code: "playback_failed",
              message: error.localizedDescription,
              details: nil
            ))
          }
        case "stop":
          self?.cachedAudioPlayer?.stop()
          self?.cachedAudioPlayer = nil
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
