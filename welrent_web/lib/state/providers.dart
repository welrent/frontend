import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../data/catalog.dart';
import '../models/models.dart';
import '../services/auth_repository.dart';
import '../services/local_store.dart';
import '../services/welrent_api.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden at startup.');
});

final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('AppConfig must be overridden at startup.');
});

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final apiProvider = Provider<WelrentApi>((ref) {
  return WelrentApi(
    config: ref.watch(appConfigProvider),
    client: ref.watch(httpClientProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    config: ref.watch(appConfigProvider),
    client: ref.watch(httpClientProvider),
  );
});

final localStoreProvider = Provider<LocalStore>((ref) {
  return LocalStore(ref.watch(sharedPreferencesProvider));
});

final headerSearchFocusProvider = Provider<FocusNode>((ref) {
  final node = FocusNode(debugLabel: 'header-search');
  ref.onDispose(node.dispose);
  return node;
});

final shellScrolledProvider = StateProvider<bool>((ref) => false);

final languageProvider = StateNotifierProvider<LanguageController, String>((
  ref,
) {
  return LanguageController(ref.watch(localStoreProvider));
});

class LanguageController extends StateNotifier<String> {
  LanguageController(this._store) : super(_store.readLanguage());

  final LocalStore _store;

  Future<void> select(String code) async {
    state = code;
    await _store.writeLanguage(code);
  }
}

enum AuthStatus { loading, ready }

class AuthState {
  const AuthState({required this.status, this.user});

  const AuthState.loading() : this(status: AuthStatus.loading);
  const AuthState.ready(SessionUser? user)
    : this(status: AuthStatus.ready, user: user);

  final AuthStatus status;
  final SessionUser? user;
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future<void>.microtask(restore);
    return const AuthState.loading();
  }

  LocalStore get _store => ref.read(localStoreProvider);
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> restore() async {
    state = AuthState.ready(_store.readSession());
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _repo.signIn(email: email.trim(), password: password);
    if (result.user == null) {
      return result.error ?? 'Something went wrong. Please try again.';
    }
    final existing = _store.readSession();
    final user = result.user!.copyWith(
      bio: existing != null && existing.email == result.user!.email
          ? existing.bio
          : result.user!.bio,
      photoUrl:
          result.user!.photoUrl ??
          (existing != null && existing.email == result.user!.email
              ? existing.photoUrl
              : null),
    );
    await _store.writeSession(user);
    state = AuthState.ready(user);
    return null;
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String confirm,
  }) async {
    final result = await _repo.register(
      name: name,
      email: email.trim(),
      password: password,
      confirm: confirm,
    );
    if (result.user == null) {
      return result.error ?? 'Registration failed. Please try again.';
    }
    await _store.writeSession(result.user);
    state = AuthState.ready(result.user);
    return null;
  }

  Future<String?> sendReset(String email) {
    return _repo.sendPasswordReset(email.trim());
  }

  Future<void> updateName(String name) async {
    final user = state.user;
    if (user == null) return;
    final next = user.copyWith(displayName: name.trim());
    await _repo.updateDisplayName(next);
    await _store.writeSession(next);
    state = AuthState.ready(next);
  }

  Future<void> updateBio(String bio) async {
    final user = state.user;
    if (user == null) return;
    final next = user.copyWith(bio: bio);
    try {
      await _repo.saveBio(next);
    } catch (_) {
      // Local bio remains available when Firestore is not reachable.
    }
    await _store.writeSession(next);
    state = AuthState.ready(next);
  }

  Future<void> updatePhoto(String photoUrl) async {
    final user = state.user;
    if (user == null) return;
    final next = user.copyWith(photoUrl: photoUrl);
    await _store.writeSession(next);
    state = AuthState.ready(next);
  }

  Future<void> signOut() async {
    await _store.writeSession(null);
    state = const AuthState.ready(null);
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

final catalogProvider = FutureProvider<Catalog>((ref) {
  return ref.watch(apiProvider).fetchCatalog();
});

class BookingController extends Notifier<List<Booking>> {
  @override
  List<Booking> build() {
    final saved = ref.watch(localStoreProvider).readBookings();
    if (saved.isEmpty) return [...DemoData.bookings];
    return saved;
  }

  Future<void> add(Booking booking) => _commit([booking, ...state]);

  Future<void> cancel(String id) {
    return _commit([
      for (final item in state)
        if (item.id == id)
          item.copyWith(status: 'Cancelled', active: false)
        else
          item,
    ]);
  }

  Future<void> _commit(List<Booking> next) async {
    state = next;
    await ref.read(localStoreProvider).writeBookings(next);
  }
}

final bookingControllerProvider =
    NotifierProvider<BookingController, List<Booking>>(BookingController.new);

final activeChatIdProvider = StateProvider<int>((ref) => 1);

class ChatController extends Notifier<List<Conversation>> {
  @override
  List<Conversation> build() => DemoData.conversations();

  void send(int conversationId, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final now = TimeOfDay.now();
    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final minute = now.minute.toString().padLeft(2, '0');
    final suffix = now.period == DayPeriod.am ? 'AM' : 'PM';
    final time = '$hour:$minute $suffix';
    state = [
      for (final item in state)
        if (item.id != conversationId)
          item
        else
          item.copyWith(
            time: time,
            messages: [
              ...item.messages,
              ChatMessage(
                id: item.messages.length + 1,
                sender: 'me',
                text: trimmed,
                time: time,
              ),
            ],
          ),
    ];
  }
}

final chatControllerProvider =
    NotifierProvider<ChatController, List<Conversation>>(ChatController.new);

class NotificationController extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() => DemoData.notifications;

  void markAllRead() {
    state = [for (final item in state) item.copyWith(unread: false)];
  }

  void markRead(int id) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(unread: false) else item,
    ];
  }
}

final notificationControllerProvider =
    NotifierProvider<NotificationController, List<AppNotification>>(
      NotificationController.new,
    );

List<NavLink> visibleNavLinks(List<NavLink> links) {
  return links.where((link) {
    final title = link.title.toLowerCase();
    return !title.contains('booking') &&
        !title.contains('notification') &&
        !title.contains('chat');
  }).toList();
}
