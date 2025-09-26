import 'package:e_commerce_app/ui/Role_based_login/user/models/app_model.dart';

class CartModel {
  final String productId;
  final AppModel productData;
  int quantity;
  final String selectedColor;
  final String selectedSize;
  CartModel({
    required this.productId,
    required this.productData,
    required this.selectedColor,
    required this.selectedSize,
    required this.quantity,
  });
}
