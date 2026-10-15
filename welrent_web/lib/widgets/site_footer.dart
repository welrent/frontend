import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog.dart';
import '../models/models.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import 'common.dart';
import 'icons.dart';

class SiteFooter extends ConsumerWidget {
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider).valueOrNull;
    final content = catalog?.content;
    final footer = catalog?.footer ?? DemoData.footer;
    final language = ref.watch(languageProvider);
    final width = MediaQuery.sizeOf(context).width;
    final stacked = width < AppBreakpoints.mobile;
    final columns = width < 480 ? 1 : (width < AppBreakpoints.mobile ? 2 : 4);

    return ColoredBox(
      color: Colors.white,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.borderLight)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 60, bottom: 30),
          child: CenteredContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flex(
                  direction: stacked ? Axis.vertical : Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: stacked ? double.infinity : 360,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BrandLogo(height: 30),
                          const SizedBox(height: 15),
                          Text(
                            content?.footerBrandDesc ?? 'Welcome to Welrent, the smartest auto sharing and rental app. We guarantee the perfect car for every moment.',
                            style: AppText.outfit(
                              size: 14.4,
                              color: AppColors.textMuted,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 15,
                            runSpacing: 10,
                            children: const [
                              _StoreBadge(icon: 'apple', label: 'App Store'),
                              _StoreBadge(icon: 'play', label: 'Google Play'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (stacked) const SizedBox(height: 30),
                    Column(
                      crossAxisAlignment: stacked
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Trustpilot',
                          style: AppText.outfit(
                            size: 18,
                            weight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text.rich(
                          TextSpan(
                            style: AppText.outfit(
                              size: 14.4,
                              weight: FontWeight.w600,
                            ),
                            children: const [
                              TextSpan(text: 'Excellent '),
                              TextSpan(
                                text: '★★★★★',
                                style: TextStyle(color: AppColors.trustGreen),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 40),
                _FooterGrid(footer: footer, columns: columns),
                const SizedBox(height: 20),
                const Divider(height: 1, color: Colors.transparent),
                Flex(
                  direction: stacked ? Axis.vertical : Axis.horizontal,
                  crossAxisAlignment: stacked
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      content?.footerCopyright ??
                          '© 2026 Welrent App. Smart Agreements.',
                      style: AppText.outfit(
                        size: 12.8,
                        color: AppColors.textMuted,
                      ),
                    ),
                    if (stacked) const SizedBox(height: 16),
                    Wrap(
                      spacing: 20,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _FooterLink(label: 'Privacy', url: '/privacy'),
                        _FooterLink(label: 'Terms', url: '/terms'),
                        Container(
                          width: stacked ? 0 : 1,
                          height: 14,
                          color: AppColors.borderLight,
                        ),
                        for (final code in const ['EN', 'NL', 'FR'])
                          GestureDetector(
                            onTap: () => ref
                                .read(languageProvider.notifier)
                                .select(code),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Text(
                                code,
                                style: AppText.outfit(
                                  size: 12.8,
                                  weight: FontWeight.w600,
                                  color: language == code
                                      ? AppColors.textPrimary
                                      : AppColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterGrid extends StatelessWidget {
  const _FooterGrid({required this.footer, required this.columns});

  final Map<String, List<NavLink>> footer;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final entries = footer.entries.toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 20.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: 28,
          children: [
            for (final entry in entries)
              SizedBox(
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: AppText.outfit(
                        size: 14.4,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    for (final link in entry.value) ...[
                      _FooterLink(
                        label: link.title,
                        url: link.url,
                        muted: true,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FooterLink extends StatefulWidget {
  const _FooterLink({
    required this.label,
    required this.url,
    this.muted = false,
  });

  final String label;
  final String url;
  final bool muted;

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final base = widget.muted ? AppColors.fieldText : AppColors.textMuted;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () {
          if (widget.url.startsWith('/')) {
            context.go(widget.url);
          } else {
            openExternal(widget.url);
          }
        },
        child: Text(
          widget.label,
          style: AppText.outfit(
            size: widget.muted ? 13.6 : 12.8,
            color: _hover ? AppColors.textPrimary : base,
          ),
        ),
      ),
    );
  }
}

class _StoreBadge extends StatefulWidget {
  const _StoreBadge({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  State<_StoreBadge> createState() => _StoreBadgeState();
}

class _StoreBadgeState extends State<_StoreBadge> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => showAppMessage(
          context,
          title: widget.label,
          message:
              'The ${widget.label} listing is not linked from the current Welrent frontend.',
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: _hover ? 0.8 : 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(widget.icon, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: AppText.outfit(
                    size: 12.8,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
