import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  _PaymentMethodsScreenState createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  int _selectedCardIndex = 0; // Default to the first card

  final List<Map<String, dynamic>> _paymentCards = [
    {
      'cardNumber': '**** **** **** 3947',
      'expiryDate': '05/23',
      'cardHolderName': 'Jennyfer Doe',
      'brand': 'Mastercard',
    },
    {
      'cardNumber': '**** **** **** 4546',
      'expiryDate': '11/22',
      'cardHolderName': 'Jennyfer Doe',
      'brand': 'Visa',
    },
  ];

  void _showAddCardBottomSheet(BuildContext context) {
    String cardHolderName = '';
    String cardNumber = '';
    String expiryDate = '';
    String cvv = '';
    bool isDefault = false;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      isScrollControlled: true, // To prevent the keyboard from covering the modal
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add new card',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Name on card',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    cardHolderName = value;
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Card number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: Image.asset('assets/images/mastercard_logo.png', width: 40), // Default card logo
                  ),
                  onChanged: (value) {
                    cardNumber = value;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Expire Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          expiryDate = value;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'CVV',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: const Icon(Icons.help_outline),
                        ),
                        onChanged: (value) {
                          cvv = value;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CheckboxListTile(
                  value: isDefault, // Default to unchecked
                  onChanged: (value) {
                    setState(() {
                      isDefault = value!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Set as default payment method'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Validate form fields
                    if (cardHolderName.isNotEmpty && cardNumber.isNotEmpty && expiryDate.isNotEmpty && cvv.isNotEmpty) {
                      setState(() {
                        _paymentCards.add({
                          'cardNumber': '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}',
                          'expiryDate': expiryDate,
                          'cardHolderName': cardHolderName,
                          'brand': 'Mastercard', // Default to Mastercard for now
                          'isDefault': isDefault,
                        });

                        if (isDefault) {
                          _selectedCardIndex = _paymentCards.length - 1; // Set the newly added card as default
                        }
                      });
                      Navigator.pop(context); // Close the modal
                    } else {
                      // Show validation error (optional)
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Add your button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text(
                    'ADD CARD',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Payment methods',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Your payment cards',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _paymentCards.length,
                itemBuilder: (context, index) {
                  return _buildPaymentCard(
                    index,
                    _paymentCards[index]['cardNumber'],
                    _paymentCards[index]['expiryDate'],
                    _paymentCards[index]['cardHolderName'],
                    _paymentCards[index]['brand'],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            FloatingActionButton(
              onPressed: () {
                _showAddCardBottomSheet(context); // Trigger the bottom sheet when plus is clicked
              },
              backgroundColor: Colors.black,
              child: const Icon(Icons.add, color: Colors.white),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(int index, String cardNumber, String expiryDate, String cardHolderName, String brand) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCardIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: _selectedCardIndex == index ? Colors.grey.shade300 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Image.asset(
                  'assets/images/${brand.toLowerCase()}_logo.png', // Add your Visa/Mastercard logos here
                  width: 40,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                cardNumber,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _selectedCardIndex == index ? Colors.black : Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Card Holder Name: $cardHolderName',
                style: TextStyle(
                  fontSize: 14,
                  color: _selectedCardIndex == index ? Colors.black : Colors.black,
                ),
              ),
              Text(
                'Expiry Date: $expiryDate',
                style: TextStyle(
                  fontSize: 14,
                  color: _selectedCardIndex == index ? Colors.black : Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _selectedCardIndex == index,
                    onChanged: (value) {
                      setState(() {
                        _selectedCardIndex = index;
                      });
                    },
                    checkColor: Colors.white,
                    activeColor: Colors.black,
                  ),
                  const Text(
                    'Use as default payment method',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
