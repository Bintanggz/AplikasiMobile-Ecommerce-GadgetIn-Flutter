import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class NotificationOptionsScreen extends StatelessWidget {
  const NotificationOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Notifikasi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(defaultPadding),
        children: [
          SwitchListTile(
            title: const Text('Notifikasi Produk Baru'),
            subtitle: const Text('Dapatkan notifikasi tentang produk baru'),
            value: true,
            onChanged: (value) {},
          ),
          SwitchListTile(
            title: const Text('Notifikasi Diskon'),
            subtitle: const Text('Dapatkan notifikasi tentang penawaran spesial'),
            value: true,
            onChanged: (value) {},
          ),
          SwitchListTile(
            title: const Text('Notifikasi Pesanan'),
            subtitle: const Text('Dapatkan update tentang status pesanan Anda'),
            value: true,
            onChanged: (value) {},
          ),
          SwitchListTile(
            title: const Text('Notifikasi Promosi'),
            subtitle: const Text('Dapatkan notifikasi tentang promosi dan event'),
            value: false,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }
}
