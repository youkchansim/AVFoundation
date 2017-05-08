//
//  MainViewController.swift
//  AVFoundationiOS
//
//  Created by Youk Chansim on 2017. 5. 8..
//  Copyright © 2017년 Youk Chansim. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var levelMeterView: MeterView!
    
    var levelTimer: CADisplayLink?
    let controller = THRecorderController()
    
    func startTimer() {
        levelTimer?.invalidate()
        
        levelTimer = CADisplayLink(target: self, selector: #selector(updateDisplay))
        levelTimer?.preferredFramesPerSecond = 5
        levelTimer?.add(to: RunLoop.current, forMode: .commonModes)
    }
    
    func stopMeterTimer() {
        levelTimer?.invalidate()
        levelTimer = nil
        levelMeterView.resetLevelMeter()
    }
    
    func updateDisplay() {
        let levels = controller.levels
        
        levelMeterView.level = levels.level
        levelMeterView.peakLevel = levels.peakLevel
        
        levelMeterView.setNeedsDisplay()
    }
}

class MeterView: UIView {
    var level: Float = 0
    var peakLevel: Float = 0
    
    func resetLevelMeter() {
        level = 0
        peakLevel = 0
    }
}
