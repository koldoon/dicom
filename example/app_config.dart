abstract class AppConfig {
  String get baseUrl;
}

class DevelopmentAppConfig implements AppConfig {
  @override
  String get baseUrl => 'https://dev-backend-domain.dev';
}
