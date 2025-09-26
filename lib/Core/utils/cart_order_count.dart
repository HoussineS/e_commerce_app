import 'package:e_commerce_app/ui/Role_based_login/user/controller/carts_provider.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/ui/Cart/screens/user_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

class CartOrderCount extends ConsumerWidget {
  const CartOrderCount({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cp = ref.watch(cartsProvider);
  
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => UserCart()));
          },
          icon: Icon(Iconsax.shopping_bag, size: 28),
        ),
        Positioned(
          top: 2,
          right: 5,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                cp.getCarts.length.toString(),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
