import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class PaymentOptionScreen extends StatefulWidget {
  final String selectedAddress;

  const PaymentOptionScreen({Key? key, required this.selectedAddress})
      : super(key: key);

  @override
  State<PaymentOptionScreen> createState() => _PaymentOptionScreenState();
}

class _PaymentOptionScreenState extends State<PaymentOptionScreen> {
  String? selectedPaymentMethod;
  String? selectedUPI;
  bool isPaymentSuccessful = false;

  Future<void> handlePayment() async {
    if (selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment option')),
      );
      return;
    }

    setState(() {
      isPaymentSuccessful = true;
    });

    // Simulate a payment delay
    await Future.delayed(const Duration(seconds: 3));

    await saveOrderToDatabase();

    setState(() {
      isPaymentSuccessful = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment Successful! Order Placed')),
    );

    Navigator.pop(context);
  }

  Future<void> saveOrderToDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    final authId = prefs.getString('uid');

    if (authId != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('authentication')
          .where('auth_id', isEqualTo: authId)
          .get();

      if (userDoc.docs.isNotEmpty) {
        final userData = userDoc.docs.first.data();

        // Fetch bag items
        final bagItemsSnapshot = await FirebaseFirestore.instance
            .collection('authentication')
            .doc(userDoc.docs.first.id)
            .collection('bag')
            .get();

        final bagItems = bagItemsSnapshot.docs.map((doc) {
          return {'id': doc.id, ...doc.data()};
        }).toList();

        final orderId = FirebaseFirestore.instance.collection('orders').doc().id;

        final orderData = {
          'auth_id': authId,
          'addresses': widget.selectedAddress,
          'email': userData['email'] ?? '',
          'profileImageUrl': userData['profileImageUrl'] ?? '',
          'orderId': orderId,
          'orderItems': bagItems.map((item) {
            return {
              'productName': item['productName'] ?? '',
              'quantity': item['quantity'] ?? 0,
              'productImage': item['productImage'] ?? '',
              'totalPrice': item['offerPrice'] * item['quantity'] ?? 0.0,
            };
          }).toList(),
          'totalPrice': bagItems.fold<double>(
            0.0,
                (sum, item) =>
            sum + (item['offerPrice'] ?? 0.0) * (item['quantity'] ?? 0),
          ),
          'paymentMode': selectedPaymentMethod,
          'paymentStatus': selectedPaymentMethod == 'COD' ? 'Pending' : 'Success',
          'orderStatus': 'Pending',
          'createdAt': FieldValue.serverTimestamp(),
        };

        // Save to `orders` collection
        await FirebaseFirestore.instance.collection('orders').doc(orderId).set(orderData);

        // Clear bag items after successful order
        for (var bagItem in bagItems) {
          await FirebaseFirestore.instance
              .collection('authentication')
              .doc(userDoc.docs.first.id)
              .collection('bag')
              .doc(bagItem['id'])
              .delete();
        }
      }
    }
  }

  Widget netBankingFields() {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(labelText: 'Enter Net Banking ID'),
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Enter Password'),
          obscureText: true,
        ),
      ],
    );
  }

  Widget cardFields() {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(labelText: 'Card Number'),
          keyboardType: TextInputType.number,
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Expiry Date'),
          keyboardType: TextInputType.datetime,
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'CVV'),
          obscureText: true,
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Cardholder Name'),
        ),
      ],
    );
  }

  Widget upiOptions(double screenWidth) {
    List<Map<String, String>> upiApps = [
      {'name': 'Google Pay', 'image': 'assets/images/Google-Pay-hero_1.png'},
      {'name': 'PhonePe', 'image': 'assets/images/phone_pay.png'},
      {'name': 'BharatPe', 'image': 'assets/images/bharat_pay.jpg'},
      {'name': 'CRED', 'image': 'assets/images/cred_logo.png'},
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: upiApps.map((upi) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedUPI = upi['name'];
            });
          },
          child: Container(
            width: screenWidth * 0.4,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                  color: selectedUPI == upi['name'] ? Colors.green : Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Image.asset(
                  upi['image']!,
                  height: screenWidth * 0.2,
                  width: screenWidth * 0.2,
                ),
                const SizedBox(height: 5),
                Text(upi['name']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: screenWidth * 0.04)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Payment Option'),
        centerTitle: true,
      ),
      body: isPaymentSuccessful
          ? Center(
        child: Lottie.asset('assets/animations/Payment_success.json'),
      )
          : Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: const Text('Netbanking'),
                  leading: const Icon(Icons.account_balance),
                  onTap: () {
                    setState(() {
                      selectedPaymentMethod = 'Netbanking';
                    });
                  },
                ),
                ListTile(
                  title: const Text('Card'),
                  leading: const Icon(Icons.credit_card),
                  onTap: () {
                    setState(() {
                      selectedPaymentMethod = 'Card';
                    });
                  },
                ),
                ListTile(
                  title: const Text('Online/UPI'),
                  leading: const Icon(Icons.qr_code),
                  onTap: () {
                    setState(() {
                      selectedPaymentMethod = 'Online/UPI';
                    });
                  },
                ),
                ListTile(
                  title: const Text('Cash on Delivery (COD)'),
                  leading: const Icon(Icons.money),
                  onTap: () {
                    setState(() {
                      selectedPaymentMethod = 'COD';
                    });
                  },
                ),
                const Divider(),
                selectedPaymentMethod == 'Netbanking'
                    ? netBankingFields()
                    : selectedPaymentMethod == 'Card'
                    ? cardFields()
                    : selectedPaymentMethod == 'Online/UPI'
                    ? upiOptions(screenWidth)
                    : const Center(child: Text('COD Selected')),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: handlePayment,
            child: const Text('Confirm Payment'),
          ),
        ],
      ),
    );
  }
}
