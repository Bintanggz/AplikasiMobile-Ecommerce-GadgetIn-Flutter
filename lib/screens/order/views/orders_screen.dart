import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop/constants.dart';
import 'package:shop/services/cart_service.dart';
import 'package:shop/components/network_image_with_loader.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  String formatRp(dynamic value) {
    return formatCurrency(value is int ? value.toDouble() : (value as num).toDouble());
  }

  String getStatusText(String status) {
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

  Color getStatusColor(String status) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
      ),
      body: Builder(
        builder: (context) {
          try {
            final cartService = CartService();
            final userId = cartService.currentUserId;
            
            // Get orders stream - remove orderBy to avoid index requirement
            final ordersStream = FirebaseFirestore.instance
                .collection('orders')
                .where('userId', isEqualTo: userId)
                .snapshots();

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: ordersStream,
              builder: (context, snapshot) {
                // Show loading indicator
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Handle errors
                if (snapshot.hasError) {
                  print('❌ OrdersScreen Snapshot Error: ${snapshot.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: errorColor),
                        const SizedBox(height: defaultPadding),
                        Text(
                          'Terjadi kesalahan',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        Text(
                          '${snapshot.error}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: defaultPadding),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Kembali'),
                        ),
                      ],
                    ),
                  );
                }

                // Get documents safely
                final docs = snapshot.data?.docs ?? <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                
                print('📦 OrdersScreen: Found ${docs.length} orders');
                
                // Sort by createdAt descending manually if orderBy doesn't work
                if (docs.isNotEmpty) {
                  try {
                    docs.sort((a, b) {
                      final aTime = a.data()['createdAt'] as Timestamp?;
                      final bTime = b.data()['createdAt'] as Timestamp?;
                      if (aTime == null && bTime == null) return 0;
                      if (aTime == null) return 1;
                      if (bTime == null) return -1;
                      return bTime.compareTo(aTime);
                    });
                  } catch (e) {
                    print('⚠️ OrdersScreen: Error sorting orders: $e');
                  }
                }

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: defaultPadding),
                        Text(
                          'Belum ada pesanan',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        Text(
                          'Pesanan Anda akan muncul di sini',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(defaultPadding),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final items = data['items'] as List<dynamic>? ?? [];
                    final total = (data['total'] ?? 0).toInt();
                    final status = (data['status'] ?? 'pending').toString();
                    final createdAt = data['createdAt'] as Timestamp?;

                    return Container(
                      margin: const EdgeInsets.only(bottom: defaultPadding),
                      padding: const EdgeInsets.all(defaultPadding),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(defaultBorderRadious),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pesanan #${doc.id.substring(0, 8).toUpperCase()}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: getStatusColor(status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: getStatusColor(status),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  getStatusText(status),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: getStatusColor(status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (createdAt != null) ...[
                            const SizedBox(height: defaultPadding / 2),
                            Text(
                              'Tanggal: ${createdAt.toDate().toString().substring(0, 16)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                          const SizedBox(height: defaultPadding),
                          ...items.map((item) {
                            final itemData = item as Map<String, dynamic>;
                            // Ambil nama dari berbagai field yang mungkin
                            final itemName = (itemData['name'] ?? 
                                            itemData['title'] ?? 
                                            itemData['productName'] ?? 
                                            'Produk').toString();
                            final itemQty = (itemData['quantity'] ?? 0).toInt();
                            final itemPrice = (itemData['price'] ?? 0).toInt();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: defaultPadding / 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '$itemName x$itemQty',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                  Text(
                                    formatRp(itemPrice * itemQty),
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          // Shipping Address
                          if (data['shippingAddress'] != null) ...[
                            const SizedBox(height: defaultPadding / 2),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _formatShippingAddress(data['shippingAddress'] as Map<String, dynamic>?),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (data['paymentMethodName'] != null) ...[
                            const SizedBox(height: defaultPadding / 2),
                            Row(
                              children: [
                                const Icon(Icons.payment, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  'Pembayaran: ${data['paymentMethodName']}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    formatRp(total),
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _showOrderDetails(context, doc.id, data);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(defaultBorderRadious),
                                  ),
                                ),
                                child: const Text('Detail'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          } catch (e, stackTrace) {
            // Handle error if user not logged in or other errors
            print('❌ OrdersScreen Error: $e');
            print('❌ StackTrace: $stackTrace');
            
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: errorColor),
                    const SizedBox(height: defaultPadding),
                    Text(
                      'Terjadi kesalahan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    Text(
                      e.toString().contains('User belum login') 
                          ? 'Silakan login terlebih dahulu'
                          : 'Error: ${e.toString()}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: defaultPadding),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Kembali'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _showOrderDetails(BuildContext context, String orderId, Map<String, dynamic> orderData) {
    final items = orderData['items'] as List<dynamic>? ?? [];
    final total = (orderData['total'] ?? 0).toInt();
    final status = (orderData['status'] ?? 'pending').toString();
    final createdAt = orderData['createdAt'] as Timestamp?;
    final paymentMethod = orderData['paymentMethodName'] ?? 'Tidak diketahui';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: defaultPadding),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Detail Pesanan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: defaultPadding),
              Container(
                padding: const EdgeInsets.all(defaultPadding),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ID Pesanan',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '#${orderId.substring(0, 8).toUpperCase()}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: getStatusColor(status),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            getStatusText(status),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: getStatusColor(status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (createdAt != null) ...[
                      const SizedBox(height: defaultPadding / 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tanggal',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            createdAt.toDate().toString().substring(0, 16),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: defaultPadding / 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Metode Pembayaran',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          paymentMethod,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: defaultPadding),
              Text(
                'Item Pesanan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: defaultPadding / 2),
              ...items.map((item) {
                final itemData = item as Map<String, dynamic>;
                // Ambil nama dari berbagai field yang mungkin
                final itemName = (itemData['name'] ?? 
                                itemData['title'] ?? 
                                itemData['productName'] ?? 
                                'Produk').toString();
                final itemQty = (itemData['quantity'] ?? 0).toInt();
                final itemPrice = (itemData['price'] ?? 0).toInt();
                final itemImage = itemData['imageUrl'] ?? '';
                final itemTotal = itemPrice * itemQty;

                return Container(
                  margin: const EdgeInsets.only(bottom: defaultPadding / 2),
                  padding: const EdgeInsets.all(defaultPadding / 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(defaultBorderRadious),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      if (itemImage.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(defaultBorderRadious / 2),
                          child: NetworkImageWithLoader(
                            itemImage,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            radius: defaultBorderRadious / 2,
                          ),
                        )
                      else
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(defaultBorderRadious / 2),
                          ),
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      const SizedBox(width: defaultPadding / 2),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              itemName,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${itemQty}x ${formatRp(itemPrice)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        formatRp(itemTotal),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: defaultPadding),
              Container(
                padding: const EdgeInsets.all(defaultPadding),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pesanan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formatRp(total),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Shipping Address
              if (orderData['shippingAddress'] != null) ...[
                const SizedBox(height: defaultPadding),
                Text(
                  'Alamat Pengiriman',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: defaultPadding / 2),
                Container(
                  padding: const EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(defaultBorderRadious),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderData['shippingAddress']['name'] ?? 'Penerima',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (orderData['shippingAddress']['phone'] != null && 
                          orderData['shippingAddress']['phone'].toString().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          orderData['shippingAddress']['phone'],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        '${orderData['shippingAddress']['address'] ?? ''}, ${orderData['shippingAddress']['city'] ?? ''}, ${orderData['shippingAddress']['postalCode'] ?? ''}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: defaultPadding),
            ],
          ),
        ),
      ),
    );
  }

  String _formatShippingAddress(Map<String, dynamic>? address) {
    if (address == null) return '';
    final name = address['name'] ?? 'Penerima';
    final city = address['city'] ?? '';
    final addressLine = address['address'] ?? '';
    if (city.isNotEmpty && addressLine.isNotEmpty) {
      return '$name - $city';
    } else if (city.isNotEmpty) {
      return '$name - $city';
    } else if (addressLine.isNotEmpty) {
      return '$name - $addressLine';
    }
    return name;
  }
}
