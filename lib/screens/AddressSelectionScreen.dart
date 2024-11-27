import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'PaymentOptionScreen.dart';

class AddressSelectionScreen extends StatefulWidget {
  const AddressSelectionScreen({Key? key}) : super(key: key);

  @override
  _AddressSelectionScreenState createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  List<Map<String, dynamic>> addresses = [];
  String? selectedAddress;
  bool isLoading = true; // Loading indicator state

  @override
  void initState() {
    super.initState();
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('uid');

      if (userId == null) {
        throw Exception('User ID not found in SharedPreferences');
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('authentication')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data['addresses'] is List) {
          setState(() {
            addresses = List<Map<String, dynamic>>.from(data['addresses']);
          });
        } else {
          throw Exception('No addresses found for this user.');
        }
      } else {
        throw Exception('User document does not exist.');
      }
    } catch (e) {
      print('Error fetching addresses: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch addresses: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void proceedToPayment() {
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an address to continue.')),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentOptionScreen(selectedAddress: selectedAddress!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Address'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : addresses.isEmpty
          ? const Center(child: Text('No addresses available.'))
          : ListView.builder(
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final address = addresses[index];

          final name = address['name'] ?? 'Unnamed Address'; // Provide fallback
          final addressLine = address['addressLine1'] ?? 'Unnamed Address'; // Provide fallback
          final city = address['city'] ?? 'No city provided'; // Provide fallback

          return RadioListTile<String>(
            title: Text(addressLine),
            subtitle: Text(city,),

            value: addressLine, // Ensure it's non-null
            groupValue: selectedAddress,
            onChanged: (value) {
              setState(() {
                selectedAddress = value;
              });
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: proceedToPayment,
          child: const Text('Proceed to Payment'),
        ),
      ),
    );
  }
}
