import 'api_client.dart';
import 'cache_keys.dart';
import 'cache_service.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';
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
  final parameters = <String, String>{
    'page': page.toString(),
    'search': search,
  };

  if (category != null && category.isNotEmpty) {
    parameters['category'] = category;
  }

  final url = Uri(
    path: 'get-items',
    queryParameters: parameters,
  ).toString();

  final response = await _client.get(url);

  debugPrint('GET PRODUCTS URL: $url');
  debugPrint('GET PRODUCTS RESPONSE: $response');

  dynamic rawProducts;

  if (response is List) {
    rawProducts = response;
  } else if (response is Map) {
    rawProducts =
        response['data'] ??
        response['items'] ??
        response['products'];

    // Handles a nested paginator response.
    if (rawProducts is Map) {
      rawProducts = rawProducts['data'];
    }
  }

  if (rawProducts is! List) {
    debugPrint(
      'PRODUCT ERROR: No product list found in response',
    );

    return [];
  }

  return rawProducts
      .map<Map<String, dynamic>>(
        (item) => Map<String, dynamic>.from(
          item as Map,
        ),
      )
      .toList();
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
    final token = await AuthService.getToken();
    if (couponCode != null && couponCode.isNotEmpty) {
      url += '?coupon_code=$couponCode';
    }

    return await _client.get(url, requireAuth: token != null);
  }

  // ============================================================
  // ADD TO CART
  // ============================================================

  Future<dynamic> addToCart({
    required int itemId,
    int quantity = 1,
  }) async {
    final token = await AuthService.getToken();
    return await _client.post(
      'add-to-cart',
      {
        'item_id': itemId,
        'quantity': quantity,
      },
      requireAuth: token != null
    );
  }

  // ============================================================
  // UPDATE CART ITEM
  // ============================================================

  Future<dynamic> updateCartItem({
    required int itemId,
    required int quantity,
  }) async {
    final token = await AuthService.getToken();
    return await _client.put(
      'update-cart-item',
      {
        'item_id': itemId,
        'quantity': quantity,
      },
      requireAuth: token != null
    );
  }

  // ============================================================
  // REMOVE CART ITEM
  // ============================================================

  Future<dynamic> removeCartItem(
    int itemId,
  ) async {
    final token = await AuthService.getToken();
    return await _client.delete(
      'delete-cart-item',
      {
        'item_id': itemId,
      },
      requireAuth: token != null
    );
  }

  // ============================================================
  // CLEAR CART
  // ============================================================

  Future<dynamic> clearCart() async {
    final token = await AuthService.getToken();
    return await _client.delete(
      'clear-cart',
      {},
      requireAuth: token != null
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