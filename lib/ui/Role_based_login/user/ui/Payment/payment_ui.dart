import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/ui/Role_based_login/user/ui/Payment/add_payment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PaymentUi extends StatefulWidget {
  const PaymentUi({super.key});

  @override
  State<PaymentUi> createState() => _PaymentUiState();
}

class _PaymentUiState extends State<PaymentUi> {
  @override
  void initState() {
    userId = FirebaseAuth.instance.currentUser?.uid;
    super.initState();
  }

  String? erroText;
  String? userId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment'), centerTitle: true),
      body: userId == null
          ? Center(child: Text('You need a account'))
          : SizedBox(
              height: double.maxFinite,
              width: double.maxFinite,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('User payment methode')
                    .where('userId', isEqualTo: userId!)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final methods = snapshot.data!.docs;
                  if (methods.isEmpty) {
                    return Center(
                      child: Text('No payment methode yet.Please add one!'),
                    );
                  }
                  return ListView.builder(
                    itemCount: methods.length,
                    itemBuilder: (context, index) {
                      final methode = methods[index].data();

                      return ListTile(
                        leading: CachedNetworkImage(
                          imageUrl: methode['image'],
                          height: 50,
                          width: 50,
                        ),
                        title: Text(methode['paymentMethode']),
                        subtitle: Text(
                          'Activate',
                          style: TextStyle(color: Colors.green),
                        ),
                        trailing: MaterialButton(
                          onPressed: () {
                            showFundDialog(context, methods[index]);
                          },
                          child: Text('Add fund'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => AddPayment()));
        },
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        child: Icon(Icons.add, size: 30),
      ),
    );
  }

  void showFundDialog(BuildContext context, DocumentSnapshot snapshot) {
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Add fund'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            labelText: 'Amount',
            prefixText: '\$',
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final isValid = double.tryParse(amountController.text);
              if (isValid == null ||
                  isValid <= 0 ||
                  amountController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Enter a possitive Amount',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                await snapshot.reference.update({
                  'balance': FieldValue.increment(isValid),
                });
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Added \$$isValid to ${snapshot['paymentMethode']}',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}
