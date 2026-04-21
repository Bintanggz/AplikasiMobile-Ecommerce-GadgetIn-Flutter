// lib/screens/auth/views/components/login_form.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../constants.dart';
import 'package:shop/route/route_constants.dart';

class LogInForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const LogInForm({super.key, required this.formKey});

  @override
  State<LogInForm> createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
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
                await FirebaseAuth.instance.signInWithEmailAndPassword(
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
                  SnackBar(content: Text(e.message ?? "Login failed")),
                );
              }

              setState(() => loading = false);
            },
            child: loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Log In"),
          ),
        ],
      ),
    );
  }
}
