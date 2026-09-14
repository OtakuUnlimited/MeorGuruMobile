import 'package:flutter/foundation.dart';

import 'shop_service.dart';

class CartNotifier extends ChangeNotifier {
  final ShopService _shopService = ShopService();

  List<Map<String, dynamic>> _items = [];

  bool _loading = false;
  String? _error;

  List<Map<String, dynamic>> get items =>
      List.unmodifiable(_items);

  bool get loading => _loading;

  String? get error => _error;

  bool get isEmpty => _items.isEmpty;

  bool get hasItems => _items.isNotEmpty;

  int get itemCount {
    return _items.fold<int>(
      0,
      (total, item) {
        final quantity = int.tryParse(
              item['quantity']?.toString() ?? '1',
            ) ??
            1;

        return total + quantity;
      },
    );
  }

  String get badgeCount {
    return itemCount > 9
        ? '9+'
        : itemCount.toString();
  }

  double get subtotal {
    return _items.fold<double>(
      0,
      (total, item) {
        final price = double.tryParse(
              (
                item['discounted_unit_price'] ??
                item['discounted_price'] ??
                item['unit_price'] ??
                item['price'] ??
                0
              )
                  .toString()
                  .replaceAll(',', ''),
            ) ??
            0;

        final quantity = int.tryParse(
              item['quantity']?.toString() ?? '1',
            ) ??
            1;

        return total + (price * quantity);
      },
    );
  }

  // ============================================================
  // LOAD CART FROM LARAVEL SESSION
  // ============================================================

  Future<void> loadServerCart() async {
    _loading = true;
    _error = null;

    notifyListeners();

    try {
      final response =
          await _shopService.getCart();

      debugPrint(
        'SERVER CART RESPONSE: $response',
      );

      List<dynamic> serverItems = [];

      if (response is Map) {
        if (response['cart'] is List) {
          serverItems = response['cart'];
        } else if (response['data'] is List) {
          serverItems = response['data'];
        }
      }

      _items = serverItems.map((item) {
        final cartItem =
            Map<String, dynamic>.from(
          item as Map,
        );

        cartItem['selected'] =
            cartItem['selected'] ?? true;

        return cartItem;
      }).toList();
    } catch (e, stackTrace) {
      _items = [];
      _error = e.toString();

      debugPrint(
        'LOAD SERVER CART ERROR: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadCart() async {
    await loadServerCart();
  }

  Future<void> refresh() async {
    await loadServerCart();
  }

  // ============================================================
  // ADD TO CART
  // ============================================================

  Future<bool> addToCart({
    required int itemId,

    // Retained for compatibility with ItemDetailScreen.
    // Laravel only requires itemId and quantity.
    Map<String, dynamic>? product,

    int quantity = 1,
  }) async {
    try {
      _error = null;

      final response =
          await _shopService.addToCart(
        itemId: itemId,
        quantity: quantity,
      );

      debugPrint(
        'ADD TO CART RESPONSE: $response',
      );

      if (response is Map &&
          response['success'] == false) {
        _error = response['message']?.toString() ??
            'Could not add item to cart';

        notifyListeners();

        return false;
      }

      await loadServerCart();

      return true;
    } catch (e, stackTrace) {
      _error = e.toString();

      debugPrint(
        'ADD TO CART ERROR: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // UPDATE QUANTITY
  // ============================================================

  Future<bool> updateQuantity({
    required int itemId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      return removeItem(itemId);
    }

    try {
      _error = null;

      final response =
          await _shopService.updateCartItem(
        itemId: itemId,
        quantity: quantity,
      );

      debugPrint(
        'UPDATE CART RESPONSE: $response',
      );

      if (response is Map &&
          response['success'] == false) {
        _error = response['message']?.toString() ??
            'Could not update cart';

        notifyListeners();

        return false;
      }

      await loadServerCart();

      return true;
    } catch (e, stackTrace) {
      _error = e.toString();

      debugPrint(
        'UPDATE CART ERROR: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // INCREMENT
  // ============================================================

  Future<bool> increment({
    required int itemId,
  }) async {
    final index = _findItemIndex(itemId);

    if (index == -1) {
      return false;
    }

    final quantity = int.tryParse(
          _items[index]['quantity']
                  ?.toString() ??
              '1',
        ) ??
        1;

    return updateQuantity(
      itemId: itemId,
      quantity: quantity + 1,
    );
  }

  // ============================================================
  // DECREMENT
  // ============================================================

  Future<bool> decrement({
    required int itemId,
  }) async {
    final index = _findItemIndex(itemId);

    if (index == -1) {
      return false;
    }

    final quantity = int.tryParse(
          _items[index]['quantity']
                  ?.toString() ??
              '1',
        ) ??
        1;

    if (quantity <= 1) {
      return removeItem(itemId);
    }

    return updateQuantity(
      itemId: itemId,
      quantity: quantity - 1,
    );
  }

  // ============================================================
  // REMOVE ITEM
  // ============================================================

  Future<bool> removeItem(
    int itemId,
  ) async {
    try {
      _error = null;

      final response =
          await _shopService.removeCartItem(
        itemId,
      );

      debugPrint(
        'REMOVE CART RESPONSE: $response',
      );

      if (response is Map &&
          response['success'] == false) {
        _error = response['message']?.toString() ??
            'Could not remove item';

        notifyListeners();

        return false;
      }

      await loadServerCart();

      return true;
    } catch (e, stackTrace) {
      _error = e.toString();

      debugPrint(
        'REMOVE CART ERROR: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // CLEAR CART
  // ============================================================

  Future<bool> clearCart() async {
    try {
      _error = null;

      final response =
          await _shopService.clearCart();

      debugPrint(
        'CLEAR CART RESPONSE: $response',
      );

      if (response is Map &&
          response['success'] == false) {
        _error = response['message']?.toString() ??
            'Could not clear cart';

        notifyListeners();

        return false;
      }

      await loadServerCart();

      return true;
    } catch (e, stackTrace) {
      _error = e.toString();

      debugPrint(
        'CLEAR CART ERROR: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // FIND CART ITEM
  // ============================================================

  int _findItemIndex(
    int itemId,
  ) {
    return _items.indexWhere(
      (item) {
        final id = int.tryParse(
          (
            item['item_id'] ??
            item['id'] ??
            ''
          ).toString(),
        );

        return id == itemId;
      },
    );
  }
}

final CartNotifier cartNotifier =
    CartNotifier();