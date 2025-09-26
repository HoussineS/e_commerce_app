// ignore_for_file: use_build_context_synchronously

import 'package:e_commerce_app/Core/models/screen_config.dart';
import 'package:e_commerce_app/services/auth_service.dart';
import 'package:e_commerce_app/ui/Role_based_login/admin/ui/admin_main_screen.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/ui/user_main_screen.dart';
import 'package:e_commerce_app/ui/signup_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String emailInput = '';
  String passwordInput = '';
  bool _isHidden = true;
  bool _isLoading = false;

  // auth instance
  final AuthService _auth = AuthService();

  Future<void> _submit() async {
    //check if is input is validate
    if (!_formkey.currentState!.validate()) {
      //do nothink
      return;
    }
    _formkey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    final response = await _auth.login(
      email: emailInput,
      password: passwordInput,
    );
    setState(() {
      _isLoading = false;
    });
    if (response == 'Admin') {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const AdminMainScreen()));
    } else if (response == 'User') {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const UserMainScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response!), duration: Duration(seconds: 3)),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = ScreenConfig.screenHeight;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Image.asset('assets/images/categorie/user-login.jpg'),
                SizedBox(height: height * 0.01),
                Form(
                  key: _formkey,
                  child: Column(
                    children: [
                      //email input
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                        ),
                        validator: (email) {
                          if (email == null || email.isEmpty) {
                            return 'Please enter your email';
                          }

                          // Simple regex for email validation
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (!emailRegex.hasMatch(email)) {
                            return 'Enter a valid email address';
                          }

                          return null;
                        },
                        onSaved: (newEmail) {
                          emailInput = newEmail!;
                        },
                      ),
                      SizedBox(height: height * 0.01),
                      //password input
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isHidden = !_isHidden;
                              });
                            },
                            icon: Icon(
                              _isHidden
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        obscureText: _isHidden,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }

                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }

                          return null;
                        },
                        onSaved: (password) {
                          passwordInput = password!;
                        },
                      ),
                      //login button
                      SizedBox(height: height * 0.015),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: _isLoading
                              ? CircularProgressIndicator()
                              : Text("login"),
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      Row(
                        children: [
                          const Text(
                            "Don't have a account?",
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(width: 5),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => SignupScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Sign up here",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                letterSpacing: -1,
                              ),
                            ),
                          ),
                        ],
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
}
