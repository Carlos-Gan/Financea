import 'package:financea/data/utility.dart';
import 'package:financea/model/datas/add_data.dart';
import 'package:financea/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

/// Chart dinámico para Day/Week/Month/Year con filtro Expense/Income
class Chart extends StatefulWidget {
  final int indexx; // 0:Day,1:Week,2:Month,3:Year
  final bool showExpenses; // true=expenses, false=income
  const Chart({super.key, required this.indexx, required this.showExpenses});

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  late List<SalesData> data;

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  @override
  void didUpdateWidget(covariant Chart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.indexx != widget.indexx || oldWidget.showExpenses != widget.showExpenses) {
      _prepareData();
      setState(() {});
    }
  }

  void _prepareData() {
    List<AddData> records;
    DateTime now = DateTime.now();
    String filterType = widget.showExpenses ? 'Expense' : 'Income';

    switch (widget.indexx) {
      case 0:
        records = today();
        // horas
        Map<int, double> map = {for (var h = 0; h < 24; h++) h: 0};
        for (var r in records) {
          if (r.IN == filterType) {
            int h = r.datetime.toLocal().hour;
            map[h] = map[h]! + double.tryParse(r.amount)!;
          }
        }
        data = map.entries.map((e) => SalesData(e.key.toString(), e.value)).toList();
        break;
      case 1:
        records = week();
        Map<String, double> dayMap = {};
        for (int i = 0; i < 7; i++) {
          final dt = now.subtract(Duration(days: now.weekday - 1 - i));
          final label = DateFormat('EEE').format(dt);
          dayMap[label] = 0;
        }
        for (var r in records) {
          if (r.IN == filterType) {
            final lbl = DateFormat('EEE').format(r.datetime.toLocal());
            dayMap[lbl] = dayMap[lbl]! + double.tryParse(r.amount)!;
          }
        }
        data = dayMap.entries.map((e) => SalesData(e.key, e.value)).toList();
        break;
      case 2:
        records = month();
        int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        Map<int, double> monthMap = {for (var d = 1; d <= daysInMonth; d++) d: 0};
        for (var r in records) {
          if (r.IN == filterType) {
            int d = r.datetime.toLocal().day;
            monthMap[d] = monthMap[d]! + double.tryParse(r.amount)!;
          }
        }
        data = monthMap.entries.map((e) => SalesData(e.key.toString(), e.value)).toList();
        break;
      case 3:
        records = year();
        Map<int, double> yearMap = {for (var m = 1; m <= 12; m++) m: 0};
        for (var r in records) {
          if (r.IN == filterType) {
            int m = r.datetime.toLocal().month;
            yearMap[m] = yearMap[m]! + double.tryParse(r.amount)!;
          }
        }
        data = yearMap.entries.map((e) => SalesData(DateFormat('MMM').format(DateTime(now.year, e.key)), e.value)).toList();
        break;
      default:
        data = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        series: <SplineSeries<SalesData, String>>[
          SplineSeries<SalesData, String>(
            color: AppColors.secondaryColor,
            width: 3,
            dataSource: data,
            xValueMapper: (SalesData sd, _) => sd.label,
            yValueMapper: (SalesData sd, _) => sd.sales,
          ),
        ],
      ),
    );
  }
}

class SalesData {
  SalesData(this.label, this.sales);
  final String label;
  final double sales;
}
