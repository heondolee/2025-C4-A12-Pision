//
//  Extension + Float.swift
//  Pision
//
//  Created by 여성일 on 7/22/25.
//

import Foundation

extension Array where Element == Float {
  /// Float 배열의 평균을 계산합니다.
  /// 배열이 비어 있으면 0을 반환합니다.
  func average() -> Float {
    guard !isEmpty else { return 0 }
    return self.reduce(0, +) / Float(self.count)
  }
}
