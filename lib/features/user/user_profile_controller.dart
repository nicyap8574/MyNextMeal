import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../utils/popups/loaders.dart';

class UserProfileController extends GetxController {
  static UserProfileController get instance => Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late final user = _auth.currentUser;

  Map<String, dynamic>? cachedData;

  Future<void> saveChanges({
    required BuildContext context,
    required List<String> selectedDietOptions,
    required List<String> selectedDietaryFocus,
  }) async {
    try {
      await _db.collection('users').doc(user!.uid).set({
        'dietOptions': selectedDietOptions,
        'dietaryFocus': selectedDietaryFocus,
      }, SetOptions(merge: true));

      cachedData = {
        ...?cachedData,
        'dietOptions': selectedDietOptions,
        'dietaryFocus': selectedDietaryFocus,
      };

      AppLoaders.showSnackBar(context, 'Goals updated');
    } catch (e) {
      debugPrint('Error saving changes: $e');
      AppLoaders.showSnackBar(context, 'Could not save goals. Try again.');
    }
  }

  Future<void> saveDietaryRestrictions({
    required BuildContext context,
    required List<String> restrictions,
  }) async {
    try {
      await _db.collection('users').doc(user!.uid).set({
        'dietaryRestrictions': restrictions,
      }, SetOptions(merge: true));

      cachedData = {
        ...?cachedData,
        'dietaryRestrictions': restrictions,
      };

      AppLoaders.showSnackBar(context, 'Restrictions updated');
    } catch (e) {
      debugPrint('Error saving restrictions: $e');
      AppLoaders.showSnackBar(context, 'Could not save restrictions.');
    }
  }

  Future<void> saveNotificationPrefs({
    required BuildContext context,
    required bool mealRemindersEnabled,
    required bool breakfastReminder,
    required bool lunchReminder,
    required bool dinnerReminder,
  }) async {
    try {
      await _db.collection('users').doc(user!.uid).set({
        'mealRemindersEnabled': mealRemindersEnabled,
        'breakfastReminder': breakfastReminder,
        'lunchReminder': lunchReminder,
        'dinnerReminder': dinnerReminder,
      }, SetOptions(merge: true));

      cachedData = {
        ...?cachedData,
        'mealRemindersEnabled': mealRemindersEnabled,
        'breakfastReminder': breakfastReminder,
        'lunchReminder': lunchReminder,
        'dinnerReminder': dinnerReminder,
      };
    } catch (e) {
      debugPrint('Error saving notification prefs: $e');
      AppLoaders.showSnackBar(context, 'Could not save reminder settings.');
    }
  }

  Future<String?> exportUserData() async {
    try {
      final details = await getUserDetails();
      final mealsSnapshot = await _db
          .collection('meals')
          .where('user', isEqualTo: user!.uid)
          .orderBy('createdAt', descending: true)
          .get();

      final meals = mealsSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      final exportPayload = {
        'exportedAt': DateTime.now().toIso8601String(),
        'profile': details ?? {},
        'meals': meals,
      };

      return const JsonEncoder.withIndent('  ').convert(exportPayload);
    } catch (e) {
      debugPrint('Error exporting data: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserDetails() async {
    if (cachedData != null) {
      return cachedData;
    } else {
      final doc = await _db.collection('users').doc(user!.uid).get();

      if (doc.exists) {
        cachedData = doc.data();
        return doc.data();
      }
      return null;
    }
  }

  void invalidateCache() {
    cachedData = null;
  }
}
