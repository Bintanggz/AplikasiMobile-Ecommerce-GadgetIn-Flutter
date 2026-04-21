import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop/entry_point.dart';
import 'package:shop/services/cart_screen.dart' as cart_service;
import 'screen_export.dart';

// Route names diasumsikan sudah didefinisikan di route_constants.dart

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {

  // =================== MAIN SCREENS ===================
    case onbordingScreenRoute:
      return MaterialPageRoute(builder: (_) => const OnBordingScreen());

    case logInScreenRoute:
      return MaterialPageRoute(builder: (_) => const LoginScreen());

    case signUpScreenRoute:
      return MaterialPageRoute(builder: (_) => const SignUpScreen());

    case passwordRecoveryScreenRoute:
      return MaterialPageRoute(builder: (_) => const PasswordRecoveryScreen());

    case homeScreenRoute:
      return MaterialPageRoute(builder: (_) => const HomeScreen());

    case discoverScreenRoute:
      return MaterialPageRoute(builder: (_) => const DiscoverScreen());

    case onSaleScreenRoute:
      return MaterialPageRoute(
        builder: (_) {
          final category = settings.arguments as String?;
          return OnSaleScreen(category: category);
        },
      );

    case kidsScreenRoute:
      return MaterialPageRoute(builder: (_) => const KidsScreen());

    case searchScreenRoute:
      return MaterialPageRoute(builder: (_) => const SearchScreen());

    case bookmarkScreenRoute:
      return MaterialPageRoute(builder: (_) => const BookmarkScreen());

    case entryPointScreenRoute:
      return MaterialPageRoute(builder: (_) => const EntryPoint());

    case profileScreenRoute:
      return MaterialPageRoute(builder: (_) => const ProfileScreen());

    case userInfoScreenRoute:
      return MaterialPageRoute(builder: (_) => const UserInfoScreen());

    case notificationsScreenRoute:
      return MaterialPageRoute(builder: (_) => const NotificationsScreen());

    case noNotificationScreenRoute:
      return MaterialPageRoute(builder: (_) => const NoNotificationScreen());

    case enableNotificationScreenRoute:
      return MaterialPageRoute(builder: (_) => const EnableNotificationScreen());

    case notificationOptionsScreenRoute:
      return MaterialPageRoute(builder: (_) => const NotificationOptionsScreen());

    case addressesScreenRoute:
      return MaterialPageRoute(builder: (_) => const AddressesScreen());

    case ordersScreenRoute:
      return MaterialPageRoute(builder: (_) => const OrdersScreen());

    case preferencesScreenRoute:
      return MaterialPageRoute(builder: (_) => const PreferencesScreen());

    case emptyWalletScreenRoute:
      return MaterialPageRoute(builder: (_) => const EmptyWalletScreen());

    case walletScreenRoute:
      return MaterialPageRoute(builder: (_) => const WalletScreen());

    case cartScreenRoute:
      return MaterialPageRoute(builder: (_) => cart_service.CartScreen());

    case checkoutScreenRoute:
      return MaterialPageRoute(
        builder: (context) {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null) {
            return const Scaffold(
              body: Center(child: Text('Error: No checkout data')),
            );
          }
          return CheckoutScreen(
            items: args['items'] as List<QueryDocumentSnapshot<Map<String, dynamic>>>,
            total: args['total'] as int,
          );
        },
      );

    case thanksForOrderScreenRoute:
      return MaterialPageRoute(
        builder: (context) {
          final args = settings.arguments as Map<String, dynamic>?;
          return ThanksForOrderScreen(
            orderTotal: args?['orderTotal'],
            paymentMethod: args?['paymentMethod'],
          );
        },
      );

    case productReviewsScreenRoute:
      return MaterialPageRoute(builder: (_) => const ProductReviewsScreen());

    // Admin Routes
    case adminDashboardScreenRoute:
      return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());

    case adminUsersScreenRoute:
      return MaterialPageRoute(builder: (_) => const AdminUsersScreen());

    case adminOrdersScreenRoute:
      return MaterialPageRoute(builder: (_) => const AdminOrdersScreen());

  // =================== ARGUMENT SCREENS ===================
    case productDetailsScreenRoute:
      return MaterialPageRoute(
        builder: (context) {
          final args = settings.arguments as Map<String, dynamic>?;

          // Fallback/default jika args null
          final productData = args ?? {
            'name': 'Unknown Product',
            'price': 0,
            'description': 'No description available',
            'imageUrl': '',
            'stock': 0,
          };

          return ProductDetailsScreen(productData: productData);
        },
      );

  // =================== UNUSED / COMMENTED SCREENS ===================
  // case addReviewsScreenRoute:
  // case verificationMethodScreenRoute:
  // ...

    default:
      return MaterialPageRoute(builder: (_) => const OnBordingScreen());
  }
}
