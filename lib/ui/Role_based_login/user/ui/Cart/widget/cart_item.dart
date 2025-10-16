import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/Core/models/screen_config.dart';
import 'package:e_commerce_app/Core/utils/color_conversion.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/controller/carts_provider.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/models/cart_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItem extends ConsumerWidget {
  final CartModel cart;
  const CartItem({super.key, required this.cart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cp = ref.watch(cartsProvider);
    final double finalPrice =
        (cart.productData.price *
        ((100 - cart.productData.percentageDiscount) / 100));
    final bool isWaiting = ref.watch(isLoadingProviderState(cart.productId));
    return Container(
      height: 120,
      width: ScreenConfig.screenWidth / 1.1,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Dismissible(
        key: Key(cart.productId),
        direction: DismissDirection.endToStart, //scrole right to left
        onDismissed: (direction) {
          ref.read(cartsProvider).removeFromCart(cart.productId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Item deleted succesfuly',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        },
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(left: 20),
          child: Padding(
            padding: const EdgeInsets.only(right: 30),
            child: Icon(Icons.delete_forever, color: Colors.black, size: 30),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(width: 20),
                CachedNetworkImage(
                  imageUrl: cart.productData.image,
                  width: 100,
                  height: 120,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cart.productData.name,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          const Text('Color: '),
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: getColorFromName(
                              cart.selectedColor,
                            ),
                          ),
                          SizedBox(width: 10),
                          const Text('Size: '),
                          Text(
                            cart.selectedSize,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            '\$${finalPrice.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.pink, fontSize: 20),
                          ),
                          SizedBox(width: ScreenConfig.screenWidth * 0.08),
                          GestureDetector(
                            onTap: () async {
                              if (!isWaiting) {
                                ref
                                        .read(
                                          isLoadingProviderState(
                                            cart.productId,
                                          ).notifier,
                                        )
                                        .state =
                                    true;
                                await cp.decreaseQuantity(cart.productId);
                                ref
                                        .read(
                                          isLoadingProviderState(
                                            cart.productId,
                                          ).notifier,
                                        )
                                        .state =
                                    false;
                              }
                            },

                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.blue,
                              ),
                              child: Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            cart.quantity.toString(),
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: () async {
                              if (!isWaiting) {
                                ref
                                        .read(
                                          isLoadingProviderState(
                                            cart.productId,
                                          ).notifier,
                                        )
                                        .state =
                                    true;
                                await cp.addToCart(
                                  cart.productId,
                                  cart.productData,
                                  cart.selectedColor,
                                  cart.selectedSize,
                                );
                                ref
                                        .read(
                                          isLoadingProviderState(
                                            cart.productId,
                                          ).notifier,
                                        )
                                        .state =
                                    false;
                              }
                            },
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.blue,
                              ),
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
