import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/models.dart';

class AuthRepository {
  AuthRepository({required this.config, http.Client? client})
    : _client = client ?? http.Client();

  final AppConfig config;
  final http.Client _client;

  static const loginMissing =
      'Auth is not configured. Add Firebase env keys to enable login.';
  static const registerMissing =
      'Auth is not configured. Add Firebase env keys to enable registration.';
  static const resetMissing =
      'Auth is not configured. Add Firebase env keys to enable password reset.';

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    if (config.hasFirebase) {
      return _firebaseSignIn(email: email, password: password);
    }
    if (config.hasApi) {
      return _apiSignIn(email: email, password: password);
    }
    return const AuthResult(error: loginMissing);
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String confirm,
  }) async {
    if (password != confirm) {
      return const AuthResult(error: 'Passwords do not match.');
    }
    if (password.length < 8) {
      return const AuthResult(error: 'Password must be at least 8 characters.');
    }
    if (config.hasFirebase) {
      return _firebaseRegister(name: name, email: email, password: password);
    }
    if (config.hasApi) {
      final signedIn = await _apiSignIn(email: email, password: password);
      if (!signedIn.ok || signedIn.user == null) return signedIn;
      return AuthResult(
        user: signedIn.user!.copyWith(displayName: name.trim()),
      );
    }
    return const AuthResult(error: registerMissing);
  }

  Future<String?> sendPasswordReset(String email) async {
    if (!config.hasFirebase) return resetMissing;
    try {
      final response = await _client.post(
        _firebaseUri('accounts:sendOobCode'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'requestType': 'PASSWORD_RESET', 'email': email}),
      );
      if (response.statusCode == 200) return null;
      final message = _firebaseMessage(response.body);
      if (message.contains('EMAIL_NOT_FOUND')) {
        return 'No account found with this email address.';
      }
      return 'Failed to send reset email. Please try again.';
    } catch (_) {
      return 'Failed to send reset email. Please try again.';
    }
  }

  Future<void> updateDisplayName(SessionUser user) async {
    if (!config.hasFirebase || user.token == null || user.token!.isEmpty) {
      return;
    }
    await _client.post(
      _firebaseUri('accounts:update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'idToken': user.token,
        'displayName': user.displayName,
        'returnSecureToken': true,
      }),
    );
  }

  Future<void> saveBio(SessionUser user) async {
    if (!config.hasFirebase ||
        config.firebaseProjectId.isEmpty ||
        user.token == null ||
        user.token!.isEmpty) {
      return;
    }
    final url = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/${config.firebaseProjectId}'
      '/databases/(default)/documents/users/${Uri.encodeComponent(user.id)}'
      '?updateMask.fieldPaths=bio',
    );
    await _client.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${user.token}',
      },
      body: jsonEncode({
        'fields': {
          'bio': {'stringValue': user.bio},
        },
      }),
    );
  }

  Future<AuthResult> _firebaseSignIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        _firebaseUri('accounts:signInWithPassword'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      if (response.statusCode == 200) {
        return AuthResult(user: _userFromFirebase(response.body));
      }
      return AuthResult(error: _loginError(_firebaseMessage(response.body)));
    } catch (_) {
      return const AuthResult(error: 'Something went wrong. Please try again.');
    }
  }

  Future<AuthResult> _firebaseRegister({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        _firebaseUri('accounts:signUp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      if (response.statusCode != 200) {
        final message = _firebaseMessage(response.body);
        if (message.contains('EMAIL_EXISTS')) {
          return const AuthResult(
            error: 'An account with this email already exists.',
          );
        }
        return const AuthResult(
          error: 'Registration failed. Please try again.',
        );
      }
      final user = _userFromFirebase(response.body)
          .copyWith(displayName: name.trim());
      await updateDisplayName(user);
      return AuthResult(user: user);
    } catch (_) {
      return const AuthResult(error: 'Registration failed. Please try again.');
    }
  }

  Future<AuthResult> _apiSignIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${config.normalizedApiBase}/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode != 200) {
        return const AuthResult(error: 'Invalid email or password.');
      }
      final data = jsonDecode(response.body);
      if (data is! Map) {
        return const AuthResult(
          error: 'Something went wrong. Please try again.',
        );
      }
      final map = Map<String, dynamic>.from(data);
      final userJson = map['user'];
      final userMap = userJson is Map
          ? Map<String, dynamic>.from(userJson)
          : <String, dynamic>{};
      return AuthResult(
        user: SessionUser(
          id: '${userMap['id'] ?? email}',
          email: '${userMap['email'] ?? email}',
          token: map['token'] as String?,
          provider: 'api',
        ),
      );
    } catch (_) {
      return const AuthResult(error: 'Something went wrong. Please try again.');
    }
  }

  Uri _firebaseUri(String method) {
    return Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/$method?key=${config.firebaseApiKey}',
    );
  }

  SessionUser _userFromFirebase(String body) {
    final data = jsonDecode(body);
    final map = data is Map
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{};
    return SessionUser(
      id: '${map['localId'] ?? ''}',
      email: '${map['email'] ?? ''}',
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      token: map['idToken'] as String?,
      refreshToken: map['refreshToken'] as String?,
      provider: 'firebase',
    );
  }

  String _firebaseMessage(String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map && data['error'] is Map) {
        return '${(data['error'] as Map)['message'] ?? ''}';
      }
    } catch (_) {
      return body;
    }
    return body;
  }

  String _loginError(String message) {
    if (message.contains('EMAIL_NOT_FOUND') ||
        message.contains('INVALID_PASSWORD') ||
        message.contains('INVALID_LOGIN_CREDENTIALS') ||
        message.contains('invalid-credential')) {
      return 'Invalid email or password.';
    }
    return 'Something went wrong. Please try again.';
  }
}
