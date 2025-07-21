//
//  RecordView.swift
//  Pision
//
//  Created by 여성일 on 7/14/25.
//

import AVFoundation
import CoreML
import SwiftUI

// MARK: - Var
struct MeasureView: View {
  // ViewModel
  @StateObject private var viewModel: MeasureViewModel
  
  // General Var
  @State private var isSheetPresented: Bool = false
  @State private var isBottomButtonPresented: Bool = true
  
  // init
  init() {
    _viewModel = StateObject(wrappedValue: MeasureViewModel())
  }
}

// MARK: - View
extension MeasureView {
  var body: some View {
    ZStack(alignment: .top) {
      Color.clear.ignoresSafeArea()
      
      CameraView(session: viewModel.session)
        .ignoresSafeArea()
      
      LinearGradient(colors: [Color.gradientGray, Color.white.opacity(0)], startPoint: .top, endPoint: .bottom)
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: 116)
      
      VStack {
        MeasureToggleButtonView(
          viewModel: viewModel,
          buttonWidth: 63,
          height: 38
        )
        
        Spacer()
        
        MeasureSheetView(viewModel: viewModel)
          .frame(maxWidth: .infinity, maxHeight: 196)
      }
    }
    .onAppear {
      viewModel.cameraStart()
    }
    .onDisappear {
      viewModel.cameraStop()
    }
  }
  
  private var MeasureBottomView: some View {
    ZStack(alignment: .center) {
      if viewModel.timerState == .stopped {
        Button {
          viewModel.timerStart()
          updateBottomButtonVisibility()
        } label: {
          Image(systemName: "play.fill")
            .foregroundStyle(.white)
            .frame(width: 70, height: 70)
            .background(.blue)
            .clipShape(.circle)
        }
        .buttonStyle(.plain)
      } else {
        Button {
          showSheet()
        } label : {
          Image(systemName: "note.text")
            .foregroundStyle(.white)
            .frame(width: 70, height: 70)
            .background(.gray)
            .clipShape(.circle)
        }
      }
    }
  }
}

// MARK: - Func
extension MeasureView {
  private func showSheet() {
    isSheetPresented = true
  }
  
  private func updateBottomButtonVisibility() {
    isBottomButtonPresented = false
  }
}

#Preview {
  MeasureView()
}


