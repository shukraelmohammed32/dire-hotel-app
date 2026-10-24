class HealthResponse {
  const HealthResponse({
    required this.ok,
    required this.service,
    required this.database,
  });

  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    return HealthResponse(
      ok: json['ok'] as bool? ?? false,
      service: json['service'] as String? ?? 'unknown',
      database: json['database'] as String? ?? 'unknown',
    );
  }

  final bool ok;
  final String service;
  final String database;

  bool get isDatabaseOk => database.toLowerCase() == 'ok';

  Map<String, dynamic> toJson() => {
        'ok': ok,
        'service': service,
        'database': database,
      };
}
