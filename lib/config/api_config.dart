abstract final class ApiConfig {
  static const profileApiBaseUrl = String.fromEnvironment(
    'PROFILE_API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
}
