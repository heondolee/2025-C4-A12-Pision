//
//  Extension + Int.swift
//  Pision
//
//  Created by 여성일 on 7/23/25.
//

import Foundation

extension Int {
  /// 정수(Int)를 `Float` 타입으로 변환합니다.
  ///
  /// `Float(값)`을 직접 사용하는 대신, 간결하게 타입 변환을 할 수 있습니다.
  ///
  /// ```
  /// let intValue = 5
  /// let floatValue = intValue.f  // 5.0
  /// ```
  var f: Float { Float(self) }
}
