import 'package:flutter/foundation.dart';

import '../services/shop_service.dart';
import '../services/cache_service.dart';
import 'auth_service.dart';

class CartNotifier extends ChangeNotifier {
  // ============================================================
  // CACHE KEY
  // ============================================================

  static const String cartCacheKey = 'cart';

  // ============================================================
  // SERVICES
  // ============================================================

  final ShopService _shopService = ShopService();

  // ============================================================
  // STATE
  // ============================================================

  List<Map<String, dynamic>> _items = [];

  bool _loading = false;

  bool _syncing = false;

  String? _error;

  // ============================================================
  // GETTERS
  // ============================================================

  List<Map<String, dynamic>> get items =>
      List.unmodifiable(_items);

  bool get loading => _loading;

  bool get syncing => _syncing;

  String? get error => _error;

  bool get isEmpty => _items.isEmpty;

  int get itemCount {
    return _items.fold<int>(
      0,
      (total, item) {
        final quantity =
            int.tryParse(
                  item['quantity']?.toString() ?? '1',
                ) ??
                1;

        return total + quantity;
      },
    );
  }

  String get badgeCount {
    if (itemCount > 9) {
      return '9+';
    }

    return itemCount.toString();
  }

  // ============================================================
  // SUBTOTAL
  // ============================================================

  double get subtotal {
    return _items.fold<double>(
      0,
      (total, item) {
        final price = double.tryParse(
              (item['discounted_price'] ??
                      item['price'] ??
                      0)
                  .toString()
                  .replaceAll(',', ''),
            ) ??
            0;

        final quantity =
            int.tryParse(
                  item['quantity']?.toString() ?? '1',
                ) ??
                1;

        return total + (price * quantity);
      },
    );
  }

  // ============================================================
  // LOAD GUEST CART FROM CACHE
  // ============================================================

  Future<void> loadLocalCart() async {
    _loading = true;
    _error = null;

    notifyListeners();

    try {
      final cached =
          await CacheService.getList(
        cartCacheKey,
      );

      _items = cached
          .map<Map<String, dynamic>>(
            (item) => Map<String, dynamic>.from(
              item as Map,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint(
        'LOAD LOCAL CART ERROR: $e',
      );

      _items = [];

      _error = e.toString();
    }

    _loading = false;

    notifyListeners();
  }

  // ============================================================
  // SAVE LOCAL CART
  // ============================================================

  Future<void> _saveLocalCart() async {
    await CacheService.save(
      cartCacheKey,
      _items,
    );
  }

  // ============================================================
  // LOAD SERVER CART
  // ============================================================

  Future<void> loadServerCart() async {
    _loading = true;
    _error = null;

    notifyListeners();

    try {
      final response =
          await _shopService.getCart();

      debugPrint(
        '===== SERVER CART =====',
      );

      debugPrint(
        response.toString(),
      );

      List<dynamic> serverItems = [];

      if (response is Map) {
        if (response['cart'] is List) {
          serverItems =
              response['cart'];
        } else if (response['data'] is List) {
          serverItems =
              response['data'];
        }
      }

      _items = serverItems
          .map<Map<String, dynamic>>(
            (item) => Map<String, dynamic>.from(
              item as Map,
            ),
          )
          .toList();

      // Keep local cache in sync with
      // the server cart.
      await _saveLocalCart();
    } catch (e) {
      debugPrint(
        'LOAD SERVER CART ERROR: $e',
      );

      _error = e.toString();
    }

    _loading = false;

    notifyListeners();
  }

  // ============================================================
  // ADD TO CART
  // ============================================================

  Future<bool> addToCart({
  required int itemId,
  required Map<String, dynamic> product,
  int quantity = 1,
}) async {
  try {
    _error = null;

    final loggedIn = await AuthService.isLoggedIn();

    debugPrint('================ CART ADD ================');
    debugPrint('Item ID: $itemId');
    debugPrint('Quantity: $quantity');
    debugPrint('Logged in: $loggedIn');

    // ============================================================
    // LOGGED-IN USER
    // ============================================================

    if (loggedIn) {
      final response = await _shopService.addToCart(
        itemId: itemId,
        quantity: quantity,
      );

      debugPrint('ADD TO CART API RESPONSE: $response');

      await loadServerCart();

      return true;
    }

    // ============================================================
    // GUEST USER
    // ============================================================

    final existingIndex = _items.indexWhere(
      (item) {
        final existingId = int.tryParse(
          (item['item_id'] ?? item['id']).toString(),
        );

        return existingId == itemId;
      },
    );

    if (existingIndex != -1) {
      final currentQuantity = int.tryParse(
            _items[existingIndex]['quantity']?.toString() ?? '1',
          ) ??
          1;

      _items[existingIndex]['quantity'] =
          currentQuantity + quantity;
    } else {
      final cartItem = Map<String, dynamic>.from(product);

      cartItem['item_id'] = itemId;
      cartItem['quantity'] = quantity;
      cartItem['selected'] = true;

      _items.add(cartItem);
    }

    await _saveLocalCart();

    debugPrint(
      'GUEST CART SAVED: $_items',
    );

    notifyListeners();

    return true;
  } catch (e, stackTrace) {
    debugPrint('================ CART ERROR ================');
    debugPrint('ADD TO CART ERROR: $e');
    debugPrint('$stackTrace');

    _error = e.toString();

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
    bool isLoggedIn = false,
  }) async {
    if (quantity <= 0) {
      return removeItem(
        itemId,
        isLoggedIn: isLoggedIn,
      );
    }

    try {
      _error = null;

      // ========================================================
      // LOGGED IN
      // ========================================================

      if (isLoggedIn) {
        await _shopService.updateCartItem(
          itemId: itemId,
          quantity: quantity,
        );

        await loadServerCart();

        return true;
      }

      // ========================================================
      // GUEST
      // ========================================================

      final index =
          _findItemIndex(itemId);

      if (index == -1) {
        return false;
      }

      _items[index]['quantity'] =
          quantity;

      await _saveLocalCart();

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint(
        'UPDATE CART ERROR: $e',
      );

      _error = e.toString();

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // INCREMENT
  // ============================================================

  Future<bool> increment({
    required int itemId,
    bool isLoggedIn = false,
  }) async {
    final index =
        _findItemIndex(itemId);

    if (index == -1) {
      return false;
    }

    final currentQuantity =
        int.tryParse(
              _items[index]['quantity']
                      ?.toString() ??
                  '1',
            ) ??
            1;

    return updateQuantity(
      itemId: itemId,
      quantity: currentQuantity + 1,
      isLoggedIn: isLoggedIn,
    );
  }

  // ============================================================
  // DECREMENT
  // ============================================================

  Future<bool> decrement({
    required int itemId,
    bool isLoggedIn = false,
  }) async {
    final index =
        _findItemIndex(itemId);

    if (index == -1) {
      return false;
    }

    final currentQuantity =
        int.tryParse(
              _items[index]['quantity']
                      ?.toString() ??
                  '1',
            ) ??
            1;

    if (currentQuantity <= 1) {
      return true;
    }

    return updateQuantity(
      itemId: itemId,
      quantity: currentQuantity - 1,
      isLoggedIn: isLoggedIn,
    );
  }

  // ============================================================
  // REMOVE ITEM
  // ============================================================

  Future<bool> removeItem(
    int itemId, {
    bool isLoggedIn = false,
  }) async {
    try {
      _error = null;

      // ========================================================
      // LOGGED IN
      // ========================================================

      if (isLoggedIn) {
        await _shopService.removeCartItem(
          itemId,
        );

        await loadServerCart();

        return true;
      }

      // ========================================================
      // GUEST
      // ========================================================

      _items.removeWhere(
        (item) {
          final id =
              int.tryParse(
                item['item_id']?.toString() ??
                    item['id']?.toString() ??
                    '',
              );

          return id == itemId;
        },
      );

      await _saveLocalCart();

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint(
        'REMOVE CART ERROR: $e',
      );

      _error = e.toString();

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // CLEAR CART
  // ============================================================

  Future<bool> clearCart({
    bool isLoggedIn = false,
  }) async {
    try {
      _error = null;

      if (isLoggedIn) {
        await _shopService.clearCart();
      }

      _items.clear();

      await _saveLocalCart();

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint(
        'CLEAR CART ERROR: $e',
      );

      _error = e.toString();

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // SYNC GUEST CART WITH ACCOUNT
  // ============================================================

  Future<bool> syncGuestCart() async {
    if (_items.isEmpty) {
      return true;
    }

    try {
      _syncing = true;
      _error = null;

      notifyListeners();

      // Make a copy because the server
      // cart may change while syncing.
      final localItems =
          List<Map<String, dynamic>>.from(
        _items,
      );

      // ========================================================
      // SEND EACH LOCAL ITEM TO SERVER
      // ========================================================

      for (final item in localItems) {
        final itemId =
            int.tryParse(
          item['item_id']?.toString() ??
              item['id']?.toString() ??
              '',
        );

        final quantity =
            int.tryParse(
                  item['quantity']
                          ?.toString() ??
                      '1',
                ) ??
                1;

        if (itemId == null) {
          continue;
        }

        await _shopService.addToCart(
          itemId: itemId,
          quantity: quantity,
        );
      }

      // ========================================================
      // GET SERVER CART
      // ========================================================

      final response =
          await _shopService.getCart();

      List<dynamic> serverItems = [];

      if (response is Map) {
        if (response['cart'] is List) {
          serverItems =
              response['cart'];
        } else if (response['data'] is List) {
          serverItems =
              response['data'];
        }
      }

      _items = serverItems
          .map<Map<String, dynamic>>(
            (item) => Map<String, dynamic>.from(
              item as Map,
            ),
          )
          .toList();

      // ========================================================
      // UPDATE CACHE
      // ========================================================

      await _saveLocalCart();

      _syncing = false;

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint(
        'SYNC CART ERROR: $e',
      );

      _error = e.toString();

      _syncing = false;

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // INITIALIZE CART
  // ============================================================

  Future<void> initialize({
    required bool isLoggedIn,
  }) async {
    if (isLoggedIn) {
      await loadServerCart();
    } else {
      await loadLocalCart();
    }
  }

  // ============================================================
  // FIND ITEM
  // ============================================================

  int _findItemIndex(
    int itemId,
  ) {
    return _items.indexWhere(
      (item) {
        final id =
            int.tryParse(
          item['item_id']?.toString() ??
              item['id']?.toString() ??
              '',
        );

        return id == itemId;
      },
    );
  }

  // ============================================================
// LOAD CART
// ============================================================

Future<void> loadCart({
  bool? isLoggedIn,
}) async {
  bool loggedIn;

  if (isLoggedIn != null) {
    loggedIn = isLoggedIn;
  } else {
    loggedIn = await AuthService.isLoggedIn();
  }

  await initialize(
    isLoggedIn: loggedIn,
  );
}

Future<void> refresh({
  bool? isLoggedIn,
}) async {
  await loadCart(
    isLoggedIn: isLoggedIn,
  );
}
}
final CartNotifier cartNotifier = CartNotifier();