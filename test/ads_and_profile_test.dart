import 'package:bozorpro/core/widgets/user_avatar.dart';
import 'package:bozorpro/features/ads/ads_carousel.dart';
import 'package:bozorpro/features/auth/data/auth_models.dart';
import 'package:bozorpro/features/extras/data/extras_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AuthUser parses avatar and sms reminder flag', () {
    final AuthUser user = AuthUser.fromJson(<String, dynamic>{
      'id': 1,
      'name': 'Bro',
      'phone': '+998901234567',
      'avatar_url': 'https://x.uz/storage/avatars/a.jpg',
      'sms_reminders': false,
    });
    expect(user.avatarUrl, 'https://x.uz/storage/avatars/a.jpg');
    expect(user.smsReminders, isFalse);
    expect(user.copyWith(name: 'Ali').avatarUrl, user.avatarUrl);

    final AuthUser plain = AuthUser.fromJson(<String, dynamic>{
      'id': 2,
      'name': 'Vali',
      'phone': '+998900000000',
    });
    expect(plain.avatarUrl, isNull);
    expect(plain.smsReminders, isTrue);
  });

  test('AdBanner parses api json', () {
    final AdBanner banner = AdBanner.fromJson(<String, dynamic>{
      'id': 7,
      'title': 'Aksiya',
      'url': 'https://example.uz',
      'image_url': 'https://example.uz/b.jpg',
    });
    expect(banner.id, 7);
    expect(banner.url, 'https://example.uz');
  });

  testWidgets('carousel shows banners with page dots', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(380, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: AdsCarouselView(
              banners: <AdBanner>[
                AdBanner(id: 1, title: 'Birinchi', url: 'https://a.uz', imageUrl: 'http://127.0.0.1:1/a.jpg'),
                AdBanner(id: 2, title: 'Ikkinchi', url: 'https://b.uz', imageUrl: 'http://127.0.0.1:1/b.jpg'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.byType(PageView), findsOneWidget);
    // Avto-aylantirish: 5 soniyadan so'ng ikkinchi banner
    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);
  });

  testWidgets('user avatar falls back to initial', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: UserAvatar(name: 'bro'))),
    );
    expect(find.text('B'), findsOneWidget);
  });
}
