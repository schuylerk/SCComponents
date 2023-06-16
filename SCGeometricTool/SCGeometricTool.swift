//
//  SCGeometricTool.swift
//
//  Created by schuyler on 2023/6/8.
//

import Foundation

class SCGeometricTool {
  ///两条直线交点
  static func intersectionPointOfTwoStraightLines(_ line1: StraightLine, _ line2: StraightLine) -> (x: Double, y: Double)? {
    // x = (b2c1 - b1c2) / (a2b1 - a1b2)
    // y = (a1b1c2 - a1b2c1) / (a2b1b1 - a1b1b2) - c1 / b1
    // - a / b
    let (a1, b1, c1) = line1.getabc()
    let (a2, b2, c2) = line2.getabc()
    // 重合
    if a1 == a2 && b1 == b2 && c1 == c2 { return nil }
    // 平行
    if b1 == 0 && b2 == 0 { return nil }
    if a1 == 0 && a2 == 0 { return nil }
    if b1 * b2 != 0 && (-a1 / b1) == (-a2 / b2) { return nil }
    // 两条直线分别垂直x,y轴
    if a1 == 0 && b2 == 0 { return (-1 * (c2 / a2), -1 * (c1 / b1)) }
    if a2 == 0 && b1 == 0 { return (-1 * (c1 / a1), -1 * (c2 / b2)) }
    
    let x = (b2 * c1 - b1 * c2) / (a2 * b1 - a1 * b2)
    let y: Double
    if b1 == 0 {
      y = (a2 * c1) / (a1 * b2) - c2 / b2
    } else {
      y = (a1 * b1 * c2 - a1 * b2 * c1) / (a2 * b1 * b1 - a1 * b1 * b2) - c1 / b1
    }
    return (x, y)
  }
  
  /// 直线与圆的交点
  static func intersectionPointOfLineAndCircle(_ line: StraightLine, _ circle: Circle) -> [(x: Double, y: Double)]? {
    let centerOfCircle = circle.center
    let distance = distanceFromPointToLine(centerOfCircle, line)
    guard distance <= circle.r else { return nil }
    let (a1, b1, c1) = line.getabc()
    let (a2, b2, r) = circle.getabr()
    let a = a1 * a1 + b1 * b1
    let b = 2 * (a1 * c1 - a2 * b1 * b1 + a1 * b1 * b2)
    let c = c1 * c1 + 2 * b1 * b2 * c1 + a2 * a2 * b1 * b1 + b1 * b1 * b2 * b2 - r * r * b1 * b1
    guard let xValues = solutionOfQuadraticEquation(a, b, c) else { return nil }
    return xValues.map { ($0, line.getValueY($0)) }
  }
  
  /// 点到直线的距离
  static func distanceFromPointToLine(_ point: (x: Double, y: Double), _ line: StraightLine) -> Double {
    guard let verticalLine = StraightLine.vertical(point, line) else { return Double.greatestFiniteMagnitude }
    guard let intersectionPoint = intersectionPointOfTwoStraightLines(line, verticalLine) else { return Double.greatestFiniteMagnitude }
    return distanceBetweenTwoPoints(x1: intersectionPoint.x, y1: intersectionPoint.y, x2: point.x, y2: point.y)
  }
  
  /// 两点之间的距离
  static func distanceBetweenTwoPoints(x1: Double, y1: Double, x2: Double, y2: Double) -> Double {
    return sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
  }
  
  /// 求一元二次方程的解 ax^2 + bx + c = 0
  static func solutionOfQuadraticEquation(_ a: Double, _ b: Double, _ c: Double) -> [Double]? {
    guard a != 0 else { return nil }
    let decisionValue = b * b - 4 * a * c
    guard decisionValue >= 0 else { return nil }
    guard decisionValue > 0 else { return [-b / (2 * a)] }
    let value1 = (-b + sqrt(decisionValue)) / (2 * a)
    let value2 = (-b - sqrt(decisionValue)) / (2 * a)
    return [value1, value2]
  }
  
}

extension SCGeometricTool {
  ///ax + by + c = 0
  struct StraightLine {
    var a: Double
    var b: Double
    var c: Double
    
    init?(a: Double, b: Double, c: Double) {
      if a == 0, b == 0 { return nil }
      self.a = a
      self.b = b
      self.c = c
    }
    
    /// 使用不重合的两个点来创建一条直线
    static func line(x1: Double, y1: Double, x2: Double, y2: Double) -> StraightLine? {
      if x1 == x2, y1 == y2 { return nil }
      if x1 == x2 {
        return StraightLine(a: 1, b: 0, c: -x1)
      }
      if y1 == y2 {
        return StraightLine(a: 0, b: 1, c: -y1)
      }
      let k = (y2 - y1) / (x2 - x1)
      let b = y1 - k * x1
      return StraightLine(a: k, b: -1, c: b)
    }
    
    /// 创建一条线段的中垂线
    static func perpendicularBisector(x1: Double, y1: Double, x2: Double, y2: Double) -> StraightLine? {
      if x1 == x2, y1 == y2 { return nil }
      if x1 == x2 {
        return StraightLine(a: 0, b: 1, c: -(y2 + y1) / 2)
      }
      if y1 == y2 {
        return StraightLine(a: 1, b: 0, c: -(x1 + x2) / 2)
      }
      let middlePoint: (x: Double, y: Double) = ((x1 + x2) / 2, (y1 + y2) / 2)
      let k = -1 / ((y2 - y1) / (x2 - x1))
      let b = middlePoint.y - k * middlePoint.x
      return StraightLine(a: k, b: -1, c: b)
    }
    
    /// 过一点做一条直线的垂线
    static func vertical(_ point: (x: Double, y: Double), _ line: StraightLine) -> StraightLine? {
      let (a, b, _) = line.getabc()
      if a == 0 {
        return StraightLine(a: 1, b: 0, c: -point.x)
      }
      if b == 0 {
        return StraightLine(a: 0, b: 1, c: -point.y)
      }
      let k = -1 / (-a / b)
      let b2 = point.y - k * point.x
      return StraightLine(a: k, b: -1, c: b2)
    }
    
    func getValueY(_ x: Double) -> Double {
      if b == 0 { return Double.greatestFiniteMagnitude }
      return -(a * x + c) / b
    }
    
    func getValueX(_ y: Double) -> Double {
      if a == 0 { return Double.greatestFiniteMagnitude }
      return -(b * y + c) / a
    }
    
    func getabc() -> (Double, Double, Double) {
      return (a, b, c)
    }
  }
  
}

extension SCGeometricTool {
  ///(x－a)^2＋(y－b)^2＝r^2
  struct Circle {
    var a: Double
    var b: Double
    var r: Double
    var center: (x: Double, y: Double) { (a, b) }
    
    init?(a: Double, b: Double, r: Double) {
      guard r > 0 else { return nil }
      self.a = a
      self.b = b
      self.r = r
    }
    
    /// 构造一个圆，它过两点且有一条过第一个点的切线
    static func circle(_ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double, _ line: StraightLine) -> Circle? {
      if x1 == x2 && y1 == y2 { return nil }
      guard line.getValueY(x1) == Double.greatestFiniteMagnitude || line.getValueY(x1) == y1 else { return nil }
      guard let line1 = SCGeometricTool.StraightLine.vertical((x1, y1), line) else { return nil }
      guard let line2 = SCGeometricTool.StraightLine.perpendicularBisector(x1: x1, y1: y1, x2: x2, y2: y2) else { return nil }
      guard let centerOfCircle = SCGeometricTool.intersectionPointOfTwoStraightLines(line1, line2) else { return nil }
      let r = SCGeometricTool.distanceBetweenTwoPoints(x1: x1, y1: y1, x2: centerOfCircle.x, y2: centerOfCircle.y)
      return Circle(a: centerOfCircle.x, b: centerOfCircle.y, r: r)
    }
    
    /// 给定圆上的一点，计算该点的弧度
    func radian(_ x: Double, _ y: Double) -> Double {
      // a^2 = b^2 + c^2 - 2bccosA
      // cosA = (b^2 + c^2 - a^2) / 2bc
      // b == c == r
      // cosA = 1 - a^2 / 2r^2
//      guard (x - a) * (x - a) + (y - b) * (y - b) == r * r else { return Double.greatestFiniteMagnitude }
      let edgeALength = SCGeometricTool.distanceBetweenTwoPoints(x1: x, y1: y, x2: center.x + r, y2: center.y)
      let cosA = 1 - ((edgeALength * edgeALength) / (2 * r * r))
      return acos(cosA)
    }
    
    func getabr() -> (Double, Double, Double) {
      return (a, b, r)
    }
  }
}
