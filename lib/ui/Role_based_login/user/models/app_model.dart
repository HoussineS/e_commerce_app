import 'package:e_commerce_app/Core/utils/color_conversion.dart';
import 'package:flutter/material.dart';

class AppModel {
  final String name, image, description, category;
  final double rating, price;
  final int review;
  List<Color> fcolor;
  List<String> size;
  bool isCheck;
  double percentageDiscount;

  AppModel({
    required this.name,
    required this.image,
    required this.rating,
    required this.price,
    required this.review,
    required this.fcolor,
    required this.size,
    required this.description,
    required this.isCheck,
    required this.category,
    this.percentageDiscount = 0.0,
  });
  Map<String, dynamic> getMap() {
    return {
      'name': name,
      'image': image,
      'description': description,
      'category': category,
      'rating': rating,
      'price': price,
      'review': review,
      'fcolor': fcolor
          .map((color) => colorToName(color))
          .toList(), // Convert Colors to int
      'size': size,
      'isCheck': isCheck,
      'percentageDiscount': percentageDiscount,
    };
  }
}

List<AppModel> fashionEcommerceApp = [
  AppModel(
    name: 'T-shirt',
    image:
        'https://images.unsplash.com/photo-1571513800374-df1bbe650e56', // Unsplash image
    rating: 4.5,
    price: 29,
    review: 120,
    fcolor: [Colors.red, Colors.blue],
    size: ['S', 'M', 'L'],
    description: 'Comfortable cotton t-shirt',
    isCheck: false,
    category: 'Women',
  ),

  AppModel(
    name: 'Jeans',
    image:
        'https://images.unsplash.com/photo-1509631179647-0177331693ae', // Unsplash image
    rating: 4.0,
    price: 49,
    review: 80,
    fcolor: [Colors.black, Colors.blue],
    size: ['M', 'L', 'XL'],
    description: 'Stylish slim-fit jeans',
    isCheck: false,
    category: 'Women',
  ),
  AppModel(
    name: 'Sneakers',
    image:
        'https://plus.unsplash.com/premium_photo-1707932495000-5748b915e4f2', // Unsplash image
    rating: 4.8,
    price: 79,
    review: 200,
    fcolor: [Colors.white, Colors.black],
    size: ['8', '9', '10'],
    description: 'Comfortable and durable sneakers',
    isCheck: true,
    category: 'Men',
  ),
  AppModel(
    name: 'Watch',
    image:
        'https://images.unsplash.com/photo-1566206091558-7f218b696731', // Unsplash image
    rating: 4.2,
    price: 199,
    review: 50,
    fcolor: [Colors.black, Colors.grey, Colors.white],
    size: ['S', 'M'],
    description: 'Elegant leather strap watch',
    isCheck: false,
    category: 'Women',
  ),
  AppModel(
    name: 'Hat',
    image:
        'https://plus.unsplash.com/premium_photo-1723874486879-4059a9aefa3d', // Unsplash image
    rating: 4.3,
    price: 19,
    review: 65,
    fcolor: [Colors.brown, Colors.black],
    size: ['M', 'L'],
    description: 'Classic summer hat',
    isCheck: true,
    category: 'Baby',
  ),
];

final descreption =
    'A stylish and comfortable t-shirt made from soft, breathable fabric, perfect for everyday wear. Its sleek design and versatile color make it an essential addition to any wardrobe.';
List<String> filterCategory = [
  "Filter",
  "Ratings",
  "Size",
  "Color",
  "Price",
  "Brand",
];
