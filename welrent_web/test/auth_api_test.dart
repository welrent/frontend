import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:welrent_web/config/app_config.dart';
import 'package:welrent_web/services/auth_repository.dart';
import 'package:welrent_web/services/welrent_api.dart';

void main() {
  test(
    'login, registration, and reset explain a missing auth config',
    () async {
      final auth = AuthRepository(config: const AppConfig());

      final login = await auth.signIn(email: 'a@b.co', password: 'secret');
      expect(login.error, AuthRepository.loginMissing);

      final register = await auth.register(
        name: 'Ada',
        email: 'a@b.co',
        password: 'longpassword',
        confirm: 'longpassword',
      );
      expect(register.error, AuthRepository.registerMissing);
      expect(
        await auth.sendPasswordReset('a@b.co'),
        AuthRepository.resetMissing,
      );
    },
  );

  test('registration rejects mismatched and short passwords', () async {
    final auth = AuthRepository(
      config: const AppConfig(firebaseApiKey: 'public-web-key'),
    );
    expect(
      (await auth.register(
        name: 'Ada',
        email: 'a@b.co',
        password: 'abcdefgh',
        confirm: 'abcdefgi',
      )).error,
      'Passwords do not match.',
    );
    expect(
      (await auth.register(
        name: 'Ada',
        email: 'a@b.co',
        password: 'short',
        confirm: 'short',
      )).error,
      'Password must be at least 8 characters.',
    );
  });

  test('PHP login stores the returned token', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/api/auth/login');
      return http.Response(
        jsonEncode({
          'token': 'session-token',
          'user': {'id': '42', 'email': 'driver@welrent.com'},
        }),
        200,
      );
    });
    final auth = AuthRepository(
      config: const AppConfig(apiBaseUrl: 'https://api.example.test'),
      client: client,
    );

    final result = await auth.signIn(
      email: 'driver@welrent.com',
      password: 'secret',
    );
    expect(result.ok, isTrue);
    expect(result.user!.id, '42');
    expect(result.user!.token, 'session-token');
    expect(result.user!.provider, 'api');
  });

  test('cars fall back to the demo fleet when the API is offline', () async {
    final client = MockClient((request) async => http.Response('nope', 500));
    final api = WelrentApi(
      config: const AppConfig(apiBaseUrl: 'https://api.example.test'),
      client: client,
    );
    final cars = await api.fetchCars();
    expect(cars.map((car) => car.slug), containsAll(['an-RS6', 'an-EVO']));
  });

  test('createRental refuses to pretend a booking reached the API', () async {
    final api = WelrentApi(config: const AppConfig());
    expect(
      api.createRental(
        uid: '1',
        carName: 'an RS6',
        carImage: '',
        startDate: '2026-12-16',
        endDate: '2026-12-17',
        days: 1,
        price: 120,
        location: 'Monaco',
      ),
      throwsA(isA<ApiException>()),
    );
  });
}
