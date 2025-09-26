import 'package:dotted_line/dotted_line.dart';
import 'package:e_commerce_app/Core/models/screen_config.dart';
import 'package:e_commerce_app/Core/utils/colors.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/controller/carts_provider.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/ui/Cart/screens/order_confirmation.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/ui/Cart/widget/cart_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserCart extends ConsumerStatefulWidget {
  const UserCart({super.key});

  @override
  ConsumerState<UserCart> createState() => _UserCartState();
}

class _UserCartState extends ConsumerState<UserCart> {
  @override
  Widget build(BuildContext context) {
    final cp = ref.watch(cartsProvider);
    final carts = cp.getCarts;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Cart',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        // leading: IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
      ),
      backgroundColor: fbackroudColor2,
      body: carts.isEmpty
          ? Center(child: Text('Cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: carts.length,
                    itemBuilder: (context, index) {
                      final cartData = carts[index];
                      return Padding(
                        padding: EdgeInsetsGeometry.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        child: GestureDetector(
                          onTap: () {},
                          child: CartItem(cart: cartData),
                        ),
                      );
                    },
                  ),
                ),
                if (carts.isNotEmpty) _buildSummarySection(context, cp),
              ],
            ),
    );
  }

  Widget _buildSummarySection(BuildContext context, CartsProvider cp) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Delivery',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 10),
              Expanded(child: DottedLine()),
              SizedBox(width: 10),
              Text(
                '\$4.99',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Total Order',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 10),
              Expanded(child: DottedLine()),
              SizedBox(width: 10),
              Text(
                '\$${(cp.calculateTotal()).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          MaterialButton(
            color: Colors.black,
            height: 65,
            minWidth: ScreenConfig.screenWidth * 0.9,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(10),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => OrderConfirmation(
                    carts: cp.getCarts,
                    total: cp.calculateTotal() + 4.99,
                  ),
                ),
              );
            },
            child: Text(
              'Pay \$${(cp.calculateTotal() + 4.99).toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
