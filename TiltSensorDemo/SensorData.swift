//
//  SensorData.swift
//  TiltSensorDemo
//
//  Created by 李永康 on 4/16/25.
//
import Foundation

struct DataSaver {
    static func saveAllData(accelSamples: [(x: Double, y: Double, z: Double)],
                           gyroSamples: [(x: Double, y: Double, z: Double)],
                           accelBias: (x: Double, y: Double, z: Double),
                           accelVariance: (x: Double, y: Double, z: Double),
                           gyroBias: (x: Double, y: Double, z: Double),
                           gyroVariance: (x: Double, y: Double, z: Double)) {
        
        let prefix = generateFilenamePrefix()
        saveRawData(accel: accelSamples, gyro: gyroSamples, filename: "\(prefix)_raw.csv")
        saveResults(accelBias: accelBias, accelVar: accelVariance,
                   gyroBias: gyroBias, gyroVar: gyroVariance,
                   filename: "\(prefix)_results.csv")
    }
    
    // timestamp
    private static func generateFilenamePrefix() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter.string(from: Date())
    }
    
    // save raw data
    private static func saveRawData(accel: [(x: Double, y: Double, z: Double)],
                                   gyro: [(x: Double, y: Double, z: Double)],
                                   filename: String) {
        var csv = "timestamp,acc_x,acc_y,acc_z,gyro_x,gyro_y,gyro_z\n"
        let count = min(accel.count, gyro.count)
        
        for i in 0..<count {
            let a = accel[i]
            let g = gyro[i]
            csv += String(format: "%.4f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\n",
                         Double(i)*0.01, a.x, a.y, a.z, g.x, g.y, g.z)
        }
        
        saveToFile(content: csv, filename: filename)
    }
    
    // save calculated results
    private static func saveResults(accelBias: (x: Double, y: Double, z: Double),
                                    accelVar: (x: Double, y: Double, z: Double),
                                    gyroBias: (x: Double, y: Double, z: Double),
                                    gyroVar: (x: Double, y: Double, z: Double),
                                    filename: String) {
        let csv = """
        sensor,axis,bias,variance
        acc,x,\(accelBias.x),\(accelVar.x)
        acc,y,\(accelBias.y),\(accelVar.y)
        acc,z,\(accelBias.z),\(accelVar.z)
        gyro,x,\(gyroBias.x),\(gyroVar.x)
        gyro,y,\(gyroBias.y),\(gyroVar.y)
        gyro,z,\(gyroBias.z),\(gyroVar.z)
        """
        
        saveToFile(content: csv, filename: filename)
    }
    
    static func saveMeasurementData(data: [(timestamp: TimeInterval, angle: Double)], filename: String) {
        var csv = "timestamp,angle\n"
        for entry in data {
            csv += String(format: "%.3f,%.2f\n", entry.timestamp, entry.angle)
        }
        saveToFile(content: csv, filename: filename)
    }
    
    private static func saveToFile(content: String, filename: String) {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileURL = dir.appendingPathComponent(filename)
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Saved: \(fileURL.path)")
        } catch {
            print("Save failed: \(error)")
        }
    }
}
