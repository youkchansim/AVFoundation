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

