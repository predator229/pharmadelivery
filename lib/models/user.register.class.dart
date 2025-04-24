
import 'package:pharmadelivery/models/country.class.dart';

import 'Mobil.class.dart';

class UserRegisterClass {
  final String id;
  final String? email;
  final String? name;
  final String? surname;
  final String? photoURL;
  final bool disabled;
  final Country? country;
  final String? city;
  final String? address;
  final List<Mobil>? mobils;
  final Mobil? phone;
  final String? vehicleType;
  final String? marqueVehicule;
  final String? modelVehicule;
  final String? anneeVehicule;
  final String? nrEssieux;
  final String? capaciteCharge;
  final String? nrImmatriculation;
  final DateTime? nrAssurance;
  final String? nrChassis;
  final String? nrPermis;
  final DateTime? nrVisiteTechnique;
  final String? nrCarteGrise;
  final String? nrContrat;
  final int coins;

  UserRegisterClass({
    required this.id,
    this.email,
    this.name,
    this.surname,
    this.photoURL,
    this.disabled = false,
    this.country,
    this.city,
    this.address,
    this.mobils,
    this.phone,
    this.vehicleType,
    this.marqueVehicule,
    this.modelVehicule,
    this.anneeVehicule,
    this.nrEssieux,
    this.capaciteCharge,
    this.nrImmatriculation,
    this.nrAssurance,
    this.nrChassis,
    this.nrPermis,
    this.nrVisiteTechnique,
    this.nrCarteGrise,
    this.nrContrat,
    this.coins = 0,
  });

  factory UserRegisterClass.fromJson(Map<String, dynamic> json) {
    return UserRegisterClass(
      id: json['_id'] ?? '',
      email: json['email'],
      name: json['name'],
      surname: json['surname'],
      photoURL: json['photoURL'],
      disabled: json['disabled'] ?? false,
      country: json['country'] != null ? Country.fromJson(json['country']) : null,
      city: json['city'],
      address: json['address'],
      mobils: json['mobils'] != null && (json['mobils'] as List).isNotEmpty
          ? (json['mobils'] as List).map((i) => Mobil.fromJson(i)).toList()
          : [],  // Gestion des listes vides      phone: json['phone'],
      phone: json['phone'] != null ? Mobil.fromJson(json['phone']) : null,
      vehicleType: json['vehicleType'],
      marqueVehicule: json['marqueVehicule'],
      modelVehicule: json['modelVehicule'],
      anneeVehicule: json['anneeVehicule'],
      nrEssieux: json['nrEssieux'],
      capaciteCharge: json['capaciteCharge'],
      nrImmatriculation: json['nrImmatriculation'],
      nrAssurance: json['nrAssurance'] != null ? DateTime.tryParse(json['nrAssurance']) : null,
      nrChassis: json['nrChassis'],
      nrPermis: json['nrPermis'],
      nrVisiteTechnique: json['nrVisiteTechnique'] != null ? DateTime.tryParse(json['nrVisiteTechnique']) : null,
      nrCarteGrise: json['nrCarteGrise'],
      nrContrat: json['nrContrat'],
      coins: json['coins'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'name': name,
      'surname': surname,
      'photoURL': photoURL,
      'disabled': disabled,
      'country': country,
      'city': city,
      'address': address,
      'mobils': mobils,
      'phone': phone,
      'vehicleType': vehicleType,
      'marqueVehicule': marqueVehicule,
      'modelVehicule': modelVehicule,
      'anneeVehicule': anneeVehicule,
      'nrEssieux': nrEssieux,
      'capaciteCharge': capaciteCharge,
      'nrImmatriculation': nrImmatriculation,
      'nrAssurance': nrAssurance?.toIso8601String(),
      'nrChassis': nrChassis,
      'nrPermis': nrPermis,
      'nrVisiteTechnique': nrVisiteTechnique?.toIso8601String(),
      'nrCarteGrise': nrCarteGrise,
      'nrContrat': nrContrat,
      'coins': coins,
    };
  }
}
