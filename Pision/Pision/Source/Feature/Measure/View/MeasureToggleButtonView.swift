//
//  MeasureToggleButtonView.swift
//  Pision
//
//  Created by 여성일 on 7/20/25.
//

import SwiftUI

// MARK: - Var
struct MeasureToggleButtonView: View {
  // ViewModel
  @ObservedObject private var viewModel: MeasureViewModel

  // General Var
  let buttonWidth: CGFloat
  let height: CGFloat
  
  // init
  init(
    viewModel: MeasureViewModel,
    buttonWidth: CGFloat,
    height: CGFloat
  ) {
    self.viewModel = viewModel
    self.buttonWidth = buttonWidth
    self.height = height
  }
}

// MARK: - View
extension MeasureToggleButtonView {
  var body: some View {
    ZStack(alignment: .leading) {
      Capsule()
        .fill(.black.opacity(0.4))
        .frame(width: buttonWidth * 2, height: height)
      
      Capsule()
        .fill(.white)
        .frame(width: buttonWidth, height: height)
        .offset(x: viewModel.isAutoBrightnessModeOn ? buttonWidth : 0)
        .animation(.easeInOut(duration: 0.25), value: viewModel.isAutoBrightnessModeOn)
      
      HStack(spacing: 0) {
        Button {
          withAnimation {
            viewModel.isAutoBrightnessModeOn.toggle()
          }
        } label: {
          Text("자동꺼짐")
            .font(.system(size: 12))
            .fontWeight(.bold)
            .foregroundStyle(!viewModel.isAutoBrightnessModeOn ? .black : .white)
            .frame(width: buttonWidth, height: height)
        }
        
        Button {
          withAnimation {
            viewModel.isAutoBrightnessModeOn.toggle()
          }
        } label: {
          Text("계속보기")
            .font(.system(size: 12))
            .fontWeight(.bold)
            .foregroundStyle(viewModel.isAutoBrightnessModeOn ? .black : .white)
            .frame(width: buttonWidth, height: height)
        }
      }
    }
    .clipShape(Capsule())
    .padding(.horizontal, 16)
  }
}

#Preview {
  MeasureToggleButtonView(viewModel: MeasureViewModel(), buttonWidth: 63, height: 36)
}
