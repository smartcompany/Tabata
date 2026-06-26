/// 카카오 개발자 콘솔(https://developers.kakao.com) 앱 키.
/// iOS 번들 `com.smartcompany.tabata` / Android `com.smartcompany.tabata` 가
/// 플랫폼에 등록되어 있어야 합니다.
abstract final class KakaoConfig {
  static const nativeAppKey = String.fromEnvironment(
    'KAKAO_NATIVE_APP_KEY',
    defaultValue: '03b6a4ae680153f2ef7077cd02b70d90',
  );

  static const javaScriptAppKey = String.fromEnvironment(
    'KAKAO_JAVASCRIPT_APP_KEY',
    defaultValue: 'f136e1c4a8c75f8d6419eb98fbc5217c',
  );

  static const restApiKey = String.fromEnvironment(
    'KAKAO_REST_API_KEY',
    defaultValue: '10410045c87eac78fa87c98651db059b',
  );

  static bool get isConfigured =>
      nativeAppKey.isNotEmpty && javaScriptAppKey.isNotEmpty;

  /// 카카오 개발자 콘솔에 등록된 네이티브 앱 스킴 (kakao + 네이티브 앱 키)
  static String get nativeAppScheme => 'kakao$nativeAppKey';
}
