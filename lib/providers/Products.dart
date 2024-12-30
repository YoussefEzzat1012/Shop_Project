import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exceptions.dart';
import 'product.dart';

class Products with ChangeNotifier {
  final authToken;
  final userId;
  Products(this.authToken, this.userId, this._items);

  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  List<Product> get items {
    return [..._items];
  }

  Future<void> fetchProducts([bool filterByUser = false]) async {
    final String filterString =
        filterByUser ? 'orderBy=%22creatorId%22&equalTo=%22$userId%22' : '';
    String StringUrl =
        'https://shop-app-c2c23-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString';
    Uri url = Uri.parse(StringUrl);

    try {
      final response = await http.get(url);

      final extractData = json.decode(response.body) as Map<String, dynamic>;
      if (extractData.isEmpty) {
        return;
      }

      final urlstring =
          'https://shop-app-c2c23-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      Uri url_fav = Uri.parse(urlstring);
      final favResponse = await http.get(url_fav);
      final favData = json.decode(favResponse.body);
      final List<Product> loadedData = [];
      extractData.forEach((prodId, prodData) {
        loadedData.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            isFavorite: favData == null ? false : favData[prodId] ?? false,
            imageUrl: prodData['imageUrl'],
            price: prodData['price']));
      });
      _items = loadedData;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    String StringUrl =
        'https://shop-app-c2c23-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    Uri url = Uri.parse(StringUrl);
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'id': product.id,
            'creatorId': userId,
          }));
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
        creatorId: userId,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }

    // _items.insert(0, newProduct); // at the start of the list
  }

  List<Product> get favoriteItems {
    return _items.where((prod) => prod.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => id == prod.id);
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final urlsring =
          'https://shop-app-c2c23-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
      Uri url = Uri.parse(urlsring);
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final urlsring =
        'https://shop-app-c2c23-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    Uri url = Uri.parse(urlsring);
    final _existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? _existingProduct = _items[_existingProductIndex];
    _items.removeAt(_existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(_existingProductIndex, _existingProduct as Product);
      notifyListeners();
      throw HttpException('could not deleting the product');
    }

    _existingProduct = null;
  }
}
