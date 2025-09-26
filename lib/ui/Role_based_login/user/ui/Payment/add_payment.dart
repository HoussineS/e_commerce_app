import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/widget/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class AddPayment extends StatefulWidget {
  const AddPayment({super.key});

  @override
  State<AddPayment> createState() => _AddPaymentState();
}

class _AddPaymentState extends State<AddPayment> {
  final _formKey = GlobalKey<FormState>();
  Future<List<Map<String, dynamic>>> fecthPaymentsMethodes() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('payments_methodes')
        .get();
    return snapshot.docs
        .map((doc) => {'name': doc['name'], 'image': doc['image']})
        .toList();
  }

  final TextEditingController _cartNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _cartNumberController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  bool _isWaiting = false;
  final maskFormater = MaskTextInputFormatter(
    mask: '**** **** **** ****',
    filter: {'*': RegExp(r'[0-9]')},
  );
  String? selectedPaymentMethode;
  Map<String, dynamic>? selectedPaymentMethodeData;
  double balance = 0.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Payment methode'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                FutureBuilder(
                  future: fecthPaymentsMethodes(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text(
                        'Error on loading payment methode ${snapshot.error}',
                        style: TextStyle(color: Colors.red),
                      );
                    }
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    return DropdownButton<String>(
                      elevation: 2,

                      value: selectedPaymentMethode,
                      hint: Text('Select payment methode'),
                      items: snapshot.data!.map((paymentMethode) {
                        return DropdownMenuItem<String>(
                          value: paymentMethode['name'],
                          child: Row(
                            children: [
                              CachedNetworkImage(
                                imageUrl: paymentMethode['image'],
                                height: 30,
                                width: 30,
                                errorWidget: (context, url, error) {
                                  return Icon(Icons.error);
                                },
                              ),
                              SizedBox(width: 10),
                              Text(paymentMethode['name']),
                            ],
                          ),
                        );
                      }).toList(),

                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethode = value;
                          selectedPaymentMethodeData = snapshot.data
                              ?.firstWhere(
                                (element) => element['name'] == value,
                              );
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _userNameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: 'Cart holder name',
                    hintText: 'eg.Jon Doe',
                    border: const OutlineInputBorder(),
                  ),

                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Provide you full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _cartNameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: 'Cart name',
                    hintText: 'eg.Mastercard',
                    border: const OutlineInputBorder(),
                  ),

                  validator: (value) {
                    if (value == null || value.length < 2) {
                      return 'Name of the cart is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _cartNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Cart Number',
                    hintText: 'eg.1234 5678 9012 3456',
                    border: const OutlineInputBorder(),
                  ),
                  inputFormatters: [maskFormater],
                  validator: (value) {
                    if (value == null ||
                        value.replaceAll(' ', '').length != 16) {
                      return 'Cart number must be exactly 16!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _balanceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Balance',
                    hintText: 'eg.40',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    balance = double.tryParse(value) ?? 0.0;
                  },
                ),
                const SizedBox(height: 10),
                _isWaiting
                    ? CircularProgressIndicator()
                    : MyButton(
                        onTab: () {
                          _addPaymentMethode();
                        },
                        text: 'Add payment methode',
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addPaymentMethode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final paymentMethodeCollection = FirebaseFirestore.instance.collection(
      'User payment methode',
    );
    if (userId != null && selectedPaymentMethodeData != null) {
      setState(() {
        _isWaiting = true;
      });
      final existMethode = await paymentMethodeCollection
          .where('userId', isEqualTo: userId)
          .where(
            'paymentMethode',
            isEqualTo: selectedPaymentMethodeData!['name'],
          )
          .get();
      if (existMethode.docs.isNotEmpty) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You alreday have this payment methode'),
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {
          _isWaiting = false; // reset spinner
        });
        return;
      }
      await paymentMethodeCollection.add({
        'userName': _userNameController.text,
        'nameOfCart': _cartNameController.text,
        'numeroOfCart': _cartNumberController.text.trim(),
        'balance': balance,
        'userId': userId,
        'paymentMethode': selectedPaymentMethodeData!['name'],
        'image': selectedPaymentMethodeData!['image'],
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${selectedPaymentMethodeData!['name']} added successfuly ',
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      setState(() {
        _isWaiting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed add payment methode '),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
