# Using Advanced Capture Features
이전 장에서는 AV Foundation의 캡처 클래스를 처음 보았고 이를 활용하는 방법을 잘 이해했습니다. 이러한 핵심 기능을 숙달하는 것이 모든 사진 또는 비디오 캡처 응용 프로그램을 빌드하는 기초가되므로 필수적입니다. 그러나, AV Foundation은 여전히 슬리브를 꽤 많이 가지고 있습니다. 가장 최근의 iOS 버전에서는 몇 가지 놀라운 새로운 기능을 소개했으며, 이 장에서는 프레임 워크의 고급 캡처 기능에 대해 기본을 뛰어 넘을 것입니다.

## Video Zooming
iOS 7 이전에는 Apple에서 AVCaptureConnection의 videoScaleAndCropFactor 속성을 통해 카메라 줌을 제한적으로 지원했습니다. 이를 통해 연결 확장을 기본값 1.0에서 videoMaxScaleAndCropFactor 속성에 의해 결정된 최대 값까지 조정할 수 있습니다. 이 기능은 특정 경우에 유용 할 수 있지만 몇 가지 중요한 제한 사항이 있습니다. 첫 번째는 videoScaleAndCropFactor가 연결 수준 설정이므로 이 상태를 사용자 인터페이스에 올바르게 반영하려면 AVCaptureVideoPreviewLayer에 적절한 크기 조정 변환을 적용해야합니다. 이것은 더 많은 스케일링 인자가 적용될 때 수행되어야 할 추가 작업이며 미리보기 레이어에서 이미지 품질을 감소시킵니다. 두 번째로 큰 제한은 AVCaptureStillImageOutput에 대한 연결에서만 이 속성을 설정할 수 있기 때문에 비디오 캡처 응용 프로그램에서 이 기능을 사용할 수 없습니다. 다행히도 iOS 7에서 줌을 수행하는 더 좋은 방법이 소개되었습니다. 이 기능을 사용하면 AVCaptureDevice에 직접 줌 요소를 적용 할 수 있습니다. 즉, 미리보기 레이어를 포함한 모든 세션의 출력에 이 설정의 상태가 자동으로 반영됩니다. 이 새로운 기능을 사용하는 방법을 살펴 보겠습니다.

<p align="center">
<image src="Resource/01.png" width="300">
</p>

샘플 코드에 들어가서 이 기능을 어떻게 사용할 수 있는지 살펴 보겠습니다. 7 장 디렉토리 인 ZoomKamera_Starter에서 시작 프로젝트를 찾을 수 있습니다 (그림 7.1 참조).

```
노트
이 장의 샘플 프로젝트는 THBaseCameraController라는 기본 클래스를 사용합니다. 이 클래스는 기본적으로 6 장 "미디어 캡처"에서 만든 카메라 컨트롤러이지만 일부 확장 점이 추가되었습니다. 특히, 세션 입력, 출력 및 세션 사전 설정을 구성하기 위해 재정의 할 수있는 메소드를 제공합니다. 이것은 우리가 이전 장에서 다루었던 주제로 얽매이지 않고 도입 된 새로운 기능에 집중할 수있게 해줍니다.
```

스타터 프로젝트에서는 THCameraController라는 클래스의 스텁 된 구현을 찾을 수 있습니다. 이 클래스는 THBaseCameraController를 확장하고 비디오 확대 / 축소를 수행하는 기능을 추가합니다. Listing 7.1에서는이 클래스의 인터페이스를 제공한다.

```objectivec
// 7.1
#import <AVFoundation/AVFoundation.h>
#import "THBaseCameraController.h"

@protocol THCameraZoomingDelegate <NSObject>                                // 1
- (void)rampedZoomToValue:(CGFloat)value;
@end

@interface THCameraController : THBaseCameraController

@property (weak, nonatomic) id<THCameraZoomingDelegate> zoomingDelegate;

- (BOOL)cameraSupportsZoom;                                                 // 2

- (void)setZoomValue:(CGFloat)zoomValue;
- (void)rampZoomToValue:(CGFloat)zoomValue;
- (void)cancelZoom;

@end
```
1. THCameraZoomingDelegate는 줌 슬라이더 컨트롤을 현재 줌 상태와 동기화 된 상태로 유지하기 위해 사용자 인터페이스에서 사용할 rampedZoomToValue : 메서드를 제공합니다.
2. 모든 하드웨어가 이 기능을 지원하지는 않기 때문에 클라이언트가 zoom 컨트롤을 표시할지 결정하기 위해 쿼리 할 수있는 cameraSupportsZoom 메소드를 추가합니다.

클래스 구현으로 넘어 가서 Listing 7.2와 같이 확대 / 축소 동작을 작성 해보자.
```objectivec
#import "THCameraController.h"
#import <AVFoundation/AVFoundation.h>

const CGFloat THZoomRate = 1.0f;

// KVO Contexts
static const NSString *THRampingVideoZoomContext;
static const NSString *THRampingVideoZoomFactorContext;

@implementation THCameraController

- (BOOL)cameraSupportsZoom {
    return self.activeCamera.activeFormat.videoMaxZoomFactor > 1.0f;        // 1
}

- (CGFloat)maxZoomFactor {
    return MIN(self.activeCamera.activeFormat.videoMaxZoomFactor, 4.0f);    // 2
}

- (void)setZoomValue:(CGFloat)zoomValue {                                   // 3
    if (!self.activeCamera.isRampingVideoZoom) {

        NSError *error;
        if ([self.activeCamera lockForConfiguration:&error]) {              // 4

            // Provide linear feel to zoom slider
            CGFloat zoomFactor = pow([self maxZoomFactor], zoomValue);      // 5
            self.activeCamera.videoZoomFactor = zoomFactor;

            [self.activeCamera unlockForConfiguration];                     // 6

        } else {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
}

...

@end
```
1. cameraSupportsZoom 메소드 구현을 시작하십시오. 활성 AVCaptureDeviceFormat에 대해 현재 선택된 AVCaptureDevice인 activeCamera에 문의하십시오. 캡처 장치는 포맷의 videoMaxZoomFactor 값이 1.0보다 큰 경우 확대 / 축소를 지원합니다.
2. 최대 허용 줌 계수를 결정하려면 활성 형식의 videoMaxZoomFactor 및 4.0f의 MIN 값을 찾습니다. 4.0f의 값은 임의이지만 합리적인 확대 / 축소 범위를 제공합니다. 일반적으로 videoMaxZoomFactor에 확대 / 축소를 허용하고 싶지는 않습니다. 일반적으로 사용할 수있는 것보다 훨씬 크기 때문에 최대 값을 계산할 때는 항상 고려해야합니다. 허용되는 최대 값을 초과하여 확대 / 축소 비율을 설정하려고 시도하면 예외가 발생합니다.
3. setZoomValue : 메서드는 사용자가 그림 7.1의 확대 / 축소 슬라이더를 움직일 때 호출됩니다. 슬라이더의 범위는 0.0f ~ 1.0f입니다.
4. 캡처 장치가 현재 비디오 줌을 램핑하지 않는 경우 구성을 위해 장치를 잠그십시오. 이 구성은 다른 모든 구성 요소와 마찬가지로 구성을 변경하기 전에 잠금을 얻지 못하면 예외를 발생시킵니다.
5. 응용 프로그램은 1x ~ 4x의 줌 범위를 제공합니다. 이 증가는 기하 급수적이므로 범위 전체에서 선형 느낌을 제공하려면 최대 줌 팩터를 zoomValue (0 ~ 1)의 제곱으로 높이면 zoomFactor 값이 계산됩니다. 계산이 끝나면 캡처 장치의 videoZoomFactor 속성 값을 설정합니다.
6. 마지막으로 구성이 완료되면 장치의 잠금을 해제합니다.

응용 프로그램을 실행하고 슬라이더를 이동하십시오. 확대 / 축소 레벨은 미리보기 레이어뿐만 아니라 캡처 한 모든 비디오 또는 사진에 지속적으로 반영됩니다. maxZoomFactor 메서드에서 반환 된 상한을 자유롭게 조정하여 더 높은 줌 레벨을 설정하는 효과를 확인하십시오.
videoZoomFactor 속성은 줌 레벨을 즉시 조정합니다. 이것은 슬라이더와 같은 지속적인 유형의 제어에 적합합니다. 그러나 시간이 지남에 따라 하나의 값에서 다른 값으로 램핑하여 줌 레벨을 조정할 수도 있습니다. jog shuttle type의 컨트롤을 작성하려는 경우 유용 할 수 있습니다. 앱은 슬라이더의 끝에 마이너스 (-) 및 더하기 (+) 버튼을 제공합니다. 시간이 지남에 따라 줌 레벨을 조정할 수 있도록이 버튼에 몇 가지 동작을 추가해 보겠습니다 (목록 7.3 참조).

```objectivec
- (void)rampZoomToValue:(CGFloat)zoomValue {                                // 1
    CGFloat zoomFactor = pow([self maxZoomFactor], zoomValue);
    NSError *error;
    if ([self.activeCamera lockForConfiguration:&error]) {
        [self.activeCamera rampToVideoZoomFactor:zoomFactor                 // 2
                                        withRate:THZoomRate];
        [self.activeCamera unlockForConfiguration];
    } else {
        [self.delegate deviceConfigurationFailedWithError:error];
    }
}

- (void)cancelZoom {                                                        // 3
    NSError *error;
    if ([self.activeCamera lockForConfiguration:&error]) {
        [self.activeCamera cancelVideoZoomRamp];
        [self.activeCamera unlockForConfiguration];
    } else {
        [self.delegate deviceConfigurationFailedWithError:error];
    }

}
```
1. 사용자 인터페이스에서 더하기 또는 빼기 버튼을 눌러 rampZoomToValue : 메소드를 호출합니다. 사용자가 마이너스 (-) 버튼을 누르면이 메소드에 전달 된 값은 0.0f가되고 사용자가 플러스 (+) 버튼을 누르면 1.0f가됩니다. 이전과 마찬가지로 zoomValue 인수를 기반으로 적절한 zoomFactor를 계산합니다.
2. rampToVideoZoomFactor : withRate : 메서드를 호출하여 계산 된 zoomFactor와 상수 THZoomRate (1.0f와 같음)를 전달합니다. 매 초 줌 배율을 두 ​​배로 늘리는 효과가 있습니다. 적절한 비율 값은 사용자가 결정할 수 있지만 일반적으로 확대 / 축소 컨트롤에 편안한 느낌을주기 위해 1.0f ~ 3.0f의 범위입니다.
3. 사용자가 버튼 위로 터치 업하면 cancelZoom 메서드가 호출됩니다. 그러면 현재 확대 / 축소 램프가 취소되고 zoomFactor가 현재 상태로 설정됩니다. 모든 장치 구성 변경 사항과 마찬가지로 구성을 위해 장치를 잠그고 원하는대로 변경 한 다음 완료되면 잠금을 해제해야합니다.

응용 프로그램을 다시 실행하고 이 새로운 동작을 시도하십시오. 플러스와 마이너스 버튼이 예상대로 동작하고 비디오 줌을 부드럽게 램프하는 것을 볼 수 있습니다. 그러나 슬라이더가 현재 줌 레벨을 반영하지 않는다는 점에서 사용자 인터페이스에 문제가 있음을 알 수 있습니다. Listing 7.4에서이 문제를 해결해 보자.

```objectivec
- (BOOL)setupSessionInputs:(NSError **)error {
    BOOL success = [super setupSessionInputs:error];                        // 1
    if (success) {
        [self.activeCamera addObserver:self
                            forKeyPath:@"videoZoomFactor"
                               options:0
                               context:&THRampingVideoZoomFactorContext];
        [self.activeCamera addObserver:self
                            forKeyPath:@"rampingVideoZoom"
                               options:0
                               context:&THRampingVideoZoomContext];

    }
    return success;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    if (context == &THRampingVideoZoomContext) {
        [self updateZoomingDelegate];                                       // 2
    } else if (context == &THRampingVideoZoomFactorContext) {
        if (self.activeCamera.isRampingVideoZoom) {
            [self updateZoomingDelegate];                                   // 3
        }
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

- (void)updateZoomingDelegate {
    CGFloat curZoomFactor = self.activeCamera.videoZoomFactor;
    CGFloat maxZoomFactor = [self maxZoomFactor];
    CGFloat value = log(curZoomFactor) / log(maxZoomFactor);                // 4
    [self.zoomingDelegate rampedZoomToValue:value];                         // 5

}
```
1. setupSessionInputs의 수퍼 클래스 구현을 덮어 씁니다. 캡처 세션이 설정 될 때 activeCamera에 액세스 할 수 있습니다. 자아를 캡처 장치의 videoZoomFactor 및 rampingVideoZoom 키 경로의 옵저버로 추가합니다.
2. 컨텍스트가 & THRampingVideoZoomContext 인 경우 updateZoomingDelegate 메서드를 호출합니다. 이 관찰은 램프가 시작될 때 발생하고 램프가 끝나면 다시 발생합니다.
3. 컨텍스트가 & THRampingVideoZoomFactorContext이고 활성 비디오 램프가 진행중인 경우 다시 updateZoomingDelegate 메서드를 호출합니다.
4. 현재 줌 레벨을 슬라이더의 0에서 1 스케일로 다시 변환하려면 현재 videoZoomFactor의 로그를 maxZoomFactor의 로그로 나눈 값을 취하십시오.
5. 마지막으로이 값을 zoomingDelegate로 전달하여 사용자 인터페이스를 적절히 업데이트 할 수 있도록하십시오.

이제 응용 프로그램을 다시 실행하면 jog shuttle 컨트롤과 상호 작용할 때 슬라이더 값이 해당 위치를 제대로 업데이트하는 것을 볼 수 있습니다.
AV Foundation의 새로운 확대 / 축소 기능은 플랫폼에 추가 된 것으로 캡처 연결의 videoScaleAndCropFactor 사용에 대한 중요한 이점을 제공합니다. AVCaptureDevice에 직접 videoZoomFactor를 설정하면 이제는 하나의 줌으로 모든 것을 제어 할 수 있습니다.

## Face Detection
내장 iOS 카메라 앱을 사용했다면, 새로운 얼굴이 카메라의 시야에 들어올 때 새로운 얼굴에 자동으로 초점을 맞추는 방법을 발견했을 것입니다. 새로 감지 된 얼굴 주위에 노란색 상자가 그려지고 사각형의 중심점에서 자동 초점 작업이 수행됩니다. 이는 수동 사용자 상호 작용없이 초점을 맞춘 샷을 신속하게 캡처하는 것이 훨씬 쉬워 지므로 유용한 기능입니다. 다행히도 AV Foundation의 실시간 얼굴 탐지 기능을 활용하여 자신의 응용 프로그램에서 이와 동일한 기능을 구현할 수 있습니다.
iOS 개발자에게 얼굴 인식 기능을 제공하는 데있어 Apple의 첫 번째 진출은 Core Image 프레임 워크를 통해 이루어졌습니다. Core Image는 사용하기 쉽고 다소 강력한 얼굴 탐지 기능을 제공하는 CIDetector 및 CIFaceFeature 객체를 제공합니다. 그러나 이러한 기능은 실시간 사용에 최적화되어 있지 않아 최신 카메라 및 비디오 응용 프로그램에 필요한 프레임 속도를 얻지 못합니다. iOS 6에서 Apple은 AV Foundation에 직접 새로운 하드웨어 가속 기능을 도입하여 최대 10 개의 얼굴을 실시간으로 감지 할 수있었습니다. 이 기능은 AVCaptureMetadataOutput이라는 특수한 AVCaptureOutput 유형을 통해 가능합니다. 이 출력은 지금까지 본 다른 출력과 비슷하지만 스틸 이미지 또는 QuickTime 동영상을 출력하는 대신 메타 데이터를 출력합니다. 이 메타 데이터는 다양한 메타 데이터 유형을 처리하는데 적합한 인터페이스를 정의하는 AVMetadataObject라는 추상 클래스 형태로 제공됩니다. 얼굴 인식 작업을 할 때 AVMetadataFaceObject라는 구체적인 하위 클래스 유형을 출력합니다.
AVMetadataFaceObject의 인스턴스는 감지 된 얼굴을 설명하는 몇 가지 속성을 제공합니다. 가장 중요한 것은 얼굴의 경계입니다. 이것은 장치의 스칼라 좌표에서 주어진 CGRect입니다. 6 장에서 장치의 스칼라 좌표는 카메라 왼쪽면의 0,0에서 카메라의 기본 방향의 오른쪽 하단 구석의 1,1까지의 범위를 나타냅니다.
범위 외에도 AVMetadataFaceObject 인스턴스는 감지 된 얼굴의 롤 및 요우 각도를 정의하는 속성을 제공합니다. 롤각은 사람의 머리가 어깨쪽으로 기울어 진 상태를 나타내며, 요각은 얼굴이 y 축을 중심으로 회전하는 것을 나타냅니다.
이 기능을 어떻게 사용할 수 있는지 알아보기 위해 애플리케이션을 빌드 해 봅시다. 7 장 디렉토리의 FaceKamera_Starter에서 샘플 프로젝트를 찾을 수 있습니다. 먼저 Listing 7.5와 같이 애플리케이션의 카메라 컨트롤러 클래스를 빌드한다.

```objectivec
//  7.5
#import <AVFoundation/AVFoundation.h>
#import "THBaseCameraController.h"

@protocol THFaceDetectionDelegate <NSObject>
- (void)didDetectFaces:(NSArray *)faces;
@end

@interface THCameraController : THBaseCameraController

@property (weak, nonatomic) id <THFaceDetectionDelegate> faceDetectionDelegate;

@end
```
이 클래스의 다른 클래스와 마찬가지로이 클래스는 핵심 카메라 동작을 정의하는 THBaseCameraController에서 확장됩니다. 이 인터페이스에서 THFaceDetectionDelegate라는 새로운 프로토콜을 정의하고 THCameraController 클래스에서 이 인터페이스의 속성을 정의합니다. 이 델리게이트는 카메라가 새로운 메타 데이터를 캡처 할 때 알림을 받습니다. 클래스 구현으로 전환하고 Listing 7.6 에서처럼 이 클래스의 동작을 빌드를 해봅니다.

```objectivec
#import "THCameraController.h"
#import <AVFoundation/AVFoundation.h>

@interface THCameraController ()
@property (strong, nonatomic) AVCaptureMetadataOutput *metadataOutput;      // 1
@end

@implementation THCameraController

- (BOOL)setupSessionOutputs:(NSError **)error {

    self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];           // 2
    if ([self.captureSession canAddOutput:self.metadataOutput]) {
        [self.captureSession addOutput:self.metadataOutput];

        NSArray *metadataObjectTypes = @[AVMetadataObjectTypeFace];         // 3
        self.metadataOutput.metadataObjectTypes = metadataObjectTypes;

        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        [self.metadataOutput setMetadataObjectsDelegate:self                // 4
                                                  queue:mainQueue];

        return YES;

    } else {                                                                // 5
        if (error) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:
                                           @"Failed to still image output."};
            *error = [NSError errorWithDomain:THCameraErrorDomain
                                         code:THCameraErrorFailedToAddOutput
                                     userInfo:userInfo];
        }
        return NO;
    }
}

@end
```
1. 이 클래스에서 사용하는 AVCaptureMetadataOutput 인스턴스를 저장하기 위해 클래스 확장 내에 속성을 만드는 것으로 시작하십시오.
2. 이 메소드의 수퍼 클래스 구현이 이 경우에 필요하지 않으므로 setupSessionOutputs : 메소드를 완전히 대체하십시오. 대신 AVCaptureMetadataOutput의 새 인스턴스를 만들고 이를 캡처 세션의 출력으로 추가하십시오.
3. AVCaptureMetadataOutput 객체를 구성 할 때 metadataObjectTypes 속성을 설정하여 이 객체가 출력해야하는 메타 데이터 유형을 지정하는 것이 중요합니다. 탐지 된 메타 데이터 유형 세트를 제한하면 성능 최적화가되고 관심있는 대상으로 객체가 축소됩니다. AV Foundation은 많은 메타 데이터 유형을 지원하지만, 현재 얼굴 메타 데이터에만 관심이 있기 때문에 AVMetadataObjectTypeFace라는 상수 값이있는 단일 요소가 포함 된 NSArray를 제공합니다.
4. AVCaptureMetadataOutput은 새로운 메타 데이터가 검출 될 때 호출 될 델리게이트 객체를 필요로합니다. self를 대리자로 표시하고 콜백이 발생할 직렬 전달 대기열을 제공합니다. 이것은 커스텀 시리얼 디스패치 큐일 수 있습니다; 그러나 얼굴 인식이 하드웨어 가속으로 수행 될 흥미로운 작업이 기본 대기열에 있기 때문에이 인수의 기본 대기열을 지정합니다.
5. 마지막으로, 당신은 적절한 NSError와 오류 포인터를 채우고 NO 돌아갑니다.

프로젝트를 빌드하면 AVCaptureMetadataOutputObjectsDelegate 프로토콜을 채택하지 않으므로 self가 유효한 대리자가 아님을 나타내는 컴파일러 경고가 표시됩니다. 컨트롤러가 새로운 메타 데이터가 탐지되었을 때 통지를 받기 전에 이 프로토콜을 채택하고 captureOutput : didOutputMetadataObjects : fromConnection : 메소드를 구현해야합니다. Listing 7.7처럼 THCameraController 클래스에 다음을 추가하여이 문제를 해결하자.

```objectivec
//  7.7
#import "THCameraController.h"
#import <AVFoundation/AVFoundation.h>

@interface THCameraController () <AVCaptureMetadataOutputObjectsDelegate>      // 1
...
@end

@implementation THCameraController

- (BOOL)setupSessionOutputs:(NSError **)error {
    ...
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {

    for (AVMetadataFaceObject *face in metadataObjects) {                   // 2
        NSLog(@"Face detected with ID: %li", (long)face.faceID);
        NSLog(@"Face bounds: %@", NSStringFromCGRect(face.bounds));
    }

    [self.faceDetectionDelegate didDetectFaces:metadataObjects];            // 3

}

@end
```
1. 클래스 확장이 AVCaptureMetadataOutputObjectsDelegate 프로토콜을 채택하도록하십시오.
2. 프로토콜의 방법을 구현할 때 일부 임시 디버깅 코드를 추가하여 감지가 예상대로 발생하는지 확인합니다. 검출 된 각각의 얼굴을 반복하고 각 출력에 대해 faceID와 경계를 반복합니다. 이 디버깅 코드는 구성이 완료되었는지 확인한 후에 제거 할 수 있습니다.
3. 마지막으로 위임 객체의 didDetectFaces : 메서드를 호출하여 AVCaptureMetadataOutput 인스턴스로 출력되는 AVMetadataObject 인스턴스의 배열을 전달합니다.
응용 프로그램을 실행하십시오. 얼굴이 카메라의 시야에 들어 오면 콘솔에 디버그 메시지가 전송되는 것을 볼 수 있습니다. 경계는 장치 좌표로 주어집니다. 잠시 후에, 이것이 어떻게 더 유용한 좌표 공간으로 변환 될 수 있는지 보게 될 것입니다.

## Building the Face Detection Delegate
이 책의 코드 예제는 대부분 사용자 인터페이스 레이어에서 벗어날 수있는 방법으로 분해되었습니다. 그러나 얼굴 인식 작업은 이 메타 데이터를 사용하는 방법에 대해 더 잘 이해하기 위해 UIKit 및 Core Animation 코드로 이동해야하는 경우입니다. 이 응용 프로그램에서 THFaceDetectionDelegate 프로토콜을 채택한 객체는 THPlayerView 클래스입니다. Listing 7.8에서 인터페이스를 살펴 보자.
```objectivec
//  7.8
#import <AVFoundation/AVFoundation.h>
#import "THFaceDetectionDelegate.h"

@interface THPreviewView : UIView <THFaceDetectionDelegate>

@property (strong, nonatomic) AVCaptureSession *session;

@end
```
이 클래스에는 간단한 인터페이스가 있습니다. 가장 주목할 점은 THFaceDetectionDelegate 프로토콜을 채택한다는 것입니다. 이 클래스는 메타 데이터의 대상이 될 것이고 시각적 표현을 제공하는 데 사용될 것입니다.
구현으로 전환하고 이 클래스를 작성해 보겠습니다. 뷰 구현에는 상당한 양의 코드가 있기 때문에 Listing 7.9에서 볼 수있는 것처럼 기본적인 클래스 구조로 시작하여 이를 조각으로 만들 것입니다.

```objectivec
//  7.9
#import "THPreviewView.h"

@interface THPreviewView ()                                                 // 1
@property (strong, nonatomic) CALayer *overlayLayer;
@property (strong, nonatomic) NSMutableDictionary *faceLayers;
@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation THPreviewView

+ (Class)layerClass {                                                       // 2
    return [AVCaptureVideoPreviewLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    //
}

- (AVCaptureSession*)session {
    return self.previewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session {                            // 3
    self.previewLayer.session = session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

- (void)didDetectFaces:(NSArray *)faces {
    //
}

@end
```
1. 클래스 확장을 작성하고 클래스가 사용하는 내부 특성을 정의하십시오.
2. 이전 장에서 수행 한 것처럼 layerClass 메서드를 재정의하고 AVCaptureVideoPreviewLayer의 인스턴스를 반환합니다. 이 기술은 새로운 인스턴스가 생성 될 때 AVCaptureVideoPreviewLayer를 이 클래스의 백업 레이어로 자동 설정합니다.
3. AVCaptureSession과 AVCapturePreviewLayer를 연결하려면 setSession : 메서드를 재정의하고 AVCaptureSession 인스턴스를 미리보기 레이어의 세션 속성으로 설정합니다.
기본 클래스 구조를 설정하고, 계속해서 Listing 7.10의 setupView 메소드 구현을 제공한다.

```objectivec
//  7.10
@implementation THPreviewView

...

- (void)setupView {
    self.faceLayers = [NSMutableDictionary dictionary];                     // 1
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    self.overlayLayer = [CALayer layer];                                    // 2
    self.overlayLayer.frame = self.bounds;
    self.overlayLayer.sublayerTransform = THMakePerspectiveTransform(1000);
    [self.previewLayer addSublayer:self.overlayLayer];
}

static CATransform3D THMakePerspectiveTransform(CGFloat eyePosition) {      // 3
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0 / eyePosition;
    return transform;
}

...

@end
```
1. 감지 된면에 해당하는 레이어 인스턴스를 저장하는 데 사용되는 NSMutableDictionary를 사용하여 faceLayers 속성을 초기화합니다. 또한 videoGravity를 AVLayerVideoGravityResizeAspectFill로 설정하여 미리보기 레이어의 경계를 채 웁니다. 사용 가능한 비디오 중력 값에 대한 설명은 6 장을 참조하십시오.
2. 새로운 CALayer 인스턴스로 overlayLayer 속성을 초기화하고 미리보기 레이어를 완전히 채우도록 경계를 뷰의 경계와 동일하게 설정합니다. 레이어의 sublayerTransform 속성을 모든 하위 레이어에 원근감 변환을 적용하도록 구성된 CATransform3D로 설정합니다.
3. CATransform3D 유형을 반환하는 함수를 만듭니다. 이것은 Core Animation에서 스케일링 및 회전과 같은 변형을 적용하는 데 사용되는 변형 행렬 유형입니다. m34 요소를 설정하면 하위 레이어를 Y 축을 중심으로 회전 할 수있는 원근감 변환을 적용 할 수 있습니다.
이전에 Core Animation을 사용하지 않았다면 이 중 일부는 혼란 스러울 수도 있지만 걱정하지 마십시오. 곧 이 구성의 효과가 나타납니다. 코어 애니메이션 프레임 워크를 효과적으로 사용하는 방법에 대한 훌륭한 개요를 보려면 Nick Lockwood의 iOS Core Animation (2014, Boston : Addison-Wesley)을 권하고 싶습니다.
AVCaptureMetadataOutput 개체에 의해 캡처 된 메타 데이터는 장치 공간에 있습니다. 이 메타 데이터를 사용하려면 먼저 제공 한 데이터를 뷰의 좌표 공간으로 변환해야합니다. 다행히 AVCaptureVideoPreviewLayer가이 변환에 필요한 열심히 수행하는 데 필요한 메소드를 제공하기 때문에 이렇게하는 것이 쉽지 않습니다. Listing 7.11은 이것이 어떻게 수행되는지 보여준다.

```objectivec
//  7.11
@implementation THPreviewView

...

- (void)didDetectFaces:(NSArray *)faces {

    NSArray *transformedFaces = [self transformedFacesFromFaces:faces];     // 1

    // Process transformed faces. To be implemented in Listing 7.12.
}

- (NSArray *)transformedFacesFromFaces:(NSArray *)faces {                   // 2
    NSMutableArray *transformedFaces = [NSMutableArray array];
    for (AVMetadataObject *face in faces) {
        AVMetadataObject *transformedFace =                                 // 3
            [self.previewLayer transformedMetadataObjectForMetadataObject:face];
        [transformedFaces addObject:transformedFace];
    }
    return transformedFaces;
}

...

@end
```
1. 변환 된면을 저장할 로컬 NSArray를 만듭니다.
2. 장치 좌표 공간면 오브젝트를 뷰 좌표 공간 오브젝트의 콜렉션으로 변환하는 새로운 메소드를 작성하십시오.
3. 메소드에 전달 된면들의 콜렉션을 반복하고 각각에 대해 미리보기 레이어의 transformedMetadataObjectForMetadataObject : 메소드를 호출하여 변형 된 faces 배열에 추가합니다.
이제는 사용자 인터페이스를 구성하는 데 의미있는 좌표를 갖는 AVMetadataFaceObject 인스턴스 모음이 있습니다. Listing 7.12의 미리보기의 구현을 계속하자.

```objectivec
@implementation THPreviewView

...

- (void)didDetectFaces:(NSArray *)faces {

    NSArray *transformedFaces = [self transformedFacesFromFaces:faces];

    NSMutableArray *lostFaces = [self.faceLayers.allKeys mutableCopy];      // 1

    for (AVMetadataFaceObject *face in transformedFaces) {

        NSNumber *faceID = @(face.faceID);                                  // 2
        [lostFaces removeObject:faceID];

        CALayer *layer = self.faceLayers[faceID];                           // 3
        if (!layer) {
            // no layer for faceID, create new face layer
            layer = [self makeFaceLayer];                                   // 4
            [self.overlayLayer addSublayer:layer];
            self.faceLayers[faceID] = layer;
        }

        layer.transform = CATransform3DIdentity;                            // 6
        layer.frame = face.bounds;

    }

    for (NSNumber *faceID in lostFaces) {                                   // 7
        CALayer *layer = self.faceLayers[faceID];
        [layer removeFromSuperlayer];
        [self.faceLayers removeObjectForKey:faceID];
    }

}

- (CALayer *)makeFaceLayer {                                                // 5
    CALayer *layer = [CALayer layer];
    layer.borderWidth = 5.0f;
    layer.borderColor =
        [UIColor colorWithRed:0.188 green:0.517 blue:0.877 alpha:1.000].CGColor;
    return layer;
}

...

@end
```
1. faceLayers 사전에 포함 된 키 값의 변경 가능한 사본을 작성하십시오. 이 배열은 어떤 얼굴이 보이지 않고 사용자 인터페이스에서 레이어가 제거되었는지 확인하는 데 사용됩니다.
2. 변환 된 각 얼굴 객체를 반복하고 검출 된 얼굴을 고유하게 식별하는 관련 faceID를 캡처합니다. 이 메소드의 끝에서 레이어가 사용자 인터페이스에서 제거되지 않도록 lostFaces 배열에서 항목을 제거하십시오.
3. 현재 faceID에 대한 faceLayers 사전에서 CALayer 인스턴스를 찾으십시오. 이 사전은 CALayer 객체의 임시 캐시로 사용됩니다.
4. 주어진 faceID에 대해 레이어가 발견되지 않으면 makeFaceLayer 메서드를 호출하여 새 얼굴 레이어를 만들고 overlayLayer에 추가합니다. 마지막으로 didDetectFaces : 메소드의 이전 호출에서 다시 사용할 수 있도록 사전에 추가하십시오.
5. makeFaceLayer 메서드는 5- 포인트 옅은 파란색 테두리로 새 CALayer를 만들고 레이어를 호출자에게 반환합니다.
6. 레이어의 변형 속성을 CATransform3DIdentity로 설정합니다. 아이덴티티 변환은 레이어의 기본 변환입니다.이 변환은 기본적으로 변환되지 않은 상태를 의미합니다. 곧 적용 할 변환을 재설정하는 효과가 있습니다. 또한 face 객체의 bounds 속성을 기반으로 레이어의 프레임을 설정합니다.
7. 마지막으로, lostFaces 배열에 포함 된 나머지 얼굴 ID의 컬렉션을 반복하여 슈퍼 레이어와 faceLayers 사전에서 제거합니다.
이제 응용 프로그램을 실행하고이 기능을 실제로 사용할 준비가되었습니다. 앱은 기본적으로 전면 카메라가 활성화되어 설정되므로 카메라를 들여다 보면 얼굴 주위에 파란색 상자가 표시되어 실시간으로 운동을 추적 할 수 있습니다. 현재로서는 AVMetadataFaceObject에서 제공하는 다른 흥미로운 데이터를 사용하지 않고 있습니다. 우리는 얼굴 오브젝트가 검출 된 얼굴의 롤과 요를 설명하는 데이터도 포함하고있는 방법을 논의했습니다. 이것이 어떻게 사용자 인터페이스에서 묘사 될 수 있는지 보자 (Listing 7.13 참조).

```objectivec
//  7.13
@implementation THPreviewView

...

- (void)didDetectFaces:(NSArray *)faces {

    NSArray *transformedFaces = [self transformedFacesFromFaces:faces];

    NSMutableArray *lostFaces = [self.faceLayers.allKeys mutableCopy];

    for (AVMetadataFaceObject *face in transformedFaces) {

        NSNumber *faceID = @(face.faceID);
        [lostFaces removeObject:faceID];

        CALayer *layer = self.faceLayers[faceID];
        if (!layer) {
            // no layer for faceID, create new face layer
            layer = [self makeFaceLayer];
            [self.overlayLayer addSublayer:layer];
            self.faceLayers[faceID] = layer;
        }

        layer.transform = CATransform3DIdentity;                            // 1
        layer.frame = face.bounds;

        if (face.hasRollAngle) {
            CATransform3D t = [self transformForRollAngle:face.rollAngle];  // 2
            layer.transform = CATransform3DConcat(layer.transform, t);
        }

        if (face.hasYawAngle) {
            CATransform3D t = [self transformForYawAngle:face.yawAngle];    // 4
            layer.transform = CATransform3DConcat(layer.transform, t);
        }
    }

    for (NSNumber *faceID in lostFaces) {                                   // 6
        CALayer *layer = self.faceLayers[faceID];
        [layer removeFromSuperlayer];
        [self.faceLayers removeObjectForKey:faceID];
    }

}

// Rotate around Z-axis
- (CATransform3D)transformForRollAngle:(CGFloat)rollAngleInDegrees {        // 3
    CGFloat rollAngleInRadians = THDegreesToRadians(rollAngleInDegrees);
    return CATransform3DMakeRotation(rollAngleInRadians, 0.0f, 0.0f, 1.0f);
}

// Rotate around Y-axis
- (CATransform3D)transformForYawAngle:(CGFloat)yawAngleInDegrees {          // 5
    CGFloat yawAngleInRadians = THDegreesToRadians(yawAngleInDegrees);

    CATransform3D yawTransform =
        CATransform3DMakeRotation(yawAngleInRadians, 0.0f, -1.0f, 0.0f);

    return CATransform3DConcat(yawTransform, [self orientationTransform]);
}

- (CATransform3D)orientationTransform {                                     // 6
    CGFloat angle = 0.0;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case UIDeviceOrientationLandscapeRight:
            angle = -M_PI / 2.0f;
            break;
        case UIDeviceOrientationLandscapeLeft:
            angle = M_PI / 2.0f;
            break;
        default: // as UIDeviceOrientationPortrait
            angle = 0.0;
            break;
    }
    return CATransform3DMakeRotation(angle, 0.0f, 0.0f, 1.0f);
}

static CGFloat THDegreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
}

...

@end
```
1. 각 얼굴 레이어에 대해 transform 속성을 CATransform3DIdentity로 설정합니다. 이것은 이전에 적용된 변환을 재설정하는 효과가 있습니다.
2. hasRollAngle 속성을 테스트하여면 오브젝트가 유효한 롤 각도를 갖는지 확인합니다. hasRollAngle이 NO를 반환하면 rollAngle 속성을 요청하면 예외가 발생합니다. face 객체에 rollAngle이있는 경우 적절한 CATransform3D를 요청하고 식별 변환과 연결하고 레이어의 transform 속성을 설정합니다.
3. face 객체에서 얻은 rollAngle은도 단위이지만 Core Animation 변형 함수에서 요구하는대로 라디안으로 변환해야합니다. 이 변환 된 각도를 X, Y, Z 구성 요소의 값 0, 0, 1과 함께 CATransform3DMakeRotation 함수에 전달하십시오. 그러면 Z 축을 중심으로 롤 각 회전 변형이 발생합니다.
4. rollAngle을 계산할 때와 마찬가지로 먼저 얼굴에 요각이 있는지 물어볼 필요가 있습니다. 그렇다면 해당 값을 요청하고 적절한 변환을 계산하여 레이어의 기존 변환과 연결하고 레이어의 변형 속성으로 설정합니다.
5. 요각에 대한 변형을 만드는 것은 롤 각을 만들 때 수행 한 것과 유사합니다. 먼저 각도를 라디안으로 변환하고 회전 변환을 만들지만 이번에는 Y 축을 중심으로 회전합니다. overlayLayer에 필요한 sublayerTransform이 적용되어 있으므로 레이어가 Z 축을 따라 투영되므로면 이 좌우로 바뀌면 3D 효과가 발생합니다.
6. 응용 프로그램의 사용자 인터페이스는 세로 방향으로 고정되어 있지만 장치의 방향에 적합한 회전 변환을 계산해야합니다. 이렇게하지 않으면 얼굴 레이어의 yaw 효과가 잘못 그려집니다. 이 변환은 다른 변환과 연결됩니다.
응용 프로그램을 다시 실행하십시오. 이제 머리를 좌우로 기울이면 상자가 회전하고 움직임을 추적합니다. 마찬가지로, 어깨를 향해 머리를 회전 시키면, 박스가 yaw를 추적하고 3D 공간에 투영되는 것을 볼 수 있습니다.
이제는 AV Foundation 얼굴 탐지 사용에 대한 확실한 이해가 있어야합니다. 우리는 이 기능을 사용하여 구축 할 수있는 사용자 인터페이스의 표면을 긁어 모으고 있습니다. 나는 모자, 안경, 콧수염을 씌우려는 생각이 머리에 터지기를 바랍니다. Core Animation 레이어를 비디오 이미지와 합성하는 정지 이미지를 캡처하는 것은 전적으로 가능합니다. 하지만, 이 책의 범위를 벗어나는 중요한 Quartz 프레임웍이 필요하다. 이 컴포지팅을 수행하는 방법에 대한 예제는 Apple Developer Connection 사이트의 Apple SquareCam 샘플 또는 WWDC 2013의 StacheCam 예제를 참조하십시오.

## Machine-Readable Code Detection
AV Foundation이 제공하는 중요한 새로운 기능은 바코드 스캐닝을 지원하는보다 공식적인 방식인 기계 판독 가능 코드를 탐지하는 기능입니다. 이 프레임 워크는 광범위한 바코드 심볼로지를 실시간으로 감지하고 전면 및 후면 카메라 모두에서 작동하며 iOS 7 및 iOS 8을 실행할 수있는 모든 장치에서 지원됩니다. 이 기능의 기술적 세부 사항을 설명하기 전에 프레임 워크가 지원하는 다양한 바코드 심볼로지를 간략하게 살펴보십시오.

### 1D Codes
1D Codes는 가장 보편적인 유형의 바코드입니다. 이들은 선적, 제조 및 소매에 널리 사용되며 대부분의 재고 관리 시스템에서 중요한 역할을합니다. AV Foundation은 표 7.1에 표시된 1D 기호를 지원합니다.

<p align="center">
<image src="Resource/02.png" width="50%" height="50%">
</p>

AV Foundation은 3 가지 2D 기호를 추가로 지원합니다. QR 코드는 주로 모바일 마케팅에 사용되지만 모바일 공간에서 이러한 코드를 창의적으로 많이 사용하게됩니다. 아즈텍 코드는 항공 업계에서 탑승권으로 널리 사용됩니다. PDF417은 일반적으로 운송 응용 프로그램에 사용됩니다. 표 7.2는 이러한 코드의 예를 제공합니다.

<p align="center">
<image src="Resource/03.png" width="50%" height="50%">
</p>

바코드에 대한 자세한 내용은이 설명서의 범위를 벗어나지 만, http://makebarcode.com/에서 이러한 기호에 대한 기능 및 용도에 대한 좋은 요약을 찾을 수 있습니다.
Barvode 스캐너 제작
이 기능을 사용하는 샘플 앱을 만들어 보겠습니다. CodeKamera_Starter라는 7 장 디렉토리에서 샘플 프로젝트를 찾을 수 있습니다. 우리는 Listing 7.14에있는 카메라 컨트롤러 객체를 빌드부터 시작한다.

```objectivec
//  7.14
#import <AVFoundation/AVFoundation.h>
#import "THBaseCameraController.h"

@protocol THCodeDetectionDelegate <NSObject>
- (void)didDetectCodes:(NSArray *)codes;
@end

@interface THCameraController : THBaseCameraController

@property (weak, nonatomic) id <THCodeDetectionDelegate> codeDetectionDelegate;

@end
```
THCameraController의 인터페이스는 FaceKamera 앱용으로 만든 인터페이스와 거의 동일합니다. 유일한 차이점은 THCodeDetectionDelegate라는 새로운 위임 프로토콜의 정의입니다. 이 대리자는 새 바코드가 감지 될 때 호출 될 단일 didDetectCodes : 메서드를 정의합니다. 구현으로 전환하고 그 동작을 빌드하기 시작하자 (Listing 7.15 참조).

```objectivec
#import "THCameraController.h"
#import <AVFoundation/AVFoundation.h>
@interface THCameraController () <AVCaptureMetadataOutputObjectsDelegate>   // 1
@property (strong, nonatomic) AVCaptureMetadataOutput *metadataOutput;
@end

@implementation THCameraController

- (NSString *)sessionPreset {                                               // 2
    return AVCaptureSessionPreset640x480;
}

- (BOOL)setupSessionInputs:(NSError *__autoreleasing *)error {
    BOOL success = [super setupSessionInputs:error];
    if (success) {
        if (self.activeCamera.autoFocusRangeRestrictionSupported) {         // 3

            if ([self.activeCamera lockForConfiguration:error]) {

                self.activeCamera.autoFocusRangeRestriction =
                            AVCaptureAutoFocusRangeRestrictionNear;

                [self.activeCamera unlockForConfiguration];
            }
        }
    }
    return success;
}

...

@end
```
1. AVCaptureMetadataOutput에 대한 참조를 저장하는 클래스 확장을 작성하는 것으로 시작하십시오. FaceKamera 앱에서했던 것처럼 이 클래스는 AVCaptureMetadataOutputObjectsDelegate 프로토콜을 채택하여 새 메타 데이터가 발견 될 때 알림을받을 수 있습니다.
2. sessionPreset 메소드를 대체하여 사용할 대체 세션 사전 설정 유형을 리턴하십시오. 앱에 가장 적합한 캡처 사전 설정을 자유롭게 사용할 수 있지만 Apple은 성능을 향상시키기 위해 가장 낮은 해상도를 사용하는 것이 좋습니다.
3. 캡처 장치의 자동 초점 기능은 일반적으로 거리에 관계없이 개체를 검색합니다. 일반적으로 일반적인 사진 또는 비디오 카메라 응용 프로그램에서 원하는 동작입니다. 그러나 iOS 7에 속성이 추가되어 범위 제한을 적용하여이 동작을 조정할 수있었습니다. 스캔 할 대부분의 바코드는 몇 피트 이내에있게 되므로 스캔 영역을 줄여 탐지의 응답성을 향상시킬 수 있습니다. 이 기능이 지원되는지 테스트하고 autoFocusRangeRestriction 속성을 AVCaptureAutoFocusRangeRestrictionNear로 설정합니다.

캡처 장치 입력 구성이 완료되면 Listing 7.16의 캡처 세션 출력 설정을 살펴 보자.

```objectivec
//  7.16
@implementation THCameraController

...

- (BOOL)setupSessionOutputs:(NSError **)error {
    self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];

    if ([self.captureSession canAddOutput:self.metadataOutput]) {
        [self.captureSession addOutput:self.metadataOutput];

        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        [self.metadataOutput setMetadataObjectsDelegate:self
                                                  queue:mainQueue];

        NSArray *types = @[AVMetadataObjectTypeQRCode,                      // 1
                           AVMetadataObjectTypeAztecCode];

        self.metadataOutput.metadataObjectTypes = types;

    } else {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:
                                       @"Failed to add metadata output."};
        *error = [NSError errorWithDomain:THCameraErrorDomain
                                     code:THCameraErrorFailedToAddOutput
                                 userInfo:userInfo];
        return NO;
    }

    return YES;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {

    [self.codeDetectionDelegate didDetectCodes:metadataObjects];            // 2

}

@end
```
1. setupSessionOutputs : 메소드의 구현은 FaceKamera app에서 사용되는 것과 거의 동일하게 구현됩니다. 유일한 차이점은 AVCaptureMetadataOutput 객체에서 사용하는 metadataObjectTypes입니다. 이 경우 QR 및 아즈텍 코드를 스캔하는데 관심이 있다고 지정합니다.
2. 델리게이트 콜백에서 THCodeDetectionDelegate를 호출하여 감지된 메타 데이터 객체의 배열을 전달합니다.
바코드로 작업 할 때 나오는 AVMetadataCaptureOutput 객체는 AVMetadataMachineReadableCodeObject의 인스턴스가됩니다. 이 객체는 바코드의 실제 데이터 값과 바코드 지오메트리를 정의하는 두 가지 속성을 제공하는 stringValue 속성을 정의합니다. bounds 속성은 감지 된 코드의 축으로 정렬 된 경계 사각형을 제공하고 corner 속성은 모서리 점에 대한 사전 표현의 NSArray를 제공합니다. 후자는 코드의 모서리 지점과 긴밀하게 정렬되는 베이지어 패스를 구성 할 수 있으므로 특히 유용합니다.

### Building the Code Detection Delegate
이 응용 프로그램의 THCodeDetectionDelegate는 THPreviewView입니다. Listing 7.17부터 시작하여 이것이 어떻게 구현되는지 살펴 보자.

```objectivec
#import <AVFoundation/AVFoundation.h>
#import "THCodeDetectionDelegate.h"

@interface THPreviewView : UIView <THCodeDetectionDelegate>

@property (strong, nonatomic) AVCaptureSession *session;

@end
```
이 인터페이스는 익숙한 모양이어야합니다. 유일한 주목할 점은 THCodeDetectionDelegate 프로토콜을 채택하여 메타 데이터의 대상이 될 수 있도록한다는 점입니다. Listing 7.18의 구현으로 넘어 갑시다. FaceKamera 앱에서 사용하는 미리보기를 논의 할 때와 마찬가지로 기본 클래스 구조부터 시작하여 섹션을 다룹니다.
```objectivec
//  7.18
#import "THPreviewView.h"

@interface THPreviewView ()                                                 // 1
@property (strong, nonatomic) NSMutableDictionary *codeLayers;
@end

@implementation THPreviewView

+ (Class)layerClass {                                                       // 2
  return [AVCaptureVideoPreviewLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {                                                         // 3
    _codeLayers = [NSMutableDictionary dictionary];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
}

- (AVCaptureSession*)session {
  return self.previewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session {                            // 4
    self.previewLayer.session = session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

- (void)didDetectCodes:(NSArray *)codes {

}

@end
```
1. 클래스 확장을 작성하고 클래스가 사용하는 내부 특성을 정의하십시오.
2. 이전 섹션에서 수행 한 것처럼 layerClass 메서드를 재정의하고 AVCaptureVideoPreviewLayer의 인스턴스를 반환합니다. 이 메서드를 재정 의하여 뷰의 배경 레이어를 AVCaptureVideoPreviewLayer의 인스턴스로 만듭니다.
3. NSMutableDictionary의 인스턴스로 codeLayers 속성을 초기화합니다. 이것은 검출 된 바코드의 지오메트리를 나타내는 레이어 배열을 저장하는 데 사용됩니다. 종횡비가 경계 내에서 유지되도록 레이어의 videoGravity를 AVLayerVideoGravityResizeAspect로 설정합니다.
4. AVCaptureSession과 AVCapturePreviewLayer를 연결하려면 setSession : 메서드를 재정의하고 AVCaptureSession 인스턴스를 미리보기 레이어의 세션 속성으로 설정합니다.
기본적인 클래스 구조를 설정하고, 계속해서 Listing 7.19의 didDetectCodes : 메소드 구현을 시작하자. 취해야 할 첫 번째 단계는 장치 좌표에서 뷰 좌표로 메타 데이터를 변환하는 것입니다.

```objectivec
@implementation THPreviewView

...

- (void)didDetectCodes:(NSArray *)codes {

    NSArray *transformedCodes = [self transformedCodesFromCodes:codes];     // 1

}

- (NSArray *)transformedCodesFromCodes:(NSArray *)codes {                   // 2
    NSMutableArray *transformedCodes = [NSMutableArray array];
    for (AVMetadataObject *code in codes) {
        AVMetadataObject *transformedCode =
          [self.previewLayer transformedMetadataObjectForMetadataObject:code];
        [transformedCodes addObject:transformedCode];
    }
    return transformedCodes;
}

@end
```
1. 위임 메소드에 전달 된 AVMetadataMachineReadableCodeObject 인스턴스를 기반으로 변환 된 메타 데이터 오브젝트를 저장할 로컬 NSArray를 작성하십시오.
2. 디바이스 좌표 공간 메타 데이터 오브젝트에서 뷰 좌표 공간 오브젝트로의 변환을 수행 할 새 메소드를 작성하십시오. 이 메서드는 메서드에 전달 된 메타 데이터 개체 컬렉션을 반복하고 각각에 대해 미리보기 레이어의 transformedMetadataObjectForMetadataObject : 메서드를 호출하고 transformedCodes 배열에 추가합니다.
이제는 사용자 인터페이스를 구성하는 데 의미있는 좌표를 갖는 AVMetadataMachineReadableCodeObject 인스턴스 콜렉션이 있습니다. Listing 7.20과 같이이 메소드를 계속해서 구현해 보자.

```objectivec
//  7.20
@implementation THPreviewView

...

- (void)didDetectCodes:(NSArray *)codes {

    NSArray *transformedCodes = [self transformedCodesFromCodes:codes];

    NSMutableArray *lostCodes = [self.codeLayers.allKeys mutableCopy];      // 1

    for (AVMetadataMachineReadableCodeObject *code in transformedCodes) {

        NSString *stringValue = code.stringValue;                           // 2
        if (stringValue) {
            [lostCodes removeObject:stringValue];
        } else {
            continue;
        }

        NSArray *layers = self.codeLayers[stringValue];                     // 3

        if (!layers) {
            // no layers for stringValue, create new code layers
            layers = @[[self makeBoundsLayer], [self makeCornersLayer]];

            self.codeLayers[stringValue] = layers;
            [self.previewLayer addSublayer:layers[0]];
            [self.previewLayer addSublayer:layers[1]];
        }

        CAShapeLayer *boundsLayer = layers[0];                              // 4
        boundsLayer.path  = [self bezierPathForBounds:code.bounds].CGPath;

        NSLog(@"String: %@", stringValue);                                  // 5
    }

    for (NSString *stringValue in lostCodes) {                              // 6
        for (CALayer *layer in self.codeLayers[stringValue]) {
            [layer removeFromSuperlayer];
        }
        [self.codeLayers removeObjectForKey:stringValue];
    }
}

- (UIBezierPath *)bezierPathForBounds:(CGRect)bounds {
    return [UIBezierPath bezierPathWithRect:bounds];
}

- (CAShapeLayer *)makeBoundsLayer {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor =
      [UIColor colorWithRed:0.95f green:0.75f blue:0.06f alpha:1.0f].CGColor;
    shapeLayer.fillColor = nil;
    shapeLayer.lineWidth = 4.0f;
    return shapeLayer;
}

- (CAShapeLayer *)makeCornersLayer {
    CAShapeLayer *cornersLayer = [CAShapeLayer layer];
    cornersLayer.lineWidth = 2.0f;
    cornersLayer.strokeColor =
      [UIColor colorWithRed:0.172 green:0.671 blue:0.428 alpha:1.000].CGColor;
    cornersLayer.fillColor =
      [UIColor colorWithRed:0.190 green:0.753 blue:0.489 alpha:0.500].CGColor;

    return cornersLayer;
}

@end
```
1. codeLayers 사전에서 키의 변경 가능한 복사본을 만듭니다. 이 배열은이 메서드의 마지막에 어느 레이어를 삭제할까를 결정하기 위해서 사용됩니다.
2. 코드에서 stringValue를 찾으십시오. 유효한 문자열 객체가 반환 된 경우 lostCodes 배열에서 제거합니다. stringValue가 nil이면 합법적 인 값이없는 모든 코드를 건너 뛰기 때문에 continue 문을 실행하여 루프의 다음 반복을 계속하기 만하면됩니다.
3. 현재 stringValue에 대한 레이어의 기존 배열을 찾습니다. 이 값에 대한 항목이 없으면 두 개의 새 CAShapeLayer 개체를 만듭니다. CAShapeLayer는 베이지어 패스를 그리는데 사용되는 특수한 CALayer 서브 클래스입니다. 첫 번째는 경계 사각형을 그리는데 사용되며 다른 하나는 곧 구성 할 모서리 경로를 그립니다. 사전에 레이어에 대한 항목을 추가하고 각 레이어를 previewLayer에 추가합니다.
4. bounds 레이어의 경우 객체의 경계와 관련된 UIBezierPath를 만듭니다. Core Animation은 Quartz 타입에서만 작동하므로 CGPath 속성에 UIBezierPath를 요청하면 CGPathRef가 반환되어 레이어의 패스 속성으로 설정됩니다.
5. 이 앱의 목적에 따라 stringValue를 콘솔에 기록합니다. 실제 응용 프로그램에서는이 값을 의미있는 방식으로 사용자에게 표시하려고 할 것입니다.
6. 마지막으로 나머지 lostCodes 항목을 반복하고 각각에 대해 미리보기 레이어에서 레이어를 제거하고 사전에서 배열 항목을 제거합니다.
이제 응용 프로그램을 실행할 수 있습니다. 표 7.2의 바코드를 사용하여이 기능을 테스트 할 수 있습니다. 감지 된 각 코드에 대해 화면에 그려진 경계 사각형을 볼 수 있습니다. 카메라의 시점이 바코드에 수직인 경우 경계 사각형이 잘 정렬됩니다. 그러나 이 사각형은 비스듬히 스캔 할 때 잘 정렬되지 않습니다. 이것은 corner 속성이 들어오는 곳입니다. 대부분의 경우 corners 속성은 코드의 모서리 점을 포함하는 사전을 제공하므로 코드 지오메트리를 그리는데 더 좋은 소스를 제공합니다. 이러한 점을 사용하면 코드 모서리와 긴밀하게 정렬되는 베이지어 패스를 훨씬 쉽게 만들 수 있습니다. Listing 7.21의 corner 속성을 사용하는 방법을 살펴 보자.

```objectivec
@implementation THPreviewView

...

- (void)didDetectCodes:(NSArray *)codes {

    NSArray *transformedCodes = [self transformedCodesFromCodes:codes];

    NSMutableArray *lostCodes = [self.codeLayers.allKeys mutableCopy];

    for (AVMetadataMachineReadableCodeObject *code in transformedCodes) {

        NSString *stringValue = code.stringValue;
        if (stringValue) {
            [lostCodes removeObject:stringValue];
        } else {
            continue;
        }

        NSArray *layers = self.codeLayers[stringValue];
        if (!layers) {
            // no layers for stringValue, create new code layers
            layers = @[[self makeBoundsLayer], [self makeCornersLayer]];

            self.codeLayers[stringValue] = layers;
            [self.previewLayer addSublayer:layers[0]];
            [self.previewLayer addSublayer:layers[1]];
        }

        CAShapeLayer *boundsLayer  = layers[0];
        boundsLayer.path  = [self bezierPathForBounds:code.bounds].CGPath;

        CAShapeLayer *cornersLayer = layers[1];                             // 1
        cornersLayer.path = [self bezierPathForCorners:code.corners].CGPath;

        NSLog(@"String: %@", stringValue);
    }

    for (NSString *stringValue in lostCodes) {
        for (CALayer *layer in self.codeLayers[stringValue]) {
            [layer removeFromSuperlayer];
        }
        [self.codeLayers removeObjectForKey:stringValue];
    }
}

- (UIBezierPath *)bezierPathForCorners:(NSArray *)corners {
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (int i = 0; i < corners.count; i++) {
        CGPoint point = [self pointForCorner:corners[i]];                   // 2
        if (i == 0) {                                                       // 4
            [path moveToPoint:point];
        } else {
            [path addLineToPoint:point];
        }
    }
    [path closePath];                                                       // 5
    return path;
}

- (CGPoint)pointForCorner:(NSDictionary *)corner {                          // 3
    CGPoint point;
    CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)corner, &point);
    return point;
}

...


@end
```
1. cornersLayer의 경우 메타 데이터 객체의 corners 속성을 기반으로 CGPath를 구성합니다.
2. bezierPathForCorners : 메소드에서 빈 UIBezierPath를 작성하여 시작하십시오. CGPoint를 구성하는 각 항목에 대해 모서리 배열의 항목을 반복합니다.
3. 코너 포인트를 포함하는 사전에는 X 값에 대한 항목과 Y 값에 대한 항목이 있습니다. 이 값들을 직접 가져 와서 CGPoint를 수동으로 생성 할 수 있습니다. 그러나 Quartz 프레임 워크는 CGPointMakeWithDictionaryRepresentation이라는 편리한 함수를 제공하여 이를 수행합니다. 사전과 CGPoint 구조체에 대한 포인터를 전달하면됩니다.
4. UIBezierPath의 메소드를 사용하여 이러한 점을 기반으로 베이지어 경로를 생성합니다. 첫 번째 포인트의 경우 moveToPoint :를 호출하여 경로를 시작하고 후속 포인트의 경우 addLineToPoint :를 호출하여 나머지 포인트를 연결합니다.
5. 마지막으로 경로를 닫고 UIBezierPath 인스턴스를 호출자에게 반환합니다.

응용 프로그램을 다시 실행하십시오. 이제 장치를 움직이면 레이어가 바코드 모서리와 밀접하게 정렬됩니다.
기계 판독이 가능한 코드를 감지 할 수있는 기능이 프레임 워크에 매우 환영 받기 때문에이 기능은 다양한 응용 프로그램에서 광범위하게 구현 될 것으로 기대됩니다. 이 기능의 성능을 더 잘 이해하려면 지원되는 다른 기호를 실험 해 보는 것이 좋습니다. 또한 이 기능을 구현하는 모든 사용자에게 유용한 추가 통찰력과 팁을 제공하기 때문에 Apple의 Tech Note TN2325를 읽는 것이 좋습니다.

## Using High Frame Rate Capture
iOS 7에서 가장 흥미로운 기능 중 하나는 최신 세대의 iOS 장치에서 고화질 비디오를 캡처하는 기능이었습니다. 초당 프레임 수 (FPS)로 비디오를 캡처하면 몇 가지 흥미로운 이점을 얻을 수 있습니다. 첫 번째는 높은 FPS 비디오는 증가 된 시간 샘플링 속도로 인해 움직임을보다 정확하게 캡처하므로 사실감과 선명도가 더 잘 나타납니다. 특히 스포츠 경기와 같이 빠르게 움직이는 콘텐츠를 녹화 할 때 제공되는 모션의 세부 묘사와 유동성이 상당히 뛰어납니다. 다른, 그리고 아마도 더 널리 사용되는 이점은 고품질의 슬로우 모션 비디오 효과를 가능하게 하는 것입니다. 최신 세대의 iOS 장치는 60FPS (iPhone 5의 경우 120FPS)로 비디오 캡처를 지원하므로 30FPS의 프레임 속도를 유지하면서 재생 속도를 절반으로 줄여 부드러운 재생 경험을 제공 할 수 있습니다. 슬로우 모션보다 극적인 감각을 더할 수있는 것은 없으며, 이제는 그 능력이 당신의 손 안에 달려 있습니다.
높은 프레임 속도 캡처는 개발자가 얼마 동안 원했던 것입니다. 다행히도 애플은 그것을 별도의 기능으로 소개하지는 않았지만 프레임 워크 전반에 걸쳐 강력한 지원을 제공합니다.
  * 캡처 : 프레임 워크는 비디오 안정화 기능과 함께 60FPS에서 720p 비디오 캡처 또는 iPhone 5에서 최대 120FPS 캡처를 지원합니다. 또한 드롭 가능한 P 프레임을 지원하는 h.264 기능을 지원하므로 오래된 프레임에서 높은 프레임 속도의 콘텐츠가 원활하게 재생됩니다.
  * 재생 : AVPlayer는 이미 다양한 재생 속도로 콘텐츠를 재생할 수 있도록 지원합니다. 그러나 AVPlayerItem에 중요한 오디오 프로세싱 향상 기능이 추가되어 재생률을 낮추어 재생할 때 오디오 내용이 처리되는 방식을 제어 할 수 있습니다. AVPlayerItem에는 이제 재생 속도를 줄이거나 늘릴 때 사용되는 알고리즘을 설정할 수있는 audioTimePitchAlgorithm 속성이 있습니다. 사용 가능한 옵션은 AVPlayerItem API 설명서를 참조하십시오.
  * 편집 : 프레임 워크의 편집 기능은 변경 가능한 컴포지션 내에서 확장된 편집을 완벽하게 지원합니다. 8 장에서 미디어 구성 및 편집 방법에 대해 설명합니다.
  * 내보내기 : AV Foundation은 원본 프레임 속도를 유지하는 기능을 제공하므로 높은 FPS 콘텐츠가 내보내지거나 모든 콘텐츠가 표준 30FPS 출력으로 병합되도록 프레임 속도 변환을 수행 할 수 있습니다.

### High Frame Rate Capture Overview
이전 장에서는 세션 사전 설정을 지정하여 캡처 세션의 서비스 품질을 설정하는 방법을 보았습니다. 높은 프레임 속도 캡처를 지원하는 새로운 프리셋을 기대할 수 있습니다. 불행히도 이 기능을 사용하는 것은 그렇게 간단하지 않습니다. 이 프리셋 메커니즘을 확장하는 것은 실용적이지 않습니다. 프레임 속도와 크기의 모든 조합을 고려해야하는 사전 설정이 폭발적으로 발생하기 때문입니다. 대신 iOS 7에서 도입 된 병렬 구성 메커니즘을 통해 이 기능을 사용할 수 있습니다. 이 새로운 방법은 미리 설정된 모델을 대체하지는 않지만보다 세분화된 제어가 필요할 때 세션을 구성하는 대체 방법을 제공합니다.
이 장의 앞부분에서 AVCaptureDeviceFormat을 사용하여 활성 캡처 장치 형식이 지원하는 최대 확대 / 축소 비율을 결정했습니다. 비디오 확대 / 축소 예제에서 선택한 세션 사전 설정에 따라 자동으로 설정된 장치의 activeFormat을 사용하여 작업하고 있었습니다. 활성 형식 외에 장치에서 formats 속성을 쿼리하여 지원되는 모든 형식을 요청할 수도 있습니다. AVCaptureDeviceFormat의 인스턴스에는 videoSupportedFrameRateRanges 속성이 있습니다. 이 속성에는 형식에서 지원하는 최소 및 최대 프레임 속도와 기간을 자세히 설명하는 AVFrameRateRange 객체의 배열이 들어 있습니다. 높은 프레임 속도 캡처를 가능하게하는 기본 방법은 장치의 최고 품질 형식을 찾고 관련 프레임 지속 시간을 찾은 다음 캡처 장치에서 형식 및 프레임 지속 시간 값을 수동으로 설정하는 것입니다. 샘플 코드가 생기면 더 명확 해집니다. 7 장 디렉토리에서 SlowKamera_Starter 프로젝트를 열고이 기능을 구현해 봅시다.

## Enabling High Frame Rate Capture
이 지원을 가능하게하는 것은 현재 다소 번거롭지만, 이 기능을 AVCaptureDevice (참고 자료 7.22 참조)의 카테고리로 래핑하는 것이 조금 더 간단할 수 있습니다. 이 카테고리를 만들어 보겠습니다.
```objectivec
//  7.22
#import <AVFoundation/AVFoundation.h>

@interface AVCaptureDevice (THAdditions)

- (BOOL)supportsHighFrameRateCapture;
- (BOOL)enableHighFrameRateCapture:(NSError **)error;

@end
```
AVCaptureDevice에서 두 가지 방법, 즉 현재 프레임에서 높은 프레임 속도 캡처가 지원되는지 여부와 지원되는 경우 이 기능을 활성화하는 방법을 추가하여 범주를 만듭니다. 구현으로 넘어 갑시다.
카테고리 메소드 구현을 제공하기 전에 먼저 카테고리 메소드 구현을 단순화하는데 사용될 THQualityOfService라는 AVCaptureDevice + THAdditions.m 파일 내에 private 클래스를 작성해야합니다(목록 7.23 참조).

```objectivec
//  7.23
#import "AVCaptureDevice+THAdditions.h"
#import "THError.h"

@interface THQualityOfService : NSObject

@property(strong, nonatomic, readonly) AVCaptureDeviceFormat *format;
@property(strong, nonatomic, readonly) AVFrameRateRange *frameRateRange;
@property(nonatomic, readonly) BOOL isHighFrameRate;

+ (instancetype)qosWithFormat:(AVCaptureDeviceFormat *)format
               frameRateRange:(AVFrameRateRange *)frameRateRange;

- (BOOL)isHighFrameRate;

@end

@implementation THQualityOfService

+ (instancetype)qosWithFormat:(AVCaptureDeviceFormat *)format
               frameRateRange:(AVFrameRateRange *)frameRateRange {

    return [[self alloc] initWithFormat:format frameRateRange:frameRateRange];
}

- (instancetype)initWithFormat:(AVCaptureDeviceFormat *)format
                frameRateRange:(AVFrameRateRange *)frameRateRange {
    self = [super init];
    if (self) {
        _format = format;
        _frameRateRange = frameRateRange;
    }
    return self;
}

- (BOOL)isHighFrameRate {
    return self.frameRateRange.maxFrameRate > 30.0f;
}

@end
```
높은 프레임 속도 캡처를 사용하려면 캡처 장치에서 사용할 수있는 형식을 보고 지원되는 가장 높은 AVCaptureDeviceFormat 및 가장 높은 AVFrameRateRange를 찾아야합니다. THQualityOfService는 이 값을 저장하고 공용 범주 메소드의 구현을 단순화하는데 사용됩니다. Listing 7.24의 첫 번째 카테고리 메소드 구현을 살펴 보자.

```objectivec
//  7.24
@implementation AVCaptureDevice (THAdditions)

- (BOOL)supportsHighFrameRateCapture {
    if (![self hasMediaType:AVMediaTypeVideo]) {                            // 1
        return NO;
    }
    return [self findHighestQualityOfService].isHighFrameRate;              // 2
}

- (THQualityOfService *)findHighestQualityOfService {

    AVCaptureDeviceFormat *maxFormat = nil;
    AVFrameRateRange *maxFrameRateRange = nil;

    for (AVCaptureDeviceFormat *format in self.formats) {

        FourCharCode codecType =                                            // 3
            CMVideoFormatDescriptionGetCodecType(format.formatDescription);

        if (codecType == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {

            NSArray *frameRateRanges = format.videoSupportedFrameRateRanges;

            for (AVFrameRateRange *range in frameRateRanges) {              // 4
                if (range.maxFrameRate > maxFrameRateRange.maxFrameRate) {
                    maxFormat = format;
                    maxFrameRateRange = range;
                }
            }
        }
    }

    return [THQualityOfService qosWithFormat:maxFormat                      // 6
                              frameRateRange:maxFrameRateRange];
}

...

@end
```
1. AVCaptureDevice 인스턴스가 미디어 유형이 AVMediaTypeVideo인지 묻는 방법으로 AVCaptureDevice 인스턴스가 비디오 장치인지 확인합니다. 그렇지 않은 경우 이 메소드에서 NO를 리턴하십시오.
2. findHighestQualityOfService 메서드를 호출하여 이 카메라 장치가 지원하는 최대 형식 및 프레임 속도를 결정합니다. 높은 프레임 속도 캡처를 지원하고 값을 반환하는 경우 THQualityOfService 개체에 요청하십시오.
3. 모든 캡처 장치에서 지원되는 형식을 반복하고 각각에 대해 formatDescription에서 codecType을 가져옵니다. CMFormatDescriptionRef는, 형식 오브젝트에 관한 다양한 흥미로운 세부 사항을 제공하는 Core Media의 불투명 한 형식입니다. 420YpCbCr8BiPlanarVideoRange의 codeType 형식 만 처리하면 비디오 형식만으로 검색이 제한됩니다.
4. videoSupportedFrameRateRanges 속성에서 반환 된 형식의 AVFrameRateRange 객체 컬렉션을 반복합니다. 각각에 대해 maxFrameRate가 현재 최대 값보다 큰지를 결정합니다. 궁극적 인 목표는이 카메라 장치가 제공하는 최고 형식 및 프레임 속도 지원을 찾는 것입니다.
5. 마지막으로 지원되는 최고 형식 및 프레임 속도 범위를 캡처하는 내부 THQualityOfService의 새 인스턴스를 반환하십시오.
이제 활성 카메라가 제공하는 최고 수준의 지원을 결정할 수있는 방법을 얻었으므로 Listing 7.25에서이 기능을 실제로 활성화하는 방법을 살펴 보자.

```objectivec
//  7.25
- (BOOL)enableMaxFrameRateCapture:(NSError **)error {

    THQualityOfService *qos = [self findHighestQualityOfService];

    if (!qos.isHighFrameRate) {                                             // 1
        if (error) {
            NSString *message = @"Device does not support high FPS capture";
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : message};

            NSUInteger code = THCameraErrorHighFrameRateCaptureNotSupported;

            *error = [NSError errorWithDomain:THCameraErrorDomain
                                         code:code
                                     userInfo:userInfo];
        }
        return NO;
    }


    if ([self lockForConfiguration:error]) {                                // 2

        CMTime minFrameDuration = qos.frameRateRange.minFrameDuration;

        self.activeFormat = qos.format;                                     // 3
        self.activeVideoMinFrameDuration = minFrameDuration;                // 4
        self.activeVideoMaxFrameDuration = minFrameDuration;

        [self unlockForConfiguration];
        return YES;
    }
    return NO;

}
```
1. 장치에서 제공하는 최대 서비스 품질을 찾는 것으로 시작하십시오. 높은 프레임 속도 캡처를 지원하지 않으면 오류 포인터를 채우고 NO를 반환합니다.
2. 캡처 장치를 수정하기 전에 구성을 위해 장치를 잠글 필요가 있습니다.
3. 장치의 activeFormat을 검색된 AVCaptureDeviceFormat으로 설정합니다.
4. AVFrameRateRange에 정의 된 값의 최소 및 최대 프레임 지속 기간을 모두 고정하십시오. AV Foundation은 일반적으로 프레임 속도가 아닌 CMTime의 인스턴스로 지정된 프레임 지속 시간을 처리합니다. minFrameDuration은 maxFrameRate의 역수입니다. 예를 들어, 60FPS의 프레임 속도는 1/60 초의 지속 시간으로 표현됩니다.
카테고리가 완료되면이를 애플리케이션의 THCameraController 클래스에서 작동하도록 만들어 보자 (예제 7.26 참조).

```objectivec
//  7.26
#import "THCameraController.h"
#import "AVCaptureDevice+THAdditions.h"

@implementation THCameraController

- (BOOL)cameraSupportsHighFrameRateCapture {
    return [self.activeCamera supportsHighFrameRateCapture];
}

- (BOOL)enableHighFrameRateCapture {
    NSError *error;
    BOOL enabled = [self.activeCamera enableMaxFrameRateCapture:&error];
    if (!enabled) {
        [self.delegate deviceConfigurationFailedWithError:error];
    }
    return enabled;
}

@end
```
최신 세대 장치가있는 경우이 기능이 실제로 작동하는지 확인할 수 있습니다. 응용 프로그램을 실행하고 몇 초 분량의 비디오를 녹화하십시오. 중지 버튼을 누르면 비디오가 속도 조절 장치가 있는 플레이어에 표시됩니다. 다양한 속도 옵션을 시험하여 다양한 고화질 비디오가 다양한 재생 속도에서 얼마나 좋은지 확인하십시오.
높은 프레임 속도 캡처는 널리 요구되는 기능이었으며 iOS 7부터는 이 기능을 현재 사용할 수 있습니다. 캡처 외에도 AV Foundation은 프레임 워크의 모든 측면에서 높은 프레임 속도의 컨텐츠를 완벽하게 지원하며 흥미 진진한 새로운 클래스의 캡처 응용 프로그램을 만드는데 필요한 창의적인 도구를 제공합니다.

## Processing Video
6 장에서는 AVCaptureMovieFileOutput 클래스를 사용하여 QuickTime 무비를 캡처했습니다. 이 클래스는 내장 카메라에서 비디오 데이터를 쉽게 캡처하는 방법을 제공하지만 많은 시나리오에서 필요한 비디오 데이터 자체와 상호 작용할 수있는 기능을 제공하지 않습니다. 비디오 스트림에 실시간 비디오 효과를 적용하는 Apple의 Photo Booth 같은 응용 프로그램이나 카메라가 캡처한 환경에 대화형 캐릭터를 투영하는 Sphero의 Sharky the Beaver와 같은 증강 현실 응용 프로그램의 요구 사항을 고려하십시오. 이 두 예제 모두 AVCaptureMovieFileOutput에서 제공하는 것보다 캡처 된 비디오 데이터에 대한 저수준 제어가 필요합니다. 이 수준의 제어가 필요하면 AVCaptureVideoDataOutput이라는 프레임 워크에서 제공하는 최저 수준의 비디오 캡처 출력으로 전환합니다.
AVCaptureVideoDataOutput은 카메라 센서가 캡처한 비디오 프레임에 직접 액세스 할 수있는 AVCaptureOutput 하위 클래스입니다. 이는 비디오 데이터의 형식, 타이밍 및 메타 데이터를 완벽하게 제어 할 수 있으므로 필요에 따라 비디오 내용을 조작 할 수 있기 때문에 매우 강력한 기능입니다. 가장 일반적으로이 처리는 OpenGL ES 또는 Core Image를 사용하여 수행되지만 Quartz조차도 간단한 처리로 충분할 수 있습니다. 곧 빌드 할 샘플 앱에서 비디오 데이터 처리에 널리 사용되기 때문에 OpenGL ES와 통합하는 방법을 보여줄 것이지만 다음 장에서는 Core Image와 통합하고 활용하는 방법과 강력한 필터 모음의 이점을 살펴볼 것입니다.

```
노트
AV Foundation은 AVCaptureAudioDataOutput이라고 불리는 것뿐만 아니라 오디오 데이터 작업을위한 저수준 캡처 출력을 제공합니다. 이 장에서는 AVCaptureVideoDataOutput에만 초점을 맞추 겠지만 AVAssetReader 및 AVAssetWriter를 사용할 때 다음 장에서 오디오 형제를 사용할 것입니다.
```

AVCaptureVideoDataOutput을 사용하면이 장의 앞 부분에서 사용한 AVCaptureMetadataOutput과 유사하지만 가장 큰 차이점은 대리자 콜백입니다. AVCaptureVideoDataOutput은 AVMetadataObject의 인스턴스를 출력하는 대신 AVCaptureVideoDataOutputSampleBufferDelegate 프로토콜을 통해 비디오 데이터가 포함 된 객체를 출력합니다.
AVCaptureVideoDataOutputSampleBufferDelegate는 다음 메소드를 정의합니다.
  * captureOutput : didOutputSampleBuffer : fromConnection :이 메서드는 새로운 비디오 프레임이 기록 될 때마다 호출됩니다. 데이터는 비디오 데이터 출력의 videoSettings 속성 구성을 기반으로 디코딩되거나 다시 인코딩됩니다.
  * captureOutput : didDropSampleBuffer : fromConnection :이 메서드는 늦은 비디오 프레임이 삭제 될 때마다 호출됩니다. 이것을 호출하는 가장 일반적인 이유는 didOutputSampleBuffer : 호출에서 너무 많은 처리 시간이 걸리기 때문입니다. 되도록 효율적으로 처리를 수행해야합니다. 그렇지 않으면 결국 버퍼를 받지 못하게됩니다.
두 방법 모두에서 가장 중요한 인수는 샘플 버퍼와 관련된 것입니다. 샘플 버퍼는 CMSampleBuffer라는 객체 형식으로 제공됩니다. 이 샘플은 AVCaptureStillImageOutput과 함께 작업했을 때 6 장에서 간단히 설명했습니다. 이 유형에 대한 확실한 이해가 필수적이므로 이 객체가 무엇인지, 무엇이 제공되는지 자세히 살펴 보겠습니다.

### Understanding CMSampleBuffer
CMSampleBuffer는 미디어 파이프 라인을 통해 디지털 샘플을 셔틀 링하는 데 사용되는 Core Media 프레임 워크에서 제공하는 Core Foundation 스타일의 객체입니다. CMSampleBuffer는 기본 샘플 데이터에 대한 래퍼 역할을하며 데이터를 해석하고 처리하는 데 필요한 추가 메타 데이터와 함께 형식 및 타이밍 정보를 제공합니다. 먼저 CMSampleBuffer가 제공하는 샘플 데이터를 살펴 보겠습니다.

### Sample Data
AVCaptureVideoDataOutput으로 작업 할 때 샘플 버퍼에는 단일 비디오 프레임에 대한 원시 픽셀 데이터를 제공하는 코어 비디오 객체 인 CVPixelBuffer가 포함됩니다. 다음 예제는 CVPixelBuffer의 내용을 직접 조작하여 그레이 스케일 효과를 캡처 된 이미지 버퍼에 적용하는 방법을 보여줍니다.

```objectivec
const int BYTES_PER_PIXEL = 4;

CMSampleBufferRef sampleBuffer = // obtained sample buffer
CVPixelBufferRef pixelBuffer =                                          // 1
    CMSampleBufferGetImageBuffer(sampleBuffer);

CVPixelBufferLockBaseAddress( pixelBuffer, 0);                          // 2

size_t bufferWidth = CVPixelBufferGetWidth(pixelBuffer);                // 3
size_t bufferHeight = CVPixelBufferGetHeight(pixelBuffer);

unsigned char *pixel =                                                  // 4
    (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
unsigned char grayPixel;

for (int row = 0; row < bufferHeight; row++) {                          // 5
    for(int column = 0; column < bufferWidth; column++) {
        grayPixel = (pixel[0] + pixel[1] + pixel[2]) / 3;
        pixel[0] = pixel[1] = pixel[2] = grayPixel;
        pixel += BYTES_PER_PIXEL;
    }
}

CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);                         // 6

// Process grayscale video frame
```
이 예제에서 소개 된 새로운 정보가 꽤 있으므로 자세한 내용을 살펴 보겠습니다.
1. 먼저 CMSampleBufferGetImageBuffer 함수를 사용하여 CMSampleBufferRef에서 기본 CVPixelBuffer를 가져옵니다. CVPixelBuffer는 주 메모리에 픽셀 데이터를 저장하여 내용을 조작 할 수있는 기회를 제공합니다.
2. CVPixelBuffer 데이터와 상호 작용하기 전에 CVPixelBufferLockBaseAddress를 호출하여 해당 메모리 블록에 대한 잠금을 가져와야합니다.
3. CVPixelBufferGetWidth 및 CVPixelBufferGetHeight 함수를 사용하여 픽셀 버퍼의 너비와 높이를 결정하면 행과 열을 반복 할 수 있습니다.
4. CVPixelBufferGetBaseAddress 함수를 사용하여 이 픽셀 버퍼에 대한 기본 주소 포인터를 가져옵니다. 이렇게하면 이 버퍼로 인덱싱하고 데이터를 반복 할 수 있습니다.
5. 버퍼의 픽셀의 행과 열을 반복하고 RGB 픽셀의 간단한 그레이 스케일 평균을 수행합니다.
6. 마지막으로 CVPixelBufferUnlockBaseAddress 함수를 호출하여 2 단계에서 얻은 잠금을 해제해야합니다.

여기에서 이 버퍼를 CGImageRef 또는 UIImage로 변환하거나 필요한 추가 이미지 처리를 수행 할 수 있습니다. CVPixelBuffer.h에서 사용할 수있는 추가 CVPixelBuffer 함수를 살펴볼 것을 권장합니다.

### Format Descriptions
원시 미디어 샘플 그 자체 외에도 CMSampleBuffer는 CMFormatDescription이라는 개체 형태로 샘플에 대한 형식 정보에 대한 액세스를 제공합니다. CMFormatDescription.h에는 미디어 샘플에 대한 세부 정보에 액세스 할 수있는 다양한 함수가 정의되어 있습니다. CMFormatDecription 접두어가 붙은 이 헤더에 포함 된 함수는 일반적으로 모든 미디어 유형에 적용되며 CMVideoFormatDescription 및 CMAudioFormatDescription 접두어가 붙은 함수를 사용하여 각각 비디오 및 오디오에 대한 세부 정보를 얻습니다.
CMFormatDescription을 사용하여 오디오와 비디오 데이터를 구별하는 한 가지 방법을 살펴 보겠습니다.

```objectivec
CMFormatDescriptionRef formatDescription =
    CMSampleBufferGetFormatDescription(sampleBuffer);

CMMediaType mediaType = CMFormatDescriptionGetMediaType(formatDescription);

if (mediaType == kCMMediaType_Video) {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Process the frame of video
} else if (mediaType == kCMMediaType_Audio) {
    CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    // Process audio samples
}
```

### Timing
CMSampleBuffer는 미디어 샘플에 대한 타이밍 정보도 제공합니다. 타이밍 정보는 CMSampleBufferGetPresentationTimeStamp 및 CMSampleBufferGetDecodeTimeStamp 함수를 사용하여 추출하여 원래의 프레젠테이션 타임 스탬프 및 디코딩 타임 스탬프를 각각 가져올 수 있습니다. 다음 장에서 AVAssetReader 및 AVAssetWriter에 대해 논의 할 때 이 함수를 사용하는 방법에 대해 자세히 살펴 보겠습니다.

### Metadata Attachments
또한 Core Media는 CMAttachment.h에 정의 된 CMAttachment 형식으로 메타 데이터 프로토콜을 제공합니다. 이 API는 교환 가능한 이미지 파일 형식 (Exif) 태그와 같이 하위 수준 메타 데이터를 읽고 쓸 수있는 기능을 제공합니다. 예를 들어, 다음 예제는 주어진 CMSampleBuffer에서 Exif 메타 데이터를 검색 할 수 있음을 보여줍니다.

```objectivec
CFDictionaryRef exifAttachments = (CFDictionaryRef)CMGetAttachment(sampleBuffer,
                                     kCGImagePropertyExifDictionary,
                                     NULL);
```

이 딕셔너리를 콘솔에 프린트했다면, 다음 예제와 비슷한 결과를 볼 수 있습니다.

```
{
    ApertureValue = "2.526068811667587";
    BrightnessValue = "-0.4554591284958377";
    ExposureMode = 0;
    ExposureProgram = 2;
    ExposureTime = "0.04166666666666666";
    FNumber = "2.4";
    Flash = 32;
    FocalLenIn35mmFilm = 35;
    FocalLength = "2.18";
    ISOSpeedRatings =     (
        800
    );
    LensMake = Apple;
    LensModel = "iPhone 5 front camera 2.18mm f/2.4";
    LensSpecification =     (
        "2.18",
        "2.18",
        "2.4",
        "2.4"
    );
    MeteringMode = 5;
    PixelXDimension = 640;
    PixelYDimension = 480;
    SceneType = 1;
    SensingMethod = 2;
    ShutterSpeedValue = "4.584985584026477";
    WhiteBalance = 0;
}
```
CMSampleBuffer 및 관련 유형은 고급 AV Foundation 사용 사례로 작업 할 때 중요한 역할을 합니다. 이 작업을 곧 진행할 것이지만 다음 장에서이 유형으로 작업하는 몇 가지 추가 방법을 살펴볼 것입니다.

### Using AVCaptureVideoDataOutput
샘플 프로젝트를 살펴보고 AVCaptureVideoDataOutput을 사용하는 방법을 살펴 보겠습니다. CubeKamera_Starter라는 7 장 디렉토리에서 샘플 프로젝트를 찾을 수 있습니다. 이 프로젝트는 AV Foundation과 OpenGL ES를 통합하는 데 사용되는 몇 가지 기술을 보여줍니다. CubeKamera 앱은 전면 카메라에서 비디오를 캡처하여 회전하는 큐브에 OpenGL 텍스처로 해당 비디오 프레임을 매핑합니다.
Listing 7.27에서 프로젝트의 THCameraController 클래스에 대한 인터페이스를 살펴 보자.
```objectivec
//  7.27
#import <AVFoundation/AVFoundation.h>
#import "THBaseCameraController.h"

@protocol THTextureDelegate <NSObject>
- (void)textureCreatedWithTarget:(GLenum)target name:(GLuint)name;
@end

@interface THCameraController : THBaseCameraController

- (instancetype)initWithContext:(EAGLContext *)context;
@property (weak, nonatomic) id <THTextureDelegate> textureDelegate;

@end
```

이 클래스의 인터페이스는 정의된 OpenGL ES 유형 중 일부를 제외하고이 장에서 보았던 인터페이스와 비슷합니다. THCameraController는 EAGLContext 인스턴스로 생성됩니다. 이 객체는 OpenGL ES를 사용하여 그리는 데 필요한 상태와 리소스를 관리하는 렌더링 컨텍스트를 제공합니다. 헤더는 또한 불변의 OpenGL ES 이미지인 새로운 텍스처가 생성 될 때마다 호출 될 THTextureDelegate 프로토콜을 정의합니다. Listing 7.28의 구현으로 넘어 갑시다.

```objectivec
//  7.28
#import "THCameraController.h"
#import <AVFoundation/AVFoundation.h>

@interface THCameraController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (weak, nonatomic) EAGLContext *context;
@property (strong, nonatomic) AVCaptureVideoDataOutput *videoDataOutput;

@end

@implementation THCameraController

- (instancetype)initWithContext:(EAGLContext *)context {
    self = [super init];
    if (self) {
        _context = context;
    }
    return self;
}

- (NSString *)sessionPreset {                                               // 1
    return AVCaptureSessionPreset640x480;
}

- (BOOL)setupSessionOutputs:(NSError **)error {

    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];

    self.videoDataOutput.videoSettings =                                    // 2
        @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};


    [self.videoDataOutput setSampleBufferDelegate:self                      // 3
                                            queue:dispatch_get_main_queue()];

    if ([self.captureSession canAddOutput:self.videoDataOutput]) {          // 4
        [self.captureSession addOutput:self.videoDataOutput];
        return YES;
    }

    return NO;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {

}

@end
```
1. 이 응용 프로그램은 고해상도 비디오를 필요로하지 않으므로 sessionPreset 메서드를 재정 의하여 AVCaptureSessionPreset640x480을 반환합니다.
2. AVCaptureVideoDataOutput의 새 인스턴스를 만들고 해당 VideoSettings 사전을 사용자 지정합니다. 카메라의 네이티브 형식은 양면 420v입니다. 크로마 하위 샘플링에서 1 장, "AV Foundation 시작하기"의 설명을 상기 해보면 이 형식은 휘도와 색차를 구분하고 가로 및 세로 방향으로 색상을 서브 샘플링합니다. 이 네이티브 형식으로 직접 작업 할 수도 있지만 OpenGL ES로 작업 할 때는 BGRA를 사용하는 것이 좋습니다. 이 형식 변환이 약간의 성능 저하를 초래한다는 점을 알아 두십시오.
3. 이 클래스는 AVCaptureVideoDataOutputSampleBufferDelegate 프로토콜을 채택하고 대리자의 메서드를 호출해야하는 디스패치 큐를 지정하기 때문에 자체의 출력 대리자를 설정합니다. queue 인수에 지정된 발송 큐는 직렬 큐 여야합니다. 이 경우 이 응용 프로그램에 가장 적합하기 때문에 기본 대기열을 사용하지만 대부분의 경우 전용 비디오 처리 대기열이됩니다.
4. 마지막으로, 표준 테스트를 수행하여 출력을 세션에 추가 할 수 있는지 판별하십시오. 그렇다면 추가하여 YES를 리턴하십시오. 검사가 실패하면 NO를 반환합니다.

지금까지는 이전 예제에서 수행 한 것과 유사합니다. 계속해서 OpenGL ES 통합 지점에 대해 이야기 해 봅시다. OpenGL ES의 범위는이 책의 범위를 벗어나지 만 AV Foundation 개발자는 OpenGL ES가 고성능 비디오에 필요한 제어 기능을 제공하는 유일한 솔루션입니다. 응용 프로그램. 따라서 우리는 OpenGL ES에 다리 역할을하는 AV Foundation의 기본 프레임 워크에서 제공하는 기능에 대해 설명합니다. OpenGL ES 2.0에 대한 전체 개요를 보려면 Erik Buck (2012, Boston : Addison-Wesley)이 iOS 용 OpenGL ES 학습을 읽는 것이 좋습니다.
코어 비디오는 코어 비디오 픽셀 버퍼와 OpenGL ES 텍스처 사이의 다리 역할을 하는 CVOpenGLESTextureCache라는 객체 유형을 제공합니다. 캐시의 목적은 값 비싼 데이터 전송을 CPU에서 GPU로 제거하는 것입니다 (다시 잠재적으로 다시). 먼저 텍스쳐 캐시를 만들어서 (Listing 7.29) 봅시다.

```objectivec
//  7.29
@interface THCameraController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (weak, nonatomic) EAGLContext *context;
@property (strong, nonatomic) AVCaptureVideoDataOutput *videoDataOutput;

@property (nonatomic) CVOpenGLESTextureCacheRef textureCache;               // 1
@property (nonatomic) CVOpenGLESTextureRef cameraTexture;

@end

@implementation THCameraController

- (instancetype)initWithContext:(EAGLContext *)context {
    self = [super init];
    if (self) {
        _context = context;
        CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault,    // 2
                                                    NULL,
                                                    _context,
                                                    NULL,
&_textureCache);
        if (err != kCVReturnSuccess) {                                      // 3
            NSLog(@"Error creating texture cache. %d", err);
        }
    }
    return self;

}
```
1. 두 개의 새 속성을 추가하십시오. 첫 번째는 CVOpenGLESTextureCacheRef 자체용이고 두 번째는 AVCaptureVideoDataOutput 대리자 콜백에서 만들어지는 CVOpenGLESTextureRef 개체입니다.
2. CVOpenGLESTextureCacheCreate 함수를 사용하여 캐시의 새 인스턴스를 작성하십시오. 이 함수에 제공되는 핵심 인수는 backing EAGLContext와 textureCache 포인터입니다.
3.이 함수의 반환 값을 확인하는 것이 좋습니다. 이 경우 kCVReturnSuccess가 아닌 다른 것을 반환하면 오류를 콘솔에 기록하기 만하면됩니다. 프로덕션 앱에서 이것을 더욱 강력하게 처리 할 것을 제안합니다.

텍스쳐 캐시를 생성하면 실제로 움직일 수 있고 실제로 텍스처를 만들기 시작할 수 있습니다. CVPixelBuffer로부터 텍스처를 생성하는 함수는 CVOpenGLESTextureCacheCreateTextureFromImage이다. 이 함수는 델리게이트 콜백 내에서 사용되어 각 비디오 프레임에 대해 새로운 텍스처를 만듭니다. Listing 7.30은 이것이 어떻게 사용되는지 보여줍니다.

```objectivec
//  7.30
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {

    CVReturn err;
    CVImageBufferRef pixelBuffer =                                          // 1
        CMSampleBufferGetImageBuffer(sampleBuffer);

    CMFormatDescriptionRef formatDescription =                              // 2
        CMSampleBufferGetFormatDescription(sampleBuffer);
    CMVideoDimensions dimensions =
        CMVideoFormatDescriptionGetDimensions(formatDescription);

    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, // 3
                                                       _textureCache,
                                                       pixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_RGBA,
                                                       dimensions.height,
                                                       dimensions.height,
                                                       GL_BGRA,
                                                       GL_UNSIGNED_BYTE,
                                                       0,
                                                       &_cameraTexture);

    if (!err) {
        GLenum target = CVOpenGLESTextureGetTarget(_cameraTexture);         // 4
        GLuint name = CVOpenGLESTextureGetName(_cameraTexture);
        [self.textureDelegate textureCreatedWithTarget:target name:name];   // 5
    } else {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }

    [self cleanupTextures];
}

- (void)cleanupTextures {                                                   // 6
    if (_cameraTexture) {
        CFRelease(_cameraTexture);
        _cameraTexture = NULL;
    }
    CVOpenGLESTextureCacheFlush(_textureCache, 0);

}
```
1. 캡처 된 CMSampleBuffer에서 기본 CVImageBuffer를 가져와서 시작하십시오. (CVImageBuffer는 CVPixelBufferRef의 typedef입니다.)
2. CMSampleBuffer에서 CMFormatDescription을 가져옵니다. 형식 설명을 사용하여 CMVideoFormatDescriptionGetDimensions 함수를 사용하여 비디오 프레임의 크기를 가져옵니다. 이것은 너비와 높이가 들어있는 CMVideoDimensions 구조체를 반환합니다.
3. CVOpenGLESTextureCacheCreateTextureFromImage 함수를 사용하여 CVPixelBuffer에서 OpenGL ES 텍스처를 만듭니다. width 및 height 인수에 대해 dimension.height를 전달하고 있음을 알 수 있습니다. 오타가 아니라 오히려 약간의 속임수입니다. 비디오를 수평으로 자르기 때문에 완벽한 사각형입니다. 이 자르기를 수행 할 수있는 다른 방법이 있지만 이 예제에서는 간단하고 적합한 방법입니다.
4. CVOpenGLESTextureRef에서 대상과 이름을 가져옵니다. 텍스처 개체를 회전 큐브의 표면에 제대로 바인딩하는 데 필요합니다.
5. 대리자의 textureCreatedWithTarget : name 메서드를 호출하여 대리자가 실제 GL 텍스처 바인딩을 수행합니다.
6. 마지막으로 개인 cleanupTextures를 호출하여 텍스처를 해제하고 텍스처 캐시를 플러시합니다.

신청서는 완전하며 시험 사용 준비가 완료되었습니다. 응용 프로그램을 실행하면 캡쳐 된 비디오 프레임이 얼굴에 매핑 된 계속 회전하는 큐브가 나타납니다. 이 간단한 응용 프로그램이지만 AV Foundation과 OpenGL ES를 통합하는 방법을 잘 이해하고 있습니다. 두 기술이 서로 잘 어울리는 곳을 여러번 발견하게 될 것입니다.
AVCaptureVideoDataOutput은 캡처중인 비디오 프레임에 액세스 할 수있는 인터페이스를 제공합니다. 이를 통해 데이터가 표시되거나 처리되는 방식을 완벽하게 제어 할 수 있으므로 매우 강력한 비디오 애플리케이션을 구축 할 수 있습니다. 다음 장에서 다시 이 주제로 돌아와서 사용자 정의 비디오 처리 결과를 기록하는 방법을 살펴 보겠습니다.

## Summary
우리는 여러분의 어플리케이션에 많은 흥미 진진하고 흥미로운 것을 추가 할 수있는 많은 강력한 기능들을 다루었습니다. 이러한 기능을 별도로 살펴 보았지만 실제로 이러한 기능 중 상당수는 무료이며 단일 응용 프로그램에서 유용하게 사용할 수 있습니다. 6 장과 7 장에서 다루었던 기능은 차세대 놀라운 캡처 응용 프로그램을 구축하는 데 필요한 도구를 제공합니다.