////
////  AnalyzeModel.swift
////  Pision
////
////  Created by rundo on 7/22/25.
////
//import Swift
//import Foundation
//
//////struct ScoreDetailData { // 분석뷰의 Core, Aux 그래프에 보여줄 정보
//////  // let avgYaw, avgEAR, eyeClosedRatio, blinkCount: Float
//////  let yawScore, eyeOpenScore, eyeClosedScore, blinkScore: Float // CoreScore 지표: 이거 필요
//////  // let avgYawChange, snoozeRatio, totalFrames, blinkCountAux: Float?
//////  let yawStabilityScore, mlSnoozeScore, blinkScoreAux: Float? // AuxScore 자표: 이거 필요
//////}
////
////struct CoreScore {
////  yawScore, eyeOpenScore, eyeClosedScore, blinkScore, coreScore//👍
////}
////
////struct AuxScore {
////  yawStabilityScore, mlSnoozeScore, blinkScoreAux, auxScore//👍
////}
////
////
////struct TaskData { // 세션(태스크) 단위 데이터
////  let id: UUID //👍
////  let startTime: Date // 공부 시작 시간👍
////  let endTime: Date // 공부 끝난 시간👍
////  let totalDuration: TimeInterval          // 전체시간 : 공부끝시간 - 공부시작시간👍
////  let totalFocusTime: TimeInterval         // 집중시간👍
////  let averageScore: Float                  // 전체 평균 집중도 -> 집중시간 / 전체시간 👍
//////  let scoreHistory: [ScoreData]            // 30초 간격 점수 목록
////  let coreScore: [CoreScore]               // 30초마다 계산됨👍
////  let auxScore: [AuxScore]              // 이거도 30초마다 계산됨👍
////  var focusRatio: [Float]?   // 시간별 집중도 차트용👍
////}
////
//
//
//struct DailySummary { // 기록뷰에 보여줄 정보
//  let date: Date // 날짜 👍
//  let taskDatas: [TaskData] // 하루에 여러 세션(태스크)이 있음.👍
//  
//  var totalStudyTime: TimeInterval { // 총 공부시간👍
//    taskDatas.map(\.totalDuration).reduce(0, +)
//  }
//  
//  var totalFocusTime: TimeInterval { // 총 집중시간👍
//    taskDatas.map(\.totalFocusTime).reduce(0, +)
//  }
//  
//  var sessionCount: Int { // 집중 횟수👍
//    taskDatas.count
//  }
//  
//  var averageFocusRatio: Float { // 집중률 👍
//    guard totalStudyTime > 0 else { return 0 }
//    return Float(totalFocusTime / totalStudyTime) * 100
//  }
//}
//
//
//// 보류 👍
//struct PeriodSummary { // 기록뷰의 주, 월, 년에 보여줄 정보
//  let label: String                     // ex) 2025-30(.week일경우 30번째주), 2025(.year일 경우 2025년), 2025-07(.month일 경우 7월) - "-"로 분리해서 인식 하면 될 듯
//  let unit: PeriodUnit                 // .week, .month, .year
//  
//  let totalStudyTime: TimeInterval // 총 공부시간
//  let totalFocusTime: TimeInterval // 총 집중시간
//  let sessionCount: Int // 집중 횟수
//  let averageFocusRatio: Float // 집중률
//  
//  let isDataLoaded: Bool // 해당 기간에 맞게 DailySummary를 저장할 때 (아직 불러오고 있는지)로딩중을 판별할 수 있음.
//  var dailySummaries: [DailySummary]?
//}
//
//enum PeriodUnit {
//  case day
//  case week
//  case month
//  case year
//}
//
////struct HourlyFocusRatio { // 한 세션당 시간별 집중도 차트를 그리기위한 정보
//////  let hour: Int                 // 0~23 -> 순서대로
////  let focusRatio: Float         // 시간대별 평균 집중도 (%)👍
//////  let sessionCount: Int         // 해당 시간대에 측정된 세션 수
////}
//
//
//
//// MARK: - CoreScore (30초 단위 Core 집중도 지표)
//struct CoreScore {
//  let yawScore: Float                 // 고개 정면 유지 정도
//  let eyeOpenScore: Float             // 눈 뜬 정도
//  let eyeClosedScore: Float           // 눈 감은 시간 비율
//  let blinkScore: Float               // 깜빡임 빈도 점수
//  var coreScore: Float
//}
//
//// MARK: - AuxScore (30초 단위 안정성 보조 지표)
//struct AuxScore {
//  let yawStabilityScore: Float        // 고개 흔들림 안정도
//  let mlSnoozeScore: Float            // ML 기반 졸음 예측
//  let blinkScoreAux: Float            // 1분 깜빡임 수
//  var auxScore: Float
//}
//
//// MARK: - TaskData (세션 단위 정보)
//struct TaskData {
//  let id: UUID                        // 테스트 고유 ID
//  let timestamp: Date                 // 각 30초의 시작 시간
//  let startTime: Date                // 공부 시작 시간
//  let endTime: Date                  // 공부 종료 시간
//  let totalDuration: TimeInterval   // 전체 시간 (endTime - startTime)
//  let totalFocusTime: TimeInterval  // 집중한 시간
//  let averageScore: Float           // 평균 집중도 (총 집중 시간 / 전체 시간)
//  
//  let coreScores: [CoreScore]       // 30초 단위 Core 점수 기록
//  let auxScores: [AuxScore]         // 30초 단위 Aux 점수 기록
//  
//  var focusRatios: [Float]?         // 시간대별 집중도 비율 (예: 24개, 1시간 단위)
//}
