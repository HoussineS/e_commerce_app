import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/Core/provider/favorite_provider.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/controller/carts_provider.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/ui/Order/order_ui.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/ui/Payment/payment_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfile extends ConsumerStatefulWidget {
  const UserProfile({super.key});

  @override
  ConsumerState<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends ConsumerState<UserProfile> {
  final FirebaseAuth _authService = FirebaseAuth.instance;
  final userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: double.maxFinite,
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Center(
                        child: const Text(
                          'Sorry technical error try again later😅!',
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Eror on listing to user ${snapshot.error}',
                        ),
                      );
                    }
                    final user = snapshot.data!;
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage(
                            'assets/images/user_avatar.png',
                          ),
                        ),
                        Text(
                          user['name'],
                          style: const TextStyle(
                            fontSize: 20,
                            height: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user['email'],
                          style: const TextStyle(
                            color: Colors.black,
                            height: 0.5,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Divider(),
              GestureDetector(
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => OrderUi()));
                },
                child: ListTile(
                  leading: Icon(Icons.change_circle_rounded, size: 30),
                  title: Text(
                    'Orders',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PaymentUi()),
                  );
                },
                child: ListTile(
                  leading: Icon(Icons.payment, size: 30),
                  title: Text(
                    'Payment methode',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              GestureDetector(
                child: ListTile(
                  leading: Icon(Icons.info, size: 30),
                  title: Text(
                    'About Us',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.red),
                          SizedBox(width: 8),
                          Text("Confirm Logout"),
                        ],
                      ),
                      content: const Text(
                        "Are you sure you want to log out?",
                        style: TextStyle(fontSize: 16),
                      ),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(); // close dialog
                            _authService.signOut();
                            ref.invalidate(cartsProvider);
                            ref.invalidate(favProvider);
                          },
                          child: const Text("Yes, logout"),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(); // just close
                          },
                          child: const Text("No, stay logged in"),
                        ),
                      ],
                    ),
                  );
                },
                child: const ListTile(
                  leading: Icon(Icons.logout, size: 30),
                  title: Text(
                    'Log Out',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
