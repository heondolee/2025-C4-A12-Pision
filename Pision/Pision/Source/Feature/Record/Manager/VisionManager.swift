//
//  VisionManager.swift
//  PisionTest2
//
//  Created by 여성일 on 7/13/25.
//

import Foundation
import Vision

final class VisionManager {
  private let faceRequest = VNDetectFaceLandmarksRequest() // 얼굴 인식 request 값
  private let poseRequest = VNDetectHumanBodyPoseRequest() // 포즈 인식 request 값
  private let sequenceHandler = VNSequenceRequestHandler() // 비전 시퀸스 처리 핸들러 객체
  
  /*
   비전 분석 결과를 외부로 전달하는 클로저
   CameraManager로 전달하기 위한 클로저임
   */
  var onFaceDetection: (([VNFaceObservation], [Double], [Double]) -> Void)?
  var onPoseDetection: ((VNHumanBodyPoseObservation) -> Void)?
  
  func processFaceLandMark(pixelBuffer: CVPixelBuffer) {
    do {
      try sequenceHandler.perform([faceRequest], on: pixelBuffer)
      
      guard let result = faceRequest.results else { return }
      
      var yaws: [Double] = []
      var rolls: [Double] = []
      
      for face in result { 
        if let yaw = face.yaw?.doubleValue {
          yaws.append(yaw * 180 / .pi)
        }
        
        if let roll = face.roll?.doubleValue {
          rolls.append(roll * 180 / .pi)
        }
      }
    
      onFaceDetection?(result, yaws, rolls)
    } catch {
      print("Log: Vision Face 처리 에러")
    }
  }
  
  func processBodyPose(pixelBuffer: CVPixelBuffer) {
    do {
      try sequenceHandler.perform([poseRequest], on: pixelBuffer)
      
      guard let result = poseRequest.results,
            let first = result.first else { return }
      
      onPoseDetection?(first)
    } catch {
      print("Log: Vision Pose 처리 에러")
    }
  }
}
