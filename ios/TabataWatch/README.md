# TabataWatch (Apple Watch 컴패니언)

폰이 타이머를 주도하고, 워치는 구간·남은 시간·일시정지/종료·실시간 심박을 표시합니다.

## 준비 사항

1. **watchOS 플랫폼 설치 (필수)** — Runner에 Watch 앱이 포함되어 있어, watchOS가 없으면 iPhone 빌드도 실패합니다.
   - Xcode → Settings → Platforms(Components) → **watchOS** 설치
   - 또는 터미널: `xcodebuild -downloadPlatform watchOS`
2. **워치 개발자 모드 ON (개발 빌드 설치에 필수)**
   - Apple Watch → **설정 → 개인정보 보호 및 보안 → 개발자 모드** → 켬 → 재시작 → 다시 켬
   - 메뉴가 없으면: Xcode에서 워치를 destination으로 한 번 Run 시도한 뒤 워치를 재부팅하면 항목이 생깁니다.
3. `ios/Runner.xcworkspace`를 Xcode로 열기
4. 서명: Runner와 동일한 Team (`NTCK5U8AWD`). Bundle ID: `com.smartcompany.tabata.watchkitapp`
5. Watch 타깃 HealthKit capability 확인

## 실기기에 처음 설치하는 방법 (권장 순서)

iPhone Watch 앱의 「사용 가능한 앱」만으로는 개발 서명이 막히는 경우가 많습니다.

1. 워치 **잠금 해제**, 폰·맥 가까이, **개발자 모드 ON**
2. Xcode → scheme **Runner** → destination **iPhone** → ▶ Run (폰 앱 설치)
3. Xcode → scheme **TabataWatch** → destination **김용건의 Apple Watch** → ▶ Run  
   - 이때 Xcode가 워치 UDID를 등록하고 watchOS용 프로비저닝을 만듭니다.
4. 워치 홈에서 **Tabata** 실행  
   - idle: **내 루틴** 목록 → 탭하면 해당 루틴 전체 시작  
   - 또는 폰에서 운동 시작 후 타이머·심박 표시

## 워치에서 시작

1. 워치 idle의 **내 루틴**에서 루틴을 탭하면, 폰 앱이 꺼져 있어도 **백그라운드로 깨어나** 해당 루틴 전체 운동을 시작합니다 (폰 화면이 자동으로 켜지지는 않습니다).
2. 폰을 나중에 열면 운동 화면이 이미 열려 있습니다.
3. 목록이 비어 있으면 「iPhone에서 루틴을 추가하세요」가 표시됩니다. 목록 동기화를 위해 폰 앱을 한 번은 실행해 두세요.

## 설치가 안 되거나 스피너만 돌 때

1. 워치 **개발자 모드**가 켜져 있는지 확인 (가장 흔한 원인)
2. iPhone에서 앱 삭제 → `flutter run` 또는 Xcode Runner로 재설치
3. Xcode **TabataWatch** → 워치 destination으로 직접 Run
4. 워치 저장 공간 / 폰·워치 거리 / 워치 잠금 상태 확인

## 동작

- iPhone에서 운동 시작 → Watch에 타이머 UI 표시
- Watch 일시정지 / 재개 / 종료 → 폰 타이머 제어
- 심박은 Watch의 `HKWorkoutSession`으로 수집 (Health에 중복 운동 기록은 저장하지 않음)
