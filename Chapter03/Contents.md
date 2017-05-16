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