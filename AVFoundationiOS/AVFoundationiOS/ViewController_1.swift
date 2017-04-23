//
//  ViewController.swift
//  AVFoundationiOS
//
//  Created by Youk Chansim on 2017. 4. 24..
//  Copyright © 2017년 Youk Chansim. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: "Hello World!")
        synthesizer.speak(utterance)
    }
}
