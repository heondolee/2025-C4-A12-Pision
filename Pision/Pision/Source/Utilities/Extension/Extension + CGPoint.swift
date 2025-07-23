//
//  Extension + CGPoint.swift
//  Pision
//
//  Created by 여성일 on 7/21/25.
//

import Foundation

extension CGPoint {
  /// 두 점 사이의 유클리드 거리(눈 사이 거리 등)를 계산합니다.
  /// `self`는 기준 좌표이며, `other`는 비교 대상 좌표입니다.
  /// - Parameter other: 비교할 다른 CGPoint 좌표
  /// - Returns: 두 점 사이의 거리 (`CGFloat`)
  func eyeDistance(to other: CGPoint) -> CGFloat {
    hypot(self.x - other.x, self.y - other.y)
  }
}
