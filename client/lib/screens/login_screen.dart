import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // =================== SUBMIT ===================
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // Firebase Email/Password Login
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Successful!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, '/dashboard');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String errorMessage = 'Login failed';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This account has been disabled';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // =================== INPUT ===================
  Widget _inputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // =================== SOCIAL ICON ===================
  Widget _socialIcon(IconData icon, Color color, bool isSmall) {
    return InkWell(
      onTap: () {},
      child: Container(
        height: isSmall ? 42 : 48,
        width: isSmall ? 42 : 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: FaIcon(icon, color: color, size: isSmall ? 18 : 22),
        ),
      ),
    );
  }

  // =================== UI ===================
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isSmall = size.width < 360;
    final bool isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFE6F4F1),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // ================= HEADER =================
            Container(
              height: isTablet ? size.height * 0.35 : size.height * 0.40,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
              decoration: const BoxDecoration(
                color: Color(0xFF1F8F88),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(
                    "Hello! Login to Get Started",
                    style: TextStyle(
                      fontSize: isTablet ? 42 : (isSmall ? 28 : 36),
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Text(
                  //   "Welcome to GrowTown",
                  //   style: TextStyle(
                  //     color: Colors.white70,
                  //     fontSize: isSmall ? 14 : 16,
                  //   ),
                  // ),
                  const Spacer(),
                ],
              ),
            ),

            // ================= LOGIN CARD =================
            Transform.translate(
              offset: Offset(0, isSmall ? -60 : -80),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: EdgeInsets.all(isSmall ? 20 : 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 25,
                        offset: const Offset(0, 15),
                      )
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F8F88),
                              ),
                            ),
                            const SizedBox(height: 24),

                            _inputField(
                              controller: _emailController,
                              icon: Icons.email_outlined,
                              hint: "Email",
                              validator: (value) {
                                if (value == null || value.isEmpty) return "Enter email";
                                if (!value.contains("@")) return "Enter valid email";
                                return null;
                              },
                            ),

                            const SizedBox(height: 18),

                            _inputField(
                              controller: _passwordController,
                              icon: Icons.lock_outline,
                              hint: "Password",
                              obscure: _obscurePassword,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return "Enter password";
                                if (value.length < 6) return "Minimum 6 characters";
                                return null;
                              },
                            ),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: const Text("Forgot Password",
                                    style: TextStyle(color: Color(0xFF1F8F88))),
                              ),
                            ),

                            SizedBox(
                              height: isSmall ? 48 : 54,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1F8F88),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text("Login",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            ),

                            const SizedBox(height: 22),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _socialIcon(FontAwesomeIcons.google, Colors.red, isSmall),
                                const SizedBox(width: 16),
                                _socialIcon(FontAwesomeIcons.facebookF, Colors.blue, isSmall),
                                const SizedBox(width: 16),
                                _socialIcon(FontAwesomeIcons.linkedinIn, Colors.blueAccent, isSmall),
                              ],
                            ),

                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don’t have an account? "),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/createAccount');
                                  },
                                  child: const Text("Sign Up",
                                      style: TextStyle(
                                          color: Color(0xFF1F8F88),
                                          fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
