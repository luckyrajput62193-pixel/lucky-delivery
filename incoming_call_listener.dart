import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/voice_call_screen.dart';
import '../services/order_call_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class IncomingCallListener extends StatefulWidget {
  final Widget child;
  const IncomingCallListener({super.key, required this.child});
  @override State<IncomingCallListener> createState() => _IncomingCallListenerState();
}

class _IncomingCallListenerState extends State<IncomingCallListener> {
  final Set<String> _shown = {};
  final Map<String, Timer> _ringTimers = {};
  static const Duration _ringTimeoutDuration = Duration(seconds: 45);
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  StreamSubscription<User?>? _authSub;
  String? _activeUid;

  @override
  void initState() {
    super.initState();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((_) => _bind());
    _bind();
  }

  void _bind() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == _activeUid && _sub != null) return;
    _sub?.cancel();
    _activeUid = uid;
    if (uid == null) return;
    _sub = FirebaseFirestore.instance.collection('users').doc(uid).collection('incomingCalls').where('status', isEqualTo: 'ringing').snapshots().listen((snap) {
      for (final doc in snap.docs) {
        if (_shown.contains(doc.id)) continue;
        _shown.add(doc.id);
        final d = doc.data();
        final ctx = navigatorKey.currentState?.overlay?.context;
        if (ctx == null) continue;
        _ringTimers[doc.id]?.cancel();
        late BuildContext dialogContext;
        showDialog<void>(
          context: ctx,
          barrierDismissible: false,
          builder: (context) {
            dialogContext = context;
            return AlertDialog(
            title: Text(L.text(appLanguage.value, 'incomingVoiceCall')),
            content: Text(L.text(appLanguage.value, 'incomingVoiceCallText')),
            actions: [
              TextButton(onPressed: () async { _ringTimers.remove(doc.id)?.cancel(); Navigator.of(dialogContext).pop(); try { await OrderCallService.endCall(orderId: d['orderId'].toString(), callId: d['callId'].toString()); } catch (_) {} }, child: Text(L.text(appLanguage.value, 'decline'))),
              FilledButton(onPressed: () { _ringTimers.remove(doc.id)?.cancel(); Navigator.of(dialogContext).pop(); navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => VoiceCallScreen(orderId: d['orderId'].toString(), callId: d['callId'].toString(), incoming: true))); }, child: Text(L.text(appLanguage.value, 'answer'))),
            ],
          );
          },
        );
        _ringTimers[doc.id] = Timer(_ringTimeoutDuration, () async {
          try {
            await OrderCallService.endCall(orderId: d['orderId'].toString(), callId: d['callId'].toString());
          } catch (_) {}
          _ringTimers.remove(doc.id)?.cancel();
          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
        });
      }
    });
  }

  @override
  void dispose() { for (final timer in _ringTimers.values) { timer.cancel(); } _ringTimers.clear(); _authSub?.cancel(); _sub?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) => widget.child;
}
