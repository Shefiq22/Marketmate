import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/cart_repository.dart';
import '../repositories/products_repository.dart';

class CartProvider extends ChangeNotifier {
  final CartRepository _repo = CartRepository();
  final ProductsRepository _productRepo = ProductsRepository();
  final List<CartItem> _items = [];
  bool _initialized = false;
  bool _stockValidated = false;
  bool _isValidating = false;

  List<CartItem> get items => List.unmodifiable(_items);
  List<CartItem> get selectedItems => _items.where((i) => i.selected).toList();

  List<CartItem> get availableItems =>
      _items.where((i) => i.selected && !i.outOfStock).toList();

  List<CartItem> get outOfStockItems =>
      _items.where((i) => i.outOfStock).toList();

  bool get hasAvailableItems => availableItems.isNotEmpty;
  bool get stockValidated => _stockValidated;
  bool get isValidating => _isValidating;

  bool get canProceedToCheckout {
    if (_items.isEmpty) return false;
    return availableItems.isNotEmpty;
  }

  int get totalCount => _items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => availableItems.fold(0, (sum, i) => sum + i.total);

  double get deliveryFee => availableItems.isEmpty ? 0 : 2000;

  double get grandTotal => subtotal + deliveryFee;

  bool get isInitialized => _initialized;

  bool isInCart(String productId) =>
      _items.any((i) => i.product.id == productId);

  int quantityOf(String productId) {
    final item = _items.where((i) => i.product.id == productId);
    return item.isEmpty ? 0 : item.first.quantity;
  }

  Future<void> loadFromApi() async {
    try {
      final apiItems = await _repo.getCart();
      _items
        ..clear()
        ..addAll(apiItems);
      _initialized = true;
      notifyListeners();
    } catch (_) {
      _initialized = true;
    }
  }

  Future<void> validateStock() async {
    if (_items.isEmpty || _isValidating) return;
    _isValidating = true;
    notifyListeners();

    final futures = _items.map((item) async {
      try {
        final liveProduct = await _productRepo.getById(item.product.id);
        if (liveProduct.stock <= 0 || !liveProduct.isAvailable) {
          item.outOfStock = true;
          item.stockWarning = null;
        } else if (item.quantity > liveProduct.stock) {
          item.outOfStock = false;
          item.stockWarning = 'Only ${liveProduct.stock} items left in stock!';
          item.quantity = liveProduct.stock;
        } else {
          item.outOfStock = false;
          item.stockWarning = null;
        }
      } catch (_) {
        // Keep item as-is if the API call fails
      }
    }).toList();

    await Future.wait(futures);
    _stockValidated = true;
    _isValidating = false;
    notifyListeners();
  }

  void resetStockValidation() {
    for (final item in _items) {
      item.outOfStock = false;
      item.stockWarning = null;
    }
    _stockValidated = false;
    notifyListeners();
  }

  void addItem(Product product) {
    final idx = _items.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      _items[idx].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    _stockValidated = false;
    notifyListeners();
    _repo.addItem(product.id).catchError((_) {});
  }

  void removeItem(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    if (_items.isEmpty) _stockValidated = false;
    notifyListeners();
    _repo.removeItem(productId).catchError((_) {});
  }

  void increment(String productId) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      _items[idx].quantity++;
      _stockValidated = false;
      notifyListeners();
    }
  }

  void decrement(String productId) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      if (_items[idx].quantity > 1) {
        _items[idx].quantity--;
      } else {
        _items.removeAt(idx);
      }
      _stockValidated = false;
      notifyListeners();
    }
  }

  void toggleSelect(String productId) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      _items[idx].selected = !_items[idx].selected;
      notifyListeners();
    }
  }

  /// Builds the checkout payload excluding out-of-stock items,
  /// only including items that are selected and in stock.
  List<Map<String, dynamic>> get checkoutPayload {
    return availableItems
        .map((item) => {
              'product': item.product.id,
              'quantity': item.quantity,
            })
        .toList();
  }

  void clearCart() {
    _items.clear();
    _stockValidated = false;
    notifyListeners();
  }
}
