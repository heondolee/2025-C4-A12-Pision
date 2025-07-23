//
//  MLManager.swift
//  PisionTest2
//
//  Created by 여성일 on 7/13/25.
//

import CoreML
import Vision

final class MLManager {
  private let model: pisionModel
  private var poseBuffer: [VNHumanBodyPoseObservation] = []
  
  init?() {
    guard let loaded = try? pisionModel(configuration: MLModelConfiguration()) else {
      print("Log: 모델 로드 실패")
      return nil
    }
    self.model = loaded
  }

  func bodyPosePredict(from observation: VNHumanBodyPoseObservation) -> String {
    poseBuffer.append(observation)
    
    if poseBuffer.count > 30 {
      poseBuffer.removeFirst()
    }
    
    guard poseBuffer.count == 30 else { return "" }
    
    do {
      let array = try MLMultiArray(shape: [30, 3, 18] as [NSNumber], dataType: .float32)
      
      let jointNames: [VNHumanBodyPoseObservation.JointName] = [
        .nose, .leftEye, .rightEye, .leftEar, .rightEar,
        .leftShoulder, .rightShoulder, .leftElbow, .rightElbow,
        .leftWrist, .rightWrist, .leftHip, .rightHip,
        .leftKnee, .rightKnee, .leftAnkle, .rightAnkle,
        .root
      ]
      
      for (frameIndex, observation) in poseBuffer.enumerated() {
        
        let points = try observation.recognizedPoints(.all)
        
        for (jointIndex, joint) in jointNames.enumerated() {
          if let point = points[joint] {
            array[[frameIndex as NSNumber, 0, jointIndex as NSNumber]] = NSNumber(value: Float(point.location.x))
            array[[frameIndex as NSNumber, 1, jointIndex as NSNumber]] = NSNumber(value: Float(point.location.y))
            array[[frameIndex as NSNumber, 2, jointIndex as NSNumber]] = NSNumber(value: Float(point.confidence))
          } else {
            array[[frameIndex as NSNumber, 0, jointIndex as NSNumber]] = 0
            array[[frameIndex as NSNumber, 1, jointIndex as NSNumber]] = 0
            array[[frameIndex as NSNumber, 2, jointIndex as NSNumber]] = 0
          }
        }
      }
      let result = try model.prediction(poses: array)
      let label = result.label
      return label
    } catch {
      print("Log: 예측 에러")
    }
    return ""
  }
}
