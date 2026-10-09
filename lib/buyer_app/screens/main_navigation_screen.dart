import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mecity_marketplace/providers/cart_provider.dart';
import 'package:mecity_marketplace/providers/wishlist_provider.dart';
import 'package:mecity_marketplace/providers/auth_provider.dart';
import 'package:mecity_marketplace/buyer_app/screens/home_screen.dart';
import 'package:mecity_marketplace/buyer_app/screens/products_screen.dart';
import 'package:mecity_marketplace/buyer_app/screens/events_screen.dart';
import 'package:mecity_marketplace/buyer_app/screens/cart_screen.dart';
import 'package:mecity_marketplace/buyer_app/screens/wishlist_screen.dart';
import 'package:mecity_marketplace/buyer_app/screens/profile_screen.dart';
import 'package:mecity_marketplace/buyer_app/screens/login_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _customerPages = const [
    HomeScreen(),
    ProductsScreen(),
    EventsScreen(),
    CartScreen(),
    WishlistScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // If user is logged out, present Login/Register Screen
    if (!authProvider.isLoggedIn) {
      return const LoginScreen();
    }

    // Render Buyer (Customer) Shopping App with Bottom Navigation Bar
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _customerPages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (idx) => setState(() => _currentIndex = idx),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).textTheme.bodyMedium?.color,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          backgroundColor: Colors.transparent,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Catalog',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.flash_on_rounded),
              label: 'Flash Sale',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                label: Text(cartProvider.itemCount.toString()),
                isLabelVisible: cartProvider.itemCount > 0,
                backgroundColor: const Color(0xFFEF4444),
                child: const Icon(Icons.shopping_cart_rounded),
              ),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                label: Text(wishlistProvider.count.toString()),
                isLabelVisible: wishlistProvider.count > 0,
                backgroundColor: const Color(0xFF6366F1),
                child: const Icon(Icons.favorite_rounded),
              ),
              label: 'Wishlist',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}

// Alias for BuyerHomePage
typedef BuyerHomePage = MainNavigationScreen;

