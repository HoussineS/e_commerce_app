import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/Core/utils/cart_order_count.dart';
import 'package:e_commerce_app/Core/utils/color_conversion.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/models/app_model.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/ui/categorie_items.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/ui/item_details.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/widget/curated_items.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/widget/custome_banner.dart';
import 'package:e_commerce_app/Core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  late final SupabaseStreamFilterBuilder categoryStream;
  late final CollectionReference<Map<String, dynamic>> itemStream;
  @override
  void initState() {
    categoryStream = Supabase.instance.client
        .from('category')
        .stream(primaryKey: ['id']);
    itemStream = FirebaseFirestore.instance.collection('items');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/logo.jpg', height: 60),
                  CartOrderCount(),
                ],
              ),
            ),
            SizedBox(height: 10),
            //cutome banner
            CustomeBanner(),
            SizedBox(height: 10),
            //shop by categorie
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SHOP BY CATEGORY',
                        style: TextStyle(
                          color: Colors.black,
                          letterSpacing: -1,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'SEE ALL',
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: 16,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                StreamBuilder(
                  stream: categoryStream,
                  builder:
                      (
                        context,
                        AsyncSnapshot<List<Map<String, dynamic>>> asyncSnapshot,
                      ) {
                        if (!asyncSnapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (asyncSnapshot.hasError) {
                          print('❌ ${asyncSnapshot.error}');
                          return Row(
                            children: [
                              Center(
                                child: Text(
                                  'Error on load category try again later ',
                                ),
                              ),
                            ],
                          );
                        }

                        final categories = asyncSnapshot.data!;
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(
                              categories.length,
                              (i) => InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => CategorieItems(
                                        category: categories[i]['name'],
                                        selectedCategory: categories[i]['name'],
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 15,
                                      ),
                                      child: CircleAvatar(
                                        radius: 30,
                                        backgroundColor: fbackroudColor1,
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                              categories[i]['image'],
                                            ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(categories[i]['name']),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CURATED FOR YOU',
                        style: TextStyle(
                          color: Colors.black,
                          letterSpacing: -1,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'SEE ALL',
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: 16,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                StreamBuilder(
                  stream: itemStream.snapshots(),
                  builder: (context, asyncSnapshot) {
                    if (asyncSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (asyncSnapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error on loading item ${asyncSnapshot.error}',
                          style: TextStyle(color: Colors.red, fontSize: 15),
                        ),
                      );
                    }
                    if (asyncSnapshot.data == null ||
                        asyncSnapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No item yet!'));
                    }
                    final items = asyncSnapshot.data!.docs;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(items.length, (index) {
                          final data = items[index].data();
                          final List<String> colors = List<String>.from(
                            data['colors'] ?? [],
                          );
                          final List<Color> itemColors = colors
                              .map((e) => getColorFromName(e))
                              .toList();
                          final item = AppModel(
                            name: data['name'],
                            image: data['imageUrl'],
                            rating: 4.5,
                            price: double.tryParse(data['price']) ?? 0,
                            review: 80,
                            fcolor: itemColors,
                            size: List<String>.from(data['sizes'] ?? []),
                            description:
                                'Lightweight and breathable running shoes designed for comfort and performance. Perfect for daily workouts or casual wear.',
                            isCheck: data['isDiscounted'],
                            category: data['category'],
                            percentageDiscount:
                                (data['percentageDiscount'] as num?)
                                    ?.toDouble() ??
                                0.0,
                          );
                          return Padding(
                            padding: index == 0
                                ? EdgeInsetsGeometry.symmetric(horizontal: 20)
                                : EdgeInsets.only(right: 20),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ItemDetails(
                                      item: item,
                                      itemId: items[index].id,
                                    ),
                                  ),
                                );
                              },
                              child: CuratedItems(
                                item: item,
                                itemId: items[index].id,
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
