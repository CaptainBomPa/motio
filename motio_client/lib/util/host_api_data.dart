class HostApiData {
  // static const String _host = '10.0.1.214';
  // static const String _host = '10.0.1.203';
  static const String _host = 'fmroz.me';

  static const String baseCoreApiUrl = 'https://core.$_host/v1.0/api/core';
  static const String baseCoreApiWsUrl = 'ws://core.$_host/v1.0/api/core';
  static const String baseAuthApiUrl = 'https://auth.$_host/v1.0/api/auth';
  static const String baseNotificationApiUrl = 'http://notification.$_host/v1.0/api/notification';
}
