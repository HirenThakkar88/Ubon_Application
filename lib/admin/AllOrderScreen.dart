import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Define the Order model
class Order {
  final String addresses;
  final String authId;
  final DateTime createdAt;
  final String email;
  final String orderId;
  final List<dynamic> orderItems;
  final String orderStatus;
  final String paymentMode;
  final String paymentStatus;
  final String profileImageUrl;
  final String? trackingNumber; // Optional field

  Order({
    required this.addresses,
    required this.authId,
    required this.createdAt,
    required this.email,
    required this.orderId,
    required this.orderItems,
    required this.orderStatus,
    required this.paymentMode,
    required this.paymentStatus,
    required this.profileImageUrl,
    this.trackingNumber,
  });

  factory Order.fromMap(Map<String, dynamic> data) {
    return Order(
      addresses: data['addresses'] ?? '',
      authId: data['auth_id'] ?? '',
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      email: data['email'] ?? '',
      orderId: data['orderId'] ?? '',
      orderItems: data['orderItems'] ?? [],
      orderStatus: data['orderStatus'] ?? 'Pending',
      paymentMode: data['paymentMode'] ?? '',
      paymentStatus: data['paymentStatus'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      trackingNumber: data['trackingNumber'], // Fetch optional field
    );
  }
}

Future<List<Order>> fetchOrders() async {
  final querySnapshot = await FirebaseFirestore.instance.collection('orders').get();
  return querySnapshot.docs.map((doc) => Order.fromMap(doc.data())).toList();
}

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({Key? key}) : super(key: key);

  @override
  _AllOrdersScreenState createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = fetchOrders();
  }

  void _deleteOrder(String orderId) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order $orderId deleted successfully')),
      );
      setState(() {
        _ordersFuture = fetchOrders();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete order: $e')),
      );
    }
  }

  void _editOrder(BuildContext context, Order order) {
    String updatedStatus = order.orderStatus;
    String? updatedTrackingNumber = order.trackingNumber;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Order Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: updatedStatus,
                items: const [
                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'Delivered', child: Text('Delivered')),
                  DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    updatedStatus = value;
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Order Status',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: updatedTrackingNumber,
                onChanged: (value) {
                  updatedTrackingNumber = value.isNotEmpty ? value : null;
                },
                decoration: InputDecoration(
                  labelText: 'Tracking Number (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('orders')
                      .doc(order.orderId)
                      .update({
                    'orderStatus': updatedStatus,
                    'trackingNumber': updatedTrackingNumber,
                  });
                  setState(() {
                    _ordersFuture = fetchOrders();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Order updated successfully.')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update order: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Orders"),
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          } else {
            final orders = snapshot.data!;
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Profile')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Order ID')),
                    DataColumn(label: Text('Order Items')),
                    DataColumn(label: Text('Order Status')),
                    DataColumn(label: Text('Tracking Number')),
                    DataColumn(label: Text('Payment Mode')),
                    DataColumn(label: Text('Payment Status')),
                    DataColumn(label: Text('Created At')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: orders.map((order) {
                    return DataRow(cells: [
                      DataCell(
                        CircleAvatar(
                          backgroundImage: NetworkImage(order.profileImageUrl),
                          onBackgroundImageError: (_, __) =>
                          const Icon(Icons.account_circle),
                        ),
                      ),
                      DataCell(Text(order.email)),
                      DataCell(Text(order.orderId)),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: order.orderItems.map<Widget>((item) {
                            return Text(
                                "Name: ${item['productName']}, Qty: ${item['quantity']}, Price: ${item['totalPrice']}");
                          }).toList(),
                        ),
                      ),
                      DataCell(Text(order.orderStatus)),
                      DataCell(Text(order.trackingNumber ?? 'Not Available')),
                      DataCell(Text(order.paymentMode)),
                      DataCell(Text(order.paymentStatus)),
                      DataCell(Text(order.createdAt.toString())),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _editOrder(context, order);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteOrder(order.orderId);
                              },
                            ),
                          ],
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
