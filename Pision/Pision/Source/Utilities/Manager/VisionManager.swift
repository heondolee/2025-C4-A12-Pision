//
//  VisionManager.swift
//  PisionTest2
//
//  Created by 여성일 on 7/13/25.
//

import Foundation
import Vision

// MARK: - General
final class VisionManager: ObservableObject {
  @Published private(set) var latestCoreScore: CoreScore?
  @Published private(set) var latestAuxScore: AuxScore?
  @Published private(set) var totalScore: [Float] = []
  @Published private(set) var pose: VNHumanBodyPoseObservation?
  
  private let sequenceHandler = VNSequenceRequestHandler() // 비전 시퀸스 처리 핸들러 객체
  private let faceRequest = VNDetectFaceLandmarksRequest() // 얼굴 인식 request 값
  private let poseRequest = VNDetectHumanBodyPoseRequest() // 포즈 인식 request 값
  
  private var avgYAW: Float = 0
  private var isBlink: Bool = false
  private var blinkCount: Int = 0
  private var yaws: [Float] = []
  private var rolls: [Float] = []
  private var ears: [Float] = []
  private var mlPredictions: [String] = []
  
  private let mlManager = MLManager()!
}

// MARK: - Extension
extension VisionManager {
  func processFaceLandMark(pixelBuffer: CVPixelBuffer) {
    do {
      try sequenceHandler.perform([faceRequest], on: pixelBuffer)
      
      guard let result = faceRequest.results else { return }
      
      var yaws: [Float] = []
      var rolls: [Float] = []
      var ears: [Float] = []
      
      for face in result {
        if let yaw = face.yaw?.doubleValue {
          yaws.append(Float(yaw))
        }
        
        if let roll = face.roll?.doubleValue {
          rolls.append(Float(roll))
        }
        
        if let landmarks = face.landmarks,
           let leftEye = landmarks.leftEye,
           let rightEye = landmarks.rightEye {
          let leftEAR = calculateEAR(leftEye)
          let rightEAR = calculateEAR(rightEye)
          
          let avgEAR = (leftEAR + rightEAR) / 2.0
          ears.append(Float(avgEAR))
          
          countBlink(leftEAR: leftEAR, rightEAR: rightEAR, threshold: 0.1)
        }
      }
      
      DispatchQueue.main.async {
        self.yaws.append(contentsOf: yaws)
        self.rolls.append(contentsOf: rolls)
        self.ears.append(contentsOf: ears)
      }
    } catch {
      print("Log: Vision Face 처리 에러")
    }
  }
  
  func processBodyPose(pixelBuffer: CVPixelBuffer) {
    do {
      try sequenceHandler.perform([poseRequest], on: pixelBuffer)
      
      var labels: [String] = []
      guard let result = poseRequest.results,
            let first = result.first else { return }
      
      let label = mlManager.bodyPosePredict(from: first)
      labels.append(label)
      
      DispatchQueue.main.async {
        self.pose = first
        self.mlPredictions.append(contentsOf: labels)
      }
    } catch {
      print("Log: Vision Pose 처리 에러")
    }
  }
}

// MARK: - Private func
extension VisionManager {
  private func restData() {
    yaws.removeAll()
    ears.removeAll()
    mlPredictions.removeAll()
    blinkCount = 0
  }
}

// MARK: - General Calc
extension VisionManager {
  private func minMaxNormalize(value: Float, minValue: Float = 0, maxValue: Float) -> Float {
    guard maxValue != minValue else { return 0 }
    return min(max((value - minValue) / (maxValue - minValue), 0), 1)
  }
}

// MARK: - EAR Calc
extension VisionManager {
  private func calculateEAR(_ eye: VNFaceLandmarkRegion2D) -> CGFloat {
    let points = eye.normalizedPoints
    
    guard points.count >= 6 else { return 0.25 }
    
    let leftVerticalDist = points[1].eyeDistance(to: points[5])
    let rightVerticalDist = points[2].eyeDistance(to: points[4])
    let horizontalDist = points[0].eyeDistance(to: points[3])
    
    let ear = (leftVerticalDist + rightVerticalDist) / (2 * horizontalDist)
    
    return ear
  }
  
  private func countBlink(leftEAR: CGFloat, rightEAR: CGFloat, threshold: CGFloat) {
    let isLeftBlinking = leftEAR < threshold
    let isRightBlinking = rightEAR < threshold
    
    if isLeftBlinking && isRightBlinking {
      if !isBlink {
        isBlink = true
      }
    } else {
      if isBlink {
        isBlink = false
        blinkCount += 1
      }
    }
  }
}

// MARK: - Score Calculate
extension VisionManager {
  func calculateAllScores() {
    // Calc CoreScore
    let avgYaw = yaws.map { abs($0) >= 0.786 ? abs($0) : 0.0 }.average()
    let yawScore = (1 - minMaxNormalize(value: avgYaw, maxValue: 0.7)) * 100 * 0.25

    let avgEAR = ears.map { abs($0) }.average()
    let eyeOpenScore = minMaxNormalize(value: avgEAR, minValue: 0.1, maxValue: 0.18) * 100 * 0.30
    let eyeClosedRatio = (Float(ears.filter { $0 < 0.1 }.count) * 0.0405) / 30.0
    let eyeClosedScore = (1.0 - minMaxNormalize(value: eyeClosedRatio, minValue: 0, maxValue: 1)) * 100 * 0.20
    let blinkRatio = Float(blinkCount) / 15
    let blinkScore = max(0, (1.0 - blinkRatio) * 100 * 0.25)

    let coreScoreValue = yawScore + eyeOpenScore + blinkScore + eyeClosedScore
    let core = CoreScore(
      yawScore: yawScore,
      eyeOpenScore: eyeOpenScore,
      eyeClosedScore: eyeClosedScore,
      blinkScore: blinkScore,
      coreScore: coreScoreValue
    )
    
    // Calc AuxScore
    let blinkScoreAux = (1.0 - minMaxNormalize(value: Float(blinkCount), maxValue: 30)) * 100 * 0.25
    
    let yawDiffs = zip(yaws.dropFirst(), yaws).map { abs($0 - $1) }
    let avgYawChange = yawDiffs.average()
    let yawStabilityScore = (1 - minMaxNormalize(value: avgYawChange, minValue: 0, maxValue: 0.2)) * 100 * 0.35
    
    let count = min(mlPredictions.count, ears.count, yaws.count)
    let snoozePredictions = (0..<count).map { i in
      let isSnooze = mlPredictions[i] == ModelLabel.snooze.rawValue
      let isLowEAR = ears[i] < 0.1
      let isHighYaw = abs(yaws[i]) > 0.3
      return isSnooze || isLowEAR || isHighYaw
    }
    let snoozeCount = snoozePredictions.filter { $0 }.count
    let snoozeRatio: Float = snoozePredictions.isEmpty ? 0 : Float(snoozeCount) / Float(snoozePredictions.count)
    let mlSnoozeScore = pow(1.0 - snoozeRatio, 2) * 100 * 0.4
    
    let auxScoreValue = blinkScoreAux + yawStabilityScore + mlSnoozeScore
    
    let aux = AuxScore(
      blinkScore: blinkScoreAux,
      yawStabilityScore: yawStabilityScore,
      mlSnoozeScore: mlSnoozeScore,
      AuxScore: auxScoreValue
    )

    // Calc TotalScore
    let total = (0.7 * core.coreScore) + (0.3 * aux.AuxScore)
    
    DispatchQueue.main.async {
      self.latestCoreScore = core
      self.latestAuxScore = aux
      self.totalScore.append(total)
    }

    print("CoreScore:", core)
    print("AuxScore:", aux)
    print("✅ Total Score:", total)

    restData()
  }
}
