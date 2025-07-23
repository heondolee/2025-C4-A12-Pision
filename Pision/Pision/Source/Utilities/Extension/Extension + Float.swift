//
//  Extension + Float.swift
//  Pision
//
//  Created by 여성일 on 7/22/25.
//

import Foundation

extension Array where Element == Float {
  func average() -> Float {
    guard !isEmpty else { return 0 }
    return self.reduce(0, +) / Float(self.count)
  }
}
