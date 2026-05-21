import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

/// Feature access levels
enum FeatureAccess { free, premium }

/// Premium state model
class PremiumState {
  final bool isPremium;
  final DateTime? expiryDate;

  const PremiumState({
    this.isPremium = false,
    this.expiryDate,
  });

  /// Feature access map: free vs premium
  static const Map<String, FeatureAccess> featureAccess = {
    // Free features
    'pdf_read': FeatureAccess.free,
    'pdf_night_mode': FeatureAccess.free,
    'pdf_bookmark': FeatureAccess.free,
    'pdf_merge': FeatureAccess.free,
    'pdf_to_image': FeatureAccess.free,
    // Premium features
    'pdf_annotate': FeatureAccess.premium,
    'pdf_highlight': FeatureAccess.premium,
    'pdf_split': FeatureAccess.premium,
    'pdf_delete_page': FeatureAccess.premium,
    'pdf_reorder': FeatureAccess.premium,
    'pdf_compress': FeatureAccess.premium,
    'image_to_pdf': FeatureAccess.premium,
    'pdf_encrypt': FeatureAccess.premium,
  };

  bool canAccess(String feature) {
    final access = featureAccess[feature];
    if (access == null || access == FeatureAccess.free) return true;
    return isPremium;
  }

  PremiumState copyWith({
    bool? isPremium,
    DateTime? expiryDate,
  }) =>
      PremiumState(
        isPremium: isPremium ?? this.isPremium,
        expiryDate: expiryDate ?? this.expiryDate,
      );
}

/// Premium state manager
class PremiumNotifier extends StateNotifier<PremiumState> {
  static const String _boxName = 'premium_box';
  static const String _isPremiumKey = 'is_premium';
  static const String _expiryDateKey = 'expiry_date';

  PremiumNotifier() : super(const PremiumState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    final box = await Hive.openBox(_boxName);
    final isPremium = box.get(_isPremiumKey, defaultValue: false) as bool;
    final expiryMillis = box.get(_expiryDateKey) as int?;
    state = PremiumState(
      isPremium: isPremium,
      expiryDate: expiryMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(expiryMillis)
          : null,
    );
  }

  Future<void> _saveState() async {
    final box = await Hive.openBox(_boxName);
    await box.put(_isPremiumKey, state.isPremium);
    if (state.expiryDate != null) {
      await box.put(_expiryDateKey, state.expiryDate!.millisecondsSinceEpoch);
    }
  }

  Future<void> activatePremium() async {
    state = PremiumState(
      isPremium: true,
      expiryDate: DateTime.now().add(const Duration(days: 365)),
    );
    await _saveState();
  }
}

/// Premium Provider
final premiumProvider = StateNotifierProvider<PremiumNotifier, PremiumState>(
  (ref) => PremiumNotifier(),
);
