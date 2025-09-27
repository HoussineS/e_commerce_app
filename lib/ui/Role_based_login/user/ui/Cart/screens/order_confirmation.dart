import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/Core/models/screen_config.dart';
import 'package:e_commerce_app/Core/utils/colors.dart';
import 'package:e_commerce_app/Core/utils/payment_methode_list.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/controller/carts_provider.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/models/cart_model.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/ui/user_main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderConfirmation extends ConsumerStatefulWidget {
  final List<CartModel> carts;
  final double total;

  const OrderConfirmation({
    super.key,
    required this.carts,
    required this.total,
  });

  @override
  ConsumerState<OrderConfirmation> createState() => _OrderConfirmationState();
}

class _OrderConfirmationState extends ConsumerState<OrderConfirmation> {
  final TextEditingController addressController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? addressError;
  String? selectedPaymentMethodeId;
  double? balance;
  String? paymentMehodeName;
  bool _showScrollHint = true;

  @override
  void initState() {
    super.initState();

    // Hide scroll hint when user scrolls down a bit
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && _showScrollHint) {
        setState(() {
          _showScrollHint = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cp = ref.watch(cartsProvider);
    return Scaffold(
      backgroundColor: fbackroudColor2,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: _buildContent(cp),
            ),

            // 👇 Floating scroll-down hint
            if (_showScrollHint)
              Positioned(
                bottom: 85,
                left: 0,
                right: 0,
                child: Center(
                  child: Column(
                    children: const [
                      Text(
                        "Scroll down to add your address",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 30,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(CartsProvider cp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        SizedBox(
          height: ScreenConfig.screenHeight * 0.3,
          width: double.infinity,
          child: Column(
            children: [
              Image.asset(
                'assets/images/cart-image.png',
                height: ScreenConfig.screenHeight * 0.22,
                width: ScreenConfig.screenWidth * 0.7,
              ),
              const SizedBox(height: 10),
              const Text(
                'Confirm your order',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Review your order details before placing.',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        const Text(
          'Order detail',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),

        // Order Items Container
        Container(
          constraints: BoxConstraints(
            maxHeight: ScreenConfig.screenHeight * 0.4,
          ),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Items List
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: ScreenConfig.screenHeight * 0.15,
                  ),
                  child: ListView.builder(
                    itemCount: widget.carts.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final cart = widget.carts[index];
                      final price =
                          (cart.productData.price *
                                  ((100 - cart.productData.percentageDiscount) /
                                      100))
                              .toStringAsFixed(2);

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: CachedNetworkImageProvider(
                              cart.productData.image,
                            ),
                          ),
                          title: Text(
                            cart.productData.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            'Color: ${cart.selectedColor} | Size: ${cart.selectedSize.toUpperCase()}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$$price',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('Qty: ${cart.quantity}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const Divider(),

                // Delivery
                _buildRow('Delivery', '\$4.99'),

                // Total
                _buildRow('Total', '\$${widget.total.toStringAsFixed(2)}'),

                const SizedBox(height: 5),
                const Text(
                  'Select payment method',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                PaymentMethodeList(
                  selectedPaymentMethodeId: selectedPaymentMethodeId,
                  balance: balance,
                  total: widget.total,
                  onSelectePaymentMethode: (methodeId, methodeName, bal) {
                    setState(() {
                      selectedPaymentMethodeId = methodeId;
                      balance = bal;
                      paymentMehodeName = methodeName;
                    });
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add your delivery address',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    hintText: 'Your address',
                    errorText: addressError,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 30),

        // Bottom buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const StadiumBorder(),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const StadiumBorder(),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                onPressed: () {
                  if (addressController.text.isEmpty) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeInOut,
                    );
                    setState(() {
                      addressError = 'This field is required';
                    });
                    return;
                  }
                  if (paymentMehodeName == null || paymentMehodeName!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Select a payment method!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  if (balance! < widget.total) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sold insufucent'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  _showOrderConfirmationDialog(
                    context,
                    addressController.text,
                    cp,
                  );
                },
                child: const Text('Confirm Order'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderConfirmationDialog(
    BuildContext context,
    String address,
    CartsProvider cp,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Confirm Your Order',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListBody(
                  children: widget.carts.map((cart) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        "${cart.productData.name} × ${cart.quantity}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Text(
                  'Total: \$${(widget.total).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Payment method:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      paymentMehodeName!,
                      style: const TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Delivery address:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        address.toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _saveOrder(cp, context, selectedPaymentMethodeId!, address);
                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveOrder(
    CartsProvider cp,
    BuildContext context,
    String paymendMethodeId,
    String address,
  ) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    await cp.saveOrder(
      userId: userId,
      paymendMethodeId: paymendMethodeId,
      adreess: address,
      totalPrice: widget.total,
      context: context,
      cartOrderd: widget.carts
    );
    Navigator.of(
      // ignore: use_build_context_synchronously
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => UserMainScreen()));
    ScaffoldMessenger.of(
      // ignore: use_build_context_synchronously
      context,
    ).showSnackBar(
      SnackBar(
        content: Text('Order palced successfuly'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
