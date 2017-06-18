# Capturing Media
2007년에 발표 된 iPhone의 도입은 휴대 전화 산업에 분열을 초래했으며 모바일 컴퓨팅에 대한 우리의 이해를 완전히 재정의했습니다. 소개에서 즉시 명백하지 않은 점은 디지털 카메라 산업을 얼마나 크게 혼란스럽게 하는지에 있습니다. iPhone은 시장에서 가장 인기있는 디지털 카메라 중 하나가되었습니다. 많은 사람들이 전통적인 point-and-shoot 카메라와 캠코더를 완전히 대체했습니다. 기존의 카메라 장치에서 벗어나 디지털 사진 및 비디오 사용 방식도 변경되었습니다. 더 이상 사진은 사진 앨범으로, 비디오는 거실로 옮겨졌습니다. 오늘날 우리는 우리의 미디어를 단지 몇 번의 도청으로 세계와 포착, 편집 및 공유 할 수 있습니다. 이 장에서는 AV Foundation의 캡처 기능을 탐구하여 다음 멋진 사진 또는 비디오 응용 프로그램을 제작하는 방법을 보여줍니다.

1. http://www.flickr.com/cameras

## Capture Overview
AV Foundation의 사진 및 비디오 캡처 기능은 처음 시작된 이래로 프레임 워크에 대한 강력한 선택이었습니다. iOS 4에서 소개 된 덕분에 개발자는 iOS 장치의 카메라 및 생성 된 데이터에 직접 액세스 할 수 있었으며 새로운 종류의 사진 및 비디오 응용 프로그램을 만들 수있었습니다. 이 프레임 워크의 캡처 기능은 계속해서 Apple의 미디어 엔지니어에게 중요한 초점을 맞춰 주며 새로운 릴리스에는 중요한 새로운 기능과 향상된 기능이 추가되었습니다. 코어 캡처 클래스는 iOS와 OS X에서 일관되지만, 이는 몇 가지 차이점을 발견 할 수있는 프레임 워크의 한 영역입니다. 이러한 차이점은 일반적으로 특정 플랫폼에 맞게 조정 된 기능 때문입니다. 예를 들어, Mac OS X은 스크린 레코딩에 사용되는 AVCaptureScreenInput 클래스를 제공하지만 iOS는 샌드 박스 제한으로 인한 것이 아닙니다. AV Foundation의 캡처 기능에 대한 내용은 iOS에 초점을 맞출 것이지만 대부분의 논의는 OS X에도 적용됩니다.
캡처 응용 프로그램을 개발할 때 상당히 많은 클래스가 있습니다. 프레임 워크의 기능을 시작하기위한 첫 번째 단계는 관련된 클래스와 각각의 역할과 책임을 이해하는 것입니다. 그림 6.1은 캡처 응용 프로그램을 개발할 때 사용되는 클래스의 개요를 제공합니다.

<p align="center">
<image src="Resource/01.png" width="50%" height="50%">
</p>

### Capture Session
AV Foundation의 캡처 스택의 중심 클래스는 AVCaptureSession입니다. 캡처 세션은 입력 및 출력이 연결된 가상 "patch bay"의 역할을 합니다. 카메라 및 마이크와 같은 물리적 장치에서 하나 이상의 출력 대상으로의 데이터 흐름을 제어합니다. 입력 및 출력의 라우팅은 즉석에서 구성 할 수 있으므로 세션 기간 동안 필요에 따라 캡처 환경을 재구성 할 수 있습니다.
캡처 세션은 캡처 된 데이터의 형식과 품질을 제어하는 세션 사전 설정을 사용하여 추가로 구성 할 수 있습니다. 세션은 많은 유스 케이스에서 잘 작동하는 AVCaptureSessionPresetHigh의 사전 설정 값을 기본값으로 사용하지만 응용 프로그램의 특정 요구에 맞게 출력을 조정할 수있는 다양한 사전 설정이 있습니다.

### Capture Devices
AVCaptureDevice는 카메라 또는 마이크와 같은 물리적 장치에 인터페이스를 제공합니다. 가장 일반적으로 이러한 장치는 Mac, iPhone 또는 iPad에 통합되어 있지만 외부 디지털 카메라 또는 캠코더 일 수도 있습니다. AVCaptureDevice는 카메라의 초점, 노출, 화이트 밸런스 및 플래시를 제어하는 기능과 같은 물리적 하드웨어에 대한 상당한 제어 기능을 제공합니다.
AVCaptureDevice는 시스템 캡처 장치에 액세스하는 데 사용되는 다양한 클래스 메서드를 제공합니다. 자주 사용되는 한 가지 방법은 defaultDeviceWithMediaType :이며, 지정된 미디어 유형에 대해 시스템이 지정한 기본 장치를 반환합니다. 예를 살펴 보겠습니다.

```ObjectiveC
AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
```

이 예에서는 기본 비디오 장치를 요구합니다. 전면 카메라와 후면 카메라가 모두있는 iOS 장치에서이 호출은 시스템에서 기본 카메라로 지정 되었기 때문에 후면 카메라를 반환합니다. 카메라가 장착 된 Mac에서는 내장 된 FaceTime 카메라를 반환합니다.

### Capture Device Inputs
캡처 장치로 특히 흥미로운 작업을 수행하려면 우선 캡처 세션에 입력으로 추가해야합니다. 그러나 캡처 장치를 AVCaptureSession에 직접 추가 할 수는 없지만 AVCaptureDeviceInput의 인스턴스에 래핑해야합니다. 이 객체는 장치의 출력을 캡처 세션에 연결하는 가상 패치 케이블의 역할을합니다. AVCaptureDeviceInput은 다음 예제와 같이 deviceInputWithDevice : error : 메서드를 사용하여 만듭니다.

```ObjectiveC
NSError *error;

AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
```

이 메서드는 유효한 NSError 포인터를 전달해야합니다. 입력 포인터가 생성되는 동안 발생한 오류에 대한 설명으로 채워지기 때문입니다.

### Capture Outputs
AV Foundation은 AVCaptureOutput을 확장하는 여러 클래스를 제공합니다. 이것은 캡처 세션의 데이터에 대한 출력 대상을 나타내는 추상 기본 클래스입니다. 프레임 워크는 정지 이미지 및 비디오를 쉽게 캡처 할 수 있도록 AVCaptureStillImageOutput 및 AVCaptureMovieFileOutput과 같은이 클래스의 일부 상위 레벨 확장을 제공합니다. 하드웨어에서 캡처 한 디지털 샘플에 직접 액세스 할 수있는 AVCaptureAudioDataOutput 및 AVCaptureVideoDataOutput과 같은 하위 레벨 확장도 있습니다. 이러한 저수준 출력을 사용하려면 캡처 장치가 제공하는 데이터를 더 잘 이해해야하지만 오디오 및 비디오 스트림의 실시간 처리와 같은 강력한 기능을 제공합니다.

### Capture Connections
일러스트레이션에서 특별히 이름이 지정되지 않았지만 다양한 구성 요소를 연결하는 검은 색 화살표로 표시된 하나의 클래스는 AVCaptureConnection입니다. 캡처 세션은 지정된 캡처 장치 입력에 의해 판매 된 미디어 유형을 결정하고 해당 유형의 미디어를 수락하는 출력을 캡처하도록 연결을 자동으로 형성합니다. 예를 들어 AVCaptureMovieFileOutput은 오디오와 비디오 데이터를 모두 받아들이므로 세션은 비디오를 생성하고 오디오를 생성하며 연결을 적절하게 연결하는 입력을 결정합니다. 이러한 연결에 액세스하면 특정 연결을 비활성화하는 기능이나 오디오 연결의 경우 개별 오디오 채널에 대한 액세스 기능과 같이 신호 흐름에 대한 낮은 수준의 제어 기능을 제공합니다.

### Capture Preview
카메라 응용 프로그램은 카메라가 무엇을 캡처하고 있는지 알 수없는 경우 특히 유용하지 않습니다. 다행히 프레임 워크는 이러한 요구를 충족시키기 위해 AVCaptureVideoPreviewLayer 클래스를 제공합니다. 미리보기 레이어는 캡처 된 비디오 데이터의 실시간 미리보기를 제공하는 Core Animation CALayer 하위 클래스입니다. 이 클래스는 AVPlayerLayer와 비슷한 역할을하지만 카메라 캡처의 필요에 맞게 조정됩니다. AVPlayerLayer와 마찬가지로 AVCaptureVideoPreviewLayer는 그림 6.2, 6.3 및 6.4 에서처럼 레이어의 경계 내에서 렌더링되는 내용이 확장되거나 확장되는 방식을 제어하는 비디오 중력 개념을 지원합니다.

<p align="center">
<image src="Resource/02.png" width="50%" height="50%">
</p>

그림 6.2 AVLayerVideoGravityResizeAspect는 비디오의 원래 종횡비를 유지하기 위해 포함 레이어 범위 내에서 비디오의 크기를 조정합니다. 이것은 다르게 설정되지 않은 경우 기본값이며 대부분의 경우에 적합합니다.

<p align="center">
<image src="Resource/03.png" width="50%" height="50%">
</p>

그림 6.3 AVLayerVideoGravityResizeAspectFill은 레이어의 경계를 채우기 위해 크기를 조절하면서 비디오의 종횡비를 유지하므로 종종 비디오 이미지가 잘 리게됩니다.

<p align="center">
<image src="Resource/04.png" width="50%" height="50%">
</p>

그림 6.4 AVLayerVideoGravityResize는 포함하는 레이어의 경계와 일치하도록 비디오 내용을 확장합니다. 이것은 일반적으로 비디오 이미지를 왜곡하여 "funhouse 효과"를 초래하기 때문에 가장 유용하지 않습니다.

### Simple Recipe
캡처 클래스의 고급 수준을 넘어서는 간단한 카메라 앱 캡처 세션을 설정하는 방법에 대한 예를 살펴 보겠습니다.

```ObjectiveC
// 1. Create a capture session.
AVCaptureSession *session = [[AVCaptureSession alloc] init];

// 2. Get a reference to the default camera.
AVCaptureDevice *cameraDevice =
    [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

// 3. Create a device input for the camera.
NSError *error;
AVCaptureDeviceInput *cameraInput =
    [AVCaptureDeviceInput deviceInputWithDevice:cameraDevice error:&error];

// 4. Connect the input to the session.
if ([session canAddInput:cameraInput]) {
    [session addInput:cameraInput];
}

// 5. Create an AVCaptureOutput to capture still images.
AVCaptureStillImageOutput *imageOutput =
    [[AVCaptureStillImageOutput alloc] init];

// 6. Add the output to the session.
if ([session canAddOutput:imageOutput]) {
    [session addOutput:imageOutput];
}

// 7. Start the session and begin the flow of data.
[session startRunning];
```
이 예제는 기본 카메라에서 스틸 이미지를 캡처하는 데 필요한 기본 인프라를 설정합니다. 캡처 세션을 만들고 캡처 장치 입력을 통해 세션에 기본 카메라를 추가하고 스틸 이미지를 출력 할 수있는 세션에 캡처 출력을 추가 한 다음 세션 실행을 시작하여 비디오 데이터가 시스템을 통해 흐르기 시작합니다 . 일반적인 세션 설정은이 예제보다 더 복잡 할 수 있지만 핵심 구성 요소가 어떻게 잘 맞는지 잘 보여줍니다.
이제 핵심 캡처 클래스에 대해 전반적으로 이해했으므로 이러한 클래스를 구현하여 AV Foundation의 캡처 기능에 대해 자세히 살펴 보도록하겠습니다.