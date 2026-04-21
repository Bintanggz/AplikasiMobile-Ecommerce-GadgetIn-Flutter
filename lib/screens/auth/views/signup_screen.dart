import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../constants.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  final AuthService _authService = AuthService();
  bool loading = false;
  bool agree = false;

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Setujui Terms & Privacy dulu")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      // Gunakan AuthService.register() yang sudah otomatis set role sebagai 'user'
      final name = nameController.text.trim().isEmpty 
          ? emailController.text.trim().split('@')[0] 
          : nameController.text.trim();
      
      await _authService.register(
        emailController.text.trim(),
        passwordController.text.trim(),
        name,
      );

      if (!mounted) return;

      // Navigasi ke entry point menggunakan route constants
      Navigator.pushNamedAndRemoveUntil(
        context,
        entryPointScreenRoute,
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String msg = "Gagal membuat akun";

      if (e.code == 'email-already-in-use') {
        msg = "Email '${emailController.text.trim()}' sudah terdaftar. Silakan login atau gunakan email lain.";
      } else if (e.code == 'invalid-email') {
        msg = "Email tidak valid";
      } else if (e.code == 'weak-password') {
        msg = "Password terlalu lemah. Minimal 6 karakter.";
      } else {
        msg = e.message ?? "Gagal membuat akun. ${e.code}";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: errorColor,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Terms & Privacy Policy"),
        content: const SingleChildScrollView(
          child: Text(
            "Ini adalah contoh Syarat dan Ketentuan layanan.\n\n"
            "1. Pengguna wajib memberikan data yang benar.\n"
            "2. Kami menjaga privasi data Anda sesuai kebijakan privasi.\n"
            "3. Dilarang melakukan tindakan ilegal menggunakan aplikasi ini.\n\n"
            "Dengan mendaftar, Anda menyetujui semua ketentuan di atas.",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=1200&q=80",
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.smartphone, size: 64, color: Colors.grey),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Let’s get started!",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "Create your new account below.",
                  ),
                  const SizedBox(height: defaultPadding),

                  // ======================
                  // FORM
                  // ======================
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Name
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: "Nama Lengkap",
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Masukkan nama";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        // Email
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return "Masukkan email";
                            if (!val.contains("@")) return "Email tidak valid";
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // Password
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Password",
                            prefixIcon: Icon(Icons.lock),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return "Masukkan password";
                            if (val.length < 6) return "Minimal 6 karakter";
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // Confirm Password
                        TextFormField(
                          controller: confirmController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Confirm Password",
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          validator: (val) {
                            if (val != passwordController.text) {
                              return "Password tidak sama";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: defaultPadding),

                  // ======================
                  // TERMS CHECKBOX
                  // ======================
                  Row(
                    children: [
                      Checkbox(
                        value: agree,
                        onChanged: (v) => setState(() => agree = v ?? false),
                      ),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: "I agree with the",
                            children: [
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _showTermsDialog,
                                text: " Terms of service ",
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const TextSpan(
                                text: "& privacy policy.",
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: defaultPadding * 2),

                  // ======================
                  // BUTTON SIGN UP
                  // ======================
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loading ? null : signUp,
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Continue"),
                    ),
                  ),

                  const SizedBox(height: defaultPadding / 2),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Do you have an account?"),
                      TextButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushNamed(context, logInScreenRoute);
                          }
                        },
                        child: const Text("Log in"),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
