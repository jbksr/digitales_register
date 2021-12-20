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

import 'dart:collection';
import 'dart:convert';

import 'package:built_redux/built_redux.dart';
import 'package:dr/actions/app_actions.dart';
import 'package:dr/actions/login_actions.dart';
import 'package:dr/app_state.dart';
import 'package:dr/main.dart';
import 'package:dr/middleware/middleware.dart';
import 'package:dr/reducer/reducer.dart';
import 'package:dr/serializers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiver/testing/src/async/fake_async.dart';

const serverUrl = "null/v2/api/auth/login";

/// Implememts [FlutterSecureStorage] in memory.
class FakeSecureStorage implements FlutterSecureStorage {
  FakeSecureStorage({Map<String, String>? storage}) : storage = storage ?? {};

  final Map<String, String> storage;
  @override
  Future<bool> containsKey({
    String? key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
  }) async {
    return storage.containsKey(key);
  }

  @override
  Future<void> delete({
    String? key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
  }) async {
    storage.remove(key);
  }

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
  }) async {
    storage.clear();
  }

  @override
  Future<String?> read({
    String? key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
  }) async {
    return storage[key];
  }

  @override
  Future<Map<String, String>> readAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
  }) async {
    return storage;
  }

  @override
  Future<void> write({
    String? key,
    String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
  }) async {
    storage[key!] = value!;
  }
}

class StorageHelper {
  Future<bool> exists(String user) async {
    final value = await read(user);
    return value != null;
  }

  Future<String?> read(String user) async {
    return secureStorage.read(key: getStorageKey(user, serverUrl));
  }

  Future<void> cleanup() async {
    await secureStorage.deleteAll();
  }
}

void main() {
  secureStorage = FakeSecureStorage();
  final storageHelper = StorageHelper();

  tearDown(() {
    deletedData = false;
    storageHelper.cleanup();
  });

  test('save state occurs after five seconds', () {
    FakeAsync().run((async) async {
      const username = "test_username";
      final store = Store<AppState, AppStateBuilder, AppActions>(
        appReducerBuilder.build(),
        AppState((b) => b.loginState
          ..loggedIn = true
          ..username = username),
        AppActions(),
        middleware: middleware(includeErrorMiddleware: false),
      );
      // dispatch any action to trigger a state save
      await store.actions.setUrl("abc");
      // saving the state is throttled by five seconds
      async.elapse(const Duration(seconds: 1));

      expect(
        await storageHelper.exists(username),
        false,
      );
      // after over 5 seconds, the state should be saved
      async.elapse(const Duration(seconds: 6));
      expect(
        await storageHelper.exists(username),
        true,
      );
    });
  });
  test('save state occurs immediately', () async {
    const username = "test_username2";
    final store = Store<AppState, AppStateBuilder, AppActions>(
      appReducerBuilder.build(),
      AppState((b) => b.loginState
        ..loggedIn = true
        ..username = username),
      AppActions(),
      middleware: middleware(includeErrorMiddleware: false),
    );

    await store.actions.saveState();

    // the state should be saved immediately
    expect(
      await storageHelper.exists(username),
      true,
    );
    expect(
        serializers.deserialize(
            json.decode((await storageHelper.read(username))!) as Object),
        const TypeMatcher<AppState>());
  });
  test('state is not saved when data saving is disabled', () async {
    const username = "test_username2";
    final store = Store<AppState, AppStateBuilder, AppActions>(
      appReducerBuilder.build(),
      AppState(
        (b) {
          b.loginState
            ..loggedIn = true
            ..username = username;
          b.settingsState.noDataSaving = true;
        },
      ),
      AppActions(),
      middleware: middleware(includeErrorMiddleware: false),
    );

    await store.actions.saveState();

    expect(
      await storageHelper.exists(username),
      true,
    );

    expect(
        serializers.deserialize(
            json.decode((await storageHelper.read(username))!) as Object),
        const TypeMatcher<SettingsState>());
  });
  test('state is deleted on logout when state saving is disabled', () async {
    navigatorKey = GlobalKey();
    const username = "test_username3";
    final store = Store<AppState, AppStateBuilder, AppActions>(
      appReducerBuilder.build(),
      AppState(
        (b) {
          b.loginState
            ..loggedIn = true
            ..username = username;
          b.settingsState.deleteDataOnLogout = true;
        },
      ),
      AppActions(),
      middleware: middleware(includeErrorMiddleware: false),
    );

    await store.actions.saveState();

    // the state should be saved immediately
    expect(
      await storageHelper.exists(username),
      true,
    );

    expect(
        serializers.deserialize(
            json.decode((await storageHelper.read(username))!) as Object),
        const TypeMatcher<AppState>());
    await store.actions.loginActions.logout(
      LogoutPayload(
        (b) => b
          ..hard = true
          ..forced = true,
      ),
    );

    expect(
        serializers.deserialize(
            json.decode((await storageHelper.read(username))!) as Object),
        const TypeMatcher<SettingsState>());
  });
  test('state is deleted/saved when the setting is switched', () async {
    const username = "test_username4";
    final store = Store<AppState, AppStateBuilder, AppActions>(
      appReducerBuilder.build(),
      AppState(
        (b) {
          b.loginState
            ..loggedIn = true
            ..username = username;
          b.settingsState.noDataSaving = false;
        },
      ),
      AppActions(),
      middleware: middleware(includeErrorMiddleware: false),
    );

    await store.actions.saveState();

    // the state should be saved immediately
    expect(
      await storageHelper.exists(username),
      true,
    );

    expect(
        serializers.deserialize(
            json.decode((await storageHelper.read(username))!) as Object),
        const TypeMatcher<AppState>());

    await store.actions.settingsActions.saveNoData(true);

    expect(
        serializers.deserialize(
            json.decode((await storageHelper.read(username))!) as Object),
        const TypeMatcher<SettingsState>());

    await store.actions.settingsActions.saveNoData(false);

    expect(
        serializers.deserialize(
            json.decode((await storageHelper.read(username))!) as Object),
        const TypeMatcher<AppState>());

    await store.actions.settingsActions.saveNoData(true);

    expect(
        serializers.deserialize(
            json.decode((await storageHelper.read(username))!) as Object),
        const TypeMatcher<SettingsState>());

    await store.actions.settingsActions.saveNoData(false);

    expect(
        serializers.deserialize(
            json.decode((await storageHelper.read(username))!) as Object),
        const TypeMatcher<AppState>());
  });

  test('Default map is ordered', () {
    expect({"username": "asdf", "url": "foo"}, isA<LinkedHashMap>());
    final keys = {"username": "asdf", "url": "foo"}.keys.toList();
    expect(keys[0], "username");
    expect(keys[1], "url");
  });
}
