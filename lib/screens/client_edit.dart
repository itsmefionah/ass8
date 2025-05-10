import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class EditClient extends StatefulWidget {
  EditClient({super.key, required this.user});
  DocumentSnapshot user;
  @override
  State<EditClient> createState() => _EditClientState();
}

class _EditClientState extends State<EditClient> {
  var fnCtrl = TextEditingController();
  var lnCtrl = TextEditingController();
  var mnCtrl = TextEditingController();
  var addressCtrl = TextEditingController();
  var birthdateCtrl = TextEditingController();
  var emailCtrl = TextEditingController();

  DateTime? bdate;

  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fnCtrl.text = widget.user['firstname'];
    mnCtrl.text = widget.user['middlename'];
    lnCtrl.text = widget.user['lastname'];
    addressCtrl.text = widget.user['address'];
    birthdateCtrl.text = DateFormat().add_yMMMMd().format(
      widget.user['birthdate'].toDate(),
    );
    bdate = widget.user['birthdate'].toDate();
    emailCtrl.text = widget.user['email'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.amberAccent,
        foregroundColor: Colors.black87,
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
              const SizedBox(height: 16),
              buildTextField("Address", addressCtrl),
              const SizedBox(height: 16),

              TextFormField(
                readOnly: true,
                controller: birthdateCtrl,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: "Birthdate",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: bdate!,
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          bdate = picked;
                          birthdateCtrl.text = DateFormat.yMMMMd().format(
                            picked,
                          );
                        });
                      }
                    },
                  ),
                ),
                validator:
                    (value) =>
                        (value == null || value.isEmpty) ? "*Required!" : null,
              ),
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
        editClient();
      },
    );
  }

  void editClient() async {
    try {
      // QuickAlert.show(
      //   context: context,
      //   type: QuickAlertType.loading,
      //   text: "Please Wait",
      // );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.id)
          .update({
            'firstname': fnCtrl.text,
            'middlename': mnCtrl.text,
            'lastname': lnCtrl.text,
            'address': addressCtrl.text,
            'birthdate': bdate,
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
