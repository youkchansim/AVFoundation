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
    
    @IBAction func music(_ sender: Any) {
        musicController.play()
    }
    
    @IBAction func musicStop(_ sender: Any) {
        musicController.stop()
    }
    
    @IBAction func start(_ sender: Any) {
        if controller.record {
            print("start success")
            startTimer()
        } else {
            print("start fail")
        }
    }
    
    @IBAction func stop(_ sender: Any) {
        controller.stopWithCompletionHandler{
            self.stopMeterTimer()
            print($0)
        }
    }
    
    @IBAction func save(_ sender: Any) {
        controller.saveRecordingWithName(name: "memo") {
            self.stopMeterTimer()
            if $0, let memo = $1 as? THMemo {
                if controller.playbackMemo(memo: memo) {
                    print("success")
                } else {
                    print("fail")
                }
            }
        }
    }
    
    var levelTimer: CADisplayLink?
    let controller = THRecorderController()
    let musicController = THPlayerController()
    
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
        
        print(levels.level, levels.peakLevel)
        
        levelMeterView.setNeedsDisplay()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
