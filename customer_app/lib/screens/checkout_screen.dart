import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../providers/cart_provider.dart';
import '../models/order_model.dart';
import '../theme/app_theme.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  StreamSubscription<DocumentSnapshot>? _profileSubscription;
  bool _hasPrepopulated = false;
  bool _saveAsDefaultAddress = false;

  String _paymentMethod = 'Cash on Delivery';
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthService>(context, listen: false);
    _nameController = TextEditingController(
      text: auth.currentUser?.displayName ?? '',
    );
    _phoneController = TextEditingController();
    _addressController = TextEditingController();

    _profileSubscription = auth.getUserProfileStream().listen((snapshot) {
      if (!_hasPrepopulated && mounted && snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          if (_nameController.text.trim().isEmpty && data['name'] != null && (data['name'] as String).isNotEmpty) {
            _nameController.text = data['name'] as String;
          }
          if (_phoneController.text.trim().isEmpty && data['phone'] != null && (data['phone'] as String).isNotEmpty) {
            _phoneController.text = data['phone'] as String;
          }
          if (_addressController.text.trim().isEmpty && data['address'] != null && (data['address'] as String).isNotEmpty) {
            _addressController.text = data['address'] as String;
          }
        }
        _hasPrepopulated = true;
      }
    });
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handlePlaceOrder() async {
    if (_isPlacingOrder) return;
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthService>(context, listen: false);
    final cart = Provider.of<CartProvider>(context, listen: false);

    if (cart.itemList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty!'),
          backgroundColor: AppTheme.surfaceElevated,
        ),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      final user = auth.currentUser!;
      final orderItems = cart.itemList.map((ci) {
        return OrderItemModel(
          productId: ci.product.id,
          title: ci.product.title,
          price: ci.product.price,
          quantity: ci.quantity,
          imageUrl: ci.product.imageUrl,
        );
      }).toList();

      final order = OrderModel(
        id: '',
        userId: user.uid,
        customerName: _nameController.text.trim(),
        customerEmail: user.email ?? '',
        customerPhone: _phoneController.text.trim(),
        customerAddress: _addressController.text.trim(),
        paymentMethod: _paymentMethod,
        items: orderItems,
        totalAmount: cart.totalAmount,
        status: 'Pending',
        createdAt: DateTime.now(),
      );

      final orderId = await _firestoreService.placeOrder(order);

      // Save as default profile address if selected by customer
      if (_saveAsDefaultAddress) {
        try {
          await auth.updateProfile(
            phone: _phoneController.text.trim(),
            address: _addressController.text.trim(),
          );
        } catch (profileError) {
          debugPrint('Non-critical profile address update error: $profileError');
        }
      }

      // Clear the cart
      cart.clearCart();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderSuccessScreen(orderId: orderId),
          ),
        );
      }
    } catch (e) {
      setState(() => _isPlacingOrder = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: AppTheme.statusError,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgPrimary,
        elevation: 0,
        title: const Text('Checkout & Delivery'),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceCard,
          border: Border(top: BorderSide(color: AppTheme.borderSubtle, width: 1)),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPlacingOrder ? null : _handlePlaceOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: AppTheme.bgPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isPlacingOrder
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.bgPrimary,
                          ),
                        )
                      : Text(
                          'Place Order • ৳ ${cart.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              // Shipping Address Section
              Card(
                color: AppTheme.surfaceCard,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppTheme.borderSubtle),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.accentSubtle,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.location_on_outlined, color: AppTheme.accent, size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Shipping Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                        decoration: const InputDecoration(
                          labelText: 'Recipient Full Name *',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter recipient name';
                          }
                          final trimmed = v.trim();
                          if (trimmed.length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          if (trimmed.length > 100) {
                            return 'Name cannot exceed 100 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                        decoration: const InputDecoration(
                          labelText: 'Phone Number *',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter phone number';
                          }
                          final phone = v.trim();
                          if (phone.length < 5 || phone.length > 30) {
                            return 'Phone number must be between 5 and 30 characters';
                          }
                          final phoneRegex = RegExp(r'^[0-9+\-()\s]+$');
                          if (!phoneRegex.hasMatch(phone)) {
                            return 'Enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                        decoration: const InputDecoration(
                          labelText: 'Delivery Address in Bangladesh *',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter delivery address';
                          }
                          final trimmed = v.trim();
                          if (trimmed.length < 5) {
                            return 'Address must be at least 5 characters';
                          }
                          if (trimmed.length > 500) {
                            return 'Address cannot exceed 500 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      CheckboxListTile(
                        value: _saveAsDefaultAddress,
                        onChanged: _isPlacingOrder
                            ? null
                            : (val) => setState(() => _saveAsDefaultAddress = val ?? false),
                        title: const Text(
                          'Save as default address in my profile',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppTheme.accent,
                        checkColor: AppTheme.bgPrimary,
                        dense: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Payment Method Section
              Card(
                color: AppTheme.surfaceCard,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppTheme.borderSubtle),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.accentSubtle,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.payment_outlined, color: AppTheme.accent, size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Payment Method',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildPaymentOption(
                        title: 'Cash on Delivery (COD)',
                        subtitle: 'Pay with cash upon delivery of your items',
                        icon: Icons.payments_outlined,
                        value: 'Cash on Delivery',
                        isAvailable: true,
                      ),
                      const SizedBox(height: 10),
                      _buildPaymentOption(
                        title: 'bKash / Nagad / Rocket',
                        subtitle: 'Online payment gateway not currently integrated',
                        icon: Icons.account_balance_wallet_outlined,
                        value: 'Mobile Banking',
                        isAvailable: false,
                        badgeText: 'Unavailable',
                      ),
                      const SizedBox(height: 10),
                      _buildPaymentOption(
                        title: 'Credit / Debit Card',
                        subtitle: 'Card payment gateway not currently integrated',
                        icon: Icons.credit_card_outlined,
                        value: 'Credit / Debit Card',
                        isAvailable: false,
                        badgeText: 'Unavailable',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Order Summary Card
              Card(
                color: AppTheme.surfaceCard,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppTheme.borderSubtle),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Summary (${cart.itemCount} items)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: AppTheme.borderSubtle, height: 1),
                      const SizedBox(height: 12),
                      ...cart.itemList.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity}x ${item.product.title}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                ),
                              ),
                              Text(
                                '৳ ${item.totalPrice.toStringAsFixed(0)}',
                                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      const Divider(color: AppTheme.borderSubtle, height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal:', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                          Text(
                            '৳ ${cart.totalAmount.toStringAsFixed(0)}',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Payable:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            '৳ ${cart.totalAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppTheme.accent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
  ),
);
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    bool isAvailable = true,
    String? badgeText,
  }) {
    final isSelected = isAvailable && _paymentMethod == value;

    return InkWell(
      onTap: isAvailable ? () => setState(() => _paymentMethod = value) : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppTheme.accent
                : (isAvailable ? AppTheme.borderSubtle : AppTheme.borderSubtle.withValues(alpha: 0.5)),
            width: isSelected ? 1.5 : 1,
          ),
          color: isSelected
              ? AppTheme.accentSubtle
              : (isAvailable ? AppTheme.bgSecondary : AppTheme.bgPrimary),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.accent
                  : (isAvailable ? AppTheme.textMuted : AppTheme.textDisabled),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isAvailable ? AppTheme.textPrimary : AppTheme.textMuted,
                          fontSize: 14,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.bgSecondary,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isAvailable ? AppTheme.textMuted : AppTheme.textDisabled,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.check_circle
                  : (isAvailable ? Icons.circle_outlined : Icons.block_outlined),
              color: isSelected
                  ? AppTheme.accent
                  : (isAvailable ? AppTheme.textMuted : AppTheme.textDisabled),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
