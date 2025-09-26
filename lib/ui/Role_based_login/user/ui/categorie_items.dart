import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/Core/models/screen_config.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/models/app_model.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/models/sub_category.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/widget/category_grid.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/widget/sub_categorie_widget.dart';
import 'package:e_commerce_app/Core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CategorieItems extends StatefulWidget {
  final String selectedCategory;
  final String category;
  const CategorieItems({
    super.key,
    required this.category,
    required this.selectedCategory,
  });

  @override
  State<CategorieItems> createState() => _CategorieItemsState();
}

class _CategorieItemsState extends State<CategorieItems> {
  TextEditingController serachController = TextEditingController();
  List<QueryDocumentSnapshot> allIem = [];
  List<QueryDocumentSnapshot> filtredItem = [];
  @override
  void initState() {
    serachController.addListener(_onSearchBarChanged);
    super.initState();
  }

  @override
  void dispose() {
    serachController.dispose();
    super.dispose();
  }

  void _onSearchBarChanged() {
    final serchTerm = serachController.text.toLowerCase as String;
    setState(() {
      filtredItem = allIem.where((item) {
        final itemData = item.data() as Map<String, dynamic>;
        final itemName = itemData['name'] as String;
        return itemName.contains(serchTerm);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference itemCollection = FirebaseFirestore.instance
        .collection('items');
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
                        controller: serachController,
                        decoration: InputDecoration(
                          hintText: "${widget.category}'s Fashion",
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Row(
                  children: List.generate(
                    listOfSubCategory.length,
                    (index) =>
                        SubCategorieWidget(subCateg: listOfSubCategory[index]),
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: itemCollection
                    .where('category', isEqualTo: widget.selectedCategory)
                    .snapshots(),
                builder: (context, asyncSnapshot) {
                  if (asyncSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (asyncSnapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error on filtred Category ${asyncSnapshot.error}',
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
                    if (allIem.isEmpty) {
                      allIem = items;
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
