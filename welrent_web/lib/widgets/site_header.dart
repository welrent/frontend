import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import 'common.dart';
import 'icons.dart';

class SiteHeader extends ConsumerStatefulWidget {
  const SiteHeader({super.key, required this.scrolled, this.dark = false});

  final bool scrolled;
  final bool dark;

  @override
  ConsumerState<SiteHeader> createState() => _SiteHeaderState();
}

class _SiteHeaderState extends ConsumerState<SiteHeader> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _submitSearch() {
    final query = _search.text.trim();
    final target = query.isEmpty
        ? '/offerlist'
        : '/offerlist?q=${Uri.encodeQueryComponent(query)}';
    context.go(target);
  }

  Color _linkColor(bool hover) {
    if (widget.dark) {
      return hover ? Colors.white : Colors.white.withValues(alpha: 0.62);
    }
    return hover ? AppColors.accentBlue : AppColors.fieldText;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = AppBreakpoints.isMobile(width);
    final compact = width < 1100;
    final catalog = ref.watch(catalogProvider).valueOrNull;
    final links = visibleNavLinks(catalog?.navbar ?? DemoData.navbar);
    final auth = ref.watch(authControllerProvider);
    final user = auth.user;
    final location = GoRouterState.of(context).uri.path;
    final background = widget.dark
        ? (widget.scrolled ? const Color(0xCC000000) : Colors.transparent)
        : (widget.scrolled ? AppColors.bgWhite : Colors.transparent);
    final border = widget.dark
        ? Colors.white.withValues(alpha: widget.scrolled ? 0.1 : 0)
        : (widget.scrolled ? AppColors.gridLine : Colors.transparent);

    return Material(
      color: background,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: border)),
        ),
        child: CenteredContainer(
          child: mobile
              ? _mobile(links, auth, user)
              : _desktop(links, auth, user, location, compact),
        ),
      ),
    );
  }

  Widget _desktop(
    List links,
    AuthState auth,
    dynamic user,
    String location,
    bool compact,
  ) {
    return SizedBox(
      height: 65,
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _logo(),
            if (!compact) ...[
              const SizedBox(width: 40),
              SizedBox(width: 260, child: _searchField(compact: false)),
            ] else
              const SizedBox(width: 20),
            const SizedBox(width: 28),
            for (final link in links) ...[
              _NavText(
                label: link.title as String,
                colorBuilder: _linkColor,
                onTap: () => _open(link.url as String),
              ),
              const SizedBox(width: 22),
            ],
            if (!compact) ...[
              _iconLink('/offerlist?type=motorbike', 'moto', 'Motorbikes'),
              const SizedBox(width: 8),
              _iconLink('/offerlist?type=car', 'car-side', 'Cars'),
              const SizedBox(width: 8),
              _iconLink('/offerlist?type=boat', 'boat', 'Boats'),
              Container(
                width: 1,
                height: 24,
                margin: const EdgeInsets.symmetric(horizontal: 14),
                color: widget.dark
                    ? Colors.white.withValues(alpha: 0.18)
                    : AppColors.borderLight.withValues(alpha: 0.8),
              ),
            ],
            if (user != null && !compact) ...[
              _iconLink('/chat', 'chat', 'Chat', darkIcon: widget.dark),
              const SizedBox(width: 4),
              _iconLink(
                '/bookings',
                'calendar',
                'My Bookings',
                darkIcon: widget.dark,
              ),
              const SizedBox(width: 4),
              _notifyLink(),
              const SizedBox(width: 12),
            ],
            _authLabel(auth, user),
            const SizedBox(width: 12),
            _avatar(user),
          ],
        ),
      ),
    );
  }

  Widget _mobile(List links, AuthState auth, dynamic user) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Column(
        children: [
          _logo(),
          const SizedBox(height: 12),
          _searchField(compact: true),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _NavText(
                label: 'Welrent Act',
                colorBuilder: (_) => AppColors.accentBlue,
                weight: FontWeight.w700,
                onTap: () => context.go('/act'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '·',
                  style: AppText.outfit(color: AppColors.textMuted),
                ),
              ),
              if (auth.status == AuthStatus.loading)
                Text(
                  '...',
                  style: AppText.outfit(size: 13, color: AppColors.textMuted),
                )
              else if (user != null)
                _NavText(
                  label: user.label as String,
                  colorBuilder: (_) => AppColors.accentBlue,
                  weight: FontWeight.w700,
                  onTap: () => context.go('/account'),
                )
              else
                Flexible(
                  child: _NavText(
                    label: 'You are not logged in',
                    colorBuilder: (_) => AppColors.textMuted,
                    onTap: () => context.go('/login'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _logo() {
    return GestureDetector(
      onTap: () => context.go('/'),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: BrandLogo(height: 40, invert: widget.dark),
      ),
    );
  }

  Widget _searchField({required bool compact}) {
    final focus = ref.watch(headerSearchFocusProvider);
    return Container(
      width: double.infinity,
      height: 34,
      padding: const EdgeInsets.only(left: 14, right: 8),
      decoration: BoxDecoration(
        color: widget.dark
            ? Colors.white.withValues(alpha: 0.08)
            : AppColors.searchBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          AppIcon('search', size: 14, color: AppColors.iconGrey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _search,
              focusNode: focus,
              onSubmitted: (_) => _submitSearch(),
              style: AppText.outfit(
                size: 13.6,
                color: widget.dark ? Colors.white : AppColors.textPrimary,
              ),
              cursorColor: AppColors.accentBlue,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search...',
                hintStyle: AppText.outfit(
                  size: 13.6,
                  color: AppColors.iconGrey,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (!compact)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.kbdBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '⌘ K',
                style: AppText.outfit(
                  size: 10,
                  weight: FontWeight.w600,
                  color: AppColors.bodyGrey,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _authLabel(AuthState auth, dynamic user) {
    if (auth.status == AuthStatus.loading) {
      return Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.borderLight,
          shape: BoxShape.circle,
        ),
      );
    }
    if (user != null) {
      return _NavText(
        label: user.label as String,
        colorBuilder: (hover) => hover
            ? AppColors.accentBlue
            : (widget.dark ? Colors.white : AppColors.textPrimary),
        weight: FontWeight.w700,
        onTap: () => context.go('/account'),
      );
    }
    return _NavText(
      label: 'You are not logged in',
      colorBuilder: _linkColor,
      onTap: () => context.go('/login'),
    );
  }

  Widget _avatar(dynamic user) {
    final photo = user?.photoUrl as String?;
    return Tooltip(
      message: user == null ? 'Log in' : 'Account',
      child: GestureDetector(
        onTap: () => context.go(user == null ? '/login' : '/account'),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: 32,
            height: 32,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: AppColors.searchBg,
              shape: BoxShape.circle,
            ),
            child: photo != null && photo.isNotEmpty
                ? RemoteOrAssetImage(source: photo, fit: BoxFit.cover)
                : const Center(
                    child: AppIcon('user', size: 14, color: AppColors.iconGrey),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _iconLink(
    String url,
    String icon,
    String tooltip, {
    bool darkIcon = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: _HoverIcon(
        onTap: () => context.go(url),
        child: AppIcon(
          icon,
          size: 20,
          color: darkIcon
              ? Colors.white.withValues(alpha: 0.85)
              : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _notifyLink() {
    final unread = ref
        .watch(notificationControllerProvider)
        .any((item) => item.unread);
    return Tooltip(
      message: 'Notifications',
      child: _HoverIcon(
        onTap: () => context.go('/notifications'),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AppIcon(
              'bell',
              size: 20,
              color: widget.dark
                  ? Colors.white.withValues(alpha: 0.85)
                  : AppColors.textPrimary,
            ),
            if (unread)
              const Positioned(
                top: -2,
                right: -2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFFFF4D4F),
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(color: Colors.white, width: 1.5),
                    ),
                  ),
                  child: SizedBox(width: 8, height: 8),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _open(String url) {
    if (url.startsWith('/')) {
      context.go(url);
    } else {
      openExternal(url);
    }
  }
}

class _NavText extends StatefulWidget {
  const _NavText({
    required this.label,
    required this.onTap,
    required this.colorBuilder,
    this.weight = FontWeight.w500,
    this.overflow,
  });

  final String label;
  final VoidCallback onTap;
  final Color Function(bool hover) colorBuilder;
  final FontWeight weight;
  final TextOverflow? overflow;

  @override
  State<_NavText> createState() => _NavTextState();
}

class _NavTextState extends State<_NavText> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.label,
          maxLines: 1,
          overflow: widget.overflow,
          style: AppText.outfit(
            size: 13.6,
            weight: widget.weight,
            color: widget.colorBuilder(_hover),
          ),
        ),
      ),
    );
  }
}

class _HoverIcon extends StatefulWidget {
  const _HoverIcon({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_HoverIcon> createState() => _HoverIconState();
}

class _HoverIconState extends State<_HoverIcon> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hover ? AppColors.searchBg : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class MobileBottomNav extends ConsumerWidget {
  const MobileBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    if (!AppBreakpoints.isMobile(width)) return const SizedBox.shrink();
    final links = visibleNavLinks(
      ref.watch(catalogProvider).valueOrNull?.navbar ?? DemoData.navbar,
    );
    final user = ref.watch(authControllerProvider).user;
    final path = GoRouterState.of(context).uri.path;
    final items = <_BottomItem>[
      const _BottomItem('Home', '/', 'home'),
      for (final link in links) _BottomItem(link.title, link.url, 'clock'),
      _BottomItem(
        user == null ? 'Login' : 'Account',
        user == null ? '/login' : '/account',
        'user',
      ),
    ];

    return Material(
      color: Colors.white,
      elevation: 12,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.borderLight)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
            child: Row(
              children: [
                for (final item in items)
                  Expanded(
                    child: _BottomButton(
                      item: item,
                      active: _active(path, item.url),
                      onTap: () {
                        if (item.url.startsWith('/')) {
                          context.go(item.url);
                        } else {
                          openExternal(item.url);
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _active(String path, String url) {
    if (!url.startsWith('/')) return false;
    final target = url.split('?').first;
    if (target == '/') return path == '/';
    return path == target || path.startsWith('$target/');
  }
}

class _BottomItem {
  const _BottomItem(this.label, this.url, this.icon);
  final String label;
  final String url;
  final String icon;
}

class _BottomButton extends StatelessWidget {
  const _BottomButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _BottomItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.accentBlue : AppColors.textMuted;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(item.icon, size: 22, color: color),
            const SizedBox(height: 5),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppText.outfit(
                size: 11.2,
                weight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchShortcut extends ConsumerWidget {
  const SearchShortcut({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () {
          ref.read(headerSearchFocusProvider).requestFocus();
        },
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () {
          ref.read(headerSearchFocusProvider).requestFocus();
        },
      },
      child: child,
    );
  }
}
