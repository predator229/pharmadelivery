import 'package:flutter/material.dart';
import 'package:pharmadelivery/models/auth.class.dart';
import 'package:provider/provider.dart';

import '../../../controllers/deliveryman.socket.service.controller.dart';
import '../../../controllers/root.page.controller.dart';
import '../../../models/settings.class.dart';

class SettingsWidget extends StatefulWidget {
  BaseAuth auth;
  DeliverymanSocketService deliverySocketService;
  BuildContext context;
  final void Function(bool)? onToggleNotifications;
  final void Function(String)? onLanguageChanged;
  final bool notificationsEnabled;
  final String selectedLanguage;
  final List<String> availableLanguages;

  SettingsWidget({
    super.key,
    required this.context,
    required this.deliverySocketService,
    required this.auth,
    this.onToggleNotifications,
    this.onLanguageChanged,
    this.notificationsEnabled = true,
    this.selectedLanguage = 'Français',
    this.availableLanguages = const ['Français', 'English', 'Español'],
  });

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  late bool _notifications;
  late String _language;

  @override
  void initState() {
    super.initState();
    _notifications = widget.notificationsEnabled;
    _language = widget.selectedLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Compte',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 1,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text("${widget.auth.userConected.name ?? ''} ${widget.auth.userConected.surname ?? ''} "),
                subtitle: Text(widget.auth.userConected.email ?? ''),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Naviguer vers édition profil
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Modifier le mot de passe'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Naviguer vers mot de passe
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          'Préférences',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 1,
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Notifications'),
                secondary: const Icon(Icons.notifications_none),
                value: _notifications,
                onChanged: (value) {
                  setState(() => _notifications = value);
                  widget.onToggleNotifications?.call(value);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: const Text('Langue'),
                trailing: DropdownButton<String>(
                  value: _language,
                  underline: const SizedBox(),
                  items: widget.availableLanguages
                      .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _language = value);
                      widget.onLanguageChanged?.call(value);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        TextButton(
          child: Row(
            children: [
              const Icon(Icons.exit_to_app, color: Colors.red),
              const SizedBox(width: 10),
              Text("Se deconnecter", style: TextStyle(color: Colors.red, fontSize: 16)),
            ],
          ),
          onPressed: () async {
            if (widget.deliverySocketService.isConnected) {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Deconnection', style: TextStyle(fontWeight: FontWeight.bold, color: SettingsClass().bottunColor)),
                    content: Text('Vous etes encore en ligne. Êtes-vous sûr de vouloir vous déconnecter ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  );
                },
              );

              if (shouldLogout == true) {
                widget.deliverySocketService.disconnect();
                Future.delayed(const Duration(seconds: 2));
                widget.auth.signOut();
                Navigator.of(widget.context).pushReplacementNamed(RoutePage.routeName);
              }
            }
          },
        )
      ],
    );
  }
}
