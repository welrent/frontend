import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/models.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class OfferlistScreen extends ConsumerWidget {
  const OfferlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    final params = GoRouterState.of(context).uri.queryParameters;
    final location = params['location']?.isNotEmpty == true
        ? params['location']!
        : 'Anywhere';
    final type = params['type'];
    final query = (params['q'] ?? '').trim().toLowerCase();

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 56, 0, 60),
      child: CenteredContainer(
        padding: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.sizeOf(context).width < AppBreakpoints.mobile
                ? 20
                : 40,
          ),
          child: catalog.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: Center(
                child: AppSpinner(size: 28, color: AppColors.accentBlue),
              ),
            ),
            error: (error, _) => _Message(
              text: 'Vehicles could not be loaded.',
              action: 'Try again',
              onPressed: () => ref.invalidate(catalogProvider),
            ),
            data: (data) {
              final cars = data.cars.where((car) {
                if (query.isEmpty) return true;
                return car.name.toLowerCase().contains(query) ||
                    car.subtitle.toLowerCase().contains(query) ||
                    car.slug.toLowerCase().contains(query);
              }).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Vehicles',
                    style: AppText.outfit(size: 40, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 40),
                  Wrap(
                    spacing: 20,
                    runSpacing: 12,
                    children: [
                      _FilterChip(label: 'Location', value: location),
                      if (type != null && type.isNotEmpty)
                        _FilterChip(label: 'Type', value: type),
                      if (query.isNotEmpty)
                        _FilterChip(label: 'Search', value: query),
                    ],
                  ),
                  const SizedBox(height: 40),
                  if (cars.isEmpty)
                    const _Message(
                      text: 'No vehicles available at the moment. Check back soon!',
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth > 980
                            ? 3
                            : constraints.maxWidth > 680
                            ? 2
                            : 1;
                        final gap = 30.0;
                        final width =
                            (constraints.maxWidth - gap * (columns - 1)) /
                            columns;
                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: [
                            for (final car in cars)
                              SizedBox(
                                width: width,
                                child: _VehicleCard(car: car),
                              ),
                          ],
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 220),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppText.outfit(size: 13.6, color: AppColors.fieldText),
          ),
          const SizedBox(height: 4),
          Text(value, style: AppText.outfit(size: 16, weight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.car});

  final Car car;

  @override
  Widget build(BuildContext context) {
    final dark = car.isDarkMode;
    final foreground = dark ? Colors.white : AppColors.textPrimary;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 24),
      decoration: BoxDecoration(
        color: dark ? AppColors.textPrimary : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            car.subtitle,
            style: AppText.outfit(
              size: 14.4,
              color: foreground.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            car.name,
            style: AppText.outfit(
              size: 28.8,
              weight: FontWeight.w700,
              color: foreground,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: RemoteOrAssetImage(
              source: car.photoUrl,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: AppText.outfit(
                      size: 19.2,
                      weight: FontWeight.w600,
                      color: foreground,
                    ),
                    children: [
                      TextSpan(text: '\$${car.price} '),
                      TextSpan(
                        text: '/ day',
                        style: AppText.outfit(
                          size: 12.8,
                          color: foreground.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              HoverButton(
                onPressed: () => context.go('/vehicle/${car.slug}'),
                background: dark ? Colors.white : Colors.black,
                hoverBackground: dark
                    ? const Color(0xFFE5E7EB)
                    : const Color(0xFF222222),
                foreground: dark ? Colors.black : Colors.white,
                radius: 100,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: const Text('View Deal'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.action, this.onPressed});

  final String text;
  final String? action;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppText.outfit(size: 17.6, color: AppColors.fieldText),
          ),
          if (action != null) ...[
            const SizedBox(height: 20),
            HoverButton(
              onPressed: onPressed,
              background: AppColors.textPrimary,
              hoverBackground: const Color(0xFF2D3A54),
              radius: 10,
              child: Text(action!),
            ),
          ],
        ],
      ),
    );
  }
}
