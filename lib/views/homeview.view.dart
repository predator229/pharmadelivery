import 'dart:io';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import 'package:pharmadelivery/models/settings.class.dart';
import 'package:pharmadelivery/views/welcome.view.dart';

import '../controllers/auth.provider.controller.dart';
import '../controllers/deliveryman.socket.service.controller.dart';
import '../controllers/root.page.controller.dart';
import '../models/auth.class.dart';
import 'home/widgets/settings.widget.dart';

class HomeView extends StatefulWidget {
  static const String routeName = '/home';
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin  {

  late BaseAuth auth;
  late DeliverymanSocketService deliverySocketService;

  int _currentIndex = 0;
  IO.Socket? emptyServerConnection;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    auth = AuthProviders.of(context).auth;
    deliverySocketService = Provider.of<DeliverymanSocketService>(context);
  }
  Column HomeWidget (){
    return  Column(
      children: [
        AppBar(
          title:  Text('Accueil', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          // centerTitle: true,
          backgroundColor: deliverySocketService.isConnected ? SettingsClass().bottunColor : Colors.red,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              // Scaffold.of(context).openDrawer();
            },
          ),
          elevation: 1,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () {
                // Logique pour afficher les notifications
              },
            ),
            IconButton(
              icon: Icon(
                deliverySocketService.isConnected ? Icons.toggle_on : Icons.toggle_off,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () async {
                if (!deliverySocketService.isConnected) {
                  deliverySocketService.connect();
                } else {
                  deliverySocketService.disconnect();
                }
              },
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.white,
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text('Recentes commandes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          if (deliverySocketService.isConnected)
                            IconButton(
                              icon: const Icon(Icons.refresh, color: Colors.black),
                              onPressed: () {
                                // appel vers l'api pour rafraichir les commandes de la journee
                              },
                            ),
                        ],
                      ),
                      SizedBox(height: 15),
                      if (!deliverySocketService.isConnected)
                        Text('Vous êtes hors ligne', style: TextStyle(color: Colors.red, fontSize: 16)),
                      if (deliverySocketService.isConnected)
                        _buildOrdersList(),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ],
    );
  }

  Widget _drawerItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;

    return ListTile(
      leading: Icon(icon, color: isSelected ? SettingsClass().bottunColor : Colors.black),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? SettingsClass().bottunColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        Navigator.pop(context); // fermer le drawer
      },
    );
  }

  Widget switchWidget() {
    switch (_currentIndex) {
      case 0:
        return  HomeWidget();
      // case 1:
      //   return const OrdersView();
      // case 2:
      //   return const HistoryView();
      // case 3:
      //   return const ProfileView();
      case 3:
        return SettingsWidget(
          context: context,
          deliverySocketService: deliverySocketService,
          auth: auth,
          onToggleNotifications: (enabled) => print('Notifs: $enabled'),
          onLanguageChanged: (lang) => print('Langue: $lang'),
        );
      default:
        return HomeWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: switchWidget(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_sharp), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Commandes'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historique'),
          // BottomNavigationBarItem(icon: Icon(Icons.person),label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(Icons.settings),label: 'Parametres'),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: SettingsClass().bottunColor,
        onTap: (index) { setState(() { _currentIndex = index; });},

      ),
      persistentFooterButtons: _currentIndex == 3
        ? [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Version 1.0.0', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(width: 20),
                Text('© 2025 Pharmadelivery', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ]
        : null,
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: SettingsClass().bottunColor,
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/300'), // ou auth.photoURL
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(auth.userConected.name ?? 'Livreur', style: const TextStyle(color: Colors.white, fontSize: 18)),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.circle, color: Colors.green, size: 10),
                              const SizedBox(width: 5),
                              Text(deliverySocketService.isConnected ? 'En ligne' : 'Hors ligne',
                                  style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _drawerItem(Icons.home, 'Accueil', 0),
              _drawerItem(Icons.list_alt, 'Commandes', 1),
              _drawerItem(Icons.history, 'Historique', 2),
              _drawerItem(Icons.settings, 'Paramètres', 3),
              const Spacer(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Se déconnecter', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await auth.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed(WelcomeView.routeName);
                  }
                },
              ),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildNavItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.black87),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildOrderItem(String orderId, String pharmacy, int status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: _getStatusColor(status), size: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(orderId, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(pharmacy, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ),
            ],
          ),
          Text(status.toString(), style: TextStyle(fontSize: 14, color: _getStatusColor(status))),
        ],
      ),
    );
  }

  Color _getStatusColor(int status) {
    // 1: En cours, 2: Livrée, 3: En retard
    switch (status) {
      case 1:
        return Colors.blue;
      case 2:
        return SettingsClass().secondColor;
      case 2:
        return Colors.redAccent;
      default:
        return Colors.redAccent;
    }
  }
  Widget _buildOrdersList() {
    return Column(
      children: [
        _buildOrderItem('Commande #123', 'Pharmacie A', 2),
        _buildOrderItem('Commande #456', 'Pharmacie B', 2),
        _buildOrderItem('Commande #789', 'Pharmacie C', 2),
      ],
    );
  }
}


