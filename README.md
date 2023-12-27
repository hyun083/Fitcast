<a href="https://apps.apple.com/us/app/fitcast-%EA%B8%B0%EC%98%A8%EB%B3%84-%EC%98%B7%EC%B0%A8%EB%A6%BC/id6474090221" target="_blank">
<p align="center"><img src="https://github.com/hyun083/Fitcast/assets/58415560/b832fb83-6d9d-41c3-b9e6-96ef8e88b139" width="30%"></p>
  
<a>

# WeatherFit
계절간 기온과 일교차가 큰 대한민국의 환경을 체감하며 만든 서비스입니다.

외출때마다 기온별 옷차림을 확인하는 번거로움을 해결하기 위해 제작하였습니다.

# 기능
- 사용자의 위치기반 일기예보를 제공합니다.
  - 사용자 위치 기반의 시간단위 일기예보를 확인할 수 있습니다.
- 외출시간의 평균기온을 제공합니다.
  - 사용자가 지정한 외출시간의 일기에보를 파악하고 평균기온을 확인할 수 있습니다.
- 기온별 알맞은 옷차림을 제공합니다.
  - 총 8구간의 기온에 알맞은 옷차림 정보를 제공합니다.
  - 사용자의 외출시간에 맞는 옷차림을 바로 확인할 수 있습니다.
- 실시간 기온에 맞는 옷차림 정보를 위젯으로 제공합니다.
  - 급하게 외출할 경우 위젯을 통해 간편하게 적절한 옷차림을 확인 할 수 있습니다.

# 앱 구조
![MVVM](https://github.com/hyun083/Fitcast/assets/58415560/53932c11-e480-416d-8a31-84791de307aa)

SwiftUI를 사용해보고 싶어 이에 알맞은 MVVM 디자인 패턴을 적용했습니다.

# 스크린샷

|![fitcast image light](https://github.com/hyun083/Fitcast/assets/58415560/ac71b568-69cf-4130-9672-c0755224c4bf)|![fitcast image dark](https://github.com/hyun083/Fitcast/assets/58415560/cd22e80d-5e18-472e-a243-f6335e49410f)|
|:---:|:---:|
|라이트와 다크모드 두가지 배경화면을 제공합니다.|하단의 pickerView를 통해 사용자의 외출시간을 지정합니다. <br/> 해당 시간은 UserDefaults로 설정되어 마지막 값이 항상 저장됩니다.|
|![fitcast image widget light](https://github.com/hyun083/Fitcast/assets/58415560/c9c7575c-8936-425c-b6a0-0582901dc1cd)|![fitcast image widget dark](https://github.com/hyun083/Fitcast/assets/58415560/eb02d889-377e-44cd-ad85-dc04d7d84694)|
|위젯도 마찬가지로 두가지 배경화면을 제공합니다. <br/> 라이트모드와 다크모드의 여부로 화면이 변경됩니다.|사용자의 실시간 위치를 기반으로 현재 기온이 표시되며, 이에 알맞은 옷차림을 보여줍니다.|
