import Foundation
import WatchConnectivity
import Flutter
import UIKit

/// Bridges Flutter MethodChannel `watch_workout` to WatchConnectivity.
final class WatchSessionManager: NSObject, WCSessionDelegate {
  static let shared = WatchSessionManager()
  static let channelName = "com.smartcompany.tabata/watch_workout"
  private static let pendingStartKey = "pendingWatchStartRoutineId"

  private var channel: FlutterMethodChannel?
  private var lastSnapshot: [String: Any] = [:]
  private var cachedRoutines: [[String: Any]] = []
  private var sessionActive = false
  private var startBackgroundTask: UIBackgroundTaskIdentifier = .invalid
  private var lastEmittedStartId: String?
  private var lastEmittedStartAt: Date?

  private override init() {
    super.init()
  }

  /// Activate WCSession before Flutter is ready so Watch `transferUserInfo`
  /// can wake a terminated app and deliver `startRoutine`.
  func prepareAtLaunch() {
    guard WCSession.isSupported() else { return }
    let session = WCSession.default
    session.delegate = self
    if session.activationState == .notActivated {
      session.activate()
    }
  }

  func configure(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: Self.channelName,
      binaryMessenger: messenger
    )
    channel?.setMethodCallHandler { [weak self] call, result in
      self?.handle(call: call, result: result)
    }

    prepareAtLaunch()
    flushPendingStartToFlutter()
  }

  private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isWatchSupported":
      result(WCSession.isSupported())
    case "isWatchReachable":
      guard WCSession.isSupported() else {
        result(false)
        return
      }
      let session = WCSession.default
      result(session.activationState == .activated && session.isReachable)
    case "isWatchPaired":
      guard WCSession.isSupported() else {
        result(false)
        return
      }
      result(WCSession.default.isPaired)
    case "consumePendingStartRoutine":
      let id = UserDefaults.standard.string(forKey: Self.pendingStartKey)
      UserDefaults.standard.removeObject(forKey: Self.pendingStartKey)
      result(id)
    case "syncSnapshot":
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "bad_args", message: "Expected map", details: nil))
        return
      }
      sessionActive = true
      lastSnapshot = args
      // Clear queued cold-start id so resume/consume won't relaunch.
      UserDefaults.standard.removeObject(forKey: Self.pendingStartKey)
      pushSnapshot(args)
      endStartBackgroundTask()
      result(nil)
    case "syncRoutineList":
      guard let args = call.arguments as? [String: Any],
            let routines = args["routines"] as? [[String: Any]] else {
        result(FlutterError(code: "bad_args", message: "Expected routines list", details: nil))
        return
      }
      cachedRoutines = routines
      pushRoutineList()
      result(nil)
    case "endSession":
      sessionActive = false
      lastEmittedStartId = nil
      lastEmittedStartAt = nil
      var endPayload = lastSnapshot
      endPayload["isCompleted"] = true
      endPayload["sessionActive"] = false
      endPayload["routines"] = cachedRoutines
      pushSnapshot(endPayload)
      lastSnapshot = [:]
      result(nil)
    case "notifyStartFailed":
      sessionActive = false
      pushStartFailed()
      endStartBackgroundTask()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func pushRoutineList() {
    pushIdleContextIfNeeded()
  }

  private func pushIdleContextIfNeeded() {
    guard WCSession.isSupported() else { return }
    let session = WCSession.default
    guard session.activationState == .activated else { return }

    var payload: [String: Any] = [
      "sessionActive": false,
      "isCompleted": false,
      "routines": cachedRoutines,
      "updatedAt": Date().timeIntervalSince1970,
    ]

    if sessionActive, !lastSnapshot.isEmpty {
      payload = lastSnapshot
      payload["sessionActive"] = true
      payload["routines"] = cachedRoutines
      payload["updatedAt"] = Date().timeIntervalSince1970
    }

    do {
      try session.updateApplicationContext(payload)
    } catch {
      NSLog("[WatchSession] updateApplicationContext failed: \(error.localizedDescription)")
    }

    if session.isReachable {
      session.sendMessage(payload, replyHandler: nil) { error in
        NSLog("[WatchSession] sendMessage failed: \(error.localizedDescription)")
      }
    }
  }

  private func pushSnapshot(_ snapshot: [String: Any]) {
    guard WCSession.isSupported() else { return }
    let session = WCSession.default
    guard session.activationState == .activated else { return }

    var payload = snapshot
    payload["sessionActive"] = sessionActive
    payload["updatedAt"] = Date().timeIntervalSince1970
    if !cachedRoutines.isEmpty {
      payload["routines"] = cachedRoutines
    }

    do {
      try session.updateApplicationContext(payload)
    } catch {
      NSLog("[WatchSession] updateApplicationContext failed: \(error.localizedDescription)")
    }

    if session.isReachable {
      session.sendMessage(payload, replyHandler: nil) { error in
        NSLog("[WatchSession] sendMessage failed: \(error.localizedDescription)")
      }
    }
  }

  private func pushStartFailed() {
    guard WCSession.isSupported() else { return }
    let session = WCSession.default
    guard session.activationState == .activated else { return }

    let payload: [String: Any] = [
      "startFailed": true,
      "sessionActive": false,
      "isCompleted": false,
      "routines": cachedRoutines,
      "updatedAt": Date().timeIntervalSince1970,
    ]

    do {
      try session.updateApplicationContext(payload)
    } catch {
      NSLog("[WatchSession] startFailed context failed: \(error.localizedDescription)")
    }
    if session.isReachable {
      session.sendMessage(payload, replyHandler: nil, errorHandler: nil)
    }
  }

  private func emitToFlutter(method: String, arguments: Any?) {
    DispatchQueue.main.async { [weak self] in
      self?.channel?.invokeMethod(method, arguments: arguments)
    }
  }

  private func persistPendingStart(routineId: String) {
    UserDefaults.standard.set(routineId, forKey: Self.pendingStartKey)
  }

  private func flushPendingStartToFlutter() {
    guard let routineId = UserDefaults.standard.string(forKey: Self.pendingStartKey),
          !routineId.isEmpty else { return }
    emitToFlutter(
      method: "watchCommand",
      arguments: ["command": "startRoutine", "routineId": routineId]
    )
  }

  private func beginStartBackgroundTask() {
    let start = { [weak self] in
      guard let self else { return }
      guard self.startBackgroundTask == .invalid else { return }
      self.startBackgroundTask = UIApplication.shared.beginBackgroundTask(
        withName: "watchStartRoutine"
      ) { [weak self] in
        self?.endStartBackgroundTask()
      }
    }
    if Thread.isMainThread {
      start()
    } else {
      DispatchQueue.main.async(execute: start)
    }
  }

  private func endStartBackgroundTask() {
    let end = { [weak self] in
      guard let self else { return }
      guard self.startBackgroundTask != .invalid else { return }
      UIApplication.shared.endBackgroundTask(self.startBackgroundTask)
      self.startBackgroundTask = .invalid
    }
    if Thread.isMainThread {
      end()
    } else {
      DispatchQueue.main.async(execute: end)
    }
  }

  // MARK: - WCSessionDelegate

  func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {
    if let error {
      NSLog("[WatchSession] activation error: \(error.localizedDescription)")
    }
    if sessionActive, !lastSnapshot.isEmpty {
      pushSnapshot(lastSnapshot)
    } else if !cachedRoutines.isEmpty {
      pushIdleContextIfNeeded()
    }
    flushPendingStartToFlutter()
  }

  func sessionDidBecomeInactive(_ session: WCSession) {}

  func sessionDidDeactivate(_ session: WCSession) {
    session.activate()
  }

  func sessionReachabilityDidChange(_ session: WCSession) {
    emitToFlutter(
      method: "watchReachability",
      arguments: ["reachable": session.isReachable, "paired": session.isPaired]
    )
    if session.isReachable, sessionActive, !lastSnapshot.isEmpty {
      pushSnapshot(lastSnapshot)
    } else if session.isReachable, !sessionActive {
      pushIdleContextIfNeeded()
    }
  }

  func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
    handleWatchMessage(message)
  }

  func session(
    _ session: WCSession,
    didReceiveMessage message: [String: Any],
    replyHandler: @escaping ([String: Any]) -> Void
  ) {
    handleWatchMessage(message)
    replyHandler(["ok": true])
  }

  func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
    handleWatchMessage(userInfo)
  }

  private func handleWatchMessage(_ message: [String: Any]) {
    if let command = message["command"] as? String {
      if command == "requestRoutines" {
        emitToFlutter(method: "requestRoutines", arguments: nil)
        // Avoid overwriting an in-progress start with an idle context.
        if !sessionActive {
          pushIdleContextIfNeeded()
        }
        return
      }
      if command == "startRoutine",
         let routineId = message["routineId"] as? String,
         !routineId.isEmpty {
        let now = Date()
        if lastEmittedStartId == routineId,
           let at = lastEmittedStartAt,
           now.timeIntervalSince(at) < 2.5 {
          NSLog("[WatchSession] ignore duplicate startRoutine id=\(routineId)")
          return
        }
        lastEmittedStartId = routineId
        lastEmittedStartAt = now
        NSLog("[WatchSession] received startRoutine id=\(routineId)")
        // Persist first so a cold-started Flutter engine can pick it up.
        persistPendingStart(routineId: routineId)
        beginStartBackgroundTask()
      }
      var args: [String: Any] = ["command": command]
      if let routineId = message["routineId"] as? String {
        args["routineId"] = routineId
      }
      emitToFlutter(method: "watchCommand", arguments: args)
      return
    }
    if let bpm = message["heartRate"] as? Double {
      var args: [String: Any] = ["bpm": bpm]
      if let avg = message["avgBpm"] as? Double { args["avgBpm"] = avg }
      if let max = message["maxBpm"] as? Double { args["maxBpm"] = max }
      emitToFlutter(method: "heartRate", arguments: args)
    }
  }
}
