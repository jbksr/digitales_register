import 'package:redux/redux.dart';

import '../actions.dart';
import '../app_state.dart';

SettingsStateBuilder settingsStateReducer(SettingsStateBuilder state, action) {
  return action is SettingsLoadedAction
      ? action.state.toBuilder()
      : (state
        ..noDataSaving = _saveDataReducer(state.noDataSaving, action)
        ..noPasswordSaving = _savePassReducer(state.noPasswordSaving, action)
        ..askWhenDelete = _askWhenDeleteReducer(state.askWhenDelete, action)
        ..doubleTapForDone =
            _doubleTapForDoneReducer(state.doubleTapForDone, action)
        ..noAverageForAllSemester =
            _noAvgForAllReducer(state.noAverageForAllSemester, action)
        ..showCancelled = _showCancelledReducer(state.showCancelled, action)
        ..typeSorted = _sortByTypeReducer(state.typeSorted, action));
}

final _askWhenDeleteReducer =
    TypedReducer((bool ask, SetAskWhenDeleteAction action) => action.ask);
final _noAvgForAllReducer =
    TypedReducer((bool noAvg, SetNoAverageForAllAction action) => action.noAvg);
final _showCancelledReducer = TypedReducer(
    (bool showCancelled, SetGradesShowCancelledAction action) =>
        action.showCancelled);
final _doubleTapForDoneReducer = TypedReducer(
    (bool enabled, SetDoubleTapForDoneAction action) => action.enabled);
final _sortByTypeReducer = TypedReducer(
    (bool typeSorted, SetGradesTypeSortedAction action) => action.typeSorted);
final _saveDataReducer =
    TypedReducer((bool safeMode, SetSaveNoDataAction action) => action.noSave);
final _savePassReducer =
    TypedReducer((bool safeMode, SetSaveNoPassAction action) => action.noSave);
