import 'dart:convert';

import 'package:flutter/foundation.dart';

import './cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String? authToken;
  final String? userId;

  Orders(this.authToken, this.userId,this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
  String StringUrl = 'https://shop-app-c2c23-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
  Uri url = Uri.parse(StringUrl);

  try {
    final response = await http.get(url);

    // Check if the response was successful
    if (response.statusCode != 200) {
      throw Exception('Failed to load orders. Status code: ${response.statusCode}');
    }

    final List<OrderItem> loadedOrders = [];

    // Check if the response body is empty
    if (response.body.isEmpty) {
      return; // Handle the empty response case
    }

    // Decode the response body
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    // Check if extractedData is empty
    if (extractedData.isEmpty) {
      return; // Handle the case when there are no orders
    }

    // Map over the data and create order items
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item['id'],
                  price: item['price'],
                  quantity: item['quantity'],
                  title: item['title'],
                ),
              )
              .toList(),
        ),
      );
    });

    // Reverse the orders and update the _orders list
    _orders = loadedOrders.reversed.toList();
    notifyListeners();

  } catch (error) {
    // Handle errors (network issues, JSON decoding errors, etc.)
    print('Error fetching orders: $error');
  }
}



  Future<void> addOrder(List<CartItem> cartProducts, double total) async{
    String StringUrl =
        'https://shop-app-c2c23-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    Uri url = Uri.parse(StringUrl);
    final timestamp = DateTime.now();
   final response = await http.post(url, body: json.encode({
      'amount': total,
      'dateTime': timestamp.toIso8601String(),
      'products': cartProducts.map((cp) =>{
        'id': cp.id,
        'title': cp.title,
        'quantity': cp.quantity,
        'price' : cp.price
      }).toList(),
    }));

    if (response.statusCode >= 400) {
      throw Exception("Failed to place order");
    }
    
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        dateTime: timestamp,
        products: cartProducts,
      ),
    );
    notifyListeners();
  }
}
