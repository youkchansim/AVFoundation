# Using AV Kit
4 장, "비디오 재생하기"에서는 AVPlayer 및 AVPlayerItem을 사용하여 사용자 정의 비디오 플레이어를 만드는 방법에 대해 자세히 살펴 보았습니다. 맞춤 비디오 플레이어를 만드는 것은 플레이어의 행동과 사용자 인터페이스를 완벽하게 제어 할 수 있기 때문에 많은 경우에 바람직합니다. 그러나 AV Foundation의 강력한 기능을 활용하고 싶지만 Mac OS X의 iOS 또는 QuickTime Player의 비디오 앱과 일치하는 사용자 인터페이스와 경험을 제공하려면 어떻게해야합니까? 이러한 플레이어의 모양과 느낌을 일치시키기 위해서는 상당한 양의 작업이 필요하며 각 iOS 또는 Mac OS X 버전의 모양에 맞게 여러 사용자 인터페이스를 유지해야합니다. 다행히도 AV Kit 덕분에 더 좋은 방법이 존재합니다.
AV Kit은 기본 운영 체제 플레이어의 모양과 느낌과 일치하는 AV Foundation 기반 비디오 플레이어를 만드는 프로세스를 단순화합니다. 이 프레임 워크는 Mac OS X Mavericks에서 처음 소개되었으며 iOS 8부터 iOS에서도 사용할 수 있습니다. 이 장에서는 주로 OS X 용 AV Kit에 초점을 맞추고 있습니다. `그 이유는 iOS 용 AV Kit보다 더 많은 기능을 제공하기 때문입니다`. 그러나 AV Kit의 iOS 버전을 먼저 살펴 보겠습니다.

## AV Kit for iOS
iOS Media Player 프레임 워크는 오랫동안 모든 기능을 갖춘 비디오 재생을 앱에 통합 할 수있는 간단한 방법을 제공하는 `MPMoviePlayerController` 및 `MPMoviePlayerViewController` 클래스를 제공합니다. MPMoviePlayerController는 표준 재생 제어 기능을 제공하며 하위뷰로 삽입하거나 전체 화면으로 표시 할 수 있으며 AirPlay를 통해 Apple TV로 오디오 및 비디오 콘텐츠 스트리밍을 지원하며 기타 유용한 기능을 제공합니다. 이 모든 기능을 통해 우리는 왜 다른 것을 필요로할까요? MPMoviePlayerController의 주된 단점은 블랙 박스 구성 요소가 매우 중요하다는 것입니다. AV Foundation 위에 구축되었지만 불행히도 이러한 토대를 숨 깁니다. 이렇게하면 AVPlayer 및 AVPlayerItem에서 제공하는 고급 기능 중 일부를 사용할 수 없게됩니다. iOS 8부터는 이제 AV Kit 프레임 워크가 제공하는보다 강력한 대안이 있습니다.
iOS 용 AV Kit은 AVPlayerViewController라는 단일 클래스만 포함하는 프레임 워크 표준에 따라 상당히 적당합니다. 이것은 AVPlayer 인스턴스의 재생을 표시하고 제어하는데 사용되는 UIViewController 하위 클래스입니다. AVPlayerViewController는 다음과 같은 속성을 제공하는 아주 간단한 인터페이스를 가지고 있습니다.

   * player : 미디어 콘텐츠를 재생하는 데 사용되는 AVPlayer 인스턴스입니다.
   * showsPlaybackControls : 재생 컨트롤을 표시할지 또는 숨길지를 나타내는 부울 값입니다.
   * videoGravity : 내부 AVPlayerLayer 인스턴스의 비디오 중력을 설정하는 데 사용되는 NSString입니다. AVPlayerLayer가 지원하는 비디오 중력에 대한 재교육이 필요한 경우 4 장을 참조하십시오.
   * readyForDisplay : 비디오 내용이 준비되어 표시 준비가되었는지 여부를 확인하기 위해 관찰 할 수있는 부울 값입니다.

겸손한 인터페이스에도 불구하고, 이 클래스는 많은 유틸리티 가치를 제공합니다. 이 점을 설명하기 위해 이 클래스의 간단한 예제를 살펴 보겠습니다.

```Swift
import UIKit
import AVKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if let url = Bundle.main.url(forResource: "video", withExtension: "m4v") {
            let controller = AVPlayerViewController()
            controller.player = AVPlayer(url: url)
            
            window?.rootViewController = controller
        }
        
        return true
    }
}
```

이 예제는 새로운 AVPlayerViewController를 만들고 AVPlayer의 인스턴스를 설정하고 컨트롤러를 윈도우의 rootViewController로 설정합니다. 아주 적은 코드가 작성되었지만이 예제를 실행하면 그림 5.1과 같은 플레이어가 생성됩니다.

<p align="center">
<image src="Resource/01.png" width="50%" height="50%">
</p>

그림 5.1에서 볼 수 있듯이 AVPlayerViewController는 많은 코드를 작성하지 않고도 많은 기능을 제공합니다. 기본 iOS 비디오 플레이어와 동일한 사용자 인터페이스와 경험을 갖춘 완벽하게 기능하는 플레이어를 만들었습니다. 이 클래스는 UIViewController 하위 클래스이므로 자식보기 컨트롤러로 포함하거나 다른보기 컨트롤러와 마찬가지로 쉽게 표시 할 수 있습니다.


```
노트
이 예제는 playerWithURL : convenience initializer를 사용하여 AVPlayer를 만드는 방법을 보여줍니다. 이것은 단순한 경우에도 효과적이지만 더 많은 제어가 필요할 때 이전 장에서했던 것처럼 전체 재생 스택을 설정하려는 경향이 있습니다.
```

AVPlayerViewController는 MPMoviePlayerController와 달리 사용할 재생 컨트롤을 지정할 수있게하는 controlsStyle 속성을 제공하지 않습니다. 대신 동적으로 업데이트되는 동적 재생 컨트롤을 제공하여 재생중인 콘텐츠에 필요한 사용자 인터페이스를 제공합니다. 즉, 챕터 마커가 있는 로컬 비디오를 재생하든 자막이 있는 비디오를 스트리밍하든 관계없이 사용자에게 항상 적절한 사용자 경험이 제공됩니다. 그림 5.2는 작동중인 대체 컨트롤 스타일 중 일부를 보여줍니다.

<p align="center">
<image src="Resource/02.png" width="50%" height="50%">
</p>

AVPlayerViewController는 iOS 8에서 사용할 수 있는 간단하면서도 강력한 새 클래스입니다. MPMoviePlayerController를 사용하면 프레임 워크에서 제공하는 고급 기능을 사용할 수 있는 전체 AV Foundation 스택을 제공하므로 훌륭한 대안을 제공합니다. AVPlayerViewController에 대한 추가 정보는 WWDC 2014에서 세션 503 : 현대 미디어 재생 마스터 링을 참조하십시오.

## AV Kit for Mac OS X
Mac 용 AV Kit은 Mac OS X Mavericks에서 처음 소개되었습니다. 이 프레임 워크는 AVPlayerView라는 클래스를 제공하므로 모든 기능을 갖춘 비디오 재생을 Mac 응용 프로그램에 쉽게 통합 할 수 있습니다. QuickTime Player X와 동일한 비디오 재생 환경을 제공하므로 Mac 사용자가 기대했던 동작 및 사용자 인터페이스를 쉽게 제공 할 수 있습니다.
AVPlayerView는 AVPlayer 인스턴스의 재생을 표시하고 제어하는데 사용되는 NSView 하위 클래스입니다. 이전 장에서 배운 모든 내용은 AVPlayerView를 사용할 때도 적용되지만 표준화 된 재생 컨트롤 및 동작을 제공하는 비디오 재생 응용 프로그램을 훨씬 빠르고 쉽게 개발할 수 있습니다. 또한 현지화, 상태 복원, 전체 화면 재생, 고해상도 디스플레이 및 접근성과 같은 모든 표준 현대식 OS X 기능을 자동으로 지원합니다.

### First Steps
이 섹션에서는 AV Kit 기반 비디오 플레이어를 제작하여 AVPlayerView를 사용하는 법을 배웁니다. 5 장 디렉토리에는 KitTime Player_starter라는 샘플 프로젝트가 있습니다. 이 책의 샘플 애플리케이션 대부분은 AV Foundation 코드를 자체 클래스 세트로 분해하지만 Mac 관련 주제이기 때문에 기본 NSDocument 인스턴스의 컨텍스트에서이 앱을 개발할 것입니다. 프로젝트를 열고 시작하겠습니다.
먼저 구성해야 할 일은 KitTime Player 대상의 문서 형식 설정을 일부 변경하는 것입니다. 프로젝트 네비게이터에서 프로젝트의 루트 노드를 강조 표시하고 KitTime 플레이어 대상을 선택하십시오. 정보 탭을 선택하고 문서 유형 섹션을 펼치고 그림 5.3과 같이 다음과 같이 변경하십시오.

<p align="center">
<image src="Resource/03.png" width="50%" height="50%">
</p>

   * 응용 프로그램이 사용자 정의 문서 유형을 작성하지 않으므로 확장 필드에서 mydoc 확장을 제거하십시오.
   * 식별자 필드를 public.audiovisual-content로 설정합니다. 이 Uniform Type Identifier를 지정하면 응용 프로그램에서 모든 시청각 미디어를 열 수 있습니다.
   * 응용 프로그램을 시작할 때 새 문서 창이 생성되지 않도록 뷰어에 역할을 설정하십시오.

그런 다음 Project Navigator에서 THDocument.xib를 선택합니다. NSWindow는 재생할 비디오 콘텐츠의 종횡비를 수용 할 수 있도록 640x360으로 크기가 조정되었지만 마음대로 조정할 수 있습니다. 개체 라이브러리의 검색 상자에 AV Player View 구성 요소가 나타날 때까지 AVPlayerView를 입력합니다. 이 인스턴스를 창에 끌어다 놓고 그림 5.4와 같이 창 경계 내에서 가운데에 놓습니다.

<p align="center">
<image src="Resource/04.png" width="50%" height="50%">
</p>

창 크기를 변경할 때 AVPlayerView의 크기가 적절하게 설정되도록하려면 적절한 자동 레이아웃 제약 조건을 추가해야합니다. 이 경우 가장 쉬운 방법은 그림 5.5와 같이 자동 레이아웃 문제 해결 단추를 선택하고 창에 누락 된 제약 조건 추가를 선택하는 것입니다.

<p align="center">
<image src="Resource/05.png" width="50%" height="50%">
</p>

플레이어보기의 속성 검사기에서 Controls Style 속성을 Floating으로 설정합니다 (그림 5.6 참조).

<p align="center">
<image src="Resource/06.png" width="50%" height="50%">
</p>

이것은 QuickTime Player에서 본 것과 동일한 인터페이스를 제공합니다.
THDocument 인스턴스는 이미 plierer 뷰에 대한 IBOutlet을 정의하지만, 플레이어를 콘센트에 연결해야합니다. 그림 5.7에서와 같이 파일 소유자 프록시에서 AVPlayerView 인스턴스로 컨트롤 드래그하고 playerView 콘센트를 선택하십시오.

<p align="center">
<image src="Resource/07.png" width="50%" height="50%">
</p>

필요한 Interface Builder 구성이 완료되었으므로 THDocument.m 파일로 전환하십시오. 아래는 이 클래스의 초기 구현을 보여준다.

```swift
import Foundation
import AVKit
import Cocoa

@objc
class THDocument: NSDocument {
    @IBOutlet weak var playerView: AVPlayerView!
    
    override var windowNibName: String {
        return "THDocument"
    }
    
    override func windowControllerDidLoadNib(_ controller: NSWindowController) {
        super.windowControllerDidLoadNib(controller)
    }
    
    func readFromURL(url: URL, ofType typeName: String, error: Error) -> Bool {
        return true
    }
}
```

이것은 NSDocument의 기본 뼈대이지만 비디오 플레이어 응용 프로그램을 빌드하는데 필요한 모든 핵심 요소가 있습니다.
누락 된 유일한 것은 AV Foundation 코드입니다. windowControllerDidLoadNib : 메서드의 끝에 다음 코드 줄을 추가합니다.

```Swift
override func windowControllerDidLoadNib(_ controller: NSWindowController) {
        super.windowControllerDidLoadNib(controller)
        
        if let url = fileURL {
            playerView.player = AVPlayer(url: url)
        }
        playerView.showsSharingServiceButton = true
    }
```

이러한 코드 라인을 사용하여 응용 프로그램을 실행하십시오. 응용 프로그램이 시작되면 파일 메뉴에서 열기를 선택하고 5 장 디렉토리에서 hubblecast.m4v 파일을 선택하고 응용 프로그램의 재생 버튼을 누릅니다. 단 몇 분만에 몇 줄의 코드 만 있으면 그림 5.8과 같은 플레이어를 만들 수 있습니다!

<p align="center">
<image src="Resource/08.png" width="50%" height="50%">
</p>

AVPlayerView는 표준 재생 컨트롤, 비디오 스크러버, 볼륨 조절, dynamic chapter 및 자막 메뉴 및 Mac OS X에서 제공하는 표준 대상과 공유 할 수있는 공유 서비스 메뉴를 자동으로 제공합니다. 맥 플랫폼. 우리가 따라갈 때 할 수있는 일과 할 수있는 일이 훨씬 더 많습니다. 그러나 이것은 꽤 인상적인 출발입니다. AVPlayerView에서 제공하는 다양한 컨트롤 스타일에 잠시 주목하십시오.

## Control Styles
AVPlayerView는 사용자가 선택할 수 있는 다양한 컨트롤 스타일을 제공합니다. 이전에 했던것처럼 Interface Builder에서 시각적으로 이 속성을 변경하거나 controlsStyle 속성을 수정하여 프로그래밍 방식으로 이 속성을 변경할 수 있습니다. 제공하는 다양한 스타일을 살펴 보겠습니다.

### Inline
인라인 스타일(AVPlayerViewControlsStyleInline)은 AVPlayerView에서 사용되는 기본 스타일입니다 (그림 5.9 참조). 이 스타일은 QTKit 프레임 워크의 QTMovieView에서 제공하는 인터페이스와 매우 유사하게 보이며 표준 재생, 스크러빙 및 볼륨 컨트롤을 제공합니다. 또한 미디어에 데이터가있을 때 표시되는 동적 장 및 자막 메뉴를 지원합니다.

<p align="center">
<image src="Resource/09.png" width="50%" height="50%">
</p>

### Floating
플로팅 스타일(AVPlayerViewControlsStyleFloating)은 현재 버전의 QuickTime Player에서 제공하는 것과 동일한 모양을 제공합니다 (그림 5.10 참조). 사실, QuickTime Player의 Mavericks 버전은 AVPlayerView를 사용하므로 대부분의 Mac 사용자가 즉시 익숙하게 사용할 수있는 인터페이스를 제공합니다. 인라인 스타일과 마찬가지로 표준 재생, 스크러빙 및 볼륨 조절 기능을 제공하며 동영상에 챕터 및 자막이 있으면 자동으로 챕터 및 자막 메뉴도 표시됩니다.

<p align="center">
<image src="Resource/10.png" width="50%" height="50%">
</p>

### Minimal
최소 스타일(AVPlayerViewControlsStyleMinimal)은 재생 중 또는 일시 중지 버튼과 순환 진행 표시기 (그림 5.11 참조) 중 하나를 표시하는 화면 중앙에 떠 다니는 둥근 버튼을 제공합니다. 최소한의 제어가 필요한 짧은 비디오를 재생할 때 선택할 수있는 적절한 스타일 일 수 있습니다.

<p align="center">
<image src="Resource/11.png" width="50%" height="50%">
</p>

### None
None 스타일(AVPlayerViewControlsStyleNone)은 기본적으로 스타일이 없습니다. 이 스타일을 선택하면 컨트롤이 제공되지 않고 단순히 비디오 내용만 표시됩니다 (그림 5.12 참조). 자신의 재생 제어 기능을 제공하려는 경우 또는 비디오를 명시적으로 제어할 필요가 없는 경우 유용할 수 있습니다.

<p align="center">
<image src="Resource/12.png" width="50%" height="50%">
</p>

선택한 스타일에 관계없이 AVPlayerView는 항상 표준 키보드 단축키 세트에 응답합니다. 스페이스 바를 누르면 비디오가 재생되고 일시정지됩니다. 오른쪽 및 왼쪽 화살표 키를 사용하여 비디오를 통해 프레임 단위로 단계를 밟을 수 있습니다. 또한 플레이어보기는 J 키 입력이 되감기, L 키 빨리 감기 및 K 키 재생을 중지하는 J-K-L 탐색에 응답합니다.

```
노트
HTTP 라이브 스트리밍 비디오를 재생하는 경우 AVPlayerView는 컨트롤 스타일에 따라 스트리밍 재생에 적합한 대체 컨트롤을 자동으로 표시합니다.
```

```
노트
플로팅 및 인라인 스타일만 showSharingServiceButton 속성을 YES로 설정하여 활성화한 공유 서비스 메뉴를 표시 할 수 있습니다.
```

## Going Further
AV Kit을 사용하여 신속하게 작동하고 실행하는 방법을 살펴보았습니다. 하지만 이 기능을 사용하여 이 앱에서 좀 더 고급 기능을 사용할 수 있습니다. 이렇게하려면 미디어 스택의 설정부터 몇 가지 수정작업을 수행하십시오. AVPlayer는 기본 AVAsset 및 AVPlayerItem 인스턴스를 만들고 해당 객체를 준비하는 지름길인 playerWithURL : 메서드를 제공합니다. 이 방법을 사용하는 것이 편리 할 수 있지만 일반적으로 이러한 개체를 직접 사용해야하는 경우 명시적으로 만들고 작성하기가 쉽습니다. 이전 장에서 AV Foundation 재생 스택 설정과 동일한 기본 기술을 사용합니다 (목록 5.2 참조).

```Swift
// Listing 5.2 Setting up the Playback Stack

import Foundation
import AVKit
import Cocoa

@objc
class THDocument: NSDocument {
    @IBOutlet weak var playerView: AVPlayerView!
    
    let STATUS_KEY = "status"
    var asset: AVAsset?
    var playerItem: AVPlayerItem?
    var chapters: NSArray?
    
    override var windowNibName: String {
        return "THDocument"
    }
    
    override func windowControllerDidLoadNib(_ controller: NSWindowController) {
        super.windowControllerDidLoadNib(controller)
        
        if let url = fileURL {
            setupPlayerbackStack(with: url)
        }
    }
    
    func readFromURL(url: URL, ofType typeName: String, error: Error) -> Bool {
        return true
    }
    
    func setupPlayerbackStack(with url: URL) {
        asset = AVAsset(url: url)
        
        let keys = [
            "commonMetadata",
            "availableChapterLocales",
            ]
        
        if let asset = self.asset {
            playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: keys)
            
            if let playerItem = self.playerItem {
                playerItem.addObserver(self, forKeyPath: STATUS_KEY, options: .new, context: nil)
                playerView.player = AVPlayer(playerItem: playerItem)
                playerView.showsSharingServiceButton = true
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == STATUS_KEY {
            if playerItem?.status == .readyToPlay {
                if let title = titleForAsset(asset: asset) {
                    windowForSheet?.title = title
                    chapters = chaptersForAsset(asset: asset)
                    playerItem?.removeObserver(self, forKeyPath: STATUS_KEY)
                }
            }
        }
    }
    
    func titleForAsset(asset: AVAsset?) -> String? {
        guard let asset = asset else {
            return nil
        }
        
        return nil
    }
    
    func chaptersForAsset(asset: AVAsset?) -> NSArray? {
        guard let asset = asset else {
            return nil
        }
        
        return nil
    }
}
```

1. AVAsset, AVPlayerItem 및 NSArray에 대한 세 가지 새 속성을 추가하여 다가오는 섹션에서 캡처 할 챕터 데이터를 저장합니다.
2. 간단한 AVPlayer 생성 코드를 제거하고 대신 setupPlaybackStackWithURL :이라는 새 메서드에 설정 코드를 입력합니다. 이 코드는 windowControllerDidLoadNib : 메서드에서 호출합니다.
3. commonMetadata 및 availableChapterLocales 키를 저장할 NSArray를 만듭니다. 이것들은로드하려는 AVAsset 키이므로 Asset에 대한 추가 검사를 수행 할 수 있습니다.
4. 새로운 playerItemWithAsset : automaticallyLoadedAssetKeys : 편의 초기화 프로그램을 사용하여 AVPlayerItem을 만듭니다. 이것은 Mac OS X 10.9 및 iOS 7.0에서 AVAsset 키값 로드를 단순화시키는 훌륭한 추가 기능이었습니다.
5. 플레이어 항목의 상태 속성을 관찰자로 추가하여 플레이어 항목이 재생 준비가되었을 때 알림을받을 수 있습니다. 이것은 필요한 Asset 특성이 로드되고 재생 파이프 라인이 준비된 후에 발생합니다.
6. 플레이어 항목의 상태가 AVPlayerItemStatusReadyToPlay인 경우 로드하도록 요청한 AVAsset 속성을 안전하게 호출 할 수 있습니다.
7. titleForAsset을 호출합니다. 재생할 Asset의 제목을 검색 할 수 있습니다. 유효한 제목이 반환되면 윈도우의 title 속성으로 설정합니다. 그렇지 않은 경우 제목에는 저작물의 파일 이름이 표시됩니다. 약간의 방법으로 titleForAsset : 메소드에 대한 구현을 제공 하겠지만, 이제는 nil을 반환하는 스텁 구현을 제공한다.
8. chaptersForAsset : 현재 Asset에서 발견 된 장 표시 자에 대한 데이터를 저장하는 객체의 배열을 가져옵니다. 잠깐 챕터 데이터를 검색하는 방법에 대해 설명하겠지만 이제는 chaptersForAsset : 메소드의 스텁 구현을 제공 할 것입니다.

변경 사항은 기능을 변경하지는 않지만 향후 개선 될 기능에 대비되었습니다. 건전한 검사로서 응용 프로그램을 다시 실행하고 기능이 이전과 같이 계속 작동하는지 확인하십시오.
추가 할 더 큰 기능으로 이동하기 전에 titleForAsset : 메소드 (Listing 5.3 참조) 구현 방법을 살펴 보자. 이 방법은 지난 두 장에서 사용했던 AV Foundation의 표준 메타 데이터 기능을 사용합니다.

```Swift
// Listing 5.3

func titleInMetadata(metadata: [AVMetadataItem]) -> String? {
        let items = AVMetadataItem.metadataItems(from: metadata, withKey: AVMetadataCommonKeyTitle, keySpace: AVMetadataKeySpaceCommon)
        return items.first?.stringValue
    }
    
    func titleForAsset(asset: AVAsset?) -> String? {
        guard let asset = asset else {
            return nil
        }
        
        if let title = titleInMetadata(metadata: asset.commonMetadata) {
            if !title.isEmpty {
                return title
            }
        }
        
        return nil
    }
```

1. AVMetadataItem 인스턴스 콜렉션에서 제목을 추출하는 titleInMetadata라는 새 메소드를 추가하십시오. 먼저 `metadataItemsFromArray : withKey : keySpace : class` 메서드를 호출하여 공통 키 공간에서 제목 키를 검색합니다.
2. 이 배열에서 firstObject를 가져 와서 그 값을 NSString으로 가져옵니다. 공통 키 공간의 제목 값은 항상 문자열이므로 stringValue 속성을 사용하여 안전하게 NSString에 강제 변환 할 수 있습니다.
3. assetInMetadata : 메서드를 호출하여 자산의 commonMetadata를 인수로 전달합니다. 유효한 제목이 발견되면 반환합니다. 그렇지 않으면 nil을 리턴 할 것입니다.

응용 프로그램을 다시 실행할 수 있습니다. 5 장 디렉토리에있는 샘플 비디오에는 제목 메타 데이터가 포함되어 있으므로 창 제목 표시 줄에 포함 된 제목이 표시되어야합니다.

## Working with Chapters
플로팅 또는 인라인 컨트롤 스타일을 사용하는 경우 AVPlayerView는 비디오 파일에 Chapter 데이터가 있을 때마다 Chapter 메뉴를 자동으로 표시합니다. 이것은 매우 편리하지만 일부 추가 기능을 구현하기 위해이 데이터를 직접 사용해야하거나 동적 챕터 메뉴를 제공하지 않는 컨트롤 스타일을 사용하는 경우에는 어떻게해야합니까? 다행히 AV Foundation을 사용하면 AVTimedMetadataGroup 클래스를 통해이 데이터로 작업 할 수 있습니다.
Timed 메타 데이터는 제 3 장, "저작물 및 메타 데이터 작업"이후로 작업한 정적 메타 데이터와 본질적으로 동일하지만, 전체적으로 Asset에 적용하는 대신 이 메타 데이터는 Asset의 특정 시간 범위에만 적용됩니다 타임 라인. AVAsset은이 데이터를 검색 할 수있는 두 가지 방법을 제공합니다.

```Swift
asset?.chapterMetadataGroups(withTitleLocale: Locale, containingItemsWithCommonKeys: [String]?)
asset?.chapterMetadataGroups(bestMatchingPreferredLanguages: [String])
```

두 메소드 모두 Asset에서 발견 된 챕터 메타 데이터를 나타내는 AVTimedMetadataGroup 객체의 NSArray를 반환합니다. 메소드 시그니처에서 추측 할 수 있듯이 Chapter 데이터는 로케일에 따라 다릅니다. 두 메서드 중 하나를 호출하기 전에 먼저 다음 예제와 같이 Asset의 availableChapterLocales 키가 로드되었는지 확인해야합니다.

```Swift
        let key = "availableChapterLocales"
        asset?.loadValuesAsynchronously(forKeys: [key]) {
            let status = self.asset?.statusOfValue(forKey: key, error: nil)
            if status == .loaded {
                let langs = NSLocale.preferredLanguages
                let chapterMetadata = asset?.chapterMetadataGroups(bestMatchingPreferredLanguages: langs)
                //processAVTimeMetadataGroup objects
            }
        }
```

AVTimedMetadataGroup에는 timeRange와 items의 두 가지 속성이 있습니다. timeRange 속성은 시간 범위의 시작 시간을 나타내는 CMTime과 지속 시간을 정의하는 CMTime을 포함하는 CMTimeRange 구조체를 저장합니다. 이렇게하면 이 메타 데이터가 적용되는 Asset의 타임 라인에서 시간 범위를 결정할 수 있습니다. 챕터의 제목과 선택적으로 썸네일 이미지는 공통 키 공간의 AVMetadataItem 객체의 NSArray를 포함하는 items 속성에서 찾을 수 있습니다.
Listing 5.4에 chaptersForAsset : 메소드를 구현하여이를 실행 해 보자.

```Swift
//  5.4

    func chaptersForAsset(asset: AVAsset?) -> NSArray? {
        guard let asset = asset else {
            return nil
        }
        
        let languages = Locale.preferredLanguages
        let metadataGroups = asset.chapterMetadataGroups(bestMatchingPreferredLanguages: languages)
        var chapters: [THChapter] = []
        metadataGroups.enumerated().forEach {
            let time = $0.element.timeRange.start
            let number = $0.offset
            let title = titleInMetadata(metadata: $0.element.items)
            
            if let chapter = THChapter(time: time, number: UInt(number), title: title) {
                chapters.append(chapter)
            }
        }
        
        return chapters as NSArray
    }
```

1. 우선 NSLocale에 preferredLanguages 배열을 요청하십시오. 이렇게하면 사용자의 언어 기본 설정에 따라 정렬 된 언어 코드 배열이 반환됩니다. 필자의 경우, 이 목록의 첫 번째 요소는 영어입니다.
2. 사용자가 선호하는 언어와 가장 잘 일치하는 챕터 메타 데이터 그룹을 자산에 요청합니다.
3. AVTimedMetadataGroup 오브젝트 각각을 반복하고 각각에서 관련 데이터를 추출하십시오. 구체적으로, 앞에서 정의한 titleInMetadata : 메소드를 사용하여 timeRange와 제목에서 시작 시간을 가져옵니다. 또한 현재 루프 인덱스를 기반으로 각 장의 장 번호를 만듭니다. THChapter라는 사용자 정의 모델 객체에이 데이터를 저장하여이 데이터로 작업하는 것을 단순화합니다.

챕터 메타 데이터를 가져 와서 THChapter 객체 컬렉션에 멋지게 감쌌으므로이 데이터로 무엇을 할 수 있습니까? AVPlayerView에서 제공하는 다른 사용자 정의 지점을 활용하여이 데이터를 실행합니다. AVPlayerView는 사용자의 NSMenu를 플레이어의 컨트롤에 추가 할 수있게 해주는 `actionPopUpButtonMenu`를 제공합니다. 다음 및 이전 장으로 건너 뛸 수있는 기능을 제공하는 메뉴를 만듭니다. Listing 5.5와 같이 NSMenu를 빌드한다.

```Swift
// 5.5

    func setupActionMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Previous Chapter", action: #selector(previousChapter), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Next Chapter", action: #selector(nextChapter), keyEquivalent: ""))
        
        playerView.actionPopUpButtonMenu = menu
    }
    
    func previousChapter(sender: Any?) {
        
    }
    
    func nextChapter(sender: Any?) {
        
    }
```

1. 새 NSMenu 인스턴스를 만들고 previousChapter : 및 nextChapter : 셀럭터를 각각 호출하는 "이전 장"및 "다음 장"메뉴 항목을 추가하십시오. 당분간 이러한 메소드의 스텁 구현을 제공 할 것입니다.
2. 이 메뉴를 플레이어 뷰의 actionPopUpButtonMenu 속성으로 설정하십시오. 이 메뉴는 플로팅 또는 인라인 컨트롤 스타일을 사용할 때 표시됩니다.

이 메뉴를 추가하기 전에 먼저 setupActionMenu 메소드를 호출해야합니다. Listing 5.6과 같이 `observeValueForKeyPath : `메소드를 수정한다.

```Swift
//5.6

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == STATUS_KEY {
            if playerItem?.status == .readyToPlay {
                if let title = titleForAsset(asset: asset) {
                    windowForSheet?.title = title
                    chapters = chaptersForAsset(asset: asset)
                    if !(chapters?.isEmpty ?? true) {
                        setupActionMenu()
                    }
                    playerItem?.removeObserver(self, forKeyPath: STATUS_KEY)
                }
            }
        }
    }
```

챕터 데이터가 Asset에 있는 경우에만 이 메뉴를 표시하려고합니다. chapters 배열이 비어 있지 않으면 setupActionMenu 메서드를 호출합니다.
응용 프로그램을 다시 실행하고 메뉴가 표시되는지 확인할 수 있습니다. 메뉴 항목을 클릭 할 수는 있지만 아직 해당 메소드를 아직 구현하지 않았기 때문에 아무것도 발생하지 않습니다. 이러한 메소드에 대한 구현을 제공하기 전에 우선 다음과 이전 장을 찾으려면 몇 가지 추가 지원 코드를 추가해야합니다 (목록 5.7 참조). 다음 코드는 Core Media 유형 및 함수의 고급 사용법을 처음으로 접하는 것이므로 상당히 복잡하므로이 메서드를 좀 더 자세히 살펴 보겠습니다.

```Swift
// 5.7

    func findPreviousChapter() -> THChapter? {
        guard let item = playerItem else {
            return nil
        }
        
        let playerTime = item.currentTime()
        let currentTime = CMTimeSubtract(playerTime, CMTimeMake(3,1))
        let pastTime = kCMTimeNegativeInfinity
        let timeRange = CMTimeRangeMake(pastTime, currentTime)
        return findChapterInTimeRange(timeRange: timeRange, reverse: true)
    }
    
    func findNextChapter() -> THChapter? {
        guard let item = playerItem else {
            return nil
        }
        
        let currentTime = item.currentTime()
        let futureTime = kCMTimePositiveInfinity
        let timeRange = CMTimeRangeMake(currentTime, futureTime)
        return findChapterInTimeRange(timeRange: timeRange, reverse: false)
    }
    
    func findChapterInTimeRange(timeRange: CMTimeRange, reverse: Bool) -> THChapter? {
        var matchingChapter: THChapter?
        
        let options: NSEnumerationOptions = reverse ? .reverse : NSEnumerationOptions(rawValue: 0)
        chapters?.enumerateObjects(options: options) { obj, idx, stop in
            if let chapter = obj as? THChapter {
                if chapter.is(in: timeRange) {
                    matchingChapter = chapter
                    stop.pointee = true
                }
            }
        }
        
        return matchingChapter
    }
```

1. 이전 장을 찾으려면 두 개의 CMTime 값을 정의하십시오. 첫 번째는 플레이어 아이템의 현재 시간에서 3초를 포착하고, 두 번째는 kCMTimeNegativeInfinity 상수를 사용하여 정의 된 과거의 무한 시간입니다. 동영상을 재생할 때 시간이 계속해서 앞당겨지고 있으므로 메뉴 항목을 선택할 때 몇 초만 기다려야합니다. 그렇지 않으면 사용자는 현재 챕터의 시작 시간으로 돌아가는 일정한 루프에 갇혀있을 것입니다. currentTime을 계산할 때 CMTimeSubtract 함수를 사용하여 3 초를 빼고 결과 값을 currentTime으로 설정합니다.
2. CMTimeRangeMake 함수를 사용하여 CMTimeRange를 작성하십시오. 이 함수는 pastTime을 시간 범위의 시작으로 전달하고 currentTime은 지속 기간으로 전달합니다. 이 시간 범위는 THChapter 객체 컬렉션을 검색하는데 사용됩니다.
3. findChapterInTimeRange : reverse : 메서드를 호출하여 reverse : 인수에 대해 YES를 전달합니다. 이는 chapters 배열을 거꾸로 검색하려고 함을 나타냅니다.
4. findPreviousChapter 메서드와 비슷하게 플레이어 아이템의 현재 시간을 캡처하십시오. 특별한 계산을 수행 할 필요가 없습니다. 앞으로 나아갈 때 타이밍 문제가 없기 때문입니다. 시간 범위의 상한선을 표시하는 kCMTimePositiveInfinity 상수를 사용하여 미래에 무한히 시간을 만듭니다.
5. 현재 시간을 시작으로 미래 시간을 지속 시간으로 사용하여 CMTimeRange를 작성하십시오.
6. findChapterInTimeRange : reverse :를 호출합니다. 이 경우에는 챕터 배열을 통해 앞으로 검색하려고하기 때문에 이번에는 reverse : 인수로 NO를 전달합니다.
7. chapters 배열의 객체를 열거하여 reverse : 인수로 지정된 순서대로 컬렉션을 반복합니다.
8. Chapter의 isInTimeRange : 메서드를 호출하여 Chapter의 시작 시간이 지정된 시간 범위에 있는지 확인합니다. 이후 일치 항목을 발견하면 요소 처리를 중단 할 수 있습니다.
9. 마지막으로 일치하는 THChapter를 반환합니다. 또한 타임 라인의 시작 부분에서 뒤로 이동하거나 타임 라인의 끝에서 앞으로 이동하려고하는 경우와 같이 일치하는 항목이 없으면 이 메서드에서 nil을 반환하는 것이 좋습니다.

간단한 데이터 홀더 객체이기 때문에 THChapter 클래스의 전체 구현을 다루지는 않겠지만 Core Media 프레임 워크에서 찾은 유용한 매크로를 사용하기 때문에 isInTimeRange : 메서드를 호출하고 싶습니다.

```Objectivec
- (BOOL)isInTimeRange:(CMTimeRange)timeRange {
    return CMTIME_COMPARE_INLINE(_time, >, timeRange.start) &&
            CMTIME_COMPARE_INLINE(_time, <, timeRange.duration);
}
```

Core Media는 많은 유용한 기능과 매크로를 정의합니다. 공정하게 사용할 가능성이 큰 매크로는 CMTIME_COMPARE_INLINE입니다. 이 매크로는 비교 연산자와 함께 두 개의 CMTime 값을 취해 비교가 true인지 나타내는 부울을 반환합니다. isInTimeRange : 메서드에서 Chapter의 시작시간과 지속시간 사이에 시간이 있는지를 결정합니다.
어려운 부분은 끝났으므로 이 기능을 실제로 사용할 준비가되었습니다. Listing 5.8은 나머지 메소드의 구현을 보여준다.

```Swift
// 5.8

    func previousChapter(sender: Any?) {
        skipToChapter(findChapter: findPreviousChapter)
    }
    
    func nextChapter(sender: Any?) {
        skipToChapter(findChapter: findNextChapter)
    }
    
    func skipToChapter(findChapter: () -> THChapter?) {
        guard let chapter = findChapter() else {
            return
        }
        
        playerItem?.seek(to: chapter.time) { _ in
            self.playerView.flashChapterNumber(Int(chapter.number), chapterTitle: chapter.title)
        }
    }
```

1. 사용자가 이전 Chapter 메뉴를 선택하면 findPreviousChapter 메소드를 호출하고 그 결과를 skipToChapter : 메소드에 전달합니다.
2. 마찬가지로 사용자가 다음 장 메뉴를 선택하면 findNextChapter 메서드를 호출하고 반환 된 값을 skipToChapter : 메서드에 전달합니다.
3. 마지막으로 skipToChapter : 메서드에서 플레이어 아이템의 seekToTime : completionHandler : 메서드를 호출하여 챕터 시간을 첫 번째 인수로 전달합니다. completionHandler : 콜백에서 플레이어 뷰의 flash-ChapterNumber : chapterTitle : 메서드를 호출하여 플레이어 뷰에서 장 번호와 제목을 깜박입니다.
응용 프로그램을 다시 실행하고 비디오를 열고 건너 뜁니다.

## Enabling Trimming
AVPlayerView에서 제공하는 뛰어난 기본 재생 경험 외에도 슬리브의 또 다른 유용한 트릭이 있습니다. 현재 버전의 QuickTime Player를 사용했다면 그림 5.13과 같이 편집 메뉴로 가서 트리밍을 선택하여 트리밍 인터페이스를 열 수 있다는 것을 알고있을 수 있습니다.

<p align="center">
<image src="Resource/13.png" width="50%" height="50%">
</p>

AVPlayerView는 이와 동일한 동작 및 인터페이스를 제공하며, 가장 중요한 부분은 자신의 응용 프로그램에 추가하기가 매우 쉽다는 것입니다. 샘플 애플리케이션에는 이미 Trim 메뉴 항목과 스텁 된 startTrimming : 메소드가 있지만 이 메소드에 대한 구현을 제공해야한다 (목록 5.9 참조).

```Swift
// 5.9

    @IBAction func startTrimming(sender: Any) {
        playerView.beginTrimming(completionHandler: nil)
    }
```

내가 어떤 코드를 잊어 버렸는지 궁금해하고 있을지 모르지만, 직접 해보십시오. 응용 프로그램을 실행하고 샘플 비디오를 엽니다. 편집 메뉴로 가서 자르기 메뉴 항목을 선택하십시오. 이렇게하면 QuickTime Player에서 제공되는 것과 동일한 트리밍 인터페이스가 제공되며, 자르기 및 취소 버튼 모두 예상되는 동작을 제공합니다.
트리밍하기 전에 항상 플레이어 뷰의 `canBeginTrimming` 속성을 쿼리하여 시작해야합니다. 이 속성이 NO를 반환하는 몇 가지 경우가 있습니다. 첫 번째는 트리밍 인터페이스가 이미 제공되고있는 경우입니다.이 상태에서 트리밍을 시작하는 것이 적절하지 않기 때문입니다. 두 번째는 Asset에서 명시 적으로 트리밍을 허용하지 않는 경우입니다. 예를 들어, iTunes Store에서 구입 한 영화 또는 TV 프로그램을 트리밍 할 수 없습니다. 보통 이 프로퍼티를 쿼리하는 가장 적절한 곳은 `validateUserInterfaceItem :` 메소드에 있을 것이므로 메뉴 아이템을 적절하게 활성화 또는 비활성화 할 수 있습니다 (예제 5.10 참조).

```Swift
// 5.10

    override func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        let action = item.action
        if action == #selector(startTrimming(sender:)) {
            return playerView.canBeginTrimming
        }
        
        return true
    }
```

이제 응용 프로그램을 실행할 때 트리밍 인터페이스가 나타나면 트리밍 메뉴 항목이 비활성화됩니다.
트리밍이 어떻게 수행되고 있는지 궁금 할 것입니다. Asset을 다듬기위한 코드를 추가하지 않았으며, 기억한다면 AVAsset은 수정 불가능한 불변 객체입니다. Trim 버튼을 클릭했을 때 무슨 일이 일어 났습니까? 음, 일종의 환상. 자르기 단추를 클릭하면 플레이어뷰에서 현재 AVPlayerItem의 두 속성을 수정합니다. 트림 컨트롤의 왼쪽은 플레이어 항목의 reversePlaybackEndTime 속성을 설정하고 오른쪽은 forwardPlaybackEndTime을 설정합니다. 이 속성은 자산의 유효 타임 라인을 정의합니다. 비디오를 트리밍 한 다음 다시 트리밍 메뉴를 호출하면 모든 컨텐츠가 아직 남아 있고 트리밍 인터페이스가 트리밍 한 부분으로 조정된다는 것을 알 수 있습니다. AVPlayerView의 제한 사항은 아니지만 단순히 AV Foundation의 변경 불가능한 디자인 철학에 부합합니다. 이것이 바로 QuickTime Player에서 볼 수있는 동작입니다. 따라서 자산이 수정되지 않는 경우 어떻게 변경 사항을 저장합니까? 이것은 우리에게 Export의 화제를 가져온다.

## Exporting
트리밍 작업의 결과를 저장하려면 AVAssetExportSession 클래스를 사용하여 현재 에셋을 새 것으로 내보낼 수 있습니다. 이 클래스는 이미 보았으며 AV Foundation에서 작업 할 때 자주 사용하는 클래스입니다.
응용 프로그램에는 해당 startExporting : 메소드에 연결되는 파일 메뉴의 내보내기 메뉴 항목이 이미 있습니다. 필요한 것은이 메서드에 대한 구현을 제공하는 것입니다. Listing 5.11에서 볼 수 있듯이 문서 객체의 클래스 확장에 몇 가지 새로운 속성을 추가하는 것으로 시작한다.

```Swift
// 5.11

    @IBAction func startExporting(sender: Any) {
        playerView.player?.pause()
        let savePanel = NSSavePanel()
        
        if let window = windowForSheet {
            savePanel.beginSheetModal(for: window) {
                if $0 == NSFileHandlingPanelOKButton {
                    savePanel.orderOut(nil)
                    
                    let preset = AVAssetExportPresetAppleM4V720pHD
                    if let asset = self.asset {
                        self.exportSession = AVAssetExportSession(asset: asset, presetName: preset)
                        
                        if let startTime = self.playerItem?.reversePlaybackEndTime, let endTime = self.playerItem?.forwardPlaybackEndTime {
                            let timeRange = CMTimeRange(start: startTime, end: endTime)
                            
                            self.exportSession?.timeRange = timeRange
                            self.exportSession?.outputFileType = self.exportSession?.supportedFileTypes.first
                            self.exportSession?.outputURL = savePanel.url
                            
                            self.exportController = THExportWindowController()
                            self.exportController?.exportSession = self.exportSession
                            self.exportController?.delegate = self
                            if let exportControllerWindow = self.exportController?.window {
                                window.beginSheet(exportControllerWindow, completionHandler: nil)
                                self.exportSession?.exportAsynchronously {
                                    window.endSheet(exportControllerWindow)
                                    self.exportController = nil
                                    self.exportSession = nil
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    extension THDocument: THExportWindowControllerDelegate {
        func exportDidCancel() {
            exportSession?.cancelExport()
        }
    }
```
1. 내보내기가 실행되는 동안 사용자가 전송 컨트롤과 상호 작용할 수 없기 때문에 비디오가 현재 재생중인 경우 재생을 일시 중지하여 시작하십시오.
2. AVAssetExportSession의 새 인스턴스를 만들고 자산과 내보내기 사전 설정을 전달합니다. 이 경우 AVAsetExportPresetAppleM4V720pHD를 사용하고 있는데 720p MPEG-4 비디오 파일을 만들지 만 대체 프리셋을 자유롭게 선택할 수 있습니다. 예를 들어 트리밍 작업을 내보내는 경우 AVAssetExportPresetPassthrough를 사용하여 미디어를 트랜스 코딩하지 않아도됩니다.
3. 역방향 및 정방향 재생 종료 시간을 기준으로 시간 범위를 만듭니다. 명시적인 트림 작업이 수행되지 않은 경우 역방향 및 정방향 종료 시간은 kCMTimeInvalid와 같아 지므로 kCMTimeRangeInvalid와 같은 시간 범위가됩니다. 내보내기 세션에서 kCMTimeRangeInvalid의 시간 범위 값을 설정하면 비디오의 전체 재생 시간이 내보내집니다.
4. 내보내기 세션을 시간 범위, 내보내기 세션과 호환 가능한 출력 파일 유형 및 NSSavePanel에서 가져온 출력 URL로 구성합니다.
5. 샘플 애플리케이션은 THExportWindowController라는 클래스를 제공하는데, 이것은 내보내기 진행 창을 표시하기위한 간단한 NSWindowController 서브 클래스이다. 새 인스턴스를 만들고 자체를 위임자로 설정하고 창을 새 시트로 제공하십시오.
6. 내보내기를 시작하면 콜백이 호출되면 내보내기 시트와 컨트롤러 인스턴스가 분리됩니다.
7. 사용자가 내보내기 진행 창에서 취소 단추를 누르면 내보내기 세션이 취소됩니다.

이 모든 기능을 시험해 볼 때입니다. 응용 프로그램을 실행하고 샘플 비디오를 열고 흥미로운 섹션을 잘라내어 하드 드라이브의 위치로 복사본을 내 보냅니다. 당신이 사용할 수있는 수출 결과를 확인하려면 ... KitTime Player!

## Movie Modernization
이 장에서 마지막으로 다룰 내용은 AV Foundation의 일부는 아니지만 주제와 관련이 있으며 기존 QuickTime 기반 응용 프로그램이있는 경우 특히 중요 할 수 있습니다.
QuickTime은 매우 강력하고 유연한 미디어 플랫폼의 일부인 매우 다양한 코덱 및 미디어 유형을 지원했습니다. 그러나 지원되는 코덱의 대부분은 더 이상 적합하지 않으며 지원되는 트랙 유형 중 일부는 더 새롭고보다 유능한 기술로 대체되었습니다. AV Foundation은 이러한 레거시 기능을 지원하지 않으며, 대신 미래에 가장 적합한 코덱 및 트랙 유형이라고 생각하는 것에 초점을 둡니다.
현재의 미디어 환경을 감안할 때,이 코덱과 미디어 유형은 전적으로 합리적 일 수 있습니다. 그러나 오늘날의 Macintosh 멀티미디어 환경은 시작되지 않았습니다. 사용자는 지원되지 않는 코덱으로 수 년 동안 인코딩 된 미디어를 보유하고 있으며 이러한 콘텐츠를 단순히 포기할 것으로 기대하는 것은 무리가 있습니다. 당신은 무엇을 할 수 있나요?
드문 경우지만, 애플은 Mac OS X 10.9에서 더 이상 사용되지 않는 프레임 워크에 새로운 클래스를 추가했습니다. 특히 QTKit 프레임 워크에 QTMovieModernizer라는 새로운 클래스를 추가했습니다. 이 수업의 목적은 이전 미디어를 AV Foundation에서 지원하는 형식으로 마이그레이션하는 것입니다. 실제로 QuickTime Player의 Mavericks 버전을 사용하여 이전 QuickTime 파일을 열면이 동작을 볼 수 있습니다. 파일을 열면 미디어를 열기 전에 "변환 중 ..."이라는 메시지가 표시됩니다. QuickTime Player는이 클래스를 사용하여 미디어를 변환하며 응용 프로그램에서도이 클래스를 사용할 수 있습니다.
응용 프로그램을 실행하고 파일> 열기 ...를 선택하고 5 장 디렉토리로 이동합니다. 여기에는 다양한 레거시 코덱으로 인코딩 된 몇 개의 QuickTime 파일이 포함 된 Legacy라는 하위 디렉토리가 있습니다. 이 파일 중 하나를 열고 재생 버튼을 누릅니다. 스피커에서 나오는 오디오는 들리지만 AV Foundation에는 비디오 트랙을 디코딩 할 수있는 방법이 없으므로 비디오 내용이 표시되지 않습니다. 이 문제를 해결하기 위해 QTMovieModernizer 클래스를 사용하는 방법을 살펴 보겠습니다. Listing 5.13과 같이 기존 코드를 약간 수정하면된다.

```Swift
// 5.13

    override func windowControllerDidLoadNib(_ controller: NSWindowController) {
        super.windowControllerDidLoadNib(controller)
        
        if !modernizing {
            if let url = fileURL {
                setupPlayerbackStack(with: url)
            }
        } else {
            if let window = controller.window as? THWindow {
                window.showConvertingView()
            }
        }
    }
```
windowControllerDidLoadNib :를 수정하여 QTMovieModernizer가 현재 변환을 실행 중인지 여부를 나타내는 modernizing 속성의 상태에 따라 조건부로 설정을 수행합니다. 근대화가 false이면 정상적으로 설정을 실행하지만 사실이면 진행률 회 전자를 표시하는 window 객체에 showConvertingView를 호출합니다.
목록 5.13을 변경하여 실제 현대화 프로세스로 넘어 갑시다. Listing 5.14와 같이 readFromURL : ofType : error : 메소드를 다음과 같이 변경한다.

```Swift
// 5.13

Swift는 QTKit을 지원하지않아서 예제작성불가..
```

## Summary
이 장에서는 AVKit 프레임 워크를 사용하는 방법을 잘 이해하게되었습니다. iOS 용 AV Kit은 AVPlayerViewController를 제공하므로 AV Foundation을 사용하여 iOS 용 최신 비디오 재생 응용 프로그램을 쉽게 만들 수 있습니다. Mac OS X 용 AV Kit은 AVPlayerView를 제공합니다. AVPlayerView는 Mac에서 비디오 재생 응용 프로그램을 만드는 간단하지만 강력한 방법을 제공하며 QTMovieView의 지원 중단으로 남겨진 공백을 채 웁니다. AV Kit을 사용하면 두 플랫폼 모두에서 사용자가 기대했던 것과 동일한 기능, 인터페이스 및 인터페이스로 비디오 플레이어를 쉽게 만들 수 있습니다. 또한 AVTimeMetadataGroup 클래스를 사용하여 AVAsset에 저장된 시간별 챕터 메타 데이터를 처리하는 방법을 살펴 보았습니다. Mac 응용 프로그램의 맥락에서이 주제를 다뤘지만이 기능은 물론 iOS에서도 사용할 수 있습니다. 마지막으로 우리는 매우 유용한 QTMovieModernizer 클래스를 보았습니다. 이 클래스는 QTKit 프레임 워크의 일부이지만 Mac 플랫폼에서 AV Foundation 응용 프로그램의 기능을 향상시키는데 사용할 수 있습니다.