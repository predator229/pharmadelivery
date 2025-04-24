import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pharmadelivery/controllers/auth.provider.controller.dart';
import 'package:pharmadelivery/models/auth.class.dart';
import 'package:pharmadelivery/models/settings.class.dart';
import 'package:pharmadelivery/models/user.register.class.dart';
import 'package:pharmadelivery/views/homeview.view.dart';
// import 'package:pharmadelivery/views/profil.view.dart';
import 'package:pharmadelivery/views/welcome.view.dart';
import 'package:http/http.dart' as http;

import 'apis.controller.dart';

class RoutePage extends StatefulWidget {
  static const routeName = '/first-page';
  const RoutePage({super.key});

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  @override
  Widget build(BuildContext context) {
    final BaseAuth auth = AuthProviders.of(context).auth;

    return StreamBuilder<User?>(
      stream: auth.onAuthStatusChanged,
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return FutureBuilder<dynamic>(
              future: ApiController().post('users/authentificate', {'uid': FirebaseAuth.instance.currentUser?.uid}),
              builder: (context, authSnapshot) {
                if (authSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (authSnapshot.hasError || authSnapshot.data == null) {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Une erreur est survenue. Veuillez vous reconnecter.')),
                    );
                    auth.signOut();
                  });
                  return const CircularProgressIndicator();
                } else if (authSnapshot.hasData && authSnapshot.data['error'] != null && authSnapshot.data['error'] == 0 ) {
                  auth.userConected = UserRegisterClass.fromJson(authSnapshot.data['user']);
                  return auth.userConected != null ? HomeView() : WelcomeView();
                }
                return CircularProgressIndicator();
              },
            );
          }
          return WelcomeView();
        }
        return const CircularProgressIndicator();
      },
    );
  }
}

