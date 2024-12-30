import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart'  as http;


class Product with ChangeNotifier{

 final String? id;
 final String title;
 final String description;
 final double price;
 final String imageUrl;
 final String? creatorId;
 bool isFavorite;


 Product({
  required this.id,
  required this.title,
  required this.description,
  required this.imageUrl,
  required this.price,
  this.creatorId,
  this.isFavorite = false
 });

 void _setFavValue(bool newValue) {
  isFavorite = newValue;
  notifyListeners();
 }

 Future<void> toggoleFavorite(String? token, String? userId) async{
  
  final _oldStatus = isFavorite;
  isFavorite = !isFavorite;
  notifyListeners();


final urlstring = 'https://shop-app-c2c23-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';
  Uri url = Uri.parse(urlstring);

  try{
  final response = await http.put(url, body: json.encode(
    isFavorite,
  ));

  if (response.statusCode >= 400) {
      _setFavValue(_oldStatus);
  }
  } catch(error) {
    _setFavValue(_oldStatus);
  }
 
 }

}