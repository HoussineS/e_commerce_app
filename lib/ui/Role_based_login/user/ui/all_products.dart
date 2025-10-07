import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/Core/models/screen_config.dart';
import 'package:e_commerce_app/Core/utils/colors.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/models/app_model.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/widget/category_grid.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AllProducts extends StatefulWidget {
  const AllProducts({super.key});

  @override
  State<AllProducts> createState() => _AllProductsState();
}

class _AllProductsState extends State<AllProducts> {
  final CollectionReference itemCollection = FirebaseFirestore.instance
      .collection('items');

  List<QueryDocumentSnapshot> allItems = [];
  List<QueryDocumentSnapshot> filtredItem = [];
  void _onSearchBarChanged(String userInput) {
    final serchTerm = userInput.toLowerCase();
    setState(() {
      filtredItem = allItems.where((item) {
        final itemData = item.data() as Map<String, dynamic>;
        final itemName = itemData['name'] as String;
        return itemName.toLowerCase().contains(serchTerm);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back_ios_new),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: SizedBox(
                      height: ScreenConfig.screenHeight * 0.04,
                      child: TextField(
                        onChanged: _onSearchBarChanged,
                        decoration: InputDecoration(
                          hintText: "serach for producsts",
                          hintStyle: const TextStyle(color: Colors.black26),
                          filled: true,
                          fillColor: fbackroudColor2,
                          contentPadding: const EdgeInsets.all(5),
                          prefixIcon: Icon(
                            Iconsax.search_normal,
                            color: Colors.black26,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(filterCategory.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text(filterCategory[index]),
                            SizedBox(width: 3),
                            Icon(
                              index == 0
                                  ? Icons.filter_list
                                  : Icons.keyboard_arrow_down,
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            Expanded(
              child: StreamBuilder(
                stream: itemCollection.snapshots(),
                builder: (context, asyncSnapshot) {
                  if (asyncSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (asyncSnapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error on filtred ${asyncSnapshot.error}',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }
                  if (asyncSnapshot.hasData) {
                    final items = asyncSnapshot.data!.docs;
                    if (allItems.isEmpty) {
                      allItems = items;
                      filtredItem = items;
                    }
                    if (filtredItem.isEmpty) {
                      return Center(child: Text('No item found it'));
                    }
                  }
                  return CategoryGrid(product: filtredItem);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
