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