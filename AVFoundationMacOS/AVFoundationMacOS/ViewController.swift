//
//  ViewController.swift
//  AVFoundationMacOS
//
//  Created by Youk Chansim on 2017. 4. 23..
//  Copyright © 2017년 Youk Chansim. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let synthesizer = NSSpeechSynthesizer()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

