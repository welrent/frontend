import 'geolocation_stub.dart'
    if (dart.library.js_interop) 'geolocation_web.dart'
    as geo;

Future<bool> detectBrowserLocation() => geo.detectBrowserLocation();
