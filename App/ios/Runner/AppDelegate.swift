import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var screenCaptureEventChannel: FlutterEventChannel?
  private var screenCaptureStreamHandler: ScreenCaptureStreamHandler?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Setup screen capture detection EventChannel
    if let controller = window?.rootViewController as? FlutterViewController {
      screenCaptureStreamHandler = ScreenCaptureStreamHandler()
      screenCaptureEventChannel = FlutterEventChannel(
        name: "com.novelpop.app/screen_capture",
        binaryMessenger: controller.binaryMessenger
      )
      screenCaptureEventChannel?.setStreamHandler(screenCaptureStreamHandler)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// MARK: - Screen Capture Stream Handler
class ScreenCaptureStreamHandler: NSObject, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events

    // Listen for screenshot notifications
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(userDidTakeScreenshot),
      name: UIApplication.userDidTakeScreenshotNotification,
      object: nil
    )

    // Listen for screen recording changes (iOS 11+)
    if #available(iOS 11.0, *) {
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(screenCapturedDidChange),
        name: UIScreen.capturedDidChangeNotification,
        object: nil
      )

      // Check initial state
      if UIScreen.main.isCaptured {
        events("recording_started")
      }
    }

    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    NotificationCenter.default.removeObserver(self)
    eventSink = nil
    return nil
  }

  @objc private func userDidTakeScreenshot() {
    eventSink?("screenshot")
  }

  @objc private func screenCapturedDidChange() {
    if #available(iOS 11.0, *) {
      if UIScreen.main.isCaptured {
        eventSink?("recording_started")
      } else {
        eventSink?("recording_stopped")
      }
    }
  }
}
