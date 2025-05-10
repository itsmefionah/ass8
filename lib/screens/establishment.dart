import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/screens/establishment_edit.dart';
import 'package:firebase/screens/establishment_visitors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:quickalert/quickalert.dart';

class EstablishmentScreen extends StatefulWidget {
  EstablishmentScreen({super.key, required this.uid});
  String uid;
  @override
  State<EstablishmentScreen> createState() => _EstablishmentScreenState();
}

class _EstablishmentScreenState extends State<EstablishmentScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance
              .collection('establishments')
              .doc(widget.uid)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == null) {
          return Text("No Data Available!");
        }
        DocumentSnapshot est = snapshot.data!;
        return Scaffold(
          drawer: Drawer(
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.amberAccent),
                  padding: const EdgeInsets.only(top: 40, bottom: 25),
                  width: double.infinity,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.black87,
                          child: Icon(
                            Icons.business,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "${est['firstname']} ${est['lastname']}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "${est['email']}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EditEstsblishment(est: est),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.edit,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text("Edit Profile"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.group),
                        title: const Text("Go To Visitors"),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => VisitorsScreen(uid: widget.uid),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          appBar: AppBar(
            backgroundColor: Colors.amberAccent,
            foregroundColor: Colors.black,
            title: Text(est['establishment']),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => TraceApp()),
                    (route) => false,
                  );
                },
                icon: Icon(Icons.logout),
              ),
            ],
          ),
          body: Center(
            child: SizedBox(
              width: 190,
              child: ElevatedButton(
                onPressed: () async {
                  String text = await FlutterBarcodeScanner.scanBarcode(
                    '',
                    'Cancel',
                    true,
                    ScanMode.DEFAULT,
                  );
                  print('${text}HIHIHI');
                  DocumentSnapshot user =
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(text)
                          .get();
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.loading,
                    barrierDismissible: false,
                  );
                  try {
                    if (user.exists) {
                      QuerySnapshot data =
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.id)
                              .collection('visits')
                              .orderBy('timein', descending: true)
                              .limit(1)
                              .get();

                      if (data.docs.isEmpty ||
                          data.docs.first['timeout'] != null) {
                        await FirebaseFirestore.instance
                            .collection('establishments')
                            .doc(widget.uid)
                            .collection('visitors')
                            .add({
                              'timein': DateTime.now(),
                              'timeout': null,
                              'clientId': user.id,
                            });
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.id)
                            .collection('visits')
                            .add({
                              'timein': DateTime.now(),
                              'timeout': null,
                              'establishmentId': widget.uid,
                            });
                        Navigator.of(context).pop();

                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.confirm,
                          text:
                              "${user['firstname']} ${user['middlename'][0]}. ${user['lastname']} can now enter the establishment!",
                          title: "Scan success!",
                        );
                      } else {
                        QuerySnapshot latestEst =
                            await FirebaseFirestore.instance
                                .collection('establishments')
                                .doc(widget.uid)
                                .collection('visitors')
                                .orderBy('timein', descending: true)
                                .limit(1)
                                .get();

                        QuerySnapshot latestCli =
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.id)
                                .collection('visits')
                                .orderBy('timein', descending: true)
                                .limit(1)
                                .get();
                        latestCli.docs.first.reference.update({
                          'timeout': DateTime.now(),
                        });

                        latestEst.docs.first.reference.update({
                          'timeout': DateTime.now(),
                        });

                        Navigator.of(context).pop();
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.confirm,
                          text:
                              "${user['firstname']} ${user['middlename'][0]}. ${user['lastname']} can now leave the establishment!",
                          title: "Scan success!",
                        );
                      }
                    } else {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.error,
                        text: "User doesn't exist!",
                        title: "Something went wrong!",
                      );
                    }
                  } on FirebaseException catch (e) {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: "Something went wrong",
                      text: e.message,
                    );
                  } catch (ex) {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: "Something went wrong",
                      text: ex.toString(),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "SCAN CLIENT CODE",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
