import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get currentUserId {
    final u = _auth.currentUser;
    if (u == null) throw Exception('User belum login');
    return u.uid;
  }

  CollectionReference<Map<String, dynamic>> get _cartRef => _db
      .collection('carts')
      .doc(currentUserId)
      .collection('items')
      .withConverter<Map<String, dynamic>>(
    fromFirestore: (snap, _) => snap.data()!,
    toFirestore: (map, _) => map,
  );

  Stream<QuerySnapshot<Map<String, dynamic>>> getCartItems() {
    return _cartRef.snapshots().map((snap) => snap as QuerySnapshot<Map<String, dynamic>>);
  }

  Future<void> addToCart({
    required String productId,
    required String name,
    required int price,
    required String imageUrl,
    int quantity = 1,
  }) async {
    // Validasi input
    if (productId.isEmpty) {
      throw Exception('ID produk tidak boleh kosong');
    }
    if (name.isEmpty) {
      throw Exception('Nama produk tidak boleh kosong');
    }
    if (price <= 0) {
      throw Exception('Harga produk tidak valid');
    }
    if (quantity <= 0) {
      throw Exception('Jumlah produk harus lebih dari 0');
    }

    try {
      final docRef = _cartRef.doc(productId);
      final doc = await docRef.get();

      if (doc.exists && doc.data() != null) {
        final currentQty = (doc.data()!['quantity'] ?? 1) as int;
        await docRef.update({'quantity': currentQty + quantity});
      } else {
        await docRef.set({
          'productId': productId,
          'name': name,
          'price': price,
          'imageUrl': imageUrl,
          'quantity': quantity,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Re-throw dengan pesan yang lebih jelas
      if (e.toString().contains('permission') || e.toString().contains('PERMISSION_DENIED')) {
        throw Exception('Tidak memiliki izin untuk menambah ke keranjang');
      } else if (e.toString().contains('network') || e.toString().contains('NETWORK')) {
        throw Exception('Masalah koneksi internet. Coba lagi nanti.');
      } else {
        throw Exception('Gagal menambah ke keranjang: ${e.toString()}');
      }
    }
  }

  Future<void> updateQuantity(String docId, int qty) async {
    await _cartRef.doc(docId).update({'quantity': qty});
  }

  Future<void> removeItem(String docId) async {
    await _cartRef.doc(docId).delete();
  }

  Future<void> clearCart() async {
    final snap = await _cartRef.get();
    for (var d in snap.docs) {
      await d.reference.delete();
    }
  }
}
