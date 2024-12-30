import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/http_exceptions.dart';
class Auth with ChangeNotifier{
   String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }
  Future<void> _authenticate(String email, String password, String ulrSegment) async{
     String sturl = 'https://identitytoolkit.googleapis.com/v1/accounts:$ulrSegment?key=AIzaSyCOvRCCiePEX_wZDXKxShbwb38ZsnYtNec';
    Uri url = Uri.parse(sturl);
    try{
    final response = await http.post(url, body: json.encode({
      'email': email,
      'password': password,
      'returnSecureToken': true,
    }),
    headers: {'Content-Type': 'application/json'},
    );
    print(json.decode(response.body));

     final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

       _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({'token': _token, 'userId': _userId, 'expiryDate': _expiryDate?.toIso8601String()});
      prefs.setString('userData', userData);
      print('User data saved: $userData');
    } catch (error){
      throw error;
    }
  }

Future<bool> tryAutoLogin() async {
  final prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey('userData')) {
    return false;
  }

  final userData = prefs.getString('userData');
  if (userData == null) {
    return false;
  }

  try {
    final extractedData = json.decode(userData) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(extractedData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      print("Hello From TryAutoLogin");
      prefs.remove('userData'); // Cleanup expired data
      return false;
    }

    _token = extractedData['token'];
    _expiryDate = expiryDate;
    _userId = extractedData['userId'];
    notifyListeners();

    if (_expiryDate != null) {
      _autoLogout();
    }
    return true;
  } catch (error) {
    print("Error during auto-login: $error");
    return false;
  }
}


  Future<void> signup(String email, String password) async{
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signin(String email, String password) async{
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<void> logout() async{
    _token = null;
    _userId = null;
    _expiryDate = null;
     if (_authTimer != null) {
      _authTimer?.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();

  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer?.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}