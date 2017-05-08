//
//  MeterView.swift
//  AVFoundationiOS
//
//  Created by Youk Chansim on 2017. 5. 8..
//  Copyright © 2017년 Youk Chansim. All rights reserved.
//

import UIKit

class MeterView: UIView {
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var peakLevelLabel: UILabel!
    
    var level: Float = 0
    var peakLevel: Float = 0
    
    func resetLevelMeter() {
        level = 0
        peakLevel = 0
        
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
//        levelLabel.text = "\(level)"
//        peakLevelLabel.text = "\(peakLevelLabel)"
    }
}
