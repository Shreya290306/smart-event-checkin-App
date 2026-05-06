import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/user_model.dart';
import '../providers/app_state.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  UserRole _selectedRole = UserRole.admin;

  void _login() {
    if (_idController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID is required')));
      return;
    }

    final user = UserModel(
      id: _idController.text.trim(),
      name: _nameController.text.trim().isEmpty ? 'User' : _nameController.text.trim(),
      role: _selectedRole,
    );

    ref.read(currentUserProvider.notifier).state = user;
    
    if (_selectedRole == UserRole.admin) {
      context.go('/');
    } else {
      context.go('/student');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 12,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(LucideIcons.calendarCheck, size: 64, color: Color(0xFF6C63FF)),
                  const SizedBox(height: 16),
                  Text(
                    'Smart Check-in',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.black87),
                  ),
                  const SizedBox(height: 32),
                  SegmentedButton<UserRole>(
                    segments: const [
                      ButtonSegment(value: UserRole.admin, label: Text('Admin'), icon: Icon(LucideIcons.shield)),
                      ButtonSegment(value: UserRole.student, label: Text('Student'), icon: Icon(LucideIcons.graduationCap)),
                    ],
                    selected: {_selectedRole},
                    onSelectionChanged: (Set<UserRole> newSelection) {
                      setState(() => _selectedRole = newSelection.first);
                    },
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _idController,
                    decoration: const InputDecoration(labelText: 'User ID', prefixIcon: Icon(LucideIcons.hash)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name (Optional)', prefixIcon: Icon(LucideIcons.user)),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
