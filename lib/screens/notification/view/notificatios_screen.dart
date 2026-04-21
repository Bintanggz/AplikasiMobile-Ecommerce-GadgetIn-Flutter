import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/constants.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  List<Map<String, String>> get _notifications => const [
        {
          "title": "Status Pesanan",
          "message": "Pesanan #EC-1203 sedang dikemas.",
          "time": "2 menit lalu",
          "icon": "assets/icons/Order.svg"
        },
        {
          "title": "Promo Spesial",
          "message": "Diskon 15% untuk aksesoris gaming hari ini!",
          "time": "1 jam lalu",
          "icon": "assets/icons/Sale.svg"
        },
        {
          "title": "Pengiriman",
          "message": "Kurir sedang menuju alamat kamu.",
          "time": "Kemarin",
          "icon": "assets/icons/Delivery.svg"
        },
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifikasi"),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("Tandai telah dibaca"),
          )
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(defaultPadding),
        itemBuilder: (context, index) {
          final item = _notifications[index];
          return ListTile(
            onTap: () {},
            leading: Container(
              padding: const EdgeInsets.all(defaultPadding / 2),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              child: SvgPicture.asset(
                item["icon"]!,
                height: 20,
                colorFilter:
                    const ColorFilter.mode(primaryColor, BlendMode.srcIn),
              ),
            ),
            title: Text(
              item["title"]!,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(item["message"]!),
            trailing: Text(
              item["time"]!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Theme.of(context).hintColor),
            ),
          );
        },
        separatorBuilder: (_, __) => const Divider(),
        itemCount: _notifications.length,
      ),
    );
  }
}
