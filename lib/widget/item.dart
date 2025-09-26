import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Item extends StatelessWidget {
  final String imageUrl;
  final String? name;
  final String? price;
  final String? category;
  const Item({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(8),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        elevation: 2,
        child: ListTile(
          leading: ClipOval(
            child: CircleAvatar(
              radius: 30,

              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 60,
                width: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(
            name != null ? '$name' : 'N/A',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    price != null
                        ? '\$${double.tryParse(price!)!.toStringAsFixed(2)}'
                        : 'N/A',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(category != null ? '$category' : "N/A"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
