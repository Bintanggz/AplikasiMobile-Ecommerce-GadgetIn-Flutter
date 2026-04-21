// lib/screens/auth/views/components/sign_up_form.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../constants.dart';
import 'package:shop/route/route_constants.dart';

class SignUpForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const SignUpForm({super.key, required this.formKey});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _username = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _username,
            validator: (value) =>
            value == null || value.isEmpty ? "Username is required" : null,
            decoration: const InputDecoration(
              hintText: "Username",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            controller: _email,
            validator: emaildValidator.call,
            decoration: const InputDecoration(
              hintText: "Email address",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            controller: _password,
            validator: passwordValidator.call,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: "Password",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: defaultPadding),
          ElevatedButton(
            onPressed: loading
                ? null
                : () async {
              if (!widget.formKey.currentState!.validate()) return;
              setState(() => loading = true);

              try {
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: _email.text.trim(),
                  password: _password.text.trim(),
                );

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  entryPointScreenRoute,
                      (route) => false,
                );
              } on FirebaseAuthException catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.message ?? "Sign up failed")),
                );
              }

              setState(() => loading = false);
            },
            child: loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Sign Up"),
          ),
        ],
      ),
    );
  }
}
