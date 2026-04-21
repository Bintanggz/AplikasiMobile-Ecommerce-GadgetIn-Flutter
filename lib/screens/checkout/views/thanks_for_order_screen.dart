import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/screen_export.dart';

class ThanksForOrderScreen extends StatelessWidget {
  const ThanksForOrderScreen({
    super.key,
    this.orderTotal,
    this.paymentMethod,
  });

  final dynamic orderTotal;
  final String? paymentMethod;

  @override
  Widget build(BuildContext context) {
    // Ensure orderTotal is properly converted to int
    final orderTotalValue = orderTotal is int 
        ? orderTotal 
        : orderTotal is num 
            ? orderTotal.toInt() 
            : (orderTotal as int? ?? 0);
    
    // Get payment method, with proper fallback
    final paymentMethodValue = (paymentMethod ?? 'Cash on Delivery (COD)').toString();

    String formatRp(dynamic value) {
      return formatCurrency(value is int ? value.toDouble() : (value as num).toDouble());
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              const Spacer(),
              Image.asset(
                Theme.of(context).brightness == Brightness.light
                    ? "assets/Illustration/success.png"
                    : "assets/Illustration/success_dark.png",
                height: MediaQuery.of(context).size.height * 0.3,
              ),
              const Spacer(flex: 2),
              Text(
                "Pesanan Berhasil!",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: defaultPadding / 2),
              Text(
                "Terima kasih atas pesanan Anda",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: defaultPadding),
              Container(
                padding: const EdgeInsets.all(defaultPadding),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Pesanan:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          formatRp(orderTotalValue),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Metode Pembayaran:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          paymentMethodValue,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: defaultPadding),
              Text(
                paymentMethodValue.toLowerCase().contains('cash on delivery') ||
                paymentMethodValue.toLowerCase().contains('cod')
                    ? 'Pesanan Anda akan diproses dan dikirim segera. Silakan siapkan uang tunai saat barang diterima.'
                    : 'Silakan lakukan pembayaran sesuai dengan metode yang dipilih. Pesanan akan diproses setelah pembayaran dikonfirmasi.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      entryPointScreenRoute,
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultBorderRadious),
                    ),
                  ),
                  child: const Text(
                    'Kembali ke Beranda',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: defaultPadding / 2),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      ordersScreenRoute,
                      (route) => route.settings.name == entryPointScreenRoute,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultBorderRadious),
                    ),
                  ),
                  child: const Text(
                    'Lihat Pesanan Saya',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

