import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mecity_marketplace/providers/auth_provider.dart';
import 'package:mecity_marketplace/providers/order_provider.dart';
import 'package:mecity_marketplace/models/order.dart';
import 'package:mecity_marketplace/models/user.dart';
import 'package:mecity_marketplace/services/chat_service.dart';
import 'package:mecity_marketplace/buyer_app/screens/chat_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Color bgColor = const Color(0xFF0F172A);
  final Color cardColor = const Color(0xFF1E293B);
  final Color inputColor = const Color(0xFF0F172A);
  final Color accentColor = const Color(0xFFFBBF24);
  final Color textPrimary = Colors.white;
  final Color textSecondary = const Color(0xFF94A3B8);

  final List<String> _menuItems = [
    'Profile',
    'Orders',
    'Refunds',
    'Inbox',
    'Track Order',
    'Change Pwd',
    'Address',
    'Logout'
  ];

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _menuItems.length, vsync: this);
    
    _tabController.addListener(() {
      if (_tabController.index == _menuItems.length - 1) { 
        int prevIndex = _tabController.previousIndex;
        _tabController.index = prevIndex;
        _showLogoutDialog(context);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      if (authProvider.user.id.isNotEmpty && !authProvider.user.id.startsWith('u_')) {
         orderProvider.fetchOrdersFromApi(authProvider.user.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('Logout Account', style: TextStyle(color: textPrimary)),
        content: Text('Are you sure you want to log out of your account?', style: TextStyle(color: textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully!')),
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  bool _isProfileInit = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  void _initProfileData(UserModel user) {
    if (!_isProfileInit && user.id.isNotEmpty) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber;
      _latController.text = user.latitude?.toString() ?? '';
      _lngController.text = user.longitude?.toString() ?? '';
      _isProfileInit = true;
    }
  }

  Widget _buildProfileDetails(UserModel user) {
    _initProfileData(user);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(user.avatarUrl.isNotEmpty ? user.avatarUrl : 'https://ui-avatars.com/api/?name=${user.name}'),
            backgroundColor: const Color(0xFF4ADE80),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildTextField('Full Name', _nameController)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField('Email Address', _emailController)),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.48,
              child: _buildTextField('Phone Number', _phoneController, keyboardType: TextInputType.phone),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text('My Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.my_location, size: 14, color: Colors.black),
                      label: const Text('Detect', style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Set your location to find nearby stores.', style: TextStyle(color: textSecondary, fontSize: 12)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField('Latitude', _latController, keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField('Longitude', _lngController, keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Tip: Pin your exact location on the map to see stores within a 5-10km radius of your home!',
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final lat = double.tryParse(_latController.text);
                final lng = double.tryParse(_lngController.text);
                
                final success = await authProvider.updateUserInfo(
                  name: _nameController.text.trim(),
                  email: _emailController.text.trim(),
                  phoneNumber: _phoneController.text.trim(),
                  latitude: lat,
                  longitude: lng,
                );
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? 'Profile updated successfully!' : (authProvider.errorMessage ?? 'Failed to update profile.'))),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5), // Indigo-600
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Update Information', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textSecondary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: textPrimary, fontSize: 14),
          decoration: InputDecoration(
            fillColor: inputColor,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            hintText: 'Enter $label',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersList(OrderProvider orderProvider, {bool refundsOnly = false}) {
    if (orderProvider.isLoading) return const Center(child: CircularProgressIndicator());
    
    List<OrderModel> orders = orderProvider.orders;
    if (refundsOnly) {
      orders = orders.where((o) => o.status == OrderStatus.processingRefund).toList();
      if (orders.isEmpty) {
        return Center(child: Text('No refund requests.', style: TextStyle(color: textPrimary)));
      }
    } else {
      if (orders.isEmpty) return Center(child: Text('No orders placed yet.', style: TextStyle(color: textPrimary)));
    }
    
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');

    return RefreshIndicator(
      onRefresh: () async {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        if (auth.user.id.isNotEmpty && !auth.user.id.startsWith('u_')) {
          await orderProvider.fetchOrdersFromApi(auth.user.id);
        }
      },
      color: accentColor,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
        final order = orders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Order #${order.id}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (refundsOnly || order.status == OrderStatus.processingRefund || order.status == OrderStatus.refundSuccess)
                        ? const Color(0xFFF59E0B).withOpacity(0.2) // Amber for refunds
                        : const Color(0xFF10B981).withOpacity(0.2), // Emerald for delivered
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      order.status.apiString.toUpperCase(),
                      style: TextStyle(
                        color: (refundsOnly || order.status == OrderStatus.processingRefund || order.status == OrderStatus.refundSuccess)
                            ? const Color(0xFFFBBF24)
                            : const Color(0xFF34D399),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Items: ${order.items.map((i) => i.product.name).join(", ")}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: textSecondary),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${currencyFormatter.format(order.totalAmount)}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: accentColor, fontSize: 15),
                  ),
                  if (!refundsOnly && order.status == OrderStatus.delivered)
                    ElevatedButton(
                      onPressed: orderProvider.isLoading ? null : () async {
                        final success = await orderProvider.requestRefund(order.id);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(success ? 'Refund requested successfully' : (orderProvider.errorMessage ?? 'Failed to request refund'))),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444), // Red for refund
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        minimumSize: const Size(80, 32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: orderProvider.isLoading 
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Request Refund', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    ),
    );
  }

  Widget _buildTrackOrder(OrderProvider orderProvider) {
    if (orderProvider.isLoading) return const Center(child: CircularProgressIndicator());
    
    final activeOrders = orderProvider.orders.where((o) => 
      o.status != OrderStatus.delivered && 
      o.status != OrderStatus.refundSuccess && 
      o.status != OrderStatus.cancelled &&
      o.status != OrderStatus.processingRefund
    ).toList();

    if (activeOrders.isEmpty) return Center(child: Text('No active orders to track.', style: TextStyle(color: textPrimary)));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeOrders.length,
      itemBuilder: (context, index) {
        final order = activeOrders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Track Order #${order.id}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
              const SizedBox(height: 4),
              Text('Tracking Number: ${order.trackingNumber}', style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 24),
              ...order.trackingSteps.map((step) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Icon(
                          step.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          color: step.isCompleted ? const Color(0xFF34D399) : textSecondary.withOpacity(0.5),
                          size: 20,
                        ),
                        if (step != order.trackingSteps.last)
                          Container(
                            width: 2,
                            height: 30,
                            color: step.isCompleted ? const Color(0xFF34D399) : textSecondary.withOpacity(0.2),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: step.isCompleted ? textPrimary : textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step.description,
                            style: TextStyle(fontSize: 12, color: textSecondary),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('My Account & Profile', style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary)),
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: accentColor,
              unselectedLabelColor: textSecondary,
              indicatorColor: accentColor,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
              tabs: _menuItems.map((tab) => Tab(text: tab)).toList(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileDetails(authProvider.user),
          _buildOrdersList(orderProvider),
          _buildOrdersList(orderProvider, refundsOnly: true),
          const _InboxTab(),
          _buildTrackOrder(orderProvider),
          const _ChangePasswordTab(),
          const _AddressTab(),
          Center(child: Text('Logging out...', style: TextStyle(color: textPrimary))),
        ],
      ),
    );
  }
}

class _ChangePasswordTab extends StatefulWidget {
  const _ChangePasswordTab();
  @override
  State<_ChangePasswordTab> createState() => _ChangePasswordTabState();
}

class _ChangePasswordTabState extends State<_ChangePasswordTab> {
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obsOld = true;
  bool _obsNew = true;
  bool _obsConfirm = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Security Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Update your account password', style: TextStyle(color: Color(0xFF94A3B8))),
          const SizedBox(height: 32),
          
          _buildPasswordField('Old Password', _oldCtrl, _obsOld, () => setState(() => _obsOld = !_obsOld)),
          const SizedBox(height: 16),
          _buildPasswordField('New Password', _newCtrl, _obsNew, () => setState(() => _obsNew = !_obsNew)),
          const SizedBox(height: 16),
          _buildPasswordField('Confirm New Password', _confirmCtrl, _obsConfirm, () => setState(() => _obsConfirm = !_obsConfirm)),
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : () async {
                if (_newCtrl.text != _confirmCtrl.text) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New passwords do not match')));
                  return;
                }
                final success = await authProvider.changePassword(
                  oldPassword: _oldCtrl.text, 
                  newPassword: _newCtrl.text, 
                  confirmPassword: _confirmCtrl.text
                );
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated!')));
                  _oldCtrl.clear();
                  _newCtrl.clear();
                  _confirmCtrl.clear();
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authProvider.errorMessage ?? 'Failed to update')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFBBF24),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: authProvider.isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black))
                  : const Text('Update Password', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController ctrl, bool obs, VoidCallback toggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF94A3B8))),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          obscureText: obs,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            fillColor: const Color(0xFF0F172A),
            filled: true,
            suffixIcon: IconButton(
              icon: Icon(obs ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
              onPressed: toggle,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFBBF24))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _AddressTab extends StatefulWidget {
  const _AddressTab();
  @override
  State<_AddressTab> createState() => _AddressTabState();
}

class _AddressTabState extends State<_AddressTab> {
  bool _isAdding = false;
  final _countryCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _address1Ctrl = TextEditingController();
  final _address2Ctrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  String _addressType = 'Default';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (_isAdding) {
      return _buildAddAddressForm(authProvider);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Delivery Addresses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 16, color: Colors.black),
                label: const Text('Add', style: TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold)),
                onPressed: () => setState(() => _isAdding = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFBBF24),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (user.addresses.isEmpty)
             Center(
               child: Padding(
                 padding: const EdgeInsets.only(top: 40),
                 child: Text('No saved addresses found.', style: TextStyle(color: Colors.white.withOpacity(0.5))),
               )
             )
          else 
            Expanded(
              child: ListView.builder(
                itemCount: user.addresses.length,
                itemBuilder: (context, idx) {
                  final addr = user.addresses[idx];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(addr.addressType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                              const SizedBox(height: 8),
                              Text('${addr.addressLine1} ${addr.addressLine2}, ${addr.city}, ${addr.country} - ${addr.zipCode}', style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('PHONE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                            Text(user.phoneNumber, style: const TextStyle(fontSize: 13, color: Colors.white)),
                          ],
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                            await authProvider.deleteAddress(addr.id);
                          },
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddAddressForm(AuthProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => setState(() => _isAdding = false),
              ),
              const Text('Add New Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          _buildField('Country', _countryCtrl),
          const SizedBox(height: 12),
          _buildField('City', _cityCtrl),
          const SizedBox(height: 12),
          _buildField('Address Line 1', _address1Ctrl),
          const SizedBox(height: 12),
          _buildField('Address Line 2 (Optional)', _address2Ctrl),
          const SizedBox(height: 12),
          _buildField('Zip Code', _zipCtrl, isNumber: true),
          const SizedBox(height: 12),
          const Text('Address Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF94A3B8))),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _addressType,
            dropdownColor: const Color(0xFF1E293B),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              fillColor: const Color(0xFF0F172A),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFBBF24))),
            ),
            items: ['Default', 'Home', 'Office'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _addressType = val);
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: provider.isLoading ? null : () async {
                final addr = AddressModel(
                  id: '',
                  addressType: _addressType,
                  addressLine1: _address1Ctrl.text,
                  addressLine2: _address2Ctrl.text,
                  city: _cityCtrl.text,
                  country: _countryCtrl.text,
                  zipCode: _zipCtrl.text,
                );
                final success = await provider.addAddress(addr);
                if (success && mounted) {
                  setState(() => _isAdding = false);
                  _countryCtrl.clear();
                  _cityCtrl.clear();
                  _address1Ctrl.clear();
                  _address2Ctrl.clear();
                  _zipCtrl.clear();
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage ?? 'Failed')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFBBF24),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: provider.isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black))
                  : const Text('Save Address', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF94A3B8))),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            fillColor: const Color(0xFF0F172A),
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFBBF24))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _InboxTab extends StatefulWidget {
  const _InboxTab();
  @override
  State<_InboxTab> createState() => _InboxTabState();
}

class _InboxTabState extends State<_InboxTab> {
  bool _isLoading = true;
  List<dynamic> _conversations = [];
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).user.id;
    final chats = await _chatService.getUserConversations(userId);
    if (mounted) {
      setState(() {
        _conversations = chats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_conversations.isEmpty) {
      return const Center(child: Text('No active conversations.', style: TextStyle(color: Colors.white)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _conversations.length,
      itemBuilder: (context, idx) {
        final msg = _conversations[idx];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(conversation: msg),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF0F172A),
                  radius: 18,
                  child: Icon(Icons.store, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Seller Chat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(msg['lastMessage'] ?? 'Started a conversation', style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
