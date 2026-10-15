import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog.dart';
import '../models/models.dart';
import '../services/welrent_api.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class VehicleScreen extends ConsumerWidget {
  const VehicleScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    return catalog.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 120),
        child: Center(child: AppSpinner(size: 28, color: AppColors.accentBlue)),
      ),
      error: (_, _) => const _Missing(),
      data: (data) {
        Car? car;
        for (final item in data.cars) {
          if (item.matchesSlug(slug)) {
            car = item;
            break;
          }
        }
        car ??= DemoData.vehicleBySlug(slug, DemoData.cars);
        if (car == null) return const _Missing();
        return _VehicleDetail(car: car);
      },
    );
  }
}

class _Missing extends StatelessWidget {
  const _Missing();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 90),
      child: CenteredContainer(
        child: Column(
          children: [
            Text(
              'Vehicle Not Found',
              style: AppText.outfit(size: 36, weight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            Text(
              'This vehicle is not available or the listing could not be loaded.',
              style: AppText.outfit(size: 16, color: AppColors.fieldText),
            ),
            const SizedBox(height: 30),
            HoverButton(
              onPressed: () => context.go('/offerlist'),
              background: AppColors.textPrimary,
              hoverBackground: const Color(0xFF2D3A54),
              radius: 10,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              child: const Text('Browse Vehicles'),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleDetail extends ConsumerWidget {
  const _VehicleDetail({required this.car});

  final Car car;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = car.isDarkMode;
    final foreground = dark ? Colors.white : AppColors.textPrimary;
    final width = MediaQuery.sizeOf(context).width;
    final stacked = width < 900;
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          car.subtitle,
          style: AppText.outfit(
            size: 19,
            color: foreground.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          car.name,
          style: AppText.outfit(
            size: stacked ? 48 : 64,
            weight: FontWeight.w800,
            color: foreground,
            height: 1,
          ),
        ),
        const SizedBox(height: 30),
        Text(
          'Experience the unmatched capabilities of ${car.name}. The perfect companion for your journey starts here.',
          style: AppText.outfit(
            size: 17.6,
            color: foreground.withValues(alpha: 0.8),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 40),
        Text.rich(
          TextSpan(
            style: AppText.outfit(
              size: 32,
              weight: FontWeight.w700,
              color: foreground,
            ),
            children: [
              TextSpan(text: '\$${car.price} '),
              TextSpan(
                text: '/ day',
                style: AppText.outfit(
                  size: 16,
                  weight: FontWeight.w400,
                  color: foreground.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        HoverButton(
          onPressed: () => _book(context, ref),
          background: AppColors.bookRed,
          hoverBackground: const Color(0xFFE04343),
          radius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Text(
            'Book Now',
            style: AppText.outfit(
              size: 17.6,
              weight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
    final photo = RemoteOrAssetImage(source: car.photoUrl, fit: BoxFit.contain);

    return ColoredBox(
      color: dark ? AppColors.textPrimary : AppColors.infoBg,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 56),
        child: CenteredContainer(
          child: stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [info, const SizedBox(height: 32), photo],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: info),
                    const SizedBox(width: 60),
                    Expanded(child: photo),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _book(BuildContext context, WidgetRef ref) async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) {
      final go = await showConfirmDialog(
        context,
        title: 'Sign in to book',
        message: 'Bookings are attached to your Welrent account.',
        confirmLabel: 'Sign in',
      );
      if (go && context.mounted) context.go('/login');
      return;
    }

    final params = GoRouterState.of(context).uri.queryParameters;
    final start =
        DateTime.tryParse(params['start'] ?? '') ?? DateTime(2026, 12, 16);
    final end =
        DateTime.tryParse(params['end'] ?? '') ??
        start.add(const Duration(days: 1));
    final days = end.difference(start).inDays <= 0
        ? 1
        : end.difference(start).inDays;
    final location = params['location']?.isNotEmpty == true
        ? params['location']!
        : 'Anywhere';
    final total = car.price * days;

    final confirmed = await showConfirmDialog(
      context,
      title: 'Book ${car.name}',
      message:
          '$location\n${isoDate(start)} → ${isoDate(end)}\n$days ${days == 1 ? 'day' : 'days'} · \$$total',
      confirmLabel: 'Confirm booking',
    );
    if (!confirmed || !context.mounted) return;

    final api = ref.read(apiProvider);
    final config = ref.read(appConfigProvider);
    try {
      if (!config.hasApi) {
        final localRef =
            'WLR-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
        await ref
            .read(bookingControllerProvider.notifier)
            .add(
              Booking(
                id: localRef,
                type: 'car',
                name: car.name,
                image: car.photoUrl,
                status: 'Confirmed',
                dates: '${isoDate(start)} - ${isoDate(end)}',
                location: location,
                total: '\$$total',
                active: true,
                local: true,
              ),
            );
        if (!context.mounted) return;
        await showAppMessage(
          context,
          title: 'Saved on this device',
          message:
              'API_BASE_URL is not configured, so booking $localRef was stored locally and was not sent to the Welrent API.',
        );
        return;
      }
      final bookingRef = await api.createRental(
        uid: user.id,
        carName: car.name,
        carImage: car.photoUrl,
        startDate: isoDate(start),
        endDate: isoDate(end),
        days: days,
        price: total,
        location: location,
      );
      await ref
          .read(bookingControllerProvider.notifier)
          .add(
            Booking(
              id: bookingRef,
              type: 'car',
              name: car.name,
              image: car.photoUrl,
              status: 'Confirmed',
              dates: '${isoDate(start)} - ${isoDate(end)}',
              location: location,
              total: '\$$total',
              active: true,
              local: true,
            ),
          );
      if (!context.mounted) return;
      await showAppMessage(
        context,
        title: 'Booking confirmed',
        message: 'Reference $bookingRef is saved with the Welrent API.',
      );
    } on ApiException catch (error) {
      if (!context.mounted) return;
      await showAppMessage(
        context,
        title: 'Booking failed',
        message: error.message,
      );
    }
  }
}
