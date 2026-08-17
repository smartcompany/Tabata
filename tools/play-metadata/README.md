# Google Play — 모두의 타바타

Google Play Console API용 출시 노트(What’s New) 업로드.  
문구 원본은 `../asc-metadata/whats-new.json` 입니다.

Play 로케일: `ko-KR`, `en-US`, `ja-JP`, `zh-CN`

## 사용

```bash
cd client/tools/play-metadata

./update-whats-new.sh --dry-run
./update-whats-new.sh
./update-whats-new.sh --version-code 30 --track production
```

`versionCode`를 생략하면 `pubspec.yaml`의 `+` 빌드 번호를 씁니다.  
해당 트랙에 **draft** 릴리스가 있어야 합니다.

## 1회 설정

```bash
cp .env.example .env
# PLAY_SERVICE_ACCOUNT_JSON / PLAY_PACKAGE_NAME 확인
npm install
```

서비스 계정 JSON은 AIFindProducts와 같은 Play Publisher 키를 씁니다.  
Play Console → 사용자 및 권한에서 그 서비스 계정에 **모두의 타바타** (`com.smartcompany.tabata`) 앱 권한을 초대해야 합니다.
