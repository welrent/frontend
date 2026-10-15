class NavLink {
  const NavLink({required this.title, required this.url});

  final String title;
  final String url;

  factory NavLink.fromJson(Map<String, dynamic> json) {
    return NavLink(
      title: '${json['title'] ?? ''}',
      url: '${json['url'] ?? '#'}',
    );
  }
}

class SiteContent {
  const SiteContent({
    required this.footerBrandDesc,
    required this.footerCopyright,
  });

  final String footerBrandDesc;
  final String footerCopyright;

  factory SiteContent.fromJson(Map<String, dynamic> json) {
    return SiteContent(
      footerBrandDesc: '${json['footer_brand_desc'] ?? ''}',
      footerCopyright: '${json['footer_copyright'] ?? ''}',
    );
  }
}

class Car {
  const Car({
    required this.id,
    required this.name,
    required this.slug,
    required this.subtitle,
    required this.photoUrl,
    required this.isDarkMode,
    required this.price,
  });

  final int id;
  final String name;
  final String slug;
  final String subtitle;
  final String photoUrl;
  final bool isDarkMode;
  final num price;

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: parseInt(json['id']),
      name: '${json['name'] ?? ''}',
      slug: '${json['slug'] ?? ''}',
      subtitle: '${json['subtitle'] ?? ''}',
      photoUrl: '${json['photo_url'] ?? json['photoUrl'] ?? ''}',
      isDarkMode: parseBool(json['is_dark_mode'] ?? json['isDarkMode']),
      price: parseNum(json['price'], 150),
    );
  }

  bool matchesSlug(String value) {
    return slug == value || name == value.replaceAll('-', ' ');
  }
}

class Rental {
  const Rental({
    required this.bookingRef,
    required this.carName,
    required this.carImage,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.price,
    required this.status,
    required this.location,
  });

  final String bookingRef;
  final String carName;
  final String carImage;
  final String startDate;
  final String endDate;
  final int days;
  final num price;
  final String status;
  final String location;

  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      bookingRef: '${json['booking_ref'] ?? ''}',
      carName: '${json['car_name'] ?? ''}',
      carImage: '${json['car_image'] ?? ''}',
      startDate: '${json['start_date'] ?? ''}',
      endDate: '${json['end_date'] ?? ''}',
      days: parseInt(json['days']),
      price: parseNum(json['price']),
      status: '${json['status'] ?? 'upcoming'}',
      location: '${json['location'] ?? ''}',
    );
  }
}

class Booking {
  const Booking({
    required this.id,
    required this.type,
    required this.name,
    required this.image,
    required this.status,
    required this.dates,
    required this.location,
    required this.total,
    required this.active,
    this.local = false,
  });

  final String id;
  final String type;
  final String name;
  final String image;
  final String status;
  final String dates;
  final String location;
  final String total;
  final bool active;
  final bool local;

  Booking copyWith({String? status, bool? active}) {
    return Booking(
      id: id,
      type: type,
      name: name,
      image: image,
      status: status ?? this.status,
      dates: dates,
      location: location,
      total: total,
      active: active ?? this.active,
      local: local,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'name': name,
    'image': image,
    'status': status,
    'dates': dates,
    'location': location,
    'total': total,
    'active': active,
    'local': local,
  };

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: '${json['id'] ?? ''}',
      type: '${json['type'] ?? 'car'}',
      name: '${json['name'] ?? ''}',
      image: '${json['image'] ?? ''}',
      status: '${json['status'] ?? ''}',
      dates: '${json['dates'] ?? ''}',
      location: '${json['location'] ?? ''}',
      total: '${json['total'] ?? ''}',
      active: parseBool(json['active']),
      local: parseBool(json['local']),
    );
  }
}

class SessionUser {
  const SessionUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.token,
    this.refreshToken,
    this.bio = '',
    this.provider = 'api',
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? token;
  final String? refreshToken;
  final String bio;
  final String provider;

  String get label {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final at = email.split('@').first;
    return at.isEmpty ? 'Account' : at;
  }

  String get initials {
    final parts = label.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final chars = parts.map((p) => p[0]).take(2).join();
    return chars.toUpperCase();
  }

  SessionUser copyWith({
    String? displayName,
    String? photoUrl,
    String? bio,
    String? token,
  }) {
    return SessionUser(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      token: token ?? this.token,
      refreshToken: refreshToken,
      bio: bio ?? this.bio,
      provider: provider,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'token': token,
    'refreshToken': refreshToken,
    'bio': bio,
    'provider': provider,
  };

  factory SessionUser.fromJson(Map<String, dynamic> json) {
    return SessionUser(
      id: '${json['id'] ?? ''}',
      email: '${json['email'] ?? ''}',
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
      bio: '${json['bio'] ?? ''}',
      provider: '${json['provider'] ?? 'api'}',
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.time,
  });

  final int id;
  final String sender;
  final String text;
  final String time;
}

class Conversation {
  const Conversation({
    required this.id,
    required this.name,
    required this.avatar,
    required this.time,
    required this.messages,
    this.online = false,
  });

  final int id;
  final String name;
  final String avatar;
  final String time;
  final List<ChatMessage> messages;
  final bool online;

  String get lastMsg => messages.isEmpty ? '' : messages.last.text;

  Conversation copyWith({String? time, List<ChatMessage>? messages}) {
    return Conversation(
      id: id,
      name: name,
      avatar: avatar,
      time: time ?? this.time,
      messages: messages ?? this.messages,
      online: online,
    );
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.time,
    required this.unread,
  });

  final int id;
  final String type;
  final String title;
  final String description;
  final String time;
  final bool unread;

  AppNotification copyWith({bool? unread}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      description: description,
      time: time,
      unread: unread ?? this.unread,
    );
  }
}

class ActPageLink {
  const ActPageLink({
    required this.title,
    required this.body,
    required this.path,
  });

  final String title;
  final String body;
  final String path;
}

class FleetItem {
  const FleetItem({
    required this.name,
    required this.price,
    required this.specs,
    required this.image,
  });

  final String name;
  final String price;
  final String specs;
  final String image;
}

class Destination {
  const Destination({
    required this.slug,
    required this.name,
    required this.fullName,
    required this.price,
    required this.image,
    required this.about,
    required this.cars,
    required this.boats,
  });

  final String slug;
  final String name;
  final String fullName;
  final String price;
  final String image;
  final String about;
  final List<FleetItem> cars;
  final List<FleetItem> boats;
}

class Catalog {
  const Catalog({
    required this.cars,
    required this.navbar,
    required this.footer,
    required this.content,
  });

  final List<Car> cars;
  final List<NavLink> navbar;
  final Map<String, List<NavLink>> footer;
  final SiteContent content;
}

class AuthResult {
  const AuthResult({this.user, this.error});

  final SessionUser? user;
  final String? error;

  bool get ok => user != null && (error == null || error!.isEmpty);
}

int parseInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

num parseNum(dynamic value, [num fallback = 0]) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value) ?? fallback;
  return fallback;
}

bool parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase();
    return normalized == '1' || normalized == 'true' || normalized == 'yes';
  }
  return false;
}

String formatGrouped(num value) {
  final rounded = value.round();
  final negative = rounded < 0;
  final digits = rounded.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '${negative ? '-' : ''}$buffer';
}

String formatClock(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  final suffix = value.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}

String formatDateTime(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$month/$day/${value.year}, ${formatClock(value)}';
}

String isoDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
