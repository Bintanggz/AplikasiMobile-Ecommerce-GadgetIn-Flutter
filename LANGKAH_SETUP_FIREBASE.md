# 📋 Langkah-Langkah Setup Firebase untuk Admin Panel

Berdasarkan screenshot Firebase Console Anda, ikuti langkah-langkah berikut:

---

## 🔧 STEP 1: Set User sebagai Admin

### Cara 1: Via Firebase Console (Manual)

1. **Di Firebase Console yang sedang Anda buka:**
   - Pastikan Anda sudah di document user: `tmDF6anfkpZ0bKmmqMb0PSNmwpN2`
   - Klik tombol **"+ Add field"** di bagian bawah fields yang ada

2. **Tambahkan field pertama:**
   - **Field name:** `role`
   - **Field type:** pilih **string**
   - **Field value:** ketik `admin`
   - Klik **Save**

3. **Tambahkan field kedua:**
   - Klik **"+ Add field"** lagi
   - **Field name:** `isAdmin`
   - **Field type:** pilih **boolean**
   - **Field value:** centang checkbox (true)
   - Klik **Save**

4. **Tambahkan field ketiga (opsional, untuk keamanan):**
   - Klik **"+ Add field"** lagi
   - **Field name:** `isBanned`
   - **Field type:** pilih **boolean**
   - **Field value:** biarkan tidak tercentang (false)
   - Klik **Save**

5. **Hasil akhir document user Anda harus seperti ini:**
   ```
   email: "user1@gmail.com"
   name: "Hafizh"
   phone: ""
   role: "admin"
   isAdmin: true
   isBanned: false
   updatedAt: [timestamp]
   ```

### Cara 2: Via Kode (Jika sudah ada admin lain)

Jika sudah ada admin lain, bisa set via Admin Panel di aplikasi:
1. Login sebagai admin yang sudah ada
2. Buka Profile > Admin Dashboard
3. Manage Users > Pilih user > Set as Admin

---

## 🔒 STEP 2: Update Firestore Security Rules

1. **Di Firebase Console:**
   - Klik **"Firestore Database"** di menu kiri (yang sedang Anda buka)
   - Klik tab **"Rules"** di bagian atas (di sebelah "Data", "Indexes", "Usage")

2. **Copy-paste rules berikut:**

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

3. **Klik tombol "Publish"** di bagian atas editor rules
4. **Tunggu beberapa detik** hingga rules terupdate (akan muncul notifikasi "Rules published successfully")

---

## ✅ STEP 3: Verifikasi Setup

### 3.1 Verifikasi User Document

1. **Refresh halaman Firebase Console**
2. **Buka collection `users`** > document user Anda
3. **Pastikan fields berikut ada:**
   - ✅ `role: "admin"`
   - ✅ `isAdmin: true`
   - ✅ `isBanned: false` (opsional)

### 3.2 Verifikasi Security Rules

1. **Di tab Rules**, pastikan rules sudah terpublish
2. **Klik "Rules playground"** (opsional) untuk test rules
3. **Atau langsung test di aplikasi**

---

## 🚀 STEP 4: Test di Aplikasi

1. **Install dependencies (jika belum):**
   ```bash
   flutter pub get
   ```

2. **Run aplikasi:**
   ```bash
   flutter run
   ```

3. **Login dengan akun admin:**
   - Email: `user1@gmail.com`
   - Password: (password yang Anda gunakan saat register)

4. **Akses Admin Panel:**
   - Buka menu **Profile** (icon profil di bottom navigation)
   - Scroll ke bawah
   - Akan muncul section **"Admin"** dengan menu **"Admin Dashboard"**
   - Klik **"Admin Dashboard"**

5. **Test fitur admin:**
   - ✅ Dashboard menampilkan statistik
   - ✅ Manage Users bisa akses dan edit users
   - ✅ Manage Orders bisa akses dan update status orders

---

## 🔍 STEP 5: Troubleshooting

### Problem: Menu Admin tidak muncul di Profile

**Solusi:**
1. Pastikan user document sudah memiliki field `role: "admin"` dan `isAdmin: true`
2. Logout dan login lagi
3. Restart aplikasi
4. Check console untuk error

### Problem: "Permission denied" saat akses admin panel

**Solusi:**
1. Pastikan Security Rules sudah di-publish
2. Pastikan field `role` di user document = `"admin"` (bukan `admin` tanpa quotes)
3. Check apakah user sudah login dengan benar
4. Restart aplikasi

### Problem: Tidak bisa update order status

**Solusi:**
1. Pastikan Security Rules sudah benar (khususnya bagian `orders`)
2. Pastikan user sudah di-set sebagai admin
3. Check error di console

### Problem: Payment gateway error

**Solusi:**
1. Pastikan API keys Midtrans sudah benar di `payment_service.dart`
2. Pastikan menggunakan sandbox keys untuk testing
3. Check network connection
4. Check error message di console

---

## 📝 Checklist Final

Sebelum lanjut ke production, pastikan:

- [ ] User sudah di-set sebagai admin (field `role` dan `isAdmin`)
- [ ] Firestore Security Rules sudah di-update dan di-publish
- [ ] Admin Panel bisa diakses dari aplikasi
- [ ] Dashboard menampilkan statistik dengan benar
- [ ] Manage Users berfungsi (view, edit, ban/unban)
- [ ] Manage Orders berfungsi (view, filter, update status)
- [ ] Payment gateway sudah dikonfigurasi dengan benar
- [ ] Test semua fitur admin

---

## 🎯 Next Steps

Setelah setup selesai:

1. **Test semua fitur admin** secara menyeluruh
2. **Set user lain sebagai admin** jika diperlukan
3. **Setup webhook Midtrans** untuk handle payment notification (opsional)
4. **Monitor error logs** di Firebase Console
5. **Backup data** secara berkala

---

## 📞 Need Help?

Jika masih ada masalah:
1. Check error logs di Firebase Console > Firestore > Usage
2. Check error di Flutter console
3. Verify semua field di user document sudah benar
4. Pastikan Security Rules sudah di-publish

---

**Selamat! Setup admin panel Anda sudah selesai! 🎉**

