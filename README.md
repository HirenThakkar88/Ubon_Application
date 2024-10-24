# Ubon Application

**Ubon Application** is an e-commerce platform designed to offer users a seamless online shopping experience. Built with a robust and scalable architecture, this project enables customers to browse products, add items to their cart, and securely complete transactions.

## Features

- **Product Catalog**: Explore a variety of products with detailed descriptions and pricing.
- **Shopping Cart**: Add, remove, or adjust quantities of items in your cart.
- **User Authentication**: Secure login and registration using Firebase Authentication (Email/Password and social login options).
- **Order Tracking**: Monitor your order's status in real time.
- **Payment Gateway**: Integration with secure payment methods for smooth transactions.
- **Wishlist**: Save products to your favorites for future purchases.
- **Coupons & Discounts**: Apply promotional codes to get discounts.
- **Notifications**: Receive real-time notifications about new products and offers using Firebase Cloud Messaging (FCM).
- **Search & Filter**: Easily find products using the search and filter functionalities.
- **Data Storage**: All product and user data is securely stored in Firebase Firestore.

## Tech Stack

- **Frontend**: Flutter
- **Backend**: Firebase (Firestore, Authentication, Cloud Messaging, and more)
- **State Management**: Flutter Bloc

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/ubon_application.git
   cd ubon_application
2. Install dependencies:
   flutter pub get
3. Set up Firebase:
   Go to the Firebase Console and create a new project.
Enable Firebase Authentication, Firestore, and Cloud Messaging.
Download the google-services.json file and place it in the android/app directory.
(For iOS) Download the GoogleService-Info.plist file and place it in the ios/Runner directory.
4. Run the app:
   flutter run

## Contributing
Contributions are welcome! Feel free to submit a pull request or open an issue to discuss improvements.

## License
This project is licensed under the MIT License - see the LICENSE file for details.

You can add this file directly to your project's root directory as `README.md`.
