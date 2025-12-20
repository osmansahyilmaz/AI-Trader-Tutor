import 'package:ai_trader_tutor/core/constants.dart';
import 'package:ai_trader_tutor/features/auth/auth_screen.dart';
import 'package:ai_trader_tutor/features/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: MyApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
  ],
  redirect: (context, state) {
    // Note: In a real app, you should listen to auth state changes stream
    // and trigger router refresh. For MVP PR #1, we just check current session.
    // To make it reactive, we'd need a Riverpod provider watching onAuthStateChange.
    final session = Supabase.instance.client.auth.currentSession;
    final isAuthRoute = state.uri.path == '/auth';

    if (session == null && !isAuthRoute) {
      return '/auth';
    }
    if (session != null && isAuthRoute) {
      return '/';
    }
    return null;
  },
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Trader AI Tutor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
