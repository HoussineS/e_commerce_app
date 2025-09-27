// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/ui/Order/order_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderUi extends StatefulWidget {
  const OrderUi({super.key});

  @override
  State<OrderUi> createState() => _OrderUiState();
}

class _OrderUiState extends State<OrderUi> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final CollectionReference ordersRef = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('orders');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Orders'), centerTitle: true),
      backgroundColor: Colors.grey[100],
      body: StreamBuilder(
        stream: ordersRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error on loading user orders ${snapshot.error}",
                style: TextStyle(color: Colors.red, fontSize: 20),
              ),
            );
          }
          final orders = snapshot.data!.docs;
          if (orders.isEmpty) {
            return Center(child: Text("No orders yet!"));
          }
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              final price =
                  double.tryParse(order['toltalPrice'].toString()) ?? 0;
              final orderId = orders[index].id;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  title: Text('Order id: $orderId'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total: ${price.toStringAsFixed(2)}'),
                      Text(
                        'Date: ${DateFormat('dd/m/yyyy - kk:mm').format((order['createdAt'] as Timestamp).toDate())}',
                      ),
                    ],
                  ),

                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OrderDetails(orderId: orderId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
