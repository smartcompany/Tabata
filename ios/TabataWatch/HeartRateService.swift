import Foundation
import HealthKit

final class HeartRateService: NSObject {
  static let shared = HeartRateService()

  private let healthStore = HKHealthStore()
  private var session: HKWorkoutSession?
  private var builder: HKLiveWorkoutBuilder?
  private var started = false
  private var samples: [Double] = []

  private override init() {
    super.init()
  }

  func startIfNeeded(activityType: String?) {
    guard HKHealthStore.isHealthDataAvailable() else { return }
    if started { return }

    let heartType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    let types: Set<HKSampleType> = [heartType, HKObjectType.workoutType()]
    healthStore.requestAuthorization(toShare: [HKObjectType.workoutType()], read: types) {
      [weak self] success, _ in
      guard success else { return }
      DispatchQueue.main.async {
        self?.beginSession(activityType: activityType)
      }
    }
  }

  private func beginSession(activityType: String?) {
    guard !started else { return }
    let config = HKWorkoutConfiguration()
    config.activityType = mapActivity(activityType)
    config.locationType = .indoor

    do {
      let session = try HKWorkoutSession(healthStore: healthStore, configuration: config)
      let builder = session.associatedWorkoutBuilder()
      builder.dataSource = HKLiveWorkoutDataSource(
        healthStore: healthStore,
        workoutConfiguration: config
      )
      session.delegate = self
      builder.delegate = self
      self.session = session
      self.builder = builder
      session.startActivity(with: Date())
      builder.beginCollection(withStart: Date()) { _, _ in }
      started = true
      samples = []
    } catch {
      NSLog("[TabataWatch] HKWorkoutSession failed: \(error.localizedDescription)")
    }
  }

  func stop() {
    guard started else { return }
    session?.end()
    builder?.endCollection(withEnd: Date()) { [weak self] _, _ in
      // Do not finish/save workout to Health — phone owns Health write.
      self?.builder?.discardWorkout()
      self?.session = nil
      self?.builder = nil
      self?.started = false
      self?.samples = []
    }
  }

  private func mapActivity(_ raw: String?) -> HKWorkoutActivityType {
    switch raw {
    case "traditionalStrengthTraining": return .traditionalStrengthTraining
    case "functionalStrengthTraining": return .functionalStrengthTraining
    case "highIntensityIntervalTraining": return .highIntensityIntervalTraining
    case "yoga": return .yoga
    case "flexibility": return .flexibility
    case "coreTraining": return .coreTraining
    case "walking": return .walking
    case "running": return .running
    case "cycling": return .cycling
    default: return .traditionalStrengthTraining
    }
  }

  private func publish(bpm: Double) {
    samples.append(bpm)
    let avg = samples.reduce(0, +) / Double(samples.count)
    let maxBpm = samples.max() ?? bpm
    DispatchQueue.main.async {
      WatchConnectivityService.shared.heartRateBpm = bpm
      WatchConnectivityService.shared.avgBpm = avg
      WatchConnectivityService.shared.maxBpm = maxBpm
    }
    WatchConnectivityService.shared.sendHeartRate(bpm: bpm, avgBpm: avg, maxBpm: maxBpm)
  }
}

extension HeartRateService: HKWorkoutSessionDelegate {
  func workoutSession(
    _ workoutSession: HKWorkoutSession,
    didChangeTo toState: HKWorkoutSessionState,
    from fromState: HKWorkoutSessionState,
    date: Date
  ) {}

  func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
    NSLog("[TabataWatch] workout session error: \(error.localizedDescription)")
  }
}

extension HeartRateService: HKLiveWorkoutBuilderDelegate {
  func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}

  func workoutBuilder(
    _ workoutBuilder: HKLiveWorkoutBuilder,
    didCollectDataOf collectedTypes: Set<HKSampleType>
  ) {
    guard let heartType = HKQuantityType.quantityType(forIdentifier: .heartRate),
          collectedTypes.contains(heartType),
          let statistics = workoutBuilder.statistics(for: heartType),
          let quantity = statistics.mostRecentQuantity()
    else { return }
    let bpm = quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
    publish(bpm: bpm)
  }
}
