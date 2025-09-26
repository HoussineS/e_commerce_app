import 'package:e_commerce_app/ui/Role_based_login/user/ui/favorite_items.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/ui/user_home.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/ui/Profile/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  int selectedIndex = 0;
  final pages = [UserHome(), FavoriteItems(), UserProfile()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.black45,
        selectedItemColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        currentIndex: selectedIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Iconsax.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Iconsax.heart), label: 'Favorite'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: pages[selectedIndex],
    );
  }
}
