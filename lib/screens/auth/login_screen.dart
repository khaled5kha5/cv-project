import 'package:cv_project1/screens/auth/register_screen.dart';
import 'package:cv_project1/services/auth_service.dart';
import 'package:flutter/material.dart';


class LoginScreen extends StatefulWidget {
  
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {

  // Instance of AuthService to handle authentication
  final AuthService _authService = AuthService();

  // Key for form validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for email and password fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // For toggling password visibility
  bool _isPasswordVisible = false;

  // For showing loading indicator during login
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                SizedBox(height: 120,),

                // Title
                const Text('Welcome Back!', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('login to continue',textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 60),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration:  InputDecoration(
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
                  }
                ),
                const SizedBox(height: 16),

                

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  // Use visible password type to allow toggling visibility
                  keyboardType: TextInputType.visiblePassword,
                  decoration:  InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    // Toggle password visibility
                    suffixIcon: IconButton(
                      icon: Icon(
                        // Change icon based on visibility state
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(),
                    
                  ),
                  // Use the visibility state to determine if the text should be obscured
                  obscureText: !_isPasswordVisible,
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
                const SizedBox(height: 35),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    // Show loading indicator on button when logging in
                    child: 
                    // If loading, show CircularProgressIndicator, otherwise show 'Login' text
                    isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Login'),
                ),
                ),


                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),

                // Navigate to RegisterScreen when tapped
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text('Create new account'),
                )
              ],
            ),
           ]
           )
          ),
        ),
        )
    );
  }

  // Method to handle login logic
  Future<void> _login() async {
      if (!_formKey.currentState!.validate()) {
        return;
      }
        setState(() => isLoading = true);
        // If form is not valid, show error message and return
    try {
      await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
    finally {
    setState(() => isLoading = false);
    }
  
  }
}
