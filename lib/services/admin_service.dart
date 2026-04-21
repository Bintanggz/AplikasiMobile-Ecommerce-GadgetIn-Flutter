import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if current user is admin
  Future<bool> isAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _db.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return false;

      final userData = userDoc.data();
      return userData?['role'] == 'admin' || userData?['isAdmin'] == true;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  /// Set user as admin (hanya bisa dilakukan oleh admin lain atau manual di Firestore)
  Future<void> setUserAsAdmin(String userId) async {
    try {
      if (!await isAdmin()) {
        throw Exception('Only admin can set other users as admin');
      }

      await _db.collection('users').doc(userId).update({
        'role': 'admin',
        'isAdmin': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error setting user as admin: $e');
      rethrow;
    }
  }

  /// Get all users
  Stream<List<Map<String, dynamic>>> getAllUsers() {
    return _db.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'id': doc.id,
        };
      }).toList();
    });
  }

  /// Get user by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        return {...doc.data()!, 'id': doc.id};
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// Update user data
  Future<void> updateUser({
    required String userId,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (!await isAdmin()) {
        throw Exception('Only admin can update users');
      }

      await _db.collection('users').doc(userId).update({
        if (data != null) ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  /// Ban/Unban user
  Future<void> toggleUserBan(String userId, bool isBanned) async {
    try {
      if (!await isAdmin()) {
        throw Exception('Only admin can ban/unban users');
      }

      await _db.collection('users').doc(userId).update({
        'isBanned': isBanned,
        'bannedAt': isBanned ? FieldValue.serverTimestamp() : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Jika user diban, logout user tersebut (optional)
      if (isBanned) {
        // Note: Ini hanya update data, user masih bisa login sampai token expire
        // Untuk benar-benar logout, perlu implementasi di client side
      }
    } catch (e) {
      print('Error toggling user ban: $e');
      rethrow;
    }
  }

  /// Delete user (soft delete atau hard delete)
  Future<void> deleteUser(String userId, {bool hardDelete = false}) async {
    try {
      if (!await isAdmin()) {
        throw Exception('Only admin can delete users');
      }

      if (hardDelete) {
        // Hard delete - hapus dari Firestore
        await _db.collection('users').doc(userId).delete();
      } else {
        // Soft delete - mark as deleted
        await _db.collection('users').doc(userId).update({
          'isDeleted': true,
          'deletedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      if (!await isAdmin()) {
        throw Exception('Only admin can access dashboard stats');
      }

      // Get total users
      final usersSnapshot = await _db.collection('users').get();
      final totalUsers = usersSnapshot.docs.length;
      final activeUsers = usersSnapshot.docs
          .where((doc) => doc.data()['isBanned'] != true)
          .length;

      // Get total orders
      final ordersSnapshot = await _db.collection('orders').get();
      final totalOrders = ordersSnapshot.docs.length;
      final pendingOrders = ordersSnapshot.docs
          .where((doc) => doc.data()['status'] == 'pending')
          .length;
      final completedOrders = ordersSnapshot.docs
          .where((doc) => doc.data()['status'] == 'delivered')
          .length;

      // Calculate total revenue
      double totalRevenue = 0;
      for (var doc in ordersSnapshot.docs) {
        final data = doc.data();
        if (data['status'] == 'delivered' || data['status'] == 'processing') {
          final total = (data['total'] ?? 0).toDouble();
          totalRevenue += total;
        }
      }

      // Get total products
      final productsSnapshot = await _db.collection('product').get();
      final totalProducts = productsSnapshot.docs.length;

      return {
        'totalUsers': totalUsers,
        'activeUsers': activeUsers,
        'bannedUsers': totalUsers - activeUsers,
        'totalOrders': totalOrders,
        'pendingOrders': pendingOrders,
        'completedOrders': completedOrders,
        'totalRevenue': totalRevenue,
        'totalProducts': totalProducts,
      };
    } catch (e) {
      print('Error getting dashboard stats: $e');
      rethrow;
    }
  }

  /// Get recent orders
  Stream<List<Map<String, dynamic>>> getRecentOrders({int limit = 10}) {
    return _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'id': doc.id,
        };
      }).toList();
    });
  }

  /// Get all orders
  Stream<List<Map<String, dynamic>>> getAllOrders() {
    return _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'id': doc.id,
        };
      }).toList();
    });
  }

  /// Update order status
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      if (!await isAdmin()) {
        throw Exception('Only admin can update order status');
      }

      await _db.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating order status: $e');
      rethrow;
    }
  }
}

