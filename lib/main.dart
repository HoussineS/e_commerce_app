import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/Core/models/screen_config.dart';
import 'package:e_commerce_app/ui/Role_based_login/admin/ui/admin_main_screen.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/ui/user_main_screen.dart';

import 'package:e_commerce_app/ui/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final supaBaseUrl = dotenv.env['SUPABASE_URL'];
  final supaBaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
  await Firebase.initializeApp();
  await Supabase.initialize(url: supaBaseUrl!, anonKey: supaBaseAnonKey!);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ScreenConfig.init(context);
    return ProviderScope(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const AuthentificationHandler(),
      ),
    );
  }
}

class AuthentificationHandler extends StatefulWidget {
  const AuthentificationHandler({super.key});

  @override
  State<AuthentificationHandler> createState() =>
      _AuthentificationHandlerState();
}

class _AuthentificationHandlerState extends State<AuthentificationHandler> {
  User? currentUser;
  String? userRole;
  StreamSubscription<User?>? _authSubscription;
  @override
  void initState() {
    super.initState();
    _initHandlerAuth();
  }

  @override
  void dispose() {
    _authSubscription!.cancel();
    super.dispose();
  }

  void _initHandlerAuth() async {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      user,
    ) async {
      if (!mounted) {
        return;
      }
      setState(() {
        currentUser = user;
      });

      if (currentUser != null) {
        final docData = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get();
        if (!mounted) return;

        if (docData.exists) {
          // print("😒 user roleee  ${docData['role']}");
          setState(() {
            userRole = docData['role'];
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return LoginScreen();
    } else {
      if (userRole == null) {
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      } else if (userRole == 'Admin') {
        return AdminMainScreen();
      }
      return UserMainScreen();
    }
  }
}
