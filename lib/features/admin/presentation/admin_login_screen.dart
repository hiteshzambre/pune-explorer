import 'package:flutter/material.dart';
import '../../authentication/presentation/auth_screen.dart';

/// Unified Admin Login Screen that delegates directly to the standard [AuthScreen],
/// ensuring the admin portal uses the exact same login interface as regular users
/// and validates admin credentials directly via Supabase Auth and Database roles.
class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthScreen(redirectPath: '/admin/dashboard');
  }
}

