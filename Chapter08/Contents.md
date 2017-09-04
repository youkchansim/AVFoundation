# 8. Reading and Writing Media
AV Foundation은 재생, 캡처 및 편집 작업과 같은 상위 수준 작업을 수행하는 데 필요한 많은 기능을 제공합니다. 이러한 고급 기능은 AV Foundation을 매력적으로 만드는 요소의 일부입니다. 이러한 기능을 사용하여 미디어 처리 방법에 대한 세부 정보를 얻지 않고도 강력한 미디어 응용 프로그램을 만들 수 있습니다. 그러나 때로는 프레임 워크의 고급 기능만으로는 사용자의 요구를 충족시키지 못할 수도 있으며 약간 더 깊이 필요합니다. 이 장에서는 프레임 워크의 저수준 읽기 및 쓰기 기능을 살펴보고 AV Foundation 응용 프로그램을 빌드 할 때 사용할 수있는 일반적인 시나리오에 대해 설명합니다.

## Overview
AV Foundation은 미디어 앱을 제작할 때 일반적으로 접할 수 있는 유스 케이스에 대한 광범위한 기능을 제공합니다. 전용 고급 기능이 일반적으로 프레임 워크 작업의 기본 방법이지만 고급 미디어 응용 프로그램을 작성하기 시작할 때 프레임 워크에서 기본적으로 지원하지 않는 기능을 필요로하는 사용 사례가 발생할 수 있습니다. 이것이 운이 나쁘다는 뜻입니까? 해결책을 찾기 위해 다른 곳으로 돌릴 필요가 있습니까? 아니요, 단지 프레임 워크의 AVAssetReader 및 AVAssetWriter 클래스에서 제공하는 낮은 수준의 기능으로 떨어질 필요가 있음을 의미합니다 (그림 8.1 참조). 이 클래스는 미디어 샘플과 직접 작업 할 수있는 기능을 제공하여 세계를 열어줍니다.

<p align="center">
<image src="Resource/01.png" width="500">
</p>

### AVAssetReader
AVAssetReader는 AVAsset의 인스턴스에서 `미디어 샘플을 읽는데 사용`됩니다. 하나 이상의 `AVAssetReaderOutput` 객체로 구성되어 copyNextSampleBuffer 메서드를 통해 오디오 샘플 및 비디오 프레임에 대한 액세스를 제공합니다. AVAssetReaderOutput은 추상 클래스이지만 프레임 워크는 특정 AVAssetTrack의 디코딩 된 미디어 샘플과 여러 오디오 트랙의 혼합 출력 또는 여러 비디오 트랙의 합성 출력을 읽을 수 있게 해주는 세 가지 구체적인 인스턴스를 제공합니다. Asset Reader의 내부 파이프 라인은 멀티 스레딩되어 다음 사용 가능한 샘플을 계속 가져 와서 요청할 때 대기 시간을 최소화합니다. 낮은 대기 시간 검색을 제공함에도 불구하고 재생과 같은 실시간 작업을위한 것이 아닙니다.

```
노트
AVAssetReader는 단일 Asset에 포함 된 미디어 샘플만 대상으로 지정할 수 있습니다. 동시에 여러 파일 기반 Asset에서 샘플을 읽어야하는 경우 다음 장에서 설명 할 AVComposition이라는 AV클래스의 하위 클래스에서 함께 샘플을 구성 할 수 있습니다.
```

### AVAssetWriter
AVAssetWriter는 AVAssetReader에 상응하며 `MPEG-4 또는 QuickTime 파일과 같은 컨테이너 파일에 미디어를 인코딩하고 기록`하는데 사용됩니다. 컨테이너에 기록 할 미디어 샘플을 포함하는 CMSampleBuffer 객체를 추가하는데 사용되는 하나 이상의 `AVAssetWriterInput` 객체로 구성됩니다. AVAssetWriterInput은 오디오 또는 비디오와 같은 특정 미디어 유형을 처리하도록 구성되며 샘플에 첨부 된 샘플은 최종 출력 내에서 개별 AVAssetTrack을 생성합니다. 비디오 샘플을 처리하도록 구성된 AVAssetWriterInput을 사용하여 작업 할 때는 AVAssetWriterInputPixelBufferAdaptor라는 특수한 어댑터 객체를 자주 사용합니다. 이 클래스는 CVPixelBuffer 객체로 패키지 된 비디오 샘플을 추가 할 때 최적화 된 성능을 제공합니다. 입력은 AVAssetWriterInputGroup을 사용하여 상호 배타적인 배열로 그룹화 할 수도 있습니다. 이를 통해 4장 "비디오 재생"에서 설명한 AVMediaSelectionGroup 및 AVMediaSelectionOption 클래스를 사용하여 재생 시 선택할 수 있는 언어별 미디어 트랙을 포함하는 Asset을 만들 수 있습니다.
AVAssetWriter는 미디어 샘플 인터리빙을 자동으로 지원합니다. 샘플을 디스크에 기록 할 수있는 한 가지 방법은 그림 8.2와 같이 순차적으로 기록하는 것입니다. 모든 미디어 샘플을 캡처 할 수 있지만, 함께 제공해야하는 샘플이 서로 멀리 떨어져 있기 때문에 데이터 정렬이 비효율적입니다. 따라서 저장 장치가 데이터를 효율적으로 읽는 것이 더 어려워지며 Asset 재생 및 성능 추구에 악영향을 미칩니다.

<p align="center">
<image src="Resource/02.png" width="500">
</p>

이러한 샘플을 정렬하는 더 좋은 방법은 그림 8.3 에서처럼 인터리브 방식입니다. 적절한 인터리빙 패턴을 유지하기 위해 AVAssetWriterInput은 필요한 인터리브를 유지하면서 입력이 더 많은 데이터를 추가 할 수 있는지 나타내는 readyForMoreMediaData 속성을 제공합니다. 이 등록 정보가 YES 인 경우에만 writer 입력에 새 샘플을 추가 할 수 있습니다.

<p align="center">
<image src="Resource/03.png" width="500">
</p>

AVAssetWriter는 실시간 및 오프라인 작업 모두에 사용할 수 있지만 각 시나리오에서 서로 다른 접근 방식을 사용하여 샘플 버퍼를 작성자의 입력에 추가합니다.

  * RealTime : AVCaptureVideoDataOutput에서 캡처 한 샘플을 작성하는 것과 같이 실시간 소스로 작업 할 때 AVAssetWriterInput은 expectForMediaDataInRealTime 속성을 YES로 설정하여 readyForMoreMediaData 값이 적절히 계산되도록 해야합니다. 실시간 소스에서 작성 중이라고 표시하면 Writer가 최적화되므로 이상적인 인터리빙을 유지하는 것과 달리 샘플을 빨리 작성하는 것이 더 중요합니다. 이 최적화는 오디오 및 비디오 샘플이 거의 동일한 속도로 캡처되기 때문에 들어오는 데이터가 자연스럽게 삽입되기 때문에 잘 작동합니다.

  * Offline : AVAssetReader에서 샘플 버퍼를 읽는 것과 같이 오프라인 소스에서 미디어를 읽는 경우 샘플을 추가하기 전에 Writer 입력의 readyForMoreMediaData 속성 상태를 관찰해야하지만 requestMediaDataWhenReadyOnQueue : usingBlock : 메소드를 사용하여 데이터의 공급을 제어할 수 있습니다. 이 메소드에 전달 된 블록은 라이터 입력이 더 많은 샘플을 추가 할 준비가되면 계속 호출됩니다. 그러면 소스에서 다음 샘플을 검색하고 추가합니다.

## Reading and Writing Example
오프라인 시나리오에서 AVAssetReader 및 AVAssetWriter를 사용하는 방법을 보여주는 기본 예제를 살펴 보겠습니다. 이 예제는 AVAssetReader를 사용하여 Asset의 비디오 트랙에서 샘플을 읽어서 AVAssetWriter를 사용하여 새 QuickTime 무비 파일에 기록합니다. 이것은 일반적으로 고안된 예제이지만 이러한 클래스를 함께 사용할 때 관련된 기본 단계를 보여줍니다. AVAssetReader의 설정과 구성부터 시작하겠습니다.

```objectivec
AVAsset *asset = // Asynchronously loaded video asset
AVAssetTrack *track =
    [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];

self.assetReader =
    [[AVAssetReader alloc] initWithAsset:asset error:nil];

NSDictionary *readerOutputSettings = @{
    (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)
};

AVAssetReaderTrackOutput *trackOutput =
    [[AVAssetReaderTrackOutput alloc] initWithTrack:track
                                        outputSettings:readerOutputSettings];

[self.assetReader addOutput:trackOutput];

[self.assetReader startReading];
```

이 예제는 새로운 AVAssetReader를 만들어서 AVAsset 인스턴스를 전달하여 읽기 시작합니다. Asset의 비디오 트랙에서 샘플을 읽고 비디오 프레임을 BGRA 형식으로 압축 해제하는 `AVAssetReaderTrackOutpu`t을 만듭니다. 리더에 출력을 추가하고 startReading 메소드를 호출하여 읽기 프로세스를 시작합니다.
다음으로 AVAssetWriter를 만들고 구성해 보겠습니다.

```objectivec
NSURL *outputURL = // Destination output URL

self.assetWriter = [[AVAssetWriter alloc] initWithURL:outputURL fileType:AVFileTypeQuickTimeMovie error:nil];

NSDictionary *writerOutputSettings = @{
    AVVideoCodecKey: AVVideoCodecH264,
    AVVideoWidthKey: @1280,
    AVVideoHeightKey: @720,
    AVVideoCompressionPropertiesKey: @{
        AVVideoMaxKeyFrameIntervalKey: @1,
        AVVideoAverageBitRateKey: @10500000,
        AVVideoProfileLevelKey: AVVideoProfileLevelH264Main31,
    }
};

AVAssetWriterInput *writerInput =
    [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo
                                   outputSettings:writerOutputSettings];

[self.assetWriter addInput:writerInput];

[self.assetWriter startWriting];
```

이 예제에서는 새 AVAssetWriter를 만들고 출력 URL에 새 파일을 원하는 파일 형식과 함께 써야합니다. 적절한 미디어 유형과 출력 설정으로 새로운 AVAssetWriterInput을 생성하여 720p H.264 비디오를 만듭니다. 출력기에 입력을 추가하고 startWriting 메서드를 호출합니다.

```
노트
AVAssetWriter가 AVAssetExportSession을 통해 제공하는 뚜렷한 이점은 출력을 인코딩 할 때 사용하는 압축 설정을 세부적으로 제어 할 수 있다는 것입니다. 이를 통해 키 프레임 간격, 비디오 비트 전송률, H.264 프로파일, 픽셀 종횡비 및 clean aperture와 같은 설정을 지정할 수 있습니다.
```

AVAssetReader 및 AVAssetWriter 객체가 설정된 상태에서 새 쓰기 세션을 시작하여 소스 Asset의 샘플을 읽고 새 Asset에 쓸 시간입니다. 이 예제는 pull 모델을 사용하여 Writer 입력이 더 많은 샘플을 추가 할 준비가 되었을 때 소스에서 샘플을 가져 오는 방법을 보여줍니다. 이것은 비 실시간 소스에서 샘플을 작성할 때 사용할 모델입니다.

```objectivec
// Serial Queue
dispatch_queue_t dispatchQueue =
    dispatch_queue_create("com.tapharmonic.WriterQueue", NULL);

[self.assetWriter startSessionAtSourceTime:kCMTimeZero];
[writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{

    BOOL complete = NO;

    while ([writerInput isReadyForMoreMediaData] && !complete) {

        CMSampleBufferRef sampleBuffer = [trackOutput copyNextSampleBuffer];

        if (sampleBuffer) {
            BOOL result = [writerInput appendSampleBuffer:sampleBuffer];
            CFRelease(sampleBuffer);
            complete = !result;
        } else {
            [writerInput markAsFinished];
            complete = YES;
        }
    }

    if (complete) {
        [self.assetWriter finishWritingWithCompletionHandler:^{
            AVAssetWriterStatus status = self.assetWriter.status;
            if (status == AVAssetWriterStatusCompleted) {
                // Handle success case
            } else {
                // Handle failure case
            }
        }];
    }
}];
```

이 예제는 startSessionAtSourceTime : 메서드를 사용하여 새 쓰기 세션을 시작하고 kCMTimeZero를 소스 샘플의 시작 시간으로 전달하여 시작됩니다. requestMediaDataWhenReadyOnQueue : usingBlock :에 전달 된 블록은 Writer 입력이 더 많은 샘플을 추가 할 준비가 되면 계속해서 호출됩니다. 각 호출에서 입력이 더 많은 데이터를 준비하는 동안, 트랙 출력에서 ​​사용 가능한 샘플을 복사하여 입력에 추가합니다. 모든 샘플이 트랙 출력에서 ​​복사되면 AVAssetWriterInput을 마친 것으로 표시하고 추가가 완료되었음을 나타냅니다. 마지막으로, finishWritingWithCompletionHandler :를 호출하여 쓰기 세션을 마무리합니다. 완성 처리기에서 Asset Writer의 status 속성을 쿼리하여 작성 세션이 성공적으로 완료되었는지, 실패했는지, 취소되었는지 여부를 확인할 수 있습니다.
이제 AVAssetReader 및 AVAssetWriter 클래스를 더 잘 이해할 수 있습니다. 앞의 코드 예제는 이러한 클래스를 사용하여 오프라인 처리를 수행 할 때 사용할 기본 패턴을 제공합니다. 좀더 구체적이고 실제적인 예제를 계속 살펴보고, AVAssetReader 및 AVAssetWriter의 가치에 대해 더 잘 이해할 수 있도록하겠습니다.

### Building an Audio Waveform View
많은 오디오 및 비디오 어플리케이션의 일반적인 요구 사항은 오디오 파형의 그래픽 렌더링을 제공하는 것입니다 (그림 8.4 참조). 이렇게하면 오디오 트랙을 쉽게 시각화 할 수 있으므로 원하는 위치에서 더 쉽게 손질하거나 편집 할 수 있습니다. 이 섹션에서는 AV Foundation을 사용하여이 기능을 구현하는 방법에 대해 설명합니다.

<p align="center">
<image src="Resource/04.png" width="500">
</p>

파형 그리기의 기본 레시피에는 세 가지 주요 단계가 있습니다.
  1. Read : 첫 번째 단계는 렌더링 할 오디오 샘플을 읽는 것입니다. 리니어 PCM으로 오디오 데이터를 읽고 압축을 풀 필요가 있습니다. 제 1 장, "AV Foundation 시작하기"에서 리니어 PCM은 비 압축 오디오 샘플 형식입니다.
  2. Reduce : 읽는 샘플의 수는 화면에 표시 할 수있는 것보다 훨씬 많습니다. 44.1kHz의 샘플 레이트로 녹음 된 모노 오디오 파일을 생각해보십시오. 1 초의 오디오에는 44,100 개의 샘플이 있는데, 샘플보다 훨씬 많은 샘플입니다. 이 샘플 세트에는 감소 과정이 적용되어야합니다. 이 프로세스는 일반적으로 샘플의 총 수를 샘플의 더 작은 "bins"으로 세분화하고 최대 샘플, 모든 샘플의 평균 또는 최소 / 최대 쌍을 찾기 위해 각각을 조작합니다.
  3. Render : 이 단계에서는 축소 된 샘플을 가져 와서 화면에 렌더링합니다. 이것은 일반적으로 Quartz로 수행되지만 Apple에서 지원하는 모든 드로잉 프레임 워크를 사용할 수 있습니다. 데이터를 그리는 방법의 성격은 데이터를 축소 한 방법에 따라 다릅니다. 최소 / 최대 쌍을 포착 한 경우 각 쌍에 대해 수직선을 그립니다. 각 bin의 평균 또는 최대 샘플 값을 캡처 한 경우 Quartz Bezier 경로를 사용하면 파형을 그리는데 적합합니다.

THWaveformView_Starter라는 8장 디렉토리에서 시작 프로젝트를 찾을 수 있습니다. 그림 8.5와 같은 파형을 렌더링 할 수있는 UIView 하위 클래스를 빌드합니다. 첫 번째 단계부터 시작해 보겠습니다.

<p align="center">
<image src="Resource/05.png" width="500">
</p>

### Reading the Audio Samples
구축 할 첫 번째 클래스는 THSampleDataProvider입니다. 이 클래스는 AVAssetReader의 인스턴스를 사용하여 AVAsset에서 오디오 샘플을 읽어서 NSData 객체로 반환합니다. 이 클래스의 인터페이스는 Listing 8.1과 같습니다.

```objectivec
//  8.1
#import <AVFoundation/AVFoundation.h>

typedef void(^THSampleDataCompletionBlock)(NSData *);

@interface THSampleDataProvider : NSObject

+ (void)loadAudioSamplesFromAsset:(AVAsset *)asset
                  completionBlock:(THSampleDataCompletionBlock)completionBlock;

@end
```
이 클래스에 대한 인터페이스는 오디오 샘플을 읽으려는 loadAudioSamplesFromAsset : completionBlock : class 메소드가 주요 관심사입니다. Listing 8.2에서이 클래스의 구현으로 넘어 갑니다.

```objectivec
+ (void)loadAudioSamplesFromAsset:(AVAsset *)asset
                  completionBlock:(THSampleDataCompletionBlock)completionBlock {
    NSString *tracks = @"tracks";
    
    [asset loadValuesAsynchronouslyForKeys:@[tracks] completionHandler:^{ //  1
        AVKeyValueStatus status = [asset statusOfValueForKey:tracks error:nil];
        NSData *sampleData = nil;
        
        if (status == AVKeyValueStatusLoaded) { //  2
            sampleData = [self readAudioSamplesFromAsset:asset];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{  //  3
            completionBlock(sampleData);
        });
    }];
}
```

1. 애셋의 트랙 속성에 액세스 할 때 차단하지 않도록 애셋의 필수 키를 표준 비동기 적으로로드하는 것으로 시작하십시오.
2. 트랙 키가 성공적으로로드 된 경우 private readAudioSamplesFromAsset : 메소드를 호출하여 Asset의 오디오 트랙에서 샘플을 읽습니다.
3. 임의의 백그라운드 대기열에서로드가 발생하기 때문에 주 대기열로 다시 보내고 검색된 오디오 샘플을 사용하여 완료 블록을 호출하거나 읽을 수없는 경우에는 nil을 호출 할 수 있습니다.

이제 readAudioSamplesFromAsset : 메소드의 구현에 대해 살펴 보겠습니다. 이전 장에서 우리는 AVCaptureVideoDataOutput 객체에 의해 판매되는 비디오 프레임에 접근하기 위해 CMSampleBuffer를 사용하는 것에 대해 논의했다. 비 압축 비디오 데이터로 작업 할 때는 CMSampleBufferGetImageBuffer 함수를 사용하여 프레임의 픽셀이 포함 된 기본 CVImageBufferRef를 검색합니다. Asset에서 오디오 샘플을 읽을 때 다시 CMSampleBuffer로 작업하게 됩니다. 이 경우 기본 데이터는 CMBlockBuffer라는 핵심 미디어 유형의 형태로 제공됩니다. 블록 버퍼는 코어 미디어 파이프 라인을 통해 임의의 바이트 데이터를 전달하는 데 사용됩니다. 오디오 샘플을 사용하여 수행하려는 작업에 따라 오디오 데이터가 포함 된 블록 버퍼에 액세스하는 몇 가지 방법을 사용할 수 있습니다.
CMSampleBufferGetDataBuffer 함수를 사용하여 블록 버퍼에 대한 참조를 가져올 수 있습니다. 이 함수는 데이터에 액세스해야하지만 추가 처리는 필요하지 않습니다. 또는 Core Audio로 전달하는 등 오디오 데이터를 처리하려는 경우 CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer 함수를 사용하여 AudioBufferList로 데이터에 액세스 할 수 있습니다. 이렇게하면 Core Audio AudioBufferList와 함께 데이터가 포함 된 샘플의 수명을 관리하는 유지 된 CMBlockBuffer와 함께 데이터를 반환합니다. 샘플을 가져 와서 NSData에 복사하기 때문에 이전 방법을 사용하여 오디오 데이터를 검색합니다(Listing 8.3 참조).

```objectivec
+ (NSData *)readAudioSamplesFromAsset:(AVAsset *)asset {
    
    NSError *error = nil;
    
    AVAssetReader *assetReader =                                            // 1
    [[AVAssetReader alloc] initWithAsset:asset error:&error];
    
    if (!assetReader) {
        NSLog(@"Error creating asset reader: %@", [error localizedDescription]);
        return nil;
    }
    
    AVAssetTrack *track =                                                   // 2
    [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    
    NSDictionary *outputSettings = @{                                       // 3
                                     AVFormatIDKey               : @(kAudioFormatLinearPCM),
                                     AVLinearPCMIsBigEndianKey   : @NO,
                                     AVLinearPCMIsFloatKey       : @NO,
                                     AVLinearPCMBitDepthKey      : @(16)
                                     };
    
    AVAssetReaderTrackOutput *trackOutput =                                 // 4
    [[AVAssetReaderTrackOutput alloc] initWithTrack:track
                                     outputSettings:outputSettings];
    
    [assetReader addOutput:trackOutput];
    
    [assetReader startReading];
    
    NSMutableData *sampleData = [NSMutableData data];
    
    while (assetReader.status == AVAssetReaderStatusReading) {
        
        CMSampleBufferRef sampleBuffer = [trackOutput copyNextSampleBuffer];// 5
        
        if (sampleBuffer) {
            CMBlockBufferRef blockBufferRef =                               // 6
            CMSampleBufferGetDataBuffer(sampleBuffer);
            
            size_t length = CMBlockBufferGetDataLength(blockBufferRef);
            SInt16 sampleBytes[length];
            
            CMBlockBufferCopyDataBytes(blockBufferRef,                      // 7
                                       0,
                                       length,
                                       sampleBytes);
            
            [sampleData appendBytes:sampleBytes length:length];
            
            CMSampleBufferInvalidate(sampleBuffer);                         // 8
            CFRelease(sampleBuffer);
        }
    }
    
    if (assetReader.status == AVAssetReaderStatusCompleted) {               // 9
        return sampleData;
    } else {
        NSLog(@"Failed to read audio samples from asset");
        return nil;
    }
}
```
1. AVAssetReader의 새 인스턴스를 만들고 읽을 Asset을 전달합니다. 객체를 초기화하는 중 오류가 발생하면 오류 메시지를 콘솔에 기록하고 nil을 반환합니다.
2. Asset에서 발견 된 첫 번째 오디오 트랙을 검색합니다. 샘플 프로젝트에 포함 된 오디오 파일에는 하나의 트랙 만 포함되어 있지만 원하는 미디어 유형으로 항상 트랙을 검색하는 것이 가장 좋습니다.
3. Asset 트랙에서 오디오 샘플을 읽을 때 사용할 압축 해제 설정이 들어있는 NSDictionary를 만듭니다. 샘플은 압축되지 않은 형식으로 읽어야하므로 형식 키로 kAudioFormatLinearPCM을 지정합니다. 또한 리틀 엔디안 바이트 순서로 16 비트 부호있는 정수로 읽어야하는지 확인해야합니다. 샘플 프로젝트에는 이러한 설정으로 충분하지만 AVAudioSettings.h에서 포맷 변환을 보다 잘 제어 할 수 있는 많은 추가 키를 찾을 수 있습니다.
4. 이전 단계에서 생성한 출력 설정을 전달하는 AVAssetReaderTrackOutput의 새 인스턴스를 만듭니다. 이것을 AVAssetReader에 출력으로 추가하고 startReading을 호출하여 Asset 판독기가 샘플 프리 패치를 시작할 수 있게합니다.
5. 트랙 출력의 copyNextSampleBuffer 메서드를 호출하여 루프의 각 반복을 시작합니다. 이 메서드는 오디오 샘플이 포함 된 다음 사용 가능한 샘플 버퍼를 반환합니다.
6. CMSampleBuffer의 오디오 샘플은 CMBlockBuffer라는 형식으로 포함됩니다. CMSampleBufferGetDataBuffer 함수를 사용하여이 블록 버퍼에 액세스합니다. CMBlockBufferGetDataLength 함수를 사용하여 길이를 결정하고 오디오 샘플을 보관할 16 비트 부호있는 정수의 배열을 만듭니다.
7. CMBlockBufferCopyDataBytes 함수를 사용하여 배열에 CMBlockBuffer에 포함 된 데이터를 채우고 배열의 내용을 NSData 인스턴스에 추가합니다.
8. 이 샘플 버퍼가 처리되었음을 나타내려면 CMSampleBufferInvalidate 함수를 사용하고 나중에 사용하지 않도록 무효화하십시오. 또한 복사 된 CMSampleBuffer를 해제하여 메모리를 확보해야합니다.
9. Asset 판독기의 상태가 AVAssetReaderStatusCompleted 인 경우 데이터를 성공적으로 읽었으며 오디오 샘플이 포함 된 NSData를 반환합니다. 오류가 발생하면 nil을 반환합니다.

첫 번째 단계가 완료되면 다양한 오디오 포맷에서 오디오 샘플을 성공적으로 읽을 수 있습니다. 다음 단계는 화면에서 그려지는 사용 가능한 형태로 데이터를 축소하는 것입니다.

### Reducing the Audio Samples
THSampleDataProvider는 주어진 오디오 Asset에서 완전한 샘플 세트를 추출합니다. 매우 작은 오디오 파일을 사용하더라도 수십만 개의 샘플이 생길 수 있으며 이는 화면 상에 그려지는 것보다 훨씬 큽니다. 이 집합을 최종적으로 화면에 그려지는 값 모음으로 필터링하는 방법을 정의해야합니다. 이 축소 작업을 수행하려면이 작업을 수행 할 THSampleDataFilter라는 개체를 만듭니다. 이 클래스의 인터페이스는 Listing 8.4와 같습니다.

```objectivec
//  8.4
@interface THSampleDataFilter : NSObject

- (id)initWithData:(NSData *)sampleData;

- (NSArray *)filteredSamplesForSize:(CGSize)size;

@end
```

이 클래스의 인스턴스는 오디오 샘플이 포함 된 NSData로 초기화됩니다. 지정된 크기 제약 조건에 따라 데이터 집합을 필터링하는 filteredSamplesForSize : 메서드를 제공합니다.
이 데이터를 처리하는 데는 두 가지 단계가 있습니다. 첫 번째로, 샘플을 "bin"으로 분할하여 각 샘플에서 최대 샘플을 찾습니다. 모든 저장소가 처리되면 filteredSamplesForSize : 메서드에 전달 된 크기 제약 조건을 기준으로 샘플에 확장 인수를 적용합니다. Listing 8.5에서 이 클래스의 구현을 살펴 봅시다.

```objectivec
//  8.5
- (NSArray *)filteredSamplesForSize:(CGSize)size {
    NSMutableArray *filteredSamples = [[NSMutableArray alloc] init];        // 1
    NSUInteger sampleCount = self.sampleData.length / sizeof(SInt16);
    NSUInteger binSize = sampleCount / size.width;
    
    SInt16 *bytes = (SInt16 *)self.sampleData.bytes;
    
    SInt16 maxSample = 0;
    for (NSUInteger i = 0; i < sampleCount; i += binSize) {
        SInt16 sampleBin[binSize];
        
        for (NSUInteger j = 0; j < binSize; j++) {                          // 2
            sampleBin[j] = CFSwapInt16LittleToHost(bytes[i + j]);
        }
        
        SInt16 value = [self maxValueInArray:sampleBin ofSize:binSize];     // 3
        [filteredSamples addObject:@(value)];
        
        if (value > maxSample) {                                            // 4
            maxSample = value;
        }
    }
    
    CGFloat scaleFactor = (size.height / 2) / maxSample;
    
    for (NSUInteger i = 0; i < filteredSamples.count; i++) {                // 5
        filteredSamples[i] = @([filteredSamples[i] integerValue] * scaleFactor);
    }
    
    return filteredSamples;
}

- (SInt16)maxValueInArray:(SInt16[])values ofSize:(NSUInteger)size {
    SInt16 maxValue = 0;
    for (int i = 0; i < size; i++) {
        if (abs(values[i]) > maxValue) {
            maxValue = abs(values[i]);
        }
    }

    return maxValue;
}
```

1. 오디오 샘플의 필터링 된 배열을 저장하기 위해 NSMutableArray를 작성하는 것으로 시작하십시오. 또한 처리 할 총 샘플 수를 결정하고 메서드에 전달 된 크기 제약 조건에 적합한 "bin"크기를 계산합니다. 빈에는 필터링 할 샘플의 하위 세트가 들어 있습니다.
2. 전체 오디오 샘플 세트를 반복하고 각 반복에서 처리 할 데이터 상자를 구성합니다. 오디오 샘플로 작업 할 때는 항상 바이트 순서를 기억해야하므로 `CFSwapInt16LittleToHost` 함수를 사용하여 샘플이 호스트의 기본 바이트 순서로되어 있는지 확인합니다.
3. 각 bin에 대해 maxValueInArray : 메소드를 호출하여 최대 샘플을 찾습니다. 이 메서드는 빈의 모든 샘플을 반복하고 최대 절대 값을 찾습니다. 결과 값은 filteredSamples 배열에 추가됩니다.
4. 모든 오디오 샘플을 반복하면서 필터링 된 값의 최대 값을 계산합니다. 이것은 필터링 된 샘플에 적용 할 스케일링 계수를 계산하는데 사용됩니다.
5. 필터링 된 샘플을 반환하기 전에 이 메서드에 전달 된 크기 제약 조건에 상대적인 값의 크기를 조정해야합니다. 그러면 화면상에 렌더링 할 수 있는 부동 소수점 값의 배열이 생깁니다. 값의 크기가 조정되면 배열을 호출자에게 반환합니다.

THSampleDataFilter 클래스가 완성되었습니다. 이제 오디오 샘플을 렌더링하기 위해 뷰를 빌드하는 방법에 대해 토론 할 준비가되었습니다.

### Rendering the Audio Samples
결과를 렌더링하기 위해 UIView 하위 클래스를 빌드합니다. Listing 8.6에서 이 클래스가 제공하는 인터페이스를 살펴 봅시다.

```objectivec
//  8.6
@class AVAsset;

@interface THWaveformView : UIView

@property (strong, nonatomic) AVAsset *asset;
@property (strong, nonatomic) UIColor *waveColor;

@end
```

이 뷰는 파형을 그려야하는 AVAsset 및 색상을 설정할 수있는 간단한 인터페이스를 제공합니다. Listing 8.7부터 시작하여 이 클래스의 구현을 살펴 봅시다. 일부 UIView 상용구 코드는 이 목록에서 생략되었습니다. 완전한 구현을 위한 프로젝트 소스 코드를 참조하십시오.

```objectivec
//  8.7
#import "THWaveformView.h"
#import "THSampleDataProvider.h"
#import "THSampleDataFilter.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat THWidthScaling = 0.95;
static const CGFloat THHeightScaling = 0.85;

@interface THWaveformView ()
@property (strong, nonatomic) THSampleDataFilter *filter;
@property (strong, nonatomic) UIActivityIndicatorView *loadingView;
@end

@implementation THWaveformView

...

- (void)setAsset:(AVAsset *)asset {
    if (_asset != asset) {
        _asset = asset;

        [THSampleDataProvider loadAudioSamplesFromAsset:self.asset          // 1
                                        completionBlock:^(NSData *sampleData) {

            self.filter =                                                   // 2
                [[THSampleDataFilter alloc] initWithData:sampleData];

            [self.loadingView stopAnimating];                               // 3
            [self setNeedsDisplay];
        }];
    }
}

- (void)drawRect:(CGRect)rect {
    // To be implemented
}

@end
```
1. 오디오 샘플을 로드하여 THSampleDataProvider 클래스에서 loadAudioSamplesFromAsset : completionBlock : 메서드를 호출합니다.
2. 샘플이 로드되면 THSampleDataFilter의 새 인스턴스를 만들고 오디오 샘플이 포함 된 NSData를 전달합니다.
3. 뷰의 로드 스피너를 닫고 setNeedsDisplay를 호출하여 drawRect : 메소드가 호출되도록 뷰에 대한 하우스 키핑을 수행합니다.

drawRect : 메소드의 구현으로 넘어 가면서이 데이터가 화면 상에 그려지는 모습을 볼 수 있습니다 (Listing 8.8 참조).

```objectivec
//  8.8
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, THWidthScaling, THHeightScaling);            // 1
    
    CGFloat xOffset = self.bounds.size.width -
    (self.bounds.size.width * THWidthScaling);
    
    CGFloat yOffset = self.bounds.size.height -
    (self.bounds.size.height * THHeightScaling);
    
    CGContextTranslateCTM(context, xOffset / 2, yOffset / 2);
    
    NSArray *filteredSamples =                                              // 2
    [self.filter filteredSamplesForSize:self.bounds.size];
    
    CGFloat midY = CGRectGetMidY(rect);
    
    CGMutablePathRef halfPath = CGPathCreateMutable();                      // 3
    CGPathMoveToPoint(halfPath, NULL, 0.0f, midY);
    
    for (NSUInteger i = 0; i < filteredSamples.count; i++) {
        float sample = [filteredSamples[i] floatValue];
        CGPathAddLineToPoint(halfPath, NULL, i, midY - sample);
    }
    
    CGPathAddLineToPoint(halfPath, NULL, filteredSamples.count, midY);
    CGMutablePathRef fullPath = CGPathCreateMutable();                      // 4
    CGPathAddPath(fullPath, NULL, halfPath);
    
    CGAffineTransform transform = CGAffineTransformIdentity;                // 5
    transform = CGAffineTransformTranslate(transform, 0, CGRectGetHeight(rect));
    transform = CGAffineTransformScale(transform, 1.0, -1.0);
    CGPathAddPath(fullPath, &transform, halfPath);
    
    CGContextAddPath(context, fullPath);                                    // 6
    CGContextSetFillColorWithColor(context, self.waveColor.CGColor);
    CGContextDrawPath(context, kCGPathFill);
    
    CGPathRelease(halfPath);                                                // 7
    CGPathRelease(fullPath);
}
```

1. 웨이브 폼이 뷰의 경계로부터 삽입되기를 원하는 경우, 정의 된 높이와 폭 상수에 기반하여 그래픽 콘텍스트를 스케일링하는 것으로 시작합니다. x 및 y 오프셋을 계산하여 컨텍스트를 변환하여 스케일 된 컨텍스트 내에서 오프셋을 적절하게 이동합니다.
2. THSampleDataFilter 인스턴스에서 필터링 된 샘플을 검색하여 뷰의 경계 크기를 전달합니다. 프로덕션 코드에서 이 검색을 drawRect : 메소드 밖으로 옮겨서 샘플을 필터링 할 때 더 효율적으로 최적화 할 수 있지만이 접근법은 샘플 앱에 충분합니다.
3. 파형의 베지어 패스의 위쪽 절반을 그리는데 사용되는 새 CGMutablePathRef를 만듭니다. 필터링 된 샘플을 반복하고 각각에 대해 CGPathAddLineToPoint를 호출하여 경로에 점을 추가합니다. 루프 인덱스는 x 좌표로 사용하고 샘플 값은 y 좌표로 사용합니다.
4. 두 번째 CGMutablePathRef를 만들고 4 단계에서 생성한 베지어 경로를 전달합니다. 이 베 지어 경로를 사용하여 전체 파형을 그립니다.
5. 파형의 아래쪽 절반을 그리려면 상단 경로로 변환 및 비율 변환을 적용합니다. 결과적으로 상단 경로가 거꾸로 뒤집어 져 완성 된 파형이 채워집니다.
6. 그래픽 컨텍스트에 완성 된 경로를 추가하고, 지정된 waveColor에 따라 채우기 색을 설정하고, CGContextDrawPath (context, kCGPathFill)를 호출하여 채워진 경로를 컨텍스트에 그립니다.
7. Quartz 객체를 생성 할 때마다 메모리를 비우는 것은 사용자의 책임이므로 마지막 단계는 생성한 경로 객체에 CGPathRelease를 호출하는 것입니다.

그림 8.5에서 볼 수 있듯이 응용 프로그램의뷰 컨트롤러는 두 개의 뷰를 그리도록 설정됩니다. 응용 프로그램의뷰 컨트롤러를 열고 색상을 시험해 보거나 스토리 보드에서 뷰를 수정할 수 있습니다. 이제 응용 프로그램에서 파형을 렌더링 할 때마다 사용할 수있는 재사용 가능한 멋진 클래스가 생겼습니다.