import 'package:flutter_test/flutter_test.dart';
import 'package:welrent_web/data/catalog.dart';
import 'package:welrent_web/models/models.dart';

void main() {
  test('Car.fromJson accepts integer dark-mode flags and string prices', () {
    final car = Car.fromJson({
      'id': '7',
      'name': 'an RS6',
      'slug': 'an-RS6',
      'subtitle': 'Rent...',
      'photo_url': 'assets/WLR_CAR_RS6.png',
      'is_dark_mode': 1,
      'price': '120',
    });

    expect(car.id, 7);
    expect(car.isDarkMode, isTrue);
    expect(car.price, 120);
    expect(car.matchesSlug('an-RS6'), isTrue);
    expect(car.matchesSlug('an-RS6'.replaceAll('RS6', 'RS6')), isTrue);
  });

  test('slug matching accepts the display name with hyphens', () {
    const car = Car(
      id: 2,
      name: 'an EVO',
      slug: 'an-EVO',
      subtitle: 'Rent...',
      photoUrl: '',
      isDarkMode: false,
      price: 150,
    );
    expect(car.matchesSlug('an-EVO'), isTrue);
    expect(car.matchesSlug('an-EVO-extra'), isFalse);
    expect(
      Car.fromJson({'is_dark_mode': 'yes', 'price': null}).isDarkMode,
      isTrue,
    );
    expect(Car.fromJson({'isDarkMode': false}).price, 150);
  });

  test('unknown city pages resolve to Monaco', () {
    expect(DestinationData.resolve('amsterdam').name, 'Monaco');
    expect(DestinationData.resolve('MONACO').fullName, contains('Monaco'));
    expect(DestinationData.resolve('malta').name, 'Malta');
  });

  test('grouped prices and clocks match the marketplace format', () {
    expect(formatGrouped(12500), '12,500');
    expect(formatClock(DateTime(2026, 12, 16, 22, 30)), '10:30 PM');
    expect(isoDate(DateTime(2026, 1, 2)), '2026-01-02');
  });
}
