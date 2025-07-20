//
//  MainViewModel.swift
//  PisionTest2
//
//  Created by 여성일 on 7/13/25.
//

import AVFoundation
import Foundation
import SwiftUI
import Vision

final class MeasureViewModel: ObservableObject {
  // Published Var
  @Published var yawAngles: [Double] = []
  @Published var rollAngles: [Double] = []
  @Published var predictedLabel: String = "-"
  @Published var predictionConfidence: Double = 0.0
  @Published private var secondsElapsed: Int = 0
  @Published var timerState: TimerState = .stopped
  @Published var isAutoBrightnessModeOn: Bool = false {
    didSet {
      if !isAutoBrightnessModeOn {
        startAutoBrightnessMode()
      } else {
        cancelAutoBrightnessMode()
        restoreBrightness()
      }
    }
  }
  
  // General Var
  private var timer: Timer?
  private var brightnessTimer: DispatchWorkItem?
  
  var timeString: String {
    let hrs = secondsElapsed / 3600
    let mins = (secondsElapsed % 3600) / 60
    let secs = secondsElapsed % 60
    return String(format: "%02d:%02d:%02d", hrs, mins, secs)
  }
  
  // Manager
  private let mlManager = MLManager()!
  private let cameraManager = CameraManager()
  
  var session: AVCaptureSession {
    cameraManager.session
  }
  
  // init
  init() {
    cameraManager.requestAndCheckPermissions()
    
    cameraManager.onYawsUpdate = { [weak self] yaws in
      self?.yawAngles = yaws
    }
    
    cameraManager.onRollsUpdate = { [weak self] rolls in
      self?.rollAngles = rolls
    }
    
    cameraManager.onPoseUpdate = { [weak self] pose in
      self?.mlManager.addPoseObservation(from: pose)
    }
    
    mlManager.onPrediction = { [weak self] label, confidence in
      self?.predictedLabel = label
      self?.predictionConfidence = confidence
    }
    
    if !isAutoBrightnessModeOn {
      startAutoBrightnessMode()
    } else {
      restoreBrightness()
    }
  }
  
  // Func
  func cameraStart() {
    cameraManager.startSession()
  }
  
  func cameraStop() {
    cameraManager.stopSession()
  }
  
  func timerStart() {
    timerStop()
    secondsElapsed = 0
    timerState = .running
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      self?.secondsElapsed += 1
    }
  }
  
  func timerPause() {
    guard timerState == .running else { return }
    print(timeString)
    timer?.invalidate()
    timerState = .pause
  }
  
  func timerResume() {
    guard timerState == .pause else { return }
    timerState = .running
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      self?.secondsElapsed += 1
    }
  }
  
  func timerStop() {
    timer?.invalidate()
    timer = nil
    secondsElapsed = 0
    timerState = .stopped
  }
}

// MARK: - Private Func
private extension MeasureViewModel {
  func startAutoBrightnessMode() {
    brightnessTimer?.cancel()
    let task = DispatchWorkItem {
      UIScreen.main.brightness = 0.01
    }
    brightnessTimer = task
    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: task)
  }
  
  func cancelAutoBrightnessMode() {
    brightnessTimer?.cancel()
    brightnessTimer = nil
  }
  
  func restoreBrightness() {
    UIScreen.main.brightness = 1.0
  }
}
