import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    as secure_storage;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:biometric_storage/biometric_storage.dart';
import 'package:path_provider/path_provider.dart';

// This file contains wrappers to make initial desktop compatibility easier.

bool isDesktop() {
  return Platform.isMacOS || Platform.isLinux || Platform.isWindows;
}

secure_storage.FlutterSecureStorage getFlutterSecureStorage() {
  if (isDesktop()) {
    return DesktopSecureStorage();
  } else {
    return secure_storage.FlutterSecureStorage();
  }
}

// Uses a different implementation to work on desktop. We cannot switch to
// this impl for every platform because that would break bakcwards compatibility.
class DesktopSecureStorage implements secure_storage.FlutterSecureStorage {
  Future<Box<String>> hiveBox = getEncryptedBox();
  DesktopSecureStorage();
  static Future<Box<String>> getEncryptedBox() async {
    final applicationDocumentDirectory =
        await getApplicationSupportDirectory() ;
    final homeDirectory =
        Directory(applicationDocumentDirectory.path + "/RegisterDB");
    if (!await homeDirectory.exists()) {
      await homeDirectory.create();
    } 
    Hive.init(homeDirectory.path);
    final biometricStorage = await BiometricStorage().getStorage(
      "",
      options: StorageFileInitOptions(
        authenticationRequired: false,
      ),
    );
    var key = await biometricStorage.read();
    if (key == null) {
      key = base64UrlEncode(Hive.generateSecureKey());
      await biometricStorage.write(key);
    }
    return await Hive.openBox('database',
        encryptionCipher: HiveAesCipher(base64Decode(key)));
  }

  @override
  Future<void> delete(
      {String key,
      dynamic iOptions,
      secure_storage.AndroidOptions aOptions}) async {
    (await hiveBox).delete(key);
  }

  @override
  Future<void> deleteAll(
      {dynamic iOptions, secure_storage.AndroidOptions aOptions}) async {
    (await hiveBox).clear();
  }

  @override
  Future<String> read(
      {String key,
      dynamic iOptions,
      secure_storage.AndroidOptions aOptions}) async {
    return (await hiveBox).get(key);
  }

  @override
  Future<Map<String, String>> readAll(
      {dynamic iOptions, secure_storage.AndroidOptions aOptions}) async {
    return (await hiveBox).toMap();
  }

  @override
  Future<void> write(
      {String key,
      String value,
      dynamic iOptions,
      secure_storage.AndroidOptions aOptions}) async {
    return (await hiveBox).put(key, value);
  }

  @override
  Future<bool> containsKey(
      {String key,
      secure_storage.IOSOptions iOptions,
      secure_storage.AndroidOptions aOptions}) async {
    return (await hiveBox).containsKey(key);
  }
}

void showToast({String msg, Toast toastLength}) {
  if (!Platform.isAndroid) {
    // We need to fix this anyways; I believe bottom sheets are the way to go.
    print(
        "TOAST: - - - - - - - - - - - - ... $msg ... - - - - - - - - - - - -");
  } else {
    Fluttertoast.showToast(msg: msg, toastLength: toastLength);
  }
}
