import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';

class Registerclient extends StatefulWidget {
  const Registerclient({super.key});

  @override
  State<Registerclient> createState() => _RegisterclientState();
}

class _RegisterclientState extends State<Registerclient> {
  final formKey = GlobalKey<FormState>();

  bool hidePassword = true;

  final fnCtrl = TextEditingController();
  final mnCtrl = TextEditingController();
  final lnCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final birthdateCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final cnfCtrl = TextEditingController();
  DateTime? bdate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Client Registration",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.amberAccent,
        foregroundColor: Colors.black,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            alignment: Alignment.bottomCenter,
            opacity: 0.15,
          ),
        ),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Text(
                      "Please complete the form below to register as a client",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              _buildSectionHeader("Personal Information"),
              SizedBox(height: 15),

              TextFormField(
                decoration: setTextDecoration("First Name"),
                controller: fnCtrl,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "First name is required";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              TextFormField(
                decoration: setTextDecoration("Middle Name"),
                controller: mnCtrl,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Middle name is required";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              TextFormField(
                decoration: setTextDecoration("Last Name"),
                controller: lnCtrl,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Last name is required";
                  }
                  return null;
                },
              ),

              SizedBox(height: 30),

              _buildSectionHeader("Contact Details"),
              SizedBox(height: 15),

              TextFormField(
                decoration: setTextDecoration("Address"),
                controller: addressCtrl,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Address is required";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              TextFormField(
                decoration: setTextDecoration(
                  "Birthdate",
                  suffixIcon: Icons.calendar_month,
                ),
                controller: birthdateCtrl,
                readOnly: true,
                onTap: () async {
                  bdate = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (bdate != null) {
                    birthdateCtrl.text = DateFormat(
                      'MMMM d, yyyy',
                    ).format(bdate!);
                    setState(() {});
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Birthdate is required";
                  }
                  return null;
                },
              ),

              SizedBox(height: 30),
              _buildSectionHeader("Account Credentials"),
              SizedBox(height: 15),

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
              SizedBox(height: 15),

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
                  if (value.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              TextFormField(
                controller: cnfCtrl,
                decoration: setTextDecoration(
                  "Confirm Password",
                  isPassField: true,
                  prefixIcon: Icons.lock_outline,
                ),
                obscureText: hidePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please confirm your password";
                  }
                  if (value != passCtrl.text) {
                    return "Passwords don't match";
                  }
                  return null;
                },
              ),

              SizedBox(height: 30),
              ElevatedButton(
                onPressed: doRegister,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    "REGISTER ACCOUNT",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 5),
        Divider(color: Colors.black, thickness: 1.5),
      ],
    );
  }

  InputDecoration setTextDecoration(
    String label, {
    bool isPassField = false,
    IconData? prefixIcon,
    IconData? suffixIcon,
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
        borderSide: BorderSide(color: Colors.red, width: 1),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade700),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      prefixIcon:
          prefixIcon != null
              ? Icon(prefixIcon, color: Colors.indigo.shade300)
              : null,
      suffixIcon:
          isPassField
              ? IconButton(
                onPressed: () {
                  hidePassword = !hidePassword;
                  setState(() {});
                },
                icon: Icon(
                  hidePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.indigo.shade300,
                ),
              )
              : suffixIcon != null
              ? Icon(suffixIcon, color: Colors.indigo.shade300)
              : null,
    );
  }

  void doRegister() {
    if (!formKey.currentState!.validate()) return;

    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: "Confirm Registration",
      text: "Are you sure you want to register as a client?",
      confirmBtnText: "Yes",
      cancelBtnText: "Cancel",
      confirmBtnColor: Colors.indigo,
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        registerClient();
      },
    );
  }

  void registerClient() async {
    try {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        text: "Processing your registration...",
      );
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailCtrl.text,
            password: passCtrl.text,
          );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCred.user!.uid)
          .set({
            'firstname': fnCtrl.text,
            'middlename': mnCtrl.text,
            'lastname': lnCtrl.text,
            'address': addressCtrl.text,
            'birthdate': bdate,
            'email': emailCtrl.text,
            'createdAt': FieldValue.serverTimestamp(),
          });

      await QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Registration Successful",
        text: "Your account has been created successfully!",
        barrierDismissible: false,
      );

      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => LoginScreen()));
    } on FirebaseAuthException catch (ex) {
      Navigator.of(context).pop();
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Registration Failed",
        text: ex.message ?? "An error occurred during registration",
      );
      print(ex);
    }
  }
}
