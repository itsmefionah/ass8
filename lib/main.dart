import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/firebase_options.dart';
import 'package:firebase/screens/client.dart';
import 'package:firebase/screens/establishment.dart';
import 'package:firebase/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(TraceApp());
}

class TraceApp extends StatelessWidget {
  const TraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          if (snapshot.data != null) {
            print("${snapshot.data} here is the data");
            var uid = snapshot.data?.uid ?? "";
            print(uid + "UID HERE");
            return FutureBuilder(
              future:
                  FirebaseFirestore.instance.collection('users').doc(uid).get(),
              builder: (context, docSnapshot) {
                if (docSnapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                var data = docSnapshot.data;
                if (data!.data() != null) {
                  return ClientScreen(uid: uid);
                } else {
                  return EstablishmentScreen(uid: uid);
                }
              },
            );
          } else {
            return HomeScreen();
          }
        },
      ),
    );
  }
}
