import 'package:flutter/material.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({Key? key}) : super(key: key);

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  int selectedAddressIndex = 0; // Default selected address

  final List<Map<String, dynamic>> addresses = [
    {
      'name': 'Hiren Thakkar',
      'addressLine1': '3 Old Yard Pedak Road',
      'city': 'Rajkot',
      'state': 'Gujrat',
      'zip': '360003',
      'country': 'India',
    },
    {
      'name': 'Vatsal Suliya',
      'addressLine1': '3 Newbridge Court',
      'city': 'Jasdan',
      'state': 'Gujrat',
      'zip': '360003',
      'country': 'India',
    },
    {
      'name': 'Hiren Thakkar',
      'addressLine1': '3 Old Yard Pedak Road',
      'city': 'Rajkot',
      'state': 'Gujrat',
      'zip': '360003',
      'country': 'India',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Shipping Addresses',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final address = addresses[index];
          return _buildAddressCard(address, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add functionality for adding new address
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white,),
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address, int index) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  address['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Handle edit address action
                  },
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${address['addressLine1']},'),
            Text('${address['city']}, ${address['state']} ${address['zip']},'),
            Text('${address['country']}'),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: selectedAddressIndex == index,
                  onChanged: (value) {
                    setState(() {
                      selectedAddressIndex = index; // Set selected address
                    });
                  },
                  activeColor: Colors.black,
                ),
                const Text('Use as the shipping address'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
