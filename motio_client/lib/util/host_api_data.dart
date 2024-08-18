class HostApiData {
  // UNCOMMENT PART DEPENDS ON DEPLOY MODE

  // DEVELOPMENT SETTINGS
  // static const String _host = '10.0.1.214';
  // static const String _host = '10.0.1.203';
  // static const String baseCoreApiUrl = 'http://$_host:8080/v1.0/api/core';
  // static const String baseCoreApiWsUrl = 'ws://$_host:8080/v1.0/api/core';
  // static const String baseAuthApiUrl = 'http://$_host:8070/v1.0/api/auth';
  // static const String baseNotificationApiUrl = 'http://$_host:8050/v1.0/api/notification';

  // PRODUCTION SETTINGS
  static const String _host = 'fmroz.me';
  static const String baseCoreApiUrl = 'https://core.$_host/v1.0/api/core';
  static const String baseCoreApiWsUrl = 'ws://core.$_host/v1.0/api/core';
  static const String baseAuthApiUrl = 'https://auth.$_host/v1.0/api/auth';
  static const String baseNotificationApiUrl = 'http://notification.$_host/v1.0/api/notification';
}
