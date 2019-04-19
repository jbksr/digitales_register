import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../actions.dart';
import '../app_state.dart';
import '../data.dart';
import '../main.dart';
import '../ui/notifications_page_content.dart';

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, NotificationsViewModel>(
      builder: (BuildContext context, NotificationsViewModel vm) {
        return NotificationPageContent(vm: vm);
      },
      converter: (Store<AppState> store) {
        return NotificationsViewModel.from(store);
      },
    );
  }
}

Function deepEq = const DeepCollectionEquality().equals;

class NotificationsViewModel {
  final List<Notification> notifications;
  final SingleArgumentVoidCallback<Notification> deleteNotification;
  final VoidCallback deleteAllNotifications;

  @override
  operator ==(other) {
    return other is NotificationsViewModel &&
        deepEq(other.notifications, notifications);
  }

  NotificationsViewModel.from(Store<AppState> store)
      : notifications = store.state.notificationState.notifications.toList(),
        deleteNotification = ((notification) =>
            store.dispatch(DeleteNotificationAction(notification))),
        deleteAllNotifications =
            (() => store.dispatch(DeleteAllNotificationsAction()));
}
