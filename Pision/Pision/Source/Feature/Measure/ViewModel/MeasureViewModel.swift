//
//  MainViewModel.swift
//  PisionTest2
//
//  Created by 여성일 on 7/13/25.
//

import AVFoundation
import Combine
import Foundation
import SwiftUI
import Vision

final class MeasureViewModel: ObservableObject {
  private var cancellables = Set<AnyCancellable>()
  
  // Published Var
  @Published private(set) var pose: VNHumanBodyPoseObservation?
  @Published private(set) var predictedLabel: String = "-"
  @Published private(set) var predictionConfidence: Double = 0.0
  @Published private var secondsElapsed: Int = 0
  @Published private(set) var timerState: TimerState = .stopped
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
  var coreScoreHistory: [CoreScore] = []
  var auxScoreHistory: [AuxScore] = []
  var totalScoreHistory: [Float] = []
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
  private let cameraManager: CameraManager
  private let visionManager = VisionManager()
  
  var session: AVCaptureSession {
    cameraManager.session
  }
  
  // init
  init() {
    cameraManager = CameraManager(visionManager: visionManager)
    cameraManager.requestAndCheckPermissions()
    bindScore()
    
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
    startTimerLoop()
    cameraManager.startMeasuring()
  }
  
  func timerPause() {
    guard timerState == .running else { return }
    timer?.invalidate()
    timerState = .pause
    cameraManager.stopMeasuring()
  }
  
  func timerResume() {
    guard timerState == .pause else { return }
    timerState = .running
    startTimerLoop()
    cameraManager.startMeasuring()
  }
  
  func timerStop() {
    timer?.invalidate()
    timer = nil
    secondsElapsed = 0
    timerState = .stopped
    cameraManager.stopMeasuring()
  }
}

// MARK: - Private Func
private extension MeasureViewModel {
  func bindScore() {
    visionManager.$latestCoreScore
      .compactMap { $0 }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] score in
        self?.coreScoreHistory.append(score)
      }
      .store(in: &cancellables)
    
    visionManager.$latestAuxScore
      .compactMap { $0 }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] score in
        self?.auxScoreHistory.append(score)
      }
      .store(in: &cancellables)
  }
  
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
  
  func startTimerLoop() {
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      guard let self = self else { return }
      self.secondsElapsed += 1
      
      if self.secondsElapsed % 30 == 0 {
        self.visionManager.calculateAllScores()
      }
    }
  }
}
