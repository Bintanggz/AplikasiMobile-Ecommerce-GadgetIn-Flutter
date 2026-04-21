import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class EnableNotificationScreen extends StatelessWidget {
  const EnableNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktifkan Notifikasi'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_active,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: defaultPadding),
            Text(
              'Aktifkan Notifikasi',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: defaultPadding / 2),
            Text(
              'Dapatkan notifikasi tentang produk baru, diskon, dan pesanan Anda',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: defaultPadding * 2),
            ElevatedButton(
              onPressed: () {
                // Handle enable notification
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notifikasi diaktifkan')),
                );
              },
              child: const Text('Aktifkan Notifikasi'),
            ),
          ],
        ),
      ),
    );
  }
}
