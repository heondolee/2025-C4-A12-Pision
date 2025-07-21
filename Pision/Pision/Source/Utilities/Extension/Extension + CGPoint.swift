//
//  Extension + CGPoint.swift
//  Pision
//
//  Created by 여성일 on 7/21/25.
//

import Foundation

extension CGPoint {
  func eyeDistance(to other: CGPoint) -> CGFloat {
    hypot(self.x - other.x, self.y - other.y)
  }
}
