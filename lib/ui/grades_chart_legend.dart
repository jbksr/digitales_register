import 'package:dr/container/chart_legend_entry_container.dart';
import 'package:flutter/material.dart';
import 'package:built_collection/built_collection.dart';

class ChartLegend extends StatelessWidget {
  final BuiltList<int> vm;

  const ChartLegend({Key key, this.vm}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return ExpansionTile(
      title: Text("Legende"),
      children: <Widget>[
        // supports the case when there are not enough subjects to fill the available vertical space.
        // this is, however, quite unlikely.
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: height / 2 - 90,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return ChartLegendEntryContainer(
                id: vm[index],
              );
            },
            itemCount: vm.length,
          ),
        )
      ],
    );
  }
}
