import 'dart:convert';

import 'package:flutter/services.dart';

class AppConfig {
  const AppConfig({
    this.apiBaseUrl = '',
    this.actBaseUrl = 'https://act.welrent.com',
    this.firebaseApiKey = '',
    this.firebaseProjectId = '',
    this.firebaseStorageBucket = '',
  });

  final String apiBaseUrl;
  final String actBaseUrl;
  final String firebaseApiKey;
  final String firebaseProjectId;
  final String firebaseStorageBucket;

  bool get hasApi => apiBaseUrl.trim().isNotEmpty;
  bool get hasFirebase => firebaseApiKey.trim().isNotEmpty;

  String get normalizedApiBase => apiBaseUrl.replaceAll(RegExp(r'/+$'), '');
  String get normalizedActBase => actBaseUrl.replaceAll(RegExp(r'/+$'), '');

  String actUrl([String path = '/']) {
    if (path.isEmpty || path == '/') return normalizedActBase;
    final suffix = path.startsWith('/') ? path : '/$path';
    return '$normalizedActBase$suffix';
  }

  static Future<AppConfig> load() async {
    var config = const AppConfig();
    try {
      final raw = await rootBundle.loadString('assets/config.json');
      final json = jsonDecode(raw);
      if (json is Map<String, dynamic>) {
        config = AppConfig(
          apiBaseUrl: '${json['apiBaseUrl'] ?? ''}',
          actBaseUrl: '${json['actBaseUrl'] ?? 'https://act.welrent.com'}',
          firebaseApiKey: '${json['firebaseApiKey'] ?? ''}',
          firebaseProjectId: '${json['firebaseProjectId'] ?? ''}',
          firebaseStorageBucket: '${json['firebaseStorageBucket'] ?? ''}',
        );
      }
    } catch (_) {
      config = const AppConfig();
    }

    const api = String.fromEnvironment('API_BASE_URL');
    const act = String.fromEnvironment('ACT_BASE_URL');
    const firebaseKey = String.fromEnvironment('FIREBASE_API_KEY');
    const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
    const bucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

    return AppConfig(
      apiBaseUrl: api.isNotEmpty ? api : config.apiBaseUrl,
      actBaseUrl: act.isNotEmpty ? act : config.actBaseUrl,
      firebaseApiKey: firebaseKey.isNotEmpty
          ? firebaseKey
          : config.firebaseApiKey,
      firebaseProjectId: projectId.isNotEmpty
          ? projectId
          : config.firebaseProjectId,
      firebaseStorageBucket: bucket.isNotEmpty
          ? bucket
          : config.firebaseStorageBucket,
    );
  }
}
