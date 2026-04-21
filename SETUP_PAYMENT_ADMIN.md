# Setup Payment Gateway & Admin Panel

## 📋 Overview

Proyek ini sudah diintegrasikan dengan:

1. **Payment Gateway (Midtrans)** - untuk pembayaran online
2. **Admin Panel** - untuk manage users, orders, dan dashboard

---

## 🔧 Setup Payment Gateway (Midtrans)

### 1. Daftar Akun Midtrans

1. Kunjungi https://dashboard.midtrans.com/
2. Daftar akun baru atau login
3. Pilih **Sandbox** untuk testing atau **Production** untuk live

### 2. Dapatkan API Keys

1. Di dashboard Midtrans, buka **Settings** > **Access Keys**
2. Copy **Server Key** dan **Client Key**
3. Buka file `lib/services/payment_service.dart`
4. Ganti nilai berikut:

```dart
static const String _serverKey = 'YOUR_MIDTRANS_SERVER_KEY';
static const String _clientKey = 'YOUR_MIDTRANS_CLIENT_KEY';
```

### 3. Konfigurasi Environment

**Untuk Production:**

- Ganti `_baseUrl` dari sandbox ke production:

```dart
static const String _baseUrl = 'https://app.midtrans.com'; // Production
```

**⚠️ PENTING:**

- Jangan commit Server Key ke repository public
- Gunakan environment variables atau backend server untuk production
- Untuk production, pindahkan logic payment ke backend server untuk keamanan

### 4. Testing Payment

1. Gunakan kartu test dari Midtrans:

   - **Card Number:** 4811 1111 1111 1114
   - **CVV:** 123
   - **Expiry:** 12/25
   - **OTP:** 112233

2. Atau gunakan metode pembayaran lain yang tersedia di sandbox

---

## 👨‍💼 Setup Admin Panel

### 1. Set User sebagai Admin

Ada 2 cara untuk set user sebagai admin:

#### Cara 1: Manual di Firebase Console

1. Buka Firebase Console: https://console.firebase.google.com/
2. Pilih project Anda
3. Buka **Firestore Database**
4. Buka collection `users`
5. Pilih user yang ingin dijadikan admin
6. Edit document dan tambahkan field:
   ```json
   {
     "role": "admin",
     "isAdmin": true
   }
   ```

#### Cara 2: Via Admin Panel (jika sudah ada admin lain)

1. Login sebagai admin yang sudah ada
2. Buka **Admin Dashboard** dari menu Profile
3. Pilih **Manage Users**
4. Pilih user yang ingin dijadikan admin
5. Klik menu (3 dots) > **Set as Admin**

### 2. Akses Admin Panel

1. Login dengan akun admin
2. Buka menu **Profile** di bottom navigation
3. Scroll ke bawah, akan muncul section **Admin**
4. Klik **Admin Dashboard**

### 3. Fitur Admin Panel

#### Dashboard

- Statistik: Total Users, Active Users, Total Orders, Total Revenue, dll
- Quick Actions: Manage Users, Manage Orders, Manage Products, Analytics

#### Manage Users

- View semua users
- Edit user data
- Ban/Unban user
- Set user sebagai admin
- Delete user (soft delete)

#### Manage Orders

- View semua orders
- Filter by status (All, Pending, Processing, Shipped, Delivered)
- Update order status
- View order details (items, shipping address, payment method)

---

## 🔒 Firestore Security Rules

Update Firestore Security Rules untuk mengamankan admin access:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper function untuk check admin
    function isAdmin() {
      return request.auth != null &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Collection product - read untuk semua, write untuk admin
    match /product/{document=**} {
      allow read: if true;
      allow write: if isAdmin();
    }

    // Collection users - read untuk semua, write untuk user sendiri atau admin
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == userId;
      allow update: if request.auth != null &&
                       (request.auth.uid == userId || isAdmin());
      allow delete: if isAdmin();
    }

    // Collection carts - hanya untuk user yang login
    match /carts/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Collection orders - read untuk user sendiri atau admin, write untuk admin
    match /orders/{orderId} {
      allow read: if request.auth != null &&
                     (resource.data.userId == request.auth.uid || isAdmin());
      allow create: if request.auth != null;
      allow update: if isAdmin();
      allow delete: if isAdmin();
    }

    // Collection payments - read untuk user sendiri atau admin
    match /payments/{paymentId} {
      allow read: if request.auth != null &&
                     (resource.data.userId == request.auth.uid || isAdmin());
      allow create: if request.auth != null;
      allow update: if isAdmin();
    }
  }
}
```

**Cara Update Rules:**

1. Buka Firebase Console
2. Pilih project Anda
3. Buka **Firestore Database** > **Rules**
4. Paste rules di atas
5. Klik **Publish**

---

## 📦 Dependencies

Pastikan dependencies berikut sudah terinstall:

```yaml
dependencies:
  http: ^1.1.0
  uuid: ^4.2.1
  cloud_firestore: ^4.11.0
  firebase_auth: ^4.8.0
```

Install dependencies:

```bash
flutter pub get
```

---

## 🚀 Testing

### Test Payment Gateway

1. Tambahkan produk ke cart
2. Checkout
3. Pilih payment method selain COD (Bank Transfer atau E-Wallet)
4. Order akan dibuat dengan status `waiting_payment`
5. Payment info akan tersimpan di collection `payments`

### Test Admin Panel

1. Set user sebagai admin (lihat cara di atas)
2. Login dengan akun admin
3. Buka Profile > Admin Dashboard
4. Test semua fitur:
   - View dashboard statistics
   - Manage users (edit, ban, set admin, delete)
   - Manage orders (view, filter, update status)

---

## ⚠️ Catatan Penting

1. **Payment Gateway:**

   - Untuk production, pindahkan logic payment ke backend server
   - Jangan expose Server Key di client app
   - Implement webhook untuk handle payment notification dari Midtrans

2. **Admin Panel:**

   - Pastikan Firestore Security Rules sudah diupdate
   - Hanya user dengan role `admin` yang bisa akses admin panel
   - Backup data sebelum delete user

3. **Security:**
   - Review Firestore Security Rules secara berkala
   - Monitor admin activities
   - Implement audit log untuk admin actions (optional)

---

## 📞 Support

Jika ada masalah:

1. Check error logs di console
2. Verify API keys sudah benar
3. Check Firestore Security Rules
4. Pastikan user sudah di-set sebagai admin

---

## 🔄 Next Steps

1. **Implement Webhook** untuk handle payment notification dari Midtrans
2. **Add Payment History** di user profile
3. **Add Analytics** di admin dashboard
4. **Add Product Management** di admin panel
5. **Add Email Notifications** untuk order updates
