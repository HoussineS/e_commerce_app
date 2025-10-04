import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetails extends StatefulWidget {
  final String orderId;
  final String userId;
  final String userRole;
  const OrderDetails({
    super.key,
    required this.orderId,
    required this.userId,
    required this.userRole,
  });

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  @override
  Widget build(BuildContext context) {
    bool isWaiting = false;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Order Details"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('orders')
            .doc(widget.orderId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading order: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Order not found'));
          }

          final order = snapshot.data!.data()!;
          final items = order['items'] as List;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Order Info Section ---
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order ID: ${widget.orderId}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text("Address: ${order['adreess'] ?? 'N/A'}"),
                        Text(
                          "Date: ${DateFormat('dd MM yyyy – kk:mm').format((order['createdAt'] as Timestamp).toDate())}",
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 8,
                              backgroundColor: order['status'] == 'Confirmed'
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            SizedBox(width: 3),
                            Text("Status: ${order['status'] ?? 'Pending'}"),
                          ],
                        ),

                        const Divider(height: 24),
                        Text(
                          "Total Price: \$${order['toltalPrice'].toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // --- Items Section ---
                const Text(
                  "Ordered Items",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          item['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Quantity: ${item['quantity']}"),
                            Text("Color: ${item['selectedColor']}"),
                            Text("Size: ${item['selectedSize']}"),
                            Text("Price: \$${item['price']}"),
                            if (item['discount'] != null &&
                                item['discount'] > 0)
                              Text("Discount: ${item['discount']}%"),
                          ],
                        ),
                        trailing: Text(
                          "\$${item['quantity'] * item['price']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.pink,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                //  --- Confirm button (only for Admin) ---
                if (widget.userRole == 'Admin')
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        label: isWaiting
                            ? CircularProgressIndicator()
                            : Text(
                                "Confirm Order",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        onPressed: order['status'] == 'pending'
                            ? () async {
                                try {
                                  setState(() {
                                    isWaiting = true;
                                  });
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(widget.userId)
                                      .collection('orders')
                                      .doc(widget.orderId)
                                      .update({
                                        'status': 'Confirmed',
                                        'confirmedAt':
                                            FieldValue.serverTimestamp(),
                                      });
                                  setState(() {
                                    isWaiting = false;
                                  });
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "✅ Order confirmed successfully",
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  setState(() {
                                    isWaiting = false;
                                  });
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "❌ Error confirming order: $e",
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
