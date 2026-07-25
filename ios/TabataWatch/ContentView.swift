import SwiftUI
import WatchKit

struct ContentView: View {
  @EnvironmentObject private var connectivity: WatchConnectivityService
  @State private var confirmEnd = false

  var body: some View {
    Group {
      if connectivity.sessionActive && !connectivity.isCompleted {
        activeWorkoutView
      } else if connectivity.isStarting {
        startingView
      } else if connectivity.isCompleted {
        completedView
      } else {
        idleView
      }
    }
    .onAppear {
      if !connectivity.sessionActive {
        connectivity.requestRoutines()
      }
    }
  }

  private var idleView: some View {
    Group {
      if !connectivity.routinesLoaded {
        VStack(spacing: 8) {
          ProgressView()
          Text("루틴 불러오는 중…")
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding()
      } else if connectivity.routines.isEmpty {
        VStack(spacing: 8) {
          Image(systemName: "iphone")
            .font(.title2)
          Text("iPhone에서 루틴을 추가하세요")
            .multilineTextAlignment(.center)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
      } else {
        VStack(spacing: 0) {
          if let error = connectivity.startError {
            Text(error)
              .font(.caption2)
              .foregroundStyle(.red)
              .multilineTextAlignment(.center)
              .padding(.horizontal, 8)
              .padding(.bottom, 4)
          }
          List {
            Section {
              ForEach(connectivity.routines) { routine in
                Button {
                  connectivity.startRoutine(id: routine.id)
                } label: {
                  Text(routine.title)
                    .font(.caption.weight(.semibold))
                    .lineLimit(2)
                }
              }
            } header: {
              Text("내 루틴")
            }
          }
        }
      }
    }
  }

  private var startingView: some View {
    VStack(spacing: 8) {
      ProgressView()
      Text("시작하는 중…")
        .font(.caption)
        .foregroundStyle(.secondary)
      Button("취소") {
        connectivity.dismissCompleted()
        connectivity.startError = nil
        connectivity.isStarting = false
      }
      .font(.caption2)
    }
    .padding()
  }

  private var completedView: some View {
    VStack(spacing: 8) {
      Text("완료")
        .font(.headline)
      if connectivity.avgBpm > 0 {
        Text("평균 \(Int(connectivity.avgBpm)) bpm")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      if connectivity.maxBpm > 0 {
        Text("최대 \(Int(connectivity.maxBpm)) bpm")
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
      Button("루틴 목록") {
        connectivity.dismissCompleted()
        connectivity.requestRoutines()
      }
      .padding(.top, 4)
    }
  }

  private var activeWorkoutView: some View {
    ScrollView {
      VStack(spacing: 6) {
        Text(phaseTitle)
          .font(.caption2.weight(.semibold))
          .foregroundStyle(phaseColor)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 2)
          .background(phaseColor.opacity(0.18), in: Capsule())

        Text("\(connectivity.remainingSec)")
          .font(.system(size: 44, weight: .bold, design: .rounded))
          .monospacedDigit()
          .foregroundStyle(connectivity.isPaused ? .yellow : .primary)

        if !connectivity.label.isEmpty {
          Text(connectivity.label)
            .font(.caption.weight(.medium))
            .lineLimit(2)
            .multilineTextAlignment(.center)
        } else if !connectivity.exerciseName.isEmpty {
          Text(connectivity.exerciseName)
            .font(.caption.weight(.medium))
            .lineLimit(2)
            .multilineTextAlignment(.center)
        }

        Text("세트 \(connectivity.setIndex)/\(connectivity.totalSets) · 횟수 \(connectivity.repIndex)/\(connectivity.totalReps)")
          .font(.caption2)
          .foregroundStyle(.secondary)

        if connectivity.heartRateBpm > 0 {
          HStack(spacing: 4) {
            Image(systemName: "heart.fill")
              .foregroundStyle(.red)
            Text("\(Int(connectivity.heartRateBpm))")
              .monospacedDigit()
          }
          .font(.caption.weight(.semibold))
        }

        HStack(spacing: 10) {
          Button {
            connectivity.sendCommand(connectivity.isPaused ? "resume" : "pause")
          } label: {
            Image(systemName: connectivity.isPaused ? "play.fill" : "pause.fill")
          }
          .buttonStyle(.borderedProminent)

          Button(role: .destructive) {
            confirmEnd = true
          } label: {
            Image(systemName: "xmark")
          }
          .buttonStyle(.bordered)
        }
        .padding(.top, 4)
      }
      .padding(.horizontal, 4)
    }
    .confirmationDialog("운동을 종료할까요?", isPresented: $confirmEnd) {
      Button("종료", role: .destructive) {
        connectivity.sendCommand("end")
      }
      Button("취소", role: .cancel) {}
    }
  }

  private var phaseTitle: String {
    switch connectivity.phaseKind {
    case "prepare": return "준비"
    case "work": return "운동"
    case "relax": return "휴식"
    case "completed": return "완료"
    default: return connectivity.phaseKind.isEmpty ? "운동" : connectivity.phaseKind
    }
  }

  private var phaseColor: Color {
    switch connectivity.phaseKind {
    case "prepare": return .orange
    case "work": return .red
    case "relax": return .cyan
    default: return .accentColor
    }
  }
}
