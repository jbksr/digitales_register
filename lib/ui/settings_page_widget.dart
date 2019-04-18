import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';

import '../container/settings_page.dart';

class SettingsPageWidget extends StatelessWidget {
  final SettingsViewModel vm;

  const SettingsPageWidget({Key key, this.vm}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Einstellungen"),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(
              "Sicherheit",
              style: Theme.of(context).textTheme.headline,
            ),
          ),
          SwitchListTile(
            title: Text("Angemeldet bleiben"),
            onChanged: (bool value) {
              vm.onSetNoPassSaving(!value);
            },
            value: !vm.noPassSaving,
          ),
          SwitchListTile(
            title: Text("Offline-Modus aktivieren"),
            subtitle: vm.noPassSaving
                ? Text('Nur möglich, wenn "Angemeldet bleiben" aktiviert ist')
                : null,
            onChanged: vm.noPassSaving
                ? null
                : (bool value) {
                    vm.onSetNoDataSaving(!value);
                  },
            value: !vm.noDataSaving,
          ),
          Divider(),
          ListTile(
            title: Text(
              "Erscheinung",
              style: Theme.of(context).textTheme.headline,
            ),
          ),
          SwitchListTile(
            title: Text("Dark Mode"),
            onChanged: (bool value) {
              vm.onSetDarkMode(value);
            },
            value: DynamicTheme.of(context).brightness == Brightness.dark,
          ),
          Divider(),
          ListTile(
            title: Text(
              "Sonstiges",
              style: Theme.of(context).textTheme.headline,
            ),
          ),
          SwitchListTile(
            title: Text(
                "Doppelt tippen, um Hausaufgaben als erledigt zu markieren"),
            onChanged: (bool value) {
              vm.onSetDoubleTapForDone(value);
            },
            value: vm.doubleTapForDone,
          ),
          SwitchListTile(
            title: Text(
                'Keinen Notendurchschnitt berechnen, wenn "Beide Semester" ausgewählt ist'),
            onChanged: (bool value) {
              vm.onSetNoAverageForAllSemester(value);
            },
            value: vm.noAverageForAllSemester,
          ),
          SwitchListTile(
            title: Text("Beim Löschen von Erinnerungen fragen"),
            onChanged: (bool value) {
              vm.onSetAskWhenDelete(value);
            },
            value: vm.askWhenDelete,
          ),
        ],
      ),
    );
  }
}
