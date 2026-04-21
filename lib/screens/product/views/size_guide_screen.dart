import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class SizeGuideScreen extends StatefulWidget {
  const SizeGuideScreen({super.key});

  @override
  State<SizeGuideScreen> createState() => _SizeGuideScreenState();
}

class _SizeGuideScreenState extends State<SizeGuideScreen> {
  bool _isShowCentimetersSize = false;

  void updateSizes() {
    setState(() {
      _isShowCentimetersSize = !_isShowCentimetersSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panduan Ukuran'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Panduan Ukuran Gadget',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: defaultPadding),
            Text(
              'Untuk produk gadget seperti smartphone, tablet, dan aksesoris lainnya, '
              'ukuran biasanya mengacu pada dimensi fisik produk.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: defaultPadding * 2),
            SwitchListTile(
              title: const Text('Tampilkan Ukuran dalam Centimeter'),
              value: _isShowCentimetersSize,
              onChanged: (value) => updateSizes(),
            ),
            const SizedBox(height: defaultPadding),
            Text(
              _isShowCentimetersSize
                  ? 'Ukuran akan ditampilkan dalam centimeter (cm)'
                  : 'Ukuran akan ditampilkan dalam inch',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: defaultPadding * 2),
            Text(
              'Catatan:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: defaultPadding / 2),
            Text(
              '• Ukuran dapat bervariasi ±1-2mm\n'
              '• Pastikan untuk memeriksa spesifikasi produk sebelum membeli\n'
              '• Jika ragu, hubungi customer service kami',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
