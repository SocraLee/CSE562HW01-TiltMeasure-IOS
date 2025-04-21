//
//  ViewController.swift
//  TiltSensorDemo
//
//  Created by Yongkang on 4/10/25.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    let sensorManager = SensorManager()
    let calibrationManager = CalibrationManager()
    var measureStartTime: Date?
    var measureSamples: [(timestamp: TimeInterval, angle: Double)] = []
    var currentMode: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        angleLabel.text = "--°"
        calibrationManager.onProgressUpdate = { [weak self] text in self?.calibrationLabel.text = text}
                
        calibrationManager.onCompletion = { [weak self] in
            self?.calibrationLabel.text = "Calibration Complete!"
            // apply calibration result to sensors
            self?.sensorManager.applyCalibration(
                accelBias: self?.calibrationManager.accelBias,
                gyroBias: self?.calibrationManager.gyroBias
            )
            self?.caibrateButton.isEnabled = true
        }
        
        sensorManager.onAngleUpdate = { [weak self] angle in
            DispatchQueue.main.async {
                // update label and plot
                self?.angleLabel.text = String(format: "%.1f°", angle)
                self?.waveformView.addPoint(angle)
                
                // save measure data
                if let start = self?.measureStartTime {
                    let timestamp = Date().timeIntervalSince(start)
                    self?.measureSamples.append((timestamp, angle))
                }
                
            }
        }
    }
    
    @IBOutlet weak var caibrateButton: UIButton!
    
    @IBOutlet weak var angleLabel: UILabel!

    @IBOutlet weak var waveformView: WaveformView!
    
    @IBOutlet weak var calibrationLabel: UILabel!
    
    
    @IBAction func caliTapped(_ sender: UIButton) {
        sender.isEnabled = false
        calibrationManager.startCalibration(duration: 60)
    }
    
    
    @IBAction func accTapped(_ sender: Any) {
        print("acc tapped")
        startMeasurement(mode: "acc")
        sensorManager.startAccelerometerOnly()
    }
    
    
    @IBAction func gyrTapped(_ sender: Any) {
        print("gyr tapped")
        startMeasurement(mode: "gyr")
        sensorManager.startGyroOnly()
    }
    
    @IBAction func fusionTapped(_ sender: Any) {
        print("fusion tapped")
        startMeasurement(mode: "fusion")
        sensorManager.startComplementaryFilter()
    }
    
    
    private func startMeasurement(mode: String) {
        // reset
        measureStartTime = Date()
        measureSamples.removeAll()
        currentMode = mode
        
        // save after 60s
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) { [weak self] in
            guard let self = self else { return }
            let filename = "\(Date().timeIntervalSince1970)_\(self.currentMode).csv"
            DataSaver.saveMeasurementData(data: self.measureSamples, filename: filename)
            
            
            self.measureStartTime = Date()
            self.measureSamples.removeAll()
        }
    }

    
}

