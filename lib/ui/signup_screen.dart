import 'package:e_commerce_app/Core/models/screen_config.dart';
import 'package:e_commerce_app/services/auth_service.dart';
import 'package:e_commerce_app/ui/login_screen.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  //auth instance
  final AuthService _auth = AuthService();
  String emailInput = '';
  String passwordInput = '';
  String nameInput = '';
  String role = '';
  bool _isHidden = true;
  bool _isLoading = false;

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
    final response = await _auth.signeUp(
      email: emailInput,
      password: passwordInput,
      name: nameInput,
      role: role,
    );
    setState(() {
      _isLoading = false;
    });
    if (response != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response)));
      return;
    }
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('login now you registred')));

    // ignore: avoid_print
    print("Email: $emailInput \n Password: $passwordInput");
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
                Image.asset('assets/images/categorie/sign-in.png'),
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
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Name",
                          border: OutlineInputBorder(),
                        ),
                        validator: (name) {
                          if (name == null || name.isEmpty) {
                            return 'name is required';
                          }
                          return null;
                        },
                        onSaved: (newName) {
                          nameInput = newName!;
                        },
                      ),
                      SizedBox(height: height * 0.01),
                      //user role
                      DropdownButtonFormField(
                        decoration: InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(),
                        ),
                        items: ['User', 'Admin']
                            .map(
                              (role) => DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              ),
                            )
                            .toList(),
                        onChanged: (role) {},
                        validator: (value) {
                          if (value == null) {
                            return 'select your role';
                          }
                          return null;
                        },
                        onSaved: (newrole) {
                          role = newrole!;
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
                            return 'Please enter your password';
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
                              : const Text("signup"),
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      Row(
                        children: [
                          const Text(
                            "Alreday have a account?",
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(width: 5),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => LoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Login here",
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
