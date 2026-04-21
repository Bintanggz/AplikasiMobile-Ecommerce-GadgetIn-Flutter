import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop/components/list_tile/divider_list_tile.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/screen_export.dart';
import 'package:shop/screens/bookmark/views/bookmark_screen.dart';
import 'package:shop/screens/product/views/product_returns_screen.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/admin_service.dart';

import 'components/profile_card.dart';
import 'components/profile_menu_item_list_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off, size: 64, color: errorColor),
              const SizedBox(height: defaultPadding),
              const Text('Anda belum login'),
              const SizedBox(height: defaultPadding),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, logInScreenRoute);
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          String userName = user.displayName ?? 'User';
          String userEmail = user.email ?? '';
          String userImage = user.photoURL ?? 
              "https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&background=7B61FF&color=fff";

          if (snapshot.hasData && snapshot.data?.exists == true) {
            final userData = snapshot.data!.data() as Map<String, dynamic>?;
            userName = userData?['name'] ?? user.displayName ?? userEmail.split('@')[0];
            userEmail = userData?['email'] ?? user.email ?? '';
          }

          return ListView(
            children: [
              ProfileCard(
                name: userName,
                email: userEmail,
                imageSrc: userImage,
                press: () {
                  Navigator.pushNamed(context, userInfoScreenRoute);
                },
              ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding * 1.5),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, onSaleScreenRoute);
              },
              child: const AspectRatio(
                aspectRatio: 1.8,
                child: NetworkImageWithLoader(
                    "https://images.unsplash.com/photo-1478760329108-5c3ed9d495a0?auto=format&fit=crop&w=900&q=80"),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Text(
              "Akun Gadget",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          ProfileMenuListTile(
            text: "Pesanan",
            svgSrc: "assets/icons/Order.svg",
            press: () {
              Navigator.pushNamed(context, ordersScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Pengembalian",
            svgSrc: "assets/icons/Return.svg",
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProductReturnsScreen(),
                ),
              );
            },
          ),
          ProfileMenuListTile(
            text: "Wishlist",
            svgSrc: "assets/icons/Wishlist.svg",
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BookmarkScreen(),
                ),
              );
            },
          ),
          ProfileMenuListTile(
            text: "Alamat Pengiriman",
            svgSrc: "assets/icons/Address.svg",
            press: () {
              Navigator.pushNamed(context, addressesScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Metode Pembayaran",
            svgSrc: "assets/icons/card.svg",
            press: () {
              Navigator.pushNamed(context, emptyPaymentScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Dompet Digital",
            svgSrc: "assets/icons/Wallet.svg",
            press: () {
              Navigator.pushNamed(context, walletScreenRoute);
            },
          ),
          const SizedBox(height: defaultPadding),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding / 2),
            child: Text(
              "Personalisasi",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          DividerListTileWithTrilingText(
            svgSrc: "assets/icons/Notification.svg",
            title: "Notifikasi",
            trilingText: "Aktif",
            press: () {
              Navigator.pushNamed(context, enableNotificationScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Preferensi",
            svgSrc: "assets/icons/Preferences.svg",
            press: () {
              Navigator.pushNamed(context, preferencesScreenRoute);
            },
          ),
          const SizedBox(height: defaultPadding),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding / 2),
            child: Text(
              "Pengaturan",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ProfileMenuListTile(
            text: "Bahasa",
            svgSrc: "assets/icons/Language.svg",
            press: () {
              Navigator.pushNamed(context, selectLanguageScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Lokasi",
            svgSrc: "assets/icons/Location.svg",
            press: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Atur lokasi akan tersedia segera."),
                ),
              );
            },
          ),
          const SizedBox(height: defaultPadding),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding / 2),
            child: Text(
              "Bantuan & Dukungan",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ProfileMenuListTile(
            text: "Pusat Bantuan",
            svgSrc: "assets/icons/Help.svg",
            press: () {
              Navigator.pushNamed(context, getHelpScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "FAQ",
            svgSrc: "assets/icons/FAQ.svg",
            press: () {},
            isShowDivider: false,
          ),
          
          // Admin Section
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return const SizedBox.shrink();
              }
              
              final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
              final isAdmin = userData?['role'] == 'admin' || userData?['isAdmin'] == true;
              
              if (!isAdmin) {
                return const SizedBox.shrink();
              }
              
              return Column(
                children: [
                  const SizedBox(height: defaultPadding),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: defaultPadding, vertical: defaultPadding / 2),
                    child: Text(
                      "Admin",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  ProfileMenuListTile(
                    text: "Admin Dashboard",
                    svgSrc: "assets/icons/Setting.svg",
                    press: () {
                      Navigator.pushNamed(context, adminDashboardScreenRoute);
                    },
                    isShowDivider: false,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: defaultPadding),

          // Log Out
          ListTile(
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Apakah Anda yakin ingin logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: errorColor),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    logInScreenRoute,
                    (route) => false,
                  );
                }
              }
            },
            minLeadingWidth: 24,
            leading: SvgPicture.asset(
              "assets/icons/Logout.svg",
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                errorColor,
                BlendMode.srcIn,
              ),
            ),
            title: const Text(
              "Log Out",
              style: TextStyle(color: errorColor, fontSize: 14, height: 1),
            ),
          )
            ],
          );
        },
      ),
    );
  }
}
