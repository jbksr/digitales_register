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

import 'package:built_redux/built_redux.dart';

import 'package:dr/actions/app_actions.dart';
import 'package:dr/app_state.dart';

final networkProtocolReducerBuilder = NestedReducerBuilder<AppState,
    AppStateBuilder, NetworkProtocolState, NetworkProtocolStateBuilder>(
  (s) => s.networkProtocolState,
  (b) => b.networkProtocolState,
)..add(AppActionsNames.addNetworkProtocolItem, _networkProtocol);

void _networkProtocol(NetworkProtocolState state,
    Action<NetworkProtocolItem> action, NetworkProtocolStateBuilder builder) {
  builder.items.add(action.payload);
}
