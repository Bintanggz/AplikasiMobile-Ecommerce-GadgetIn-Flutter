import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class PaymentService {
  // TODO: Ganti dengan Server Key dan Client Key dari Midtrans Dashboard
  // Untuk production, simpan di environment variables atau backend server
  // static const String _serverKey = 'YOUR_MIDTRANS_SERVER_KEY';
  // static const String _clientKey = 'YOUR_MIDTRANS_CLIENT_KEY';
  static final String _serverKey = dotenv.get('MIDTRANS_SERVER_KEY');
  static final String _clientKey = dotenv.get('MIDTRANS_CLIENT_KEY');
  static const String _baseUrl = 'https://app.sandbox.midtrans.com'; // Sandbox
  // static const String _baseUrl = 'https://app.midtrans.com'; // Production

  // Getter untuk client key (dibutuhkan untuk payment webview)
  static String get clientKey => _clientKey;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Generate payment token dari Midtrans
  /// Untuk production, pindahkan logic ini ke backend server untuk keamanan
  Future<Map<String, dynamic>> createPayment({
    required String orderId,
    required int grossAmount,
    required Map<String, dynamic> customerDetails,
    required List<Map<String, dynamic>> itemDetails,
    String? paymentType, // 'bank_transfer', 'gopay', 'shopeepay', dll
  }) async {
    try {
      // Generate order ID jika belum ada
      final finalOrderId = orderId.isEmpty ? const Uuid().v4() : orderId;

      // Prepare request body
      final requestBody = {
        'transaction_details': {
          'order_id': finalOrderId,
          'gross_amount': grossAmount,
        },
        'customer_details': customerDetails,
        'item_details': itemDetails,
        if (paymentType != null) 'payment_type': paymentType,
      };

      // Untuk production, panggil backend API Anda yang akan memanggil Midtrans
      // Ini adalah contoh langsung ke Midtrans (tidak disarankan untuk production)
      final response = await http.post(
        Uri.parse('$_baseUrl/snap/v1/transactions'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_serverKey:'))}',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'token': data['token'],
          'orderId': finalOrderId,
        };
      } else {
        return {
          'success': false,
          'error': jsonDecode(response.body)['error_messages']?.first ?? 'Payment failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Simpan payment info ke Firestore
  Future<void> savePaymentInfo({
    required String orderId,
    required String paymentMethod,
    required String paymentToken,
    required int amount,
    String status = 'pending',
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _db.collection('payments').doc(orderId).set({
        'orderId': orderId,
        'userId': user.uid,
        'paymentMethod': paymentMethod,
        'paymentToken': paymentToken,
        'amount': amount,
        'status': status, // pending, paid, failed, expired
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving payment info: $e');
      rethrow;
    }
  }

  /// Update payment status (dipanggil dari webhook atau manual)
  Future<void> updatePaymentStatus({
    required String orderId,
    required String status,
    Map<String, dynamic>? paymentData,
  }) async {
    try {
      final paymentRef = _db.collection('payments').doc(orderId);
      await paymentRef.update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        if (paymentData != null) ...paymentData,
      });

      // Update order status juga
      final orders = await _db
          .collection('orders')
          .where('orderId', isEqualTo: orderId)
          .limit(1)
          .get();

      if (orders.docs.isNotEmpty) {
        String orderStatus = 'pending';
        if (status == 'paid' || status == 'settlement') {
          orderStatus = 'processing';
        } else if (status == 'expire' || status == 'cancel') {
          orderStatus = 'cancelled';
        }

        await orders.docs.first.reference.update({
          'status': orderStatus,
          'paymentStatus': status,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating payment status: $e');
      rethrow;
    }
  }

  /// Get payment info
  Future<Map<String, dynamic>?> getPaymentInfo(String orderId) async {
    try {
      final doc = await _db.collection('payments').doc(orderId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting payment info: $e');
      return null;
    }
  }

  /// Check payment status dari Midtrans
  /// Untuk production, panggil dari backend
  Future<Map<String, dynamic>> checkPaymentStatus(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v2/$orderId/status'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_serverKey:'))}',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Failed to check payment status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}

