import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pharmadelivery/controllers/apis.controller.dart';
import 'package:pharmadelivery/models/country.class.dart';
import 'package:pharmadelivery/controllers/root.page.controller.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pharmadelivery/models/user.register.class.dart';


abstract class BaseAuth {
  Stream<User?> get onAuthStatusChanged;

  Future<void> sendCodeAndWaitResponse(BuildContext context, String phoneNumber, Country? country, void Function(String) isCodeSentUserFromFireBase);
  Future<void> loginWithPhoneAndCode(BuildContext context, String verificationId, String userCode);
  Future<void> loginWithEmailAndPassword(BuildContext context, String email, String password);
  Future<dynamic> registerWithEmailAndPassword(String email, String password, dynamic allInfos);
  Future<void> signInWithGoogle(BuildContext context);
  Future<void> attemptLoginAndSendBackErrorMessage(BuildContext context, dynamic credential);
  Future<bool> isEmailRegistered(String email, String phoneNumber);
  Future<bool> isPhoneNumberRegistred(String phoneNumber);
  Future<User?> currentUser();
  Future<void> signOut();
  checkIfEmailExists(String email) {}
  checkIfPhoneExists(String phone) {}
  void registerUser(BuildContext context, String trim, String trim2, String trim3, String trim4, String trim5, String trim6, String trim7, String trim8, String trim9, String trim10, String trim11) {}

  UserRegisterClass get userConected;
  set userConected(UserRegisterClass auth);
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  UserRegisterClass? _emptyUser;

  @override
  UserRegisterClass get userConected => _emptyUser!;

  @override
  set userConected(UserRegisterClass _user) {
    _emptyUser = _user;
  }

  @override
  Stream<User?> get onAuthStatusChanged { return _firebaseAuth.authStateChanges();}

  @override
  Future<void> sendCodeAndWaitResponse(BuildContext context, String phoneNumber, Country? country, void Function(String) isCodeSentUserFromFireBase) async {
    String fullPhoneNumber = '${country?.dialcode ?? ''} $phoneNumber';
    print(fullPhoneNumber);
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: fullPhoneNumber, //fullPhoneNumber.replaceAll(' ', '')
      verificationCompleted: (PhoneAuthCredential credential) async {
        attemptLoginAndSendBackErrorMessage(context, credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Le numero de telephone est incorrect $fullPhoneNumber')),
          );
        }else{
          print(e.code);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur de connection de merce ${e.code}')),
          );

        }
      },
      codeSent: (String verificationId, int? resendToken) {
        isCodeSentUserFromFireBase(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Future<void> loginWithPhoneAndCode(BuildContext context, String verificationId, String userCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: userCode);
    attemptLoginAndSendBackErrorMessage(context, credential);
  }

  @override
  Future<User?> currentUser() async {
    return _firebaseAuth.currentUser;
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> signInWithGoogle(BuildContext context) async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    attemptLoginAndSendBackErrorMessage(context, credential);
  }

  @override
  Future<dynamic> registerWithEmailAndPassword(String email, String password, dynamic allInfos) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      await ApiController().post('users/register-additional-info',
          {'info':allInfos, 'uid':_firebaseAuth.currentUser?.uid});
      return true;
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  @override
  Future<void> loginWithEmailAndPassword(BuildContext context, String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        Navigator.pushReplacementNamed(context, RoutePage.routeName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur de connexion ! Veuillez réessayer')),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur non trouvé. Veuillez vérifier vos informations.')),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mot de passe incorrect. Veuillez réessayer.')),
        );
      } else if (e.code == 'user-disabled') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cet utilisateur a été désactivé. Veuillez contacter le support.')),
        );
      } else if (e.code == 'too-many-requests') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trop de tentatives. Veuillez réessayer plus tard.')),
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Informations de connexion incorrectes')),
          );
        }
      }
    }
  }

  Future<void> attemptLoginAndSendBackErrorMessage(BuildContext context, dynamic credential) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      if (userCredential.user != null) {
        Navigator.pushReplacementNamed(context, RoutePage.routeName);
      }else{
        ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Erreur de connexion ! Veuillliez réessayer')),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
      ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('The verification code is invalid. Please try again.')));
      } else if (e.code == 'user-disabled') {
      ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('This user has been disabled. Please contact support.')));
      } else if (e.code == 'operation-not-allowed') {
      ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('This operation is not allowed. Please enable it in the Firebase console.')));
      } else if (e.code == 'too-many-requests') {
      ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Too many requests. Please try again later.')));
      } else { if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred during sign-in: ${e.message}')));
        }
      }
    }
  }

  @override
  checkIfEmailExists(String email) {
    return true;
    throw UnimplementedError();
  }

  @override
  checkIfPhoneExists(String phone) {
    return true;
    throw UnimplementedError();
  }

  @override
  void registerUser(BuildContext context, String trim, String trim2, String trim3, String trim4, String trim5, String trim6, String trim7, String trim8, String trim9, String trim10, String trim11) {
    // TODO: implement registerUser
  }
  @override
  Future<bool> isEmailRegistered(String email, String phoneNumber) async {
    return false;
    //ici communication avec le serveur pour verifier si l'email ou le numero de telephone existe
    try {
      final List<String> signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      return signInMethods.isNotEmpty;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        print('Email invalide : $email');
      } else {
        print('Erreur Firebase : ${e.code}');
      }
      return false;
    } catch (e) {
      print('Erreur inconnue : $e');
      return false;
    }
  }


  @override
  Future<bool> isPhoneNumberRegistred(String phoneNumber) async {
    try {
      final methods = await _firebaseAuth.fetchSignInMethodsForEmail(
          phoneNumber);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

}