//
//  RecordView.swift
//  Pision
//
//  Created by 여성일 on 7/14/25.
//

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
  @State private var currentState = "Snooze"
  @StateObject private var viewModel: RecordViewModel
  
  init(viewModel: RecordViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
}

extension RecordView {
  var body: some View {
    ZStack {
      Color.clear.ignoresSafeArea()
      
      VStack {
        CameraView(session: viewModel.session)
        
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
      viewModel.start()
    }
    .onDisappear {
      viewModel.stop()
    }
  }
}

#Preview {
  RecordView(viewModel: RecordViewModel())
}


