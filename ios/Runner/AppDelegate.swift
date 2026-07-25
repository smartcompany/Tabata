import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    NSLog("[ShareLink][iOS] didFinishLaunching")
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    GeneratedPluginRegistrant.register(with: self)

    // Activate WatchConnectivity before Flutter finishes booting so a Watch
    // `transferUserInfo(startRoutine)` can wake a terminated phone app.
    WatchSessionManager.shared.prepareAtLaunch()

    let finished = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    if let controller = window?.rootViewController as? FlutterViewController {
      WatchSessionManager.shared.configure(messenger: controller.binaryMessenger)
    } else {
      DispatchQueue.main.async {
        if let controller = self.window?.rootViewController as? FlutterViewController {
          WatchSessionManager.shared.configure(messenger: controller.binaryMessenger)
        }
      }
    }

    return finished
  }

  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    let url = userActivity.webpageURL?.absoluteString ?? "nil"
    NSLog("[ShareLink][iOS] continueUserActivity type=\(userActivity.activityType) url=\(url)")
    let handled = super.application(
      application,
      continue: userActivity,
      restorationHandler: restorationHandler
    )
    NSLog("[ShareLink][iOS] continueUserActivity superHandled=\(handled)")

    if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
      NSLog("[ShareLink][iOS] continueUserActivity force return true (browsing web)")
      return true
    }
    return handled
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    NSLog("[ShareLink][iOS] openURL url=\(url.absoluteString)")
    let handled = super.application(app, open: url, options: options)
    NSLog("[ShareLink][iOS] openURL superHandled=\(handled)")
    return handled
  }
}
