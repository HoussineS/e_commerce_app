// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/Core/utils/color_conversion.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/models/app_model.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/models/cart_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cartsProvider = ChangeNotifierProvider<CartsProvider>(
  (ref) => CartsProvider(),
);
final isLoadingProviderState = StateProvider.family<bool, String>((
  red,
  productId,
) {
  return false;
});

class CartsProvider with ChangeNotifier {
  CartsProvider() {
    loadData();
  }
  List<CartModel> _carts = [];
  final _fireStore = FirebaseFirestore.instance;
  final _userId = FirebaseAuth.instance.currentUser?.uid;
  //getters
  List<CartModel> get getCarts => _carts;
  //setters
  set setCarts(List<CartModel> carts) {
    _carts = carts;
    notifyListeners();
  }

  //load data from firebase
  Future<void> loadData() async {
    try {
      print('is Loading...');
      final QuerySnapshot snapshot = await _fireStore
          .collection('users')
          .doc(_userId)
          .collection('userCart')
          .get();
      if (snapshot.docs.isEmpty) {
        print('is empty');
        return;
      }
      for (var doc in snapshot.docs) {
        final cartProductData = doc.data() as Map<String, dynamic>;
        print(cartProductData);
        final colorList = List<String>.from(
          cartProductData['productData']['fcolor'] ?? [],
        );
        final fColor = colorList
            .map((color) => getColorFromName(color))
            .toList();

        _carts.add(
          CartModel(
            productId: cartProductData['productId'],
            productData: AppModel(
              name: cartProductData['productData']['name'],
              image: cartProductData['productData']['image'],
              rating: cartProductData['productData']['rating'] ?? 0,
              price: cartProductData['productData']['price'],
              review: cartProductData['productData']['review'] ?? 0,
              fcolor: fColor,
              size: List<String>.from(
                cartProductData['productData']['size'] ?? [],
              ),
              description: cartProductData['productData']['description'],
              isCheck: cartProductData['productData']['isCheck'],
              category: cartProductData['productData']['category'],
              percentageDiscount:
                  (cartProductData['productData']['percentageDiscount'] as num?)
                      ?.toDouble() ??
                  0.0,
            ),
            selectedColor: cartProductData['selectedColor'],
            selectedSize: cartProductData['selectedSize'],
            quantity: cartProductData['quantity'],
          ),
        );
      }
      notifyListeners();
    } catch (e) {
      throw (e.toString());
    }
  }

  Future<void> rest(List<CartModel> cartRemoved) async {
    // Remove from local list
    _carts.removeWhere((cartItem) {
      return cartRemoved.any(
        (itemRemoveFromCart) =>
            cartItem.productId == itemRemoveFromCart.productId,
      );
    });

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userCartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('userCart');

    // Batch write for efficiency
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // For each cart item to remove, query Firestore by productId
    for (var item in cartRemoved) {
      final querySnapshot = await userCartRef
          .where('productId', isEqualTo: item.productId)
          .get();

      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
    }

    await batch.commit();
    notifyListeners();
  }

  //save order on firestore
  Future<void> saveOrder({
    required String userId,
    required String paymendMethodeId,
    required String adreess,
    required double totalPrice,
    required BuildContext context,
    required List<CartModel> cartOrderd,
  }) async {
    if (cartOrderd.isEmpty) {
      return;
    }
    final paymentRef = FirebaseFirestore.instance
        .collection('User payment methode')
        .doc(paymendMethodeId);
    try {
      //get atomic operation using transaction
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(paymentRef);
        if (!snapshot.exists) {
          throw Exception('Payment methode not found');
        }
        final oldBalance = snapshot['balance'] as num;
        final newBalance = oldBalance - totalPrice;
        //update the balance of payment methode
        transaction.update(paymentRef, {'balance': newBalance});
        //create order data
        final orderData = {
          'items': cartOrderd.map((item) {
            return {
              'productId': item.productId,
              'quantity': item.quantity,
              'name': item.productData.name,
              'price': item.productData.price,
              'discount': item.productData.percentageDiscount,
              'selectedColor': item.selectedColor,
              'selectedSize': item.selectedSize,
            };
          }).toList(),
          'toltalPrice': totalPrice,
          'status': 'pending', //insitial is pending,
          'createdAt': FieldValue.serverTimestamp(),
          'adreess': adreess,
        };
        //create order collection on users
        final orderRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('orders')
            .doc();
        transaction.set(orderRef, orderData);
      });
      await rest(cartOrderd);
    } catch (e) {
      throw (e.toString());
    }
  }

  //add a cart or increase quantity
  Future<void> addToCart(
    String productId,
    AppModel productData,
    String selectedColor,
    String selectedSize,
  ) async {
    final index = _carts.indexWhere(
      (element) => element.productId == productId,
    );
    if (index != -1) {
      _carts[index] = CartModel(
        productId: productId,
        productData: productData,
        selectedColor: selectedColor, //update color selected
        selectedSize: selectedSize, //update Size selected
        quantity: _carts[index].quantity + 1, //icriment quantity
      );
      await updateCartInFirebase(productId, _carts[index].quantity);
      //function for update the server firebase
    } else {
      _carts.add(
        CartModel(
          productId: productId,
          productData: productData,
          selectedColor: selectedColor,
          selectedSize: selectedSize,
          quantity: 1,
        ),
      );

      await _fireStore
          .collection('users')
          .doc(_userId)
          .collection('userCart')
          .doc(productId)
          .set({
            'productId': productId,
            'productData': productData.getMap(),
            'selectedColor': selectedColor,
            'selectedSize': selectedSize,
            'quantity': 1,
          });
    }
    notifyListeners();
  }

  //remove from cart
  Future<void> removeFromCart(String productId) async {
    _carts.removeWhere((product) => product.productId == productId);
    await _fireStore
        .collection('users')
        .doc(_userId)
        .collection('userCart')
        .doc(productId)
        .delete();
    notifyListeners();
  }

  //decrease quantity
  Future<void> decreaseQuantity(String productId) async {
    final index = _carts.indexWhere(
      (product) => product.productId == productId,
    );
    if (index != -1) {
      if (_carts[index].quantity > 1) {
        _carts[index].quantity--;
        await updateCartInFirebase(productId, _carts[index].quantity);
      } else {
        _carts.removeAt(index);
        await removeFromCart(productId);
      }
    }
    notifyListeners();
  }

  //check if product is exist
  bool productIsInCarts(String productId) =>
      _carts.any((element) => element.productId == productId);
  //calculate toltal price
  double calculateTotal() {
    return _carts.fold(0.0, (previousValue, element) {
      return previousValue +
          (element.productData.price * element.quantity) *
              ((100 - element.productData.percentageDiscount) / 100);
    });
  }

  //update cart on firebase
  Future<void> updateCartInFirebase(String productid, int quantity) async {
    try {
      await _fireStore
          .collection('users')
          .doc(_userId)
          .collection('userCart')
          .doc(productid)
          .update({'quantity': quantity});
    } catch (e) {
      throw (e.toString());
    }
  }
}
