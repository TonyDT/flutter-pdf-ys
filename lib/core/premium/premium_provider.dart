import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Feature access levels
enum FeatureAccess { free, premium }

/// Premium plan types
enum PremiumPlan { none, lifetime }

/// Premium state model
class PremiumState {
  final bool isPremium;
  final PremiumPlan plan;
  final String? transactionId;
  final bool isLoading;
  final bool isRestoring;
  final ProductDetails? productDetails;
  final String? errorMessage;

  const PremiumState({
    this.isPremium = false,
    this.plan = PremiumPlan.none,
    this.transactionId,
    this.isLoading = false,
    this.isRestoring = false,
    this.productDetails,
    this.errorMessage,
  });

  /// Feature access map: free vs premium
  static const Map<String, FeatureAccess> featureAccess = {
    'image_to_pdf': FeatureAccess.free,
    'pdf_to_long_image': FeatureAccess.free,
    'edit_pdf_text': FeatureAccess.free,
    'merge_pdf': FeatureAccess.free,
    'compress_pdf': FeatureAccess.premium,
    'encrypt_pdf': FeatureAccess.premium,
  };

  bool canAccess(String feature) {
    final access = featureAccess[feature];
    if (access == null || access == FeatureAccess.free) return true;
    return isPremium;
  }

  PremiumState copyWith({
    bool? isPremium,
    PremiumPlan? plan,
    String? transactionId,
    bool? isLoading,
    bool? isRestoring,
    ProductDetails? productDetails,
    Object? errorMessage = _unchanged,
  }) =>
      PremiumState(
        isPremium: isPremium ?? this.isPremium,
        plan: plan ?? this.plan,
        transactionId: transactionId ?? this.transactionId,
        isLoading: isLoading ?? this.isLoading,
        isRestoring: isRestoring ?? this.isRestoring,
        productDetails: productDetails ?? this.productDetails,
        errorMessage: identical(errorMessage, _unchanged)
            ? this.errorMessage
            : errorMessage as String?,
      );
}

const Object _unchanged = Object();

/// Premium state manager
class PremiumNotifier extends StateNotifier<PremiumState> {
  static const String _boxName = 'premium_box';
  static const String _isPremiumKey = 'is_premium';
  static const String _planKey = 'premium_plan';
  static const String _transactionIdKey = 'transaction_id';

  // Must exactly match the one-time product ID configured in Play Console.
  static const String kLifetimeProductId = 'com.dt.pdf.flutter_pdf.lifetime';
  static const Set<String> kProductIds = {kLifetimeProductId};

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  PremiumNotifier() : super(const PremiumState()) {
    _initBilling();
    _loadLocalState();
  }

  Future<void> _initBilling() async {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (error) {
      _setBillingError('Google Play purchase listener error: $error');
    });

    // 查询商品信息
    await queryProducts();
  }

  Future<void> queryProducts() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final bool available = await _iap.isAvailable();
      if (!available) {
        _setBillingError(
          'Google Play Billing is unavailable. Please make sure Google Play is installed and signed in.',
        );
        return;
      }

      final ProductDetailsResponse response =
          await _iap.queryProductDetails(kProductIds);

      if (response.error != null || response.productDetails.isEmpty) {
        final notFoundIds = response.notFoundIDs.isEmpty
            ? ''
            : ' Product not found: ${response.notFoundIDs.join(', ')}.';
        final error = response.error;
        _setBillingError(
          error == null
              ? 'No product information was returned from Google Play.$notFoundIds'
              : 'Failed to load Google Play product: ${error.code} ${error.message}.$notFoundIds',
        );
        return;
      }

      final productDetails = matchingProductDetails(response.productDetails);

      if (productDetails == null) {
        _setBillingError(
          'Google Play returned a product ID that does not match the app configuration. Please confirm the Play Console product ID is $kLifetimeProductId.',
        );
        return;
      }

      state = state.copyWith(
        productDetails: productDetails,
        isLoading: false, // 加载完成
        errorMessage: null,
      );
    } catch (e) {
      _setBillingError('Error while querying Google Play products: $e');
    }
  }

  Future<void> _loadLocalState() async {
    final box = await Hive.openBox(_boxName);
    final isPremium = box.get(_isPremiumKey, defaultValue: false) as bool;
    final planIndex = box.get(_planKey, defaultValue: 0) as int;
    final transactionId = box.get(_transactionIdKey) as String?;

    state = state.copyWith(
      isPremium: isPremium,
      plan: PremiumPlan.values[planIndex],
      transactionId: transactionId,
    );
  }

  Future<void> _saveLocalState() async {
    final box = await Hive.openBox(_boxName);
    await box.put(_isPremiumKey, state.isPremium);
    await box.put(_planKey, state.plan.index);
    if (state.transactionId != null) {
      await box.put(_transactionIdKey, state.transactionId);
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        state = state.copyWith(isLoading: true);
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          final error = purchaseDetails.error;
          _setBillingError(
            error == null
                ? 'Purchase failed. Please try again later.'
                : 'Purchase failed: ${_formatBillingError(error)}',
          );
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          state = state.copyWith(
            isLoading: false,
            isRestoring: false,
            errorMessage: null,
          );
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          unawaited(_verifyAndActivate(purchaseDetails));
        }

        if (purchaseDetails.pendingCompletePurchase) {
          unawaited(_iap.completePurchase(purchaseDetails));
        }
      }
    }
  }

  Future<void> _verifyAndActivate(PurchaseDetails purchaseDetails) async {
    if (!isKnownProductId(purchaseDetails.productID)) {
      _setBillingError(
        'Purchase product ID mismatch: ${purchaseDetails.productID}. Please confirm the Google Play product configuration.',
      );
      return;
    }

    // 这里通常需要服务器验证，单机版可以直接激活
    state = state.copyWith(
      isPremium: true,
      plan: PremiumPlan.lifetime,
      transactionId:
          purchaseDetails.purchaseID ?? purchaseDetails.transactionDate,
      isLoading: false,
      isRestoring: false,
      errorMessage: null,
    );
    await _saveLocalState();
  }

  /// 发起购买
  Future<bool> purchasePlan() async {
    if (state.productDetails == null) {
      await queryProducts();
    }

    if (state.productDetails == null) return false;

    try {
      state = state.copyWith(errorMessage: null);
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: state.productDetails!);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      return true;
    } catch (e) {
      _setBillingError(
          'Failed to start purchase: ${_formatPurchaseException(e)}');
      return false;
    }
  }

  /// 恢复购买
  Future<void> restorePurchases() async {
    try {
      state = state.copyWith(
          isLoading: true, isRestoring: true, errorMessage: null);
      await _iap.restorePurchases();
      await Future<void>.delayed(const Duration(seconds: 4));
      if (mounted && state.isRestoring && !state.isPremium) {
        _setBillingError(
          'No restorable Google Play purchase was found. Please use the same Google account used for the purchase.',
        );
      }
    } catch (e) {
      _setBillingError('Failed to restore purchases: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// 仅供测试使用
  Future<void> cancelPremium() async {
    state = const PremiumState();
    final box = await Hive.openBox(_boxName);
    await box.clear();
  }

  void _setBillingError(String message) {
    debugPrint('[PremiumBilling] $message');
    state = state.copyWith(
      isLoading: false,
      isRestoring: false,
      errorMessage: message,
    );
  }

  @visibleForTesting
  static bool isKnownProductId(String productId) =>
      kProductIds.contains(productId);

  @visibleForTesting
  static ProductDetails? matchingProductDetails(List<ProductDetails> products) {
    for (final product in products) {
      if (product.id == kLifetimeProductId) return product;
    }
    return null;
  }

  String _formatBillingError(IAPError error) {
    final raw = '${error.code} ${error.message}';
    if (raw.toLowerCase().contains('itemunavailable')) {
      return 'Product unavailable in Google Play for this app build or tester account. ($raw)';
    }
    return raw;
  }

  String _formatPurchaseException(Object error) {
    final raw = error.toString();
    if (raw.toLowerCase().contains('itemunavailable')) {
      return 'Product unavailable in Google Play for this app build or tester account. ($raw)';
    }
    return raw;
  }
}

/// Premium Provider
final premiumProvider = StateNotifierProvider<PremiumNotifier, PremiumState>(
  (ref) => PremiumNotifier(),
);
