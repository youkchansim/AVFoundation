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
AVAssetReader는 단일 에셋에 포함 된 미디어 샘플만 대상으로 지정할 수 있습니다. 동시에 여러 파일 기반 에셋에서 샘플을 읽어야하는 경우 다음 장에서 설명 할 AVComposition이라는 AV클래스의 하위 클래스에서 함께 샘플을 구성 할 수 있습니다.
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