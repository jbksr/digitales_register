import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:collection/collection.dart';

import '../app_state.dart';
import '../data.dart';
import '../ui/calendar_week.dart';

class CalendarWeekContainer extends StatelessWidget {
  final DateTime monday;

  const CalendarWeekContainer({Key key, this.monday})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      builder: (BuildContext context, vm) {
        return CalendarWeek(vm: vm);
      },
      distinct: true,
      converter: (Store<AppState> store) {
        return CalendarWeekViewModel(store, monday);
      },
    );
  }
}
Function deepEq = const DeepCollectionEquality().equals;
typedef void DayCallback(DateTime day);

class CalendarWeekViewModel {
  final List<CalendarDay> days;

  @override operator ==(other){
    return other is CalendarWeekViewModel && deepEq(other.days, days);
  }

  CalendarWeekViewModel(Store<AppState> store, DateTime monday)
      : days = store.state.calendarState.days.values.where(
          (d) {
            final date = DateTime.utc(d.date.year, d.date.month, d.date.day);
            return !date.isBefore(monday) &&
                date.isBefore(monday.add(Duration(days: 7)));
          },
        ).toList();
}
