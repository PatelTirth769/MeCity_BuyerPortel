import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mecity_marketplace/firebase_options.dart';
import 'package:mecity_marketplace/services/firebase_seeder.dart';
import 'package:mecity_marketplace/theme/app_theme.dart';
import 'package:mecity_marketplace/providers/theme_provider.dart';
import 'package:mecity_marketplace/providers/auth_provider.dart';
import 'package:mecity_marketplace/providers/product_provider.dart';
import 'package:mecity_marketplace/providers/cart_provider.dart';
import 'package:mecity_marketplace/providers/wishlist_provider.dart';
import 'package:mecity_marketplace/providers/order_provider.dart';
import 'package:mecity_marketplace/providers/shop_provider.dart';
import 'package:mecity_marketplace/providers/category_provider.dart';
import 'package:mecity_marketplace/providers/event_provider.dart';
import 'package:mecity_marketplace/buyer_app/screens/main_navigation_screen.dart';
import 'package:mecity_marketplace/buyer_app/screens/cart_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Seed data in background, don't wait for it to finish before starting app
    FirebaseSeeder.seedInitialDataIfEmpty();
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
  }

  runApp(const MecityBuyerApp());
}

class MecityBuyerApp extends StatelessWidget {
  const MecityBuyerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'mecity',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const MainNavigationScreen(),
            routes: {
              '/cart': (context) => const CartScreen(),
            },
          );
        },
      ),
    );
  }
}
