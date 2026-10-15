import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../data/catalog.dart';
import '../models/models.dart';

class WelrentApi {
  WelrentApi({required this.config, http.Client? client})
    : _client = client ?? http.Client();

  final AppConfig config;
  final http.Client _client;

  Future<List<Car>> fetchCars() async {
    if (!config.hasApi) return DemoData.cars;
    try {
      final response = await _client.get(
        Uri.parse('${config.normalizedApiBase}/api/cars'),
      );
      if (response.statusCode != 200) return DemoData.cars;
      final data = jsonDecode(response.body);
      if (data is! List || data.isEmpty) return DemoData.cars;
      return data
          .whereType<Map>()
          .map((item) => Car.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return DemoData.cars;
    }
  }

  Future<Car?> fetchVehicle(String slug) async {
    if (!config.hasApi) return DemoData.vehicleBySlug(slug, DemoData.cars);
    try {
      final response = await _client.get(
        Uri.parse(
          '${config.normalizedApiBase}/api/vehicle/${Uri.encodeComponent(slug)}',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) return Car.fromJson(data);
        if (data is Map) return Car.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (_) {
      // Fall through to the same demo lookup the Next.js client uses.
    }
    return DemoData.vehicleBySlug(slug, DemoData.cars);
  }

  Future<Catalog> fetchCatalog() async {
    if (!config.hasApi) return DemoData.demoCatalog();
    final cars = await fetchCars();
    final nav = await _fetchNav();
    final content = await _fetchContent();
    return Catalog(
      cars: cars,
      navbar: nav.$1,
      footer: nav.$2,
      content: content,
    );
  }

  Future<(List<NavLink>, Map<String, List<NavLink>>)> _fetchNav() async {
    try {
      final response = await _client.get(
        Uri.parse('${config.normalizedApiBase}/api/nav_footer'),
      );
      if (response.statusCode != 200) {
        return (DemoData.navbar, DemoData.footer);
      }
      final data = jsonDecode(response.body);
      if (data is! Map) return (DemoData.navbar, DemoData.footer);
      final map = Map<String, dynamic>.from(data);
      final navbarJson = map['navbar'];
      final footerJson = map['footer'];
      final navbar = navbarJson is List && navbarJson.isNotEmpty
          ? navbarJson
                .whereType<Map>()
                .map(
                  (item) => NavLink.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : DemoData.navbar;
      final footer = <String, List<NavLink>>{};
      if (footerJson is Map && footerJson.isNotEmpty) {
        footerJson.forEach((key, value) {
          if (value is List) {
            footer['$key'] = value
                .whereType<Map>()
                .map(
                  (item) => NavLink.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList();
          }
        });
      }
      return (navbar, footer.isEmpty ? DemoData.footer : footer);
    } catch (_) {
      return (DemoData.navbar, DemoData.footer);
    }
  }

  Future<SiteContent> _fetchContent() async {
    try {
      final response = await _client.get(
        Uri.parse('${config.normalizedApiBase}/api/content'),
      );
      if (response.statusCode != 200) return DemoData.content;
      final data = jsonDecode(response.body);
      if (data is! Map || data.isEmpty) return DemoData.content;
      final parsed = SiteContent.fromJson(Map<String, dynamic>.from(data));
      return SiteContent(
        footerBrandDesc: parsed.footerBrandDesc.isEmpty
            ? DemoData.content.footerBrandDesc
            : parsed.footerBrandDesc,
        footerCopyright: parsed.footerCopyright.isEmpty
            ? DemoData.content.footerCopyright
            : parsed.footerCopyright,
      );
    } catch (_) {
      return DemoData.content;
    }
  }

  Future<List<Rental>> fetchRentals(String uid) async {
    if (!config.hasApi || uid.isEmpty) return const [];
    final response = await _client.get(
      Uri.parse(
        '${config.normalizedApiBase}/api/rentals?uid=${Uri.encodeQueryComponent(uid)}',
      ),
    );
    if (response.statusCode != 200) {
      throw ApiException('Could not load rentals (${response.statusCode}).');
    }
    final data = jsonDecode(response.body);
    if (data is! Map) return const [];
    final rows = data['rentals'];
    if (rows is! List) return const [];
    return rows
        .whereType<Map>()
        .map((item) => Rental.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<String> uploadPhoto({
    required List<int> bytes,
    required String contentType,
  }) async {
    if (!config.hasApi) {
      throw ApiException(
        'API_BASE_URL is not set, so this photo cannot be stored.',
      );
    }
    final response = await _client.post(
      Uri.parse('${config.normalizedApiBase}/api/photos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contentType': contentType,
        'data': base64Encode(bytes),
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Photo upload failed (${response.statusCode}).');
    }
    final data = jsonDecode(response.body);
    if (data is Map && data['url'] != null) return '${data['url']}';
    throw ApiException('Photo upload did not return a URL.');
  }

  Future<String> createRental({
    required String uid,
    required String carName,
    required String carImage,
    required String startDate,
    required String endDate,
    required int days,
    required num price,
    required String location,
  }) async {
    if (!config.hasApi) {
      throw ApiException(
        'API_BASE_URL is not set, so this booking cannot be sent to the Welrent API.',
      );
    }
    final response = await _client.post(
      Uri.parse('${config.normalizedApiBase}/api/rentals'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'uid': uid,
        'car_name': carName,
        'car_image': carImage,
        'start_date': startDate,
        'end_date': endDate,
        'days': days,
        'price': price,
        'location': location,
        'status': 'upcoming',
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'The Welrent API rejected the booking (${response.statusCode}).',
      );
    }
    final data = jsonDecode(response.body);
    if (data is Map && data['booking_ref'] != null) {
      return '${data['booking_ref']}';
    }
    throw ApiException('The Welrent API did not return a booking reference.');
  }
}

class ApiException implements Exception {
  ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}
