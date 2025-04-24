import 'package:flutter/material.dart';
import 'package:pharmadelivery/models/auth.class.dart';

class AuthProviders extends InheritedWidget {
  const AuthProviders({required Key key, required Widget child, required this.auth}) : super(key: key, child: child);

  final BaseAuth auth;

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static AuthProviders of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthProviders>()!;
  }
}