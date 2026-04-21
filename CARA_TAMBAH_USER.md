# 📝 Cara Menambahkan User Baru dengan Role "User"

Ada **3 cara** untuk menambahkan user baru dengan role "user":

---

## 🎯 **CARA 1: Register dari Aplikasi (Paling Mudah)**

### Langkah-langkah:

1. **Logout dari akun admin** (jika sedang login sebagai admin)
2. **Buka aplikasi** dan klik **"Sign up"** di halaman login
3. **Isi form registrasi:**
   - Nama Lengkap
   - Email (harus unik, belum terdaftar)
   - Password (minimal 6 karakter)
   - Confirm Password
   - Centang checkbox "I agree with Terms & Privacy"
4. **Klik "Continue"**
5. **User baru akan otomatis dibuat** dengan:
   - `role: "user"` ✅
   - `isAdmin: false` ✅
   - `isBanned: false` ✅

### Keuntungan:
- ✅ Otomatis set role sebagai "user"
- ✅ Tidak perlu akses Firebase Console
- ✅ User bisa langsung login setelah register

---

## 🎯 **CARA 2: Manual di Firebase Console**

### Langkah-langkah:

1. **Buka Firebase Console:**
   - Kunjungi: https://console.firebase.google.com/
   - Pilih project: **E-commerceApp**

2. **Buka Authentication:**
   - Klik **"Authentication"** di menu kiri
   - Klik tab **"Users"**

3. **Tambah User:**
   - Klik tombol **"Add user"** (atau ikon +)
   - Masukkan:
     - **Email:** contoh: `user2@gmail.com`
     - **Password:** minimal 6 karakter
   - Klik **"Add user"**

4. **Buat User Document di Firestore:**
   - Buka **"Firestore Database"** di menu kiri
   - Buka collection **"users"**
   - Klik **"Add document"**
   - **Document ID:** Copy **UID** dari user yang baru dibuat di Authentication
   - **Fields:**
     ```
     name: "User 2" (string)
     email: "user2@gmail.com" (string)
     role: "user" (string)
     isAdmin: false (boolean)
     isBanned: false (boolean)
     createdAt: [timestamp] (pilih timestamp, klik "Set")
     updatedAt: [timestamp] (pilih timestamp, klik "Set")
     ```
   - Klik **"Save"**

### Catatan:
- ⚠️ Pastikan Document ID sama dengan UID dari Authentication
- ⚠️ Harus buat user di Authentication dulu, baru buat document di Firestore

---

## 🎯 **CARA 3: Via Admin Panel (Jika Sudah Ada Admin)**

### Langkah-langkah:

1. **Login sebagai admin**
2. **Buka Admin Dashboard:**
   - Profile > Admin Dashboard
3. **Manage Users:**
   - Klik **"Manage Users"**
   - Klik tombol **"+"** atau **"Add User"** (jika ada)
   - Atau gunakan fitur register dari aplikasi (Cara 1)

### Catatan:
- ⚠️ Fitur "Add User" di Admin Panel belum tersedia (bisa ditambahkan nanti)
- Untuk sekarang, gunakan **Cara 1** atau **Cara 2**

---

## ✅ **Verifikasi User Baru**

Setelah menambahkan user, verifikasi di Firebase Console:

1. **Buka Firestore Database** > collection **"users"**
2. **Cari user baru** berdasarkan email
3. **Pastikan fields berikut ada:**
   ```
   ✅ name: "Nama User"
   ✅ email: "email@example.com"
   ✅ role: "user"  ← HARUS "user" (bukan "admin")
   ✅ isAdmin: false  ← HARUS false
   ✅ isBanned: false
   ✅ createdAt: [timestamp]
   ✅ updatedAt: [timestamp]
   ```

---

## 🔍 **Test Login User Baru**

1. **Logout dari aplikasi** (jika sedang login)
2. **Login dengan email dan password user baru**
3. **Seharusnya:**
   - ✅ Login berhasil
   - ✅ Redirect ke **Entry Point** (bukan Admin Dashboard)
   - ✅ Tidak ada menu "Admin" di Profile
   - ✅ Bisa belanja, checkout, dll

---

## 📋 **Perbedaan Role "admin" vs "user"**

| Fitur | Admin | User |
|-------|-------|------|
| Login redirect | Admin Dashboard | Entry Point (Home) |
| Menu Admin | ✅ Ada | ❌ Tidak ada |
| Manage Users | ✅ Bisa | ❌ Tidak bisa |
| Manage Orders | ✅ Bisa | ❌ Tidak bisa |
| Belanja | ✅ Bisa | ✅ Bisa |
| Checkout | ✅ Bisa | ✅ Bisa |

---

## ⚠️ **Troubleshooting**

### Problem: User baru tidak bisa login

**Solusi:**
1. Pastikan user sudah dibuat di **Authentication**
2. Pastikan user document sudah dibuat di **Firestore** dengan UID yang sama
3. Pastikan field `role: "user"` sudah ada

### Problem: User baru langsung jadi admin

**Solusi:**
1. Check field `role` di Firestore - harus `"user"` (bukan `"admin"`)
2. Check field `isAdmin` - harus `false`
3. Jika salah, edit manual di Firebase Console

### Problem: User baru tidak muncul di Admin Panel

**Solusi:**
1. Pastikan user document sudah dibuat di Firestore
2. Refresh Admin Panel
3. Check apakah user sudah login setidaknya sekali

---

## 🎯 **Rekomendasi**

**Untuk testing/development:**
- Gunakan **Cara 1** (Register dari aplikasi) - paling mudah dan cepat

**Untuk production:**
- User register sendiri via aplikasi (Cara 1)
- Atau admin bisa buat user manual jika diperlukan (Cara 2)

---

**Selamat! Sekarang Anda bisa menambahkan user baru dengan role "user"! 🎉**

