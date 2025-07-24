//
//  MeasureSheetView.swift
//  Pision
//
//  Created by 여성일 on 7/20/25.
//

import SwiftData
import SwiftUI

// MARK: - Var
struct MeasureSheetView: View {
  // ViewModel
  @ObservedObject private var viewModel: MeasureViewModel
  
  // SwiftData
  private let context: ModelContext

  // init
  init(
    viewModel: MeasureViewModel,
    context: ModelContext
  ) {
    self.viewModel = viewModel
    self.context = context
  }
}

// MARK: - View
extension MeasureSheetView {
  var body: some View {
    ZStack {
      Color.white
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .ignoresSafeArea()
      
      VStack(alignment: .center) {
        Text("학습시간")
          .foregroundStyle(.black)
        
        infoView
        
        Text("\(viewModel.currentFocusRatio)")
          .foregroundStyle(.white)
          .frame(width: 109, height: 40)
          .background(.gray)
          .clipShape(.capsule)
      }
    }
  }
  
  private var infoView: some View {
    HStack(spacing: 63) {
      Button {
        toggleButtonAction()
      } label: {
        Image(systemName: toggleButtonImage())
          .foregroundStyle(.black)
          .frame(width: 44, height: 44)
          .background(.gray)
          .clipShape(.circle)
      }
      .buttonStyle(.plain)
      
      Text(viewModel.timeString)
        .foregroundStyle(.black)
        .font(.title)
      
      Button {
        viewModel.timerStop(context: context) { result in
          switch result {
          case .success:
            print("성공")
          case .failed:
            print("실패")
          case .skippedLessThan10Minutes:
            print("10분 미만")
          }
        }
      } label: {
        Image(systemName: "stop.fill")
          .foregroundStyle(.white)
          .frame(width: 44, height: 44)
          .background(.blue)
          .clipShape(.circle)
      }
      .buttonStyle(.plain)
    }
  }
}

// MARK: - Func
extension MeasureSheetView {
  private func toggleButtonImage() -> String {
    switch viewModel.timerState {
    case .stopped:
      return "play.fill"
    case .running:
      return "pause.fill"
    case .pause:
      return "play.fill"
    }
  }
  
  private func toggleButtonAction() {
    switch viewModel.timerState {
    case .stopped:
      break
    case .running:
      viewModel.timerPause()
    case .pause:
      viewModel.timerResume()
    }
  }
}

//#Preview {
//  MeasureSheetView(viewModel: MeasureViewModel())
//}
