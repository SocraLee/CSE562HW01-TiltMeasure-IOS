//
//  CalibrationManager.swift
//  TiltSensorDemo
//
//  Created by 李永康 on 4/17/25.
//

import Foundation
import CoreMotion

class CalibrationManager {
    // MARK: - 数据存储
    private var accelSamples: [(x: Double, y: Double, z: Double)] = []
    private var gyroSamples: [(x: Double, y: Double, z: Double)] = []
    
    // MARK: - 校准结果
    var accelBias: (x: Double, y: Double, z: Double) = (0,0,0)
    var gyroBias: (x: Double, y: Double, z: Double) = (0,0,0)
    var accelVariance: (x: Double, y: Double, z: Double) = (0,0,0)
    var gyroVariance: (x: Double, y: Double, z: Double) = (0,0,0)
    
    // MARK: - 状态控制
    private let motionManager = CMMotionManager()
    private var calibrationTimer: Timer?
    private var isCalibrating = false
    
    // MARK: - 回调接口
    var onProgressUpdate: ((String) -> Void)? // 进度文本更新
    var onCompletion: (() -> Void)?           // 校准完成回调
    
    func startCalibration(duration: Int) {
        guard !isCalibrating else { return }
        isCalibrating = true
        
        resetSamples()
        startSensorCollection()
        startTimer(duration: duration)
    }
    
    private func resetSamples() {
        accelSamples.removeAll()
        gyroSamples.removeAll()
    }
    
    private func startSensorCollection() {
        motionManager.accelerometerUpdateInterval = 0.01
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let data = data else { return }
            self?.accelSamples.append((data.acceleration.x, data.acceleration.y, data.acceleration.z))
        }
        
        motionManager.gyroUpdateInterval = 0.01
        motionManager.startGyroUpdates(to: .main) { [weak self] data, _ in
            guard let data = data else { return }
            self?.gyroSamples.append((data.rotationRate.x, data.rotationRate.y, data.rotationRate.z))
        }
    }
    
    private func startTimer(duration: Int) {
        var remaining = duration
        calibrationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            remaining -= 1
            self?.onProgressUpdate?("Calibrating... \(remaining)s")
            
            if remaining <= 0 {
                self?.stopCalibration()
                self?.calculateBiasAndVariance()
                self?.onCompletion?()
            }
        }
    }
    
    func stopCalibration() {
        isCalibrating = false
        calibrationTimer?.invalidate()
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
    }
    
    private func calculateBiasAndVariance() {
        calculateAccelMetrics()
        calculateGyroMetrics()
        saveData()
    }
    
    private func calculateAccelMetrics() {
        accelBias.x = accelSamples.map { $0.x }.reduce(0, +) / Double(accelSamples.count)
        accelVariance.x = accelSamples.map { pow($0.x - accelBias.x, 2) }.reduce(0, +) / Double(accelSamples.count)
        // 其他轴同理
    }
    
    private func calculateGyroMetrics() {
        gyroBias.x = gyroSamples.map { $0.x }.reduce(0, +) / Double(gyroSamples.count)
        gyroVariance.x = gyroSamples.map { pow($0.x - gyroBias.x, 2) }.reduce(0, +) / Double(gyroSamples.count)
        // 其他轴同理
    }
    
    private func saveData() {
        DataSaver.saveAllData(
            accelSamples: accelSamples,
            gyroSamples: gyroSamples,
            accelBias: accelBias,
            accelVariance: accelVariance,
            gyroBias: gyroBias,
            gyroVariance: gyroVariance
        )
    }
}
