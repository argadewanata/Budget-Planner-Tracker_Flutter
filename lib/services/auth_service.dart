import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Stream<String> onAuthStateChanged() {
    return _auth.authStateChanges().map((User? user) => user?.uid ?? '');
  }

  String getCurrentUserId() {
    return _auth.currentUser?.uid ?? '';
  }

  Future getCurrentUser() async {
    return _auth.currentUser;
  }

  getProfileImage() {
    if (_auth.currentUser != null && _auth.currentUser?.photoURL != null) {
      return Image.network(_auth.currentUser!.photoURL!);
    }
    return const Icon(Icons.account_circle, size: 100);
  }

  Future updateUsername(String name, User currentUser) async {
    await currentUser.updateDisplayName(name);
    await currentUser.reload();
  }

  Future<String> registerEmail(
    String email,
    String password,
    String name,
  ) async {
    final response = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection('Users').doc(response.user!.uid).set({
      'name': name,
    });

    await updateUsername(name, response.user!);
    return response.user?.uid ?? '';
  }

  Future<String> loginEmail(String email, String password) async {
    final response = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return response.user?.uid ?? '';
  }

  Future loginGuest() async {
    final response = await _auth.signInAnonymously();
    return response.user?.uid ?? '';
  }

  logout() async {
    await _auth.signOut();
  }

  Future forgotPassword(String email) async {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future updateUserWithEmail(String email, String password, String name) async {
    final currentUser = _auth.currentUser;
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await currentUser!.linkWithCredential(credential);
    await updateUsername(name, currentUser);
  }
}

class NameValidator {
  static String? validate(String? value) {
    if (value!.isEmpty) {
      return "Name can't be empty";
    }
    if (value.length < 2) {
      return "Name must be at least 2 characters long";
    }
    if (value.length > 50) {
      return "Name must be less than 50 characters long";
    }
    return null;
  }
}

class EmailValidator {
  static String? validate(String? value) {
    if (value!.isEmpty) {
      return "Email can't be empty";
    }
    if (!value.contains('@')) {
      return "Email must contain an @ symbol";
    }
    return null;
  }
}

class PasswordValidator {
  static String? validate(String? value) {
    if (value!.isEmpty) {
      return "Password can't be empty";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters long";
    }
    return null;
  }
}
