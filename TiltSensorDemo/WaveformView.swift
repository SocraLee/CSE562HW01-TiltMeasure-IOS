//
//  WaveformView.swift
//  TiltSensorDemo
//
//  Created by 李永康 on 4/18/25.
//

import Foundation
import UIKit

class WaveformView: UIView {
    private var points: [Double] = [] // 存储最近的N个角度值
    private let maxPoints = 100       // 显示的最大点数
    
    func addPoint(_ value: Double) {
        points.append(value)
        if points.count > maxPoints {
            points.removeFirst()
        }
        
        // 添加平移动画
        UIView.animate(withDuration: 0.1) {
            self.setNeedsDisplay()
        }
    }
    
//    override func draw(_ rect: CGRect) {
//
//        guard let context = UIGraphicsGetCurrentContext() else { return }
//        // 清空背景
//        context.setFillColor(UIColor.white.cgColor)
//        context.fill(rect)
//        
//        // 绘制中线
//        context.setStrokeColor(UIColor.lightGray.cgColor)
//        context.move(to: CGPoint(x: 0, y: rect.midY))
//        context.addLine(to: CGPoint(x: rect.width, y: rect.midY))
//        context.strokePath()
//        
//        // 绘制刻度
//        let textAttributes: [NSAttributedString.Key: Any] = [
//            .font: UIFont.systemFont(ofSize: 12),
//            .foregroundColor: UIColor.gray
//        ]
//        "-90°".draw(at: CGPoint(x: 5, y: rect.height-20), withAttributes: textAttributes)
//        "0°".draw(at: CGPoint(x: 5, y: rect.midY-10), withAttributes: textAttributes)
//        "90°".draw(at: CGPoint(x: 5, y: 10), withAttributes: textAttributes)
//        
//        // 绘制波形
//        context.setStrokeColor(UIColor.blue.cgColor)
//        context.beginPath()
//        
//        let xStep = rect.width / CGFloat(maxPoints)
//        for (index, value) in points.enumerated() {
//            let x = CGFloat(index) * xStep
//            let y = rect.midY - CGFloat(value) * 2 // 缩放系数调节灵敏度
//            index == 0 ? context.move(to: CGPoint(x: x, y: y)) :
//                         context.addLine(to: CGPoint(x: x, y: y))
//        }
//        context.strokePath()
//    }

    private let minValue: Double = -100.0 // 固定显示范围
    private let maxValue: Double = 100.0
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 清空背景
        context.setFillColor(UIColor.systemBackground.cgColor)
        context.fill(rect)
        
        // 绘制刻度线
        drawGrid(in: rect)
        
        // 绘制波形
        context.setStrokeColor(UIColor.systemBlue.cgColor)
        context.setLineWidth(2.0)
        context.beginPath()
        
        let xStep = rect.width / CGFloat(maxPoints)
        for (index, value) in points.enumerated() {
            let x = CGFloat(index) * xStep
            let y = normalizedY(for: value, in: rect)
            
            if index == 0 {
                context.move(to: CGPoint(x: x, y: y))
            } else {
                context.addLine(to: CGPoint(x: x, y: y))
            }
        }
        context.strokePath()
    }
    
    // 将角度值转换为视图Y坐标
    private func normalizedY(for value: Double, in rect: CGRect) -> CGFloat {
        let scaleY = rect.height / CGFloat(maxValue - minValue)
        return rect.midY - CGFloat(value) * scaleY
    }
    
    // 绘制刻度网格
    private func drawGrid(in rect: CGRect) {
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular),
            .foregroundColor: UIColor.secondaryLabel
        ]
        
        // 水平线
        for value in stride(from: -90, through: 90, by: 90) {
            let y = normalizedY(for: Double(value), in: rect)
            
            // 刻度线
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
            UIColor.separator.setStroke()
            path.stroke()
            
            // 刻度标签
            let label = "\(value)°"
            let size = label.size(withAttributes: textAttributes)
            label.draw(at: CGPoint(x: 8, y: y - size.height/2), withAttributes: textAttributes)
        }
    }
}
