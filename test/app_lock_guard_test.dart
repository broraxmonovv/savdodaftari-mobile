import 'package:bozorpro/features/auth/state/app_lock_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(AppLockGuard.reset);

  test('lock is suspended while an external screen (camera/gallery) is open', () async {
    expect(AppLockGuard.suspended, isFalse);

    late bool during;
    await AppLockGuard.run<void>(() async {
      during = AppLockGuard.suspended;
    });

    expect(during, isTrue);
    // Tugagandan keyin ham qisqa muddat himoya (lifecycle `resumed` kechiksa)
    expect(AppLockGuard.suspended, isTrue);
  });

  test('suspension is released even if the action throws', () async {
    await expectLater(
      AppLockGuard.run<void>(() async => throw StateError('picker failed')),
      throwsStateError,
    );
    AppLockGuard.reset();
    expect(AppLockGuard.suspended, isFalse);
  });

  test('suspendFor keeps the longest window', () {
    AppLockGuard.suspendFor(const Duration(minutes: 10));
    AppLockGuard.suspendFor(const Duration(seconds: 5));
    expect(AppLockGuard.suspended, isTrue);
  });
}
