import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/Core/provider/favorite_provider.dart';
import 'package:e_commerce_app/Core/utils/color_conversion.dart';
import 'package:e_commerce_app/Core/utils/colors.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/models/app_model.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/ui/item_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteItems extends ConsumerWidget {
  const FavoriteItems({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestore = FirebaseFirestore.instance;
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final provide = ref.watch(favProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: fbackroudColor2,
      ),
      backgroundColor: fbackroudColor2,
      body: StreamBuilder(
        stream: firestore
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .snapshots(),
        builder: (context, snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return Center(child: CircularProgressIndicator());
          // }
          if (!snapshot.hasData) {
            return Center(child: Center(child: CircularProgressIndicator()));
          }
          final favItt = snapshot.data!.docs.where((doc) => doc.exists);
          if (favItt.isEmpty) {
            return Center(
              child: Text(
                'You don\'t have any favorite item yet!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }
          return FutureBuilder<List<DocumentSnapshot>>(
            future: Future.wait(
              snapshot.data!.docs.map(
                (doc) => firestore.collection('items').doc(doc.id).get(),
              ),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              final favItems = snapshot.data!
                  .where((item) => item.exists)
                  .toList();
              return ListView.builder(
                itemCount: favItems.length,
                itemBuilder: (context, index) {
                  final favItem =
                      favItems[index].data() as Map<String, dynamic>;
                  final price = double.tryParse(favItem['price']) ?? 0.0;
                  final List<String> colors = List<String>.from(
                    favItem['colors'] ?? [],
                  );
                  final List<Color> itemColors = colors
                      .map((e) => getColorFromName(e))
                      .toList();
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ItemDetails(
                            item: AppModel(
                              name: favItem['name'],
                              image: favItem['imageUrl'],
                              rating: 4.5,
                              price: price,
                              review: 80,
                              fcolor: itemColors,
                              size: List<String>.from(favItem['sizes'] ?? []),
                              description:
                                  'Lightweight and breathable running shoes designed for comfort and performance. Perfect for daily workouts or casual wear.',
                              isCheck: favItem['isDiscounted'],
                              category: favItem['category'],
                              percentageDiscount:
                                  (favItem['percentageDiscount'] as num?)
                                      ?.toDouble() ??
                                  0.0,
                            ),
                            itemId: favItems[index].id,
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsetsGeometry.symmetric(
                            horizontal: 15,
                            vertical: 5,
                          ),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),

                            child: Row(
                              children: [
                                Hero(
                                  tag: favItems[index].id,
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    height: 90,
                                    width: 90,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(
                                          favItem['imageUrl'],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 20,
                                        ),
                                        child: Text(
                                          '${favItem['name']}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text('${favItem['category']} Fashion'),
                                      favItem['isDiscounted']
                                          ? Row(
                                              children: [
                                                Text(
                                                  (price *
                                                          ((100 -
                                                                  favItem['percentageDiscount']) /
                                                              100))
                                                      .toStringAsFixed(2),
                                                  style: TextStyle(
                                                    color: Colors.pink,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(width: 2),
                                                Text(
                                                  '\$${price.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    color: Colors.black26,
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                    decorationColor:
                                                        Colors.black26,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Text(
                                              (price).toStringAsFixed(2),
                                              style: TextStyle(
                                                color: Colors.pink,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 40,
                          right: 30,
                          child: GestureDetector(
                            onTap: () {
                              provide.tooglefavorite(favItems[index].id);
                            },
                            child: Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
