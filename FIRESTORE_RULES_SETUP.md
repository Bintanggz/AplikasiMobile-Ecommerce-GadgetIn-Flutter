# Cara Mengatur Firestore Security Rules

## Masalah: Permission Denied

Jika Anda mendapatkan error "Cloud Firestore permission denied", Anda perlu mengatur Firestore Security Rules di Firebase Console.

## Langkah-langkah:

### 1. Buka Firebase Console
- Kunjungi: https://console.firebase.google.com/
- Pilih project Anda: **e-commerceapp-34f6e**

### 2. Buka Firestore Database
- Di menu kiri, klik **Firestore Database**
- Klik tab **Rules** di bagian atas

### 3. Update Rules

**Opsi A: Untuk Development/Testing (Mengizinkan semua read)**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Collection product - izinkan read untuk semua, write hanya untuk authenticated users
    match /product/{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Collection lainnya
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**Opsi B: Untuk Production (Lebih aman - hanya authenticated users)**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Collection product - izinkan read untuk semua (agar produk bisa dilihat tanpa login)
    match /product/{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Collection carts - hanya untuk user yang login
    match /carts/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Collection users - hanya untuk user yang login
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 4. Publish Rules
- Klik tombol **Publish** di bagian atas
- Tunggu beberapa detik hingga rules terupdate

### 5. Test Aplikasi
- Restart aplikasi Flutter Anda
- Produk seharusnya sudah muncul

## Catatan Penting:

⚠️ **Opsi A** (allow read: if true) hanya untuk development/testing. 
Untuk production, gunakan **Opsi B** yang lebih aman.

## Troubleshooting:

1. **Masih error?** 
   - Pastikan Anda sudah klik **Publish** setelah mengubah rules
   - Tunggu 1-2 menit untuk rules terpropagasi
   - Restart aplikasi

2. **Tidak bisa write data?**
   - Pastikan user sudah login
   - Check apakah collection name sesuai (harus "product" bukan "products")

3. **Masih permission denied?**
   - Pastikan project ID di Firebase Console sama dengan di `firebase_options.dart`
   - Check apakah `google-services.json` sudah benar


