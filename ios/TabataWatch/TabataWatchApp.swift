import SwiftUI

@main
struct TabataWatchApp: App {
  @StateObject private var connectivity = WatchConnectivityService.shared

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(connectivity)
    }
  }
}
