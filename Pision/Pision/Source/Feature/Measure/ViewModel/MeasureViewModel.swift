//
//  MainViewModel.swift
//  PisionTest2
//
//  Created by 여성일 on 7/13/25.
//

import AVFoundation
import Combine
import SwiftData
import SwiftUI
import Foundation

final class MeasureViewModel: ObservableObject {
  // Published Var
  @Published private(set) var timerState: TimerState = .stopped
  @Published private(set) var secondsElapsed: Int = 0
  @Published private(set) var currentFocusRatio: Float = 0.0
  @Published private(set) var shouldDimScreen: Bool = false
  @Published var isAutoBrightnessModeOn: Bool = false {
    didSet {
      if !isAutoBrightnessModeOn {
        startAutoBrightnessMode()
      } else {
        cancelAutoBrightnessMode()
      }
    }
  }
  
  // General Var
  private var timer: Timer?
  private var brightnessTimer: DispatchWorkItem?
  
  private var coreScoreHistory: [CoreScoreModel] = []
  private var auxScoreHistory: [AuxScoreModel] = []
  private var coreScoreHistory10Minute: [AvgCoreScoreModel] = []
  private var auxScoreHistory10Minute: [AvgAuxScoreModel] = []
  private var taskData: TaskDataModel?
  private var focusTime: Int = 0
  private var focusRatios: [Float] = []
  
  var timeString: String {
    let hrs = secondsElapsed / 3600
    let mins = (secondsElapsed % 3600) / 60
    let secs = secondsElapsed % 60
    return String(format: "%02d:%02d:%02d", hrs, mins, secs)
  }
  
  // Manager
  private let cameraManager: CameraManager
  private let visionManager = VisionManager()
  private let scoreManager = ScoreManager()
  private let swiftDataManager = SwiftDataManager()
  
  // Session
  var session: AVCaptureSession {
    cameraManager.session
  }
  
  init() {
    cameraManager = CameraManager(visionManager: visionManager)
    cameraManager.requestAndCheckPermissions()
    if !isAutoBrightnessModeOn {
      startAutoBrightnessMode()
    } else {
      cancelAutoBrightnessMode()
    }
  }
  
  func cameraStart() {
    cameraManager.startSession()
  }
  
  func cameraStop() {
    cameraManager.stopSession()
  }
  
  func resetAutoDimTimer() {
    brightnessTimer?.cancel()
    
    let task = DispatchWorkItem { [weak self] in
      self?.shouldDimScreen = true
    }
    
    brightnessTimer = task
    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: task)
    
    shouldDimScreen = false
  }
  
  func timerStart() {
    secondsElapsed = 0
    focusTime = 0
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
  
  func timerStop(context: ModelContext, completion: @escaping (SaveResult) -> Void) {
    timer?.invalidate()
    timer = nil
    timerState = .stopped
    cameraManager.stopMeasuring()
    cancelAutoBrightnessMode()
    
    saveRemainingAverage()
    
    saveTaskDataAndSaveToSwiftData(context: context, completion: completion)
  }
  
  func debugPrintAllSavedData(context: ModelContext) {
    swiftDataManager.fetchAllTaskData(context: context)
  }
}

// MARK: - Private Func
extension MeasureViewModel {
  private func startTimerLoop() {
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      guard let self = self else { return }
      self.secondsElapsed += 1
      
      if self.secondsElapsed % 30 == 0 {
        self.calculateScores()
      }
      
      if self.secondsElapsed % 600 == 0 {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          self.save10MinuteAverage()
        }
      }
    }
  }
  
  private func startAutoBrightnessMode() {
    brightnessTimer?.cancel()
    let task = DispatchWorkItem {
      self.shouldDimScreen = true
    }
    brightnessTimer = task
    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: task)
  }
  
  private func cancelAutoBrightnessMode() {
    brightnessTimer?.cancel()
    brightnessTimer = nil
    shouldDimScreen = false
  }
  
  private func calculateScores() {
    let core = scoreManager.calculateCore(
      from: visionManager.ears,
      yaws: visionManager.yaws,
      blinkCount: visionManager.blinkCount
    )
    let aux = scoreManager.calculateAux(
      from: visionManager.ears,
      yaws: visionManager.yaws,
      ml: visionManager.mlPredictions,
      blinkCount: visionManager.blinkCount
    )
    coreScoreHistory.append(core)
    auxScoreHistory.append(aux)
    
    let total = scoreManager.calculateTotal(core: core, aux: aux)
    
    currentFocusRatio = total
    if total >= 60 { focusTime += 30 }
    
    visionManager.reset()
  }
  
  private func save10MinuteAverage() {
    let last20Core = coreScoreHistory.suffix(20)
    let last20Aux = auxScoreHistory.suffix(20)
    guard last20Core.count == 20,
          last20Aux.count == 20 else { return }
    
    let avgCore = scoreManager.averageCore(from: Array(last20Core))
    coreScoreHistory10Minute.append(avgCore)
    
    let avgAux = scoreManager.averageAux(from: Array(last20Aux))
    auxScoreHistory10Minute.append(avgAux)
    
    let focusCount = zip(last20Core, last20Aux)
      .filter { scoreManager.calculateTotal(core: $0.0, aux: $0.1) >= 75 }
      .count
    
    let focusRatio = Float(focusCount * 30) / 600 * 100
    focusRatios.append(focusRatio)
  }
  
  private func saveRemainingAverage() {
    let remainderCount = min(coreScoreHistory.count % 20, auxScoreHistory.count % 20)
    guard remainderCount > 0 else { return }
    
    let remainderCore = coreScoreHistory.suffix(remainderCount)
    let remainderAux = auxScoreHistory.suffix(remainderCount)
    
    let avgCore = scoreManager.averageCore(from: Array(remainderCore))
    let avgAux = scoreManager.averageAux(from: Array(remainderAux))
    
    coreScoreHistory10Minute.append(avgCore)
    auxScoreHistory10Minute.append(avgAux)
    
    let focusCount = zip(remainderCore, remainderAux)
      .filter { scoreManager.calculateTotal(core: $0.0, aux: $0.1) >= 60 }
      .count
    let ratio = Float(focusCount * 30) / Float(remainderCount * 30) * 100
    focusRatios.append(ratio)
  }
  
  private func saveTaskDataAndSaveToSwiftData(context: ModelContext, completion: @escaping (SaveResult) -> Void) {
    if secondsElapsed < 600 {
      completion(.skippedLessThan10Minutes)
      return
    }
    
    let avgScore = (Float(focusTime) / Float(secondsElapsed)) * 100
    let data = TaskDataModel(
      startTime: Date().addingTimeInterval(-TimeInterval(secondsElapsed)),
      endTime: Date(),
      averageScore: avgScore,
      focusRatio: focusRatios,
      focusTime: focusTime,
      durationTime: secondsElapsed,
      avgCoreDatas: coreScoreHistory10Minute,
      avgAuxDatas: auxScoreHistory10Minute
    )
    self.taskData = data
    
    guard let taskData = self.taskData else {
      completion(.failed)
      return
    }
    
    swiftDataManager.saveTaskDataToSwiftData(context: context, taskData: taskData) { isSuccess in
      if isSuccess {
        completion(.success)
      } else {
        completion(.failed)
      }
    }
  }
}
