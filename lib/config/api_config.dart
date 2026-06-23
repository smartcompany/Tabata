abstract final class ApiConfig {
  static const profileApiBaseUrl = String.fromEnvironment(
    'PROFILE_API_BASE_URL',
    defaultValue: 'https://tabata-server.vercel.app',
  );
}
