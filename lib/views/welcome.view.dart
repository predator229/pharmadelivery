import 'package:pharmadelivery/models/auth.class.dart';
import 'package:pharmadelivery/models/settings.class.dart';
import 'package:pharmadelivery/views/authentifications/login.view.dart';
import 'package:pharmadelivery/views/authentifications/register.view.dart';
import 'package:flutter/material.dart';

import '../controllers/auth.provider.controller.dart';

class WelcomeView extends StatefulWidget {
  static const String routeName = '/home';
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  late BaseAuth auth;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: const Offset(-0.03, 0.0),
      end: const Offset(0.03, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    auth = AuthProviders.of(context).auth;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PharmaDelivery',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                flex: 2,
                child: SlideTransition(
                  position: _animation,
                  child: Hero(
                    tag: 'logo',
                    child: Image.asset(
                      "assets/images/camien.png",
                      width: MediaQuery.of(context).size.width * 0.7 < 400 ? MediaQuery.of(context).size.width * 0.7 : 400,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, RegisterView.routeName);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        backgroundColor: SettingsClass().bottunColor,
                      ),
                      child: const Text(
                        'Créer un compte',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, LoginView.routeName);
                      },
                      style: ElevatedButton.styleFrom(
                        maximumSize: const Size(400, 400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: BorderSide(
                          color: SettingsClass().secondColor,
                          width: 2,
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        'Se connecter',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: SettingsClass().secondColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
