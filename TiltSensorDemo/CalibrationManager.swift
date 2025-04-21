//
//  CalibrationManager.swift
//  TiltSensorDemo
//
//  Created by 李永康 on 4/17/25.
//

import Foundation
import CoreMotion

class CalibrationManager {
    
    private var accelSamples: [(x: Double, y: Double, z: Double)] = []
    private var gyroSamples: [(x: Double, y: Double, z: Double)] = []
    
    var accelBias: (x: Double, y: Double, z: Double) = (0,0,0)
    var gyroBias: (x: Double, y: Double, z: Double) = (0,0,0)
    var accelVariance: (x: Double, y: Double, z: Double) = (0,0,0)
    var gyroVariance: (x: Double, y: Double, z: Double) = (0,0,0)
    
    private let motionManager = CMMotionManager()
    private var calibrationTimer: Timer?
    private var isCalibrating = false
    
    var onProgressUpdate: ((String) -> Void)?
    var onCompletion: (() -> Void)?
    
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
        
        accelBias.y = accelSamples.map { $0.y }.reduce(0, +) / Double(accelSamples.count)
        accelVariance.y = accelSamples.map { pow($0.y - accelBias.y, 2) }.reduce(0, +) / Double(accelSamples.count)
        
        accelBias.z = accelSamples.map { $0.z }.reduce(0, +) / Double(accelSamples.count)
        accelVariance.z = accelSamples.map { pow($0.z - accelBias.z, 2) }.reduce(0, +) / Double(accelSamples.count)
        
    }
    
    private func calculateGyroMetrics() {
        gyroBias.x = gyroSamples.map { $0.x }.reduce(0, +) / Double(gyroSamples.count)
        gyroVariance.x = gyroSamples.map { pow($0.x - gyroBias.x, 2) }.reduce(0, +) / Double(gyroSamples.count)
        
        gyroBias.y = gyroSamples.map { $0.y }.reduce(0, +) / Double(gyroSamples.count)
        gyroVariance.y = gyroSamples.map { pow($0.y - gyroBias.y, 2) }.reduce(0, +) / Double(gyroSamples.count)
        
        gyroBias.z = gyroSamples.map { $0.z }.reduce(0, +) / Double(gyroSamples.count)
        gyroVariance.z = gyroSamples.map { pow($0.x - gyroBias.z, 2) }.reduce(0, +) / Double(gyroSamples.count)
        
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
