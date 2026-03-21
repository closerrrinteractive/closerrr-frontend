import 'dart:convert';
import 'package:closerrr/core/services/custom_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool? initilized;

getSharedPrefInstance() async {
  return await SharedPreferences.getInstance();
}

setDataInShared(String key, dynamic data) async {
  final pref = await getSharedPrefInstance();
  pref.remove(key);
  pref.setString(key, jsonEncode(data));
}

getDataFromShared(String key) async {
  final pref = await getSharedPrefInstance();
  String? data = pref.getString(key);

  if (data != null) {
    final parseData = jsonDecode(data);
    return parseData;
  }

  return null;
}

setInitialData() async {
  dynamic data = await getDataFromShared("initilized");
  initilized = data;
}

Future<void> deleteDataFromShared(String key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // Firebase Token Remove
  FirebaseMessaging.instance.deleteToken();
  if (prefs.containsKey(key)) {
    prefs.remove(key);
    kLog('Data with key $key removed from SharedPreferences.');
  } else {
    kLog('No data found with key $key in SharedPreferences.');
  }
}
