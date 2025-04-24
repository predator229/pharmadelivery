import 'package:flutter/material.dart';
import 'package:pharmadelivery/models/settings.class.dart';
import 'package:pharmadelivery/controllers/auth.provider.controller.dart';
import 'package:pharmadelivery/models/auth.class.dart';
import 'package:pharmadelivery/models/country.class.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pharmadelivery/models/settings.class.dart';
import 'package:pharmadelivery/views/authentifications/register.view.dart';

class LoginView extends StatefulWidget {
  static const String routeName = '/login';
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool imCommunicating = false;

  GlobalKey<FormState> _formKey= GlobalKey<FormState>();

  String? _verificationId;
  bool _isCodeSent = false;
  Country? _selectedCountry;
  int _selectedTabIndex = 0;

  late BaseAuth auth;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    auth = AuthProviders.of(context).auth;
  }

  void _sendPhoneNumber() async {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty || _selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez entrer un numéro valide.')));
      return;
    }

    setState(() {
      imCommunicating = true;
    });
    await auth.sendCodeAndWaitResponse(
      context,
      phoneNumber,
      _selectedCountry!,
      (verificationId) {
        setState(() {
          _verificationId = verificationId;
          _isCodeSent = true;
        });
      },
    );
    setState(() {
      imCommunicating = false;
    });
  }

  void _submitCode() async {
    final code = _codeController.text.trim();
    if (_verificationId == null || code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez entrer un code valide.')));
      return;
    }

    setState(() {
      imCommunicating = true;
    });
    await auth.loginWithPhoneAndCode(context, _verificationId!, code);
    setState(() {
      imCommunicating = false;
    });
  }

  void _signInWithGoogle() async {
    setState(() {
      imCommunicating = true;
    });
    await auth.signInWithGoogle(context);
    setState(() {
      imCommunicating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Connexion', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          // centerTitle: true,
        ),
        body: imCommunicating ? const Center(child: CircularProgressIndicator()) : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: Column(
            children: [
              ToggleButtons(
                isSelected: [_selectedTabIndex == 0, _selectedTabIndex == 1],
                onPressed: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                    _isCodeSent = false;
                    _verificationId = null;
                    _codeController.clear();
                  });
                },
                borderRadius: BorderRadius.circular(15),
                borderColor: Theme.of(context).brightness == Brightness.dark ? SettingsClass().bottunColor : Colors.grey[300],
                selectedColor: Colors.white,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                fillColor: SettingsClass().bottunColor,
                constraints: const BoxConstraints(minHeight: 35, minWidth: 140),
                children: const [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("Téléphone", style: TextStyle(fontSize: 16))),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("Email", style: TextStyle(fontSize: 16))),
                ],
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _selectedTabIndex == 0
                      ? (_isCodeSent ? _buildCodeForm() : _buildPhoneForm())
                      : _buildEmailForm(),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Pas encore de compte ?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterView(),
                        ),
                      );
                    },
                    child: Text('Inscivez-vous ici', style: TextStyle(color: SettingsClass().secondColor),),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildPhoneForm() {
    return SingleChildScrollView(
      child: Card(
        surfaceTintColor: Theme.of(context).brightness == Brightness.dark ? Colors.black87 : Colors.white70,
        color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text("Numéro de téléphone", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              IntlPhoneField(
                decoration: InputDecoration(
                  hintText: '00 000 000',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: SettingsClass().bottunColor, width: 2.0),
                  ),
                ),
                initialCountryCode: 'FR',
                onChanged: (phone) {
                  _selectedCountry = Country(
                    name: phone.countryISOCode,
                    dialcode: "+${phone.countryCode}",
                    id: phone.countryCode,
                    emoji: phone.countryCode,
                    code: phone.countryCode,
                  );
                  _phoneController.text = phone.number;
                },
              ),
              const SizedBox(height: 20),
              Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _sendPhoneNumber,
                        style: ElevatedButton.styleFrom(
                          maximumSize: const Size(400, 400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          side: BorderSide(
                            color: SettingsClass().bottunColor,
                            width: 2,
                          ),
                          backgroundColor: SettingsClass().bottunColor,
                        ),
                        child: Text(
                          'Envoyer le code',
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
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 20),
              _buildGoogleButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeForm() {
    return Card(
      surfaceTintColor: Theme.of(context).brightness == Brightness.dark ? Colors.black87 : Colors.white70,
      color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Code reçu par SMS", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Code de vérification',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitCode,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      backgroundColor: SettingsClass().bottunColor,
                    ),
                    child: const Text(
                      'Se connecter',
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
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                setState(() {
                  _isCodeSent = false;
                  _verificationId = null;
                  _codeController.clear();
                });
              },
              child: Text("← Retour", style: TextStyle(color: SettingsClass().bottunColor)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Card(
          surfaceTintColor: Theme.of(context).brightness == Brightness.dark ? Colors.black87 : Colors.white70,
          color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Adresse Email", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) { return 'Ce champ est requis'; }
                    final emailRegex = RegExp(r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
                    if (!emailRegex.hasMatch(value)) { return 'Adresse email invalide'; }

                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'email@example.com',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: SettingsClass().bottunColor, width: 2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Mot de passe", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ce champ est requis';
                    }
                    if (value.length < 8) {
                      return 'Le mot de passe doit contenir au moins 8 caractères';
                    }
                    if (!RegExp(r'[A-Z]').hasMatch(value)) {
                      return 'Le mot de passe doit contenir au moins une lettre majuscule';
                    }
                    if (!RegExp(r'[a-z]').hasMatch(value)) {
                      return 'Le mot de passe doit contenir au moins une lettre minuscule';
                    }
                    if (!RegExp(r'[0-9]').hasMatch(value)) {
                      return 'Le mot de passe doit contenir au moins un chiffre';
                    }
                    if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
                      return 'Le mot de passe doit contenir au moins un caractère spécial (!@#\$&*~)';
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Mot de passe',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: SettingsClass().bottunColor, width: 2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            imCommunicating = true;
                          });
                          auth.loginWithEmailAndPassword(
                            context,
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                          );
                          setState(() {
                            imCommunicating = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        backgroundColor: SettingsClass().bottunColor,
                      ),
                      child: const Text(
                        'Se connecter',
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
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 20),
                _buildGoogleButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _signInWithGoogle,
            style: ElevatedButton.styleFrom(
              maximumSize: const Size(400, 400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              side: BorderSide(
                color: Colors.white,
                width: 2,
              ),
              backgroundColor: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              children: [
                Image.asset("assets/images/icons/google.png", width: 24),
                Text(
                  'Se connecter avec Google',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
