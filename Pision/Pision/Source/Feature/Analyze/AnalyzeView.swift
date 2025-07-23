//
//  AnalyzeView.swift
//  Pision
//
//  Created by 여성일 on 7/14/25.
//

import SwiftUI
import Charts

// MARK: - 부모 뷰
struct AnalyzeView: View {
  let taskData: TaskData = exampleTaskData
}

// MARK: - body 뷰
extension AnalyzeView {
  var body: some View {
    VStack(spacing: 24) {
      FocusTimeOverview(taskData: taskData)
      HourlyFocusChart(taskData: taskData)
      CoreScoreSection(taskData: taskData)
      AuxScoreSection(taskData: taskData)
    }
    .padding()
  }
}

// MARK: - 시간 개요 뷰 -> 👍 다 들어감
extension AnalyzeView {
  struct FocusTimeOverview: View {
    let taskData: TaskData
    
    var focusRatio: Double {
      taskData.totalDuration == 0 ? 0 : taskData.totalFocusTime / taskData.totalDuration
    }

    var body: some View {
      VStack(alignment: .leading, spacing: 12) {
        Text("시작 시간 \(taskData.startTime.formatted(date: .omitted, time: .shortened))")
        Text("끝 시간 \(taskData.endTime.formatted(date: .omitted, time: .shortened))")
        Text("집중시간 \(formatSeconds(taskData.totalFocusTime))")
        Text("전체시간 \(formatSeconds(taskData.totalDuration))")
        Text("집중률 \(Int(taskData.averageScore))%")
        
        VStack(alignment: .leading, spacing: 4) {
          Text("집중 시간 비율")
            .font(.subheadline)
            .foregroundColor(.secondary)
          
          ProgressView(value: focusRatio)
            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            .frame(height: 12)
            .background(Color(.systemGray5))
            .clipShape(Capsule())

          HStack {
            Text("0%")
              .font(.caption)
              .foregroundColor(.gray)
            Spacer()
            Text("100%")
              .font(.caption)
              .foregroundColor(.gray)
          }
        }
        .padding(.top, 8)
      }
    }
  }
}


// MARK: - 시간별 집중도 바 차트 뷰
extension AnalyzeView {
  struct HourlyFocusChart: View {
    let taskData: TaskData
    
    var body: some View {
      VStack(alignment: .leading) {
        Text("시간별 집중도")
          .font(.headline)
        
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(alignment: .bottom, spacing: 4) {
            ForEach(Array(taskData.focusRatios ?? []).indices, id: \.self) { idx in
              VStack {
                Rectangle()
                  .frame(width: 10, height: CGFloat(taskData.focusRatios?[idx] ?? 0))
                  .foregroundColor(.blue)
                Text("\(Int(taskData.focusRatios?[idx] ?? 0) / 10)분")
              }
            }
          }
        }
      }
    }
  }
}

// MARK: - CoreScore 뷰 (꺾은선 그래프)
extension AnalyzeView {
  struct CoreScoreSection: View {
    let taskData: TaskData

    struct ScoreDetailEntry: Identifiable {
      let id = UUID()
      let index: Int
      let value: Double
      let category: String // 예: "yawScore", "blinkScore"
    }

    var allScoreEntries: [ScoreDetailEntry] {
      var entries: [ScoreDetailEntry] = []

      if let coreScores = taskData.coreScores {
        for (idx, score) in coreScores.enumerated() {
          entries.append(ScoreDetailEntry(index: idx + 1, value: Double(score.yawScore), category: "yawScore"))
          entries.append(ScoreDetailEntry(index: idx + 1, value: Double(score.eyeOpenScore), category: "eyeOpenScore"))
          entries.append(ScoreDetailEntry(index: idx + 1, value: Double(score.eyeClosedScore), category: "eyeClosedScore"))
          entries.append(ScoreDetailEntry(index: idx + 1, value: Double(score.blinkScore), category: "blinkScore"))
        }
      }

      if let auxScores = taskData.auxScores {
        for (idx, score) in auxScores.enumerated() {
          entries.append(ScoreDetailEntry(index: idx + 1, value: Double(score.yawStabilityScore), category: "yawStabilityScore"))
          entries.append(ScoreDetailEntry(index: idx + 1, value: Double(score.mlSnoozeScore), category: "mlSnoozeScore"))
          entries.append(ScoreDetailEntry(index: idx + 1, value: Double(score.blinkScoreAux), category: "blinkScoreAux"))
        }
      }

      return entries
    }

    var body: some View {
      VStack(alignment: .leading, spacing: 8) {
        Text("Core & Aux Score 세부 지표")
          .font(.headline)

        Chart {
          ForEach(allScoreEntries) { entry in
            LineMark(
              x: .value("Index", entry.index),
              y: .value("Score", entry.value)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(by: .value("Category", entry.category))

            PointMark(
              x: .value("Index", entry.index),
              y: .value("Score", entry.value)
            )
            .symbolSize(20)
            .foregroundStyle(by: .value("Category", entry.category))
          }
        }
        .chartYScale(domain: 0...100)
        .chartLegend(.visible)
        .frame(height: 250)
      }
    }
  }
}



// MARK: - AuxScore 뷰
extension AnalyzeView {
  struct AuxScoreSection: View {
    let taskData: TaskData
    
    var body: some View {
      VStack(alignment: .leading) {
        Text("AuxScore").font(.headline)
        Text("평균 \(Int(taskData.averageAuxScore()))점")
      }
    }
  }
}

// MARK: - Helper
extension AnalyzeView {
  static func formatSeconds(_ time: TimeInterval) -> String {
    let minutes = Int(time) / 60
    let hours = minutes / 60
    let remainingMinutes = minutes % 60
    return "\(hours)시간 \(remainingMinutes)분"
  }
}

#Preview {
  AnalyzeView()
}
