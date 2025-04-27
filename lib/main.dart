import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pharmadelivery/controllers/root.page.controller.dart';
import 'package:pharmadelivery/models/auth.class.dart';
import 'package:pharmadelivery/views/homeview.view.dart';
import 'package:pharmadelivery/views/authentifications/login.view.dart';
import 'package:pharmadelivery/views/authentifications/register.view.dart';
import 'package:pharmadelivery/controllers/auth.provider.controller.dart';
import 'package:pharmadelivery/views/welcome.view.dart';
import 'package:provider/provider.dart';
import 'controllers/deliveryman.socket.service.controller.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  runApp(const WaitingLoadingView());

  await Future.wait([
    Future.delayed(const Duration(seconds: 2)),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    initializeDateFormatting('fr_FR', null),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DeliverymanSocketService()),
      ],
      child: const EntryApp(),
    ),
  );

}

class EntryApp extends StatelessWidget {
  const EntryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthProviders(
      key: Key("autht_provifrt_kjeskdsbbfnjlv"),
      auth: Auth(),
      child: MaterialApp(
        title: 'PharmaDelivery',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        routes: {
          WelcomeView.routeName : (context) => const WelcomeView(),
          RegisterView.routeName : (context) => const RegisterView(),
          LoginView.routeName : (context) => const LoginView(),
          HomeView.routeName :  (context) => const HomeView(),
          RoutePage.routeName : (context) => const RoutePage(),
        },
        initialRoute: RoutePage.routeName,
      ),
    );
  }
}

class WaitingLoadingView extends StatefulWidget {
  const WaitingLoadingView({super.key});

  @override
  _WaitingLoadingViewState createState() => _WaitingLoadingViewState();
}

class _WaitingLoadingViewState extends State<WaitingLoadingView> with TickerProviderStateMixin {
  late AnimationController _containerController;
  late Animation<Offset> _containerOffsetAnimation;
  late AnimationController _rightImageController;
  late Animation<Offset> _rightImageOffsetAnimation;

  bool _showRightImage = false;

  @override
  void initState() {
    super.initState();

    _containerController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _containerOffsetAnimation = Tween<Offset>(
      begin: const Offset(1, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _containerController,
      curve: Curves.easeOut,
    ));

    _rightImageController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _rightImageOffsetAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _rightImageController,
      curve: Curves.easeOut,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    await _containerController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {
      _showRightImage = true;
    });
    await _rightImageController.forward();
  }

  @override
  void dispose() {
    _containerController.dispose();
    _rightImageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'pharmadelivery',
      home: Scaffold(
        body: SlideTransition(
          position: _containerOffsetAnimation,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex:1,child: Container()),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_showRightImage)
                            SlideTransition(
                              position: _rightImageOffsetAnimation,
                              child: Image.asset("assets/images/camien.png", width: MediaQuery.of(context).size.width*(1/2)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
