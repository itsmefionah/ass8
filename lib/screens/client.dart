import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/screens/client_edit.dart';
import 'package:firebase/screens/client_visited.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase/main.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ClientScreen extends StatefulWidget {
  ClientScreen({super.key, required this.uid});
  String uid;

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text("No Data Available!")),
          );
        }
        DocumentSnapshot docSnap = snapshot.data!;

        return Scaffold(
          drawer: Drawer(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(color: Colors.amberAccent),
                  padding: const EdgeInsets.only(top: 40, bottom: 25),
                  width: double.infinity,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.black87,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "${docSnap['firstname']} ${docSnap['middlename'].toString()[0]}. ${docSnap['lastname']}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "${docSnap['email']}",
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
                              builder: (context) => EditClient(user: docSnap),
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
                          padding: EdgeInsets.symmetric(
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
                        leading: const Icon(Icons.history),
                        title: const Text("Visited Establishments"),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => VisitedScreen(uid: widget.uid),
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
            centerTitle: true,
            backgroundColor: Colors.amberAccent,
            title: const Text("Client"),
            actions: [
              IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => TraceApp()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: Center(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.uid)
                      .collection('visits')
                      .orderBy('timein', descending: true)
                      .limit(1)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return const Text("Unable to load visit history.");
                }

                final docSnap = snapshot.data!;
                String statusText = "";
                String instructionText = "";

                if (docSnap.docs.isEmpty ||
                    docSnap.docs.first['timeout'] != null) {
                  statusText = "You are currently not checked in anywhere.";
                  instructionText = "Scan this QR code to check in.";
                } else {
                  statusText = "You are currently checked in.";
                  instructionText = "Scan this QR code to check out.";

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Check-in successful!")),
                    );
                  });
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      statusText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      instructionText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    QrImageView(data: widget.uid),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
