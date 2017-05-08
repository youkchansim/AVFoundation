//
//  THPlayerController.swift
//  AVFoundationiOS
//
//  Created by Youk Chansim on 2017. 5. 8..
//  Copyright © 2017년 Youk Chansim. All rights reserved.
//

import AVFoundation

class THPlayerController: NSObject {
    var playing = false
    var players: [AVAudioPlayer?] = []
    var delegate: THPlayerControllerDelegate?
    
    override init() {
        super.init()
        
        let guitarPlayer = playerForFile(name: "guitar")
        let basePlayer = playerForFile(name: "base")
        let drumsPlayer = playerForFile(name: "drums")
        
        players = [guitarPlayer, basePlayer, drumsPlayer]
        
        let nsnc = NotificationCenter.default
        nsnc.addObserver(self, selector: #selector(handelInterruption(notification:)), name: .AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
        nsnc.addObserver(self, selector: #selector(handleRouteChange(notification:)), name: .AVAudioSessionRouteChange, object: AVAudioSession.sharedInstance())
    }
    
    func playerForFile(name: String) -> AVAudioPlayer? {
        if let fileURL = Bundle.main.url(forResource: name, withExtension: "caf"), let player = try? AVAudioPlayer(contentsOf: fileURL) {
            player.numberOfLoops = -1
            player.enableRate = true
            player.prepareToPlay()
            
            return player
        }
        
        return nil
    }
    
    func play() {
        if !playing {
            let delayTime = players[0]?.deviceCurrentTime ?? 0 + 0.01
            for player in players {
                player?.play(atTime: delayTime)
            }
            playing = true
        }
    }
    
    func stop() {
        if playing {
            for player in players {
                player?.stop()
                player?.currentTime = 0.0
            }
        }
    }
    
    func adjustRate(rate: Float) {
        for player in players {
            player?.rate = rate
        }
    }
    
    func adjustPan(pan: Float, index: Int) {
        if isValidIndex(index: index) {
            let player = players[index]
            player?.pan = pan
        }
    }
    
    func adjustVolume(volume: Float, index: Int) {
        if isValidIndex(index: index) {
            let player = players[index]
            player?.volume = volume
        }
    }
    
    func isValidIndex(index: Int) -> Bool {
        return index == 0 || index < players.count
    }
    
    func handelInterruption(notification: Notification) {
        if let info = notification.userInfo, let type = info[AVAudioSessionInterruptionTypeKey] as? AVAudioSessionInterruptionType {
            switch type {
            case .began:
                delegate?.playbackStopped()
            case .ended:
                if let options = info[AVAudioSessionInterruptionOptionKey] as? AVAudioSessionInterruptionOptions {
                    if options == .shouldResume {
                        play()
                        delegate?.playbackBegan()
                    }
                }
            }
        }
    }
    
    func handleRouteChange(notification: Notification) {
        if let info = notification.userInfo, let type = info[AVAudioSessionRouteChangeReasonKey] as? AVAudioSessionRouteChangeReason {
            switch type {
            case .oldDeviceUnavailable:
                if let previousRoute = info[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                    let previousOutput = previousRoute.outputs[0]
                    let portType = previousOutput.portType
                    if portType == AVAudioSessionPortHeadphones {
                        stop()
                        delegate?.playbackStopped()
                    }
                }
            default:
                break
            }
        }
    }
}

protocol THPlayerControllerDelegate {
    func playbackStopped()
    func playbackBegan()
}
