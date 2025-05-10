import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class EditEstsblishment extends StatefulWidget {
  EditEstsblishment({super.key, required this.est});
  DocumentSnapshot est;

  @override
  State<EditEstsblishment> createState() => _EditEstState();
}

class _EditEstState extends State<EditEstsblishment> {
  var fnCtrl = TextEditingController();
  var lnCtrl = TextEditingController();
  var mnCtrl = TextEditingController();
  var emailCtrl = TextEditingController();
  var businessCtrl = TextEditingController();
  var addressCtrl = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fnCtrl.text = widget.est['firstname'];
    mnCtrl.text = widget.est['middlename'];
    lnCtrl.text = widget.est['lastname'];
    businessCtrl.text = widget.est['establishment'];
    addressCtrl.text = widget.est['address'];
    emailCtrl.text = widget.est['email'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.amberAccent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              const Text(
                "Personal Information",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              buildTextField("First Name", fnCtrl),
              const SizedBox(height: 16),
              buildTextField("Middle Name", mnCtrl),
              const SizedBox(height: 16),
              buildTextField("Last Name", lnCtrl),
              const SizedBox(height: 24),
              const Text(
                "Business Details",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              buildTextField("Establishment Name", businessCtrl),
              const SizedBox(height: 16),
              buildTextField("Address", addressCtrl),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                decoration: buildInputDecoration("Email"),
                keyboardType: TextInputType.emailAddress,
                controller: emailCtrl,
                validator: (value) {
                  if (value == null || value.isEmpty) return "*Required!";
                  if (!EmailValidator.validate(value)) {
                    return "*Invalid Email Format";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save, color: Colors.black),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: doEdit,
                label: const Text(
                  "Save Changes",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      decoration: buildInputDecoration(label),
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "*Required!";
        }
        return null;
      },
    );
  }

  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
      border: const OutlineInputBorder(),
      labelText: label,
    );
  }

  void doEdit() {
    if (!formKey.currentState!.validate()) return;

    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: "Are You Sure",
      confirmBtnText: "Yes",
      cancelBtnText: "No",
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        editEst();
      },
    );
  }

  void editEst() async {
    try {
      // QuickAlert.show(
      //   context: context,
      //   type: QuickAlertType.loading,
      //   text: "Please Wait",
      // );

      await FirebaseFirestore.instance
          .collection('establishments')
          .doc(widget.est.id)
          .update({
            'firstname': fnCtrl.text,
            'middlename': mnCtrl.text,
            'lastname': lnCtrl.text,
            'address': addressCtrl.text,
            'establishment': businessCtrl.text,
          });

      // Navigator.of(context).pop();
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Success",
        text: "Account is updated!",
      );
      // Navigator.of(context).pop();
    } on FirebaseAuthException catch (ex) {
      Navigator.of(context).pop();
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Error",
        text: ex.message,
      );
      print(ex);
    }
  }
}
