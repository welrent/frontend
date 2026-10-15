import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/site_footer.dart';

class SponsorshipScreen extends ConsumerStatefulWidget {
  const SponsorshipScreen({super.key});

  @override
  ConsumerState<SponsorshipScreen> createState() => _SponsorshipScreenState();
}

class _SponsorshipScreenState extends ConsumerState<SponsorshipScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final next = _scroll.hasClients && _scroll.offset > 10;
      if (ref.read(shellScrolledProvider) != next) {
        ref.read(shellScrolledProvider.notifier).state = next;
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context).height;
    return ColoredBox(
      color: Colors.black,
      child: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _Sticky(
              min: viewport,
              max: viewport * 3,
              builder: (t) => _Hero(progress: t),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _Sticky(
              min: viewport,
              max: viewport * 2,
              builder: (t) => _Sidepod(progress: t),
            ),
          ),
          SliverToBoxAdapter(
            child: _Stats(viewportWidth: MediaQuery.sizeOf(context).width),
          ),
          const SliverToBoxAdapter(child: SiteFooter()),
        ],
      ),
    );
  }
}

class _Sticky extends SliverPersistentHeaderDelegate {
  _Sticky({required this.min, required this.max, required this.builder});

  final double min;
  final double max;
  final Widget Function(double t) builder;

  @override
  double get minExtent => min;

  @override
  double get maxExtent => max;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final span = (max - min).clamp(1, double.infinity);
    final t = (shrinkOffset / span).clamp(0.0, 1.0);
    return builder(t);
  }

  @override
  bool shouldRebuild(covariant _Sticky oldDelegate) =>
      oldDelegate.min != min || oldDelegate.max != max;
}

class _Hero extends StatelessWidget {
  const _Hero({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final titleOpacity =
        _range(progress, 0, 0.12, 0, 1) *
        (1 - _range(progress, 0.72, 0.9, 0, 1));
    final titleScale = 1 + progress * 0.45;
    final carOpacity =
        _range(progress, 0.18, 0.38, 0, 1) *
        (1 - _range(progress, 0.82, 1, 0, 1));
    final carDy = (1 - _range(progress, 0, 0.55, 0, 1)) * 80;
    final carScale = 1 - _range(progress, 0.45, 1, 0, 0.25);
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: titleOpacity.clamp(0, 1),
            child: Transform.scale(
              scale: titleScale,
              child: Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  style: AppText.outfit(
                    size: 88,
                    weight: FontWeight.w800,
                    height: 0.9,
                    letterSpacing: -2,
                    color: Colors.white,
                  ),
                  children: [
                    const TextSpan(text: 'ENGINEERING\n'),
                    TextSpan(
                      text: 'EXCELLENCE',
                      style: AppText.outfit(
                        size: 88,
                        weight: FontWeight.w800,
                        height: 0.9,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Opacity(
            opacity: carOpacity.clamp(0, 1),
            child: Transform.translate(
              offset: Offset(0, carDy),
              child: Transform.scale(
                scale: carScale,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Image.asset(BrandAssets.f1Hero, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidepod extends StatelessWidget {
  const _Sidepod({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final imageOpacity = _range(progress, 0.05, 0.28, 0, 1);
    final scale = 1.18 - _range(progress, 0, 1, 0, 0.18);
    final textOpacity = _range(progress, 0.35, 0.55, 0, 1);
    final textDx = (1 - textOpacity) * -40;
    final width = MediaQuery.sizeOf(context).width;
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: imageOpacity.clamp(0, 1),
            child: Transform.scale(
              scale: scale,
              child: Image.asset(BrandAssets.f1Side, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            left: width < 700 ? 24 : width * 0.1,
            right: width < 700 ? 24 : null,
            top: width < 700 ? null : null,
            bottom: width < 700 ? 80 : null,
            child: Opacity(
              opacity: textOpacity.clamp(0, 1),
              child: Transform.translate(
                offset: Offset(textDx, 0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Partnership Driven By Speed.',
                        style: AppText.outfit(
                          size: width < 700 ? 36 : 48,
                          weight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Welrent joins forces with the pinnacle of motorsport to push the boundaries of automotive performance and smart logistic solutions.',
                        style: AppText.outfit(
                          size: 18,
                          color: const Color(0xFFA0A4AB),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.viewportWidth});

  final double viewportWidth;

  @override
  Widget build(BuildContext context) {
    final columns = viewportWidth < 800 ? 1 : 3;
    return ColoredBox(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 100),
        child: CenteredContainer(
          child: Column(
            children: [
              Text(
                'PERFORMANCE DATA',
                style: AppText.outfit(
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColors.fieldText,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Limitless Potential.',
                style: AppText.outfit(
                  size: 48,
                  weight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 60),
              LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 24.0;
                  final width =
                      (constraints.maxWidth - gap * (columns - 1)) / columns;
                  const stats = [
                    ('370.4', 'Top Speed (KM/H)'),
                    ('2.1s', '0-100 Acceleration'),
                    ('4.5G', 'Cornering Force'),
                  ];
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final stat in stats)
                        Container(
                          width: width,
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stat.$1,
                                style: AppText.outfit(
                                  size: 56,
                                  weight: FontWeight.w700,
                                  color: AppColors.accentBlue,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                stat.$2.toUpperCase(),
                                style: AppText.outfit(
                                  size: 14,
                                  color: AppColors.fieldText,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 80),
              HoverButton(
                onPressed: () => context.go('/offerlist'),
                radius: 12,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                child: const Text('Drive The Legacy'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

double _range(double value, double start, double end, double from, double to) {
  if (value <= start) return from;
  if (value >= end) return to;
  final t = (value - start) / (end - start);
  return from + (to - from) * t;
}
