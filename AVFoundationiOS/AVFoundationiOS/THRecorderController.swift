//
//  THRecorderController.swift
//  AVFoundationiOS
//
//  Created by Youk Chansim on 2017. 5. 8..
//  Copyright © 2017년 Youk Chansim. All rights reserved.
//

import AVFoundation

typealias THRecordingStopCompletionHandler = (Bool) -> Void
typealias THRecordingSaveCompletionHandler = (Bool, Any) -> Void

class THRecorderController: NSObject {
    var player: AVAudioPlayer?
    var recorder: AVAudioRecorder?
    var completionHandler: THRecordingStopCompletionHandler?
    var meterTable: THMeterTable?
    
    var documentDirectory: String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        return path
    }
    
    override init() {
        super.init()
        
        let tmpDir = NSTemporaryDirectory()
        let filePath = tmpDir + "/memo.caf"
        let fileURL = URL(fileURLWithPath: filePath)
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatAppleIMA4,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderBitDepthHintKey: 16,
            AVEncoderAudioQualityKey: AVAudioQuality.medium
        ]
        
        recorder = try? AVAudioRecorder(url: fileURL, settings: settings)
        recorder?.delegate = self
        recorder?.prepareToRecord()
        
        meterTable = THMeterTable()
    }
    
    var record: Bool {
        return recorder?.isRecording ?? false
    }
    
    func pause() {
        recorder?.pause()
    }
    
    func stopWithCompletionHandler(handler: @escaping THRecordingStopCompletionHandler) {
        completionHandler = handler
        recorder?.stop()
    }
    
    func saveRecordingWithName(name: String, handler: THRecordingSaveCompletionHandler) {
        let timestamp = Date.timeIntervalSinceReferenceDate
        let fileName = String(format: "%@-%f.caf", name, timestamp)
        
        let docsDir = documentDirectory
        let destPath = docsDir + "/\(fileName)"
        
        let destURL = URL(fileURLWithPath: destPath)
        if let srcURL = recorder?.url {
            do {
                try FileManager.default.copyItem(at: srcURL, to: destURL)
                handler(true, THMemo(memoWithTitle: name, url: destURL))
            } catch(let e) {
                handler(false, e)
            }
        }
    }
    
    func playbackMemo(memo: THMemo) -> Bool {
        player?.stop()
        do {
            player = try AVAudioPlayer(contentsOf: memo.url)
            player?.play()
            return true
        } catch {
            return false
        }
    }
    
    func formattedCurrentTime() -> String {
        let time = Int(recorder?.currentTime ?? 0)
        
        let hours = time / 3600
        let minutes = (time / 60) % 60
        let seconds = time % 60
        
        let format = "%02i:%02i:%02i"
        return String(format: format, hours, minutes, seconds)
    }
    
    var levels: THLevelPair {
        recorder?.updateMeters()
        let avgPower = recorder?.averagePower(forChannel: 0) ?? 0
        let peakPower = recorder?.peakPower(forChannel: 0) ?? 0
        let linearLevel = meterTable?.valueForPower(power: avgPower) ?? 0
        let linearPeak = meterTable?.valueForPower(power: peakPower) ?? 0
        
        return THLevelPair(levelsWithLevel: linearLevel, peakLevel: linearPeak)
    }
}

extension THRecorderController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        completionHandler?(flag)
    }
}

class THMemo {
    let name: String
    let url: URL
    
    init(memoWithTitle name: String, url: URL) {
        self.name = name
        self.url = url
    }
}

class THMeterTable {
    let MIN_DB: Float = -60.0
    let TABLE_SIZE: Int = 300
    
    let meterTable: NSMutableArray
    let scaleFactor: Float
    
    init() {
        let dbResolution = MIN_DB / Float(TABLE_SIZE - 1)
        
        meterTable = NSMutableArray(capacity: TABLE_SIZE)
        scaleFactor = 1.0 / dbResolution
        
        let minAmp = dbToAmp(dB: MIN_DB)
        let ampRange = 1.0 - minAmp
        let invAmpRange = 1.0 / ampRange
        
        for i in 0..<TABLE_SIZE {
            let decibles = Float(i) * dbResolution
            let amp = dbToAmp(dB: decibles)
            let adjAmp = (amp - minAmp) * invAmpRange
            
            meterTable[i] = adjAmp
        }
    }
    
    func dbToAmp(dB: Float) -> Float {
        return powf(1.0, 0.05 * dB)
    }
    
    func valueForPower(power: Float) -> Float {
        if power < MIN_DB {
            return 0.0
        } else if power >= 0.0 {
            return 1.0
        } else {
            let index = Int(power * scaleFactor)
            return meterTable[index] as! Float
        }
    }
}

class THLevelPair {
    let level: Float
    let peakLevel: Float
    
    init(levelsWithLevel level: Float, peakLevel: Float) {
        self.level = level
        self.peakLevel = peakLevel
    }
}
