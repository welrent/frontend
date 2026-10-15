import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/icons.dart';

class LocationsScreen extends StatelessWidget {
  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: CenteredContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 40, bottom: 50),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.gridLine)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WHERE WE DRIVE',
                    style: AppText.outfit(
                      size: 12.8,
                      weight: FontWeight.w700,
                      color: AppColors.accentBlue,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Our Locations',
                    style: AppText.playfair(
                      size: width < 700 ? 40 : 56,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Text(
                      'Welrent is active across the Netherlands and Belgium. Choose a city below to explore available vehicles and learn about local pickup.',
                      style: AppText.outfit(
                        size: 16.8,
                        color: AppColors.textMuted,
                        height: 1.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            for (final region in DemoData.regions) ...[
              Row(
                children: [
                  Text(region.flag, style: const TextStyle(fontSize: 35)),
                  const SizedBox(width: 14),
                  Text(
                    region.country,
                    style: AppText.outfit(size: 25.6, weight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 14.0;
                  final columns = constraints.maxWidth > 900
                      ? 4
                      : constraints.maxWidth > 640
                      ? 2
                      : 1;
                  final itemWidth =
                      (constraints.maxWidth - gap * (columns - 1)) / columns;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final city in region.cities)
                        SizedBox(
                          width: itemWidth,
                          child: _CityLink(name: city.name, slug: city.slug),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 60),
            ],
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.accentBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 20,
                runSpacing: 20,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Don't see your city?",
                          style: AppText.outfit(
                            size: 22.4,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "We're expanding fast. Check back soon or browse all available vehicles.",
                          style: AppText.outfit(
                            size: 15.2,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  HoverButton(
                    onPressed: () => context.go('/offerlist'),
                    background: Colors.white,
                    hoverBackground: const Color(0xFFF3F4F6),
                    foreground: AppColors.accentBlue,
                    radius: 8,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    child: const Text('View All Cars →'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CityLink extends StatefulWidget {
  const _CityLink({required this.name, required this.slug});

  final String name;
  final String slug;

  @override
  State<_CityLink> createState() => _CityLinkState();
}

class _CityLinkState extends State<_CityLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final color = _hover ? AppColors.accentBlue : AppColors.textPrimary;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => context.go('/locations/${widget.slug}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          decoration: BoxDecoration(
            color: _hover ? AppColors.activeBg : AppColors.bgOffWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hover ? AppColors.accentBlue : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Huur in ${widget.name}',
                  style: AppText.outfit(
                    size: 15.2,
                    weight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              AppIcon('chevron-right', size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
