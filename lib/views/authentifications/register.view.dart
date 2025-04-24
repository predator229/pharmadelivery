import 'package:pharmadelivery/controllers/auth.provider.controller.dart';
import 'package:pharmadelivery/models/auth.class.dart';
import 'package:pharmadelivery/models/country.class.dart';
import 'package:pharmadelivery/models/settings.class.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:country_picker/country_picker.dart' as country_picker;
import 'package:pharmadelivery/views/authentifications/login.view.dart';

import '../../controllers/apis.controller.dart';

class RegisterView extends StatefulWidget {
  static const String routeName = '/register';

  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  int _stepIndex = 0;
  bool imCommunicating = false;
  bool blocked = false;
  List<String> alreadyExistEmail = [];
  List allCitiesToDisplay = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _vehicleTypeController = TextEditingController();
  final TextEditingController _marqueVehiculeController = TextEditingController();
  final TextEditingController _modelVehiculeController = TextEditingController();
  final TextEditingController _anneeVehiculeController = TextEditingController();
  final TextEditingController _nrEssieuxController = TextEditingController();
  final TextEditingController _capaciteChargeController = TextEditingController();
  final TextEditingController _nrAssuranceController = TextEditingController();
  final TextEditingController _nrImmatriculationController = TextEditingController();
  final TextEditingController _nrChassisController = TextEditingController();
  final TextEditingController _nrPermisController = TextEditingController();
  final TextEditingController _nrVisiteTechniqueController = TextEditingController();
  final TextEditingController _nrCarteGriseController = TextEditingController();
  final TextEditingController _nrContratController = TextEditingController();

  final TextEditingController _mpController = TextEditingController();
  final TextEditingController _confmpController = TextEditingController();

  List<GlobalKey<FormState>> _formKeys = List.generate(4, (_) => GlobalKey<FormState>());

  Country? _selectedCountry;

  late BaseAuth auth;

  List<Step> get _steps => !blocked ? [
    Step(
      title:Text("Pays de residence, ville et adresse",),
      isActive: _stepIndex >= 0,
      stepStyle: StepStyle(
        color: _stepIndex >= 0 ? SettingsClass().bottunColor : Colors.grey,
        connectorColor: SettingsClass().bottunColor,
      ),
      content: Form(
        key: _formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () async {
                  country_picker.showCountryPicker(
                    context: context,
                    showPhoneCode: true, onSelect: (country_picker.Country value) async {
                      setState(() {
                        _selectedCountry = Country(
                        name: value.name,
                        dialcode: "+${value.phoneCode}",
                        id: value.countryCode,
                        emoji: value.flagEmoji,
                        code: value.countryCode,
                        );
                        _phoneController.text = '';
                        _cityController.text = '';
                        allCitiesToDisplay = [];
                      });
                      setState(() {
                        blocked = _selectedCountry?.code.toUpperCase() == "FR" ? false : true;
                        imCommunicating = true;
                      });
                      var allCities = await ApiController().get2('https://secure.geonames.org/searchJSON?country=${_selectedCountry?.code.toString()}&featureClass=P&maxRows=1000&username=funccodes229');
                      if (allCities != null && allCities['geonames'] != null) {
                        setState(() {
                          allCitiesToDisplay = allCities['geonames'];
                          imCommunicating = false;
                        });
                      }
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: BorderSide(
                    color: Colors.transparent,
                    width: 2,
                  ),
                  backgroundColor: Colors.white,
                ),
                child: _selectedCountry == null
                ? Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),),
                  height: 60,
                  width: double.infinity,
                  child: Center(child: Text('Cliquer ici pour selectionner votre pays', style: TextStyle(color: Colors.grey,fontSize: 13,))),
                )
                    : Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    // color: Colors.grey[100],
                  ),
                  height: 60,
                  width: double.infinity,
                  child: Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedCountry!.emoji} ${_selectedCountry!.name}',
                          style: TextStyle(fontSize: 17, color: Colors.black),
                        ),
                        Icon(Icons.arrow_drop_down, color: SettingsClass().secondColor ,),                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (!blocked && _selectedCountry != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: _cityController.text.isNotEmpty ? _cityController.text : null,
                items: allCitiesToDisplay
                    .map((city) => DropdownMenuItem<String>(
                  value: city['name'],
                  child: Text(city['name']),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _cityController.text = value ?? '';
                  });
                },
                validator: (value) => value == null || value.isEmpty ? 'Veuillez sélectionner une ville' : null,
                decoration: InputDecoration(
                  floatingLabelStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? SettingsClass().bottunColor : SettingsClass().bottunColor,
                  ),
                  labelText: 'Ville',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark ? SettingsClass().bottunColor : SettingsClass().bottunColor, width: 2.0),
                  ),
                ),
              ),
            ),
            if (!blocked && _selectedCountry != null && _cityController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _addressController,
                    validator: (value) => value == null || value.isEmpty ? 'Adresse requise' : null,
                    decoration: InputDecoration(
                      floatingLabelStyle: TextStyle(
                      color: SettingsClass().bottunColor,
                    ),
                      labelText: 'Adresse',
                      focusColor: SettingsClass().bottunColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: SettingsClass().bottunColor, width: 2.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

      ),
    ),
    Step(
      title: const Text("Identité"),
      isActive: _stepIndex >= 1,
      content: Form(
        key: _formKeys[1],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.name,
                validator: (value) => value == null || value.isEmpty ? 'Ce champ est requis' : null,
                decoration: InputDecoration(
                  floatingLabelStyle: TextStyle(
                    color: SettingsClass().bottunColor,
                  ),
                  labelText: 'Nom complet',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: SettingsClass().bottunColor, width: 2.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) { return 'Ce champ est requis'; }
                  final emailRegex = RegExp(r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
                  if (!emailRegex.hasMatch(value)) { return 'Adresse email invalide'; }
                  if (alreadyExistEmail.contains(value)) {
                    return 'Cette adresse email est deja utilisée par un autre compte';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  floatingLabelStyle: TextStyle(
                    color: SettingsClass().bottunColor,
                  ),
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: SettingsClass().bottunColor, width: 2.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: IntlPhoneField(
                decoration: InputDecoration(
                  floatingLabelStyle: TextStyle(
                    color: SettingsClass().bottunColor,
                  ),
                  labelText: 'Nr téléphone',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: SettingsClass().bottunColor, width: 2.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                ),
                initialCountryCode: _selectedCountry != null ? _selectedCountry!.code.toUpperCase() : 'FR',
                validator: (value) => value == null || value.number.isEmpty ? 'Ce champ est requis' : null,
                onChanged: (phone) {
                  setState(() {
                    _phoneController.text = phone.completeNumber;
                  });
                },
              ),
            ),
            Visibility(
              visible: false,
              maintainState: true,
              maintainAnimation: true,
              maintainSize: true,
              child: TextFormField(
                controller: _phoneController,
                validator: (value) =>
                value == null || value.isEmpty ? 'Numéro de téléphone requis' : null,
                decoration: const InputDecoration.collapsed(hintText: ''),
                style: const TextStyle(height: 0, fontSize: 0),
              ),
            ),
          ],
        ),
      ),
      stepStyle: StepStyle(
        color: _stepIndex >= 1 ? SettingsClass().bottunColor : Colors.grey,
      ),
    ),
    Step(
      stepStyle: StepStyle(
        color:  _stepIndex >= 2 ? SettingsClass().bottunColor : Colors.grey,
        connectorColor: SettingsClass().bottunColor,
      ),
      title: const Text("Véhicule"),
      isActive: _stepIndex >= 2,
      content: Form(
        key: _formKeys[2],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: DropdownButtonFormField<String>(
                 value: _vehicleTypeController.text.isNotEmpty ? _vehicleTypeController.text : null,
                 items: ['Moto', 'Voiture', 'Vélo', 'Camion']
                     .map((type) => DropdownMenuItem<String>(
                           value: type,
                           child: Text(type),
                         ))
                     .toList(),
                 onChanged: (value) {
                   setState(() {
                     _vehicleTypeController.text = value ?? '';
                   });
                 },
                 decoration: InputDecoration(
                   floatingLabelStyle: TextStyle(
                     color: SettingsClass().bottunColor,
                   ),
                   labelText: 'Type de véhicule',
                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                   filled: true,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: SettingsClass().bottunColor, width: 2.0),
                      ),
                   fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                 ),
               ),
            ),
            if (_vehicleTypeController.text == 'Moto')
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _marqueVehiculeController,
                    validator: (value) => value == null || value.isEmpty ? 'Marque requise' : null,
                    decoration: InputDecoration(
                      labelText: 'Marque',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      floatingLabelStyle: TextStyle(
                      color: SettingsClass().bottunColor,
                    ),
                      fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: SettingsClass().bottunColor, width: 2.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _modelVehiculeController,
                    validator: (value) => value == null || value.isEmpty ? 'Modèle requis' : null,
                    decoration: InputDecoration(
                      labelText: 'Modèle',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      floatingLabelStyle: TextStyle(
                      color: SettingsClass().bottunColor,
                    ),
                      fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: SettingsClass().bottunColor, width: 2.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _anneeVehiculeController,
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Année requise' : null,
                    decoration: InputDecoration(
                      labelText: 'Année',
                      floatingLabelStyle: TextStyle(
                      color: SettingsClass().bottunColor,
                    ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: SettingsClass().bottunColor, width: 2.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _nrPermisController,
                    validator: (value) => value == null || value.isEmpty ? 'Numéro de permis requis' : null,
                    decoration: InputDecoration(
                      labelText: 'Numéro de permis',
                      floatingLabelStyle: TextStyle(
                      color: SettingsClass().bottunColor,
                    ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: SettingsClass().bottunColor, width: 2.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_vehicleTypeController.text == 'Voiture')
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _marqueVehiculeController,
                    validator: (value) => value == null || value.isEmpty ? 'Marque requise' : null,
                    decoration: InputDecoration(
                      labelText: 'Marque',
                      floatingLabelStyle: TextStyle(
                      color: SettingsClass().bottunColor,
                    ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: SettingsClass().bottunColor, width: 2.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _modelVehiculeController,
                    validator: (value) => value == null || value.isEmpty ? 'Modèle requis' : null,
                    decoration: InputDecoration(
                      labelText: 'Modèle',
                      floatingLabelStyle: TextStyle(
                      color: SettingsClass().bottunColor,
                    ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: SettingsClass().bottunColor, width: 2.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _anneeVehiculeController,
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Année requise' : null,
                    decoration: InputDecoration(
                      labelText: 'Année',
                      floatingLabelStyle: TextStyle(
                      color: SettingsClass().bottunColor,
                    ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: SettingsClass().bottunColor, width: 2.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _nrCarteGriseController,
                    validator: (value) => value == null || value.isEmpty ? 'Numéro de carte grise requis' : null,
                    decoration: InputDecoration(
                      labelText: 'Numéro de carte grise',
                      floatingLabelStyle: TextStyle(
                      color: SettingsClass().bottunColor,
                    ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: SettingsClass().bottunColor, width: 2.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_vehicleTypeController.text == 'Vélo')
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _marqueVehiculeController,
                    validator: (value) => value == null || value.isEmpty ? 'Marque requise' : null,
                    decoration: InputDecoration(
                      labelText: 'Marque',
                      floatingLabelStyle: TextStyle(
                      color: SettingsClass().bottunColor,
                    ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: SettingsClass().bottunColor, width: 2.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _modelVehiculeController,
                    validator: (value) => value == null || value.isEmpty ? 'Modèle requis' : null,
                    decoration: InputDecoration(
                      labelText: 'Modèle',
                      floatingLabelStyle: TextStyle(
                      color: SettingsClass().bottunColor,
                    ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: SettingsClass().bottunColor, width: 2.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_vehicleTypeController.text == 'Camion')
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _marqueVehiculeController,
                    validator: (value) => value == null || value.isEmpty ? 'Marque requise' : null,
                    decoration: InputDecoration(
                      labelText: 'Marque',
                      floatingLabelStyle: TextStyle(
                      color: SettingsClass().bottunColor,
                    ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: SettingsClass().bottunColor, width: 2.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _modelVehiculeController,
                    validator: (value) => value == null || value.isEmpty ? 'Modèle requis' : null,
                    decoration: InputDecoration(
                      labelText: 'Modèle',
                      floatingLabelStyle: TextStyle(
                      color: SettingsClass().bottunColor,
                    ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: SettingsClass().bottunColor, width: 2.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _anneeVehiculeController,
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Année requise' : null,
                    decoration: InputDecoration(
                      labelText: 'Année',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      floatingLabelStyle: TextStyle(
                      color: SettingsClass().bottunColor,
                    ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: SettingsClass().bottunColor, width: 2.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _capaciteChargeController,
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Capacité de charge requise' : null,
                    decoration: InputDecoration(
                      labelText: 'Capacité de charge (tonnes)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      floatingLabelStyle: TextStyle(
                      color: SettingsClass().bottunColor,
                    ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: SettingsClass().bottunColor, width: 2.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _nrEssieuxController,
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Nombre d\'essieux requis' : null,
                    decoration: InputDecoration(
                      labelText: 'Nombre d\'essieux',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      floatingLabelStyle: TextStyle(
                      color: SettingsClass().bottunColor,
                    ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: SettingsClass().bottunColor, width: 2.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _nrCarteGriseController,
                    validator: (value) => value == null || value.isEmpty ? 'Numéro de carte grise requis' : null,
                    decoration: InputDecoration(
                      labelText: 'Numéro de carte grise',
                      floatingLabelStyle: TextStyle(
                      color: SettingsClass().bottunColor,
                    ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: SettingsClass().bottunColor, width: 2.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    Step(
      stepStyle: StepStyle(
        color:  _stepIndex >= 3 ? SettingsClass().bottunColor : Colors.grey,
        connectorColor: SettingsClass().bottunColor,
      ),
      title: const Text("Connection"),
      isActive: _stepIndex >= 3,
      content: Form(
        key: _formKeys[3],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                controller: _mpController,
                keyboardType: TextInputType.visiblePassword,
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
                  labelText: 'Mot de passe',
                  floatingLabelStyle: TextStyle(
                    color: SettingsClass().bottunColor,
                  ),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: SettingsClass().bottunColor, width: 2.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                controller: _confmpController,
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est requis';
                  }
                  if (value != _mpController.text) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  border: OutlineInputBorder(),
                  floatingLabelStyle: TextStyle(
                    color: SettingsClass().bottunColor,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: SettingsClass().bottunColor, width: 2.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ] : [
    Step(
      title:Text("Pays de residence, ville et adresse",),
      isActive: _stepIndex >= 0,
      stepStyle: StepStyle(
        color: _stepIndex >= 0 ? SettingsClass().bottunColor : Colors.grey,
        connectorColor: SettingsClass().bottunColor,
      ),
      content: Form(
        key: _formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () async {
                  country_picker.showCountryPicker(
                    context: context,
                    showPhoneCode: true, onSelect: (country_picker.Country value) async {
                    setState(() {
                      _selectedCountry = Country(
                        name: value.name,
                        dialcode: "+${value.phoneCode}",
                        id: value.countryCode,
                        emoji: value.flagEmoji,
                        code: value.countryCode,
                      );
                      _phoneController.text = '';
                      _cityController.text = '';
                      allCitiesToDisplay = [];
                    });
                    setState(() {
                      blocked = _selectedCountry?.code.toUpperCase() == "FR" ? false : true;
                      imCommunicating = true;
                    });
                    var allCities = await ApiController().get2('https://secure.geonames.org/searchJSON?country=${_selectedCountry?.code.toString()}&featureClass=P&maxRows=1000&username=funccodes229');
                    if (allCities != null && allCities['geonames'] != null) {
                      setState(() {
                        allCitiesToDisplay = allCities['geonames'];
                        imCommunicating = false;
                      });
                    }
                  },
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: BorderSide(
                    color: Colors.transparent,
                    width: 2,
                  ),
                  backgroundColor: Colors.white,
                ),
                child: _selectedCountry == null
                    ? Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),),
                        height: 60,
                        width: double.infinity,
                        child: Center(child: Text('Cliquer ici pour selectionner votre pays', style: TextStyle(color: Colors.grey,fontSize: 13,))),
                    )
                    : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      height: 60,
                      width: double.infinity,
                      child: Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_selectedCountry!.emoji} ${_selectedCountry!.name}',
                              style: TextStyle(fontSize: 17, color: Colors.black),
                            ),
                            Icon(Icons.arrow_drop_down, color: SettingsClass().secondColor ,),
                          ],
                        ),
                      ),
                    ),
              ),
            ),
            if (!blocked && _selectedCountry != null)
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _cityController.text.isNotEmpty ? _cityController.text : null,
                  items: allCitiesToDisplay
                      .map((city) => DropdownMenuItem<String>(
                    value: city['name'],
                    child: Text(city['name']),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _cityController.text = value ?? '';
                    });
                  },
                  validator: (value) => value == null || value.isEmpty ? 'Veuillez sélectionner une ville' : null,
                  decoration: InputDecoration(
                    floatingLabelStyle: TextStyle(
                      color: SettingsClass().bottunColor,
                    ),
                    labelText: 'Ville',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: SettingsClass().bottunColor, width: 2.0)),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: SettingsClass().bottunColor, width: 2.0),
                    ),
                  ),
                ),
              ),
            if (!blocked && _selectedCountry != null && _cityController.text.isNotEmpty)
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _addressController,
                      validator: (value) => value == null || value.isEmpty ? 'Adresse requise' : null,
                      decoration: InputDecoration(
                        floatingLabelStyle: TextStyle(
                          color: SettingsClass().bottunColor,
                        ),
                        labelText: 'Adresse',
                        focusColor: SettingsClass().bottunColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                        focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: SettingsClass().bottunColor, width: 2.0),
                      ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),

      ),
    ),
  ];

  void _sendPhoneNumber() async {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty || _selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez entrer un numéro valide.')));
      return;
    }
  }

  void _nextStep() {
    if (_stepIndex < _steps.length - 1) {
      setState(() => _stepIndex++);
    } else {
      if (_formKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Inscription réussie!")),
        );
      }
    }
  }
  void _prevStep() {
    if (_stepIndex > 0) {
      setState(() => _stepIndex--);
    }
  }

  Widget _buildStep(int step) {
    return SizedBox(
      width: step == (_stepIndex +1) ? 30 :15,
      height: step == (_stepIndex +1) ? 30 :15,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: step <= (_stepIndex +1) ? SettingsClass().bottunColor :  Colors.grey,
        child: Text( step == (_stepIndex +1) ? ' 🛵' : '$step',
          style: TextStyle(
            color: Colors.white,
            fontSize: step == (_stepIndex +1) ? 15 :10,
          ),
        ),
      ),
    );
  }
  Widget _buildLine() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.0),
        child: Container(
            height: 1,
            color: 5 == (_stepIndex +1) ? Colors.green : Colors.grey
        ),
      ),
    );
  }

  Widget _buildCheck() {
    return Icon(
      Icons.check_circle,
      color: Colors.grey,
      size: 15,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    auth = AuthProviders.of(context).auth;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Inscription", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
              SizedBox(height: 5,),
              SizedBox(
                width: MediaQuery.of(context).size.width*(3/5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (int j = 1; j < 5; j++) ...[
                      _buildStep(j),
                      if (j >= (_stepIndex +1) ) _buildLine()
                    ],
                    _buildCheck(),
                  ],
                ),
              ),
              SizedBox(height: 10,),

            ],
          )
      ),
      body: imCommunicating ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(16.0),
        child: !blocked ? SingleChildScrollView(
          child: FullRegisterView(),
        ) : FullRegisterView(),
      ),
    );
  }

  Widget FullRegisterView () {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            Stepper(
              currentStep: _stepIndex,
              onStepContinue: _nextStep,
              onStepCancel: _prevStep,
              steps: _steps,
              controlsBuilder: (context_, details) => Row(
                children: [
                  if(!blocked)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKeys[_stepIndex].currentState == null || !_formKeys[_stepIndex].currentState!.validate()) return;
                          if (_stepIndex == 0) {
                            if (_addressController.text.isEmpty || _cityController.text.isEmpty || _selectedCountry == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Veuillez selectionner votre pays, votre ville et votre adresse!')),
                              );
                              return;
                            }
                          }
                          if (_stepIndex == 1) {
                            setState(() {
                              imCommunicating = true;
                            });
                            final isRegistered = await auth.isEmailRegistered(_emailController.text.trim(), _phoneController.text.trim());
                            setState(() {
                              imCommunicating = false;
                            });
                            if (isRegistered) {
                              alreadyExistEmail.add(_emailController.text.trim());
                              setState(() {
                                _stepIndex = 1;
                                while(_stepIndex != 1){
                                  details.onStepCancel?.call();
                                }
                                _formKeys[1].currentState?.validate();
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Cet email est déjà utilisé')),
                              );
                              return;
                            }
                          }
                          if (_stepIndex != _steps.length - 1) {
                            details.onStepContinue?.call();
                          } else {
                            for (int i = 0; i < _formKeys.length; i++) {
                              if (_formKeys[i].currentState == null || !_formKeys[i].currentState!.validate()) return;
                            }
                            setState(() {
                              imCommunicating = true;
                            });
                            final allInfos = {
                              'name': _nameController.text,
                              'email': _emailController.text,
                              'phone': _phoneController.text,
                              'address': _addressController.text,
                              'vehicleType': _vehicleTypeController.text,
                              'marqueVehicule': _marqueVehiculeController.text,
                              'modelVehicule': _modelVehiculeController.text,
                              'anneeVehicule': _anneeVehiculeController.text,
                              'nrEssieux': _nrEssieuxController.text,
                              'capaciteCharge': _capaciteChargeController.text,
                              'nrAssurance': _nrAssuranceController.text,
                              'nrImmatriculation': _nrImmatriculationController.text,
                              'nrChassis': _nrChassisController.text,
                              'nrPermis': _nrPermisController.text,
                              'nrVisiteTechnique': _nrVisiteTechniqueController.text,
                              'nrCarteGrise': _nrCarteGriseController.text,
                              'nrContrat': _nrContratController.text,
                              'country': _selectedCountry?.toJson(),
                            };
                            final response = await auth.registerWithEmailAndPassword(
                              _emailController.text.trim(),
                              _mpController.text.trim(),
                              allInfos
                            );
                            setState(() {
                              imCommunicating = false;
                            });
                            if (response == true){
                              await auth.loginWithEmailAndPassword(context, _emailController.text.trim(), _mpController.text.trim());
                            }else{
                              switch (response) {
                                case 'user-not-found':
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Aucun utilisateur trouvé avec cet email.')),
                                  );
                                  break;
                                case 'wrong-password':
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Mot de passe incorrect. Veuillez réessayer.')),
                                  );
                                  break;
                                case 'email-already-in-use':
                                  alreadyExistEmail.add(_emailController.text.trim());
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Un utilisateur avec cette adresse email existe déjà. Veuillez en choisir une autre ou tenter de vous connecter.')),
                                  );
                                  break;
                                case 'weak-password':
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Le mot de passe est trop faible. Veuillez en choisir un plus fort.')),
                                  );
                                  break;
                                default:
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Une erreur est survenue. Contactez notre support. ')),
                                  );
                              }
                            }

                          }

                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          side: BorderSide(
                            color: SettingsClass().bottunColor,
                            width: 2,
                          ),
                          backgroundColor:  SettingsClass().bottunColor,
                        ),
                        child: Text(
                          'Suivant',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  if (!blocked && _stepIndex > 0)
                    SizedBox(width: 10,),
                  if (!blocked && _stepIndex > 0)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: details.onStepCancel,
                        style: ElevatedButton.styleFrom(
                          maximumSize: const Size(400, 400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          side: BorderSide(
                            color: SettingsClass().secondColor,
                            width: 2,
                          ),
                          backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                        ),
                        child: Text(
                          'Retour',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: SettingsClass().bottunColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if(blocked)
              Padding(
                padding: const EdgeInsets.only(left: 28.0),
                child: Text('Vous devez être résident en France pour vous inscrire sur cette plateforme.', style: TextStyle(color: Colors.red),),
              ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Déjà inscrit?'),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginView(),
                  ),
                );
              },
              child: Text('Connectez-vous ici', style: TextStyle(color: SettingsClass().secondColor),),
            ),
          ],
        )
      ],
    );
  }
}

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) => value == null || value.isEmpty ? 'Ce champ est requis' : null,
        decoration: InputDecoration(
          floatingLabelStyle: TextStyle(
            color: SettingsClass().bottunColor,
          ),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: SettingsClass().bottunColor, width: 2.0),
          ),
        ),
      ),
    );
  }
} 
