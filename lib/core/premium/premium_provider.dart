import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

/// Feature access levels
enum FeatureAccess { free, premium }

/// Premium plan types
enum PremiumPlan { none, monthly, yearly, lifetime }

/// Premium state model
class PremiumState {
  final bool isPremium;
  final DateTime? expiryDate;
  final PremiumPlan plan;
  final String? transactionId;

  const PremiumState({
    this.isPremium = false,
    this.expiryDate,
    this.plan = PremiumPlan.none,
    this.transactionId,
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
    
    // Check if premium is active and not expired
    if (!isPremium) return false;
    if (expiryDate != null && expiryDate!.isBefore(DateTime.now())) return false;
    
    return true;
  }

  PremiumState copyWith({
    bool? isPremium,
    DateTime? expiryDate,
    PremiumPlan? plan,
    String? transactionId,
  }) =>
      PremiumState(
        isPremium: isPremium ?? this.isPremium,
        expiryDate: expiryDate ?? this.expiryDate,
        plan: plan ?? this.plan,
        transactionId: transactionId ?? this.transactionId,
      );
}

/// Premium state manager
class PremiumNotifier extends StateNotifier<PremiumState> {
  static const String _boxName = 'premium_box';
  static const String _isPremiumKey = 'is_premium';
  static const String _expiryDateKey = 'expiry_date';
  static const String _planKey = 'premium_plan';
  static const String _transactionIdKey = 'transaction_id';

  PremiumNotifier() : super(const PremiumState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    final box = await Hive.openBox(_boxName);
    final isPremium = box.get(_isPremiumKey, defaultValue: false) as bool;
    final expiryMillis = box.get(_expiryDateKey) as int?;
    final planIndex = box.get(_planKey, defaultValue: 0) as int;
    final transactionId = box.get(_transactionIdKey) as String?;

    state = PremiumState(
      isPremium: isPremium,
      expiryDate: expiryMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(expiryMillis)
          : null,
      plan: PremiumPlan.values[planIndex],
      transactionId: transactionId,
    );
    
    // Check for expiration
    if (state.isPremium && state.expiryDate != null && state.expiryDate!.isBefore(DateTime.now())) {
      state = const PremiumState();
      await _saveState();
    }
  }

  Future<void> _saveState() async {
    final box = await Hive.openBox(_boxName);
    await box.put(_isPremiumKey, state.isPremium);
    await box.put(_planKey, state.plan.index);
    if (state.expiryDate != null) {
      await box.put(_expiryDateKey, state.expiryDate!.millisecondsSinceEpoch);
    } else {
      await box.delete(_expiryDateKey);
    }
    if (state.transactionId != null) {
      await box.put(_transactionIdKey, state.transactionId);
    } else {
      await box.delete(_transactionIdKey);
    }
  }

  /// Simulate a purchase
  Future<bool> purchasePlan(PremiumPlan plan) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    DateTime? expiry;
    switch (plan) {
      case PremiumPlan.monthly:
        expiry = DateTime.now().add(const Duration(days: 30));
        break;
      case PremiumPlan.yearly:
        expiry = DateTime.now().add(const Duration(days: 365));
        break;
      case PremiumPlan.lifetime:
        expiry = null; // Never expires
        break;
      case PremiumPlan.none:
        return false;
    }

    state = PremiumState(
      isPremium: true,
      expiryDate: expiry,
      plan: plan,
      transactionId: 'SIM_${DateTime.now().millisecondsSinceEpoch}',
    );
    
    await _saveState();
    return true;
  }

  /// Only for testing/dev
  Future<void> activatePremium() async {
    await purchasePlan(PremiumPlan.yearly);
  }

  Future<void> cancelPremium() async {
    state = const PremiumState();
    await _saveState();
  }
}

/// Premium Provider
final premiumProvider = StateNotifierProvider<PremiumNotifier, PremiumState>(
  (ref) => PremiumNotifier(),
);
