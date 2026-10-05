import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'i18n/app_language.dart';
import 'screens/order_location_screen.dart';
import 'screens/role_entry_screen.dart';
import 'screens/customer_screen.dart';
import 'screens/partner_screen.dart';
import 'screens/admin_verification_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_settings_screen.dart';
import 'screens/admin_financial_screen.dart';
import 'screens/complaints_screen.dart';
import 'screens/admin_complaints_screen.dart';
import 'screens/ride_share_screen.dart';
import 'widgets/incoming_call_listener.dart';

final GlobalKey<ScaffoldMessengerState> appMessengerKey = GlobalKey<ScaffoldMessengerState>();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((message) {
    final title = message.notification?.title;
    final body = message.notification?.body;
    final text = [title, body].whereType<String>().where((x) => x.trim().isNotEmpty).join('\n');
    if (text.isNotEmpty) {
      appMessengerKey.currentState?.showSnackBar(SnackBar(content: Text(text), duration: const Duration(seconds: 5)));
    }
  });
  await appLanguage.loadSaved();
  runApp(const LuckyDeliveryApp());
}

class LuckyDeliveryApp extends StatelessWidget {
  const LuckyDeliveryApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Low Charge Lucky Delivery',
    debugShowCheckedModeBanner: false,
    scaffoldMessengerKey: appMessengerKey,
    navigatorKey: navigatorKey,
    builder: (context, child) => IncomingCallListener(child: child ?? const SizedBox.shrink()),
    theme: ThemeData(useMaterial3: true),
    routes: {
      '/order-locations': (_) => const OrderLocationScreen(),
      '/customer': (_) => const CustomerScreen(),
      '/partner': (_) => const PartnerScreen(),
      '/admin-verification': (_) => const AdminVerificationScreen(),
      '/admin-login': (_) => const AdminLoginScreen(),
      '/admin-dashboard': (_) => const AdminDashboardScreen(),
      '/admin-settings': (_) => const AdminSettingsScreen(),
      '/admin-financial': (_) => const AdminFinancialScreen(),
      '/complaints': (_) => const ComplaintsScreen(),
      '/admin-complaints': (_) => const AdminComplaintsScreen(),
      '/ride-share': (_) => const RideShareScreen(),
    },
    home: const RoleEntryScreen(),
  );
}
