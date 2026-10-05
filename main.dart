import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/role_entry_screen.dart';
import 'screens/order_location_screen.dart';
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

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try { await Firebase.initializeApp(); } catch (_) {}
  runApp(const LuckyDeliveryApp());
}

class LuckyDeliveryApp extends StatelessWidget {
  const LuckyDeliveryApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: navigatorKey,
    debugShowCheckedModeBanner: false,
    title: 'Lucky Delivery',
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepOrange),
    home: const IncomingCallListener(child: RoleEntryScreen()),
    routes: {
      '/location': (_) => const OrderLocationScreen(),
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
  );
}
