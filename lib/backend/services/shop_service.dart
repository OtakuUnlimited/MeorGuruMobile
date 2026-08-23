import 'api_client.dart';
import 'cache_keys.dart';
import 'cache_service.dart';

class ShopService {
  final ApiClient _client = ApiClient();

  /// Categories
  Future<List<Map<String, dynamic>>> getCategories({
    String search = '',
  }) async {
    final response = await _client.get(
      'get-categories?search=$search',
    );
    return List<Map<String, dynamic>>.from(
      response['data'],
    );
  }

  /// Products
  Future<List<Map<String, dynamic>>> getProducts({
    String search = '',
    String? category,
    int page = 1,
  }) async {
    String url =
        'get-items?page=$page&search=$search';

    if (category != null && category.isNotEmpty) {
      url += '&category=$category';
    }

    final response = await _client.get(url);

    return List<Map<String, dynamic>>.from(
      response['data'],
    );
  }

  /// Popular Products
  Future<List<Map<String, dynamic>>> getPopularProducts({
    int page = 1,
  }) async {
    final response = await _client.get(
      'get-popular-items?page=$page',
    );

    return List<Map<String, dynamic>>.from(
      response['data'],
    );
  }

  /// Featured Products
  Future<List<Map<String, dynamic>>> getFeaturedProducts({
    int page = 1,
  }) async {
    final response = await _client.get(
      'get-featured-items?page=$page',
    );

    return List<Map<String, dynamic>>.from(
      response['data'],
    );
  }

  /// Product Detail
  Future<Map<String, dynamic>> getProductDetail(
    String slug,
  ) async {
    final response = await _client.get(
      'get-product-detail/$slug',
    );
    

    return Map<String, dynamic>.from(
      response['data'],
    );
  }


  //cart service

  Future<dynamic> getCart({
    String? couponCode,
  }) async {
    String url = 'checkout';

    if (couponCode != null && couponCode.isNotEmpty) {
      url += '?coupon_code=$couponCode';
    }

    return await _client.get(url);
  }

  // ============================================================
  // ADD TO CART
  // ============================================================

  Future<dynamic> addToCart({
    required int itemId,
    int quantity = 1,
  }) async {
    return await _client.post(
      'add-to-cart',
      {
        'item_id': itemId,
        'quantity': quantity,
      },
    );
  }

  // ============================================================
  // UPDATE CART ITEM
  // ============================================================

  Future<dynamic> updateCartItem({
    required int itemId,
    required int quantity,
  }) async {
    return await _client.put(
      'update-cart-item',
      {
        'item_id': itemId,
        'quantity': quantity,
      },
    );
  }

  // ============================================================
  // REMOVE CART ITEM
  // ============================================================

  Future<dynamic> removeCartItem(
    int itemId,
  ) async {
    return await _client.delete(
      'delete-cart-item',
      {
        'item_id': itemId,
      },
    );
  }

  // ============================================================
  // CLEAR CART
  // ============================================================

  Future<dynamic> clearCart() async {
    return await _client.delete(
      'clear-cart',
      {},
    );
  }

  // ============================================================
  // SYNC LOCAL CART TO SERVER
  // ============================================================
  //
  // Used when:
  // Guest has items in local cart
  //        ↓
  // User logs in
  //        ↓
  // Local cart gets pushed to API
  //
  // ============================================================

  Future<void> syncCart(
    List<Map<String, dynamic>> items,
  ) async {
    for (final item in items) {
      final itemId = int.tryParse(
        item['item_id']?.toString() ??
            item['id']?.toString() ??
            '',
      );

      final quantity = int.tryParse(
        item['quantity']?.toString() ?? '1',
      ) ?? 1;

      if (itemId == null) {
        continue;
      }

      await addToCart(
        itemId: itemId,
        quantity: quantity,
      );
    }
  }
}