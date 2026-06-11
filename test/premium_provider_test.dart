import 'package:flutter_pdf/core/premium/premium_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Premium access rules', () {
    test('compress and encrypt PDF require the lifetime purchase', () {
      const freeState = PremiumState();

      expect(freeState.canAccess('compress_pdf'), isFalse);
      expect(freeState.canAccess('encrypt_pdf'), isFalse);
    });

    test('compress and encrypt PDF are available after purchase', () {
      const premiumState = PremiumState(
        isPremium: true,
        plan: PremiumPlan.lifetime,
      );

      expect(premiumState.canAccess('compress_pdf'), isTrue);
      expect(premiumState.canAccess('encrypt_pdf'), isTrue);
    });

    test('free tools remain available without purchase', () {
      const freeState = PremiumState();

      expect(freeState.canAccess('image_to_pdf'), isTrue);
      expect(freeState.canAccess('pdf_to_long_image'), isTrue);
      expect(freeState.canAccess('edit_pdf_text'), isTrue);
      expect(freeState.canAccess('merge_pdf'), isTrue);
    });

    test('Google Play one-time product id matches the Android application id',
        () {
      expect(
        PremiumNotifier.kLifetimeProductId,
        'com.dt.pdf.flutter_pdf.lifetime',
      );
    });

    test('only the configured Google Play product can activate Pro', () {
      expect(
        PremiumNotifier.isKnownProductId('com.dt.pdf.flutter_pdf.lifetime'),
        isTrue,
      );
      expect(
        PremiumNotifier.isKnownProductId('com.dt.pdf.flutter_pdf.monthly'),
        isFalse,
      );
    });

    test('restoring state is tracked separately from regular loading', () {
      const state = PremiumState();
      final restoringState = state.copyWith(isLoading: true, isRestoring: true);

      expect(restoringState.isLoading, isTrue);
      expect(restoringState.isRestoring, isTrue);
      expect(restoringState.isPremium, isFalse);
    });
  });
}
