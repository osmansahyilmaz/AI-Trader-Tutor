import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  // --- Validation ---

  bool get _isLoginValid {
    return _isValidEmail(_loginEmailController.text) && _loginPasswordController.text.length >= 8;
  }

  bool get _isRegisterValid {
    return _isValidEmail(_registerEmailController.text) &&
        _registerPasswordController.text.length >= 8 &&
        _registerPasswordController.text == _registerConfirmPasswordController.text;
  }

  bool _isValidEmail(String email) {
    email = email.trim();
    return email.contains('@') && email.contains('.');
  }

  // --- Actions ---

  Future<void> _handleLogin() async {
    if (!_isLoginValid) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text,
      );
      // Navigation handled by main.dart router listener
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Login error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRegister() async {
    if (!_isRegisterValid) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: _registerEmailController.text.trim(),
        password: _registerPasswordController.text,
      );

      if (response.session != null) {
        // Success & Signed In (Email Confirm is OFF)
        // Router will handle navigation
      } else if (response.user != null) {
        // User created but no session? Unexpected if confirm is off.
        if (mounted) {
          setState(() {
            _errorMessage = 'Registration successful, but session was not created. Please try logging in.';
            _tabController.animateTo(0); // Switch to login tab
          });
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Registration error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- UI Builders ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trader AI Tutor Log In'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Login'),
            Tab(text: 'Register'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLoginForm(),
          _buildRegisterForm(),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _loginEmailController,
            decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _loginPasswordController,
            decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
            obscureText: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          if (_errorMessage != null) ...[
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
          ],
          FilledButton(
            onPressed: (_isLoading || !_isLoginValid) ? null : _handleLogin,
            child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _registerEmailController,
            decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _registerPasswordController,
            decoration: const InputDecoration(labelText: 'Password (min 8 chars)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
            obscureText: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _registerConfirmPasswordController,
            decoration: const InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock_outline)),
            obscureText: true,
             onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          if (_errorMessage != null) ...[
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
          ],
          FilledButton(
            onPressed: (_isLoading || !_isRegisterValid) ? null : _handleRegister,
            child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Register'),
          ),
        ],
      ),
    );
  }
}
