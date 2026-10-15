import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/catalog.dart';
import '../theme/app_theme.dart';
import 'icons.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.height = 40,
    this.word = 'Cars',
    this.invert = false,
  });

  final double height;
  final String word;
  final bool invert;

  @override
  Widget build(BuildContext context) {
    final mark = invert ? Colors.white : AppColors.purple;
    final wordColor = invert ? Colors.white : AppColors.wordmark;
    final bar = invert
        ? Colors.white.withValues(alpha: 0.7)
        : AppColors.dividerGrey;
    return Semantics(
      label: 'Welrent $word',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            BrandAssets.logoMark,
            height: height * 0.62,
            colorFilter: ColorFilter.mode(mark, BlendMode.srcIn),
          ),
          SizedBox(width: height * 0.14),
          Container(width: 1.4, height: height * 0.52, color: bar),
          SizedBox(width: height * 0.12),
          Text(
            word,
            style: AppText.tinos(size: height * 0.72, color: wordColor),
          ),
        ],
      ),
    );
  }
}

class CenteredContainer extends StatelessWidget {
  const CenteredContainer({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.content,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width < AppBreakpoints.mobile ? 20.0 : 40.0;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.symmetric(horizontal: horizontal),
          child: child,
        ),
      ),
    );
  }
}

class HoverButton extends StatefulWidget {
  const HoverButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.background = AppColors.accentBlue,
    this.hoverBackground = AppColors.accentBlueHover,
    this.foreground = Colors.white,
    this.borderColor,
    this.radius = 4,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.shadow,
    this.enabled = true,
    this.semanticLabel,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color background;
  final Color hoverBackground;
  final Color foreground;
  final Color? borderColor;
  final double radius;
  final EdgeInsetsGeometry padding;
  final List<BoxShadow>? shadow;
  final bool enabled;
  final String? semanticLabel;

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled && widget.onPressed != null;
    return MouseRegion(
      cursor: active ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Semantics(
        button: true,
        enabled: active,
        label: widget.semanticLabel,
        child: GestureDetector(
          onTap: active ? widget.onPressed : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: widget.padding,
            decoration: BoxDecoration(
              color: !active
                  ? widget.background.withValues(alpha: 0.5)
                  : _hover
                  ? widget.hoverBackground
                  : widget.background,
              borderRadius: BorderRadius.circular(widget.radius),
              border: widget.borderColor == null
                  ? null
                  : Border.all(color: widget.borderColor!),
              boxShadow: widget.shadow,
            ),
            child: IconTheme(
              data: IconThemeData(color: widget.foreground),
              child: DefaultTextStyle(
                style: AppText.outfit(
                  size: 14.4,
                  weight: FontWeight.w600,
                  color: widget.foreground,
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppSpinner extends StatelessWidget {
  const AppSpinner({super.key, this.size = 18, this.color = Colors.white});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(strokeWidth: 2.4, color: color),
    );
  }
}

Future<void> showAppMessage(
  BuildContext context, {
  required String message,
  String title = 'Welrent',
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.outfit(size: 20, weight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: AppText.outfit(
                    size: 15,
                    color: AppColors.bodyGrey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                Align(
                  alignment: Alignment.centerRight,
                  child: HoverButton(
                    onPressed: () => Navigator.of(context).pop(),
                    background: AppColors.textPrimary,
                    hoverBackground: const Color(0xFF2D3A54),
                    radius: 10,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    child: const Text('OK'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  bool danger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.outfit(size: 22, weight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: AppText.outfit(
                    size: 15,
                    color: AppColors.bodyGrey,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancel',
                        style: AppText.outfit(
                          size: 14,
                          weight: FontWeight.w600,
                          color: AppColors.fieldText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HoverButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      background: danger
                          ? AppColors.error
                          : AppColors.textPrimary,
                      hoverBackground: danger
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFF2D3A54),
                      radius: 10,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      child: Text(confirmLabel),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  return result ?? false;
}

Future<void> openExternal(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  await launchUrl(uri, webOnlyWindowName: '_blank');
}

class RemoteOrAssetImage extends StatelessWidget {
  const RemoteOrAssetImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String source;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (source.isEmpty) return _fallback();
    if (source.startsWith('data:')) {
      try {
        final bytes = _decodeDataUrl(source);
        return Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, _, _) => _fallback(),
        );
      } catch (_) {
        return _fallback();
      }
    }
    if (source.startsWith('http')) {
      return Image.network(
        source,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }
    final asset = resolveAssetPath(source);
    return Image.asset(
      asset,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, _, _) => _fallback(),
    );
  }

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      color: AppColors.infoBg,
      alignment: Alignment.center,
      child: const AppIcon('car', color: AppColors.fieldText, size: 28),
    );
  }
}

Uint8List _decodeDataUrl(String source) {
  final comma = source.indexOf(',');
  final payload = comma >= 0 ? source.substring(comma + 1) : source;
  return base64Decode(payload);
}

String resolveAssetPath(String source) {
  var path = source;
  if (path.startsWith('/')) path = path.substring(1);
  if (path.startsWith('assets/brand/')) return path;
  if (path.startsWith('assets/')) {
    return 'assets/brand/${path.substring('assets/'.length)}';
  }
  return path;
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppText.outfit(size: 24, weight: FontWeight.w700),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
