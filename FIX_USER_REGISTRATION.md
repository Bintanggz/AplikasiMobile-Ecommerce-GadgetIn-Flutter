# 🔧 Fix: Masalah Register dan Login User

## ❌ Masalah yang Terjadi

1. **Register:** Muncul error "Email sudah terdaftar" padahal belum terdaftar
2. **Login:** Muncul error "Login failed" setelah register

## 🔍 Penyebab

User sudah dibuat di **Firebase Authentication** tapi **document di Firestore belum dibuat**. Ini bisa terjadi karena:
- Error saat create document di Firestore
- Register sebelumnya gagal di tengah proses
- User dibuat manual di Authentication tapi lupa buat document

## ✅ Solusi yang Sudah Diterapkan

### 1. **Auto-create User Document saat Login**
- Jika user login dan document tidak ada, akan otomatis dibuat
- User bisa langsung login tanpa masalah

### 2. **Perbaikan Error Handling**
- Error message lebih jelas dan informatif
- Handle berbagai error code dari Firebase

### 3. **Perbaikan Register**
- Pastikan user document selalu dibuat setelah register
- Handle edge cases dengan lebih baik

---

## 🚀 Cara Mengatasi User yang Sudah Ada

Jika Anda punya user yang sudah ada di Authentication tapi belum ada document di Firestore:

### **Opsi 1: Login dengan User Tersebut (Paling Mudah)**

1. **Login dengan email dan password user tersebut**
2. **System akan otomatis membuat document** di Firestore
3. **User bisa langsung digunakan**

### **Opsi 2: Buat Manual di Firebase Console**

1. **Buka Firebase Console** > Authentication > Users
2. **Cari user yang bermasalah** (copy UID-nya)
3. **Buka Firestore Database** > collection "users"
4. **Add document:**
   - **Document ID:** Paste UID dari Authentication
   - **Fields:**
     ```
     name: "Nama User"
     email: "email@example.com"
     role: "user"
     isAdmin: false
     isBanned: false
     createdAt: [timestamp]
     updatedAt: [timestamp]
     ```
5. **Save**

### **Opsi 3: Hapus User dan Register Ulang**

1. **Buka Firebase Console** > Authentication > Users
2. **Hapus user yang bermasalah**
3. **Register ulang dari aplikasi**

---

## 🧪 Test Sekarang

### Test Register User Baru:

1. **Logout** dari aplikasi
2. **Klik "Sign up"**
3. **Isi form:**
   - Nama: "Test User"
   - Email: "test@example.com" (email baru yang belum pernah digunakan)
   - Password: "123456"
   - Confirm Password: "123456"
   - Centang Terms & Privacy
4. **Klik "Continue"**
5. **Seharusnya:**
   - ✅ Register berhasil
   - ✅ User document dibuat di Firestore
   - ✅ Redirect ke Home

### Test Login:

1. **Logout** (jika sedang login)
2. **Login dengan email dan password yang baru dibuat**
3. **Seharusnya:**
   - ✅ Login berhasil
   - ✅ Jika user document tidak ada, akan otomatis dibuat
   - ✅ Redirect sesuai role (admin → Admin Dashboard, user → Home)

---

## ⚠️ Catatan Penting

1. **Email harus unik:** Setiap email hanya bisa digunakan sekali
2. **Password minimal 6 karakter**
3. **Jika email sudah terdaftar:** Gunakan email lain atau login dengan email tersebut
4. **Jika login gagal:** Pastikan password benar dan user tidak di-ban

---

## 🔍 Troubleshooting

### Problem: Masih muncul "Email sudah terdaftar"

**Solusi:**
1. Cek di Firebase Console > Authentication > Users
2. Jika email sudah ada, gunakan email lain atau login dengan email tersebut
3. Atau hapus user dari Authentication dan register ulang

### Problem: Login masih gagal

**Solusi:**
1. Pastikan password benar
2. Cek apakah user di-ban (field `isBanned: true`)
3. Cek console untuk error message detail
4. Pastikan internet connection aktif

### Problem: User document tidak dibuat

**Solusi:**
1. Login dengan user tersebut - akan auto-create document
2. Atau buat manual di Firebase Console (Opsi 2 di atas)
3. Check Firestore Security Rules - pastikan user bisa create document sendiri

---

**Sekarang sistem sudah lebih robust dan bisa handle edge cases dengan baik! 🎉**

