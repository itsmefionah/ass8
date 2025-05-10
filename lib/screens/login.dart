import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase/screens/client.dart';
import 'package:firebase/screens/establishment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  bool hidePassword = true;
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Login",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.amberAccent,
        foregroundColor: Colors.black,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_back.webp'),
            alignment: Alignment.bottomCenter,
            opacity: 0.15,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Please enter your credentials to continue",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      _buildSectionHeader("Account Login"),
                      const SizedBox(height: 20),

                      TextFormField(
                        decoration: setTextDecoration(
                          "Email Address",
                          prefixIcon: Icons.email_outlined,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        controller: emailCtrl,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email address is required";
                          }
                          if (!EmailValidator.validate(value)) {
                            return "Please enter a valid email address";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        decoration: setTextDecoration(
                          "Password",
                          isPassField: true,
                          prefixIcon: Icons.lock_outline,
                        ),
                        obscureText: hidePassword,
                        controller: passCtrl,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password is required";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: doLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amberAccent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "LOGIN",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        const Divider(color: Colors.black, thickness: 1.5),
      ],
    );
  }

  InputDecoration setTextDecoration(
    String label, {
    bool isPassField = false,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.indigo, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade700),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      prefixIcon:
          prefixIcon != null
              ? Icon(prefixIcon, color: Colors.indigo.shade300)
              : null,
      suffixIcon:
          isPassField
              ? IconButton(
                onPressed: () {
                  setState(() {
                    hidePassword = !hidePassword;
                  });
                },
                icon: Icon(
                  hidePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.indigo.shade300,
                ),
              )
              : null,
    );
  }

  void doLogin() async {
    if (!formKey.currentState!.validate()) return;

    try {
      // QuickAlert.show(
      //   context: context,
      //   type: QuickAlertType.loading,
      //   text: "Authenticating...",
      // );

      UserCredential userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailCtrl.text.trim(),
            password: passCtrl.text,
          );

      DocumentSnapshot document =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCred.user!.uid)
              .get();

      if (document.data() != null) {
        // Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ClientScreen(uid: userCred.user!.uid),
          ),
        );
      } else {
        // Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EstablishmentScreen(uid: userCred.user!.uid),
          ),
        );
      }
    } on FirebaseAuthException catch (ex) {
      Navigator.of(context).pop();

      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Login Failed",
        text: ex.message ?? "Incorrect email or password.",
      );
    }
  }
}
