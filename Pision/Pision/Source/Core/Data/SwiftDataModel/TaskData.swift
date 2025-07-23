//
//  TaskData.swift
//  Pision
//
//  Created by 여성일 on 7/23/25.
//

import Foundation
import SwiftData

@Model
class TaskData {
  @Attribute(.unique) var id: UUID = UUID()
  var startTime: Date
  var endTime: Date
  var averageScore: Float
  var focusRatio: [Float]
  var focusTime: Int
  var durationTime: Int
  
  @Relationship(deleteRule: .cascade) var avgCoreDatas: [AvgCoreScore]
  @Relationship(deleteRule: .cascade) var avgAuxDatas: [AvgAuxScore]
  
  init(
    startTime: Date,
    endTime: Date,
    averageScore: Float,
    focusRatio: [Float],
    focusTime: Int,
    durationTime: Int,
    avgCoreDatas: [AvgCoreScore],
    avgAuxDatas: [AvgAuxScore]
  ) {
    self.startTime = startTime
    self.endTime = endTime
    self.averageScore = averageScore
    self.focusRatio = focusRatio
    self.focusTime = focusTime
    self.durationTime = durationTime
    self.avgCoreDatas = avgCoreDatas
    self.avgAuxDatas = avgAuxDatas
  }
}
