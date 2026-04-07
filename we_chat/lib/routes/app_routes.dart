import 'package:flutter/material.dart';
import 'package:we_chat/View/auth/login_page.dart';
import 'package:we_chat/View/auth/signup_page.dart';
import 'package:we_chat/View/home_page.dart';

class AppRoutes {
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';

  static Map<String, WidgetBuilder> routes = {
    login: (_) => LoginPage(),
    signup: (_) => SignupPage(),
    home: (_) => HomePage(),
  };
}