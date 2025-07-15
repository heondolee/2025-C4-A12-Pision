//
//  RecordView.swift
//  Pision
//
//  Created by 여성일 on 7/14/25.
//

// 예제코드 흐름
// PisionTest2App -> MainView 근데 MainViewModel 넣어줌
// MainViewModel은 카메라 불러오고 그 카메라에서 데이터 받아올 수 있도록 하는 로직으로 보임
// 그래서 MainView 뷰네 음음
// 카메라뷰를 extension에서 불러옴


import AVFoundation
import SwiftUI
import CoreML

struct RecordView: View {
  @State private var currentState = "focus"
  @StateObject private var viewModel: RecordViewModel
  
  @State private var timerTime = 0
  @State private var timerRunning = true
  @State private var timer:Timer?=nil
  
  @State private var savedBrightness: CGFloat = UIScreen.main.brightness
  @State private var brightnessResetWorkItem: DispatchWorkItem? = nil
  
  init(viewModel: RecordViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  private func StartTimer(){
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 1.0,repeats: true){ _ in
      DispatchQueue.main.async {
        timerTime += 1
      }
    }
  }
  
  private func StopTimer() {
    timer?.invalidate()
  }
  
  private func timeString(from seconds: Int) -> String {
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    let secs = seconds % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, secs)
  }
  
  private func setLowestBrightness() {
    DispatchQueue.main.async {
      print("밝기 낮춤")
      UIScreen.main.brightness = 0.01
    }
  }
  
  private func restoreBrightness() {
    DispatchQueue.main.async {
      print("밝기 복구: \(savedBrightness)")
      UIScreen.main.brightness = savedBrightness
    }
  }
  
  private func showBrightnessTemporarily() {
    // 기존 예약 취소
    brightnessResetWorkItem?.cancel()
    
    // 밝기 복구
    print("밝기 복원!")
    restoreBrightness()
    
    // 5초 후 다시 어둡게
    let workItem = DispatchWorkItem {
      print("밝기 다시 어둡게!")
      setLowestBrightness()
    }
    brightnessResetWorkItem = workItem
    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: workItem)
  }
}

extension RecordView {
  var body: some View {
    ZStack {
      Color.clear.ignoresSafeArea()
      
      VStack {
        ZStack{
          CameraView(session: viewModel.session)
          VStack{
            Spacer()
            Text(timeString(from: timerTime))
              .font(.largeTitle).font(.largeTitle)
            Spacer()
            Spacer()
            Spacer()
            HStack{
              Spacer()
              Button{
                timer?.invalidate()
              }label:{
                Text("정지")
              }.buttonStyle(.borderedProminent)
                .tint(.red)
              Spacer()
              Button{
                timerRunning.toggle()
                if timerRunning{
                  StartTimer()
                }else{
                  timer?.invalidate()
                }
              }label:{
                Text(timerRunning ? "일시정지":"다시시작")
              }.buttonStyle(.borderedProminent)
                .tint(.blue)
              Spacer()
            }
            Spacer()
          }
        }
        
        VStack {
          Text("rolls: \(viewModel.rollAngles)") // 고개를 좌/우로 기울이는 동작
          Text("yaw: \(viewModel.yawAngles)") // 고개를 좌/우로 도리도리 하는 동작
          Text("Pose: \(viewModel.predictedLabel)")
          Text("Pose%: \(viewModel.predictionConfidence)")
        }
        .font(.headline)
      }
      
    }
    .onAppear {
      savedBrightness = UIScreen.main.brightness
      viewModel.start()
      StartTimer()
      setLowestBrightness()
    }
    .onDisappear {
      viewModel.stop()
      StopTimer()
      restoreBrightness()
    }
    .onTapGesture {
      showBrightnessTemporarily()
    }
  }
}

#Preview {
  RecordView(viewModel: RecordViewModel())
}


