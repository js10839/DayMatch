import 'package:flutter/material.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const DayMatchApp());
}

class DayMatchApp extends StatelessWidget {
  const DayMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DayMatch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFEDE8F5)),
        fontFamily: 'SF Pro Display',
      ),
      home: const _SplashGate(),
    );
  }
}

class _SplashGate extends StatefulWidget {
  const _SplashGate();

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  late final Future<Widget> _routeFuture = _resolveStartScreen();

  Future<Widget> _resolveStartScreen() async {
    final token = await AuthService().getStoredToken();
    if (token == null) return const SignInScreen();

    final me = await AuthService().getMe();
    if (me == null) return const SignInScreen();

    final name = me.user?['name'] as String?;
    return SignUpScreen(
      initialName: name,
      alreadyCompleted: me.hasProfile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _routeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Color(0xFFEDE8F5),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF3B0FA0)),
            ),
          );
        }
        return snapshot.data ?? const SignInScreen();
      },
    );
  }
}
