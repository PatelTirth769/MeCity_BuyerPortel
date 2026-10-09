import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mecity_marketplace/data/mock_data.dart';

class FirebaseSeeder {
  static Future<void> seedInitialDataIfEmpty() async {
    final db = FirebaseFirestore.instance;

    try {
      // 1. Seed Products
      final productsSnapshot = await db.collection('products').limit(1).get();
      if (productsSnapshot.docs.isEmpty) {
        final batch = db.batch();
        for (final product in MockData.products) {
          batch.set(db.collection('products').doc(product.id), product.toMap());
        }
        await batch.commit();
      }

      // 2. Seed Categories
      final categoriesSnapshot = await db.collection('categories').limit(1).get();
      if (categoriesSnapshot.docs.isEmpty) {
        final batch = db.batch();
        for (final category in MockData.categories) {
          batch.set(db.collection('categories').doc(category.id), category.toMap());
        }
        await batch.commit();
      }

      // 3. Seed Shops
      final shopsSnapshot = await db.collection('shops').limit(1).get();
      if (shopsSnapshot.docs.isEmpty) {
        final batch = db.batch();
        for (final shop in MockData.shops) {
          batch.set(db.collection('shops').doc(shop.id), shop.toMap());
        }
        await batch.commit();
      }

      // 4. Seed User Profile
      final userDoc = await db.collection('users').doc(MockData.currentUser.id).get();
      if (!userDoc.exists) {
        await db.collection('users').doc(MockData.currentUser.id).set(MockData.currentUser.toMap());
      }
    } catch (e) {
      // Fallback silently if offline or uninitialized
    }
  }
}
