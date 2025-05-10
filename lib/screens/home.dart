import 'package:firebase/screens/login.dart';
import 'package:firebase/screens/register_client.dart';
import 'package:firebase/screens/register_establishment.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              alignment: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                textAlign: TextAlign.center,
                "Contact Tracing",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    ),
                child: Text("Login"),
              ),
              Divider(),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => Registerclient()),
                    ),
                child: Text("Register as Client"),
              ),

              ElevatedButton(
                onPressed:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Registerestablishment(),
                      ),
                    ),
                child: Text("Register as Establishment"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
