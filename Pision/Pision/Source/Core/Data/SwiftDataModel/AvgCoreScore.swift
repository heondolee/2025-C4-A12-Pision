//
//  AvgCoreScore.swift
//  Pision
//
//  Created by 여성일 on 7/23/25.
//

import SwiftData

@Model
class AvgCoreScore {
  var avgYawScore: Float
  var avgEyeOpenScore: Float
  var avgEyeClosedScore: Float
  var avgBlinkFrequency: Float
  var avgCoreScore: Float
  
  init(
    avgYawScore: Float,
    avgEyeOpenScore: Float,
    avgEyeClosedScore: Float,
    avgBlinkFrequency: Float,
    avgCoreScore: Float
  ) {
    self.avgYawScore = avgYawScore
    self.avgEyeOpenScore = avgEyeOpenScore
    self.avgEyeClosedScore = avgEyeClosedScore
    self.avgBlinkFrequency = avgBlinkFrequency
    self.avgCoreScore = avgCoreScore
  }
}
