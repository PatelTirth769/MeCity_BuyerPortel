import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mecity_marketplace/models/product.dart';
import 'package:mecity_marketplace/models/category.dart';
import 'package:mecity_marketplace/models/shop.dart';
import 'package:mecity_marketplace/models/user.dart';
import 'package:mecity_marketplace/models/order.dart';
import 'package:mecity_marketplace/models/chat.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection references
  static CollectionReference get _productsRef => _db.collection('products');
  static CollectionReference get _categoriesRef => _db.collection('categories');
  static CollectionReference get _shopsRef => _db.collection('shops');
  static CollectionReference get _usersRef => _db.collection('users');
  static CollectionReference get _ordersRef => _db.collection('orders');
  static CollectionReference get _chatsRef => _db.collection('chats');

  // --- PRODUCTS ---
  static Stream<List<Product>> getProductsStream() {
    return _productsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  static Future<void> addProduct(Product product) async {
    await _productsRef.doc(product.id).set(product.toMap());
  }

  static Future<void> addReview(String productId, Review review) async {
    final docRef = _productsRef.doc(productId);
    final doc = await docRef.get();
    if (doc.exists) {
      final product = Product.fromFirestore(doc);
      final updatedReviews = List<Review>.from(product.reviews)..insert(0, review);
      final newRating = ((product.rating * product.reviewsCount) + review.rating) / (product.reviewsCount + 1);

      await docRef.update({
        'rating': double.parse(newRating.toStringAsFixed(1)),
        'reviewsCount': product.reviewsCount + 1,
        'reviews': updatedReviews.map((r) => r.toMap()).toList(),
      });
    }
  }

  // --- CATEGORIES ---
  static Stream<List<CategoryModel>> getCategoriesStream() {
    return _categoriesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList();
    });
  }

  // --- SHOPS ---
  static Stream<List<ShopModel>> getShopsStream() {
    return _shopsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ShopModel.fromFirestore(doc)).toList();
    });
  }

  static Future<void> createShop(ShopModel shop) async {
    await _shopsRef.doc(shop.id).set(shop.toMap());
  }

  static Future<void> updateShop(ShopModel shop) async {
    await _shopsRef.doc(shop.id).update(shop.toMap());
  }

  static Future<void> verifyShop(String shopId) async {
    await _shopsRef.doc(shopId).update({'isVerified': true});
  }

  // --- USERS ---
  static Future<void> saveUser(UserModel user) async {
    await _usersRef.doc(user.id).set(user.toMap(), SetOptions(merge: true));
  }

  static Stream<UserModel?> getUserStream(String userId) {
    return _usersRef.doc(userId).snapshots().map((doc) {
      if (doc.exists) return UserModel.fromFirestore(doc);
      return null;
    });
  }

  // --- ORDERS ---
  static Stream<List<OrderModel>> getOrdersStream() {
    return _ordersRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    });
  }

  static Future<void> createOrder(OrderModel order) async {
    await _ordersRef.doc(order.id).set(order.toMap());
  }

  static Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await _ordersRef.doc(orderId).update({'status': newStatus.name});
  }

  // --- CHATS ---
  static Stream<List<ChatMessage>> getChatsStream() {
    return _chatsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
    });
  }

  static Future<void> sendMessage(ChatMessage message) async {
    await _chatsRef.doc(message.id).set(message.toMap());
  }
}
