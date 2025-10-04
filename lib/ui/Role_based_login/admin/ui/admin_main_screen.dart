// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/ui/Role_based_login/admin/controller/add_item_controller.dart';
import 'package:e_commerce_app/ui/Role_based_login/admin/ui/add_items.dart';
import 'package:e_commerce_app/ui/Role_based_login/admin/ui/orders_screens.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/controller/carts_provider.dart';
import 'package:e_commerce_app/ui/login_screen.dart';
import 'package:e_commerce_app/widget/item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _auth = FirebaseAuth.instance;

class AdminMainScreen extends ConsumerStatefulWidget {
  const AdminMainScreen({super.key});

  @override
  ConsumerState<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends ConsumerState<AdminMainScreen> {
  final userId = _auth.currentUser!.uid;
  final items = FirebaseFirestore.instance.collection('items');
  String? selectedCategorie;
  List<String> categories = ['All'];

  @override
  void initState() {
    fetchCategories();
    super.initState();
  }

  Future<void> fetchCategories() async {
    try {
      print('fetching categories...');
      final snapshot = await Supabase.instance.client.from('category').select();

      setState(() {
        categories = [
          'All',
          ...snapshot.map((categ) => categ['name'] as String),
        ];
      });
      print('Complete fetching categorie fetching categories...');
      print(categories);
    } catch (e) {
      print('❌ erro on fetcheing categorie $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload it items'),
        backgroundColor: Colors.blueAccent,
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => OrdersScreens()));
                },
                icon: Icon(Icons.receipt_long, color: Colors.black),
              ),
              Positioned(
                top: 5,
                right: 8,
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collectionGroup('orders')
                      .snapshots(),
                  builder: (context, asyncSnapshot) {
                    if (!asyncSnapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    int numbreOfOrders = asyncSnapshot.data!.docs.length;
                    return CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 9,
                      child: Center(
                        child: Text(
                          '$numbreOfOrders',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(width: 5),
          DropdownButton(
            items: categories.map((categ) {
              return DropdownMenuItem(
                value: categ,
                child: Text(categ, style: TextStyle(color: Colors.black)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                if (value == 'All') {
                  selectedCategorie = null;
                  return;
                }
                selectedCategorie = value;
              });
            },
            icon: Icon(Icons.tune, color: Colors.black),
          ),
          SizedBox(width: 10),
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              ref.invalidate(cartsProvider);
              ref.invalidate(addItemProvier);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
            icon: Icon(Icons.logout, color: Colors.black),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: items
              .where('uploadedBy', isEqualTo: userId)
              .where('category', isEqualTo: selectedCategorie)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Center(child: Text('Server error try again later'));
            }
            if (snapshot.hasData) {
              final data = snapshot.data!.docs;
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final itemData = data[index];
                  return Item(
                    name: itemData['name'],
                    imageUrl: itemData['imageUrl'],
                    price: itemData['price'],
                    category: itemData['category'],
                  );
                },
              );
            }
            return Center(child: Text('No uploaded item yet!'));
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => AddItems()));
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
