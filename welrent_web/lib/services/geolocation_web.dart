import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<bool> detectBrowserLocation() {
  final completer = Completer<bool>();
  try {
    web.window.navigator.geolocation.getCurrentPosition(
      ((web.GeolocationPosition _) {
        if (!completer.isCompleted) completer.complete(true);
      }).toJS,
      ((web.GeolocationPositionError _) {
        if (!completer.isCompleted) completer.complete(false);
      }).toJS,
    );
  } catch (_) {
    if (!completer.isCompleted) completer.complete(false);
  }
  return completer.future.timeout(
    const Duration(seconds: 8),
    onTimeout: () => false,
  );
}
