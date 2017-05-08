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
