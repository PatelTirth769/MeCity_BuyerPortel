import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mecity_marketplace/providers/auth_provider.dart';
import 'package:mecity_marketplace/buyer_app/screens/main_navigation_screen.dart';
import 'package:mecity_marketplace/widgets/mecity_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();

  final _regNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPhoneCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  final _regCityCtrl = TextEditingController();

  bool _obscureLoginPass = true;
  bool _obscureRegPass = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _regNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPhoneCtrl.dispose();
    _regPassCtrl.dispose();
    _regCityCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoading) return;

    // AuthProvider notifies listeners as soon as authentication succeeds.
    // That rebuild can dispose this LoginScreen before the awaited call below
    // resumes, so retain the app-level navigation objects up front.
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final email = _loginEmailCtrl.text.trim();
    final password = _loginPassCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid email and password.')),
      );
      return;
    }

    final success = await authProvider.loginUser(
      email: email,
      password: password,
    );

    if (success) {
      final userName = authProvider.user.name.isNotEmpty ? authProvider.user.name : 'User';

      messenger.showSnackBar(
        SnackBar(
          content: Text('Welcome back, $userName! Login successful. 🎉'),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 2),
        ),
      );

      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const BuyerHomePage(),
        ),
        (route) => false,
      );
    } else if (mounted) {
      final errorMsg = authProvider.errorMessage ?? 'Login failed. Please check your credentials.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController(text: _loginEmailCtrl.text.trim());
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.lock_reset, color: Color(0xFFD4AF37)),
                SizedBox(width: 8),
                Text('Reset Password', style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter your registered email address and we will send you a password reset link.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailCtrl,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    labelStyle: const TextStyle(color: Colors.white60),
                    prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFD4AF37)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.of(dialogCtx).pop(),
                child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final email = emailCtrl.text.trim();
                        final emailErr = _validateEmail(email);
                        if (emailErr != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(emailErr), backgroundColor: Colors.red),
                          );
                          return;
                        }

                        setDialogState(() => isSubmitting = true);
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        final success = await authProvider.forgotPassword(email: email);
                        setDialogState(() => isSubmitting = false);

                        if (mounted) {
                          Navigator.of(dialogCtx).pop();
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Password reset link sent to $email! Please check your inbox.'),
                                backgroundColor: const Color(0xFF10B981),
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          } else {
                            final err = authProvider.errorMessage ?? 'Failed to send reset email. User not found.';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(err), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Text('Send Link'),
              ),
            ],
          );
        },
      ),
    );
  }


  String? _validateName(String? value) {
    if (value == null || value.trim().length < 2) {
      return 'Enter a valid full name (at least 2 characters)';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final regex = RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    if (!RegExp(r'^[0-9]{10}$').hasMatch(cleanPhone)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoading) return;

    // Keep these references valid across auth-state rebuilds. A successful
    // automatic login replaces this screen before registerUser can return.
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final name = _regNameCtrl.text.trim();
    final email = _regEmailCtrl.text.trim();
    final phone = _regPhoneCtrl.text.trim().replaceAll(RegExp(r'[^\d]'), '');
    final city = _regCityCtrl.text.trim().isNotEmpty ? _regCityCtrl.text.trim() : 'Gandhinagar';
    final password = _regPassCtrl.text;

    final nameError = _validateName(name);
    if (nameError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(nameError)));
      return;
    }

    final emailError = _validateEmail(email);
    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(emailError)));
      return;
    }

    final phoneError = _validatePhone(phone);
    if (phoneError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(phoneError)));
      return;
    }

    final passError = _validatePassword(password);
    if (passError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(passError)));
      return;
    }

    debugPrint('STEP 1: Create account clicked');
    debugPrint('STEP 2: Request sent');

    final success = await authProvider.registerUser(
      name: name,
      email: email,
      password: password,
      phoneNumber: phone,
      city: city,
    );

    if (success) {
      final createdPersonName = authProvider.user.name.isNotEmpty ? authProvider.user.name : name;

      debugPrint('STEP 6: Authentication state ready');
      debugPrint('STEP 7: Opening Buyer Home');

      messenger.showSnackBar(
        SnackBar(
          content: Text('Welcome $createdPersonName! Account created & signed in. 🎉'),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 2),
        ),
      );

      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const BuyerHomePage(),
        ),
        (route) => false,
      );

      debugPrint('STEP 8: Buyer Home opened');
    } else if (mounted) {
      final errorMsg = authProvider.errorMessage ?? 'Registration failed. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Brand Logo Header
              Center(
                child: Column(
                  children: [
                    const MecityLogo(size: 86),
                    const SizedBox(height: 14),
                    const Text(
                      'mecity',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Multi-Vendor Marketplace • Buyer Portal',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // TabBar Navigation
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFFD4AF37),
                  labelColor: const Color(0xFFD4AF37),
                  unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  tabs: const [
                    Tab(text: 'Sign In'),
                    Tab(text: 'Create Account'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 380,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Login Form
                    Column(
                      children: [
                        TextField(
                          controller: _loginEmailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email / Phone Number',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _loginPassCtrl,
                          obscureText: _obscureLoginPass,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureLoginPass ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscureLoginPass = !_obscureLoginPass),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _showForgotPasswordDialog,
                            child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading ? null : _handleLogin,
                                child: authProvider.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.black,
                                        ),
                                      )
                                    : const Text('Sign In to Account 🚀'),
                              ),
                            );
                          },
                        ),

                      ],
                    ),

                    // Tab 2: Register Form
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            controller: _regNameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Full Name *',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _regEmailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email Address *',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _regPhoneCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Phone Number (10 digits) *',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _regCityCtrl,
                            decoration: const InputDecoration(
                              labelText: 'City *',
                              prefixIcon: Icon(Icons.location_city_outlined),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _regPassCtrl,
                            obscureText: _obscureRegPass,
                            decoration: InputDecoration(
                              labelText: 'Password *',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureRegPass ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscureRegPass = !_obscureRegPass),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: authProvider.isLoading ? null : _handleRegister,
                                  child: authProvider.isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.black,
                                          ),
                                        )
                                      : const Text('Create Buyer Account 👑'),
                                ),
                              );
                            },
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
