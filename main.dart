import 'package:flutter/material.dart';

void main() => runApp(const LuckyDeliveryApp());

class AppStrings {
  static const Map<String, Map<String, String>> data = {
    'English': {
      'app': 'Lucky Delivery', 'welcome': 'Welcome', 'customer': 'Customer', 'partner': 'Delivery Partner',
      'continue': 'Continue', 'language': 'Language', 'home': 'Home', 'orders': 'Orders', 'profile': 'Profile',
      'newOrder': 'Create Delivery', 'pickup': 'Pickup location', 'drop': 'Delivery location',
      'amount': 'Agreed amount', 'note': 'Note', 'create': 'Create order', 'available': 'Available deliveries',
      'accept': 'Accept delivery', 'noOrders': 'No orders yet', 'verification': 'Account verification',
      'verified': 'Verified account', 'demo': 'Demo mode', 'success': 'Order created successfully',
    },
    'हिन्दी': {
      'app': 'लकी डिलीवरी', 'welcome': 'स्वागत है', 'customer': 'ग्राहक', 'partner': 'डिलीवरी पार्टनर',
      'continue': 'जारी रखें', 'language': 'भाषा', 'home': 'होम', 'orders': 'ऑर्डर', 'profile': 'प्रोफ़ाइल',
      'newOrder': 'डिलीवरी बनाएं', 'pickup': 'पिकअप स्थान', 'drop': 'डिलीवरी स्थान',
      'amount': 'तय की गई राशि', 'note': 'नोट', 'create': 'ऑर्डर बनाएं', 'available': 'उपलब्ध डिलीवरी',
      'accept': 'डिलीवरी स्वीकार करें', 'noOrders': 'अभी कोई ऑर्डर नहीं', 'verification': 'खाता सत्यापन',
      'verified': 'सत्यापित खाता', 'demo': 'डेमो मोड', 'success': 'ऑर्डर सफलतापूर्वक बनाया गया',
    },
    'ગુજરાતી': {
      'app': 'લકી ડિલિવરી', 'welcome': 'સ્વાગત છે', 'customer': 'ગ્રાહક', 'partner': 'ડિલિવરી પાર્ટનર',
      'continue': 'ચાલુ રાખો', 'language': 'ભાષા', 'home': 'હોમ', 'orders': 'ઓર્ડર', 'profile': 'પ્રોફાઇલ',
      'newOrder': 'ડિલિવરી બનાવો', 'pickup': 'પિકઅપ સ્થાન', 'drop': 'ડિલિવરી સ્થાન',
      'amount': 'નક્કી કરેલી રકમ', 'note': 'નોંધ', 'create': 'ઓર્ડર બનાવો', 'available': 'ઉપલબ્ધ ડિલિવરી',
      'accept': 'ડિલિવરી સ્વીકારો', 'noOrders': 'હજુ કોઈ ઓર્ડર નથી', 'verification': 'એકાઉન્ટ ચકાસણી',
      'verified': 'ચકાસાયેલ એકાઉન્ટ', 'demo': 'ડેમો મોડ', 'success': 'ઓર્ડર સફળતાપૂર્વક બન્યો',
    },
  };
}

class DeliveryOrder {
  final String pickup, drop, note;
  final double amount;
  String status;
  DeliveryOrder({required this.pickup, required this.drop, required this.amount, this.note = '', this.status = 'Pending'});
}

class LuckyDeliveryApp extends StatefulWidget {
  const LuckyDeliveryApp({super.key});
  @override State<LuckyDeliveryApp> createState() => _LuckyDeliveryAppState();
}

class _LuckyDeliveryAppState extends State<LuckyDeliveryApp> {
  String language = 'English';
  String role = 'Customer';
  final List<DeliveryOrder> orders = [];

  String t(String key) => AppStrings.data[language]?[key] ?? AppStrings.data['English']![key] ?? key;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: t('app'),
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: HomePage(app: this),
    );
  }
}

class HomePage extends StatefulWidget {
  final _LuckyDeliveryAppState app;
  const HomePage({super.key, required this.app});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  String get t => widget.app.t('home');

  @override
  Widget build(BuildContext context) {
    final pages = [
      Dashboard(app: widget.app),
      OrdersPage(app: widget.app),
      ProfilePage(app: widget.app),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(widget.app.t('app')), centerTitle: true),
      body: pages[index],
      bottomNavigationBar: NavigationBar(selectedIndex: index, onDestinationSelected: (i) => setState(() => index = i), destinations: [
        NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: widget.app.t('home')),
        NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), selectedIcon: const Icon(Icons.receipt_long), label: widget.app.t('orders')),
        NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: widget.app.t('profile')),
      ]),
    );
  }
}

class Dashboard extends StatelessWidget {
  final _LuckyDeliveryAppState app;
  const Dashboard({super.key, required this.app});
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(app.t('welcome'), style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6), Text(app.role == 'Customer' ? app.t('customer') : app.t('partner')),
        const SizedBox(height: 16), Chip(avatar: const Icon(Icons.verified, size: 18), label: Text(app.t('verified'))),
      ]))),
      if (app.role == 'Customer') ...[
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreateOrderPage(app: app))), icon: const Icon(Icons.add_location_alt), label: Text(app.t('newOrder'))),
      ] else ...[
        const SizedBox(height: 12),
        Text(app.t('available'), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (app.orders.isEmpty) Text(app.t('noOrders')),
        ...app.orders.map((o) => OrderCard(order: o, app: app)),
      ],
      const SizedBox(height: 20),
      Card(child: ListTile(leading: const Icon(Icons.info_outline), title: Text(app.t('demo')), subtitle: const Text('Core UI is ready. Production services can be connected next.'))),
    ]);
  }
}

class CreateOrderPage extends StatefulWidget {
  final _LuckyDeliveryAppState app;
  const CreateOrderPage({super.key, required this.app});
  @override State<CreateOrderPage> createState() => _CreateOrderPageState();
}
class _CreateOrderPageState extends State<CreateOrderPage> {
  final pickup = TextEditingController(), drop = TextEditingController(), amount = TextEditingController(), note = TextEditingController();
  @override void dispose() { pickup.dispose(); drop.dispose(); amount.dispose(); note.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.app.t('newOrder'))),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      TextField(controller: pickup, decoration: InputDecoration(labelText: widget.app.t('pickup'), prefixIcon: const Icon(Icons.my_location))),
      const SizedBox(height: 12), TextField(controller: drop, decoration: InputDecoration(labelText: widget.app.t('drop'), prefixIcon: const Icon(Icons.location_on))),
      const SizedBox(height: 12), TextField(controller: amount, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: widget.app.t('amount'), prefixIcon: const Icon(Icons.currency_rupee))),
      const SizedBox(height: 12), TextField(controller: note, maxLines: 3, decoration: InputDecoration(labelText: widget.app.t('note'), prefixIcon: const Icon(Icons.notes))),
      const SizedBox(height: 24), FilledButton(onPressed: () {
        final a = double.tryParse(amount.text.trim());
        if (pickup.text.trim().isEmpty || drop.text.trim().isEmpty || a == null || a <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter pickup, delivery and a valid amount.'))); return;
        }
        widget.app.orders.add(DeliveryOrder(pickup: pickup.text.trim(), drop: drop.text.trim(), amount: a, note: note.text.trim()));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.app.t('success'))));
        Navigator.pop(context);
      }, child: Text(widget.app.t('create'))),
    ]),
  );
}

class OrdersPage extends StatelessWidget {
  final _LuckyDeliveryAppState app;
  const OrdersPage({super.key, required this.app});
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Text(app.t('orders'), style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 12),
    if (app.orders.isEmpty) Center(child: Padding(padding: const EdgeInsets.all(40), child: Text(app.t('noOrders')))),
    ...app.orders.map((o) => OrderCard(order: o, app: app)),
  ]);
}

class OrderCard extends StatelessWidget {
  final DeliveryOrder order; final _LuckyDeliveryAppState app;
  const OrderCard({super.key, required this.order, required this.app});
  @override Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [const Icon(Icons.route), const SizedBox(width: 8), Expanded(child: Text('${order.pickup} → ${order.drop}', style: const TextStyle(fontWeight: FontWeight.bold))), Chip(label: Text(order.status))]),
    const SizedBox(height: 8), Text('₹${order.amount.toStringAsFixed(0)}  •  ${order.note.isEmpty ? 'No note' : order.note}'),
    if (app.role == 'Delivery Partner' && order.status == 'Pending') Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () { order.status = 'Accepted'; (context as Element).markNeedsBuild(); }, child: Text(app.t('accept')))),
  ])));
}

class ProfilePage extends StatelessWidget {
  final _LuckyDeliveryAppState app;
  const ProfilePage({super.key, required this.app});
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Text(app.t('profile'), style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 16),
    DropdownButtonFormField<String>(value: app.role, decoration: InputDecoration(labelText: 'Role', border: const OutlineInputBorder()), items: ['Customer', 'Delivery Partner'].map((x) => DropdownMenuItem(value: x, child: Text(x == 'Customer' ? app.t('customer') : app.t('partner')))).toList(), onChanged: (v) { if (v != null) { app.role = v; (context as Element).markNeedsBuild(); } }),
    const SizedBox(height: 16),
    DropdownButtonFormField<String>(value: app.language, decoration: InputDecoration(labelText: app.t('language'), border: const OutlineInputBorder()), items: AppStrings.data.keys.map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) { if (v != null) { app.language = v; (context as Element).markNeedsBuild(); } }),
    const SizedBox(height: 16),
    ListTile(leading: const Icon(Icons.verified_user), title: Text(app.t('verification')), subtitle: Text(app.t('verified'))),
  ]);
}
