/// Configuration for connecting to the Ras Hotel Next.js backend API.
class ApiConfig {
  ApiConfig._();

  /// Default API base URL. Override at build time via:
  ///   --dart-define=API_BASE_URL=http://10.0.2.2:3000   (Android emulator → host localhost)
  ///   --dart-define=API_BASE_URL=http://192.168.x.x:3000 (LAN / real device)
  ///   --dart-define=API_BASE_URL=https://your-domain.com (production)
  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static String _activeBaseUrl = _defaultBaseUrl;

  /// Returns the current active base URL without trailing slash.
  static String get baseUrl => _normalizeUrl(_activeBaseUrl);

  /// Allows dynamically updating the base URL at runtime (e.g. settings or tests).
  static void setBaseUrl(String newUrl) {
    if (newUrl.trim().isNotEmpty) {
      _activeBaseUrl = newUrl.trim();
    }
  }

  /// Resets to the compile-time default base URL.
  static void resetToDefault() {
    _activeBaseUrl = _defaultBaseUrl;
  }

  /// Default request timeout duration.
  static const Duration timeout = Duration(seconds: 15);

  // API Endpoints
  static const String healthPath = '/api/health';
  static const String roomsPath = '/api/rooms';
  static const String availabilityPath = '/api/availability';
  static const String pricingPath = '/api/pricing';
  static const String bookingsPath = '/api/bookings';

  /// Helper to build a complete Uri for an endpoint path and optional query parameters.
  static Uri buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final base = baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final fullUrl = '$base$normalizedPath';
    final uri = Uri.parse(fullUrl);

    if (queryParameters != null && queryParameters.isNotEmpty) {
      final cleanParams = <String, String>{};
      queryParameters.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          cleanParams[key] = value.toString();
        }
      });
      return uri.replace(queryParameters: cleanParams);
    }

    return uri;
  }

  static String _normalizeUrl(String url) {
    var trimmed = url.trim();
    while (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
