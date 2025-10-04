import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/Core/models/screen_config.dart';
import 'package:e_commerce_app/Core/provider/favorite_provider.dart';
import 'package:e_commerce_app/Core/utils/cart_order_count.dart';
import 'package:e_commerce_app/Core/utils/color_conversion.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/controller/carts_provider.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/models/app_model.dart';
import 'package:e_commerce_app/Core/utils/colors.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/models/cart_model.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/ui/Cart/screens/order_confirmation.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/widget/size_and_color_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

class ItemDetails extends ConsumerStatefulWidget {
  final AppModel item;
  final String? itemId;
  const ItemDetails({super.key, required this.item, this.itemId});

  @override
  ConsumerState<ItemDetails> createState() => _ItemDetailsState();
}

class _ItemDetailsState extends ConsumerState<ItemDetails> {
  int currentIndex = 0;
  int selectedColorIndex = 0;
  int selectedSizeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(favProvider);
    final cp = ref.watch(cartsProvider);
    bool isInCart = cp.getCarts.any(
      (cartItem) => cartItem.productId == widget.itemId!,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail product'),
        centerTitle: true,
        backgroundColor: fbackroudColor1,
        actions: [CartOrderCount()],
      ),
      body: ListView(
        children: [
          Container(
            color: fbackroudColor2,
            height: ScreenConfig.screenRealHeight * 0.46,
            width: ScreenConfig.screenWidth,
            child: PageView.builder(
              scrollDirection: Axis.horizontal,
              onPageChanged: (value) {
                setState(() {
                  currentIndex = value;
                });
              },
              itemCount: 3,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    widget.itemId == null
                        ? CachedNetworkImage(
                            imageUrl: widget.item.image,
                            height: ScreenConfig.screenRealHeight * 0.4,
                            width: ScreenConfig.screenWidth * 0.85,

                            fit: BoxFit.cover,
                          )
                        : Hero(
                            tag: widget.itemId!,
                            child: CachedNetworkImage(
                              imageUrl: widget.item.image,
                              height: ScreenConfig.screenRealHeight * 0.4,
                              width: ScreenConfig.screenWidth * 0.85,

                              fit: BoxFit.cover,
                            ),
                          ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (index) => AnimatedContainer(
                          duration: Duration(microseconds: 300),

                          margin: EdgeInsets.only(right: 4, top: 20),
                          width: 7,
                          height: 7,

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: index == currentIndex
                                ? Colors.blue
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsetsGeometry.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    Text('${widget.item.rating}'),
                    SizedBox(width: 2),
                    //number of person that do a Review
                    Text(
                      '(${widget.item.review})',
                      style: const TextStyle(
                        color: Colors.black26,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        ref.read(favProvider).tooglefavorite(widget.itemId!);
                      },
                      icon: Icon(
                        provider.isFav(widget.itemId!)
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      color: provider.isFav(widget.itemId!)
                          ? Colors.red
                          : Colors.black,
                    ),
                  ],
                ),

                Text(
                  widget.item.name,
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    height: 1.5,
                  ),
                ),

                Row(
                  children: [
                    Text(
                      '\$${(widget.item.price * ((100 - widget.item.percentageDiscount) / 100)).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.pink,
                        fontSize: 18,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(width: 4),
                    if (widget.item.isCheck)
                      Text(
                        '\$${(widget.item.price).toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.black26,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.black26,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  widget.item.description,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black26,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 16),
                SizeAndColorState(
                  colors: widget.item.fcolor,
                  sizes: widget.item.size,
                  onColorsSelected: (index) {
                    setState(() {
                      selectedColorIndex = index;
                    });
                  },
                  onSizeSelected: (index) {
                    setState(() {
                      selectedSizeIndex = index;
                    });
                  },
                  selectedColorIndex: selectedColorIndex,
                  selectedSizeIndex: selectedSizeIndex,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        elevation: 0,
        backgroundColor: Colors.white,
        label: SizedBox(
          width: ScreenConfig.screenWidth * 0.9,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: isInCart
                      ? null
                      : () {
                          final productId = widget.itemId!;
                          final productData = widget.item;
                          cp.addToCart(
                            productId,
                            productData,
                            colorToName(productData.fcolor[selectedColorIndex]),
                            productData.size[selectedSizeIndex],
                          );
                          //notify user
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${productData.name} added to cart',
                              ),
                            ),
                          );
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.shopping_bag, color: Colors.black),
                        SizedBox(width: 4),
                        Text(
                          isInCart ? "Product alreday on cart" : 'ADD TO CART',
                          style: TextStyle(
                            color: Colors.black,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          if (isInCart) {
                            final itemCartInfo = cp.getCarts.firstWhere(
                              (cartItem) => cartItem.productId == widget.itemId,
                            );
                            return OrderConfirmation(
                              carts: [itemCartInfo],
                              total: double.parse(
                                (widget.item.price * itemCartInfo.quantity + 4.99).toStringAsFixed(2),
                              ),
                            );
                          }
                          return OrderConfirmation(
                            carts: [
                              CartModel(
                                productId: widget.itemId!,
                                productData: widget.item,
                                selectedColor: colorToName(
                                  widget.item.fcolor[selectedColorIndex],
                                ),
                                selectedSize:
                                    widget.item.size[selectedSizeIndex],
                                quantity: 1,
                              ),
                            ],
                            total: double.parse(
                              (widget.item.price + 4.99).toStringAsFixed(2),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      color: Colors.black,
                    ),
                    child: Center(
                      child: Text(
                        'BUY NOW',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
