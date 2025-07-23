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
    totalDuration: 5 * 3600,
    totalFocusTime: 4 * 3600,
    averageScore: 80.0,

    coreScores: [
        CoreScore(yawScore: 20, eyeOpenScore: 24, eyeClosedScore: 17, blinkScore: 12, coreScore: 83),
        CoreScore(yawScore: 18, eyeOpenScore: 23, eyeClosedScore: 18, blinkScore: 11, coreScore: 80),
        CoreScore(yawScore: 16, eyeOpenScore: 22, eyeClosedScore: 18, blinkScore: 10, coreScore: 77),
        CoreScore(yawScore: 15, eyeOpenScore: 21, eyeClosedScore: 19, blinkScore: 9, coreScore: 74),
        CoreScore(yawScore: 14, eyeOpenScore: 20, eyeClosedScore: 19, blinkScore: 8, coreScore: 71),
        CoreScore(yawScore: 20, eyeOpenScore: 24, eyeClosedScore: 17, blinkScore: 12, coreScore: 83),
        CoreScore(yawScore: 18, eyeOpenScore: 23, eyeClosedScore: 18, blinkScore: 11, coreScore: 80),
        CoreScore(yawScore: 16, eyeOpenScore: 22, eyeClosedScore: 18, blinkScore: 10, coreScore: 77),
        CoreScore(yawScore: 15, eyeOpenScore: 21, eyeClosedScore: 19, blinkScore: 9, coreScore: 74),
        CoreScore(yawScore: 14, eyeOpenScore: 20, eyeClosedScore: 19, blinkScore: 8, coreScore: 71)
    ],

    auxScores: [
        AuxScore(yawStabilityScore: 20, mlSnoozeScore: 40, blinkScoreAux: 18, auxScore: 40),
        AuxScore(yawStabilityScore: 18, mlSnoozeScore: 38, blinkScoreAux: 17, auxScore: 38),
        AuxScore(yawStabilityScore: 17, mlSnoozeScore: 36, blinkScoreAux: 16, auxScore: 36),
        AuxScore(yawStabilityScore: 16, mlSnoozeScore: 34, blinkScoreAux: 15, auxScore: 34),
        AuxScore(yawStabilityScore: 15, mlSnoozeScore: 32, blinkScoreAux: 14, auxScore: 32),
        AuxScore(yawStabilityScore: 20, mlSnoozeScore: 40, blinkScoreAux: 18, auxScore: 40),
        AuxScore(yawStabilityScore: 18, mlSnoozeScore: 38, blinkScoreAux: 17, auxScore: 38),
        AuxScore(yawStabilityScore: 17, mlSnoozeScore: 36, blinkScoreAux: 16, auxScore: 36),
        AuxScore(yawStabilityScore: 16, mlSnoozeScore: 34, blinkScoreAux: 15, auxScore: 34),
        AuxScore(yawStabilityScore: 15, mlSnoozeScore: 32, blinkScoreAux: 14, auxScore: 32)
    ],

    focusRatios: [75, 45, 80, 85, 50, 75, 45, 80, 85, 50]
)
