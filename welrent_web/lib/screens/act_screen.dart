import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ActScreen extends ConsumerWidget {
  const ActScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final width = MediaQuery.sizeOf(context).width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(0, width < 768 ? 46 : 76, 0, 90),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1C263A), Color(0xFF371947), Color(0xFF1C263A)],
              stops: [0, 0.55, 1],
            ),
          ),
          child: CenteredContainer(
            maxWidth: 760,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandLogo(height: 56, word: 'Act', invert: true),
                const SizedBox(height: 28),
                Text(
                  'Welrent Act',
                  style: AppText.outfit(
                    size: width < 700 ? 42 : 64,
                    weight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Connected to the public Act project for smart agreements, legal pages, and SSO. Live Act base: ${config.normalizedActBase}',
                  style: AppText.outfit(
                    size: 17.6,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 14,
                  runSpacing: 12,
                  children: [
                    HoverButton(
                      onPressed: () => openExternal(config.actUrl('/')),
                      radius: 4,
                      shadow: const [
                        BoxShadow(
                          color: Color(0x4D5CAAF6),
                          blurRadius: 15,
                          offset: Offset(0, 4),
                        ),
                      ],
                      child: const Text('Open Act home'),
                    ),
                    HoverButton(
                      onPressed: () => openExternal(DemoData.actRepoUrl),
                      background: Colors.transparent,
                      hoverBackground: Colors.white.withValues(alpha: 0.08),
                      borderColor: Colors.white.withValues(alpha: 0.35),
                      radius: 12,
                      child: const Text('View Act on GitHub'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 80),
          child: CenteredContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connected Act pages',
                  style: AppText.outfit(size: 32, weight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Text.rich(
                  TextSpan(
                    style: AppText.outfit(
                      size: 17.6,
                      color: AppColors.bodyGrey,
                      height: 1.7,
                    ),
                    children: [
                      const TextSpan(text: 'These routes come from '),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => openExternal(DemoData.actRepoUrl),
                          child: Text(
                            'github.com/welrent/Act',
                            style: AppText.outfit(
                              size: 17.6,
                              weight: FontWeight.w600,
                              color: AppColors.accentBlue,
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(
                        text: ' (next-app/src/app/pages/[slug] and agreements hub). The marketplace deep-links into that catalog so rentals and legal flows stay in sync.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _ActGrid(
                  cards: [
                    for (final page in DemoData.actPages)
                      _ActCardData(
                        page.title,
                        page.body,
                        page.path,
                        config.actUrl(page.path),
                        true,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: CenteredContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Also in this app',
                  style: AppText.outfit(size: 32, weight: FontWeight.w700),
                ),
                const SizedBox(height: 32),
                _ActGrid(
                  cards: [
                    _ActCardData(
                      'Book a performance car',
                      'Jump into the Welrent App marketplace and reserve an RS6, EVO, or yacht.',
                      'Browse vehicles →',
                      '/offerlist',
                      false,
                    ),
                    _ActCardData(
                      'F1 designed programme',
                      'Explore the motorsport collaboration inside the marketplace app.',
                      'View F1 page →',
                      '/sponsorship/f1/wr/designed',
                      false,
                    ),
                    _ActCardData(
                      'Act source repository',
                      'Public GitHub project that powers Act pages and the WelrentAuth SDK.',
                      'Open github.com/welrent/Act →',
                      DemoData.actRepoUrl,
                      true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        ColoredBox(
          color: AppColors.textPrimary,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 80),
            child: CenteredContainer(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 24,
                runSpacing: 24,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ready to drive?',
                          style: AppText.outfit(
                            size: 32,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Return to the Welrent App marketplace or jump into Act agreements.',
                          style: AppText.outfit(
                            size: 17.6,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 14,
                    runSpacing: 12,
                    children: [
                      HoverButton(
                        onPressed: () => context.go('/'),
                        child: const Text('Back to Welrent App'),
                      ),
                      HoverButton(
                        onPressed: () =>
                            openExternal(config.actUrl('/agreements')),
                        background: Colors.transparent,
                        hoverBackground: Colors.white.withValues(alpha: 0.08),
                        borderColor: Colors.white.withValues(alpha: 0.35),
                        radius: 12,
                        child: const Text('Act agreements'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActCardData {
  const _ActCardData(
    this.title,
    this.body,
    this.action,
    this.href,
    this.external,
  );
  final String title;
  final String body;
  final String action;
  final String href;
  final bool external;
}

class _ActGrid extends StatelessWidget {
  const _ActGrid({required this.cards});

  final List<_ActCardData> cards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 900
            ? 3
            : (constraints.maxWidth > 640 ? 2 : 1);
        const gap = 24.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final card in cards)
              SizedBox(
                width: width,
                child: _ActCard(data: card),
              ),
          ],
        );
      },
    );
  }
}

class _ActCard extends StatelessWidget {
  const _ActCard({required this.data});

  final _ActCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title,
            style: AppText.outfit(size: 20, weight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            data.body,
            style: AppText.outfit(
              size: 15,
              color: AppColors.bodyGrey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () {
              if (data.external || !data.href.startsWith('/')) {
                openExternal(data.href);
              } else {
                context.go(data.href);
              }
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                data.action.endsWith('→') ? data.action : '${data.action} →',
                style: AppText.outfit(
                  size: 15,
                  weight: FontWeight.w700,
                  color: AppColors.accentBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
