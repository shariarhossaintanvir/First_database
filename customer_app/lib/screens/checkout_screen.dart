import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../theme/app_theme.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  /// When non-null, the checkout flow places an order for this single item
  /// only. The customer's existing cart is NOT modified or cleared.
  final CartItemModel? buyNowItem;

  const CheckoutScreen({super.key, this.buyNowItem});

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

  final String _paymentMethod = 'Cash on Delivery';
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
    // 1. Prevent duplicate concurrent submissions
    if (_isPlacingOrder) return;
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthService>(context, listen: false);
    final cart = Provider.of<CartProvider>(context, listen: false);

    // Determine which items we are ordering
    final isBuyNow = widget.buyNowItem != null;
    final itemsToOrder = isBuyNow ? [widget.buyNowItem!] : cart.itemList;

    if (itemsToOrder.isEmpty) {
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
      // 2. Immediate Pre-Submission Stock Revalidation against Firestore
      // (Note: Client-side stock revalidation checks live Firestore document before creating the order.
      // This eliminates stale cart submissions, but full concurrency isolation would require backend Cloud Functions).
      final stockIssues = <String>[];
      for (final cartItem in itemsToOrder) {
        final freshProduct = await _firestoreService.getProductById(cartItem.product.id);
        if (freshProduct == null) {
          stockIssues.add('"${cartItem.product.title}" is no longer listed in our catalog.');
        } else if (!freshProduct.isAvailable || freshProduct.stock <= 0) {
          stockIssues.add('"${freshProduct.title}" is now out of stock.');
        } else if (freshProduct.stock < cartItem.quantity) {
          stockIssues.add('"${freshProduct.title}" only has ${freshProduct.stock} units remaining (requested: ${cartItem.quantity}).');
        }
      }

      if (stockIssues.isNotEmpty) {
        setState(() => _isPlacingOrder = false);
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppTheme.surfaceCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                side: const BorderSide(color: AppTheme.borderSubtle),
              ),
              title: const Row(
                children: [
                  Icon(Icons.inventory_2_outlined, color: AppTheme.accent),
                  SizedBox(width: 8),
                  Text('Stock Availability Alert', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'The following items have updated stock in our inventory:',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  ...stockIssues.map((issue) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(issue, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 8),
                  const Text(
                    'Please return to the previous screen to update the quantity.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: AppTheme.bgPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context); // Go back to product/cart
                  },
                  child: Text(isBuyNow ? 'Go Back' : 'Edit Cart'),
                ),
              ],
            ),
          );
        }
        return;
      }

      final user = auth.currentUser!;
      final totalAmount = itemsToOrder.fold<double>(
        0.0,
        (runningTotal, ci) => runningTotal + ci.totalPrice,
      );
      final orderItems = itemsToOrder.map((ci) {
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
        totalAmount: totalAmount,
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

      // Clear main cart only for regular checkout — not for Buy Now
      if (!isBuyNow) {
        cart.clearCart();
      }

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
    final isBuyNow = widget.buyNowItem != null;
    final checkoutItems = isBuyNow ? [widget.buyNowItem!] : cart.itemList;
    final checkoutItemCount = isBuyNow
        ? widget.buyNowItem!.quantity
        : cart.itemCount;
    final checkoutTotalAmount = isBuyNow
        ? widget.buyNowItem!.totalPrice
        : cart.totalAmount;

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(widget.buyNowItem != null ? 'Buy Now — Checkout' : 'Checkout & Delivery'),
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
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
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
                          'Place Order • ৳ ${checkoutTotalAmount.toStringAsFixed(0)}',
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
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
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
                              labelText: 'Phone Number (e.g. 017xxxxxxxx) *',
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
                              hintText: 'House, Road, Area, City, District',
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

                  // Payment Method Section (Cash on Delivery Only)
                  Card(
                    color: AppTheme.surfaceCard,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
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

                          // Official Cash on Delivery Card
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                              border: Border.all(color: AppTheme.accent, width: 1.5),
                              color: AppTheme.accentSubtle,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.payments_outlined,
                                  color: AppTheme.accent,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Cash on Delivery (COD)',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textPrimary,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppTheme.accent,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'ACTIVE',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Pay conveniently in cash when the delivery agent hands over your order at your doorstep. Please have the exact change ready.',
                                        style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 12,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      side: const BorderSide(color: AppTheme.borderSubtle),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Summary ($checkoutItemCount ${checkoutItemCount == 1 ? 'item' : 'items'})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: AppTheme.borderSubtle, height: 1),
                          const SizedBox(height: 12),
                          ...checkoutItems.map((item) {
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
                                '৳ ${checkoutTotalAmount.toStringAsFixed(0)}',
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Standard Delivery:', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                              const Text(
                                '৳ 0 (Included)',
                                style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Payable (COD):',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                '৳ ${checkoutTotalAmount.toStringAsFixed(0)}',
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
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
