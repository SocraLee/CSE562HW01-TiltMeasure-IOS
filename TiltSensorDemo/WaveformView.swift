//
//  WaveformView.swift
//  TiltSensorDemo
//
//  Created by 李永康 on 4/18/25.
//

import Foundation
import UIKit

class WaveformView: UIView {
    private var points: [Double] = []
    private let maxPoints = 100       // max points on the plot
    
    func addPoint(_ value: Double) {
        points.append(value)
        if points.count > maxPoints {
            points.removeFirst()
        }
        
        // plot
        UIView.animate(withDuration: 0.1) {
            self.setNeedsDisplay()
        }
    }

    private let minValue: Double = -100.0 // 固定显示范围
    private let maxValue: Double = 100.0
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // clear background
        context.setFillColor(UIColor.systemBackground.cgColor)
        context.fill(rect)
        
        // grid
        drawGrid(in: rect)
        
        // plot
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
    
    // transform angles to loc
    private func normalizedY(for value: Double, in rect: CGRect) -> CGFloat {
        let scaleY = rect.height / CGFloat(maxValue - minValue)
        return rect.midY - CGFloat(value) * scaleY
    }
    

    private func drawGrid(in rect: CGRect) {
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular),
            .foregroundColor: UIColor.secondaryLabel
        ]
        
        
        for value in stride(from: -90, through: 90, by: 90) {
            let y = normalizedY(for: Double(value), in: rect)
            
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
            UIColor.separator.setStroke()
            path.stroke()
            
            let label = "\(value)°"
            let size = label.size(withAttributes: textAttributes)
            label.draw(at: CGPoint(x: 8, y: y - size.height/2), withAttributes: textAttributes)
        }
    }
}
