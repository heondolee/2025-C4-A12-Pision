//
//  CameraManager.swift
//  Pision
//
//  Created by 여성일 on 7/9/25.
//

import AVFoundation

final class CameraManager: NSObject {
  let session = AVCaptureSession()
  
  private var isMeasuring: Bool = false
  private let videoOutput = AVCaptureVideoDataOutput()
  private var isSessionConfigured = false
  private let sessionQueue = DispatchQueue(label: "CameraSessionQueue")
  
  private let visionManager: VisionManager
  
  init(visionManager: VisionManager) {
    self.visionManager = visionManager
    super.init()
  }
  
  func startSession() {
    sessionQueue.async {
      if !self.session.isRunning {
        self.session.startRunning()
      }
    }
  }
  
  func stopSession() {
    sessionQueue.async {
      if self.session.isRunning {
        self.session.stopRunning()
      }
    }
  }
  
  func startMeasuring() {
    isMeasuring = true
  }
  
  func stopMeasuring() {
    isMeasuring = false
  }
  
  func requestAndCheckPermissions() {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
        if granted {
          self?.configureSessionIfNeeded()
        } else {
          print("카메라 접근 거부됨")
        }
      }
      
    case .authorized:
      configureSessionIfNeeded()
    case .restricted, .denied:
      print("카메라 접근 제한 또는 거부")
    @unknown default:
      print("알 수 없는 권한 상태")
    }
  }
  
  private func configureSessionIfNeeded() {
    guard !isSessionConfigured else { return }
    isSessionConfigured = true
    configureSession()
  }
  
  private func configureSession() {
    session.beginConfiguration()
    session.sessionPreset = .high
    
    guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
          let input = try? AVCaptureDeviceInput(device: device),
          session.canAddInput(input) else {
      print("카메라 인풋 실패")
      session.commitConfiguration()
      return
    }
    
    session.addInput(input)
    
    if session.canAddOutput(videoOutput) {
      videoOutput.videoSettings = [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
      ]
      videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
      videoOutput.alwaysDiscardsLateVideoFrames = true
      session.addOutput(videoOutput)
      
      if #available(iOS 17.0, *) {
        videoOutput.connections.first?.videoRotationAngle = 0
      } else {
        videoOutput.connections.first?.videoOrientation = .portrait
      }
    }
    
    session.commitConfiguration()
  }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    guard isMeasuring else { return }
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
    visionManager.processFaceLandMark(pixelBuffer: pixelBuffer)
    visionManager.processBodyPose(pixelBuffer: pixelBuffer)
  }
}
