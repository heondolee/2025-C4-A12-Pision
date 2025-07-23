//
//  AnalyzeModel.swift
//  Pision
//
//  Created by rundo on 7/23/25.
//

import Swift
import Foundation

// MARK: - CoreScore (30초 단위 Core 집중도 지표)
struct CoreScore {
  let yawScore: Float                 // 고개 정면 유지 정도
  let eyeOpenScore: Float             // 눈 뜬 정도
  let eyeClosedScore: Float           // 눈 감은 시간 비율
  let blinkScore: Float               // 깜빡임 빈도 점수
  var coreScore: Float
}

// MARK: - AuxScore (30초 단위 안정성 보조 지표)
struct AuxScore {
  let yawStabilityScore: Float        // 고개 흔들림 안정도
  let mlSnoozeScore: Float            // ML 기반 졸음 예측
  let blinkScoreAux: Float            // 1분 깜빡임 수
  var auxScore: Float
}

// MARK: - TaskData (세션 단위 정보)
struct TaskData {
  let id: UUID                        // 테스트 고유 ID
  let startTime: Date                // 공부 시작 시간
  let endTime: Date                  // 공부 종료 시간
  let totalDuration: TimeInterval   // 전체 시간 (endTime - startTime)
  let totalFocusTime: TimeInterval  // 집중한 시간
  let averageScore: Float           // 평균 집중도 (총 집중 시간 / 전체 시간)
  
  let coreScores: [CoreScore]?     // 30초 단위 Core 점수 기록
  let auxScores: [AuxScore]?         // 30초 단위 Aux 점수 기록
  
  var focusRatios: [Float]?         // 시간대별 집중도 비율 (예: 24개, 1시간 단위)
}

// averageCoreScore() : 한 태스크의 코어스코어들(10분씩)의 평균을 구해주는 함수
extension TaskData {
  func averageCoreScore() -> Double {
    guard let coreScores = coreScores, !coreScores.isEmpty else {
      return 0.0
    }
    let total = coreScores.map { Double($0.coreScore) }.reduce(0, +)
    return total / Double(coreScores.count)
  }
}

// 이하 동문
extension TaskData {
  func averageAuxScore() -> Double {
    guard let auxScores = auxScores, !auxScores.isEmpty else {
      return 0.0
    }
    let total = auxScores.map { Double($0.auxScore) }.reduce(0, +)
    return total / Double(auxScores.count)
  }
}

