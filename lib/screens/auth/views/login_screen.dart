import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop/services/auth_service.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      // Use AuthService for login (auto-creates Firestore doc if missing)
      final user = await AuthService().login(
        emailController.text.trim(), 
        passwordController.text.trim()
      );

      if (!mounted) return;

      if (user != null) {
        // Fetch user data from Firestore to check role
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
            
        final userData = userDoc.data();
        final isAdmin = userData?['role'] == 'admin' || userData?['isAdmin'] == true;

        if (isAdmin) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            adminDashboardScreenRoute,
            (route) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            entryPointScreenRoute,
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String msg = "Login failed";

      if (e.code == 'user-not-found') {
        msg = "Email tidak ditemukan";
      } else if (e.code == 'wrong-password') {
        msg = "Password salah";
      } else if (e.code == 'invalid-email') {
        msg = "Email tidak valid";
      } else if (e.code == 'user-disabled') {
        msg = "Akun ini telah dinonaktifkan";
      } else if (e.code == 'too-many-requests') {
        msg = "Terlalu banyak percobaan. Coba lagi nanti.";
      } else {
        msg = e.message ?? "Login gagal. ${e.code}";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: errorColor, 
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

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              "assets/images/login.jpg",
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back!",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "Log in with your registered email & password.",
                  ),
                  const SizedBox(height: defaultPadding),

                  // ====================== FORM ======================
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Masukkan email";
                            }
                            if (!val.contains('@')) {
                              return "Email tidak valid";
                            }
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
                            if (val == null || val.isEmpty) {
                              return "Masukkan password";
                            }
                            if (val.length < 6) {
                              return "Password minimal 6 karakter";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: defaultPadding),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      child: const Text("Forgot password?"),
                      onPressed: () {
                        Navigator.pushNamed(context, passwordRecoveryScreenRoute);
                      },
                    ),
                  ),

                  SizedBox(
                    height: size.height > 700
                        ? size.height * 0.05
                        : defaultPadding,
                  ),

                  // ====================== LOGIN BUTTON ======================
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loading ? null : login,
                      child: loading
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : const Text("Log in"),
                    ),
                  ),

                  const SizedBox(height: defaultPadding / 2),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, signUpScreenRoute); // pakai route constants
                        },
                        child: const Text("Sign up"),
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
