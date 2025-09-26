import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/Core/models/screen_config.dart';
import 'package:e_commerce_app/Core/provider/favorite_provider.dart';
import 'package:e_commerce_app/Core/utils/color_conversion.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/models/app_model.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/ui/item_details.dart';
import 'package:e_commerce_app/Core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryGrid extends ConsumerWidget {
  final List<QueryDocumentSnapshot<Object?>> product;
  const CategoryGrid({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<AppModel> products = [];
    final provier = ref.watch(favProvider);
    for (var element in product) {
      final data = element.data() as Map<String, dynamic>;
      final List<String> colors = List<String>.from(data['colors'] ?? []);
      final List<Color> itemColors = colors
          .map((e) => getColorFromName(e))
          .toList();
      print(data);
      products.add(
        AppModel(
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
              (data['percentageDiscount'] as num?)?.toDouble() ?? 0.0,
        ),
      );
    }
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      itemCount: product.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.6,
      ),
      itemBuilder: (context, index) {
        final itemId = product[index].id;
        final item = products[index];

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ItemDetails(item: item, itemId: itemId),
              ),
            );
          },
          child: Column(
            children: [
              Hero(
                tag: itemId,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    color: fbackroudColor2,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(item.image),
                    ),
                  ),
                  height: ScreenConfig.screenHeight * 0.25,
                  width: ScreenConfig.screenWidth * 0.5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: CircleAvatar(
                        backgroundColor: provier.isFav(itemId)
                            ? Colors.white
                            : Colors.black38,
                        child: IconButton(
                          onPressed: () {
                            ref.read(favProvider).tooglefavorite(itemId);
                          },
                          icon: Icon(
                            provier.isFav(itemId)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: provier.isFav(itemId)
                                ? Colors.red
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  //Model or mark
                  const Text(
                    'H&M',
                    style: TextStyle(
                      color: Colors.black26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  //Star icon
                  const Icon(Icons.star, color: Colors.amber, size: 17),
                  //Raiting
                  Text('${item.rating}'),
                  SizedBox(width: 2),
                  //number of person that do a Review
                  Text(
                    '(${item.review})',
                    style: const TextStyle(
                      color: Colors.black26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: ScreenConfig.screenWidth * 0.45,
                child: Text(
                  item.name,
                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    height: 1.5,
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    '\$${(item.price * ((100 - item.percentageDiscount) / 100)).toStringAsFixed(2)}',
                    style: TextStyle(
                      color: item.isCheck ? Colors.pink : Colors.black,
                      fontSize: 18,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(width: 4),
                  if (item.isCheck)
                    Text(
                      '\$${(item.price).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.black26,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Colors.black26,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
