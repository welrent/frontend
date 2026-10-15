import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/providers.dart';
import '../theme/app_theme.dart';
import 'site_footer.dart';
import 'site_header.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = GoRouterState.of(context).uri.path;
    final fullBleed = path == '/chat' || path.startsWith('/sponsorship');
    final darkHeader = path.startsWith('/sponsorship');
    final scrolled = ref.watch(shellScrolledProvider);
    final background = _backgroundFor(path);

    return SearchShortcut(
      child: Scaffold(
        backgroundColor: background,
        body: Stack(
          children: [
            Positioned.fill(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.axis != Axis.vertical) return false;
                  final next = notification.metrics.pixels > 10;
                  if (ref.read(shellScrolledProvider) != next) {
                    ref.read(shellScrolledProvider.notifier).state = next;
                  }
                  return false;
                },
                child: child,
              ),
            ),
            if (!fullBleed)
              const Positioned.fill(
                child: IgnorePointer(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ColoredBox(
                      color: AppColors.gridLine,
                      child: SizedBox(width: 1),
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SiteHeader(scrolled: scrolled, dark: darkHeader),
            ),
            if (!fullBleed)
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MobileBottomNav(),
              ),
          ],
        ),
      ),
    );
  }

  Color _backgroundFor(String path) {
    if (path.startsWith('/sponsorship')) return Colors.black;
    if (path == '/login' || path == '/register' || path == '/forgot') {
      return const Color(0xFFF4F7FB);
    }
    if (path == '/account' ||
        path == '/bookings' ||
        path == '/notifications' ||
        path == '/chat') {
      return AppColors.bgPage;
    }
    return AppColors.bgOffWhite;
  }
}

/// Scrollable page body under the fixed header, with the shared footer.
class ShellPage extends ConsumerStatefulWidget {
  const ShellPage({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends ConsumerState<ShellPage> {
  final _scroll = ScrollController();
  String? _location;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (_location != location) {
      _location = location;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (ref.read(shellScrolledProvider)) {
          ref.read(shellScrolledProvider.notifier).state = false;
        }
        if (_scroll.hasClients) _scroll.jumpTo(0);
      });
    }

    final mobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);
    return CustomScrollView(
      controller: _scroll,
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: mobile ? 132 : 65),
              widget.child,
              const SiteFooter(),
              if (mobile) const SizedBox(height: 88),
            ],
          ),
        ),
      ],
    );
  }
}
