import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop/constants.dart';
import 'package:shop/services/admin_service.dart';
import 'package:intl/intl.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final AdminService _adminService = AdminService();
  String _selectedStatus = 'all';

  String formatRp(dynamic value) {
    return formatCurrency(value is int ? value.toDouble() : (value as num).toDouble());
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '-';
    try {
      if (timestamp is Timestamp) {
        return DateFormat('dd MMM yyyy HH:mm').format(timestamp.toDate());
      }
      return '-';
    } catch (e) {
      return '-';
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'waiting_payment':
        return 'Menunggu Pembayaran';
      case 'processing':
        return 'Sedang Diproses';
      case 'shipped':
        return 'Sedang Dikirim';
      case 'delivered':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'waiting_payment':
        return Colors.amber;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _adminService.updateOrderStatus(
        orderId: orderId,
        status: newStatus,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order status updated to $_getStatusText(newStatus)')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _showStatusUpdateDialog(String orderId, String currentStatus) async {
    final statuses = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];
    final newStatus = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statuses.map((status) {
            return RadioListTile<String>(
              title: Text(_getStatusText(status)),
              value: status,
              groupValue: currentStatus,
              onChanged: (value) => Navigator.pop(context, value),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (newStatus != null && newStatus != currentStatus) {
      await _updateOrderStatus(orderId, newStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              children: [
                _StatusFilterChip(
                  label: 'All',
                  value: 'all',
                  selected: _selectedStatus == 'all',
                  onSelected: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _StatusFilterChip(
                  label: 'Pending',
                  value: 'pending',
                  selected: _selectedStatus == 'pending',
                  onSelected: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _StatusFilterChip(
                  label: 'Processing',
                  value: 'processing',
                  selected: _selectedStatus == 'processing',
                  onSelected: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _StatusFilterChip(
                  label: 'Shipped',
                  value: 'shipped',
                  selected: _selectedStatus == 'shipped',
                  onSelected: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _StatusFilterChip(
                  label: 'Delivered',
                  value: 'delivered',
                  selected: _selectedStatus == 'delivered',
                  onSelected: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const Divider(),

          // Orders List
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _adminService.getAllOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No orders found'));
                }

                var orders = snapshot.data!;

                // Filter by status
                if (_selectedStatus != 'all') {
                  orders = orders.where((order) => order['status'] == _selectedStatus).toList();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(defaultPadding),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final status = order['status'] ?? 'pending';
                    final items = order['items'] as List<dynamic>? ?? [];

                    return Card(
                      margin: const EdgeInsets.only(bottom: defaultPadding),
                      child: ExpansionTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.shopping_bag,
                            color: _getStatusColor(status),
                          ),
                        ),
                        title: Text(
                          'Order #${order['id']?.substring(0, 8) ?? 'N/A'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total: ${formatRp(order['total'] ?? 0)}'),
                            Text(
                              'Date: ${_formatDate(order['createdAt'])}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(status),
                            style: TextStyle(
                              color: _getStatusColor(status),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(defaultPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Order Items
                                Text(
                                  'Items:',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                ...items.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${item['quantity'] ?? 0}x ${item['name'] ?? 'Item'}',
                                          ),
                                        ),
                                        Text(formatRp((item['price'] ?? 0) * (item['quantity'] ?? 0))),
                                      ],
                                    ),
                                  );
                                }),
                                const Divider(),
                                
                                // Shipping Address
                                if (order['shippingAddress'] != null) ...[
                                  Text(
                                    'Shipping Address:',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${order['shippingAddress']['name'] ?? ''}\n'
                                    '${order['shippingAddress']['address'] ?? ''}, '
                                    '${order['shippingAddress']['city'] ?? ''}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const Divider(),
                                ],

                                // Payment Method
                                if (order['paymentMethodName'] != null) ...[
                                  Text(
                                    'Payment: ${order['paymentMethodName']}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: defaultPadding),
                                ],

                                // Action Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _showStatusUpdateDialog(
                                      order['id'],
                                      status,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Update Status'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final Function(String) onSelected;

  const _StatusFilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(value),
      selectedColor: primaryColor.withOpacity(0.2),
      checkmarkColor: primaryColor,
    );
  }
}

