import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:welrent_web/screens/home_screen.dart';

import 'support/harness.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  testWidgets('home shows the RS6 hero and signed-out header', (tester) async {
    await pumpWelrent(tester);
    expect(find.textContaining('an RS6'), findsWidgets);
    expect(find.text('You are not logged in'), findsOneWidget);
    expect(find.text('Explore Our Car Categories'), findsOneWidget);
    expect(find.text('Hatchback'), findsOneWidget);
  });

  testWidgets('header navigation opens Locations, Act, and the offer list', (
    tester,
  ) async {
    await pumpWelrent(tester);

    await tester.tap(find.text('Locations').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Our Locations'), findsOneWidget);
    expect(find.text('Nederland'), findsOneWidget);

    final context = tester.element(find.byType(Scaffold).first);
    GoRouter.of(context).go('/act');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('Welrent Act'), findsWidgets);

    GoRouter.of(context).go('/offerlist');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('View Deal'), findsWidgets);
    expect(find.textContaining('\$120'), findsWidgets);
  });

  testWidgets('login requires an email and password before calling auth', (
    tester,
  ) async {
    await pumpWelrent(tester);
    final context = tester.element(find.byType(HomeScreen));
    GoRouter.of(context).go('/login');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Welcome back'), findsOneWidget);
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    expect(find.text('Enter your email and password.'), findsOneWidget);
  });

  testWidgets('bookings keep the original upcoming and history tabs', (
    tester,
  ) async {
    await pumpWelrent(tester);
    final context = tester.element(find.byType(HomeScreen));
    GoRouter.of(context).go('/bookings');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('UPCOMING & ACTIVE'), findsOneWidget);
    expect(find.text('HISTORY'), findsOneWidget);
    expect(find.text('Audi RS6 Avant'), findsOneWidget);

    await tester.tap(find.text('HISTORY'));
    await tester.pump();
    expect(find.text('Mangusta 108'), findsOneWidget);
  });

  testWidgets('mobile width shows the signed-out prompt', (tester) async {
    await pumpWelrent(tester, size: const Size(390, 844));
    expect(find.text('You are not logged in'), findsOneWidget);
    expect(find.textContaining('an RS6'), findsWidgets);
  });
}
