//
//  SensorManager.swift
//  TiltSensorDemo
//
//  Created by 李永康 on 4/17/25.
//

import CoreMotion

class SensorManager {
    // MARK: - 配置参数
    let motionManager = CMMotionManager()
    var currentAngle: Double = 0.0
    var lastUpdateTime = Date()
    let alpha: Double = 0.98
    
    init() {
        print("initializing interval to 0.01")
        motionManager.accelerometerUpdateInterval = 0.01
        motionManager.gyroUpdateInterval = 0.01
    }
    
    // MARK: - 校准数据
    var accelBias: (x: Double, y: Double, z: Double) = (0,0,0)
    var gyroBias: (x: Double, y: Double, z: Double) = (0,0,0)
    
    // MARK: - 回调闭包
    var onAngleUpdate: ((Double) -> Void)?
    
    // MARK: - 传感器控制
    func startAccelerometerOnly() {
            stopAllSensors()
            
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
                guard let self = self, let data = data else { return }
                
                let x = data.acceleration.x - self.accelBias.x
                let y = data.acceleration.y - self.accelBias.y
                let z = data.acceleration.z - self.accelBias.z
                
                // 计算俯仰角
                let pitch = atan2(y, sqrt(x*x + z*z)) * 180 / .pi
                let tiltAngle = -pitch // 转换为设备长轴与水平面的夹角
                
                self.onAngleUpdate?(tiltAngle)
            }
        }
        
        func startGyroOnly() {
            stopAllSensors()
            currentAngle = 0.0
            lastUpdateTime = Date()
            
            motionManager.startGyroUpdates(to: .main) { [weak self] data, _ in
                guard let self = self, let data = data else { return }
                
                let dt = Date().timeIntervalSince(self.lastUpdateTime)
                self.lastUpdateTime = Date()
                
                // 积分绕X轴的角速度
                let rateX = data.rotationRate.x - self.gyroBias.x
                self.currentAngle += rateX * dt * 180 / .pi
                
                self.onAngleUpdate?(self.currentAngle)
            }
        }
        
        func startComplementaryFilter() {
            stopAllSensors()
            currentAngle = 0.0
            lastUpdateTime = Date()
            var lastAccelAngle: Double = 0.0
            
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
                guard let self = self, let data = data else { return }
                
                let x = data.acceleration.x - self.accelBias.x
                let y = data.acceleration.y - self.accelBias.y
                let z = data.acceleration.z - self.accelBias.z
                
                let pitch = atan2(y, sqrt(x*x + z*z)) * 180 / .pi
                lastAccelAngle = -pitch // 转换基准
            }
            
            motionManager.startGyroUpdates(to: .main) { [weak self] data, _ in
                guard let self = self, let data = data else { return }
                
                let dt = Date().timeIntervalSince(self.lastUpdateTime)
                self.lastUpdateTime = Date()
                
                let rateX = data.rotationRate.x - self.gyroBias.x
                let gyroAngle = self.currentAngle + rateX * dt * 180 / .pi
                
                self.currentAngle = self.alpha * gyroAngle + (1 - self.alpha) * lastAccelAngle
                self.onAngleUpdate?(self.currentAngle)
            }
        }
    
    func stopAllSensors() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
    }
    func applyCalibration(accelBias: (x: Double, y: Double, z: Double)?,
                         gyroBias: (x: Double, y: Double, z: Double)?) {
        if let accelBias = accelBias {
            self.accelBias = accelBias
        }
        if let gyroBias = gyroBias {
            self.gyroBias = gyroBias
        }
    }
}
