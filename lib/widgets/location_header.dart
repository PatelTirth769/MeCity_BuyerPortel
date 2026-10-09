import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mecity_marketplace/providers/auth_provider.dart';
import 'package:mecity_marketplace/models/user.dart';

class LocationHeader extends StatelessWidget {
  const LocationHeader({super.key});

  void _showCompulsoryLocationModal(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final currentAddr = authProvider.currentAddress;

    final streetCtrl = TextEditingController(
      text: currentAddr.addressType != 'Default' ? currentAddr.addressLine1 : '',
    );
    final cityCtrl = TextEditingController(
      text: currentAddr.city.isNotEmpty ? currentAddr.city : 'Gandhinagar',
    );
    final zipCtrl = TextEditingController(
      text: currentAddr.zipCode.isNotEmpty ? currentAddr.zipCode : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final isFetching = Provider.of<AuthProvider>(context).isFetchingLocation;

          return Container(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? const Color(0xFF1E293B),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Bar
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.my_location_rounded,
                          color: Color(0xFFD4AF37),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Delivery Location & GPS',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Info Notice Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Live GPS location enables accurate discovery of nearby verified stores, fast delivery, and local discounts.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Primary Live GPS Auto-Detect Button Card
                  GestureDetector(
                    onTap: isFetching
                        ? null
                        : () async {
                            final success = await authProvider.fetchAndSetLiveGpsLocation();
                            if (ctx.mounted) {
                              if (success) {
                                final live = authProvider.currentAddress;
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text('📍 Live GPS location set to: ${live.addressLine1}, ${live.city}!'),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFF10B981),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('⚠️ Unable to access GPS. Please check location permissions in settings.'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            }
                          },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor.withValues(alpha: 0.2),
                            Theme.of(context).primaryColor.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: isFetching
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.gps_fixed_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Use Current Live GPS Location',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'LIVE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isFetching
                                      ? 'Detecting current GPS coordinates...'
                                      : 'Auto-detect exact address using device GPS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Saved Locations List
                  if (user.addresses.isNotEmpty) ...[
                    const Text(
                      'Saved Locations:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    ...user.addresses.map((addr) {
                      final isSelected = authProvider.currentAddress.id == addr.id ||
                          (authProvider.currentAddress.addressLine1 == addr.addressLine1 &&
                              authProvider.currentAddress.city == addr.city);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).dividerColor.withValues(alpha: 0.1),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            addr.addressType == 'Live GPS'
                                ? Icons.gps_fixed_rounded
                                : (addr.addressType == 'Home'
                                    ? Icons.home_rounded
                                    : Icons.location_city_rounded),
                            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                          ),
                          title: Text(
                            '${addr.addressType}: ${addr.addressLine1}',
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${addr.city}, ${addr.country}${addr.zipCode.isNotEmpty ? ' - ${addr.zipCode}' : ''}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: isSelected
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'SELECTED',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                          onTap: () {
                            authProvider.setCurrentAddress(addr);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('📍 Delivery Location set to ${addr.addressLine1}, ${addr.city}!'),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                    const Divider(height: 24),
                  ],

                  // Manual Location Input Section
                  const Text(
                    'Set New Custom Address:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: streetCtrl,
                    decoration: InputDecoration(
                      labelText: 'Street / Area / Landmark *',
                      prefixIcon: const Icon(Icons.streetview_rounded, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: cityCtrl,
                          decoration: InputDecoration(
                            labelText: 'City *',
                            prefixIcon: const Icon(Icons.location_city_rounded, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: zipCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Pincode *',
                            prefixIcon: const Icon(Icons.pin_drop_rounded, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.check_circle_rounded),
                      label: const Text(
                        'Confirm Custom Location',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      onPressed: () {
                        if (streetCtrl.text.isNotEmpty || cityCtrl.text.isNotEmpty) {
                          final newAddr = AddressModel(
                            id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
                            addressType: 'Custom',
                            addressLine1: streetCtrl.text.isNotEmpty ? streetCtrl.text.trim() : 'Market Area',
                            city: cityCtrl.text.isNotEmpty ? cityCtrl.text.trim() : 'Gandhinagar',
                            country: 'India',
                            zipCode: zipCtrl.text.trim(),
                          );
                          authProvider.addAddress(newAddr);
                          authProvider.setCurrentAddress(newAddr);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('📍 Delivery location confirmed: ${newAddr.addressLine1}, ${newAddr.city}!'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentAddr = authProvider.currentAddress;
    final isGps = currentAddr.addressType == 'Live GPS';

    return GestureDetector(
      onTap: () => _showCompulsoryLocationModal(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isGps
                ? const Color(0xFF10B981).withValues(alpha: 0.5)
                : Theme.of(context).primaryColor.withValues(alpha: 0.3),
            width: isGps ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isGps
                  ? const Color(0xFF10B981).withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isGps
                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                    : Theme.of(context).primaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: authProvider.isFetchingLocation
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  : Icon(
                      isGps ? Icons.my_location_rounded : Icons.location_on_rounded,
                      color: isGps ? const Color(0xFF10B981) : Theme.of(context).primaryColor,
                      size: 19,
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'Deliver to ',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          currentAddr.addressType,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isGps ? const Color(0xFF10B981) : Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      if (isGps) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'GPS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 2),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    authProvider.isFetchingLocation
                        ? 'Locating via device GPS...'
                        : '${currentAddr.addressLine1}, ${currentAddr.city}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.gps_fixed_rounded,
                size: 18,
                color: isGps ? const Color(0xFF10B981) : Colors.grey,
              ),
              tooltip: 'Refresh GPS location',
              onPressed: () => authProvider.fetchAndSetLiveGpsLocation(),
            ),
          ],
        ),
      ),
    );
  }
}


