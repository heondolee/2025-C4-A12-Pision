//
//  AuxScore.swift
//  Pision
//
//  Created by 여성일 on 7/23/25.


import SwiftData

@Model
class AvgAuxScore {
  var avgBlinkScore: Float
  var avgYawStabilityScore: Float
  var avgMlSnoozeScore: Float
  var avgAuxScore: Float
  
  init(
    avgBlinkScore: Float,
    avgYawStabilityScore: Float,
    avgMlSnoozeScore: Float,
    avgAuxScore: Float
  ) {
    self.avgBlinkScore = avgBlinkScore
    self.avgYawStabilityScore = avgYawStabilityScore
    self.avgMlSnoozeScore = avgMlSnoozeScore
    self.avgAuxScore = avgAuxScore
  }
}
