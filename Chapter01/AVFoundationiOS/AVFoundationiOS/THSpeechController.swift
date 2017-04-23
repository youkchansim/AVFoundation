//
//  THSpeechController.swift
//  AVFoundationiOS
//
//  Created by Youk Chansim on 2017. 4. 24..
//  Copyright © 2017년 Youk Chansim. All rights reserved.
//

import Foundation
import AVFoundation

class THSpeechController {
    let synthesizer = AVSpeechSynthesizer()
    let voices = [
        AVSpeechSynthesisVoice(language: "ko-KR"),
        AVSpeechSynthesisVoice(language: "en-GB"),
    ]
    let speechStrings = [
        "안녕? 나는 육찬심이라고해",
        "Hi? My name is jobs. I'm ~",
        "우와 이거 되게 신기하다. 한글도 잘 되네",
        "Very! I have always felt so misun-derstood",
        "AV Foundation 정말 어렵지 않니?",
        "Oh, they're all my babies. couldn't possibly choose.",
        "정말 멋진 기능이다 이거!",
        "The pleasure was all mine! Have fun!"
    ]
}

extension THSpeechController {
    func beginConversation() {
        for (index, string) in speechStrings.enumerated() {
            let utterance = AVSpeechUtterance(string: string)
            utterance.voice = voices[index % 2]
            utterance.rate = 0.4
            utterance.pitchMultiplier = 0.8
            utterance.postUtteranceDelay = 0.1
            synthesizer.speak(utterance)
        }
    }
}
