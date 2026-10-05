import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late String _currentStatus;
  bool _isUpdating = false;

  final List<String> _statusOptions = [
    'Pending',
    'Confirmed',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Confirmed':
        return Colors.teal;
      case 'Processing':
        return Colors.blue;
      case 'Shipped':
        return Colors.purple;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    try {
      await _firestoreService.updateOrderStatus(widget.order.id, newStatus);
      setState(() {
        _currentStatus = newStatus;
        _isUpdating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUpdating = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating status: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'MMM dd, yyyy - hh:mm a',
    ).format(widget.order.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order #${widget.order.id.length > 8 ? widget.order.id.substring(0, 8) : widget.order.id}',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status & Action Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Order Status',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              _currentStatus,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getStatusColor(_currentStatus),
                            ),
                          ),
                          child: Text(
                            _currentStatus,
                            style: TextStyle(
                              color: _getStatusColor(_currentStatus),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Placed on: $formattedDate',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const Divider(height: 24),
                    const Text(
                      'Update Status:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    _isUpdating
                        ? const Center(child: CircularProgressIndicator())
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _statusOptions.map((status) {
                              final isSelected = status == _currentStatus;
                              return ChoiceChip(
                                label: Text(status),
                                selected: isSelected,
                                selectedColor: _getStatusColor(
                                  status,
                                ).withValues(alpha: 0.25),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? _getStatusColor(status)
                                      : Colors.black87,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                onSelected: (selected) {
                                  if (selected && status != _currentStatus) {
                                    _updateStatus(status);
                                  }
                                },
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Customer Details Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      Icons.person_outline,
                      'Name',
                      widget.order.customerName,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.email_outlined,
                      'Email',
                      widget.order.customerEmail,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.phone_outlined,
                      'Phone',
                      widget.order.customerPhone.isNotEmpty
                          ? widget.order.customerPhone
                          : 'N/A',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.location_on_outlined,
                      'Address',
                      widget.order.customerAddress,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.payment,
                      'Payment',
                      widget.order.paymentMethod,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Items Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ordered Items (${widget.order.items.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Divider(height: 20),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.order.items.length,
                      separatorBuilder: (ctx, idx) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final item = widget.order.items[index];
                        return Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey.shade100,
                                child: Image.network(
                                  item.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '\$${item.price.toStringAsFixed(2)} x ${item.quantity}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '\$${widget.order.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        SizedBox(
          width: 70,
          child: Text(
            '$label:',
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
