import 'package:flutter/material.dart';
import 'package:real_estate_admin/Model/Lead.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class LeadChart extends StatelessWidget {
  const LeadChart({super.key, required this.dateWiseLeads, required this.title, required this.color});

  final Map<DateTime, List<Lead>> dateWiseLeads;
  final String title;
  final Color color;

  List<ChartXY> getData() {
    Set<ChartXY> list = {};

    for (int i = 0; i < 30; i++) {
      var date = DateTime.now().subtract(Duration(days: i)).trimTime();
      if (dateWiseLeads.keys.contains(date)) {
        list.add(ChartXY(dateWiseLeads[date]?.length ?? 0, date));
      } else {
        list.add(ChartXY(0, date));
      }
    }

    return list.toList();
  }

  getSeries() {
    return [
      charts.Series<ChartXY, DateTime>(
        id: 'PER DAY LEAD',
        domainFn: ((datum, index) => datum.date),
        measureFn: (datum, index) => datum.count,
        colorFn: (datum, index) => charts.ColorUtil.fromDartColor(color),
        data: getData(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(title),
            ),
            Expanded(
              child: charts.TimeSeriesChart(
                getSeries(),
                defaultRenderer: charts.BarRendererConfig<DateTime>(),
                defaultInteractions: false,
                behaviors: [charts.SelectNearest(), charts.DomainHighlighter()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartXY {
  final int count;
  final DateTime date;
  ChartXY(this.count, this.date);

  @override
  bool operator ==(e) => e is ChartXY && date == e.date;
  @override
  int get hashCode => Object.hash(date, null);
}

extension DateTrim on DateTime {
  DateTime trimTime() {
    return DateTime(year, month, day);
  }
}
