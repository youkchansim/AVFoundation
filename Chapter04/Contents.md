# Playing Video
비디오는 정보를 제공하고 영향을 미치며, 교육을 받고 즐겁게 하기위한 매우 강력한 매체입니다. YouTube 및 Vimeo와 같은 비디오 공유 사이트 덕분에 지난 10년 동안 비디오를 소비하는 방식이 크게 바뀌 었습니다. 최근에는 iPhone 및 iPad와 같은 장치 덕분입니다. 텔레비전은 스트리밍 비디오로 빠르게 빼앗겨 가고 있습니다. 온라인 교육 및 비디오 기반의 가상 교실이 점점 보편화되고 있으며 페이스 북 및 트위터와 같은 사이트에서 매 순간 분주하게 많은 비디오가 공유됩니다. 분명히 증가하는 수요를 충족시키기 위해 풍부하고 역동적인 비디오 경험을 개발해야 할 필요가 있습니다. 이 장에서는 AV Foundation의 비디오 재생 기능에 대해 자세히 설명합니다. 맞춤 동영상 플레이어 제작과 관련된 핵심 구성 요소에 대해 논의하고 프레임 워크가 제공하는 추가 기능을 살펴보고 재생 환경을 더욱 향상시킵니다.

## Playback Overview
커스텀 플레이어를 개발할 때 많은 오브젝트가 관련됩니다. 이 섹션에서는 관련 클래스의 역할과 관계를 탐구하여 AV Foundation의 재생 기능에 대해 상당히 높은 수준의 소개부터 시작하겠습니다. 다음 섹션에서는 API 세부 정보를 자세히 살펴보고 맞춤 동영상 플레이어를 개발하여 이러한 클래스를 실제로 적용 해 보겠습니다. 그림 4.1은 관련 클래스와 그 관계에 대한 개요를 제공합니다.

<center>
<image src="Resource/01.png" width="30%" height="30%">
</center>

### AVPlayer
AV Foundation의 재생 지원은 `AVPlayer`라는 클래스를 중심으로 이루어집니다. AVPlayer는 시간이 지정된 오디오 - 비주얼 미디어를 재생하는데 사용되는 컨트롤러 개체입니다. `HTTP 라이브 스트리밍 프로토콜`을 통해 전달되는 로컬, 점진적으로 다운로드 또는 스트리밍된 미디어의 재생을 지원하므로 다양한 재생 시나리오에서 유용합니다. 나는 "컨트롤러"라고 할 때 일반적인 의미에서 의미한다는 것을 분명히해야한다. 뷰 또는 윈도우 컨트롤러가 아니지만 관련 Asset의 재생 및 타이밍을 관리하는 객체입니다. Timed Media의 재생을 제어하기 위해 사용자 인터페이스를 개발하는 데 사용할 프로그래밍 방식의 인터페이스를 제공합니다.
AVPlayer는 `비시각적 구성 요소`입니다. MP3 또는 AAC 오디오 파일을 재생하는 것이 목표인 경우 사용자 인터페이스가 부족해도 문제가 발생하지 않습니다. 그러나 이 경우 QuickTime 동영상 또는 MPEG-4 비디오를 재생하는 것이 목표라면 다소 실망스러운 사용자 경험이 될 것입니다. 비디오 출력을 사용자 인터페이스의 대상으로 지정하려면 `AVPlayerLayer`라는 클래스를 사용합니다.

```
노트
AVPlayer는 단일 Asset의 재생을 관리하지만 프레임 워크는 Asset 대기열을 관리 할 수있는 AVQueuePlayer라는 AVPlayer의 하위 클래스도 제공합니다. 이 클래스는 여러 항목을 순서대로 재생하거나 오디오 또는 비디오 에셋의 끝없는 반복을 설정하려는 경우에 유용합니다.
```

### AVPlayerLayer
`AVPlayerLayer는 Core Animation 위에 구축`되며 AV Foundation에서 찾을 수있는 몇 가지 비주얼 구성 요소 중 하나입니다. Core Animation은 Mac 및 iOS에서 사용할 수 있는 그래픽 렌더링 및 애니메이션 프레임 워크이며 이러한 플랫폼에서 볼 수있는 아름답고 유동적인 애니메이션을 담당합니다. Core Animation은 `본질적으로 시간 기반`이며, `OpenGL을 기반으로 제작` 되었기 때문에 놀랄만큼 성능이 뛰어나서 AV Foundation의 요구에 완벽하게 부합합니다.
AVPlayerLayer는 `Core Animation의 CALayer 클래스를 확장`하고 프레임 워크에서 비디오 내용을 화면에 렌더링하는데 사용됩니다. 이 레이어는 시각적 컨트롤이나 다른 장식물(사용자가 직접 작성해야 함)을 제공하지 않지만 비디오 내용의 렌더링 표면 역할을합니다. `AVPlayerLayer는 AVPlayer 인스턴스에 대한 포인터`로 생성됩니다. 이렇게하면 레이어를 플레이어에 강력하게 바인딩하여 플레이어의 시간 기반 메서드에 대한 변경 사항이 발생하면 동기화를 유지할 수 있습니다. AVPlayerLayer는 다른 CALayer처럼 사용할 수 있으며 UIView 또는 NSView의 백업 레이어로 설정하거나 기존 레이어 계층에 수동으로 추가 할 수 있습니다.
AVPlayerLayer는 상당히 단순한 클래스이며 일반적으로 그대로 사용됩니다. 사용자 정의 할 수 있는 레이어의 한 측면은 `비디오 중력`입니다. VideoGravity 속성에 대해 지정 할 수 있는 세 가지 중력 값이 있어 비디오를 포함하는 레이어의 경계 내에서 비디오를 늘리거나 크기를 조정하는 방법을 결정합니다. 그림 4.2, 4.3 및 4.4는 다양한 중력 값의 효과를 볼 수 있도록 4 : 3 경계 사각형 내에 16 : 9 비디오를 표시하는 것을 보여줍니다.

<center>
<image src="Resource/02.png" width="30%" height="30%">
</center>

<center>
<image src="Resource/03.png" width="30%" height="30%">
</center>

<center>
<image src="Resource/04.png" width="30%" height="30%">
</center>

### AVPlayerItem
궁극적인 목표는 AVPlayer를 사용하여 AVAsset을 재생하는 것입니다. AVAsset에 대한 설명서를 보면 제작 날짜, 메타 데이터 및 기간과 같이 데이터를 검색 할 수 있는 메서드와 속성을 찾을 수 있습니다. 그러나 볼 수 없는 것은 현재 시간이나 미디어 내의 특정 위치를 찾는 기능을 검색하는 방법입니다. AVAsset은 미디어 리소스의 정적 측면만 모델링하기 때문입니다. 객체의 정적 상태를 나타내는 영구 속성. 즉, 자체적으로 `AVAsset은 재생에 전혀 적합하지 않습니다`. 저작물과 관련 트랙을 재생하려면 먼저 AVPlayerItem 및 AVPlayerItemTrack 클래스에서 제공하는 `동적 요소를 구성`해야합니다.
AVPlayerItem은 미디어의 동적 관점을 모델링하고 AVPlayer가 재생하는 Asset의 표현 상태를 전달합니다. 이 클래스에서 seekToTime : 및 currentTime 및 presentationSize에 액세스하기위한 속성 등의 메서드를 찾을 수 있습니다. AVPlayerItem은 하나 이상의 미디어 트랙으로 구성되며 AVPlayerItemTrack 클래스로 모델링됩니다. AVPlayerItemTrack의 인스턴스는 오디오 및 비디오와 같이 플레이어 항목에 포함된 균등하게 입력된 미디어 스트림을 나타냅니다. AVPlayerItem에 있는 트랙은 기본 AVAsset에 있는 AVAssetTrack 인스턴스에 직접 해당합니다.

### Playback Recipe
이러한 클래스를 간단히 이해할 수 있도록 애플리케이션 스택에 포함된 비디오를 재생하기 위해 재생 스택을 설정하는 방법에 대한 간단한 코드 예제를 살펴 보겠습니다.

```Swift
    override func viewDidLoad() {
        super.viewDidLoad()

        if let assetURL = Bundle.main.url(forResource: "waves", withExtension: "mp4") {
            let asset = AVAsset(url: assetURL)
            let avPlayerItem = AVPlayerItem(asset: asset)
            
            let player = AVPlayer(playerItem: avPlayerItem)
            let playerLayer = AVPlayerLayer(player: player)
            self.view.layer.addSublayer(playerLayer)
        }
    }
```

이 예제는 비디오 파일 재생에 필요한 기본 인프라를 설정합니다. 그러나 비디오 콘텐츠를 실제로 재생하기 전에 추가 단계를 수행해야합니다. 플레이어의 관련 플레이어 항목이 아직 재생하기에 적합한 상태가 아니기 때문입니다. AVPlayerItem은 재생 준비를위한 인터페이스를 제공하지 않지만 대신 "나를 부르지 말고, 내가 당신에게 전화 할 것"에 따라 작동합니다.
AVPlayerItem은 AVPlayerItemStatus 유형의 status라는 속성을 제공합니다. 처음 생성 될 때 플레이어 항목은 `AVPlayerItemStatusUnknown` 상태로 시작합니다. 즉, 해당 미디어가 로드되지 않았고 재생을 위해 `대기열에 추가되지 않았음`을 의미합니다. AVPlayer와 AVPlayerItem을 연결하면 미디어를 대기열에 넣기 시작하지만 항목 재생을 시작할 수 있으려면 상태가 `AVPlayerItemStatusUnknown`에서 `AVPlayerItemStatusReadyToPlay`로 이동하기를 기다려야합니다. 이 변경을 관찰하는 방법은 `KVO (Key-Value Observing)를 통해 상태 속성을 관찰`하는 것입니다.
KVO는 Foundation 프레임 워크에서 제공하는 Observer 패턴을 Apple에서 구현 한 것입니다. 이렇게하면 관찰자 또는 다른 개체의 상태로 개체를 등록 할 수 있습니다. 관찰 된 객체의 상태가 변경되면 관찰 객체가 통지되고 어떤 조치를 취할 수있는 기회가 제공됩니다. AVPlayerItem을 AVPlayer에 연결하기 전에 다음 예제와 같이 status 속성의 관찰자로 코드를 설정해야합니다.

```Objectivec
static const NSString *PlayerItemStatusContext;
- (void)viewDidLoad {

    ...

    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];

    [playerItem addObserver:self
                 forKeyPath:@"status"
                    options:0
                    context:&PlayerItemStatusContext];

    self.player = [AVPlayer playerWithPlayerItem:playerItem];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    if (context == &PlayerItemStatusContext) {

        AVPlayerItem *playerItem = (AVPlayerItem *)object;
        if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
            // proceed with playback
        }
    }
}
```

플레이어 항목의 상태가 `AVPlayerItemStatusReadyToPlay`로 변경된 것을 확인한 후에는 자유롭게 재생을 시작할 수 있습니다.

### Working with Time
AVPlayer 및 AVPlayerItem은 시간 기반 객체이지만 이러한 기능을 사용하려면 먼저 AV Foundation에서 시간이 어떻게 나타나는지 파악해야합니다.
사람들은 시간을 일, 시간, 분 및 초 단위로 생각하는 경향이 있습니다. 개발자들은 종종 밀리 초와 나노초로 시간을 세분화합니다. 따라서 시간을 배정 밀도 부동 소수점 유형으로 나타내는 것이 합리적 일 수 있습니다. 사실, 2 장의 "AVAudioPlayer"에서 "오디오 재생 및 녹음"을 살펴보면, 시간을 NSTimeInterval로 표현한 방법을 알았을 것입니다. NSTimeInterval은 단순히 double 값의 typedef입니다. 그러나 부동 소수점 유형으로 시간을 표현하는 것은 부동 소수점 연산이 근본적으로 부정확성을 초래할 수 있기 때문에 문제가 될 수 있습니다. 이러한 부정확성은 누적되기 시작할 때 여러 시간 계산을 할 때 특히 문제가되며, 종종 상당한 타이밍 드리프트가 발생하여 여러 미디어 스트림을 동기화하는 것이 거의 불가능합니다. 또한 부동 소수점 유형으로 시간을 표시하는 것은 특히 자체 설명이 아니므로 다른 시간대를 사용하여 시간에 비교하고 조작하기가 어렵습니다. AV Foundation은 CMTime이라는 데이터 구조를 기반으로 시간을 표현하는 훨씬 더 강력한 접근 방식을 사용합니다.

### CMTime
AV Foundation은 Core Media라는 프레임 워크 위에 구축됩니다. Core Media는 Mac 및 iOS 미디어 스택에 중요한 기능을 많이 제공하는 저수준의 C 기반 프레임 워크입니다. 이 프레임 워크는 일반적으로 장면 뒤에 있지만, 자주 다룰 부분은 데이터 구조 인 CMTime입니다. CMTime은 시간 값, 즉 분수 값의 합리적인 표현을 제공하는 구조체입니다. 그것은 다음과 같이 정의됩니다 :

```Objectivec
typedef struct {
  CMTimeValue value;
  CMTimeScale timescale;
  CMTimeFlags flags;
  CMTimeEpoch epoch;
} CMTime;
```

이 구조체의 키 값은 value와 timescale입니다. 값은 64 비트 정수이고 시간 눈금은 32 비트 정수이며이 합리적인 시간 표현에서 각각 분자와 분모를 나타냅니다.
부분적인 용어로 시간을 생각하는 것은 익숙해지기까지는 다소 시간이 걸릴 수 있지만 시간이 오래 걸리면 두 번째 성격이됩니다. CMTimeMake 함수를 사용하여 시간을 만드는 방법에 대한 몇 가지 예를 살펴 보겠습니다.

```Objectivec
// 0.5 seconds
CMTime halfSecond = CMTimeMake(1, 2);

// 5 seconds
CMTime fiveSeconds = CMTimeMake(5, 1);

// One sample from a 44.1 kHz audio file
CMTime oneSample = CMTimeMake(1, 44100);

// Zero time value
CMTime zeroTime = kCMTimeZero;
```

CMTime 자체를 정의하는 것 외에도 CMTime.h는 시간에 따른 작업을 단순화하는 많은 수의 유틸리티 함수를 정의합니다. 대부분의 애플의 하위 레벨 C 프레임 워크와 마찬가지로 가장 좋은 문서는 헤더에서 찾을 수 있습니다. 따라서 CMTime.h를 통해 독해 기능의 기능을 이해하는 것이 좋습니다.

## Building a Video Player
이 섹션에서는 iOS 비디오 플레이어를 구축하여 AV Foundation의 재생 API에 대해 자세히 설명합니다 (그림 4.5 참조). 이 응용 프로그램은 로컬 및 원격 미디어를 재생할 수있는 기능을 제공하므로 미디어 타임 라인을 재생, 일시 중지 및 제거 할 수 있습니다. 기본 기능을 만든 후에는 사용자 환경을 개선하기 위해 수행 할 수있는 개선 사항을 살펴 보겠습니다. 4 장 디렉토리 VideoPlayer_Starter에서 시작 프로젝트를 찾을 수 있습니다.

<center>
<image src="Resource/05.png" width="30%" height="30%">
</center>

### Creating the Video View
첫 번째 단계는 비디오 콘텐츠를 화면에 표시하는 뷰를 작성하는 것입니다. 샘플 프로젝트의 THVideoPlayer / Views 그룹 아래에 THPlayerView라는 클래스가 있습니다. 이 클래스는 비디오를 표시하는 데 사용되며 비디오 재생을 조작하기위한 사용자 인터페이스를 제공합니다.
뷰 자체는 비디오 출력의 대상이 아닙니다. 대신 플레이어 출력을 AVPlayerLayer의 인스턴스로 전달해야합니다. 수동으로 레이어를 만들어 뷰의 레이어 계층에 추가 할 수 있지만 iOS의 경우에는 이렇게하는 것이 더 편리합니다. UIView는 항상 Core Animation 레이어를 통해 지원됩니다. 기본적으로 이것은 CALayer의 일반적인 인스턴스가 될 것입니다.하지만 뷰가 인스턴스화 될 때마다 사용할 사용자 정의 CALayer를 반환하기 위해 UIView에서 layerClass 메서드를 재정 의하여 사용되는 백업 레이어 유형을 사용자 정의 할 수 있습니다. AVPlayerLayer를 사용하면 레이어와 레이어 계층 구조를 수동으로 만들고 조작 할 필요가 없으므로보다 편리하게 AVPlayerLayer를 사용할 수 있습니다. 아래는 THPlayerView 클래스의 구현을 제공한다.

```Swift
import UIKit
import AVFoundation

@objc
class THPlayerView: UIView {
    
    @IBOutlet var overlayView: THOverlayView!
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    init(player: AVPlayer) {
        super.init(frame: CGRect.zero)
        
        backgroundColor = .black
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        if let playerLayer = layer as? AVPlayerLayer {
            playerLayer.player = player
        }
        
        Bundle.main.loadNibNamed("THOverlayView", owner: self, options: nil)
        
        addSubview(overlayView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.overlayView.frame = bounds
    }
    
    func transport() -> THTransport {
        return overlayView
    }
}
```

1. THOverlayView 뷰 인스턴스에 대한 포인터를 저장하는 개인 등록 정보를 정의하는 클래스 확장을 작성하십시오. 이 클래스는 비디오 재생을 조작하기위한 사용자 인터페이스 컨트롤을 제공합니다.
2. layerClass 클래스 메서드를 재정 의하여 AVPlayerLayer 클래스를 반환합니다. THPlayerView의 인스턴스가 생성 될 때마다 AVPlayerLayer를 백업 레이어로 사용합니다.
3. 생성시 고유 한 크기가 없기 때문에 크기가 0 인 프레임으로 수퍼 클래스 이니셜 라이저를 호출합니다. 프레임을 적절히 설정하기 위해이 뷰를 표시하는 것은 뷰 컨트롤러의 책임입니다.
4.이 클래스의 주요 코드 행입니다. 초기화 프로그램에서 전달 된 AVPlayer 인스턴스를 가져 와서 AVPlayerLayer에 설정하려고합니다. 이렇게하면 AVPlayer의 비디오 출력을 AVPlayerLayer 인스턴스로 보낼 수 있습니다.
5. 오버레이뷰는 NIB에 정의되어 있으므로 loadNibNamed : owner : options 메소드를 호출하여 뷰를 인스턴스화합니다. 뷰가 생성되어 제대로 overlayView 속성에 할당되면 하위 뷰로 추가됩니다.
THPlayerView 구현이 완료되면 THPlayerController 클래스를 살펴 보겠습니다.

### Creating the Video Controller
THVideoPlayer / Controllers 그룹 아래에서 THPlayerController 클래스의 스텁 된 구현을 찾을 수 있습니다. 이 클래스는 이 애플리케이션에서 많은 작업을 수행하는 클래스이며 여기에서 핵심 재생 API를 사용합니다.
THPlayerController의 인스턴스는 initWithURL : initializer를 호출하여 만들어져 재생할 미디어에 대해 NSURL을 전달합니다. AVPlayer는 로컬 및 스트리밍 미디어를 재생하는데 사용할 수 있으므로 이 URL은 로컬 파일 URL 또는 원격 HTTP URL이 될 수 있습니다. 이 클래스는 클라이언트 UIViewController가 뷰 계층 구조에 뷰를 추가 할 수 있도록 연관된 뷰에 대한 읽기 전용 특성을 추가로 제공합니다. 반환되는 뷰는 THPlayerView의 인스턴스이지만, 클라이언트의 숨겨진 정보이므로 일반 UIView로 반환합니다.
클래스 구현으로 전환하면 컨트롤러의 내부 속성을 정의하는 클래스 확장을 만드는 것으로 시작한다.

```objectivec
#import "THPlayerController.h"
#import <AVFoundation/AVFoundation.h>
#import "THTransport.h"
#import "THPlayerView.h"
#import "AVAsset+THAdditions.h"
#import "UIAlertView+THAdditions.h"

// AVPlayerItem's status property
#define STATUS_KEYPATH @"status"

// Refresh interval for timed observations of AVPlayer
#define REFRESH_INTERVAL 0.5f

// Define this constant for the key-value observation context.
static const NSString *PlayerItemStatusContext;


@interface THPlayerController () <THTransportDelegate>

@property (strong, nonatomic) AVAsset *asset;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) THPlayerView *playerView;

@property (weak, nonatomic) id <THTransport> transport;

@property (strong, nonatomic) id timeObserver;
@property (strong, nonatomic) id itemEndObserver;
@property (assign, nonatomic) float lastPlaybackRate;

@end
```

먼저 객체에 필요한 저장 영역 특성을 정의하는 클래스 확장을 작성하여 이 클래스의 구현을 시작합니다. 이 확장은 THTransport Delegate 프로토콜을 채택하고 전송 속성도 정의 함을 알 수 있습니다. 이 클래스와 비디오 재생을 관리하기위한 사용자 인터페이스를 정의하는 THOverlayView 간에는 상당한 양의 통신이 발생합니다. 이러한 클래스는 의사 소통이 필요하지만 서로를 직접적으로 알 필요는 없습니다. 이 관계를 분리하기 위해 THTransport 및 THTransportDelegate 프로토콜이 도입되었습니다.

```objectivec
@protocol THTransportDelegate <NSObject>

- (void)play;
- (void)pause;
- (void)stop;

- (void)scrubbingDidStart;
- (void)scrubbedToTime:(NSTimeInterval)time;
- (void)scrubbingDidEnd;

- (void)jumpedToTime:(NSTimeInterval)time;

@end

@protocol THTransport <NSObject>

@property (weak, nonatomic) id <THTransportDelegate> delegate;

- (void)setTitle:(NSString *)title;
- (void)setCurrentTime:(NSTimeInterval)time duration:(NSTimeInterval)duration;
- (void)setScrubbingTime:(NSTimeInterval)time;
- (void)playbackComplete;

@end
```

THOverlayView는 오버레이뷰와 통신하기위한 공식적인 인터페이스를 제공하는 THTransport 프로토콜을 채택합니다. 사용자가 스크러버 위치를 변경하거나 재생 / 일시 중지 버튼을 두드리는 등 전송 내용이 변경되면 컨트롤러에서 적절한 델리게이트 콜백이 수행됩니다. 조만간이 작업을 보게 될 것이므로 아래와 같이 THPlayerController 구현으로 넘어갑니다.

```objectivec
@implementation THPlayerController
#pragma mark - Setup

- (id)initWithURL:(NSURL *)assetURL {
    self = [super init];
    if (self) {
        _asset = [AVAsset assetWithURL:assetURL];                           // 1
        [self prepareToPlay];
    }
    return self;
}

- (void)prepareToPlay {
    NSArray *keys = @[@"tracks", @"duration", @"commonMetadata"];
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset          // 2
                           automaticallyLoadedAssetKeys:keys];

    [self.playerItem addObserver:self                                       // 3
                      forKeyPath:STATUS_KEYPATH
                         options:0
                         context:&PlayerItemStatusContext];

    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];          // 4

    self.playerView = [[THPlayerView alloc] initWithPlayer:self.player];    // 5
    self.transport = self.playerView.transport;
    self.transport.delegate = self;
}

// More methods to follow ...

@end
```

1. 초기화 메소드에 전달 된 URL에 대한 AVAsset을 작성하여 시작하십시오. Asset이 생성되면 컨트롤러의 prepareToPlay 메소드를 호출하여이 Asset을 재생하는 데 필요한 인프라를 설정합니다.
2. 프레임 워크는 Asset의 tracks 속성을 자동으로로드하므로 AVAsynchronousKeyValueLoading 프로토콜을 통해이 속성을 수동으로로드해야 할 필요가 없습니다. 그러나 과거에는 액세스해야하는 다른 Asset 속성의 경우 loadValuesAsynchronouslyForKeys : completionHandler : dance를 수행해야했습니다. iOS 7 및 Mac OS 10.9의 AVPlayerItem에 새로운 기능이 추가되어 새로운 initWithAsset : automaticallyLoadedAssetKeys : 또는 playerItemWithAsset : automaticallyLoadedAssetKeys : initializers를 사용하여 AVPlayerItem 인스턴스를 만들어 프레임 워크에 임의의 속성 집합로드를 위임 할 수 있습니다. 두 형식 중 하나는 NSArray를 두 번째 인수로 사용하며 AVPlayerItem이 초기로드 순서를 거치면서 로드하려는 Asset 키를 포함합니다. 이 접근법을 사용하여 tracks, duration 및 commonMetadata 속성을 자동으로 로드합니다.
3. AVPlayerItem의 status 속성을 관찰자로 추가하십시오. 생성시 AVPlayerItemStatusUnknown 유형의 상태로 플레이어 항목이 시작됩니다. 플레이어 항목은 상태가 AVPlayerItemStatusReadyToPlay로 변경 될 때까지 재생할 수 없습니다. 상태 속성을 관찰하는 키 - 값으로이 전환을 관찰 할 수 있습니다.
4. 새로 생성 된 AVPlayerItem에 대한 AVPlayer의 인스턴스를 만듭니다. AVPlayer는 미디어를 대기열에 넣는 프로세스를 즉시 시작합니다.
5. 마지막으로, THPlayerView 인스턴스를 만들고 AVPlayer 인스턴스에 대한 포인터를 전달합니다. 또한 THPlayerController와 THTransport 사이의 관계를 설정합니다.

### Observing Status Changes
THPlayerController를 플레이어 아이템의 status 속성의 옵저버로 설정했습니다. 해당 속성을 관찰하기 전에, 아래와 같이 observeValueForKeyPath : ofObject : change : context 메소드를 구현해야한다.

```Objectivec
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    if (context == &PlayerItemStatusContext) {

        dispatch_async(dispatch_get_main_queue(), ^{                        // 1

            [self.playerItem removeObserver:self forKeyPath:STATUS_KEYPATH];

            if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {

                // Set up time observers.                                   // 2
                [self addPlayerItemTimeObserver];
                [self addItemEndObserverForPlayerItem];

                CMTime duration = self.playerItem.duration;

                // Synchronize the time display                             // 3
                [self.transport setCurrentTime:CMTimeGetSeconds(kCMTimeZero)
                                      duration:CMTimeGetSeconds(duration)];

                // Set the video title.
                [self.transport setTitle:self.asset.title];                 // 4

                [self.player play];                                         // 5

            } else {
                [UIAlertView showAlertWithTitle:@"Error" message:@"Failed to load video"];
            }
        });
    }
}
```

1. AV Foundation은 어떤 스레드에서 상태 변경 알림을 할 것인지 지정하지 않으므로 추가 조치를 취하기 전에 dispatch_async를 사용하여 당신이 원한다면 메인 스레드로 다시 디스패치한다.
2. private addPlayerItemTimeObserver 및 addItemEndObserverForPlayerItem 메소드를 호출하여 플레이어의 시간 옵저버를 설정합니다. 다음 절에서는 이러한 방법과 시간 관찰에 대해 전반적으로 논의 할 것입니다.
3. 전송 개체에 현재 시간 및 기간을 설정합니다. 이렇게하면 사용자 인터페이스의 시간 표시가 재생중인 미디어와 올바르게 동기화됩니다. 전송 객체는 CMTime을 이해하지 못하지만 NSTimeInterval 유형으로 표시되는 초 단위로 시간을 처리합니다. CMTimeGetSeconds 함수를 사용하여 CMTime 값을 초 단위로 변환합니다. 코어 미디어는 start currentTime 인수로 사용할 상수 kCMTimeZero를 정의하며 플레이어 항목의 지속 시간을 두 번째 인수로 사용합니다.
4. 트랜스 포트에 제목 문자열을 전달하여 Asset 제목을 디스플레이에 표시 할 수 있습니다 (Asset의 메타 데이터에있는 경우). AVAsset에는 title 속성이 없습니다. 이 코드는 AVAsset에 추가하여 코드를 더 읽기 쉽게 만드는 카테고리 메소드입니다. 이 카테고리 메소드는 이전 장에서 다뤘던 메타 데이터 API를 사용하며 특히 애셋의 commonMetadata에서 AVMetadataCommonKeyTitle 값을 가져옵니다. 자세한 내용은 AVAsset + TH 추가 정보를 살펴보십시오.
5. 이제 AVPlayer에서 play 메서드를 호출하여 재생을 시작할 준비가되었습니다. 마지막으로, 상태 키 경로를 관찰 한 후에 자기를 관찰자로 지우고 싶을 것이다.
이 시점에서 앱을 실행하고 포함 된 동영상 중 하나를 재생할 수 있습니다. 비디오가 재생 되더라도 사용자 인터페이스 컨트롤은 아직 기능을 제공하지 않으며 사용자 인터페이스에서 제공하는 피드백도 없습니다. 그러면 addPlayerItemTimeObserver 메소드로 되돌아갑니다. 이 방법에 대한 구현을 제공해야하지만 먼저 AVPlayer에서 시간 변경을 관찰하는 방법에 대해 이야기해야합니다.

## Time Observation
우리는 KVO를 사용하여 플레이어 아이템의 상태 속성을 관찰하는 방법을 논의하고 보았습니다. KVO는 일반적인 주 관측에 적합하며 AVPlayerItem 및 AVPlayer에서 여러 속성을 관찰하는 데 유용합니다. 그러나 KVO가 적합하지 않은 곳은 `AVPlayer의 시간 변경을 관찰`하는 것입니다. 이러한 유형의 관측은 본질적으로 매우 동적이며 표준 키 - 값 관측에 의해 제공되는 것보다 정밀한 분해능을 필요로합니다. 이러한 요구를 충족시키기 위해 AVPlayer는 시간 변화가 발생했을 때이를 정확하게 관찰 할 수있는 두 가지 시간 기반 관찰 방법을 제공합니다. 각각을 살펴 보겠습니다.

### Periodic Time Observation
가장 일반적으로 정기적인 주기마다 시간 간격을 알리는 것이 좋습니다. 시간이 경과함에 따라 시간 표시를 업데이트하거나 시각적 재생 헤드의 위치를 ​​이동해야 할 때 필수적입니다. AVPlayer의 addPeriodicTimeObserverForInterval : queue : usingBlock : 메서드를 사용하면 이러한 유형의 변경 사항을 쉽게 관찰 할 수 있습니다. 이 방법을 사용하려면 다음 인수를 전달해야합니다.
 * interval : 통보해야 할주기적인 시간 간격을 지정하는 CMTime 값.
 * queue : 통지를 게시해야하는 직렬 발송 대기열입니다. 가장 일반적으로 이러한 알림은 명시 적으로 지정되지 않은 경우 기본적으로 사용되는 기본 대기열에서 발생해야합니다. API가 동시 대기열을 처리하도록 작성되지 않았으므로 동시 발송 대기열을 사용해서는 안됩니다. 그렇게하면 정의되지 않은 동작이 발생합니다.
 * block : 지정한 간격으로 대기열에서 호출되는 콜백 블록. 이 블록은 플레이어의 현재 시간을 나타내는 CMTime 값을 전달합니다.

 ### Boundary Time Observation
 또한 AVPlayer는 플레이어의 타임 라인에서 다양한 경계 지점을 탐색 할 수 있도록 시간을 관찰하는보다 특수화 된 방법을 제공합니다. 비디오가 재생 될 때 사용자 인터페이스 변경 사항을 동기화하거나 비주얼한 기록을 유지하려면 이 기능이 유용 할 수 있습니다. 예를 들어 사용자의 재생 진행률을 결정하기 위해 25%, 50% 및 75% 경계에서 마커를 정의 할 수 있습니다. 이 기능을 사용하려면 addBoundaryTimeObserverForTimes : queue : usingBlock : 메서드를 사용하여 다음 인수를 제공합니다.
 * times : 알림을 받고자하는 경계 지점을 지정하는 CMTime 값의 NSArray입니다.
 * queue :주기 시간 옵저버와 마찬가지로,이 메소드에 통지를 게시해야하는 직렬 디스패치 큐를 제공합니다. NULL을 지정하는 것은 명시 적으로 주 큐를 설정하는 것과 동일합니다.
 * block : 일반 재생 중에 경계 지점 중 하나가 통과 할 때마다 대기열에서 호출되는 콜백 블록입니다. 이상하게도, 블록은 통과 한 CMTime 값을 제공하지 않으므로 해당 결정을 내리기 위해 몇 가지 추가 계산을 수행해야합니다.

샘플 앱은 경계 시간 관측을 사용하지 않지만 주기적인 시간 관측은 기능에 필수적입니다. addPlayerItemTimeObserver 메소드를 구현하여이 주기적 관찰을 이용하는 방법을 살펴 보자.

```objectivec
- (void)addPlayerItemTimeObserver {
    
    // Create 0.5 second refresh interval - REFRESH_INTERVAL == 0.5
    CMTime interval =
        CMTimeMakeWithSeconds(REFRESH_INTERVAL, NSEC_PER_SEC);              // 1
    
    // Main dispatch queue
    dispatch_queue_t queue = dispatch_get_main_queue();                     // 2
    
    // Create callback block for time observer
    __weak THPlayerController *weakSelf = self;                             // 3
    void (^callback)(CMTime time) = ^(CMTime time) {
        NSTimeInterval currentTime = CMTimeGetSeconds(time);
        NSTimeInterval duration = CMTimeGetSeconds(weakSelf.playerItem.duration);
        [weakSelf.transport setCurrentTime:currentTime duration:duration];  // 4
    };
    
    // Add observer and store pointer for future use
    self.timeObserver =                                                     // 5
        [self.player addPeriodicTimeObserverForInterval:interval
                                                  queue:queue
                                             usingBlock:callback];
}
```

```
노트
AV Foundation은 매우 긴 클래스와 메소드 이름을 사용합니다. 블록과 결합하면 라인 길이가 상당히 커질 수 있습니다. 이 방법은 좀 더 간결하게 작성 될 수 있지만 게시자가 책을 14인치 넓게 만들기로 결정할 때까지 코드 형식을 지정해야합니다. 실제 프로젝트 코드에서 좀 더 간결하게 작성하는 것이 좋습니다.
```

1. CMTime을 작성하여 통지해야하는 시간 간격을 정의하십시오. 간격은 0.5 초로 정의되며 플레이어의 시간 표시를 올바르게 업데이트하기에 충분한 세분성을 제공합니다.
2. 콜백 알림을 게시 할 디스패치 큐를 정의하십시오. 거의 모든 경우에 주 스레드에서 사용자 인터페이스를 업데이트하기 위해 일반적으로 이러한 유형의 알림을 사용하기 때문에 주 큐를 사용하게됩니다.
3. 정의한주기 간격으로 호출 될 콜백 블록을 정의하십시오. 블록이 자기에 대한 약한 참조를 포착하는 것이 매우 중요합니다. 그렇게하지 않으면 진단하기 힘든 메모리 누출로 끝나게됩니다.
4. 콜백 블록의 본문에서 CMTimeGetSeconds 함수를 사용하여 블록의 CMTime 값을 NSTimeInterval로 변환하려고합니다. 마찬가지로 플레이어 아이템의 재생 시간도 변환합니다. 이 기간을 지나는 것은 이미 KVO 콜백에서 전송 시간을 경과했기 때문에 불필요한 것으로 보일 수 있지만 미디어가로드 될 때 지속 시간이 변경 될 수 있으므로 사용자 인터페이스가 올바르게 동기화되도록 하려면 가장 최근 값을 전달하는 것이 가장 좋습니다.
5. 마지막으로 addPeriodicTimeObserverForInterval : queue : usingBlock : 메서드를 정의 된 인수와 함께 호출합니다. 이 호출은 불투명 한 id 유형 포인터를 리턴합니다. 이러한 콜백을 수행하려면 강력한 참조를 유지해야합니다. 이 포인터는이 관측기를 제거하는데도 사용됩니다.

### Item End Observer
관찰하고자하는 또 다른 일반적인 이벤트는 항목의 재생이 완료 될 때입니다. 이것은 이전에 보았던 것과 같은 시간 기반의 관찰은 아니지만 유사한 용어로 생각하는 경향이 있습니다. 재생이 완료되면 AVPlayerItem은 AVPlayerItemDidPlayToEndTimeNotification이라는 알림을 게시합니다. THPlayerController 인스턴스는 적절한 조치를 취할 수 있도록이 통지의 옵저버로 등록해야합니다. 아래는 addItemEndObserverForPlayerItem 메소드의 구현을 제공한다.

```objectivec
- (void)addItemEndObserverForPlayerItem {

    NSString *name = AVPlayerItemDidPlayToEndTimeNotification;

    NSOperationQueue *queue = [NSOperationQueue mainQueue];

    __weak THPlayerController *weakSelf = self;                             // 1
    void (^callback)(NSNotification *note) = ^(NSNotification *notification) {
        [weakSelf.player seekToTime:kCMTimeZero                             // 2
                  completionHandler:^(BOOL finished) {
            [weakSelf.transport playbackComplete];                          // 3
        }];
    };

    self.itemEndObserver =                                                  // 4
        [[NSNotificationCenter defaultCenter] addObserverForName:name
                                                          object:self.playerItem
                                                           queue:queue
                                                      usingBlock:callback];
}

- (void)dealloc {
    if (self.itemEndObserver) {                                             // 5
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self.itemEndObserver
                      name:AVPlayerItemDidPlayToEndTimeNotification
                    object:self.player.currentItem];
        self.itemEndObserver = nil;
    }

}
```
1. 블록을 정의하기 전에 먼저 self에 대한 약한 참조를 정의합니다. 주기적 시간 관찰에 사용되는 콜백 블록과 마찬가지로 자기에 대한 약한 참조를 포착하지 못하면 메모리 누수가 발생합니다. 이러한 블록 기반의 유지 사이클은 진단하기가 어려우며 빠르게 숱이 줄어들 수 있습니다.
2. 재생이 완료되면 플레이어 인스턴스에서 seekToTime : kCMTimeZero를 호출하여 재생 헤드 커서를 0 위치로 다시 위치시킵니다.
3. # 2에서 탐색 호출이 완료되면 전송이 완료되었음을 전송자에게 알리고 시간 표시 및 스크러버를 재설정 할 수 있습니다.
4. NSNotificationCenter에 등록하여 itemEndObserver를 해당 옵저버로 추가하고 정의한 인수를 제공합니다.
5. 마지막으로, dealloc 메소드를 대체하여 제어기가 할당 해제 될 때 itemEndObserver를 옵저버로 제거합니다.
응용 프로그램을 실행하십시오. 비디오가 재생되고 시간이 갈수록 현재 및 남은 시간 레이블이 값을 업데이트하는 것을 볼 수 있으며 시간 스크러버가 그에 따라 재생 헤드 위치를 업데이트하는 것을 볼 수 있습니다.
전송 컨트롤이 예상대로 작동하도록 다양한 대리자 콜백 메서드를 구현해 보겠습니다.

### Transport Delegate Callbacks
THTransportDelegate 프로토콜에 의해 제공되는 간단한 전송 콜백의 구현부터 시작합시다. 아래는 이러한 메소드의 구현을 제공한다.

```objectivec
- (void)play {
    [self.player play];
}

- (void)pause {
    self.lastPlaybackRate = self.player.rate;
    [self.player pause];
}

- (void)stop {
    [self.player setRate:0.0f];
    [self.transport playbackComplete];
}

- (void)jumpedToTime:(NSTimeInterval)time {
    [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];

}
```

play의 구현은 플레이어의 동일한 이름의 메서드를 위임하기 때문에 자체 설명이 가능해야합니다. 마찬가지로 pause 메서드는 플레이어의 일시 중지 메서드를 위임하지만 가사용 목적으로 lastPlaybackRate를 캡처합니다. stop 메소드는 setRate를 호출하는데, pause를 호출하는 것과 동일한 값인 0을 전달하지만 동일한 효과를 얻는 다른 방법을 보여줍니다. 또한 전송시 playbackComplete를 호출하여 스크러버 표시 위치를 업데이트 할 수 있습니다. jumpedToTime : 메서드는 플레이어의 seekToTime : 메서드를 사용하여 타임 라인 내의 임의의 점으로 이동합니다. 이 장의 뒷부분에서이 방법을 사용하는 방법을 확인할 수 있습니다.
다음으로 스크러빙 관련 메소드를 구현하는 방법을 살펴 보겠습니다. UISlider 컨트롤과 상호 작용하는 동안 사용자가 수행하는 세 가지 이벤트 단계를 반영하여 구현할 세 가지 방법이 있습니다.

```objectivec
- (void)scrubbingDidStart {                                                 // 1
    self.lastPlaybackRate = self.player.rate;
    [self.player pause];
    [self.player removeTimeObserver:self.timeObserver];
}

- (void)scrubbedToTime:(NSTimeInterval)time {                               // 2
    [self.playerItem cancelPendingSeeks];
    [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
}

- (void)scrubbingDidEnd {                                                   // 3
    [self addPlayerItemTimeObserver];
    if (self.lastPlaybackRate > 0.0f) {
        [self.player play];
    }
}
```

1. scrubbingDidStart는 터치 다운 이벤트 (UIControlEventTouchDown)에 대한 응답으로 호출됩니다. 이 방법에서는 현재 재생 속도를 캡처 한 다음 플레이어를 일시 중지합니다. 스크러빙이 끝나면 복원 할 수 있도록 현재 속도를 캡처합니다. 또한 사용자가 미디어를 스크러빙 할 때 이러한 이벤트가 발생하지 않기 때문에 현재주기적인 시간 관찰자를 제거합니다.
2. scrubbedToTime은 UISlider 인스턴스의 값 변경 이벤트 (UIControlEventValueChanged)에 대한 응답으로 호출됩니다. 이 메서드는 사용자가 슬라이더 위치를 이동하면 빠르게 호출되기 때문에 먼저 플레이어 항목에서 cancelPendingSeeks를 호출해야합니다. `이전 탐색 요청이 완료되지 않은 경우 검색 작업이 누적되지 않도록 성능을 최적화합니다.` seekToTime을 호출하여 새로운 탐색을 시작합니다. NSTimeInterval 값을 CMTime으로 변환합니다.
3. scrubbingDidEnd는 터치 업 내부 이벤트 (UIControlEventTouchUpInside)에 대한 응답으로 호출되어 사용자가 스크러빙 작업을 완료했음을 나타냅니다. 이 메소드에서는 addPlayerItemTimeObserver를 호출하여 주기적 시간 옵저버를 다시 추가합니다. 그런 다음 lastPlaybackRate 값을 확인하고 동영상 재생 중임을 나타내는 0보다 큰 경우 동영상 재생을 다시 시작합니다.

이를 통해 핵심 비디오 재생 동작이 완료되었습니다! 응용 프로그램을 실행하면 이제 비디오를 재생, 일시 중지 및 스크럽 할 수 있습니다. 핵심 동작이 작동하면 비디오 재생 환경을 향상시키는 몇 가지 기능과 기능을 추가하여 플레이어를 더욱 향상시킬 수있는 몇 가지 방법을 살펴볼 시간입니다.

### Creating a Visual Scrubber
뷰의 레이블이 있는 플레이어의 오른쪽 위 모서리에있는 버튼을 발견했을 것입니다. 탭을 두드리면, 메인 네비게이션 바 아래의 검정색 막대의 표시를 토글합니다. 특히 유용한 기능은 아니지만이 부동산을 더 잘 활용할 수 있는지 알아 봅시다.
AV Foundation에서 찾을 수 있는 유용한 유틸리티 클래스는 AVAssetImageGenerator입니다. 이 클래스는 AVAsset의 비디오 트랙에서 이미지를 추출하는데 사용할 수 있습니다. 이를 통해 응용 프로그램의 사용자 인터페이스를 향상시키는데 사용할 수 있는 하나 이상의 축소판을 생성 할 수 있습니다.
AVAssetImageGenerator는 비디오 Asset에서 이미지를 검색하는 두 가지 방법을 제공합니다.
 * copyCGImageAtTime : actualTime : 오류 : 지정된 시간에 이미지를 캡처 할 수 있습니다. 이 기능은 단일 이미지를 캡처하여 비디오 목록에 비디오 축소판 그림으로 표시하려는 경우에 가장 유용합니다.
 * generateCGImagesAsynchronouslyForTimes : completionHandler : 첫 번째 인수에 지정된 시간 동안 일련의 이미지를 생성 할 수 있습니다. 이렇게하면 한 번의 호출로 이미지 콜렉션을 효율적으로 생성 할 수 있습니다.

 ```
 노트
AVAssetImageGenerator는 로컬 및 점진적으로 다운로드 한 에셋 모두에 대한 이미지를 생성하는 데 사용할 수 있습니다. 그러나 HTTP 라이브 스트림에서 이미지를 생성 할 수는 없습니다.
 ```

 이 기능을 사용하여 빌드 할 수 있는 좋은 기능 중 하나는 시각적인 스크러버를 만드는 것입니다. 하단 툴바에 표준 스크러버 막대를 표시하는 대신 시각적 스크러버를 만들어 사용자가 타임 라인에서 위치를 쉽게 식별하고 바로 이동할 수 있습니다. 이 기능을 구현하는 방법을 살펴 보겠습니다.

 ```objectivec
#import "THPlayerController.h"
#import <AVFoundation/AVFoundation.h>
#import "THTransport.h"
#import "THPlayerView.h"
#import "AVAsset+THAdditions.h"
#import "UIAlertView+THAdditions.h"
#import "THThumbnail.h"

...

@interface THPlayerController () <THTransportDelegate>

@property (strong, nonatomic) AVAsset *asset;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) THPlayerView *playerView;

@property (weak, nonatomic) id <THTransport> transport;

@property (strong, nonatomic) id timeObserver;
@property (strong, nonatomic) id itemEndObserver;
@property (assign, nonatomic) float lastPlaybackRate;

@property (strong, nonatomic) AVAssetImageGenerator *imageGenerator;

@end
 ```

THThumbnail.h 헤더를 가져옵니다. THThumbnail 클래스는 캡처 된 이미지와 관련 시간을 저장하는데 사용하는 프로젝트의 간단한 모델 객체입니다. 또한 AVAssetImageGenerator 유형의 새 속성을 추가합니다.
그런 다음 generateThumbnails라는 새 메소드를 추가하고 상태 관측 콜백 메소드 내부에서이 메소드를 호출하십시오.

```objectivec
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    if (context == &PlayerItemStatusContext) {

        dispatch_async(dispatch_get_main_queue(), ^{

            [self.playerItem removeObserver:self forKeyPath:STATUS_KEYPATH];

            if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {

                // Set up time observers.
                [self addPlayerItemTimeObserver];
                [self addItemEndObserverForPlayerItem];

                CMTime duration = self.playerItem.duration;

                // Synchronize the time display
                [self.transport setCurrentTime:CMTimeGetSeconds(kCMTimeZero)
                                      duration:CMTimeGetSeconds(duration)];

                // Set the video title.
                [self.transport setTitle:self.asset.title];

                [self.player play];

                [self generateThumbnails];
            } else {
                [UIAlertView showAlertWithTitle:@"Error"
                                        message:@"Failed to load video"];
            }
        });
    }
}

- (void)generateThumbnails {
    self.imageGenerator =                                                   // 1
        [AVAssetImageGenerator assetImageGeneratorWithAsset:self.asset];

    // Generate the @2x equivalent
    self.imageGenerator.maximumSize = CGSizeMake(200.0f, 0.0f);             // 2

    CMTime duration = self.asset.duration;

    NSMutableArray *times = [NSMutableArray array];                         // 3
    CMTimeValue increment = duration.value / 20;
    CMTimeValue currentValue = kCMTimeZero;
    while (currentValue <= duration.value) {
    CMTime time = CMTimeMake(currentValue, duration.timescale);
        [times addObject:[NSValue valueWithCMTime:time]];
        currentValue += increment;
    }

    __block NSUInteger imageCount = times.count;                            // 4
    __block NSMutableArray *images = [NSMutableArray array];

    AVAssetImageGeneratorCompletionHandler handler;                         // 5

    handler = ^(CMTime requestedTime,
                CGImageRef imageRef,
                CMTime actualTime,
                AVAssetImageGeneratorResult result,
                NSError *error) {

        if (result == AVAssetImageGeneratorSucceeded) {                     // 6
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            id thumbnail =
                [THThumbnail thumbnailWithImage:image time:actualTime];
            [images addObject:thumbnail];
        } else {
            NSLog(@"Failed to create thumnail image.");
        }

        // If the decremented image count is at 0, we're all done.
        if (--imageCount == 0) {                                            // 7
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *name = THThumbnailsGeneratedNotification;
                NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                [nc postNotificationName:name object:images];
            });
        }
    };

    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times       // 8
                                              completionHandler:handler];
}
```

1. 컨트롤러의 Asset 속성에 대한 참조를 전달하여 새 AVAssetImageGenerator 인스턴스를 만드는 것으로 시작하십시오. 이 개체에 대한 강력한 참조를 유지 관리하는 것이 중요합니다. 이 점에주의를 기울이지 않으면 콜백이 호출되지 않으므로 좌절감을 느낄 수 있습니다.
2. AVAssetImageGenerator는 이미지 생성을 구성하는 데 사용할 수있는 몇 가지 속성을 제공합니다. 대부분의 속성에 적절한 기본값을 제공하지만 거의 항상 명시 적으로 구성해야하는 속성은 maximumSize입니다. 기본적으로 이미지는 원래 크기로 캡처됩니다. 720p 또는 1080p 비디오로 작업하는 경우 매우 큰 이미지가 생성됩니다. maximumSize 속성을 설정하면 이미지가 자동으로 필요한 크기로 조정되므로 성능이 크게 향상됩니다. 너비가 200이고 높이가 0 인 CGSize를 지정합니다. 그러면 지정된 너비로 이미지가 생성되고 비디오의 가로 세로 비율에 따라 자동으로 높이가 조정됩니다.
3. 할 일은 캡처 할 비디오의 위치를 ​​지정하는 CMTime 값 컬렉션을 생성하기 위해 일부 계산을 수행하는 것입니다. 이 코드는 20 개의 CMTime 값을 비디오 타임 라인에 고르게 배치합니다. 비디오 기간 동안 반복하여 CMTimeMake 함수를 사용하여 새 시간을 만든 다음 결과 CMTime을 NSValue로 래핑하여 times 배열에 저장할 수 있습니다.
4. times 배열의 요소 수를 기반으로 imageCount라는 __block 변수를 정의합니다. 모든 이미지가 처리 된시기를 결정하는 데 사용됩니다. 또한 다른 __block 변수를 정의하십시오.이 시간은 NSMutableArray 유형의 이미지입니다. 생성 된 이미지 모음을 저장하는 데 사용됩니다. __block 한정자는 콜백 블록이 복사본이 아닌이 포인터에서 직접 작동하도록 보장하는 데 사용됩니다.
5. 다음에, AVAssetImageGeneratorCompletionHandler 형의 콜백 블록을 정의합니다. 이것은 더 길어진 블록 정의 중 하나이기 때문에 인수를 살펴 보겠습니다.
 * requestedTime : 요청한 원래 시간. 이것은 이미지를 생성하기 위해 호출에서 지정한 시간 배열의 값에 해당합니다.
 * imageRef : 생성 된 CGImageRef 또는 지정된 시간의 이미지를 생성 할 수없는 경우 NULL입니다.
 * actualTime : 이미지가 실제로 생성 된 시간입니다. 특정 효율성을 기반으로, 이것은 요청한 시간과 다를 수 있습니다. 이미지 생성 전에 AVAssetImageGenerator 인스턴스에서 requestedTimeToleranceBefore 및 requestedTimeToleranceAfter 값을 설정하여 requestedTime과 actualTime이 얼마나 근접하게 일치 하는지를 조정할 수 있습니다.
 * result : 이미지 생성이 성공했는지, 실패했는지, 취소되었는지 여부를 나타내는 AVAssetImageGeneratorResult입니다.
 * error : AVAssetImageGeneratorFailed의 AVAssetImageGeneratorResult를받은 경우 질문 할 수있는 NSError 포인터입니다.
6. 결과 값이 AVAssetImageGeneratorSucceeded로 되돌아 왔고 이미지가 성공적으로 생성되었음을 나타내면 반환 된 CGImageRef를 기반으로 새 UIImage를 만듭니다. 그런 다음 이미지와 시간을 래핑하는 새로운 THThumbnail 인스턴스를 만들고이를 배열에 추가하십시오.
7. 콜백 블록을 호출 할 때마다 imageCount 속성을 감소시키고 모든 이미지가 처리되었음을 나타내는 0인지 확인합니다. 그렇다면 이미지 컬렉션을 객체 인수로 전달하는 THThumbnailsGeneratedNotification이라는 새로운 애플리케이션 별 알림을 게시합니다. 이 통지는 뷰 계층에 의해 소비되어 시각적 인 스크러버를 생성하는 데 사용됩니다.

응용 프로그램을 다시 실행하십시오. 이제 Show 버튼을 누르면 검은색 막대가 비디오 파일 내의 다양한 시점을 나타내는 멋진 미리보기 모음으로 바뀌 었음을 알 수 있습니다. 이미지를 탭하면 이전에 구현 한 대리자의 jumpedToTime : 메서드가 호출됩니다. AVAssetImageGenerator는 로컬 Asset과 원격 Asset 모두에 대한 이미지를 생성 할 수 있지만 예상대로 원격 리소스의 이미지를 생성하는데 더 오래 걸립니다. 이 경우 이미지가 반환 될 때마다 시각적 레이아웃을 작성하거나 이미지 캐시에 작성하고 정기적으로 이 캐시를 폴링하는 등 사용자 경험을 향상시키기 위해 몇 가지 효율성을 높일 수 있습니다.

```
노트
대부분의 재생 유스 케이스는 iOS 시뮬레이터에서 테스트 할 수 있습니다. 그러나 실제 장치에서 테스트하면 성능이 훨씬 좋아집니다.
```

### Showing Subtitles
가능한 한 많은 사람들이 응용 프로그램에 액세스 할 수 있도록하는 것이 중요합니다. 즉, 우리는 자신의 모국어로 사용자가 응용 프로그램을 사용할 수 있도록해야하며 청각 장애 또는 기타 접근성 요구가있는 사람들의 요구를 고려해야합니다. 동영상 플레이어 애플리케이션의 사용자를위한 사용자 환경을 개선 할 수있는 한 가지 방법은 가능한 경우 항상 자막을 표시하는 것입니다. AV Foundation은 자막이나 자막 표시에 대한 강력한 지원을 제공합니다. AVPlayerLayer는 이러한 요소를 렌더링 하기위한 지원을 자동으로 제공하며 렌더링 할 내용은 사용자에게 달려 있습니다. 이를 수행하는 방법은 AVMediaSelectionGroup 및 AVMediaSelectionOption 클래스를 사용하는 것입니다.
AVMediaSelectionOption은 AVAsset 내의 대체 미디어 프레젠테이션을 나타냅니다. Asset에는 대체 오디오, 비디오 또는 텍스트 트랙과 같은 대체 미디어 프레젠테이션이 포함될 수 있습니다. 이러한 트랙은 언어 별 오디오 트랙, 대체 카메라 앵글 또는 언어 별 자막에 대해 관심을 가질 수 있습니다. 대체 트랙을 확인하는 방법은 availableMediaCharacteristicsWithMediaSelectionOptions라고하는 AVAsset의 속성을 사용하는 것입니다(필자는 AV Foundation 팀이 정말로 긴 이름을 선호한다고 언급했음을 기억합니다.). 이 속성은 Asset에 포함 된 사용 가능한 옵션의 미디어 특성을 나타내는 문자열 배열을 반환합니다. 특히 AVMediaCharacteristicVisual(비디오), AVMediaCharacteristicAudible (오디오) 또는 AVMediaCharacteristicLegible(자막 또는 자막) 중 하나 이상의 문자열 값을 반환합니다.
사용 가능한 미디어 특성을 요청한 후 AVAssets mediaSelectionGroupForMediaCharacteristic : 메서드를 호출하여 검색 할 옵션의 특정 미디어 특성을 전달할 수 있습니다. 이 메서드는 하나 이상의 상호 배타적 인 AVMediaSelectionOption 인스턴스의 컨테이너 역할을하는 AVMediaSelectionGroup을 반환합니다. 간단한 예를 살펴 보겠습니다.

```objectivec
NSArray *mediaCharacteristics =
    self.asset.availableMediaCharacteristicsWithMediaSelectionOptions;
for (NSString *characteristic in mediaCharacteristics) {
    AVMediaSelectionGroup *group =
        [self.asset mediaSelectionGroupForMediaCharacteristic:characteristic];
    NSLog(@"[%@]", characteristic);
    for (AVMediaSelectionOption *option in group.options) {
            NSLog(@"Option: %@", option.displayName);
    }
}
```

하나 이상의 subtitles가 포함 된 저작물에 대해이 코드를 실행하면 다음과 같은 출력이 생성됩니다.

```
[AVMediaCharacteristicLegible]
Option: English
Option: Italian
Option: Portuguese
Option: Russian
[AVMediaCharacteristicAudible]
Option: English
```

이 예에서는 하나의 영어 오디오 트랙과 함께 여러 개의 자막 트랙이 있음을 알 수 있습니다.
적절한 AVMediaSelectionGroup을 로드하고 원하는 AVMediaSelectionOption을 식별 한 후 다음 단계는 이를 실행하는 것입니다. 이는 활성 AVPlayerItem에서 selectMediaOption : inMediaSelectionGroup :을 호출하여 수행됩니다. 예를 들어, 러시아어 자막을 표시하려면 다음을 작성할 수 있습니다.

```objectivec
AVMediaSelectionGroup *group =
    [self.asset mediaSelectionGroupForMediaCharacteristic:characteristic];
NSLocale *russianLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];
NSArray *options =
    [AVMediaSelectionGroup mediaSelectionOptionsFromArray:group.options
                                               withLocale:russianLocale];
AVMediaSelectionOption *option = [options firstObject];
[self.playerItem selectMediaOption:option inMediaSelectionGroup:group];
```

THPlayerController 클래스에 몇 가지 새로운 메소드를 추가하여 Video Player 앱에서이를 실행 해 봅시다. 아래와 같이 다음과 같이 변경한다.

```objectivec
- (void)prepareToPlay {
    NSArray *keys = @[
        @"tracks",
        @"duration",
        @"commonMetadata",
        @"availableMediaCharacteristicsWithMediaSelectionOptions"
    ];
    
    ...

}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    if (context == &PlayerItemStatusContext) {
        dispatch_async(dispatch_get_main_queue(), ^{

            if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {

                ...

                [self loadMediaOptions];

            } else {
                [UIAlertView showAlertWithTitle:@"Error"
                                        message:@"Failed to load video"];
            }
        });
    }
}

- (void)loadMediaOptions {

}
```

prepareToPlay 메서드에서 `availableMediaCharacteristicsWithMediaSelectionOptions`속성을 속성목록에 추가하여 자동으로 로드 할 수 있습니다. 메인 스레드 차단을 방지하기 위해 미디어 선택 API를 호출하기 전에이 속성을 로드해야합니다. 플레이어 항목을 재생할 준비가되면 loadMediaOptions 메서드를 호출합니다.

```objectivec
- (void)loadMediaOptions {
    NSString *mc = AVMediaCharacteristicLegible;                            // 1
    AVMediaSelectionGroup *group =
        [self.asset mediaSelectionGroupForMediaCharacteristic:mc];          // 2
    if (group) {
        NSMutableArray *subtitles = [NSMutableArray array];                 // 3
        for (AVMediaSelectionOption *option in group.options) {
            [subtitles addObject:option.displayName];
        }
        [self.transport setSubtitles:subtitles];                            // 4
    } else {
        [self.transport setSubtitles:nil];
    }
}
```

1. Asset에 있는 자막 옵션만 찾는데 관심이 있으므로 AVMediaCharacteristicLegible 값으로 미디어 특성 문자열을 정의하십시오.
2. 정의 된 미디어 특성에 해당하는 AVMediaSelectionGroup을 요청합니다.
3. 그룹이 발견되면 (응용 프로그램의 로컬 에셋에는 자막이 포함되어 있고 원격 Asset에는 포함되지 않음) 각 해당 displayName 속성에 대해 묻는 방법으로 뷰 계층에 전달할 사용자 제공 문자열 배열을 만듭니다.
4. 마지막으로 자막 문자열을 자막선택 인터페이스에 표시 할 수 있도록 전송에 자막 문자열 모음을 설정하십시오. else 조건에서 nil을 전달하면 인터페이스를 표시하지 않아야 함을 나타냅니다.

사용자가 자막을 선택하면 해당 선택을 처리하고 현재 플레이어 항목에서 해당 AVMediaSelectionOption을 활성화하는 메서드가 필요합니다. 아래는 이 메소드를 구현하는 방법을 보여준다.

```objectivec
- (void)subtitleSelected:(NSString *)subtitle {
    NSString *mc = AVMediaCharacteristicLegible;
    AVMediaSelectionGroup *group =
        [self.asset mediaSelectionGroupForMediaCharacteristic:mc];          // 1
    BOOL selected = NO;
    for (AVMediaSelectionOption *option in group.options) {
        if ([option.displayName isEqualTo String:subtitle]) {
            [self.playerItem selectMediaOption:option                       // 2
                         inMediaSelectionGroup:group];
            selected = YES;
        }
    }
    if (!selected) {
        [self.playerItem selectMediaOption:nil                              // 3
                     inMediaSelectionGroup:group];
    }
}
```

1. Asset에 포함 된 읽을 수 있는 옵션에 대한 AVMediaSelectionGroup을 검색합니다.
2. 모든 그룹 옵션을 반복하고 subtitleSelected : 메서드에 전달 된 자막 문자열과 일치하는 AVMediaSelectionOption을 찾습니다. 올바른 옵션을 찾으면 플레이어 항목에서 selectMediaOption : inMediaSelectionGroup :을 호출하여 활성화합니다. 이렇게하면 AVPlayerLayer에서 선택한 자막을 즉시 표시 할 수 있습니다.
3. 사용자가 자막 선택 목록에서 "없음"옵션을 선택한 경우, 자막을 표시에서 제거하기 위해 선택한 미디어 옵션에 nil 값을 설정하십시오.
마지막으로해야 할 일은 VideoPlayer-Prefix.pch 파일을 열고 ENABLE_SUBTITLES 정의를 0에서 1로 변경하는 것입니다. 이렇게하면 자막이 현재 미디어에있는 경우 전송보기에서 적절한 자막 선택 인터페이스를 표시 할 수 있습니다.
응용 프로그램을 다시 실행하십시오. 전송 막대의 오른쪽 하단에 새 버튼이 표시됩니다. 사용 가능한 자막을 보려면 선택하십시오. 선택하고 소리내어 만드십시오! 부제 마술.

### Airplay
마지막으로 개선 할 부분은 AirPlay 기능을 비디오 플레이어 앱에 통합하는 것입니다. AirPlay는 Apple의 기술로 사용자는 오디오 및 비디오 컨텐츠를 Apple TV 또는 오디오 전용 컨텐츠로 다양한 타사 오디오 시스템으로 무선으로 스트리밍 할 수 있습니다. Apple TV 또는 다른 오디오 시스템의 소유자라면이 기능이 얼마나 유용 할 수 있는지 알 것입니다. 좋은 소식은이 기능을 앱에 통합하는 것이 정말 쉽다는 것입니다.
AVPlayer에는 allowsExternalPlayback이라는 속성이있어서 AirPlay 재생을 활성화 또는 비활성화 할 수 있습니다.
이 속성의 기본값은 YES입니다. 재생 앱이 추가 작업없이 이 동작을 자동으로 지원한다는 의미입니다. 이것이 일반적으로 바람직한 동작이지만, AirPlay를 비활성화해야하는 강력한 이유가있는 경우이 값을 NO로 설정할 수 있습니다.

### Providing a Route Picker
iOS는 AirPlay 경로를 선택하기위한 글로벌 인터페이스를 제공합니다. 인터페이스를 표시하기위한 사용자 인터페이스와 제스처는 iOS 버전에 따라 다릅니다. iOS 6 이전 버전에서는 홈 버튼을 두 번 탭하여 도크를 불러오고 그림 4.6과 같이 AirPlay 경로 선택기가 나타날 때까지 오른쪽으로 스와이프합니다.

<center>
<image src="Resource/06.png" width="30%" height="30%">
</center>

iOS 7 이상에서는 이 인터페이스에 훨씬 편리하게 액세스 할 수 있습니다. 화면 하단에서 위로 스와이프하여 Control Center를 불러오고 그림 4.7과 같이 AirPlay 버튼을 선택하십시오.

<center>
<image src="Resource/07.png" width="30%" height="30%">
</center>

글로벌 경로 선택기를 사용하면 사용자가 원하는 결과를 얻을 수 있지만 이상적인 사용자 환경은 아닙니다. 특히 iOS 6에서는 앱에서 사용자를 뽑아내어 사용자 워크 플로를 방해합니다. 또한 많은 사용자가 이 글로벌 인터페이스를 인식하지 못할 수도 있으므로이 유용한 기능을 완전히 간과 할 수 있습니다. 대신 AirPlay 경로 선택 인터페이스를 앱 내에서 분명하고 편리하게 제공해야합니다. 흥미롭게도, 사용할 AirPlay 프레임 워크 또는 API는 없습니다. 대신 MPVolumeView라는 Media Player 프레임 워크에서 클래스를 사용합니다.
이 구성 요소를 사용하려면 다음 예제와 같이 MediaPlayer 프레임 워크 (<MediaPlayer / MediaPlayer.h>)에 연결하고 가져 와서 MPVolumeView의 인스턴스를 만듭니다.

```Objectivec
CGRect rect = // desired frame
MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:rect];
[self.view addSubview:volumeView];
```

MPVolumeView의 기본 인스턴스는 최대 두 개의 사용자 인터페이스 요소를 제공합니다. 이름에서 알 수 있듯이 사용자가 전체 시스템 볼륨을 제어 할 수있는 볼륨 슬라이더가 표시됩니다. 이렇게하면 iOS 장치 측면에있는 하드웨어 볼륨 컨트롤을 화면 상으로 누르는 것과 동일한 효과를 얻을 수 있습니다. 사용자가 자신의 네트워크에 AirPlay 지원 장치가 있으면 AirPlay 경로 선택기 단추가 추가로 표시됩니다. 이 버튼을 누르면 사용 가능한 모든 AirPlay 경로 목록이 나타납니다.
경로 버튼을 표시하는 데만 관심이 있다면 다음과 같이 수정할 수 있습니다.

```objectivec
MPVolumeView  *volumeView = [[MPVolumeView alloc] init];
volumeView.showsVolumeSlider = NO;
[volumeView sizeToFit];
[transportView addSubview:volumeView];
```

사용자가 유효한 AirPlay 목적지를 가지고 있고 Wi-Fi가 활성화 된 경우에만 경로 선택기 버튼이 표시된다는 것을 이해하는 것이 중요합니다. 두 조건이 모두 충족되지 않으면 MPVolumeView가 자동으로 버튼을 숨 깁니다.

```
노트
MPVolumeView는 iOS 장치에서 실행중인 경우에만 표시됩니다. iOS 시뮬레이터에서 실행되는 동안 표시되지 않습니다.
```

이전 예제에서 보여준 것보다 더 복잡하지 않기 때문에 앱에서 구현하는 과정을 거치지 않아도됩니다. 앱은 가능한 경우 경로 버튼을 표시하도록 이미 제작되었지만 VideoPlayer-Prefix.pch를 열고 ENABLE_AIRPLAY 정의를 0에서 1로 변경해야합니다. Apple TV 또는 AirPlay 지원 오디오 시스템을 사용하는 경우 응용 프로그램을 실행할 때 AirPlay 경로 선택기가 나타납니다.
AirPlay에 대한 자세한 정보와이 놀라운 기술을 활용할 수있는 방법을 보려면 Apple Developer Center에서 제공되는 [AirPlay Overview1](https://developer.apple.com/library/ios/documentation/AudioVideo/Conceptual/AirPlayGuide/Introduction/Introduction.html) 문서를 확인하십시오.

## Summary
이 장에서는 AV Foundation의 비디오 재생 기능에 대해 자세히 설명했습니다. 이제 AVPlayer를 통해 AVPlayerItem의 인스턴스를 재생하고 AVPlayerLayer 인스턴스에 비디오 출력을 연결하는 방법을 잘 이해해야합니다. 또한 AVAssetImageGenerator를 처음 보았습니다. AVAssetImageGenerator는 플레이어의 비주얼 스크러버를 만드는데 유용하게 사용되었습니다. AV Foundation을 사용하여 다양한 시나리오에서 매우 유용한 수업이 될 것입니다. 마지막으로, AirPlay를 통합하고 AVMediaSelectionGroup 및 AVMediaSelectionOption을 사용하여 자막을 표시함으로써 비디오 재생 환경을 향상시킬 수있는 방법을 살펴 보았습니다. 이 장에서 작성한 샘플 응용 프로그램은 필요한 비디오 재생 솔루션을 개발할 수있는 좋은 기회를 제공해야합니다.