//
//  AnalyzeMock.swift
//  Pision
//
//  Created by rundo on 7/23/25.
//

import Foundation

// MARK: - 예시 목데이터 생성 (5시간 기준, 1시간 평균 CoreScore / AuxScore 5개)

let now = Date()
let fiveHoursAgo = Calendar.current.date(byAdding: .hour, value: -5, to: now)!

let exampleTaskData = TaskData(
    id: UUID(),
    startTime: fiveHoursAgo,
    endTime: now,
    totalDuration: 5 * 3600,        // 5시간 = 18000초
    totalFocusTime: 4 * 3600,       // 4시간 집중
    averageScore: 80.0,             // 평균 집중도 80%

    // CoreScore 10개 (30분당 평균 점수 가정)
    coreScores: [
        CoreScore(yawScore: 20, eyeOpenScore: 28, eyeClosedScore: 25, blinkScore: 10, coreScore: 83),
        CoreScore(yawScore: 18, eyeOpenScore: 26, eyeClosedScore: 27, blinkScore: 9, coreScore: 80),
        CoreScore(yawScore: 16, eyeOpenScore: 24, eyeClosedScore: 28, blinkScore: 8, coreScore: 77),
        CoreScore(yawScore: 14, eyeOpenScore: 22, eyeClosedScore: 29, blinkScore: 7, coreScore: 74),
        CoreScore(yawScore: 12, eyeOpenScore: 20, eyeClosedScore: 30, blinkScore: 6, coreScore: 71),
        CoreScore(yawScore: 20, eyeOpenScore: 28, eyeClosedScore: 25, blinkScore: 10, coreScore: 83),
        CoreScore(yawScore: 18, eyeOpenScore: 26, eyeClosedScore: 27, blinkScore: 9, coreScore: 80),
        CoreScore(yawScore: 16, eyeOpenScore: 24, eyeClosedScore: 28, blinkScore: 8, coreScore: 77),
        CoreScore(yawScore: 14, eyeOpenScore: 22, eyeClosedScore: 29, blinkScore: 7, coreScore: 74),
        CoreScore(yawScore: 12, eyeOpenScore: 20, eyeClosedScore: 30, blinkScore: 6, coreScore: 71)
    ],

    // AuxScore 10개 (30분당 평균 점수 가정)
    auxScores: [
        AuxScore(yawStabilityScore: 25, mlSnoozeScore: 15, blinkScoreAux: 10, auxScore: 40),
        AuxScore(yawStabilityScore: 22, mlSnoozeScore: 13, blinkScoreAux: 9, auxScore: 38),
        AuxScore(yawStabilityScore: 20, mlSnoozeScore: 12, blinkScoreAux: 8, auxScore: 36),
        AuxScore(yawStabilityScore: 18, mlSnoozeScore: 11, blinkScoreAux: 7, auxScore: 34),
        AuxScore(yawStabilityScore: 16, mlSnoozeScore: 10, blinkScoreAux: 6, auxScore: 32),
        AuxScore(yawStabilityScore: 25, mlSnoozeScore: 15, blinkScoreAux: 10, auxScore: 40),
        AuxScore(yawStabilityScore: 22, mlSnoozeScore: 13, blinkScoreAux: 9, auxScore: 38),
        AuxScore(yawStabilityScore: 20, mlSnoozeScore: 12, blinkScoreAux: 8, auxScore: 36),
        AuxScore(yawStabilityScore: 18, mlSnoozeScore: 11, blinkScoreAux: 7, auxScore: 34),
        AuxScore(yawStabilityScore: 16, mlSnoozeScore: 10, blinkScoreAux: 6, auxScore: 32)
    ],

    // 시간대별 집중률 (예: 1시간 단위)
    focusRatios: [75, 45, 80, 85, 50, 75, 45, 80, 85, 50]
)
