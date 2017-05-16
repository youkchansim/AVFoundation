//
//  chapter03_example.swift
//  AVFoundationiOS
//
//  Created by Youk Chansim on 2017. 5. 15..
//  Copyright © 2017년 Youk Chansim. All rights reserved.
//

import AVFoundation
import AssetsLibrary
import MediaPlayer

class Test {
    init() {
        let library = ALAssetsLibrary()
        library.enumerateGroupsWithTypes(ALAssetsGroupSavedPhotos, usingBlock: { group, stop in
            group?.setAssetsFilter(ALAssetsFilter.allVideos())
            group?.enumerateAssets(at: IndexSet(integer: 0), options: NSEnumerationOptions.init(rawValue: 0), using: { alAsset, index, innerStop in
                if let representation = alAsset?.defaultRepresentation(), let url = representation.url() {
                    let asset = AVAsset(url: url)
                    print(asset)
                }
            })
        }, failureBlock: { error in
            NSLog(error?.localizedDescription ?? "")
        })
        
        let artistPredicate = MPMediaPropertyPredicate(value: "Foo Fighters", forProperty: MPMediaItemPropertyArtist)
        let albumPredicate = MPMediaPropertyPredicate(value: "In Your Honor", forProperty: MPMediaItemPropertyAlbumTitle)
        let songPredicate = MPMediaPropertyPredicate(value: "Best of You", forProperty: MPMediaItemPropertyTitle)
        
        let query = MPMediaQuery()
        query.addFilterPredicate(artistPredicate)
        query.addFilterPredicate(albumPredicate)
        query.addFilterPredicate(songPredicate)
        
        if let results = query.items, results.count > 0 {
            let item = results[0]
            if let assetURL = item.value(forProperty: MPMediaItemPropertyAssetURL) as? URL {
                let asset = AVAsset(url: assetURL)
                print(asset)
                asset.statusOfValue(forKey: <#T##String#>, error: <#T##NSErrorPointer#>)
                asset.loadValuesAsynchronously(forKeys: <#T##[String]#>, completionHandler: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
            }
        }
        
        if let url = Bundle.main.url(forResource: "sunset", withExtension: "mov") {
            let asset = AVAsset(url: url)
            
            // Asynchronously load the assets 'tracks' property
            let keys = ["tracks"]
            asset.loadValuesAsynchronously(forKeys: keys) {
                // Capture the status of the 'tracks' preperty
                var error: NSErrorPointer
                let status = asset.statusOfValue(forKey: "tracks", error: error)
                
                //  Switch over the status to determine its state
                switch status {
                case .loaded:
                    break
                case .failed:
                    break
                case .cancelled:
                    break
                default:
                    break
                }
            }
        }
        
        if let url = Bundle.main.url(forResource: "sunset", withExtension: "mov") {
            let asset = AVAsset(url: url)
            let keys = ["availableMetadataFormats"]
            asset.loadValuesAsynchronously(forKeys: keys) {
                let metadata = NSMutableArray()
                //  Collect all metadata for the available for-mats
                for format in asset.availableMetadataFormats {
                    metadata.add(format)
                }
                //  Process AVMetadataItems
            }
        }
        
        let items: [AVMetadataItem] = []
        let keySpace = AVMetadataKeySpaceiTunes
        let artistKey = AVMetadataiTunesMetadataKeyArtist
        let albumKey = AVMetadataiTunesMetadataKeyAlbum
        let artistMetadata = AVMetadataItem.metadataItems(from: items, withKey: artistKey, keySpace: keySpace)
        let albumMetadata = AVMetadataItem.metadataItems(from: items, withKey: albumKey, keySpace: keySpace)
        
        if !artistMetadata.isEmpty {
            let artistItem = artistMetadata[0]
        }
        
        if !albumMetadata.isEmpty {
            let albumItem = albumMetadata[0]
        }
        
        if let url = URL(string: "") {
            let asset = AVAsset(url: url)
            let metadata = asset.metadata(forFormat: AVMetadataFormatiTunesMetadata)
            
            for item in metadata {
                NSLog("\(item.key, item.value)")
            }
        }
    }
}

//extension AVMetadataItem {
//    var keyString: NSString {
//        if let str = key as? NSString {
//            return str
//        } else if let number = key as? NSNumber {
//            var keyValue = number.uint32Value
//            var length = MemoryLayout<UInt32>.size
//            
//            if keyValue >> 24 == 0 {
//                length -= 1
//            }
//            
//            if keyValue >> 16 == 0 {
//                length -= 1
//            }
//            
//            if keyValue >> 8 == 0 {
//                length -= 1
//            }
//            
//            if keyValue >> 0 == 0 {
//                length -= 1
//            }
//            
//            var address = Int64(keyValue)
//            address += (MemoryLayout<UInt32>.size - length)
//            
//            keyValue = CFSwapInt32BigToHost(keyValue)
//            strncpy(<#T##__dst: UnsafeMutablePointer<Int8>!##UnsafeMutablePointer<Int8>!#>, <#T##__src: UnsafePointer<Int8>!##UnsafePointer<Int8>!#>, <#T##__n: Int##Int#>)
//        }
//    }
//}
