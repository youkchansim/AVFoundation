# 3. Working with Assets and Metadata
* AV Foundation은 상당히 간단한 시작으로 출발했었습니다. iOS 2.2 및 3.0은 이전 장에서 살펴본 오디오 전용 클래스를 가져 왔으며 다양한 응용 프로그램에서 매우 유용 할 수 있지만 훨씬 더 큰 것의 예가 될뿐입니다. iOS 4.0이 나오기 전까지 AV Foundation은 오늘의 형태로 폭발했습니다. 이 릴리스에서는 미디어 캡처, 작성, 재생 및 처리를위한 광범위한 기능을 갖춘 방대한 프레임 워크를 제공합니다. 또한 저작물의 개념을 중심으로 디자인을 중앙 집중화하여 파일 기반 오디오 수업에서 벗어났습니다. 이 장에서는 가장 중요한 `AVAsset 클래스`를 시작으로 AV Foundation의 Asset 중심 세계로의 여행을 시작합니다.

## Understanding Assets
* AV Foundation의 핵심에는 AVAsset이라는 클래스가 있습니다. 이 클래스는 AV Foundation의 디자인의 핵심이며 사실상 모든 특징과 기능에서 핵심적인 역할을합니다. AVAsset은 제목, 기간 및 메타 데이터와 같이 미디어의 `정적 속성을 전체적으로 모델링하여 미디어 리소스의 복합 표현을 제공하는 추상 불변 클래스`입니다. AV Foundation을 성공적으로 활용하려면 AV의 목적과 기능을 명확하게 이해하는 것이 중요합니다.
* AVAsset은 그것이 모델링 한 미디어의 `두 가지 중요한 측면`을 추상화합니다. 첫 번째는 `기본 미디어 형식에 대한 추상화 계층`을 제공한다는 것입니다. 즉, QuickTime 동영상, MPEG-4 비디오 또는 MP3 오디오 트랙을 사용하여 작업 할 때 또는 프레임 워크의 나머지 부분에 이르기까지 모든 작업을 의미합니다. 이는 단지 Asset 일 뿐 입니다. 이를 통해 다양한 코덱 및 컨테이너 형식의 세부 사항을 염려 할 필요없이 미디어 작업을 통일 된 방식으로 수행 할 수 있습니다. 그러나 필요할 때 언제든지 세부 정보를 얻을 수 있습니다. 또한 AVAsset은 `리소스의 위치를 ​​숨깁니다`. 기존 미디어 항목으로 작업 할 때 URL로 초기화하여 Asset을 만듭니다. 이것은 응용 프로그램 번들 또는 파일 시스템의 다른 위치를 가리키는 로컬 URL 일 수도 있고 사용자의 iPod 라이브러리에서 가져온 URL 일 수도 있고 원격 서버의 오디오 또는 비디오 스트림 URL 일 수도 있습니다 . 다시 한번, AVAsset은 이러한 세부 사항으로부터 당신을 보호하고 위치에 관계없이 미디어가 올바르게 검색되고 로드되도록 프레임 워크에 무리를줍니다. AVAsset은 미디어 형식과 위치의 복잡성을 추상화하여 시간에 맞춘 미디어 작업을 간단하고 일관된 방법으로 제공합니다.
* AVAsset은 `미디어 자체가 아니며` 시간이 지정된 미디어의 `컨테이너 역할`을합니다. 내용을 설명하는 메타 데이터와 함께 하나 이상의 미디어 트랙으로 구성됩니다. 자산에 포함 된 균일하게 형식화 된 미디어를 나타내는 AVAssetTrack이라는 클래스는 개별 트랙을 모델링합니다. AVAssetTrack은 가장 일반적으로 오디오 또는 비디오 스트림을 모델링하지만 텍스트, 자막 또는 자막과 같은 미디어를 추가로 나타낼 수 있습니다 (그림 3.1 참조).

<center>
<image src="Resource/01.png">
</center>

* Asset의 트랙은 트랙 속성을 통해 액세스 할 수 있습니다. 이 속성을 요청하면 컬렉션의 모든 트랙을 포함하는 NSArray가 반환됩니다. 또한 AVAsset은 식별자, 미디어 유형 또는 미디어 특성별로 트랙을 `검색하는 기능을 제공`합니다. 이렇게하면 추가 처리를 위해 트랙의 하위 집합을 쉽게 검색 할 수 있습니다.

## Creating an Asset
* 기존 미디어 리소스에 대한 AVAsset을 만들 때는 `URL`을 사용하여 초기화합니다. 이것은 종종 로컬 파일 URL이지만 원격 자원의 URL이 될 수도 있습니다.

```Swift
let asset = AVAsset(url: URL)
```

* AVAsset는 `추상 클래스`이므로 직접 인스턴스화 할 수 없습니다. `assetWithURL : 메서드`를 사용하여 인스턴스를 만들면 실제로 AVURLAsset이라는 하위 클래스 중 하나의 인스턴스가 만들어집니다. 이 클래스를 사용하면 사전에 옵션을 전달하여 Asset이 어떻게 생성되는지 미세하게 조정할 수 있기 때문에 이 클래스를 직접 사용하는 것이 유용 할 때가 있습니다. 예를 들어, 오디오 또는 비디오 편집 시나리오에서 사용할 Asset을 만드는 경우 다음 예제와 같이보다 정확한 기간과 타이밍을 제공하도록 옵션을 전달할 수 있습니다.

```Swift
let asset = AVURLAsset(url: URL, options: [String : Any]?)
```

* 이 옵션을 전달하면보다 정확한 재생 시간 및 타이밍 정보를 얻기 위해 `약간 더 긴 로딩 시간이 필요`하다는 힌트를 얻을 수 있습니다.
* Asset을 만들려는 일반적인 위치가 많이 있습니다. iOS 장치에서 사용자의 사진 라이브러리에 있는 비디오나 iPod 라이브러리에 있는 노래에 액세스 할 수 있습니다. Mac에서는 사용자의 iTunes 보관함에서 미디어 항목을 검색 할 수 있습니다. iOS 및 OS X에서 사용할 수 있는 일부 보조 프레임워크 덕분에 이러한 미디어 리소스도 활용할 수 있습니다. 이러한 프레임 워크를 사용하는 몇 가지 예를 살펴 보겠습니다.

## iOS Assets Library
* 내장 카메라 응용 프로그램이나 타사 비디오 캡처 응용 프로그램을 사용하여 사용자가 캡처한 비디오는 대개 사용자의 `사진 라이브러리`에 기록됩니다. iOS는 이 라이브러리에서 읽고 쓸 수있는 AssetsLibrary 프레임 워크를 제공합니다. 다음은 사용자의 Asset 라이브러리에 있는 비디오에서 AVAsset을 만드는 예제입니다.

```Swift
        let library = ALAssetsLibrary()
        library.enumerateGroupsWithTypes(ALAssetsGroupSavedPhotos, usingBlock: { group, stop in
            group?.setAssetsFilter(ALAssetsFilter.allVideos())
            group?.enumerateAssets(at: IndexSet(integer: 0), options: NSEnumerationOptions.init(rawValue: 0), using: { alAsset, index, innerStop in
                if let representation = alAsset?.defaultRepresentation(), let url = representation.url() {
                    let asset = AVAsset(url: url)
                }
            })
        }, failureBlock: { error in
            NSLog(error?.localizedDescription ?? "")
        })
```

* 이 예제는 저장된 사진 그룹에 저장된 비디오를 검색하는 방법을 보여줍니다. 이 그룹을 비디오 내용만 필터링한 다음 이 그룹의 첫 번째 비디오를 가져옵니다. 이 라이브러리의 항목은 ALAsset 객체로 모델링됩니다. 디폴트의 표현으로 ALAsset를 요구하면, AVAsset의 작성에 적절한 URL를 제공하는 ALAssetRepresentation가 리턴됩니다.

## iOS iPod Library
* 미디어를 검색 할 수있는 일반적인 위치는 사용자의 iPod 라이브러리입니다. MediaPlayer 프레임 워크는 이 라이브러리에서 항목을 쿼리하고 검색 할 API를 제공합니다. 원하는 항목을 찾으면 URL을 요청하고 이를 사용하여 자산을 초기화 할 수 있습니다. 예를 살펴 보겠습니다.

```Swift
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
            }
        }

```

* MediaPlayer 프레임 워크는 MPMediaPropertyPredicate라는 클래스를 제공하며 이 클래스를 사용하여 iPod 라이브러리 내의 모든 항목을 찾을 수 있습니다. 예제 코드는 Foo Fighter의 In Your Honor 앨범에서 "Best of You"를 찾고 있습니다. 성공적인 쿼리를 실행하면 미디어 항목의 Asset URL 속성을 캡처하여 이를 사용하여 AVAsset을 만듭니다.

## Mac iTunes Library
* OS X에서 iTunes는 미디어를 저장하는 사용자의 중앙 저장소입니다. 이 라이브러리 내의 리소스를 확인하기 위해 개발자는 일반적으로 iTunes 음악 디렉토리에 포함 된 iTunes Music Library.xml 파일을 구문 분석하고 관련 데이터를 추출합니다. Mac OS X 10.8 및 iTunes 11.0부터는 확실히 실용적인 솔루션이지만 iTunesLibrary 프레임 워크 덕분에이 라이브러리로 작업하기가 더 쉬워졌습니다. 이 라이브러리를 쿼리하는 방법을 살펴 보겠습니다.
```ObjectiveC
ITLibrary *library = [ITLibrary libraryWithAPIVersion:@"1.0" error:nil];

NSArray *items = self.library.allMediaItems;
NSString *query = @"artist.name == 'Robert Johnson' AND "
                   "album.title == 'King of the Delta Blues Singers' AND "
                   "title == 'Cross Road Blues'";
NSPredicate *predicate =
    [NSPredicate predicateWithFormat:query];

NSArray *songs = [items filteredArrayUsingPredicate:predicate];

if (songs.count > 0) {
    ITLibMediaItem *item = songs[0];
    AVAsset *asset = [AVAsset assetWithURL:item.location];
    // Asset created. Perform some AV Foundation magic.
}
```

* iTunesLibrary 프레임 워크는 MediaPlayer 프레임 워크와 같은 특정 쿼리 API를 제공하지 않습니다. 그러나 `표준 Cocoa NSPredicate 클래스`를 사용하여 복잡한 쿼리를 구성하여 원하는 항목을 찾을 수 있습니다. 원하는 항목으로 미디어 항목을 필터링 한 후 ITLibMediaItem에 해당 위치를 요청하여 AVAsset을 만드는 데 적합한 URL을 제공 할 수 있습니다.

## Asynchronous Loading
* AVAsset에는 지속 시간, 생성 날짜 및 메타 데이터와 같은 Asset에 대한 정보를 제공하는 다양한 유용한 메서드와 속성이 있습니다. 또한 보유하고있는 트랙 모음을 검색하고 작업하는 메소드도 있습니다. 그러나 저작물을 만들 때 저작물이 기본 미디어 파일의 핸들링에 불과하다는 것을 이해하는 것이 중요합니다. AVAsset은 요청 될 때까지 Asset의 등록 정보를 로드하지 못하도록하는 매우 효율적인 설계를 채택합니다. 이를 통해 연결된 미디어 및 메타 데이터 로딩의 불이익을 즉시 지불하지 않고도 Asset을 신속하게 생성 할 수 있지만 속성 액세스는 항상 동기적으로 발생한다는 것을 이해하는 것이 중요합니다. 요청한 속성이 이전에 로드되지 않은 경우 적절한 응답을 반환 할 수 있는 상태가 될 때까지 차단됩니다. 분명히 이것은 문제를 일으킬 수 있습니다. 예를 들어 Asset의 duration을 묻는 것은 잠재적으로 값 비싼 작업이 될 수 있습니다. 길이를 정의하는 헤더에 TLEN 태그가 설정되지 않은 MP3 파일로 작업하는 경우 전체 오디오 트랙의 길이를 정확하게 결정하기 위해 파싱해야합니다. 이 요청이 주 스레드에서 발행되었다고 가정하면이 응답을 기다리면 작업이 완료 될 때까지 주 스레드를 차단하게됩니다. 최선의 시나리오에서는 부진하고 응답하지 않는 사용자 인터페이스가 남아 있습니다. iOS의 극단적인 경우에는 워치 독이 함께 들어가고 애플리케이션이 종료 될 정도로 오래 차단 될 수 있습니다. 이것은 One Star Review Land에 대한 특급 항공권입니다. 이 문제를 해결하려면 자산의 속성을 `비동기적으로 쿼리`해야합니다.
* AVAsset과 AVAssetTrack은 모두 `AVAsynchronousKeyValueLoading`이라는 프로토콜을 채택합니다. 이 프로토콜은 다음 메소드를 제공하여 속성을 비동기 적으로 쿼리하는 방법을 제공합니다.

```Swift
asset.statusOfValue(forKey: String, error: NSErrorPointer)
loadValuesAsynchronously(forKeys: [String], completionHandler: (() -> Void)?)
```

* `statusOfValueForKey : error : 메소드`를 사용하여 지정된 속성의 상태를 쿼리 할 수 있습니다.이 메서드는 요청한 속성의 현재 상태를 나타내는 AVKeyValueStatus 유형의 enum 값을 반환합니다. 상태가 AVKeyValueStatusLoaded가 아닌 경우 잠재적으로 차단하지 않고 상태를 검색 할 수 없다는 의미입니다. 주어진 속성을 비동기적으로 로드하려면 `loadValuesAsynchronouslyForKeys : completionHandler : 메서드`를 호출하고 하나 이상의 키 (애셋의 속성 이름) 배열과 애셋이 요청에 응답 할 상태에있을 때 호출되는 completionHandler 블록을 제공합니다 . 예를 살펴 보겠습니다.

```Swift
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
```

* 이 예제는 응용 프로그램 번들에 저장된 QuickTime 무비에 대한 AVAsset을 만들고 비동기적으로 해당 tracks 속성을 로드합니다. 완료 핸들러에서 자산의 `statusOfValueForKey : error : 메소드`를 호출하여 요청된 등록 정보의 상태를 확인하려고합니다. 상태가 AVKeyValueStatusFailed로 되돌아 오면 오류 정보가 포함될 것이므로이 메서드에 NSError 포인터를 전달하는 것이 중요합니다. 일반적으로 상태 값을 전환하고 반환 된 상태를 기반으로 적절한 조치를 취합니다. 완료 핸들러 블록은 임의의 큐에서 호출된다는 점에 유의하십시오. 사용자 인터페이스를 업데이트하기 전에 먼저 주 큐로 다시 보내야합니다.

```
노트
이 예제는 트랙 하나의 속성을로드하는 것을 보여 주지만 한 번의 호출로 여러 속성을 요청할 수 있습니다. 여러 속성을 요청할 때주의해야 할 몇 가지 중요한 사항이 있습니다.
1. completionHandler 블록은 `loadValuesAsynchronouslyForKeys : completionHandler : 호출 당 한 번`만 호출됩니다. 호출은 이 메소드에 전달하는 키의 수와 관련이 없습니다.
2. 요청한 각 속성에서 `statusOfValueForKey : error :`를 호출해야합니다. 모든 속성이 동일한 상태 값을 반환한다고 가정 할 수는 없습니다.
```

## Media Metadata
* 미디어 앱을 제작할 때 중요한 관심사는 media-organization입니다. 파일 이름 목록을 사용자에게 제시하는 것만으로도 소수의 파일만 허용될 수 있지만이 접근법은 그 이상으로 확장되지 않습니다. 대신, 정말로 필요한 것은 사용자가 미디어를 쉽게 찾고, 식별하고 구성 할 수 있도록 미디어를 설명하는 방법입니다. 다행히도 AV Foundation에서 사용할 주요 미디어 형식은 모두 내용을 설명하는 메타 데이터를 임베드 할 수있는 기능을 제공합니다. 메타 데이터 작업은 어려운 주제 일 수 있습니다. 각 미디어 유형마다 고유 한 형식이 있기 때문에 일반적으로 개발자는 형식을 읽고 읽고 쓸 수있는 낮은 수준의 이해가 필요합니다. 고맙게도 AV Foundation은 대부분의 형식 별 세부 정보를 추상화하여 훨씬 쉽게 만듭니다. 미디어 메타 데이터로 작업하는 비교적 균일 한 방법을 제공합니다. 이 장의 나머지 부분에서는 AV Foundation의 메타 데이터 지원에 대해 자세히 설명하여 자신의 앱에서 이러한 기능을 어떻게 활용할 수 있는지 살펴 보겠습니다. 세부 사항을 설명하기 전에, 발생할 수있는 다양한 형식으로 메타 데이터를 저장하는 방법을 간단히 살펴 보겠습니다.

### Metadata Formats
* 다양한 미디어 포맷이 존재하지만, QuickTime (mov), MPEG-4 비디오 (mp4 및 m4v), MPEG-4 오디오 (m4a), MPEG-Layer III 오디오(mp3)와 같은 네 가지 기본 유형이 있습니다. AV Foundation이 이러한 파일에 포함 된 메타 데이터 작업을위한 단일 인터페이스를 제공하지만이 데이터가 각 유형에 저장되는 방법과 위치를 이해하는 것이 여전히 중요합니다. 이것은 상당히 고차원적인 토론이 될 것이지만 더 많은 조사를위한 기초를 제공 할 것입니다.

### QuickTime
* QuickTime은 Apple에서 개발한 강력한 `크로스 플랫폼 미디어 아키텍처`입니다. 아키텍처의 일부는 .mov 파일의 내부 구조를 정의하는 QuickTime File Format 사양입니다. QuickTime 파일은 Atoms라고하는 데이터 구조로 구성됩니다. 일반적으로 Atoms는 매체의 측면을 설명하는 데이터를 포함하거나 다른 원자를 포함하지만 둘 다 포함하지 않는다는 것입니다. 그러나 Apple 자체 구현으로 이 규칙을 위반 한 경우가 몇 가지 있습니다. Atoms는 오디오 샘플 및 비디오 프레임의 레이아웃, 형식에서 작성자 및 저작권 정보와 같이 표시 가능한 메타 데이터에 이르기까지 모든 것을 풍부하게 설명하는 복잡한 트리 형태의 구조로 구성됩니다.
* QuickTime 형식의 구조를 이해하는 한 가지 방법은 Hex Fiend 또는 Synalyze It과 같은 16 진 편집기에서 .mov 파일을 여는 것입니다. 일반적인 16 진수 도구는 QuickTime 파일의 데이터를 실제로 나타내지만 Atoms의 구조와 관계를 시각화하는 것이 특히 쉽지는 않습니다. 더 나은 해결책은 Apple 개발자 센터에서 제공되는 Atom Inspector 도구를 사용하는 것입니다. 이 도구는 NSOutlineView에서 Atoms 구조를 보여 주므로 Atoms 간의 계층 관계를 보다 잘 이해할 수 있으며 실제 16 진수 뷰어를 제공하므로 실제 바이트 레이아웃을 볼 수 있습니다.
* 그림 3.2는 픽사의 유명한 인크레더블 중 하나 인 QuickTime 버전의 구조를 간략하게 보여줍니다. QuickTime 파일은 최소 3 개의 최상위 아톰을 포함합니다. 파일 유형 및 호환 브랜드를 설명하는 ftyp. 실제 오디오 및 비디오 미디어가 포함 된 mdat; 미디어의 모든 관련 세부 정보 (예 : 메타 데이터 포함)를 완전히 설명하는 매우 중요한 moov 아톰 (read moo-vee)입니다.

<center>
<image src="Resource/02.png" width="50%" height="50%">
</center>

* QuickTime 동영상으로 작업 할 때 발생할 수 있는 두 가지 유형의 메타 데이터가 있습니다. Final Cut Pro X와 같은 도구로 작성된 표준 QuickTime 메타 데이터는 / moov / meta / ilst / 아래에 있으며 키에는 거의 항상 com.apple.quicktime 접두어가 붙습니다. 다른 유형은 QuickTime 사용자 데이터로 간주되며 / moov / udta / 아래에 저장됩니다. QuickTime 사용자 데이터에는 아티스트 또는 저작권 정보와 같이 플레이어가 찾을 수있는 표준 값이 포함될 수 있지만 응용 프로그램에 유용 할 수있는 임의의 데이터도 포함될 수 있습니다. AV Foundation은 두 가지 유형의 메타 데이터를 읽고 쓸 수 있습니다.
* 다양한 Atoms의 세부 사항과 관련성을 이해하는 것은 이 논의의 범위를 벗어난다. 실제로 Apple은 파일 형식의 세부 사항을 완전히 설명하는 `QuickTime File Format Specification1`이라는 400 개 이상의 페이지 문서를 보유하고 있습니다. 이 주제에 대해 전문가가되는 것이 중요하지는 않지만, 중요한 moov 원자의 세부 사항을 살펴 보는 것이 좋습니다. AV Foundation이이 데이터를 사용하는 방법에 대한 귀중한 통찰력을 얻을 수 있기 때문입니다.

[QuickTime File Format Specification](https://developer.apple.com/library/mac/documentation/quicktime/QTFF/QTFFPreface/qtffPreface.html)

### MPEG–4 Audio and Video
* MPEG-4 Part 14는 MP4 파일 형식을 정의하는 사양입니다. MP4는 QuickTime 파일 형식의 직계 종속이며, 이는 QuickTime 파일과 거의 동일한 구조를 가짐을 의미합니다. 실제로 한 파일 유형을 구문 분석하는 방법을 알고있는 도구는 일반적으로 다른 수준의 구문을 분석 할 수 있습니다 (성공 정도는 다양 함). QuickTime 파일과 마찬가지로 MP4는 아톰(atom)이라는 데이터 구조로 구성됩니다. 전문적으로, MPEG-4 명세는 그것들을 박스라고 부르지만, 형식의 QuickTime 계통을 감안할 때, 대부분의 개발자는 여전히 그것들을 원자라고 부릅니다. 그림 3.3은 Incredibles를 다시 보여 주지만 이번에는 MP4 형식으로 보여줍니다.

<center>
<image src="Resource/03.png" width="50%" height="50%">
</center>

* MPEG-4 파일의 메타 데이터는 / moov / udta / meta / ilst / 아래에 있습니다. 이 원자 아래에서 찾을 수 있는 키에 대한 표준은 없지만 대부분의 도구는 Apple의 게시되지 않은 iTunes 메타 데이터 사양에 정의 된 키를 채택합니다. 미발표 임에도 불구하고 iTunes 메타 데이터 형식은 웹에서 널리 이해되고 문서화됩니다. 이 포맷에 대한 하나의 특히 좋은 문서는 오픈 소스 mp4v2 라이브러리에서 찾을 수 있습니다.

[mp4v2 Library](https://code.google.com/p/mp4v2/wiki/iTunesMetadata)

* 파일 확장명에 혼란이 있습니다. .mp4의 확장자는 MPEG-4 미디어 용으로 정의 된 표준 확장이지만 .m4v, .m4a, .m4p 및 .m4b와 같은 변형이 있습니다. 이러한 변형은 모두 MPEG-4 컨테이너 형식을 사용하지만 일부는 추가 확장을 포함합니다. M4V 파일은 Apple의 FairPlay 암호화 및 AC3 오디오 확장 기능이 포함 된 MPEG-4 비디오 파일입니다. 둘 다 사용하지 않으면 MP4 및 M4V의 확장 기능 만 다릅니다. M4A는 오디오용이며 오디오 전용 리소스로 식별하는 수단으로 파일 확장자가 다릅니다. M4P는 FairPlay 암호화 확장을 사용하는 Apple의 이전 iTunes 오디오 형식이었습니다. M4B는 오디오북에 사용되며 일반적으로 챕터 마커가 포함되어 있으며 사용자의 재생 위치를 기억하여 재생을 북마크에 추가 할 수 있습니다.

### MP3
* MP3 파일은 이전 섹션에서 설명한 형식과 크게 다릅니다. MP3 파일은 컨테이너 형식을 사용하지 않습니다. 대신 선택적으로 구조화 된 메타 데이터 블록이 포함 된 인코딩 된 오디오 데이터가 일반적으로 파일의 시작 부분 앞에 붙습니다. MP3 파일은 ID3v2라는 형식을 사용하여 아티스트, 앨범 및 장르와 같은 데이터를 포함하여 오디오 내용에 대한 설명 정보를 저장합니다. 16진수 편집기를 사용하면 이 형식의 구조를 조사하는 좋은 방법입니다. ID3 데이터는 이전 섹션에서 설명한 원자보다 훨씬 읽기 쉽습니다. 메타 데이터가 내장된 MP3 파일의 처음 10 바이트는 ID3 블록의 헤더를 정의합니다. 이 헤더의 처음 3 바이트는 항상 '49 44 33 '(ID3)이며 이것이 ID3v2 태그이고 그 뒤에 주 버전 (2, 3 또는 4)과 개정 번호를 정의하는 2 바이트가 있음을 나타냅니다. 나머지 바이트는 플래그 집합과 ID3 블록의 크기를 정의합니다. 그림 3.4를 참조하십시오.

<center>
<image src="Resource/04.png" width="50%" height="50%">
</center>

* ID3 블록의 나머지 데이터는 다양한 메타 데이터 키와 값을 설명하는 프레임입니다. 각 프레임은 실제 태그 이름으로 시작하는 10 바이트 헤더와 크기를 나타내는 4 바이트 및 선택적 플래그를 정의하는 2 바이트를 포함합니다. 프레임의 나머지 바이트는 실제 메타 데이터 값을 포함합니다. 값이 텍스트 인 경우 (일반적인 경우) 태그의 첫 번째 바이트가 유형 인코딩을 정의합니다. 형식 인코딩은 일반적으로 ISO-8859-1을 나타내는 0x00으로 설정되지만 대체 인코딩도 지원할 수 있습니다. 그림 3.5는 John Coltrane의 클래식 곡 "Giant Steps"의 MP3 버전에 대한 ID3 구조의 예를 보여줍니다.

<center>
<image src="Resource/05.png" width="50%" height="50%">
</center>

* AV Foundation은 ID3v2 태그의 모든 버전을 읽는 것을 지원하지만, 그것들을 쓰는 것을 지원하지 않습니다. MP3는 특허가 없기 때문에 AV Foundation은 MP3 또는 ID3 데이터 인코딩을 지원하지 않습니다.

```
노트
AV Foundation은 모든 형태의 ID3v2 태그를 읽는 것을 지원하지만 ID3v2.2는 별표와 함께 제공됩니다. ID3v2.2의 레이아웃은 ID3v2.3 이상과 다릅니다. 특히 개별 태그는 4 개가 아닌 3 개의 문자입니다. 예를 들어, ID3v2.2로 태그 된 노래의 주석은 COM 프레임 아래에 저장되는 반면, ID3v2.3 이상으로 태그 된 동일한 노래는 해당 데이터를 COMM 프레임으로 저장합니다. 프레임 워크에서 정의한 문자열 상수는 ID3v2.3 이상에서 작업 할 때만 적용 할 수 있습니다. 그러나 ID3v2.2 데이터로 작업 할 수있는 방법을 샘플 애플리케이션에 전달할 수 있습니다.
```

## Working with Metadata
* AVAsset 및 AVAssetTrack은 관련 메타 데이터에 대해 쿼리 할 수 있는 기능을 제공합니다. 일반적으로 AVAsset에서 제공하는 메타 데이터를 활용하지만 트랙 레벨 메타 데이터를 검색하는 것이 유용 할 수 있습니다. 항목의 메타 데이터를 읽는 인터페이스는 `AVMetadataItem`이라는 클래스에서 제공합니다. 이 클래스는 QuickTime 및 MPEG-4 아톰 및 ID3 프레임에 저장된 메타 데이터에 액세스하는 객체 지향 인터페이스를 제공합니다.
* AVAsset 및 AVAssetTrack은 연결된 메타 데이터를 검색하는 두 가지 방법을 제공합니다. 이러한 여러 가지 방법의 필요성을 이해하려면 먼저 핵심 공간의 개념을 이해해야합니다. AV Foundation은 AVMetadataItem 인스턴스의 컬렉션을 필터링 할 수 있도록 관련 키를 그룹화하는 방법으로 키 공간을 사용합니다. 그림 3.6과 같이 모든 자산에는 최소한 메타 데이터가 검색되는 두 개의 키 공간이 있습니다.

<center>
<image src="Resource/06.png" width="50%" height="50%">
</center>

* 공통 키 공간은 지원되는 모든 미디어 유형에 공통적인 키를 정의합니다. 여기에는 제목, 아티스트 및 아트 워크 정보와 같은 공통 항목이 포함됩니다. 이는 지원되는 모든 미디어 형식에 대해 일정 수준의 메타 데이터 정규화를 제공합니다. 공통 키 공간에서 메타 데이터를 검색하려면 저작물 또는 트랙에서 commonMetadata 속성을 요청합니다. 이 속성은 사용 가능한 모든 공통 메타 데이터의 배열을 반환합니다.
* 형식 별 메타 데이터에 액세스하려면 애셋 또는 트랙에서 `metadataForFormat : 메소드`를 호출하면 됩니다. 이 메서드는 메타 데이터 형식을 정의하는 NSString을 사용하고 연결된 모든 메타 데이터가 포함 된 NSArray를 반환합니다. `AVMetadataFormat.h`는 지원하는 다양한 메타 데이터 형식에 대한 문자열 상수를 제공합니다. 특정 메타 데이터 형식 문자열을 하드 코딩하는 대신 리소스 또는 트랙에 `availableMetadataFormats`를 쿼리하여 리소스에 포함 된 모든 메타 데이터 형식을 정의하는 문자열 배열을 반환 할 수 있습니다. 이 결과 배열을 사용하여 모든 형식을 반복하고 각각에 대해 `metadataForFormat :`을 호출 할 수 있습니다. 예를 살펴 보겠습니다.

```Swift
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
```

## Finding Metadata
* 메타 데이터 항목 배열을 가져온 후에는 일반적으로 특정 메타 데이터 값을 찾고자합니다. 특히 유용한 방법 중 하나는 AVMetadataItem에서 제공하는 다양한 편의 메소드를 사용하여 결과 세트를 검색하고 필터링하는 것입니다. 예를 들어 특정 M4A 오디오 파일의 아티스트 및 앨범 메타 데이터를 가져 오는 데 관심이있는 경우 다음과 같이이 데이터를 검색 할 수 있습니다.

```Swift
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
```

* 이 예제는 AVMetadataItem에서 metadataItemsFromArray : withKey : keySpace : 메서드를 사용하여 키와 키 공간 기준에 맞는 항목으로 컬렉션을 필터링합니다. 이 호출의 반환 값은 NSArray이지만 일반적으로 단일 AVMetadataItem 인스턴스를 포함합니다.

## Using AVMetadataItem
* 가장 기본적인 형태의 AVMetadataItem은 키 / 값 쌍의 래퍼입니다. 공통 키 공간에 존재하는 경우 키 또는 commonKey를 요청할 수 있으며 가장 중요한 것은 값입니다. value 속성은 id <NSObject, NSCopying>로 정의되지만 NSString, NSNumber, NSData 또는 경우에 따라 NSDictionary가됩니다. 미리 값 유형을 알고 있으면 AVMetadataItem은 반환 값을 적절하게 입력하기 쉽게하는 stringValue, numberValue 및 dataValue의 세 가지 유형 강제 변환 속성도 제공합니다.
* AVMetadataItem으로 작업 할 때 가장 많이 접하는 문제는 키 속성을 이해하는 것입니다. commonKey는 문자열로 정의되며 AVMetadataFormat.h에 정의 된 키에 대해 평가하기 쉽지만 키 속성은 id <NSObject, NSCopying> 값으로 정의됩니다. 이 유형은 물론 NSString을 보유 할 수 있지만, 거의 그렇지 않습니다. 예를 들어, 다음 코드로 내 라이브러리의 M4A 파일에 포함 된 메타 데이터를 반복하는 경우 예기치 않은 키 값이 표시됩니다.

```Swift
        if let url = URL(string: "") {
            let asset = AVAsset(url: url)
            let metadata = asset.metadata(forFormat: AVMetadataFormatiTunesMetadata)
            
            for item in metadata {
                NSLog("\(item.key, item.value)")
            }
        }
```

* 이 코드를 실행하면 다음과 같은 목록이 생성됩니다.

```
-1452383891: Have A Drink On Me
-1455336876: AC/DC
-1451789708: A. Young - M. Young - B. Johnson
-1453233054: Back In Black
-1453039239: 1980
```

* 이 값으로 Back in Black 앨범의 AC / DC 노래임을 알 수 있지만 분명하지 않은 것은 키 속성에 대해 반환 된 정수 값입니다. 여러분이 보고있는 것은 다양한 키 문자열의 정수 값입니다. 이러한 값을 해석하려면 먼저 해당 값을 문자열로 변환해야합니다. 이것은 자주 수행 할 작업이므로 keyString이라는 AVMetadataItem에 범주 메서드를 추가하면 NSString에 해당하는 항목을 쉽게 검색 할 수 있습니다.

* Listing 3.1에서 이 카테고리 메소드의 구현을 살펴 보자.

Listing 3.1 AVMetadataItem keyString Category Method
```ObjectiveC
#import "AVMetadataItem+THAdditions.h"

@implementation AVMetadataItem (THAdditions)

- (NSString *)keyString {
    if ([self.key isKindOfClass:[NSString class]]) {                        // 1
        return (NSString *)self.key;
    }
    else if ([self.key isKindOfClass:[NSNumber class]]) {

        UInt32 keyValue = [(NSNumber *) self.key unsignedIntValue];         // 2

        // Most, but not all, keys are 4 characters. ID3v2.2 keys are
        // only be 3 characters long. Adjust the length if necessary.

        size_t length = sizeof(UInt32);                                     // 3
        if ((keyValue >> 24) == 0) --length;
        if ((keyValue >> 16) == 0) --length;
        if ((keyValue >> 8) == 0) --length;
        if ((keyValue >> 0) == 0) --length;

        long address = (unsigned long)&keyValue;
        address += (sizeof(UInt32) - length);

        // keys are stored in big-endian format, swap
        keyValue = CFSwapInt32BigToHost(keyValue);                          // 4

        char cstring[length];                                               // 5
        strncpy(cstring, (char *) address, length);
        cstring[length] = '\0';

        // Replace '©' with '@' to match constants in AVMetadataFormat.h
        if (cstring[0] == '\xA9') {                                         // 6
            cstring[0] = '@';
        }

        return [NSString stringWithCString:(char *) cstring                 // 7
                                  encoding:NSUTF8StringEncoding];

    }
    else {
        return @"<<unknown>>";
    }
}

@end
```

1. key 속성이 이미 문자열 인 경우 그대로 반환하십시오. 이것은 흔하지 않은 경우입니다.
2. 부호없는 정수 값으로 키를 요청합니다. 반환되는 값은 곧 추출 할 4 문자 코드를 나타내는 32 비트 빅 엔디안 숫자입니다.
3. 거의 모든 경우에 값은 © gen 또는 TRAK와 같은 4 자리 코드이지만 ID3v2.2를 사용하여 태그 된 MP3 파일의 경우 키 값은 3 자입니다. 길이를 줄여야하는지 결정하기 위해 코드는 각 바이트를 이동시킵니다.
4. 숫자가 빅 엔디 언 형식이기 때문에 CFSwapInt32BigToHost () 함수를 사용하여 호스트 CPU와 일치하도록 바이트 순서를 바꿉니다. 이는 Intel 및 ARM 프로세서 모두에 대한 리틀 엔디안입니다.
5. 문자 배열을 만들고 strncpy 함수를 사용하여이 배열에 문자 바이트를 채 웁니다.
6. 많은 수의 QuickTime 사용자 데이터와 iTunes 키 앞에는 © 문자가 붙습니다. 그러나 AVMetadataFormat.h에 정의 된 키 앞에는 @ 기호가 붙습니다. 키 상수와 문자열 비교를 수행하려면 ©를 @ 문자로 바꿉니 다.
7. 마지막으로 stringWithCString : encoding initializer를 사용하여 문자 배열을 NSString으로 변환합니다.

* 이 범주를 가져오고이 새 메서드를 사용하기 위해 이전 코드 예제를 수정하면 다음과 같이 훨씬 덜 이해하기 어려운 출력이 표시됩니다.

```
@nam: Have A Drink On Me
@ART: AC/DC
@wrt: A. Young - M. Young - B. Johnson
@alb: Back In Black
@day: 1980
```

```
노트
Mac OS X 10.10 및 iOS 8에서는 키와 키 스페이스로 저작물의 메타 데이터를 검색하는 것 외에도 식별자를 사용하여 메타 데이터를 검색하는 추가 방법을 도입했습니다. 식별자는 키와 키 공간을 단일 문자열로 통합하여 Asset의 메타 데이터를 검색하는데 약간 간단한 모델을 제공합니다. 이 장에서는 여러 OS 버전에서 호환 가능하기 때문에 키와 키 스페이스 접근 방식을 사용하지만 Mac OS X 10.10 또는 iOS 8 만 타겟팅하는 경우 식별자 사용을 고려할 수 있습니다.
```
* 이제 AVMetadataItem에 대한 기본적인 이해를 했으므로 MetaManager라는 Mac 메타 데이터 편집기 응용 프로그램을 작성하여이 지식을 실행 해 봅시다.

## Building the MetaManager App
* MetaManager 응용 프로그램은 메타 데이터를 보고 편집 할 수 있는 간단한 인터페이스를 제공합니다 (그림 3.7 참조). 이 기능을 사용하면 AV Foundation에서 지원하는 모든 유형의 메타 데이터를 볼 수 있으며 MP3 파일을 제외한 모든 메타 데이터를 쓸 수 있습니다. 이 응용 프로그램은 메타 데이터 클래스를 사용하는 방법에 대한 좋은 예를 제공하고 프레임 워크를 시작하기 전에 어려움을 겪는 문제를 처리하는 방법을 제공합니다. 사용자 인터페이스는 바로 사용할 준비가되어 있으며 대신 AV Foundation 기반을 구축하는 데 집중할 것입니다. 이 프로젝트의 시작 복사본은 MetaManager_starter라는 3 장 디렉토리에서 찾을 수 있습니다.

<center>
<image src="Resource/07.png" width="50%" height="50%">
</center>

* AV Foundation의 메타 데이터 클래스는 기본 메타 데이터 형식에 대해 특정 수준의 추상화를 제공하지만 다양한 미디어 형식에서 메타 데이터를 균일하게 관리하는 것은 여전히 어려울 수 있습니다. 기본 메타 데이터에 일관된 인터페이스를 제공하기 위해 채택 할 전략은 형식 별 메타 데이터를 정규화 된 키 및 값 집합에 매핑하는 것입니다. 이렇게하면 기본 메타 데이터에 간단하고 일관된 클라이언트 인터페이스가 제공되며 메타 데이터를 단일 클래스로 중앙 집중식으로 관리 할 수있는 논리가 유지됩니다. THMediaItem이라는 구현할 첫 번째 수업을 살펴 보면서 세부 사항을 살펴 봅시다.

### THMediaItem
* THMediaItem은 애플리케이션이 관리하는 미디어 작업을 위한 기본 인터페이스를 제공합니다. 기본 AVAsset 인스턴스에 대한 래퍼를 제공하고 관련 메타 데이터의로드 및 추출을 관리합니다.

class THMediaItem {
    typealias THCompletionHandler = (Bool) -> Void
    
    var fileName = ""
    var fileType = ""
    var metadata: THMetadata = THMetadata()
    var isEditable = true
    
    var url: URL?
    var asset: AVAsset
    var acceptedFormats: [String] = []
    var prepared = true
    
    init(url: URL) {
        asset = AVAsset(url: url)
        fileName = url.lastPathComponent
        fileType = fileTypeForURL(url: url)
        isEditable = !(fileType == AVFileTypeMPEGLayer3)
        acceptedFormats = [
            AVMetadataFormatQuickTimeMetadata,
            AVMetadataFormatiTunesMetadata,
            AVMetadataFormatID3Metadata,
        ]
    }
    
    func fileTypeForURL(url: URL) -> String {
        let ext = (NSString(string: url.lastPathComponent)).pathExtension
        var type = ""
        switch ext {
        case "m4a":
            type = AVFileTypeAppleM4A
        case "m4v":
            type = AVFileTypeAppleM4V
        case "mov":
            type = AVFileTypeQuickTimeMovie
        case "mp3":
            type = AVFileTypeMPEG4
        default:
            type = AVFileTypeMPEGLayer3
        }
        
        return type
    }
    
    func prepareWithCompletionHandler(completionHandler: THCompletionHandler) {
        
    }
    
    func saveWithCompletionHandler(handler: THCompletionHandler) {
        
    }
}

1. `initWithURL : 메서드`에서 클래스의 내부 상태를 설정하고 전달 된 URL을 기반으로 AVAsset의 인스턴스를 만듭니다. 응용 프로그램의 테이블 뷰에 표시되는 각 항목은 이 클래스의 인스턴스입니다.
2. 기본 자산의 파일 유형을 결정합니다. AV Foundation은 파일 형식을 결정하는 몇 가지 고급 방법을 제공하지만 파일 확장명을 기준으로 형식을 결정하면 충분합니다. 응용 프로그램의 저장 기능을 구현할 때 filetype 속성을 사용합니다.
3. 편집 가능한 플래그는 미디어 파일의 유형에 따라 설정됩니다. AV Foundation은 ID3 메타 데이터를 읽을 수는 있지만 기록 할 수는 없으므로 응용 프로그램이 저장 버튼의 활성화 상태를 적절하게 설정할 수 있도록 편집 가능 플래그를 설정합니다.
4. 지원되는 메타 데이터 형식 배열도 설정합니다. 이는 `AVMetadataKeySpaceQuickTimeUserData` 및 `AVMetadataKeySpaceISOUserData` 키 공간에 나타날 수있는 관계없는 중복 값을 제외하기 위해 수행됩니다.

### prepareWithCompletionHandler: 구현

```Swift
    func prepareWithCompletionHandler(completionHandler: @escaping THCompletionHandler) {
        if prepared {
            completionHandler(prepared)
            return
        }
        
        metadata = THMetadata()
        let keys = [
            COMMON_META_KEY,
            AVAILABLE_META_KEY,
        ]
        
        asset.loadValuesAsynchronously(forKeys: keys) {
            let commonStatus = self.asset.statusOfValue(forKey: self.COMMON_META_KEY, error: nil)
            let formatsStatus = self.asset.statusOfValue(forKey: self.AVAILABLE_META_KEY, error: nil)
            
            self.prepared = (commonStatus == .loaded) && (formatsStatus == .loaded)
            if self.prepared {
                for item in self.asset.commonMetadata {
                    self.metadata.addMetadataItem(item: item, key: item.commonKey)
                    
                    for format in self.asset.availableMetadataFormats {
                        if self.acceptedFormats.contains(format) {
                            let items = self.asset.metadata(forFormat: format)
                            for item in items {
                                self.metadata.addMetadataItem(item: item, key: item.commonKey)
                            }
                        }
                    }
                }
                
            }
            completionHandler(self.prepared)
        }
    }
```

1. 사용자가 앱의 테이블뷰에서 미디어 항목을 선택할 때마다 `prepareWithCompletionHandler : 메소드`가 호출됩니다. 이 항목은 한 번만 준비해야하므로 항목이 이미 준비된 경우 완료 블록을 호출하고 복구하십시오.
2. THMetadata의 새 인스턴스를 만듭니다. 곧 개발할이 클래스는 개별 AVMetadataItem 인스턴스에 저장된 값을 관리하는 데 사용됩니다.
3. commonMetadata 및 availableMetadataFormats 등록 정보의 상태를 평가하여 준비된 상태를 판별하십시오. 처리를 계속하려면 두 특성을 모두 로드해야합니다.
4. 공통 키 스페이스에서 리턴 된 모든 AVMetadataItem 인스턴스를 반복하고 각 인스턴스를 THMetadata 인스턴스에 추가하십시오.
5. 자산에 availableMetadataFormats가 있는지 물어보십시오. 그러면 미디어 항목에서 사용할 수있는 형식을 식별하는 문자열 배열이 반환됩니다. 특정 형식이 supportedFormats 컬렉션에 있으면 연관된 AVMetadataItem 인스턴스를 검색하여 내부 메타 데이터 저장소에 추가합니다.
6. 마지막으로 완료 핸들러 블록을 호출하여 사용자 인터페이스가 검색된 메타 데이터 값을 화면에 표시 할 수 있도록하십시오.

* 계속해서 응용 프로그램을 실행하십시오. 아직 메타 데이터를 표시 할 수있는 상태는 아니지만 개별 미디어 항목을 선택하면 키와 값이 콘솔에 인쇄되는 것을 볼 수 있습니다. 이 동작을 확인한 후에는 NSLog 문을 주석으로 처리하거나 완전히 제거 할 수 있습니다.
* THMetadata 클래스로 이동하여 개별 AVMetadataItem 인스턴스에서 반환 된 값으로 작업하는 방법에 대해 자세히 살펴 보겠습니다.

### THMetadata Implementation
* THMetadata는이 애플리케이션에서 대량으로 수행하는 클래스입니다. 관련 메타 데이터 항목에서 값을 추출하고 나중에 사용할 수 있도록 값을 저장합니다. 이 클래스에서는 사용자 인터페이스의 특정 필드에 매핑되는 다양한 키 값을 모두 정규화합니다.

```Swift
let THMetadataKeyName = "name"
let THMetadataKeyArtist = "artist"
let THMetadataKeyAlbumArtist = "albumArtist"
let THMetadataKeyArtwork = "artwork"
let THMetadataKeyAlbum = "album"
let THMetadataKeyYear = "year"
let THMetadataKeyBPM = "bpm"
let THMetadataKeyGrouping = "grouping"
let THMetadataKeyTrackNumber = "trackNumber"
let THMetadataKeyTrackCount = "trackCount"
let THMetadataKeyComposer = "composer"
let THMetadataKeyDiscNumber = "discNumber"
let THMetadataKeyDiscCount = "discCount"
let THMetadataKeyComments = "comments"
let THMetadataKeyGenre = "genre"

class THMetadata {
    var name = ""
    var artist = ""
    var albumArtist = ""
    var album = ""
    var grouping = ""
    var composer = ""
    var comments = ""
    var artwork = NSImage()
    var genre = THGenre()
    
    var year = ""
    var bpm = 0
    var trackNumber = 0
    var trackCount = 0
    var discNumber = 0
    var discCount = 0
    
    var keyMapping: [String: String] = [:]
    var metadata = NSMutableDictionary()
    var converterFactory = THMetadataConverterFactory()
    
    func buildKeyMapping() -> [String: String] {
        return [
            // Name Mapping
            AVMetadataCommonKeyTitle : THMetadataKeyName,
            
            // Artist Mapping
            AVMetadataCommonKeyArtist : THMetadataKeyArtist,
            AVMetadataQuickTimeMetadataKeyProducer : THMetadataKeyArtist,
            
            // Album Artist Mapping
            AVMetadataID3MetadataKeyBand : THMetadataKeyAlbumArtist,
            AVMetadataiTunesMetadataKeyAlbumArtist : THMetadataKeyAlbumArtist,
            "TP2" : THMetadataKeyAlbumArtist,
            
            // Album Mapping
            AVMetadataCommonKeyAlbumName : THMetadataKeyAlbum,
            
            // Artwork Mapping
            AVMetadataCommonKeyArtwork : THMetadataKeyArtwork,
            
            // Year Mapping
            AVMetadataCommonKeyCreationDate : THMetadataKeyYear,
            AVMetadataID3MetadataKeyYear : THMetadataKeyYear,
            "TYE" : THMetadataKeyYear,
            AVMetadataQuickTimeMetadataKeyYear : THMetadataKeyYear,
            AVMetadataID3MetadataKeyRecordingTime : THMetadataKeyYear,
            
            // BPM Mapping
            AVMetadataiTunesMetadataKeyBeatsPerMin : THMetadataKeyBPM,
            AVMetadataID3MetadataKeyBeatsPerMinute : THMetadataKeyBPM,
            "TBP" : THMetadataKeyBPM,
            
            // Grouping Mapping
            AVMetadataiTunesMetadataKeyGrouping : THMetadataKeyGrouping,
            "grp" : THMetadataKeyGrouping,
            AVMetadataCommonKeySubject : THMetadataKeyGrouping,
            
            // Track Number Mapping
            AVMetadataiTunesMetadataKeyTrackNumber : THMetadataKeyTrackNumber,
            AVMetadataID3MetadataKeyTrackNumber : THMetadataKeyTrackNumber,
            "TRK" : THMetadataKeyTrackNumber,
            
            // Composer Mapping
            AVMetadataQuickTimeMetadataKeyDirector : THMetadataKeyComposer,
            AVMetadataiTunesMetadataKeyComposer : THMetadataKeyComposer,
            AVMetadataCommonKeyCreator : THMetadataKeyComposer,
            
            // Disc Number Mapping
            AVMetadataiTunesMetadataKeyDiscNumber : THMetadataKeyDiscNumber,
            AVMetadataID3MetadataKeyPartOfASet : THMetadataKeyDiscNumber,
            "TPA" : THMetadataKeyDiscNumber,
            
            // Comments Mapping
            "ldes" : THMetadataKeyComments,
            AVMetadataCommonKeyDescription : THMetadataKeyComments,
            AVMetadataiTunesMetadataKeyUserComment : THMetadataKeyComments,
            AVMetadataID3MetadataKeyComments : THMetadataKeyComments,
            "COM" : THMetadataKeyComments,
            
            // Genre Mapping
            AVMetadataQuickTimeMetadataKeyGenre : THMetadataKeyGenre,
            AVMetadataiTunesMetadataKeyUserGenre : THMetadataKeyGenre,
            AVMetadataCommonKeyType : THMetadataKeyGenre
        ]
    }
    
    func addMetadataItem(item: AVMetadataItem, key: String?) {
        
    }
}
```

1. 다양한 키 공간 및 형식에서 키를 정규화하려면 형식 별 키에서 정규화 된 키로 매핑을 작성하십시오.
2. NSMutableDictionary를 작성하여 AVMetadataItem 값에서 추출한 표시 값을 저장하십시오. 이 사전에 저장된 값은 화면에 표시된 값입니다.
3. THMetadataConverter의 인스턴스를 제공 할 THMetadataConverterFactory의 인스턴스를 작성하십시오. AVMetadataItem에 저장된 데이터와 화면에 표시된 값 사이의 값을 변환하는 데 사용할 곧바로 작성할 건물 개체가 사용됩니다.

### addMetadataItem 구현

```Swift
    func addMetadataItem(item: AVMetadataItem, key: String) {
        if let normalizedKey = keyMapping[key] as? String {
            let converter = converterFactory.converter(key: normalizedKey)
            let value = converter.displayValueFromMetadataItem(item: item)
            if let dic = value as? NSDictionary {
                for currentKey in dic.allKeys {
                    if let key = currentKey as? String {
                        setValue(dic[key], forKey: key)
                    }
                }
            } else {
                setValue(value, forKey: normalizedKey)
            }
            
            metadata[normalizedKey] = item
        }
    }
```

1.이 메소드에서 가장 먼저 수행하는 작업은이 메소드에 전달 된 키의 정규화 된 키 값을 검색하는 것입니다. 이를 통해 형식 특정 키를 표준화 된 키 값에 맵핑 할 수 있습니다. 정규화 된 키가 반환되면 AVMetadataItem을 처리하게됩니다.
2. 그런 다음 converterFactory에 현재 AVMetadataItem을 처리 할 수있는 THMetadataConverter 객체를 요청합니다. 현재 메타 데이터 항목에 대한 표시 값을 제공하도록 변환기에 요청하십시오. 그러면 표시 값에 적합한 형식으로 값이 추출되고 변환됩니다.
3. 값이 리턴 된 후 그 유형을 평가합니다. 디스크 및 트랙 번호는 특수한 경우이며 값을 추출하기 위해 몇 가지 추가 조작이 필요합니다. 궁극적으로 키 - 값 코딩 메소드 인 setValue : forKey를 사용하여 개별 속성 값을 설정합니다.
4. 마지막으로 나중에 사용할 수 있도록 AVMetadataItem을 메타 데이터 사전에 저장하십시오.

* 지금까지 구현 한 것에 대해 다소 혼란스러울지라도 걱정하지 마십시오. 내가 언급한 변환기 개체를 작성하기 시작하면 조각이 맞아 떨어지게됩니다. 이 객체들을 구현해 보겠습니다.

### Data Converters
* AVMetadataItem으로 작업 할 때 가장 어렵고 혼란스러운 부분 중 하나는 value 속성에 저장된 데이터를 이해하는 것입니다. 기록연도나 분당 비트 수 (BPM)의 경우처럼 값이 아티스트 이름이나 앨범 제목 또는 숫자와 같은 간단한 문자열 일 때 데이터는 이해하기 쉽고 실제 변환이 필요하지 않습니다. 그러나 다소 혼란스럽거나 단순한 암호를 종종 접하게 될 것입니다. 즉, 이러한 값을 표시 가능한 형식으로 변환하기 위해 약간의 노력을 기울여야합니다. 이 변환 논리를 THMetadata 클래스에 직접 넣을 수는 있지만 클래스가 매우 비대해져 유지 관리가 어려울 것입니다. 그 대신, 이 로직을 아래에 표시된 것처럼 THMetadataConverter 프로토콜을 채택한 여러 컨버터 클래스로 분해한다.

```Swift
protocol THMetadataConverter {
    func displayValueFromMetadataItem(item: AVMetadataItem) -> Any?
    func metadataItemFromDisplayValue(value: Any, withMetadataItem item: AVMetadataItem) -> AVMetadataItem
}
```

### THDefaultMetadataConverter
```Swift
class THDefaultMetadataConverter: THMetadataConverter {
    func displayValueFromMetadataItem(item: AVMetadataItem) -> Any? {
        return item.value
    }
    
    func metadataItemFromDisplayValue(value: Any, withMetadataItem item: AVMetadataItem) -> AVMetadataItem {
        let metadataItem: AVMutableMetadataItem = item.mutableCopy() as! AVMutableMetadataItem
        metadataItem.value = value as? NSCopying & NSObjectProtocol
        return metadataItem
    }
}
```

* AVMetadataItem 값을 표시 값으로 변환 할 때 항목의 value 속성을 반환합니다. value 속성이 단순한 문자열 또는 숫자 값인 메타 데이터 항목에는 충분합니다. 표시 값을 AVMetadataItem으로 다시 변환 할 때 원래 AVMetadataItem의 변경 가능한 복사본을 만들어서 시작합니다.이 복사본은 AVMutableMetadataItem을 반환합니다. 이 클래스는 새 메타 데이터를 만들거나 기존 메타 데이터를 수정할 때 사용하는 AVMetadataItem의 변경 가능한 하위 클래스입니다. 부모와 동일한 기본 인터페이스를 갖지만 읽기 전용 속성 중 몇 가지를 읽기 / 쓰기로 다시 정의합니다. 원래 AVMetadataItem을 복사하여 AVMutableMetadataItem을 작성하면 모든 중요한 속성이 원래 항목의 값으로 설정된 새 인스턴스가 제공되어 value 속성을 메소드로 전달 된 값으로 설정하게됩니다.

* 이것은 단순한 변환기 였지만 곧 살펴 보 겠지만 더 복잡한 시나리오가 몇 가지 있습니다. 메타 데이터 항목의 아트웍을 변환하는 방법을 살펴 보겠습니다.

### Converting Artwork
* 앨범 표지 및 영화 포스터와 같은 미디어 아트웍 메타 데이터는 몇 가지 다른 형태로 반환됩니다. 궁극적으로 아트웍의 바이트는 NSData 인스턴스에 저장되지만 NSData를 찾으려면 때로는 추가적인 노력이 필요합니다. 아래는 THArtworkMetadataConverter에 대한 구현을 제공한다.

```Swift
class THArtworkMetadataConverter: THMetadataConverter {
    func displayValueFromMetadataItem(item: AVMetadataItem) -> Any? {
        var image: NSImage?
        if let data = item.value as? Data {
            image = NSImage(data: data)
        } else if let dic = item.value as? NSDictionary {
            if let data = dic["data"] as? Data {
                image = NSImage(data: data)
            }
        }
        
        return image
    }
    
    func metadataItemFromDisplayValue(value: Any, withMetadataItem item: AVMetadataItem) -> AVMetadataItem {
        let metadataItem: AVMutableMetadataItem = item.mutableCopy() as! AVMutableMetadataItem
        if let image = value as? NSImage {
            metadataItem.value = image.tiffRepresentation as (NSCopying & NSObjectProtocol)?
        }
        
        return metadataItem
    }
}
```

1. AVMetadataItem이 NSData 유형의 값을 리턴하면,이 오브젝트에 저장된 바이트로부터 새 NSImage를 작성합니다. NSImage와 UIImage 모두 초기화자를 편리하게 제공하므로 NSData에서 직접 이미지 인스턴스를 만들 수 있습니다.
2. 선택한 미디어 항목이 MP3 인 경우 이미지 바이트를 얻기 위해 조금 더 깊게 파고 들어야합니다. 이 경우 value 속성은 NSDictionary이므로 적절하게 값을 캐스팅 한 다음 "data"키를 검색하면 이미지 바이트가 포함 된 NSData가 반환됩니다.
3. 표시 값을 AVMutableMetadataItem의 인스턴스로 변환하는 구현은 AV Foundation이 ID3 메타 데이터를 쓸 수 없기 때문에 상당히 간단합니다. 값이 NSData로 저장되고 NSImage에 TIFFRepresentation을 요청한다고 가정 할 수 있습니다. 이미지 데이터를 PNG 또는 JPG로 저장하려면 NSBitmapImageRep, UIImage 함수 또는 Quartz 프레임 워크를 사용하여 원하는대로이 데이터를 변환 할 수 있습니다.

### Converting Comments

```Swift
class THCommentMetadataConverter: THMetadataConverter {
    func displayValueFromMetadataItem(item: AVMetadataItem) -> Any? {
        var value: String?
        
        if item.value is String {
            value = item.stringValue
        } else if let dic = item.value as? NSDictionary {
            if dic["identifier"] is String {
                if let text = dic["text"] as? String {
                    value = text
                }
            }
        }
        
        return value
    }
    
    func metadataItemFromDisplayValue(value: Any, withMetadataItem item: AVMetadataItem) -> AVMetadataItem {
        let metadataItem: AVMutableMetadataItem = item.mutableCopy() as! AVMutableMetadataItem
        metadataItem.value = value as? NSCopying & NSObjectProtocol
        return metadataItem
    }
}
```

1. 항목의 value 속성이 NSString이면 stringValue 속성을 요청할 수 있습니다. 이는 MPEG-4 및 QuickTime 미디어 모두에 해당됩니다.
2. MP3에 대한 주석은 ID3 COMM 프레임 (ID3v2.2로 작업하는 경우 COM)을 정의하는 NSDictionary에 저장됩니다. 이 프레임은 다양한 가치를위한 포괄적 인 것입니다. 예를 들어, iTunes는 오디오 정규화 및 gapless 재생 설정과 같은 항목을이 프레임에 저장합니다. 즉, ID3 메타 데이터를 요청할 때 여러 COMM 프레임을 수신 할 수 있습니다. 실제 코멘트 문자열을 포함하는 특정 COMM 프레임은 빈 문자열 식별자가있는 프레임에 포함됩니다. 원하는 항목을 찾으면 "텍스트"키를 요청하여 설명을 검색합니다.
3. 표시 값을 AVMetadataItem으로 다시 변환하는 것은 ID3 데이터와 경쟁 할 필요가 없으므로 쉽습니다. 따라서 원래 AVMetadataItem을 복사하고 value 속성을 메서드에 전달 된 값으로 설정할 수 있습니다.

### Converting Track Data
* 오디오 트랙에는 일반적으로 트랙 모음 내 노래의 서수 위치를 나타내는 정보가 들어 있습니다 (예 : 4/12). MP3 파일은이 데이터를 이해하기 쉬운 방식으로 저장하지만 M4A는 좀 더 복잡하며 표현할 수있는 값을 생성하기 위해 약간의 마사지가 필요합니다. 아래는 THTrackMetadataConverter 클래스의 구현을 보여준다.

```Swift
class THTrackMetadataConverter: THMetadataConverter {
    func displayValueFromMetadataItem(item: AVMetadataItem) -> Any? {
        var number: UInt16 = 0
        var count: UInt16 = 0
        
        if item.value is String {
            let components = item.stringValue?.components(separatedBy: "/") ?? []
            number = UInt16(components[0]) ?? 0
            count = UInt16(components[1]) ?? 0
        } else if item.value is Data {
            if let data = item.dataValue {
                if data.count == 8 {
                    let values = data.withUnsafeBytes {
                        [UInt16](UnsafeBufferPointer(start: $0, count: data.count))
                    }
                    if values[1] > 0 {
                        number = CFSwapInt16BigToHost(values[1])
                    }
                    if values[2] > 0 {
                        count = CFSwapInt16BigToHost(values[2])
                    }
                }
            }
        }
        
        let dict = NSMutableDictionary()
        dict.setObject(number, forKey: THMetadataKeyTrackNumber as NSCopying)
        dict.setObject(count, forKey: THMetadataKeyTrackCount as NSCopying)
        
        return dict
    }
    
    func metadataItemFromDisplayValue(value: Any, withMetadataItem item: AVMetadataItem) -> AVMetadataItem {
        let metadataItem: AVMutableMetadataItem = item.mutableCopy() as! AVMutableMetadataItem
        let trackData = value as? NSDictionary
        let trackNumber = trackData?[THMetadataKeyTrackNumber] as? UInt16
        let trackCount = trackData?[THMetadataKeyTrackCount] as? UInt16
        
        var values: [UInt16] = [
            0,
            0,
            0,
            0,
        ]
        
        if let number = trackNumber {
            values[1] = CFSwapInt16HostToBig(number)
        }
        
        if let count = trackCount {
            values[2] = CFSwapInt16HostToBig(count)
        }
        
        let length = MemoryLayout.size(ofValue: values)
        metadataItem.value = Data(bytes: values, count: length) as NSCopying & NSObjectProtocol
        
        return metadataItem
    }
}
```

1. MP3 트랙 정보는 "xx / xx"형식으로 문자열로 반환됩니다. 열 곡의 앨범 중 여덟 번째 트랙으로 작업하는 경우 "8/10"이라는 문자열 값을 받게됩니다. 이 경우 NSString의 `componentsSeparatedByString : 메서드`를 사용하여 값을 분할하여 개별 값을 가져 와서 해당 정수 값으로 변환하고 값을 NSNumber의 인스턴스로 채 웁니다.
2. M4A 파일의 경우 값이 조금 더 이상합니다. 메타 데이터 항목의 값을 콘솔에 인쇄하면 <00000008 000a0000>과 같은 값을 가진 NSData라는 것을 알 수 있습니다. 이것은 네 개의 16 비트, 빅 엔디안 배열의 16 진수 표현입니다. 이 배열의 두 번째 요소와 세 번째 요소는 각각 트랙 번호와 트랙 수를 포함합니다.
3. 트랙 번호가 0이 아니면 값을 가져 와서 CFSwapInt16BigToHost () 함수를 사용하여 리틀 엔디 언 형식으로 변환 한 다음 NSNumber로 값을 입력하여 엔디안 스왑을 수행합니다.
4. 트랙 카운트 값이 0이 아닌 경우 마찬가지로 값을 가져와 바이트에 대한 엔디안 스왑을 수행하고 결과 값을 NSNumber로 래핑합니다.
5. 캡처 된 번호와 카운트 값을 NSDictionary에 저장하여 호출자에게 반환합니다. 각 값을 검사하여 nil인지 확인하고, 그렇다면 NSNull 인스턴스로 대체해야합니다.
6. 표시 값을 AVMetadataItem에서 요구하는 형식으로 다시 변환한다는 것은 기본적으로 displayValueFromMetadataItem : 메소드에서 해당 값을 추출 할 때 수행 한 단계의 역을 수행한다는 것을 의미합니다. 4 개의 uint16_t 값 배열을 만들어 트랙 번호와 카운트 값을 저장합니다.
7. 유효한 트랙 번호가 있으면 바이트를 빅 엔디안 형식으로 다시 스왑하고 배열의 두 번째 위치에 저장합니다.
8. 유효한 트랙 수를 가지고 있다면, 다시 바이트를 빅 엔디안 형식으로 스왑하고 배열의 세 번째 위치에 저장하십시오.
9. 마지막으로 NSData의 인스턴스에 values 배열을 래핑하고 메타 데이터 항목의 값으로 설정합니다.
* 트랙 수 정보를 사용하여 작업하는 방법을 이해하는 것은 간단하지 않지만 지금은 비밀을 알고 있습니다!

### Converting Disc Data
* 디스크 카운트 정보는 노래가 속한 CD가 n 개의 디스크 중 n 번째 디스크임을 나타 내기 위해 사용됩니다. 일반적으로이 값은 1의 1이며 단일 디스크를 나타내지 만 트랙 디스크가 상자 세트 나 컬렉션의 일부일 경우 다른 값을 갖습니다. 예를 들어, Led Zeppelin의 Complete Studio Recordings가있는 경우 (그리고 정말로해야합니다), Led Zeppelin IV 디스크의 값은 4/10입니다. 좋은 소식은 이미이 데이터를 검색하는 방법을 알고 있습니다. 이전 섹션의 트랙 번호 및 트랙 수 데이터와 거의 같은 방식으로 저장되기 때문에이 클래스의 구현은 매우 익숙 할 것입니다. 아래는 THDiscMetadataConverter 클래스의 구현을 보여준다.

```Swift
class THDiscMetadataConverter: THMetadataConverter {
    func displayValueFromMetadataItem(item: AVMetadataItem) -> Any? {
        var number: UInt16 = 0
        var count: UInt16 = 0
        
        if item.value is String {
            let components = item.stringValue?.components(separatedBy: "/") ?? []
            number = UInt16(components[0]) ?? 0
            count = UInt16(components[1]) ?? 0
        } else if item.value is Data {
            if let data = item.dataValue {
                if data.count == 6 {
                    let values = data.withUnsafeBytes {
                        [UInt16](UnsafeBufferPointer(start: $0, count: data.count))
                    }
                    if values[1] > 0 {
                        number = CFSwapInt16BigToHost(values[1])
                    }
                    if values[2] > 0 {
                        count = CFSwapInt16BigToHost(values[2])
                    }
                }
            }
        }
        
        let dict = NSMutableDictionary()
        dict.setObject(number, forKey: THMetadataKeyTrackNumber as NSCopying)
        dict.setObject(count, forKey: THMetadataKeyTrackCount as NSCopying)
        
        return dict
    }
    
    func metadataItemFromDisplayValue(value: Any, withMetadataItem item: AVMetadataItem) -> AVMetadataItem {
        let metadataItem: AVMutableMetadataItem = item.mutableCopy() as! AVMutableMetadataItem
        let trackData = value as? NSDictionary
        let trackNumber = trackData?[THMetadataKeyTrackNumber] as? UInt16
        let trackCount = trackData?[THMetadataKeyTrackCount] as? UInt16
        
        var values: [UInt16] = [
            0,
            0,
            0,
            0,
            ]
        
        if let number = trackNumber {
            values[1] = CFSwapInt16HostToBig(number)
        }
        
        if let count = trackCount {
            values[2] = CFSwapInt16HostToBig(count)
        }
        
        let length = MemoryLayout.size(ofValue: values)
        metadataItem.value = Data(bytes: values, count: length) as NSCopying & NSObjectProtocol
        
        return metadataItem
    }
}
```

1. MP3 디스크 정보는 "xx / xx"형식의 문자열로 반환됩니다. 열 개의 디스크 콜렉션 중 네 번째 디스크의 노래로 작업하는 경우 "4/10"이라는 문자열 값을 받게됩니다. 이 경우 NSString의 componentsSeparatedByString : 메서드를 사용하여 값을 분할하여 개별 값을 가져 와서 해당 정수 값으로 변환하고 값을 NSNumber의 인스턴스로 채 웁니다.
2. iTunes M4A 파일의 디스크 정보는 NSData로 저장됩니다. NSData에는 세 개의 16 비트 빅 엔디안 번호가 들어 있습니다. 이 배열의 두 번째 요소와 세 번째 요소에는 디스크 번호와 디스크 카운트 값이 각각 들어 있습니다.
3. 디스크 번호가 0이 아니면 값을 가져 와서 CFSwapInt16BigToHost () 함수를 사용하여 리틀 엔디 언으로 변환 한 다음 값을 NSNumber로 입력합니다.
4. 디스크 카운트 값이 0이 아니면 값을 가져와 바이트에 엔디안 스왑을 수행하고 결과 값을 NSNumber로 래핑합니다.
5. 캡처 된 번호와 카운트 값을 NSDictionary에 저장하여 호출자에게 반환합니다. 각 값을 검사하여 nil인지 확인하고, 그렇다면 NSNull 인스턴스로 대체해야합니다.
6. 표시 값을 AVMetadataItem에서 요구하는 형식으로 다시 변환한다는 것은 기본적으로 displayValueFromMetadataItem : 메소드에서 해당 값을 추출 할 때 수행 한 단계의 역을 수행한다는 것을 의미합니다. 디스크 번호와 디스크 카운트 값을 저장하기 위해 uint16_t 값 3 개를 생성합니다.
7. 유효한 디스크 번호가 있으면 바이트를 빅 엔디안 형식으로 다시 스왑하고 배열의 두 번째 위치에 값을 저장합니다.
8. 유효한 디스크 개수가있는 경우 바이트를 빅 엔디안 형식으로 다시 스왑하고 배열의 세 번째 위치에 값을 저장합니다.
9. 마지막으로 NSData의 인스턴스에 values 배열을 래핑하고 메타 데이터 항목의 값으로 설정합니다.

### Converting Genre Data
* 장르 데이터로 작업하는 것은 어려울 수 있습니다. 데이터 자체가 본질적으로 복잡하지는 않지만 장르가 취할 수있는 형식이 너무 많습니다. 미리 정의 된 장르, 사용자 장르, 장르 ID, 음악 장르, 영화 장르 등이 있습니다. 또 다른 문제는 장르 정보가 단일 파일 유형의 경우에도 여러 가지 방법으로 저장 될 수 있다는 것입니다. 몇 가지 기본 사항에 대해 이야기 해 봅시다.
* 디지털 오디오를 카탈로그화 하는데 사용된 표준 장르는 원래 MP3 세계에서 나왔습니다. ID3 사양은 80개의 기본장르와 WinAmp 확장으로 간주되는 46개의 장르를 총 126개의 장르로 정의합니다. 다양한 도구에서 지원되는 기타 일반적으로 사용되는 여러 장르를 찾을 수 있지만 형식 사양의 일부는 아닙니다.
* 아이튠즈는 지배적 인 MP3가 어느 시점에 있었는지를 감안할 때, 자체 장르의 음악 장르를 만드는 대신 ID3 장르를 채택했지만 사소한 편향이 있었다. iTunes 음악 장르는 ID3에 상응하는 것보다 하나 큰 식별자를 가지고 있습니다. 예를 들어, 표 3.1은 ID3 세트의 처음 다섯 장르와 동등한 iTunes 값을 보여줍니다.

<center>
<image src="Resource/08.png" width="50%" height="50%">
</center>

* iTunes는 ID3 세트의 미리 정의 된 음악 장르를 채택하지만 TV 쇼, 영화 및 오디오북용 장르를 자체적으로 정의합니다. Apple 장르 ID 부록에서 전체 iTunes 장르 목록을 찾을 수 있습니다.

[Genre IDs Appendix](http://www.apple.com/itunes/affiliates/resources/documentation/genre-mapping.html)

* 장르 데이터 작업을 단순화하고 타이핑을 절약하기 위해 샘플 앱에는 표준 음악 장르와 TV 프로그램에 사용 된 장르를 정의하는 THGenre라는 클래스가 포함되어 있습니다. 이 장르는 응용 프로그램의 오디오 및 비디오 내용에 사용됩니다.
* 장르에 대한 세부 작업을 시작하겠습니다. 아래는 THGenreMetadataConverter 클래스의 구현을 보여준다.

```Swift
class THGenreMetadataConverter: THMetadataConverter {
    func displayValueFromMetadataItem(item: AVMetadataItem) -> Any? {
        var genre = THGenre()
        
        if item.value is String {
            if item.keySpace == AVMetadataKeySpaceID3 {
                if let genreIndex = item.numberValue?.uintValue {
                    genre = THGenre.id3Genre(with: genreIndex)
                } else {
                    genre = THGenre.id3Genre(withName: item.stringValue ?? "")
                }
            } else {
                genre = THGenre.videoGenre(withName: item.stringValue ?? "")
            }
        } else if item.value is Data {
            if let data = item.dataValue {
                if data.count == 2 {
                    let values = data.withUnsafeBytes {
                        [UInt16](UnsafeBufferPointer(start: $0, count: data.count))
                    }
                    let genreIndex = CFSwapInt16BigToHost(values[0]) 
                    genre = THGenre.iTunesGenre(with: UInt(genreIndex))
                }
            }
        }
        
        return genre
    }
    
    func metadataItemFromDisplayValue(value: Any, withMetadataItem item: AVMetadataItem) -> AVMetadataItem {
        let metadataItem: AVMutableMetadataItem = item.mutableCopy() as! AVMutableMetadataItem
        let genre = value as? THGenre
        if item.value is String {
            metadataItem.value = genre?.name as (NSCopying & NSObjectProtocol)?
        } else if item.value is Data {
            if let data = item.dataValue {
                if data.count == 2 {
                    let value = CFSwapInt16HostToBig(genre?.index ?? 0 + 1)
                    let length = MemoryLayout.size(ofValue: value)
                    metadataItem.value = Data(bytes: value, count: length)
                }
            }
        }
        
        return metadataItem
    }
}
```

1. 몇 가지 형식은 장르 데이터를 NSString으로 저장합니다. 때로는 이 문자열이 실제 장르 이름이고 때로는 미리 정의 된 장르 목록에 대한 색인입니다.
2. ID3 키 공간에서 메타 데이터 항목을 가져 와서 ID3v2.4로 작업 할 때 그 값을 NSNumber로 강제 변환 할 수 있다면 해당 값을 부호없는 정수 값으로 가져 와서 해당 인덱스를 사용하여 적절한 THGenre 인스턴스를 찾으십시오.
3. ID3의 다른 변종은 장르를 재즈, 록, 컨트리 등과 같은 실제 이름으로 저장합니다. 값이 장르 이름이면 해당 이름을 사용하여 해당 THGenre 인스턴스를 찾습니다.
4. NSString으로 저장된 다른 모든 장르의 경우 장르를 실제 장르 이름으로 저장하는 QuickTime 동영상 또는 MPEG-4 비디오 파일로 작업한다는 가정을합니다. THGenre 클래스에서 적절한 비디오 장르를 찾아 봅니다.
5. 사전 정의 된 장르 중 하나를 사용할 때 iTunes M4A 오디오는 장르를 NSData에 저장된 16 비트 빅 엔디안 번호로 반환합니다. 값을 가져와 바이트를 리틀 엔디안 형식으로 바꾼 다음 iTunesGenreWithIndex : 메서드를 호출하여 적절한 장르 인스턴스를 반환합니다.
6. 원래 AVMetadataItem이 해당 값을 문자열로 저장 한 경우 AVMetadataItem 형식으로 다시 변환 할 때 들어오는 값을 항목의 value 속성으로 설정하기 만하면됩니다.
7. 원래 AVMetadataItem이 NSData로 해당 값을 저장 한 경우 해당 바이트를 빅 엔디안 형식으로 바꾼 다음 결과 값을 NSData로 래핑하여 표시 값을 적절한 형식으로 다시 변환합니다. 또한 THGenre의 인덱스 속성은 0부터 시작하므로 iTunes 등가물로 다시 조정하려면 값에 1을 더하십시오.

* 축하합니다. 변환기 작성이 완료되었습니다. 이제 응용 프로그램을 실행하고 목록에서 항목을 선택하고 사용자 인터페이스에 표시되는 값을 볼 수 있습니다. 나머지 기능 중 하나는 사용자가 변경 사항을 저장하는 기능을 추가하는 것입니다. THMetadata 클래스로 다시 전환하여 구현을 마무리하겠습니다.

### Finalizing THMetadata
* THMetadata에서 구현할 수있는 나머지 메서드 중 하나는 해당 metadataItem 메서드입니다. 이 메서드는 현재 저장되어있는 모든 표시 값을 가져 와서 방금 만든 변환기 클래스를 사용하여 AVMetadataItem 형식으로 다시 변환합니다. 아래에서는 이 메소드의 구현을 제공한다.

```Swift
class THMetadata: NSObject {
    var name = ""
    var artist = ""
    var albumArtist = ""
    var album = ""
    var grouping = ""
    var composer = ""
    var comments = ""
    var artwork = NSImage()
    var genre: THGenre?
    
    var year = ""
    var bpm = 0
    var trackNumber = 0
    var trackCount = 0
    var discNumber = 0
    var discCount = 0
    
    var keyMapping = NSDictionary()
    var metadata = NSMutableDictionary()
    var converterFactory = THMetadataConverterFactory()
    
    func buildKeyMapping() -> NSDictionary {
        return [
            // Name Mapping
            AVMetadataCommonKeyTitle : THMetadataKeyName,
            
            // Artist Mapping
            AVMetadataCommonKeyArtist : THMetadataKeyArtist,
            AVMetadataQuickTimeMetadataKeyProducer : THMetadataKeyArtist,
            
            // Album Artist Mapping
            AVMetadataID3MetadataKeyBand : THMetadataKeyAlbumArtist,
            AVMetadataiTunesMetadataKeyAlbumArtist : THMetadataKeyAlbumArtist,
            "TP2" : THMetadataKeyAlbumArtist,
            
            // Album Mapping
            AVMetadataCommonKeyAlbumName : THMetadataKeyAlbum,
            
            // Artwork Mapping
            AVMetadataCommonKeyArtwork : THMetadataKeyArtwork,
            
            // Year Mapping
            AVMetadataCommonKeyCreationDate : THMetadataKeyYear,
            AVMetadataID3MetadataKeyYear : THMetadataKeyYear,
            "TYE" : THMetadataKeyYear,
            AVMetadataQuickTimeMetadataKeyYear : THMetadataKeyYear,
            AVMetadataID3MetadataKeyRecordingTime : THMetadataKeyYear,
            
            // BPM Mapping
            AVMetadataiTunesMetadataKeyBeatsPerMin : THMetadataKeyBPM,
            AVMetadataID3MetadataKeyBeatsPerMinute : THMetadataKeyBPM,
            "TBP" : THMetadataKeyBPM,
            
            // Grouping Mapping
            AVMetadataiTunesMetadataKeyGrouping : THMetadataKeyGrouping,
            "grp" : THMetadataKeyGrouping,
            AVMetadataCommonKeySubject : THMetadataKeyGrouping,
            
            // Track Number Mapping
            AVMetadataiTunesMetadataKeyTrackNumber : THMetadataKeyTrackNumber,
            AVMetadataID3MetadataKeyTrackNumber : THMetadataKeyTrackNumber,
            "TRK" : THMetadataKeyTrackNumber,
            
            // Composer Mapping
            AVMetadataQuickTimeMetadataKeyDirector : THMetadataKeyComposer,
            AVMetadataiTunesMetadataKeyComposer : THMetadataKeyComposer,
            AVMetadataCommonKeyCreator : THMetadataKeyComposer,
            
            // Disc Number Mapping
            AVMetadataiTunesMetadataKeyDiscNumber : THMetadataKeyDiscNumber,
            AVMetadataID3MetadataKeyPartOfASet : THMetadataKeyDiscNumber,
            "TPA" : THMetadataKeyDiscNumber,
            
            // Comments Mapping
            "ldes" : THMetadataKeyComments,
            AVMetadataCommonKeyDescription : THMetadataKeyComments,
            AVMetadataiTunesMetadataKeyUserComment : THMetadataKeyComments,
            AVMetadataID3MetadataKeyComments : THMetadataKeyComments,
            "COM" : THMetadataKeyComments,
            
            // Genre Mapping
            AVMetadataQuickTimeMetadataKeyGenre : THMetadataKeyGenre,
            AVMetadataiTunesMetadataKeyUserGenre : THMetadataKeyGenre,
            AVMetadataCommonKeyType : THMetadataKeyGenre
        ]
    }
    
    func addMetadataItem(item: AVMetadataItem, key: String) {
        if let normalizedKey = keyMapping[key] as? String {
            let converter = converterFactory.converter(key: normalizedKey)
            let value = converter.displayValueFromMetadataItem(item: item)
            if let dic = value as? NSDictionary {
                for currentKey in dic.allKeys {
                    if let key = currentKey as? String {
                        setValue(dic[key], forKey: key)
                    }
                }
            } else {
                setValue(value, forKey: normalizedKey)
            }
            
            metadata[normalizedKey] = item
        }
    }
    
    func metadataItems() -> NSArray {
        let items = NSMutableArray()
        
        addMetadataItemForNumber(trackNumber, count: trackCount, numberKey: THMetadataKeyTrackNumber, countKey: THMetadataKeyTrackCount, toArray: items)
        addMetadataItemForNumber(discNumber, count: discCount, numberKey: THMetadataKeyDiscNumber, countKey: THMetadataKeyDiscCount, toArray: items)
        
        let metaDict = metadata.mutableCopy() as! NSMutableDictionary
        metaDict.removeObject(forKey: THMetadataKeyTrackNumber)
        metaDict.removeObject(forKey: THMetadataKeyDiscNumber)
        
        for key in metaDict.allKeys {
            if let k = key as? String {
                let converter = converterFactory.converter(key: k)
                
                if let value = self.value(forKey: k), let metadataItem = metaDict[key] as? AVMetadataItem {
                    let item = converter.metadataItemFromDisplayValue(value: value, withMetadataItem: metadataItem)
                    items.add(item)
                }
            }
        }
        
        return items
    }
    
    func addMetadataItemForNumber(_ number: Int, count: Int, numberKey: String, countKey: String, toArray items: NSMutableArray) {
        let converter = converterFactory.converter(key: numberKey)
        let data = [
            numberKey: number,
            countKey: count
            ]
        
        if let sourceItem = metadata[numberKey] as? AVMetadataItem{
            let item = converter.metadataItemFromDisplayValue(value: data, withMetadataItem: sourceItem)
            items.add(item)
        }
    }
}
```

1. NSMutableArray의 인스턴스를 만들어이 메서드가 만들 메타 데이터 항목의 컬렉션을 저장합니다.
2. 트랙 번호 / 카운트와 디스크 번호 / 카운트 모두는 그 값을 AVMetadataItem 형식으로 다시 변환하기 위해 몇 가지 추가 처리가 필요하므로 # 3에서와 같이 논리가 별도의 방법으로 분해됩니다.
3. NSDictionary에서 숫자와 카운트 쌍을 랩핑하고 원본 AVMetadataItem을 가져 와서 변환기로 전달합니다.
4. 변환기에서 메타 데이터 항목을 검색하고 유효한 메타 데이터 인스턴스를 반환하면 항목 배열에 추가합니다.
5. 다양한 표시 값을 포함하는 내부 메타 데이터 사전 복사본을 만들고 이미 처리되었으므로 Array에서 트랙 및 디스크 번호 키를 제거합니다. 나머지 키와 값을 반복하여 적절한 메타 데이터 항목을 만듭니다.
6. 키 / 값 코딩 메소드 valueForKey :를 사용하여 현재 키와 연관된 값을 찾으십시오.
7. 마지막으로 현재 변환기에서 AVMetadataItem 인스턴스를 검색하고 유효한 인스턴스가 반환되면 항목 컬렉션에 추가합니다.

* 이제 THMetadata가 완료되었으며 거의 MetaManager 응용 프로그램을 완료했습니다. 남아있는 유일한 것은 THMediaItem의 saveWithCompletionHandler : 메소드 구현을 제공하는 것입니다. 이제하자.

### Saving Metadata
* THMetadata 클래스와 관련 변환기 객체를 구축 했으므로 이제 메타 데이터를 읽고 사용자의 입력을 AVMetadataItem 인스턴스로 다시 변환 할 수 있습니다. 그러나 한 가지 중요한 질문이 남아 있습니다. AVAsset은 변경 불가능한 클래스이므로 이러한 메타 데이터 변경을 어떻게 적용합니까? 대답은 AVAsset을 직접 수정하지 않고 AVAssetExportSession이라는 클래스를 사용하여 메타 데이터 변경 사항과 함께 자산의 새 복사본을 내보내는 것입니다. 이 동작을 구현하는 방법에 대해 자세히 설명하기 전에 AVAssetExportSession을 구성하고 사용하는 방법에 대해 간단히 살펴 보겠습니다.

### Using AVAssetExportSession
* AVAssetExportSession은 내보내기 사전 설정에 따라 AVAsset의 내용을 코드 변환 한 다음 내 보낸 자산을 디스크에 씁니다. 한 형식에서 다른 형식으로 변환하고, 저작물의 내용을 다듬고, 저작물의 오디오 및 비디오 동작을 수정하고, 가장 중요한 순간에 새로운 메타 데이터를 작성할 수있게 해주는 많은 기능을 제공합니다.
* 소스 자산과 내보내기 사전 설정을 제공하여 AVAssetExportSession의 인스턴스를 만듭니다. 내보내기 사전 설정은 내보낸 콘텐트의 품질 및 크기 조정과 같은 기능을 결정하는데 사용됩니다. 내보내기 세션을 만든 후에는 내보낸 콘텐트가 쓰여지는 곳을 선언하는 outputURL과 작성 될 출력 형식을 나타내는 outputFileType을 지정해야합니다. 마지막으로 exportAsynchronouslyWithCompletionHandler : 메서드를 호출하여 내보내기 프로세스를 시작합니다.
추상적인 측면에서 AVAssetExportSession에 대해 이야기하는 대신 saveWithCompletetionHandler : 메서드에서 작동하도록하십시오. 아래는 이 메소드의 구현을 제공한다.

```Swift
    func saveWithCompletionHandler(handler: @escaping THCompletionHandler) {
        guard let asset = self.asset else {
            return
        }
        
        let presetName = AVAssetExportPresetPassthrough
        let session = AVAssetExportSession(asset: asset, presetName: presetName)
        let outputURL = tempURL
        session?.outputURL = outputURL
        session?.outputFileType = fileType
        session?.metadata = metadata.metadataItems() as? [AVMetadataItem]
        
        session?.exportAsynchronously {
            let status = session?.status
            let success = status == .completed
            if success {
                if let sourceURL = self.url {
                    let manager = FileManager.default
                    try? manager.removeItem(at: sourceURL)
                    try? manager.moveItem(at: outputURL, to: sourceURL)
                    self.reset()
                }
            }
            
            DispatchQueue.main.async {
                handler(success)
            }
        }
    }
    
    var tempURL: URL {
        let tempDir = NSTemporaryDirectory()
        let ext = NSString(string: url?.lastPathComponent ?? "").pathExtension
        let tempName = "temp.\(ext)"
        let tempPath = tempDir + "/\(tempName)"
        return URL(fileURLWithPath: tempPath)
    }
    
    func reset() {
        prepared = false
        if let url = self.url {
            asset = AVAsset(url: url)
        }
    }
```

1. AVAssetExportPresetPassthrough 사전 설정을 사용하여 AVAssetExportSession을 만드는 것으로 시작하십시오. AVAssetExportSession은 여러 가지 사전 설정을 사용할 수 있지만이 사전 설정을 사용하면 미디어를 다시 인코딩하지 않고도 새 메타 데이터를 쓸 수 있습니다. "passthrough"내보내기는 실제 미디어 컨텐츠를 트랜스 코딩하는 경우 소요되는 시간보다 훨씬 짧은 시간 안에 발생합니다.
2. 디스크에 쓸 임시 파일의 URL을 만듭니다. 이 URL은 현재 URL 속성 값을 기반으로하며 파일 이름 끝에 temp라는 이름이 붙습니다.
3. THMetadata 인스턴스에 해당 metadataItems를 요청하십시오. 이것은 사용자 인터페이스 값의 상태를 포함하는 AVMutableMetadataItem 인스턴스의 배열을 반환합니다.
4. 내보내기 세션의 완료 핸들러에서 먼저 내보내기의 상태를 확인하려고합니다. 내보내기 상태가 AVAssetExportSessionCompleted 인 경우 내보내기가 성공했다는 것을 나타내며 기존 자산을 제거하고 새로 내 보낸 버전으로 바꿉니다. 이 예제에서는이 파일 작업에 대한 오류 처리와 함께 약간 빠르며 느슨한 연주를하고 있습니다. 프로덕션 응용 프로그램에서이를보다 강력하게 처리해야합니다.
5. 마지막으로 미디어 항목의 준비 상태를 재설정하고 기본 자산을 다시 초기화하는 개인 재설정 메서드를 호출합니다.
* 그리고 이것으로 MetaManager 앱이 완성되었습니다! 이제 응용 프로그램을 실행하고 기존 메타 데이터 항목을 변경하고 이러한 변경 사항을 다시 디스크에 저장할 수 있습니다.

```
노트
AVAssetExportPresetPassthrough 사전 설정은 특정 시나리오에서 유용 할 수 있으며 데모 응용 프로그램의 목적에 적합합니다. 그러나 제한 사항이 있음을 유의하십시오. MPEG-4 또는 QuickTime 컨테이너에서 기존 메타 데이터를 수정할 수 있지만 새 메타 데이터를 추가 할 수는 없습니다. 새 메타 데이터를 추가하는 유일한 방법은 트랜스 코딩 사전 설정 중 하나를 사용하는 것입니다. 또한 ID3 태그를 수정하는 데 사용할 수 없습니다. 프레임 워크는 MP3 데이터 작성을 지원하지 않기 때문에 데모 응용 프로그램의 MP3 파일은 읽기 전용이었습니다.
```

## Summary
* 이 장에서는 많은 부분을 다뤘습니다! 긴 장 이었지만 틀림없이 가장 중요한 것 중 하나는 여기에서 다룰 주제에 대한 단계를 설정하는 것입니다. 당신은 AVAsset과 AVAssetTrack을 소개 받았고 AVAsynchronousKeyValueLoading 프로토콜을 사용하여 속성을 비동기 적으로 검색하는 중요성을 배웠습니다. AVMetadataItem 및 AVMutableMetadataItem 클래스를 기반으로 구축 된 AV Foundation의 메타 데이터 기능에 대해 심도있는 다이빙을 수행하고 보유한 데이터를 조작하는 심오한 암흑의 비밀을 배웠습니다. 마지막으로, AVAssetExportSession에 대한 첫 번째 소개를 얻었고 MetaManager 응용 프로그램에서이를 잘 사용하도록했습니다. 이 클래스를 볼 수있는 것은 이번이 마지막 일이 아니며, 계속 진행하면서 다른면을 검사하게됩니다.
이제 AV Foundation 여행을 준비 할 준비가되었습니다!