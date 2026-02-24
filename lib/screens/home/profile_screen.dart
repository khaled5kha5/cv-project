import 'package:cv_project1/providers/theme_provider.dart';
import 'package:cv_project1/services/auth_service.dart';
import 'package:cv_project1/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _fireStore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: user == null
          ? _buildSignedOut(context)
          : _buildProfile(context, user),
    );
  }

  Widget _buildSignedOut(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_off_outlined, size: 48),
            const SizedBox(height: 16),
            const Text('You are not signed in.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _authService.signOut(),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, User user) {
    final email = user.email ?? 'No email';
    final avatarText = _initials(email);
    final themeProvider = context.watch<ThemeProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundImage:
                        user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                    child: user.photoURL == null
                        ? Text(
                            avatarText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          email.isNotEmpty == true ? email : 'User',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(email),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Account',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                FutureBuilder<String?>(
                  future: _fireStore.getUserName(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _infoTile('User Name', 'Loading...');
                    } else if (snapshot.hasError) {
                      return _infoTile('User Name', 'Error');
                    } else {
                      return _infoTile('User Name', snapshot.data ?? 'No name');
                    }
                  },
                ),
                _infoTile(
                  'Created',
                  _formatDate(user.metadata.creationTime),
                ),
                _infoTile(
                  'Last Sign-in',
                  _formatDate(user.metadata.lastSignInTime),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Actions',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(
                themeProvider.isDark
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
              ),
              title: const Text('Theme'),
              subtitle: Text(themeProvider.isDark ? 'Dark mode' : 'Light mode'),
              trailing: Switch(
                value: themeProvider.isDark,
                onChanged: (_) => themeProvider.toggle(),
              ),
              onTap: themeProvider.toggle,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: _authService.signOut,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) => ListTile(
        title: Text(label),
        subtitle: Text(value),
      );

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.year}-${_two(date.month)}-${_two(date.day)}';
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  String _initials(String text) {
    final parts = text.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'U';
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    final initials = (first + last).toUpperCase();
    return initials.isEmpty ? 'U' : initials;
  }
}
