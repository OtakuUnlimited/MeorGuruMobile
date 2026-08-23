import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';
import '../services/cache_service.dart';
import '../services/shop_service.dart';
import 'cache_keys.dart';

class CartService extends ChangeNotifier {
  final ShopService _shopService = ShopService();

  // --------------------------------------------------
  // STATE
  // --------------------------------------------------

  List<Map<String, dynamic>> _items = [];

  bool _loading = false;

  bool get loading => _loading;

  List<Map<String, dynamic>> get items =>
      List.unmodifiable(_items);

  // --------------------------------------------------
  // CART COUNT
  // --------------------------------------------------

  int get itemCount {
    return _items.fold<int>(
      0,
      (total, item) {
        final quantity =
            int.tryParse(
                  item['quantity']?.toString() ?? '0',
                ) ??
                0;

        return total + quantity;
      },
    );
  }

  // --------------------------------------------------
  // BADGE COUNT
  // --------------------------------------------------

  String get badgeCount {
    if (itemCount > 9) {
      return '9+';
    }

    return itemCount.toString();
  }

  // --------------------------------------------------
  // HAS ITEMS
  // --------------------------------------------------

  bool get hasItems => _items.isNotEmpty;

  // --------------------------------------------------
  // INITIALIZE
  // --------------------------------------------------

  Future<void> initialize() async {
    _loading = true;
    notifyListeners();

    try {
      final loggedIn =
          await AuthService.isLoggedIn();

      if (loggedIn) {
        await _loadFromApi();
      } else {
        await _loadFromCache();
      }
    } catch (e) {
      debugPrint(
        'Cart initialize error: $e',
      );

      await _loadFromCache();
    }

    _loading = false;
    notifyListeners();
  }

  // --------------------------------------------------
  // LOAD CACHE
  // --------------------------------------------------

  Future<void> _loadFromCache() async {
    final cached =
        await CacheService.getList(
      CacheKeys.cart,
    );

    _items = cached
        .map(
          (item) => Map<String, dynamic>.from(
            item,
          ),
        )
        .toList();

    notifyListeners();
  }

  // --------------------------------------------------
  // SAVE CACHE
  // --------------------------------------------------

  Future<void> _saveCache() async {
    await CacheService.save(
      CacheKeys.cart,
      _items,
    );
  }

  // --------------------------------------------------
  // LOAD API CART
  // --------------------------------------------------

  Future<void> _loadFromApi() async {
    final response =
        await _shopService.getCart();

    debugPrint(
      '===== API CART =====',
    );

    debugPrint(
      response.toString(),
    );

    final cart =
        response['cart'];

    if (cart is List) {
      _items = cart
          .map(
            (item) => Map<String, dynamic>.from(
              item,
            ),
          )
          .toList();
    } else {
      _items = [];
    }

    notifyListeners();
  }

  // --------------------------------------------------
  // REFRESH
  // --------------------------------------------------

  Future<void> refresh() async {
    final loggedIn =
        await AuthService.isLoggedIn();

    try {
      if (loggedIn) {
        await _loadFromApi();
      } else {
        await _loadFromCache();
      }
    } catch (e) {
      debugPrint(
        'Cart refresh error: $e',
      );

      if (!loggedIn) {
        await _loadFromCache();
      }
    }

    notifyListeners();
  }

  // --------------------------------------------------
  // ADD TO CART
  // --------------------------------------------------

  Future<bool> addToCart({
    required int itemId,
    int quantity = 1,
  }) async {
    try {
      final loggedIn =
          await AuthService.isLoggedIn();

      // ----------------------------------------------
      // GUEST
      // ----------------------------------------------

      if (!loggedIn) {
        return await _addToLocalCart(
          itemId: itemId,
          quantity: quantity,
        );
      }

      // ----------------------------------------------
      // LOGGED IN
      // ----------------------------------------------

      final response =
          await _shopService.addToCart(
        itemId: itemId,
        quantity: quantity,
      );

      debugPrint(
        '===== ADD TO CART RESPONSE =====',
      );

      debugPrint(
        response.toString(),
      );

      await _loadFromApi();

      return true;
    } catch (e) {
      debugPrint(
        'Add to cart error: $e',
      );

      return false;
    }
  }

  // --------------------------------------------------
  // ADD TO LOCAL CART
  // --------------------------------------------------

  Future<bool> _addToLocalCart({
    required int itemId,
    required int quantity,
  }) async {
    await _loadFromCache();

    final index = _items.indexWhere(
      (item) =>
          item['item_id'].toString() ==
          itemId.toString(),
    );

    if (index >= 0) {
      final currentQuantity =
          int.tryParse(
                _items[index]['quantity']
                        ?.toString() ??
                    '0',
              ) ??
              0;

      _items[index]['quantity'] =
          currentQuantity + quantity;
    } else {
      _items.add({
        'item_id': itemId,
        'quantity': quantity,
      });
    }

    await _saveCache();

    notifyListeners();

    return true;
  }

  // --------------------------------------------------
  // UPDATE QUANTITY
  // --------------------------------------------------

  Future<bool> updateQuantity({
    required int itemId,
    required int quantity,
  }) async {
    if (quantity < 1) {
      return false;
    }

    try {
      final loggedIn =
          await AuthService.isLoggedIn();

      // ----------------------------------------------
      // GUEST
      // ----------------------------------------------

      if (!loggedIn) {
        await _loadFromCache();

        final index =
            _items.indexWhere(
          (item) =>
              item['item_id'].toString() ==
              itemId.toString(),
        );

        if (index == -1) {
          return false;
        }

        _items[index]['quantity'] =
            quantity;

        await _saveCache();

        notifyListeners();

        return true;
      }

      // ----------------------------------------------
      // LOGGED IN
      // ----------------------------------------------

      await _shopService.updateCartItem(
        itemId: itemId,
        quantity: quantity,
      );

      await _loadFromApi();

      return true;
    } catch (e) {
      debugPrint(
        'Update cart error: $e',
      );

      return false;
    }
  }

  // --------------------------------------------------
  // REMOVE ITEM
  // --------------------------------------------------

  Future<bool> removeItem(
    int itemId,
  ) async {
    try {
      final loggedIn =
          await AuthService.isLoggedIn();

      // ----------------------------------------------
      // GUEST
      // ----------------------------------------------

      if (!loggedIn) {
        await _loadFromCache();

        _items.removeWhere(
          (item) =>
              item['item_id'].toString() ==
              itemId.toString(),
        );

        await _saveCache();

        notifyListeners();

        return true;
      }

      // ----------------------------------------------
      // LOGGED IN
      // ----------------------------------------------

      await _shopService.removeCartItem(
        itemId,
      );

      await _loadFromApi();

      return true;
    } catch (e) {
      debugPrint(
        'Remove cart item error: $e',
      );

      return false;
    }
  }

  // --------------------------------------------------
  // CLEAR CART
  // --------------------------------------------------

  Future<bool> clearCart() async {
    try {
      final loggedIn =
          await AuthService.isLoggedIn();

      // ----------------------------------------------
      // GUEST
      // ----------------------------------------------

      if (!loggedIn) {
        _items = [];

        await CacheService.remove(
          CacheKeys.cart,
        );

        notifyListeners();

        return true;
      }

      // ----------------------------------------------
      // LOGGED IN
      // ----------------------------------------------

      await _shopService.clearCart();

      _items = [];

      await CacheService.remove(
        CacheKeys.cart,
      );

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint(
        'Clear cart error: $e',
      );

      return false;
    }
  }

  // --------------------------------------------------
  // SYNC GUEST CART
  // --------------------------------------------------

  Future<bool> syncGuestCart() async {
    try {
      final loggedIn =
          await AuthService.isLoggedIn();

      if (!loggedIn) {
        return false;
      }

      final cached =
          await CacheService.getList(
        CacheKeys.cart,
      );

      if (cached.isEmpty) {
        await _loadFromApi();

        return true;
      }

      debugPrint(
        '===== SYNCING GUEST CART =====',
      );

      debugPrint(
        cached.toString(),
      );

      // ----------------------------------------------
      // ADD EACH GUEST ITEM TO ACCOUNT CART
      // ----------------------------------------------

      for (final rawItem in cached) {
        final item =
            Map<String, dynamic>.from(
          rawItem,
        );

        final itemId =
            int.tryParse(
          item['item_id']?.toString() ??
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

      // ----------------------------------------------
      // GET FINAL SERVER CART
      // ----------------------------------------------

      await _loadFromApi();

      // ----------------------------------------------
      // REMOVE GUEST CACHE
      // ----------------------------------------------

      await CacheService.remove(
        CacheKeys.cart,
      );

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint(
        'Cart synchronization error: $e',
      );

      return false;
    }
  }
}