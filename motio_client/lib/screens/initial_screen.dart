import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motio_client/providers/user_provider.dart';
import 'package:motio_client/screens/home_screen.dart';
import 'package:motio_client/screens/login_screen.dart';
import 'package:motio_client/services/auth_service.dart';

class InitialScreen extends ConsumerStatefulWidget {
  const InitialScreen({super.key});

  @override
  ConsumerState<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends ConsumerState<InitialScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final refreshToken = await _authService.getRefreshToken();
    if (!mounted) return;

    if (refreshToken == null) {
      moveToLoginPage();
    } else {
      final jwtResponse = await _authService.checkAndRefreshTokens();
      if (!mounted) return;
      if (jwtResponse != null) {
        await ref.read(userProvider.notifier).fetchUser();
        moveToHomeScreen();
      } else {
        sessionOutdated();
      }
    }
  }

  void sessionOutdated() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sesja wygasła. Proszę zalogować się ponownie.')));
  }

  void moveToHomeScreen() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void moveToLoginPage() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
