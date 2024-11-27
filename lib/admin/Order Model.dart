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
  });

  factory Order.fromMap(Map<String, dynamic> data) {
    return Order(
      addresses: data['addresses'] ?? '',
      authId: data['auth_id'] ?? '',
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      email: data['email'] ?? '',
      orderId: data['orderId'] ?? '',
      orderItems: data['orderItems'] ?? [],
      orderStatus: data['orderStatus'] ?? '',
      paymentMode: data['paymentMode'] ?? '',
      paymentStatus: data['paymentStatus'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
    );
  }
}
