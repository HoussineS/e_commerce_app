import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/Core/models/screen_config.dart';
import 'package:e_commerce_app/Core/provider/favorite_provider.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/models/app_model.dart';
import 'package:e_commerce_app/Core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CuratedItems extends ConsumerWidget {
  final AppModel item;
  final String itemId;

  const CuratedItems({super.key, required this.item, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(favProvider);
    return Card(
      color: Colors.white,
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
                    backgroundColor: provider.isFav(itemId)
                        ? Colors.white
                        : Colors.black38,
                    child: IconButton(
                      onPressed: () {
                        ref.read(favProvider).tooglefavorite(itemId);
                      },
                      icon: Icon(
                        provider.isFav(itemId)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: provider.isFav(itemId)
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
              textAlign: TextAlign.center,
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
                '\$${item.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: item.isCheck ? Colors.pink : Colors.black,
                  fontSize: 18,
                  height: 1.5,
                ),
              ),
              SizedBox(width: 4),
              if (item.isCheck)
                Text(
                  '\$${(item.price + 50).toStringAsFixed(2)}',
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
  }
}
