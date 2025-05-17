import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:we_chat/screens/main_screen.dart';
import '../../helper/dialogs.dart';
import '../home_screen.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) => const AuthForm(isLogin: true);
}

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});
  @override
  Widget build(BuildContext context) => const AuthForm(isLogin: false);
}

class AuthForm extends StatefulWidget {
  final bool isLogin;
  const AuthForm({super.key, required this.isLogin});
  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _submit() async {
    Dialogs.showLoading(context);
    try {
      if (widget.isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pop(context);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const MainScreen()));
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      Dialogs.showSnackbar(context, e.message ?? 'Something went wrong.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = widget.isLogin;

    return Scaffold(
      backgroundColor: const Color(0xfff0f4ff),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/icon.png', height: 100),
                const SizedBox(height: 30),
                Text(
                  isLogin ? 'Welcome Back 👋' : 'Create Your Account 👤',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 30),
                _buildTextField(
                  controller: _emailController,
                  hint: 'Email',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _passwordController,
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  obscure: true,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.deepPurple,
                    elevation: 6,
                    shadowColor: Colors.deepPurpleAccent.withOpacity(0.4),
                  ),
                  child: Text(
                    isLogin ? 'Login' : 'Sign Up',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => isLogin
                            ? const SignUpScreen()
                            : const LoginScreen(),
                      ),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: isLogin
                          ? "Don't have an account? "
                          : "Already have an account? ",
                      style: const TextStyle(
                          color: Colors.black87, fontSize: 14),
                      children: [
                        TextSpan(
                          text: isLogin ? 'Sign Up' : 'Login',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}

