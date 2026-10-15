import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class LocalStore {
  LocalStore(this.prefs);

  final SharedPreferences prefs;

  static const _sessionKey = 'welrent.session';
  static const _bookingsKey = 'welrent.localBookings';
  static const _languageKey = 'welrent.language';

  SessionUser? readSession() {
    final raw = prefs.getString(_sessionKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final data = jsonDecode(raw);
      if (data is Map) {
        return SessionUser.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> writeSession(SessionUser? user) async {
    if (user == null) {
      await prefs.remove(_sessionKey);
      return;
    }
    await prefs.setString(_sessionKey, jsonEncode(user.toJson()));
  }

  List<Booking> readBookings() {
    final raw = prefs.getString(_bookingsKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final data = jsonDecode(raw);
      if (data is! List) return const [];
      return data
          .whereType<Map>()
          .map((item) => Booking.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> writeBookings(List<Booking> bookings) async {
    await prefs.setString(
      _bookingsKey,
      jsonEncode(bookings.map((item) => item.toJson()).toList()),
    );
  }

  String readLanguage() => prefs.getString(_languageKey) ?? 'EN';

  Future<void> writeLanguage(String code) =>
      prefs.setString(_languageKey, code);
}
