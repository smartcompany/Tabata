import SwiftUI

@main
struct TabataWatchApp: App {
  @StateObject private var connectivity = WatchConnectivityService.shared

  init() {
    let args = ProcessInfo.processInfo.arguments
    if args.contains("-demoIdle") {
      WatchConnectivityService.shared.applyScreenshotDemo("idle")
    } else if args.contains("-demoWorkout") {
      WatchConnectivityService.shared.applyScreenshotDemo("workout")
    } else if args.contains("-demoDone") {
      WatchConnectivityService.shared.applyScreenshotDemo("done")
    }
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(connectivity)
    }
  }
}
