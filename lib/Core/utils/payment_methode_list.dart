import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PaymentMethodeList extends StatefulWidget {
  final String? selectedPaymentMethodeId;
  final double? balance;
  final double? total;
  final Function(String? methodeId, String? methodeName, double? balance)
  onSelectePaymentMethode;
  const PaymentMethodeList({
    super.key,
    required this.selectedPaymentMethodeId,
    required this.balance,
    required this.total,
    required this.onSelectePaymentMethode,
  });

  @override
  State<PaymentMethodeList> createState() => _PaymentMethodeListState();
}

class _PaymentMethodeListState extends State<PaymentMethodeList> {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('User payment methode')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final paymentMethods = snapshot.data!.docs;
        if (paymentMethods.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('No payment methode avilabel'),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Click here to add one',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: paymentMethods.length,
          itemBuilder: (context, index) {
            final methode = paymentMethods[index].data();
            final methodeId = paymentMethods[index].id;
            return Material(
              color: widget.selectedPaymentMethodeId == methodeId
                  ? Colors.blue[300]
                  : Colors.transparent,
              child: ListTile(
                leading: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(methode['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(methode['paymentMethode']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [avilableBalance(methode['balance'], widget.total)],
                ),
                selected: widget.selectedPaymentMethodeId == methodeId,
                onTap: () => widget.onSelectePaymentMethode(
                  methodeId,
                  methode['paymentMethode'],
                  (methode['balance'] as num).toDouble(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget avilableBalance(balance, amount) {
    return Column(
      children: [
        if (balance >= amount)
          Text('Acivate', style: TextStyle(color: Colors.green)),
        if (balance < amount)
          Text('Insifficent Balance', style: TextStyle(color: Colors.red)),
      ],
    );
  }
}
