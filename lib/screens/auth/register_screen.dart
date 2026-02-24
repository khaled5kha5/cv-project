import 'package:cv_project1/providers/auth_provider.dart';
import 'package:cv_project1/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  
  final _firestore = FirestoreService();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
      try {
        await context.read<AuthProvider>().register(
           _emailController.text,
           _passwordController.text,
        );
        await _firestore.addUser(
          uid: context.read<AuthProvider>().uid!,
          email: _emailController.text,
          username: _usernameController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: $e')),
          );
        }
      }
    
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      body:  SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Icon(Icons.app_registration, size: 64, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 20),

                Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join us to continue',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _usernameController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    // Basic username validation
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    // Simple regex for username validation (alphanumeric and underscores, 3-16 characters)
                    if (!RegExp(r'^[a-zA-Z0-9_]{3,16}$').hasMatch(value)) {
                      return 'Please enter a valid username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    // Basic email validation
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    // Simple regex for email validation
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  // Use visible password type to allow toggling visibility
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    // Toggle password visibility
                    suffixIcon: IconButton(
                      icon: Icon(
                        // Change icon based on visibility state
                        authProvider.isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: authProvider.setPasswordVisible,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  // Use the visibility state to determine if the text should be obscured
                  obscureText: !authProvider.isPasswordVisible,
                  validator: (value) {
                    // Basic password validation
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    // Enforce password length and complexity
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    // Optional: enforce maximum length and complexity rules
                    if (value.length > 20) {
                      return 'Password must be less than 20 characters';
                    }
                    // Example complexity rule: at least one uppercase letter
                    if (!RegExp(r'[A-Z]').hasMatch(value)) {
                      return 'Password must contain at least one uppercase letter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  // Use visible password type to allow toggling visibility
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock),
                    // Toggle password visibility
                    suffixIcon: IconButton(
                      icon: Icon(
                        // Change icon based on visibility state
                        authProvider.isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: authProvider.setConfirmPasswordVisible,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  // Use the visibility state to determine if the text should be obscured
                  obscureText: !authProvider.isConfirmPasswordVisible,
                  validator: (value) {
                    // Confirm password validation
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    // Check if passwords match
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 35),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _register,
                    child: authProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign Up', style: TextStyle(fontSize: 16)),
                  ),
                ),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Login'),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}