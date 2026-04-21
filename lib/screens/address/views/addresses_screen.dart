import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop/constants.dart';
import 'add_edit_address_screen.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  Future<void> _initializeDefaultAddress(String userId) async {
    final addressesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('addresses');

    final existingAddresses = await addressesRef.get();
    
    // Jika belum ada alamat, buat default address
    if (existingAddresses.docs.isEmpty) {
      await addressesRef.add({
        'name': 'Penerima',
        'phone': '',
        'address': 'Jl. Laweyan',
        'city': 'Surakarta',
        'postalCode': '57141',
        'isDefault': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Alamat Pengiriman'),
        ),
        body: const Center(
          child: Text('Anda belum login'),
        ),
      );
    }

    // Initialize default address if needed (async, don't await to avoid blocking UI)
    _initializeDefaultAddress(user.uid).catchError((e) {
      print('⚠️ AddressesScreen: Error initializing default address: $e');
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alamat Pengiriman'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddEditAddressScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('addresses')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('❌ AddressesScreen Error: ${snapshot.error}');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: errorColor),
                    const SizedBox(height: defaultPadding),
                    Text(
                      'Terjadi kesalahan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    Text(
                      '${snapshot.error}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: defaultPadding),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Kembali'),
                    ),
                  ],
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? <QueryDocumentSnapshot<Map<String, dynamic>>>[];
          
          // Sort manually: default first, then by createdAt descending
          if (docs.isNotEmpty) {
            try {
              docs.sort((a, b) {
                final aDefault = a.data()['isDefault'] ?? false;
                final bDefault = b.data()['isDefault'] ?? false;
                
                // Default addresses first
                if (aDefault && !bDefault) return -1;
                if (!aDefault && bDefault) return 1;
                
                // If both have same default status, sort by createdAt
                final aTime = a.data()['createdAt'] as Timestamp?;
                final bTime = b.data()['createdAt'] as Timestamp?;
                if (aTime == null && bTime == null) return 0;
                if (aTime == null) return 1;
                if (bTime == null) return -1;
                return bTime.compareTo(aTime);
              });
            } catch (e) {
              print('⚠️ AddressesScreen: Error sorting addresses: $e');
            }
          }

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: defaultPadding),
                  Text(
                    'Belum ada alamat',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  Text(
                    'Tambahkan alamat pengiriman Anda',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: defaultPadding * 2),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddEditAddressScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Alamat'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(defaultPadding),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final isDefault = data['isDefault'] ?? false;

              return Container(
                margin: const EdgeInsets.only(bottom: defaultPadding),
                padding: const EdgeInsets.all(defaultPadding),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                  border: Border.all(
                    color: isDefault ? primaryColor : Colors.grey.shade200,
                    width: isDefault ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: isDefault ? primaryColor : Colors.grey.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              data['name'] ?? 'Penerima',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isDefault) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Utama',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            if (!isDefault)
                              IconButton(
                                icon: const Icon(Icons.star_outline, size: 20),
                                tooltip: 'Jadikan Alamat Utama',
                                onPressed: () async {
                                  try {
                                    // Set all addresses to not default first
                                    final addressesRef = FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user.uid)
                                        .collection('addresses');
                                    
                                    final allAddresses = await addressesRef.get();
                                    for (var addressDoc in allAddresses.docs) {
                                      await addressDoc.reference.update({'isDefault': false});
                                    }
                                    
                                    // Set this address as default
                                    await addressesRef.doc(doc.id).update({'isDefault': true});
                                    
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Alamat utama berhasil diubah')),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Gagal mengubah alamat utama: $e')),
                                      );
                                    }
                                  }
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              tooltip: 'Edit Alamat',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEditAddressScreen(
                                      addressData: data,
                                      addressId: doc.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              color: errorColor,
                              tooltip: 'Hapus Alamat',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Hapus Alamat'),
                                    content: const Text('Apakah Anda yakin ingin menghapus alamat ini?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        style: TextButton.styleFrom(foregroundColor: errorColor),
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true && context.mounted) {
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user.uid)
                                        .collection('addresses')
                                        .doc(doc.id)
                                        .delete();
                                    
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Alamat berhasil dihapus')),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Gagal menghapus alamat: $e')),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    Text(
                      data['phone'] ?? '',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: defaultPadding / 4),
                    Text(
                      '${data['address'] ?? ''}, ${data['city'] ?? ''}, ${data['postalCode'] ?? ''}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
