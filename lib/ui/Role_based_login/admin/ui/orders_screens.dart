import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/Core/utils/colors.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/ui/Order/order_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrdersScreens extends StatefulWidget {
  const OrdersScreens({super.key});

  @override
  State<OrdersScreens> createState() => _OrdersScreensState();
}

class _OrdersScreensState extends State<OrdersScreens> {
  final queryDocument = FirebaseFirestore.instance
      .collectionGroup("orders")
      .orderBy('createdAt', descending: true);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fbackroudColor2,
      appBar: AppBar(title: Text("Orders"), centerTitle: true),
      body: StreamBuilder(
        stream: queryDocument.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Firebase error"));
          } else if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No orders yet"));
          }
          return ListView.builder(
            padding: EdgeInsets.all(8),

            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final orderId = snapshot.data!.docs[index].id;
              final userId =
                  snapshot.data!.docs[index].reference.parent.parent!.id;
              final orderData = snapshot.data!.docs[index].data();
              final total = orderData['toltalPrice'] as double;
              final status = orderData['status'] as String;
              final dateOrder = DateFormat(
                'dd/MM/yyyy - kk:mm',
              ).format((orderData['createdAt'] as Timestamp).toDate());
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                margin: EdgeInsets.all(8),
                child: ListTile(
                  onTap: () {
                    print(userId);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            OrderDetails(orderId: orderId, userId: userId,userRole: 'Admin',),
                      ),
                    );
                  },
                  title: Text(
                    'Order id: $orderId',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Total: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${total.toStringAsFixed(2)} ",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),

                      Text(
                        'Date: $dateOrder',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 8,
                            backgroundColor: status == 'pending'
                                ? Colors.orange
                                : Colors.green,
                          ),
                          SizedBox(width: 3),
                          Text("Status: "),
                          if (status == 'pending')
                            Text('Pending')
                          else
                            Text('Confirme'),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
