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
- 사용자가 직접 원하는 지역 정보를 검색합니다.
  - 검색한 지역은 리스트로 저장되어 제공됩니다.
- 위젯을 통해 실시간 기온에 맞는 옷차림 정보를 제공합니다.
  - 위젯을 통해 간편하게 적절한 옷차림을 확인 할 수 있습니다.

# 앱 구조
![MVVM-Architecture](https://github.com/hyun083/Fitcast/assets/58415560/2c2e1127-0345-44c9-ac03-1d24e3712eea)

SwiftUI에 알맞은 MVVM 패턴을 통해 뷰와 뷰모델간 3대1의 관계를 설정하였습니다.

# file hierarchy

![MVVM-file hierarchy](https://github.com/hyun083/Fitcast/assets/58415560/dd886d6c-73f3-48a0-8663-05aebadbc876)

프로젝트의 디렉토리 구조는 다음과 같습니다.

# 스크린샷

|![fitcast image light](https://github.com/hyun083/Fitcast/assets/58415560/ac71b568-69cf-4130-9672-c0755224c4bf)|![fitcast image dark](https://github.com/hyun083/Fitcast/assets/58415560/cd22e80d-5e18-472e-a243-f6335e49410f)|![fitcast image widget light](https://github.com/hyun083/Fitcast/assets/58415560/c9c7575c-8936-425c-b6a0-0582901dc1cd)|![fitcast image widget dark](https://github.com/hyun083/Fitcast/assets/58415560/eb02d889-377e-44cd-ad85-dc04d7d84694)|
|:---:|:---:|:---:|:---:|
|라이트와 다크모드 두가지 배경화면을 제공합니다.|하단의 pickerView를 통해 사용자의 외출시간을 지정합니다. <br/> 해당 시간은 UserDefaults로 설정되어 마지막 값이 항상 저장됩니다.|위젯도 마찬가지로 두가지 배경화면을 제공합니다. <br/> 라이트모드와 다크모드의 여부로 화면이 변경됩니다.|사용자의 실시간 위치를 기반으로 현재 기온이 표시되며, 이에 알맞은 옷차림을 보여줍니다.|

|![view image](https://github.com/hyun083/Fitcast/assets/58415560/bcd78c3e-540d-462c-b812-3d001c18b4d5)|
|:---:|
|앱 실행시 사용자는 ContentView를 마주하게 되며, 사용자의 조작에 따라 SearchView, ListView로 전환할 수 있습니다.|

|![searchView -> contentView](https://github.com/hyun083/Fitcast/assets/58415560/8b86992b-5035-4f80-8d72-97ff910de870)|![listView -> contentView](https://github.com/hyun083/Fitcast/assets/58415560/73f13205-b989-4c8c-bfb0-9897e77a9247)|
|:---:|:---:|
|SearchView에서는 주소 기반 장소 검색 기능을 제공하며, 항목을 누르게 되면 contentView로 전환되어 정보 확인이 가능합니다.|listView에서는 사용자가 searchView에서 선택했던 항목들을 확인 할 수 있으며 항목을 선택하게되면 contentView로 전환되어 정보를 확인 할 수 있습니다.|

|![locationSelect](https://github.com/user-attachments/assets/d35b0fab-6391-410f-adf7-9f8322149411)|![widget -> contentView](https://github.com/hyun083/Fitcast/assets/58415560/68c89007-d4af-4eac-bddf-1918ee5ceca2)
|:---:|:---:|
|위젯을 롱탭하면 편집 모드로 전환 할 수 있으며, 리스트 뷰에서 볼 수 있는 저장된 장소 목록을 통해 위젯이 표시할 지역을 선택할 수 있습니다.|위젯을 선택 시 위젯에서 보여주고 있는 지역의 정보를 contentView에 표시하여 앱 실행 최초화면으로 시작합니다.|

