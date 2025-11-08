import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    // Guard State before using context
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: Center(
        child: user == null
            ? const Text('No user logged in.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Welcome, ${user!.email}',
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 16),
                  Text('UID: ${user!.uid}'),
                ],
              ),
      ),
    );
  }
}
