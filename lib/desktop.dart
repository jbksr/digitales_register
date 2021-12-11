// Copyright (C) 2021 Michael Debertol
//
// This file is part of digitales_register.
//
// digitales_register is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// digitales_register is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with digitales_register.  If not, see <http://www.gnu.org/licenses/>.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    as secure_storage;
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

// This file contains wrappers to make initial desktop compatibility easier.

bool isDesktop() {
  return Platform.isMacOS || Platform.isLinux || Platform.isWindows;
}

secure_storage.FlutterSecureStorage getFlutterSecureStorage() {
  if (isDesktop()) {
    return DesktopSecureStorage();
  } else {
    return const secure_storage.FlutterSecureStorage();
  }
}

// Uses a different implementation to work on desktop. We cannot switch to
// this impl for every platform because that would break bakcwards compatibility.
class DesktopSecureStorage implements secure_storage.FlutterSecureStorage {
  Future<Box<String>> hiveBox = getEncryptedBox();
  DesktopSecureStorage();
  static Future<Box<String>> getEncryptedBox() async {
    print("getting box");
    final applicationDocumentDirectory = await getApplicationSupportDirectory();
    print("dir: $applicationDocumentDirectory");
    final dbDirectory =
        Directory("${applicationDocumentDirectory.path}/RegisterDB");
    if (!await dbDirectory.exists()) {
      print("creating file");
      await dbDirectory.create();
    }
    print("init hive");
    Hive.init(dbDirectory.path);
    print("getting biometricStorage");
    final biometricStorage = await BiometricStorage().getStorage(
      "",
      options: StorageFileInitOptions(
        authenticationRequired: false,
      ),
    );
    print("reading key");
    var key = await biometricStorage.read();
    if (key == null) {
      print("generating new key");
      key = base64UrlEncode(Hive.generateSecureKey());
      await biometricStorage.write(key);
    }
    print("openBox");
    return Hive.openBox('database',
        encryptionCipher: HiveAesCipher(base64Decode(key)));
  }

  @override
  Future<void> delete({
    required String key,
    secure_storage.IOSOptions? iOptions,
    secure_storage.AndroidOptions? aOptions,
    secure_storage.LinuxOptions? lOptions,
  }) async {
    (await hiveBox).delete(key);
  }

  @override
  Future<void> deleteAll({
    secure_storage.IOSOptions? iOptions,
    secure_storage.AndroidOptions? aOptions,
    secure_storage.LinuxOptions? lOptions,
  }) async {
    (await hiveBox).clear();
  }

  @override
  Future<String?> read({
    required String key,
    secure_storage.IOSOptions? iOptions,
    secure_storage.AndroidOptions? aOptions,
    secure_storage.LinuxOptions? lOptions,
  }) async {
    return (await hiveBox).get(key);
  }

  @override
  Future<Map<String, String>> readAll({
    secure_storage.IOSOptions? iOptions,
    secure_storage.AndroidOptions? aOptions,
    secure_storage.LinuxOptions? lOptions,
  }) async {
    return (await hiveBox).toMap() as Map<String, String>;
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    secure_storage.IOSOptions? iOptions,
    secure_storage.AndroidOptions? aOptions,
    secure_storage.LinuxOptions? lOptions,
  }) async {
    return (await hiveBox).put(key, value!);
  }

  @override
  Future<bool> containsKey({
    required String key,
    secure_storage.IOSOptions? iOptions,
    secure_storage.AndroidOptions? aOptions,
    secure_storage.LinuxOptions? lOptions,
  }) async {
    return (await hiveBox).containsKey(key);
  }
}
