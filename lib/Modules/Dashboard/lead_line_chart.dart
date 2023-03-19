import 'package:flutter/material.dart';
import 'package:real_estate_admin/Modules/Dashboard/bar_chart.dart';
import '../../Model/Lead.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class LeadLIneChart extends StatelessWidget {
  const LeadLIneChart({super.key, required this.dateWiseLeads, required this.title});

  final Map<DateTime, int> dateWiseLeads;
  final String title;

  List<ChartXY> getData() {
    Set<ChartXY> list = {};
    int initialValue = 0;
    // var keys = dateWiseLeads.keys.toList().sort((b, a) => a.compareTo(b));
    for (var element in dateWiseLeads.keys) {
      list.add(ChartXY(dateWiseLeads[element] ?? 0, element));
      // initialValue += dateWiseLeads[element] ?? 0;
    }
    return list.toList();
  }

  getSeries() {
    return [
      charts.Series<ChartXY, DateTime>(
        id: 'PER DAY LEAD',
        domainFn: ((datum, index) => datum.date),
        measureFn: (datum, index) => datum.count,
        data: getData(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: AspectRatio(
            aspectRatio: 2,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('LEAD GROWTH'),
                ),
                Expanded(
                  child: charts.TimeSeriesChart(
                    getSeries(),
                    defaultRenderer: charts.LineRendererConfig<DateTime>(),
                    defaultInteractions: false,
                    behaviors: [charts.SelectNearest(), charts.DomainHighlighter()],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
