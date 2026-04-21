# Firestore Security Rules untuk Admin Panel

## 🔒 Security Rules Lengkap

Copy dan paste rules berikut ke Firebase Console > Firestore Database > Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function untuk check admin
    function isAdmin() {
      return request.auth != null && 
             exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Helper function untuk check user sendiri
    function isOwner(userId) {
      return request.auth != null && request.auth.uid == userId;
    }
    
    // Collection product - read untuk semua, write untuk admin
    match /product/{productId} {
      allow read: if true; // Semua bisa baca produk
      allow create: if isAdmin(); // Hanya admin bisa create
      allow update: if isAdmin(); // Hanya admin bisa update
      allow delete: if isAdmin(); // Hanya admin bisa delete
    }
    
    // Collection users
    match /users/{userId} {
      // Semua user yang login bisa baca data user lain (untuk display name, dll)
      allow read: if request.auth != null;
      
      // User bisa create data sendiri saat register
      allow create: if request.auth != null && 
                       request.auth.uid == userId &&
                       request.resource.data.keys().hasAll(['name', 'email', 'role']) &&
                       request.resource.data.role == 'user'; // Default role harus 'user'
      
      // User bisa update data sendiri, atau admin bisa update semua
      allow update: if request.auth != null && 
                       (isOwner(userId) || isAdmin());
      
      // Hanya admin bisa delete user
      allow delete: if isAdmin();
    }
    
    // Collection carts - hanya untuk user yang login
    match /carts/{userId}/items/{itemId} {
      allow read, write: if request.auth != null && 
                            request.auth.uid == userId;
    }
    
    // Collection orders
    match /orders/{orderId} {
      // User bisa baca order sendiri, admin bisa baca semua
      allow read: if request.auth != null && 
                     (resource.data.userId == request.auth.uid || isAdmin());
      
      // User bisa create order sendiri
      allow create: if request.auth != null && 
                       request.resource.data.userId == request.auth.uid;
      
      // Hanya admin bisa update order (untuk update status)
      allow update: if isAdmin();
      
      // Hanya admin bisa delete order
      allow delete: if isAdmin();
    }
    
    // Collection payments
    match /payments/{paymentId} {
      // User bisa baca payment sendiri, admin bisa baca semua
      allow read: if request.auth != null && 
                     (resource.data.userId == request.auth.uid || isAdmin());
      
      // User bisa create payment sendiri
      allow create: if request.auth != null && 
                       request.resource.data.userId == request.auth.uid;
      
      // Hanya admin bisa update payment (untuk update status dari webhook)
      allow update: if isAdmin();
      
      // Hanya admin bisa delete payment
      allow delete: if isAdmin();
    }
    
    // Collection addresses - hanya untuk user sendiri
    match /users/{userId}/addresses/{addressId} {
      allow read, write: if request.auth != null && 
                            request.auth.uid == userId;
    }
  }
}
```

## 📝 Penjelasan Rules

### 1. Helper Functions

- `isAdmin()`: Check apakah user yang login adalah admin
- `isOwner(userId)`: Check apakah user yang login adalah pemilik data

### 2. Collection `product`

- **Read**: Semua bisa baca (termasuk user yang belum login)
- **Write**: Hanya admin

### 3. Collection `users`

- **Read**: Semua user yang login bisa baca
- **Create**: User bisa create data sendiri saat register (dengan role default 'user')
- **Update**: User bisa update data sendiri, atau admin bisa update semua
- **Delete**: Hanya admin

### 4. Collection `carts`

- **Read/Write**: Hanya user pemilik cart

### 5. Collection `orders`

- **Read**: User bisa baca order sendiri, admin bisa baca semua
- **Create**: User bisa create order sendiri
- **Update**: Hanya admin (untuk update status)
- **Delete**: Hanya admin

### 6. Collection `payments`

- **Read**: User bisa baca payment sendiri, admin bisa baca semua
- **Create**: User bisa create payment sendiri
- **Update**: Hanya admin (untuk update dari webhook)
- **Delete**: Hanya admin

### 7. Collection `addresses` (subcollection)

- **Read/Write**: Hanya user pemilik address

## 🚀 Cara Update Rules

1. Buka Firebase Console: https://console.firebase.google.com/
2. Pilih project Anda
3. Buka **Firestore Database** di menu kiri
4. Klik tab **Rules** di bagian atas
5. Copy-paste rules di atas
6. Klik **Publish** di bagian atas
7. Tunggu beberapa detik hingga rules terupdate

## ⚠️ Testing Rules

Setelah update rules, test dengan:

1. **Test User Access:**
   - Login sebagai user biasa
   - Coba create/update/delete product → Harus ditolak
   - Coba update order status → Harus ditolak
   - Coba akses cart user lain → Harus ditolak

2. **Test Admin Access:**
   - Login sebagai admin
   - Coba create/update/delete product → Harus berhasil
   - Coba update order status → Harus berhasil
   - Coba akses semua data → Harus berhasil

3. **Test Unauthenticated:**
   - Logout
   - Coba baca product → Harus berhasil (public read)
   - Coba create order → Harus ditolak

## 🔍 Troubleshooting

### Error: "Missing or insufficient permissions"

1. Check apakah user sudah login
2. Check apakah user sudah di-set sebagai admin (jika perlu akses admin)
3. Check rules sudah di-publish
4. Check field `role` di user document sudah benar

### Error: "Permission denied"

1. Verify rules sudah benar
2. Check helper function `isAdmin()` - pastikan user document ada dan field `role` = 'admin'
3. Check apakah user mencoba akses data yang bukan miliknya

### Tips

- Gunakan Firebase Console > Firestore > Rules > Simulator untuk test rules
- Monitor error logs di Firebase Console
- Test rules secara bertahap (satu collection dulu)

