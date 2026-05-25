import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Feature access levels
enum FeatureAccess { free, premium }

/// Premium state model
class PremiumState {
  final bool isPremium;
  final DateTime? expiryDate;
  final bool isPending; // 购买进行中
  final bool iapAvailable; // IAP是否可用

  const PremiumState({
    this.isPremium = false,
    this.expiryDate,
    this.isPending = false,
    this.iapAvailable = false,
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
    bool? isPending,
    bool? iapAvailable,
  }) =>
      PremiumState(
        isPremium: isPremium ?? this.isPremium,
        expiryDate: expiryDate ?? this.expiryDate,
        isPending: isPending ?? this.isPending,
        iapAvailable: iapAvailable ?? this.iapAvailable,
      );
}

/// Premium state manager
class PremiumNotifier extends StateNotifier<PremiumState> {
  static const String _boxName = 'premium_box';
  static const String _isPremiumKey = 'is_premium';
  static const String _expiryDateKey = 'expiry_date';

  // 内购商品ID - 需要在App Store和Google Play后台配置
  static const String _iOSProductId = 'com.dt.pdf.flutter_pdf.lifetime';
  static const String _androidProductId = 'com.dt.pdf.flutter_pdf.lifetime';
  static String get productId => Platform.isIOS ? _iOSProductId : _androidProductId;

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  PremiumNotifier() : super(const PremiumState()) {
    _loadState();
    _initIAP();
  }

  Future<void> _loadState() async {
    final box = await Hive.openBox(_boxName);
    final isPremium = box.get(_isPremiumKey, defaultValue: false) as bool;
    
    state = PremiumState(
      isPremium: isPremium,
      expiryDate: null, // 永久会员不需要过期时间
      iapAvailable: state.iapAvailable,
    );
  }

  Future<void> _saveState() async {
    final box = await Hive.openBox(_boxName);
    await box.put(_isPremiumKey, state.isPremium);
  }

  /// 初始化内购 - 检查可用性并监听购买流
  Future<void> _initIAP() async {
    try {
      // 检查IAP是否可用
      final bool available = await _iap.isAvailable();
      
      if (!available) {
        debugPrint('IAP not available on this device');
        state = state.copyWith(iapAvailable: false);
        return;
      }

      state = state.copyWith(iapAvailable: true);

      // 监听购买流
      _subscription = _iap.purchaseStream.listen(
        _handlePurchase,
        onDone: () {
          debugPrint('IAP purchase stream closed');
        },
        onError: (error) {
          debugPrint('IAP Error: $error');
          state = state.copyWith(isPending: false);
        },
      );

      debugPrint('IAP initialized successfully');
    } catch (e) {
      debugPrint('IAP initialization error: $e');
      state = state.copyWith(iapAvailable: false);
    }
  }

  /// 处理购买回调
  void _handlePurchase(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      debugPrint('Purchase status: ${purchase.status} for ${purchase.productID}');
      
      switch (purchase.status) {
        case PurchaseStatus.pending:
          state = state.copyWith(isPending: true);
          break;
          
        case PurchaseStatus.error:
          state = state.copyWith(isPending: false);
          debugPrint('Purchase error: ${purchase.error}');
          break;
          
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _deliverProduct(purchase);
          break;
          
        case PurchaseStatus.canceled:
          state = state.copyWith(isPending: false);
          break;
      }

      // 完成购买（重要：必须调用以完成交易）
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase).catchError((error) {
          debugPrint('Error completing purchase: $error');
        });
      }
    }
  }

  /// 发放商品（激活Premium）
  Future<void> _deliverProduct(PurchaseDetails purchase) async {
    // TODO: 生产环境建议添加服务端收据验证
    
    debugPrint('Delivering lifetime product: ${purchase.productID}');
    
    // 一次性购买，直接永久激活
    state = PremiumState(
      isPremium: true,
      expiryDate: null,
      isPending: false,
      iapAvailable: state.iapAvailable,
    );
    await _saveState();
    debugPrint('Lifetime Premium activated successfully');
  }

  /// 获取商品信息
  Future<ProductDetails?> getProductDetails() async {
    if (!state.iapAvailable) {
      debugPrint('IAP not available');
      return null;
    }

    try {
      final ProductDetailsResponse response =
          await _iap.queryProductDetails({productId});
      
      if (response.error != null) {
        debugPrint('Product query error: ${response.error}');
        return null;
      }
      
      if (response.productDetails.isEmpty) {
        debugPrint('No products found for ID: $productId');
        return null;
      }
      
      return response.productDetails.first;
    } catch (e) {
      debugPrint('Get product details error: $e');
      return null;
    }
  }

  /// 购买
  Future<bool> purchase(ProductDetails product) async {
    if (!state.iapAvailable) {
      debugPrint('Cannot purchase: IAP not available');
      return false;
    }

    try {
      state = state.copyWith(isPending: true);
      
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      return true;
    } catch (e) {
      debugPrint('Purchase error: $e');
      state = state.copyWith(isPending: false);
      return false;
    }
  }

  /// 恢复购买
  Future<bool> restorePurchases() async {
    if (!state.iapAvailable) {
      debugPrint('Cannot restore: IAP not available');
      return false;
    }

    try {
      state = state.copyWith(isPending: true);
      await _iap.restorePurchases();
      
      // 恢复购买的结果会通过 purchaseStream 返回
      // 这里不立即设置 isPending = false，等待 purchaseStream 处理
      return true;
    } catch (e) {
      debugPrint('Restore purchases error: $e');
      state = state.copyWith(isPending: false);
      return false;
    }
  }

  /// 检查订阅状态（可以在app启动时调用）
  Future<void> checkSubscriptionStatus() async {
    if (!state.iapAvailable) return;
    
    // 这里可以添加服务端验证逻辑
    // 验证本地存储的过期时间是否有效
    await _loadState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}

/// Premium Provider
final premiumProvider = StateNotifierProvider<PremiumNotifier, PremiumState>(
  (ref) => PremiumNotifier(),
);
