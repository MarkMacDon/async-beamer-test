import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class AuthRepository {
  const AuthRepository(this.sharedPreferences);
  final SharedPreferences sharedPreferences;

  Future<bool> getIsSignedIn() async {
    await Future.delayed(Duration(seconds: 2));
    return sharedPreferences.getBool('signedIn') ?? false;
  }

  Future<bool> signInUser() async {
    await Future.delayed(Duration(seconds: 3));
    sharedPreferences.setBool('signedIn', true);
    return true;
  }

  Future<bool> signOutUser() async {
    await Future.delayed(Duration(seconds: 3));
    sharedPreferences.setBool('signedIn', true);
    return false;
  }
}

class NavigationStateRepository {
  const NavigationStateRepository(this.sharedPreferences);
  final SharedPreferences sharedPreferences;

  String get booksLocation {
    final result =
        sharedPreferences.getString('booksLocation') ?? '/home/books';
    debugLog("NavigationStateRepository | get booksLocation | "
        "location to be returned: $result");
    return result;
  }

  set booksLocation(String location) {
    sharedPreferences.setString('booksLocation', location);
    debugLog("NavigationStateRepository | set booksLocation | "
        "new location was just set: $location");
  }

  String get articlesLocation {
    final result =
        sharedPreferences.getString('articlesLocation') ?? '/home/articles';
    debugLog("NavigationStateRepository | get articlesLocation | "
        "location to be returned: $result");
    return result;
  }

  set articlesLocation(String location) {
    sharedPreferences.setString('articlesLocation', location);
    debugLog("NavigationStateRepository | set articlesLocation | "
        "new location was just set: $location");
  }

  String get lastLocation {
    final result = sharedPreferences.getString('lastLocation') ?? '/home/books';
    debugLog("NavigationStateRepository | get lastLocation | "
        "location to be returned: $result");
    return result;
  }

  set lastLocation(String location) {
    sharedPreferences.setString('lastLocation', location);
    debugLog("NavigationStateRepository | set lastLocation | "
        "new location was just set: $location");
  }
}

class BluetoothRepository {
  Stream<int> getRandomNumberStream() {
    return Stream<int>.periodic(
        Duration(seconds: 1), (index) => Random().nextInt(10));
  }
}
