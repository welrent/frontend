import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';

class AppIcon extends StatelessWidget {
  const AppIcon(
    this.name, {
    super.key,
    this.size = 20,
    this.color,
    this.strokeWidth = 2,
  });

  final String name;
  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final paint = color ?? AppColors.textPrimary;
    return SvgPicture.string(
      _svg(name, strokeWidth),
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(paint, BlendMode.srcIn),
    );
  }

  static String _svg(String name, double stroke) {
    final body = _paths[name] ?? _paths['circle']!;
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" '
        'stroke="currentColor" stroke-width="$stroke" stroke-linecap="round" '
        'stroke-linejoin="round">$body</svg>';
  }

  static const _paths = <String, String>{
    'search': '<circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line>',
    'chevron-left': '<polyline points="15 18 9 12 15 6"></polyline>',
    'chevron-right': '<polyline points="9 18 15 12 9 6"></polyline>',
    'car': '<rect x="3" y="10" width="18" height="9" rx="2"></rect><path d="M4 10L6.5 5h11l2.5 5"></path><circle cx="7" cy="19" r="2"></circle><circle cx="17" cy="19" r="2"></circle>',
    'car-side': '<path d="M19 17h2c.6 0 1-.4 1-1v-3c0-.9-.7-1.7-1.5-1.9C18.7 10.6 16 10 16 10s-1.3-1.4-2.2-2.3c-.5-.4-1.1-.7-1.8-.7H5c-.6 0-1.1.4-1.4.9l-1.5 2.8C1.4 11 1 11.7 1 12.5V16c0 .6.4 1 1 1h2"></path><circle cx="7" cy="17" r="2"></circle><circle cx="17" cy="17" r="2"></circle>',
    'moto': '<circle cx="7" cy="18" r="2"></circle><circle cx="17" cy="18" r="2"></circle><path d="M12 18V9c0-1.1.9-2 2-2h3l2 2v2"></path><path d="M16 9h4"></path><path d="M7 18h10"></path><path d="M9 10l-2 2"></path>',
    'boat': '<path d="M2 12c.6 0 1.2.2 1.6.6l3.8 3.8a2 2 0 0 0 2.8 0l3.8-3.8c.4-.4 1-.6 1.6-.6h6.2a2 2 0 0 1 2 2v2a2 2 0 0 1-2 2H2v-6z"></path><path d="M11 12V3"></path><path d="M15 7l-4-4-4 4"></path>',
    'target': '<circle cx="12" cy="12" r="10"></circle><circle cx="12" cy="12" r="3"></circle>',
    'user': '<path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle>',
    'chat': '<path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>',
    'calendar': '<rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line>',
    'bell': '<path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path>',
    'home': '<path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline>',
    'clock': '<circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline>',
    'mail': '<path d="M4 4h16v16H4z"></path><polyline points="22 6 12 13 2 6"></polyline>',
    'edit': '<path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>',
    'camera': '<path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"></path><circle cx="12" cy="13" r="4"></circle>',
    'logout': '<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path><polyline points="16 17 21 12 16 7"></polyline><line x1="21" y1="12" x2="9" y2="12"></line>',
    'pin': '<path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle>',
    'check': '<path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline>',
    'tag': '<path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"></path><line x1="7" y1="7" x2="7.01" y2="7"></line>',
    'shield': '<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>',
    'paperclip': '<path d="M21.44 11.05l-9.19 9.19a6 6 0 0 1-8.49-8.49l9.19-9.19a4 4 0 0 1 5.66 5.66l-9.2 9.19a2 2 0 0 1-2.83-2.83l8.49-8.48"></path>',
    'send': '<line x1="22" y1="2" x2="11" y2="13"></line><polygon points="22 2 15 22 11 13 2 9 22 2"></polygon>',
    'video': '<path d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"></path>',
    'plus': '<path d="M12 5v14M5 12h14"></path>',
    'apple': '<path d="M17 20c-1 .9-2 .8-3 .4-1-.5-2-.5-3.2 0-1.4.6-2.2.4-3-.4C3 15 3.5 7.5 9 7.3c1.3 0 2.3.7 3 .7.7 0 2-.9 3.5-.7 1.5 0 2.8.6 3.6 1.8-3 1.9-2.6 5.4 0 6.6-.7 1.5-1.5 2.5-2.1 4.3zM12 7.2c0-2.2 1.7-4 3.7-4.2.3 2.4-2 4.4-3.7 4.2z"></path>',
    'play': '<path d="M3 20.5v-17c0-.5.5-.8 1-.5l15 8c.5.3.5 1.1 0 1.4l-15 8c-.5.3-1 0-1-.5z"></path>',
    'circle': '<circle cx="12" cy="12" r="9"></circle>',
  };
}
