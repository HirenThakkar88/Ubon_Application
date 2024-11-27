import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({Key? key}) : super(key: key);

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  int selectedAddressIndex = 0; // Default selected address
  List<Map<String, dynamic>> addresses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('uid');

      if (userId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('authentication')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null && data['addresses'] != null) {
            setState(() {
              addresses = List<Map<String, dynamic>>.from(data['addresses']);
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching addresses: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addAddress(Map<String, dynamic> newAddress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('uid');

      if (userId != null) {
        final userDocRef =
        FirebaseFirestore.instance.collection('authentication').doc(userId);

        // Update Firestore with the new address
        await userDocRef.update({
          'addresses': FieldValue.arrayUnion([newAddress])
        });

        // Update the local state
        setState(() {
          addresses.add(newAddress);
        });
      }
    } catch (e) {
      print('Error adding address: $e');
    }
  }

  Future<void> _updateAddress(Map<String, dynamic> updatedAddress, int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('uid');

      if (userId != null) {
        final userDocRef =
        FirebaseFirestore.instance.collection('authentication').doc(userId);

        // Update Firestore with the updated address
        await userDocRef.update({
          'addresses': FieldValue.arrayRemove([addresses[index]]),
        });

        await userDocRef.update({
          'addresses': FieldValue.arrayUnion([updatedAddress]),
        });

        // Update the local state
        setState(() {
          addresses[index] = updatedAddress;
        });
      }
    } catch (e) {
      print('Error updating address: $e');
    }
  }

  void _showAddAddressDialog() {
    final nameController = TextEditingController();
    final addressLine1Controller = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();
    final zipController = TextEditingController();
    final countryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Address'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(nameController, 'Name'),
                _buildTextField(addressLine1Controller, 'Address Line 1'),
                _buildTextField(cityController, 'City'),
                _buildTextField(stateController, 'State'),
                _buildTextField(zipController, 'ZIP Code'),
                _buildTextField(countryController, 'Country'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newAddress = {
                  'name': nameController.text.trim(),
                  'addressLine1': addressLine1Controller.text.trim(),
                  'city': cityController.text.trim(),
                  'state': stateController.text.trim(),
                  'zip': zipController.text.trim(),
                  'country': countryController.text.trim(),
                };

                _addAddress(newAddress);
                Navigator.pop(context); // Close dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showEditAddressDialog(Map<String, dynamic> currentAddress, int index) {
    final nameController = TextEditingController(text: currentAddress['name']);
    final addressLine1Controller = TextEditingController(text: currentAddress['addressLine1']);
    final cityController = TextEditingController(text: currentAddress['city']);
    final stateController = TextEditingController(text: currentAddress['state']);
    final zipController = TextEditingController(text: currentAddress['zip']);
    final countryController = TextEditingController(text: currentAddress['country']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Address'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(nameController, 'Name'),
                _buildTextField(addressLine1Controller, 'Address Line 1'),
                _buildTextField(cityController, 'City'),
                _buildTextField(stateController, 'State'),
                _buildTextField(zipController, 'ZIP Code'),
                _buildTextField(countryController, 'Country'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final updatedAddress = {
                  'name': nameController.text.trim(),
                  'addressLine1': addressLine1Controller.text.trim(),
                  'city': cityController.text.trim(),
                  'state': stateController.text.trim(),
                  'zip': zipController.text.trim(),
                  'country': countryController.text.trim(),
                };

                _updateAddress(updatedAddress, index);
                Navigator.pop(context); // Close dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String placeholder) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: placeholder,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : addresses.isEmpty
          ? const Center(child: Text('No addresses added.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final address = addresses[index];
          return _buildAddressCard(address, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAddressDialog,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
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
                  address['name'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _showEditAddressDialog(address, index);
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
