import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/screen_export.dart';
import 'package:shop/services/cart_service.dart';
import 'package:shop/services/payment_service.dart';
import 'package:uuid/uuid.dart';
import 'package:shop/screens/payment/views/payment_webview_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> items;
  final int total;

  const CheckoutScreen({
    super.key,
    required this.items,
    required this.total,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CartService _cartService = CartService();
  final PaymentService _paymentService = PaymentService();
  String _selectedPaymentMethod = 'cod';
  bool _isProcessing = false;
  Map<String, dynamic>? _shippingAddress;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'cod',
      'name': 'Cash on Delivery (COD)',
      'description': 'Bayar saat barang diterima',
      'icon': Icons.money,
      'color': Colors.green,
    },
    {
      'id': 'bank_transfer',
      'name': 'Bank Transfer',
      'description': 'Transfer ke rekening bank',
      'icon': Icons.account_balance,
      'color': Colors.blue,
    },
    {
      'id': 'ewallet',
      'name': 'E-Wallet',
      'description': 'GoPay, OVO, DANA, LinkAja',
      'icon': Icons.wallet,
      'color': Colors.purple,
    },
  ];

  String formatRp(dynamic value) {
    return formatCurrency(value is int ? value.toDouble() : (value as num).toDouble());
  }

  @override
  void initState() {
    super.initState();
    _loadShippingAddress();
  }

  Future<void> _loadShippingAddress() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final addressesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .where('isDefault', isEqualTo: true)
          .limit(1);
      
      final addressSnapshot = await addressesRef.get();
      if (addressSnapshot.docs.isNotEmpty) {
        setState(() {
          _shippingAddress = addressSnapshot.docs.first.data();
        });
      } else {
        // Fallback to first address or default
        final allAddresses = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('addresses')
            .limit(1)
            .get();
        
        if (allAddresses.docs.isNotEmpty) {
          setState(() {
            _shippingAddress = allAddresses.docs.first.data();
          });
        } else {
          // Default address
          setState(() {
            _shippingAddress = {
              'name': 'Penerima',
              'phone': '',
              'address': 'Jl. Laweyan',
              'city': 'Surakarta',
              'postalCode': '57141',
            };
          });
        }
      }
    } catch (e) {
      // Use default address if error
      setState(() {
        _shippingAddress = {
          'name': 'Penerima',
          'phone': '',
          'address': 'Jl. Laweyan',
          'city': 'Surakarta',
          'postalCode': '57141',
        };
      });
    }
  }

  Future<void> _processOrder() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final orders = FirebaseFirestore.instance.collection('orders');

      // Calculate total from items to ensure accuracy
      num calculatedTotal = 0;
      final list = <Map<String, dynamic>>[];
      
      for (var doc in widget.items) {
        final data = doc.data() as Map<String, dynamic>;
        final priceNum = (data['price'] ?? 0) as num;
        final quantityNum = (data['quantity'] ?? 0) as num;
        final price = priceNum.toInt();
        final quantity = quantityNum.toInt();
        calculatedTotal += price * quantity;
        
        // Ensure name is stored correctly (support multiple field names)
        final name = (data['name'] ?? 
                     data['title'] ?? 
                     data['productName'] ?? 
                     'Produk').toString();
        
        list.add({
          'productId': data['productId'],
          'name': name,
          'price': price,
          'quantity': quantity,
          'imageUrl': data['imageUrl'] ?? '',
        });
      }

      // Use the loaded shipping address or get default
      Map<String, dynamic> shippingAddress = _shippingAddress ?? {
        'name': 'Penerima',
        'phone': '',
        'address': 'Jl. Laweyan',
        'city': 'Surakarta',
        'postalCode': '57141',
      };

      // Use calculated total instead of widget.total to ensure accuracy
      final finalTotal = calculatedTotal > 0 ? calculatedTotal.toInt() : widget.total;
      
      // Get payment method name for consistency
      final paymentMethodName = _paymentMethods.firstWhere((p) => p['id'] == _selectedPaymentMethod)['name'] as String;
      
      // Generate order ID
      final orderId = const Uuid().v4();
      
      // Handle payment based on method
      String orderStatus = 'pending';
      String paymentStatus = 'pending';
      
      if (_selectedPaymentMethod == 'cod') {
        // COD - langsung buat order
        orderStatus = 'pending';
        paymentStatus = 'pending';
      } else {
        // Online payment - perlu generate payment token
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('User not authenticated');
        }
        
        // Prepare customer details
        final customerDetails = {
          'first_name': shippingAddress['name']?.split(' ').first ?? 'Customer',
          'last_name': shippingAddress['name']?.split(' ').length > 1 
              ? shippingAddress['name']?.split(' ').skip(1).join(' ') ?? ''
              : '',
          'email': user.email ?? '',
          'phone': shippingAddress['phone'] ?? '',
        };
        
        // Prepare item details for Midtrans
        final itemDetails = list.map((item) {
          return {
            'id': item['productId'] ?? '',
            'price': item['price'] ?? 0,
            'quantity': item['quantity'] ?? 1,
            'name': item['name'] ?? 'Product',
          };
        }).toList();
        
        // Map payment method to Midtrans payment type
        String? paymentType;
        if (_selectedPaymentMethod == 'bank_transfer') {
          paymentType = 'bank_transfer';
        } else if (_selectedPaymentMethod == 'ewallet') {
          paymentType = 'gopay'; // Default to GoPay, bisa diubah
        }
        
        // Create payment
        final paymentResult = await _paymentService.createPayment(
          orderId: orderId,
          grossAmount: finalTotal,
          customerDetails: customerDetails,
          itemDetails: itemDetails,
          paymentType: paymentType,
        );
        
        if (!paymentResult['success']) {
          throw Exception(paymentResult['error'] ?? 'Payment creation failed');
        }
        
        final paymentToken = paymentResult['token'] as String;
        
        // Save payment info
        await _paymentService.savePaymentInfo(
          orderId: orderId,
          paymentMethod: _selectedPaymentMethod,
          paymentToken: paymentToken,
          amount: finalTotal,
          status: 'pending',
        );
        
        orderStatus = 'waiting_payment';
        paymentStatus = 'pending';
        
        // Open Midtrans payment page
        if (mounted) {
          final paymentPageResult = await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentWebViewScreen(
                paymentToken: paymentToken,
                orderId: orderId,
                clientKey: PaymentService.clientKey,
              ),
            ),
          );

          // Handle payment result
          if (paymentPageResult != null) {
            final status = paymentPageResult['status'] as String;
            
            if (status == 'success') {
              // Payment successful - update order status
              await _paymentService.updatePaymentStatus(
                orderId: orderId,
                status: 'settlement',
              );
              orderStatus = 'processing';
              paymentStatus = 'settlement';
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pembayaran berhasil!'),
                    backgroundColor: successColor,
                  ),
                );
              }
            } else if (status == 'pending') {
              // Payment pending - update order status
              await _paymentService.updatePaymentStatus(
                orderId: orderId,
                status: 'pending',
              );
              orderStatus = 'waiting_payment';
              paymentStatus = 'pending';
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pembayaran menunggu konfirmasi.'),
                    backgroundColor: warningColor,
                  ),
                );
              }
            } else if (status == 'error') {
              // Payment error
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pembayaran gagal. Silakan coba lagi.'),
                    backgroundColor: errorColor,
                  ),
                );
              }
            } else if (status == 'cancelled') {
              // Payment cancelled - order tetap dibuat dengan status waiting_payment
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pembayaran dibatalkan. Anda bisa membayar nanti dari halaman pesanan.'),
                    backgroundColor: warningColor,
                    duration: Duration(seconds: 4),
                  ),
                );
              }
            }
          }
        }
      }
      
      // Create order
      await orders.add({
        'orderId': orderId,
        'userId': _cartService.currentUserId,
        'total': finalTotal,
        'items': list,
        'paymentMethod': _selectedPaymentMethod,
        'paymentMethodName': paymentMethodName,
        'paymentStatus': paymentStatus,
        'shippingAddress': shippingAddress,
        'status': orderStatus,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _cartService.clearCart();

      if (!mounted) return;

      // Navigate to success screen with the same total and payment method
      Navigator.pushReplacementNamed(
        context,
        thanksForOrderScreenRoute,
        arguments: {
          'orderTotal': finalTotal,
          'paymentMethod': paymentMethodName,
          'orderId': orderId,
        },
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memproses pesanan: ${e.toString()}'),
          backgroundColor: errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary
                  Text(
                    'Ringkasan Pesanan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                  ...widget.items.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final qty = (data['quantity'] ?? 0).toInt();
                    final price = (data['price'] ?? 0).toInt();
                    final itemTotal = qty * price;
                    final imageUrl = (data['imageUrl'] ?? productDemoImg1).toString();
                    // Ensure name is displayed correctly (support multiple field names)
                    final name = (data['name'] ?? 
                                 data['title'] ?? 
                                 data['productName'] ?? 
                                 'Produk').toString();

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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(defaultBorderRadious / 2),
                            child: NetworkImageWithLoader(
                              imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              radius: defaultBorderRadious / 2,
                            ),
                          ),
                          const SizedBox(width: defaultPadding / 2),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${qty}x ${formatRp(price)}',
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
                  }),
                  const SizedBox(height: defaultPadding),
                  const Divider(),
                  const SizedBox(height: defaultPadding),
                  
                  // Shipping Address
                  Text(
                    'Alamat Pengiriman',
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
                    child: _shippingAddress == null
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: primaryColor, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _shippingAddress!['name'] ?? 'Penerima',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, addressesScreenRoute).then((_) {
                                        _loadShippingAddress();
                                      });
                                    },
                                    child: const Text('Ubah'),
                                  ),
                                ],
                              ),
                              if (_shippingAddress!['phone'] != null && _shippingAddress!['phone'].toString().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _shippingAddress!['phone'] ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                '${_shippingAddress!['address'] ?? ''}, ${_shippingAddress!['city'] ?? ''}, ${_shippingAddress!['postalCode'] ?? ''}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: defaultPadding),
                  const Divider(),
                  const SizedBox(height: defaultPadding),
                  
                  // Payment Method
                  Text(
                    'Metode Pembayaran',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                  ..._paymentMethods.map((method) {
                    final isSelected = _selectedPaymentMethod == method['id'];
                    return Container(
                      margin: const EdgeInsets.only(bottom: defaultPadding / 2),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedPaymentMethod = method['id'] as String;
                          });
                        },
                        borderRadius: BorderRadius.circular(defaultBorderRadious),
                        child: Container(
                          padding: const EdgeInsets.all(defaultPadding),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(defaultBorderRadious),
                            border: Border.all(
                              color: isSelected ? primaryColor : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (method['color'] as Color).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  method['icon'] as IconData,
                                  color: method['color'] as Color,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: defaultPadding),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      method['name'] as String,
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      method['description'] as String,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: primaryColor,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: defaultPadding),
                ],
              ),
            ),
          ),
          // Total and Checkout Button
          Container(
            padding: const EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                  Builder(
                    builder: (context) {
                      // Calculate total from items for display accuracy
                      num displayTotal = 0;
                      for (var doc in widget.items) {
                        final data = doc.data() as Map<String, dynamic>;
                        final qtyNum = (data['quantity'] ?? 0) as num;
                        final priceNum = (data['price'] ?? 0) as num;
                        final qty = qtyNum.toInt();
                        final price = priceNum.toInt();
                        displayTotal += qty * price;
                      }
                      final finalDisplayTotal = displayTotal > 0 ? displayTotal.toInt() : widget.total;
                      
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            formatRp(finalDisplayTotal),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                const SizedBox(height: defaultPadding),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(defaultBorderRadious),
                      ),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Buat Pesanan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

