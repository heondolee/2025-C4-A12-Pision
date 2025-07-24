//
//  ScoreManager.swift
//  Pision
//
//  Created by 여성일 on 7/23/25.
//

import Foundation

// MARK: - ScoreManager
final class ScoreManager {
  /// EAR, YAW, 눈 깜빡임 데이터를 바탕으로 집중도를 나타내는 CoreScoreModel을 계산합니다.
  /// - Parameters:
  ///   - ears: EAR 값 배열
  ///   - yaws: YAW 값 배열
  ///   - blinkCount: 눈 깜빡임 횟수
  /// - Returns: CoreScoreModel 점수 결과
  func calculateCore(from ears: [Float], yaws: [Float], blinkCount: Int) -> CoreScoreModel {
    let avgYaw = yaws.map { $0 >= 0.786 ? $0 : 0 }.average()
    let yawScore = (1 - minMaxNormalize(value: avgYaw, maxValue: 0.7)) * 100 * 0.25

    let avgEAR = ears.average()
    let eyeOpenScore = minMaxNormalize(value: avgEAR, minValue: 0.1, maxValue: 0.18) * 100 * 0.3

    let eyeClosedRatio = Float(ears.filter { $0 < 0.1 }.count) * 0.0405 / 30
    let eyeClosedScore = (1 - minMaxNormalize(value: eyeClosedRatio, maxValue: 1)) * 100 * 0.2

    let blinkRatio = Float(blinkCount) / 15
    let blinkScore = max(0, (1 - blinkRatio) * 100 * 0.25)

    let core = yawScore + eyeOpenScore + eyeClosedScore + blinkScore

    return CoreScoreModel(
      yawScore: yawScore,
      eyeOpenScore: eyeOpenScore,
      eyeClosedScore: eyeClosedScore,
      blinkFrequency: blinkScore,
      coreScore: core
    )
  }
  
  /// EAR, YAW, ML 예측 결과를 바탕으로 집중도를 나타내는 AuxScoreModel을 계산합니다.
  /// - Parameters:
  ///   - ears: EAR 값 배열
  ///   - yaws: YAW 값 배열
  ///   - ml: ML 예측 라벨 배열
  ///   - blinkCount: 눈 깜빡임 횟수
  /// - Returns: AuxScoreModel 점수 결과
  func calculateAux(from ears: [Float], yaws: [Float], ml: [String], blinkCount: Int) -> AuxScoreModel {
    let blinkScore = (1 - minMaxNormalize(value: Float(blinkCount), maxValue: 30)) * 100 * 0.25

    let yawDiff = zip(yaws.dropFirst(), yaws).map { abs($0 - $1) }
    let yawStability = (1 - minMaxNormalize(value: yawDiff.average(), maxValue: 0.2)) * 100 * 0.35

    let count = min(ml.count, ears.count, yaws.count)
    let snooze = (0..<count).map { i in
      ml[i] == "snooze" || ears[i] < 0.1 || abs(yaws[i]) > 0.3
    }
    let snoozeRatio = snooze.filter { $0 }.count.f / snooze.count.f
    let mlSnooze = pow(1 - snoozeRatio, 2) * 100 * 0.4

    let aux = blinkScore + yawStability + mlSnooze
    return AuxScoreModel(
      blinkScore: blinkScore,
      yawStabilityScore: yawStability,
      mlSnoozeScore: mlSnooze,
      auxScore: aux
    )
  }

  /// CoreScore와 AuxScore를 바탕으로 TotalScore를 계산합니다.
  /// - Parameters:
  ///   - core: CoreScoreModel
  ///   - aux: AuxScoreModel
  /// - Returns: TotalScore Float 값
  func calculateTotal(core: CoreScoreModel, aux: AuxScoreModel) -> Float {
    return core.coreScore * 0.7 + aux.auxScore * 0.3
  }

  /// CoreScoreModel의 값들의 평균치를 계산합니다.
  /// - Parameters:
  ///   - scores: CoreScoreModel 배열
  /// - Returns: AvgCoreScoreModel
  func averageCore(from scores: [CoreScoreModel]) -> AvgCoreScoreModel {
    AvgCoreScoreModel(
      avgYawScore: scores.map { $0.yawScore }.average(),
      avgEyeOpenScore: scores.map { $0.eyeOpenScore }.average(),
      avgEyeClosedScore: scores.map { $0.eyeClosedScore }.average(),
      avgBlinkFrequency: scores.map { $0.blinkFrequency }.average(),
      avgCoreScore: scores.map { $0.coreScore }.average()
    )
  }
  
  /// AuxScoreModel의 값들의 평균치를 계산합니다.
  /// - Parameters:
  ///   - scores: AuxScoreModel 배열
  /// - Returns: AvgAuxScoreModel
  func averageAux(from scores: [AuxScoreModel]) -> AvgAuxScoreModel {
    AvgAuxScoreModel(
      avgBlinkScore: scores.map { $0.blinkScore }.average(),
      avgYawStabilityScore: scores.map { $0.yawStabilityScore }.average(),
      avgMlSnoozeScore: scores.map { $0.mlSnoozeScore }.average(),
      avgAuxScore: scores.map { $0.auxScore }.average()
    )
  }
}

// MARK: - Private Func
extension ScoreManager {
  /// 정규화를 수행하여 값을 0에서 1 사이로 변환합니다.
  ///
  /// 주어진 값 `value`를 `minValue`와 `maxValue` 범위 내에서 Min-Max 정규화를 적용해 0에서 1 사이의 값으로 반환합니다.
  /// 결과는 범위를 벗어나지 않도록 0~1로 클램핑됩니다.
  ///
  /// - Parameters:
  ///   - value: 정규화할 원본 값.
  ///   - minValue: 값의 최소 범위 (기본값은 0).
  ///   - maxValue: 값의 최대 범위.
  /// - Returns: 정규화된 0~1 사이의 `Float` 값. `minValue`와 `maxValue`가 같으면 0을 반환합니다.
  private func minMaxNormalize(value: Float, minValue: Float = 0, maxValue: Float) -> Float {
      guard maxValue != minValue else { return 0 }
      return min(max((value - minValue) / (maxValue - minValue), 0), 1)
  }
}
