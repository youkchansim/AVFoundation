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