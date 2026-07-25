import Combine
import Foundation
import WatchConnectivity
import WatchKit

struct WatchRoutineItem: Identifiable, Equatable {
  let id: String
  let title: String
}

final class WatchConnectivityService: NSObject, ObservableObject {
  static let shared = WatchConnectivityService()

  @Published var sessionActive = false
  @Published var phaseKind = ""
  @Published var label = ""
  @Published var remainingSec = 0
  @Published var exerciseName = ""
  @Published var setIndex = 1
  @Published var repIndex = 1
  @Published var totalSets = 1
  @Published var totalReps = 1
  @Published var isPaused = false
  @Published var isCompleted = false
  @Published var routineTitle = ""
  @Published var heartRateBpm: Double = 0
  @Published var avgBpm: Double = 0
  @Published var maxBpm: Double = 0
  @Published var routines: [WatchRoutineItem] = []
  @Published var isStarting = false
  @Published var routinesLoaded = false
  @Published var startError: String?

  /// When set, ignore WCSession updates so App Store screenshot demos stay stable.
  private(set) var screenshotDemoMode: String?

  private var lastPhaseKind = ""
  private var lastRemainingSec = -1
  private var startTimeoutWork: DispatchWorkItem?

  private override init() {
    super.init()
    guard WCSession.isSupported() else { return }
    let session = WCSession.default
    session.delegate = self
    session.activate()
  }

  func sendCommand(_ command: String) {
    sendPayload(["command": command])

    // End must clear Watch UI immediately — phone pop can be deferred while
    // the iPhone app is backgrounded.
    if command == "end" {
      applyLocalEnd()
    }
  }

  func startRoutine(id: String) {
    isStarting = true
    isCompleted = false
    startError = nil
    scheduleStartTimeout()

    let payload: [String: Any] = [
      "command": "startRoutine",
      "routineId": id,
    ]
    guard WCSession.isSupported() else { return }
    let session = WCSession.default

    // Send once: live message when reachable, otherwise queued transfer.
    // Sending both caused the phone to start the same routine ~3 times.
    if session.isReachable {
      session.sendMessage(payload, replyHandler: { _ in
        NSLog("[TabataWatch] startRoutine acknowledged by phone")
      }) { error in
        NSLog("[TabataWatch] startRoutine send failed: \(error.localizedDescription)")
        WCSession.default.transferUserInfo(payload)
      }
    } else {
      session.transferUserInfo(payload)
    }
  }

  private func scheduleStartTimeout() {
    startTimeoutWork?.cancel()
    let work = DispatchWorkItem { [weak self] in
      guard let self else { return }
      guard self.isStarting, !self.sessionActive else { return }
      self.isStarting = false
      self.startError = String(localized: "start_failed")
    }
    startTimeoutWork = work
    DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: work)
  }

  private func clearStartingState() {
    startTimeoutWork?.cancel()
    startTimeoutWork = nil
    isStarting = false
    startError = nil
  }

  func requestRoutines() {
    if screenshotDemoMode != nil { return }
    sendPayload(["command": "requestRoutines"])
  }

  func dismissCompleted() {
    isCompleted = false
    sessionActive = false
    clearStartingState()
  }

  /// Simulator / App Store screenshot demos via launch args:
  /// `-demoIdle` or `-demoWorkout`
  func applyScreenshotDemo(_ mode: String) {
    screenshotDemoMode = mode
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      self.clearStartingState()
      self.startError = nil
      switch mode {
      case "idle":
        self.sessionActive = false
        self.isCompleted = false
        self.routinesLoaded = true
        self.routines = [
          WatchRoutineItem(id: "1", title: String(localized: "demo_routine_rehab")),
          WatchRoutineItem(id: "2", title: String(localized: "demo_routine_warmup")),
          WatchRoutineItem(id: "3", title: String(localized: "demo_routine_tabata")),
        ]
      case "workout":
        self.sessionActive = true
        self.isCompleted = false
        self.isPaused = false
        self.phaseKind = "work"
        let squat = String(localized: "demo_exercise_squat")
        self.label = squat
        self.exerciseName = squat
        self.remainingSec = 20
        self.setIndex = 1
        self.repIndex = 2
        self.totalSets = 3
        self.totalReps = 8
        self.heartRateBpm = 128
        self.routineTitle = String(localized: "demo_routine_tabata")
      case "done":
        self.sessionActive = false
        self.isCompleted = true
        self.avgBpm = 118
        self.maxBpm = 142
      default:
        break
      }
    }
  }

  private func sendPayload(_ payload: [String: Any]) {
    guard WCSession.isSupported() else { return }
    let session = WCSession.default

    // Phone in background often reports reachable but sendMessage fails.
    // Fall back to transferUserInfo so the command is still delivered.
    if session.isReachable {
      session.sendMessage(payload, replyHandler: nil) { error in
        NSLog("[TabataWatch] command send failed: \(error.localizedDescription)")
        WCSession.default.transferUserInfo(payload)
      }
    } else {
      session.transferUserInfo(payload)
    }
  }

  private func applyLocalEnd() {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      self.sessionActive = false
      self.isCompleted = true
      self.isPaused = false
      self.clearStartingState()
      HeartRateService.shared.stop()
    }
  }

  func sendHeartRate(bpm: Double, avgBpm: Double, maxBpm: Double) {
    guard WCSession.isSupported() else { return }
    let session = WCSession.default
    let payload: [String: Any] = [
      "heartRate": bpm,
      "avgBpm": avgBpm,
      "maxBpm": maxBpm,
    ]
    if session.isReachable {
      session.sendMessage(payload, replyHandler: nil, errorHandler: nil)
    }
  }

  func apply(context: [String: Any]) {
    if screenshotDemoMode != nil { return }
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      let previousKind = self.phaseKind
      let previousRemaining = self.remainingSec

      if let routineRows = context["routines"] as? [[String: Any]] {
        self.routines = routineRows.compactMap { row in
          guard let id = row["id"] as? String else { return nil }
          let rawTitle = row["title"] as? String
          let trimmed = rawTitle?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
          return WatchRoutineItem(
            id: id,
            title: trimmed.isEmpty ? "루틴" : trimmed
          )
        }
        self.routinesLoaded = true
      }

      if (context["startFailed"] as? Bool) == true {
        self.clearStartingState()
        self.sessionActive = false
        self.isCompleted = false
        self.startError = String(localized: "start_failed")
        HeartRateService.shared.stop()
        return
      }

      // Snapshot messages without session keys should not wipe idle state.
      // While starting, ignore idle list-only pushes that would keep us stuck.
      let hasSessionKeys = context["sessionActive"] != nil || context["phaseKind"] != nil
      if hasSessionKeys {
        let nextActive = (context["sessionActive"] as? Bool) ?? false
        if self.isStarting && !nextActive && context["phaseKind"] == nil {
          // Likely a routine-list refresh — keep waiting for the real start.
          return
        }

        self.sessionActive = nextActive
        self.phaseKind = (context["phaseKind"] as? String) ?? ""
        self.label = (context["label"] as? String) ?? ""
        self.remainingSec = (context["remainingSec"] as? Int)
          ?? Int((context["remainingSec"] as? Double) ?? 0)
        self.exerciseName = (context["exerciseName"] as? String) ?? ""
        self.setIndex = (context["setIndex"] as? Int)
          ?? Int((context["setIndex"] as? Double) ?? 1)
        self.repIndex = (context["repIndex"] as? Int)
          ?? Int((context["repIndex"] as? Double) ?? 1)
        self.totalSets = (context["totalSets"] as? Int)
          ?? Int((context["totalSets"] as? Double) ?? 1)
        self.totalReps = (context["totalReps"] as? Int)
          ?? Int((context["totalReps"] as? Double) ?? 1)
        self.isPaused = (context["isPaused"] as? Bool) ?? false
        self.isCompleted = (context["isCompleted"] as? Bool) ?? false
        self.routineTitle = (context["routineTitle"] as? String) ?? ""

        if self.sessionActive {
          self.clearStartingState()
        }
      }

      self.playHapticsIfNeeded(
        previousKind: previousKind,
        previousRemaining: previousRemaining
      )

      if self.sessionActive && !self.isCompleted {
        HeartRateService.shared.startIfNeeded(
          activityType: context["healthActivityType"] as? String
        )
      } else {
        HeartRateService.shared.stop()
      }
    }
  }

  private func playHapticsIfNeeded(previousKind: String, previousRemaining: Int) {
    if sessionActive, phaseKind != previousKind, !phaseKind.isEmpty {
      WKInterfaceDevice.current().play(.notification)
      return
    }
    if sessionActive, !isPaused, remainingSec != previousRemaining,
       remainingSec >= 1, remainingSec <= 3 {
      WKInterfaceDevice.current().play(.click)
    }
  }
}

extension WatchConnectivityService: WCSessionDelegate {
  func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {
    let context = session.receivedApplicationContext
    if !context.isEmpty {
      apply(context: context)
    }
    requestRoutines()
  }

  func session(
    _ session: WCSession,
    didReceiveApplicationContext applicationContext: [String: Any]
  ) {
    apply(context: applicationContext)
  }

  func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
    apply(context: message)
  }

  func session(
    _ session: WCSession,
    didReceiveUserInfo userInfo: [String: Any] = [:]
  ) {
    if let command = userInfo["command"] as? String {
      // Phone-originated userInfo is unusual; ignore.
      _ = command
    } else {
      apply(context: userInfo)
    }
  }
}
