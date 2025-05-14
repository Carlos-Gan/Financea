import 'package:financea/data/utility.dart';
import 'package:financea/model/category/category_data.dart';
import 'package:financea/model/datas/add_data.dart';
import 'package:financea/utils/app_colors.dart';
import 'package:financea/utils/app_str.dart';
import 'package:financea/views/statistics/widgets/chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  int currentIndex = 0;
  bool showExpenses = true;

  final box = Hive.box<AddData>('data');
  final categoryBox = Hive.box<Category>('categories');

  @override
  Widget build(BuildContext context) {
    var tabs = [
      AppStr.get('day'),
      AppStr.get('week'),
      AppStr.get('month'),
      AppStr.get('year'),
    ];

    List<AddData> rawData;
    switch (currentIndex) {
      case 1:
        rawData = week();
        break;
      case 2:
        rawData = month();
        break;
      case 3:
        rawData = year();
        break;
      default:
        rawData = today();
    }

    final filtered =
        rawData
            .where((d) => showExpenses ? d.IN == 'Expense' : d.IN == 'Income')
            .toList()
          ..sort(
            (a, b) => double.parse(b.amount).compareTo(double.parse(a.amount)),
          );

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                AppStr.get('statistics'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(tabs.length, (i) {
                  final selected = i == currentIndex;
                  return GestureDetector(
                    onTap: () => setState(() => currentIndex = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            selected
                                ? AppColors.primaryColor(context)
                                : AppColors.primaryColorDark(context),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tabs[i],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => showExpenses = !showExpenses),
                    child: Container(
                      width: 120,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            showExpenses
                                ? AppStr.get('expenses')
                                : AppStr.get('income'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryColor(context),
                            ),
                          ),
                          Icon(
                            showExpenses
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Chart(indexx: currentIndex, showExpenses: showExpenses),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStr.get('topSpending'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Icon(Icons.swap_vert, color: AppColors.primaryColor(context)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemBuilder: (context, index) {
                  final item = filtered[index];

                  final category = categoryBox.values.firstWhere(
                    (cat) => cat.name == item.name,
                    orElse:
                        () => Category(
                          name: 'Unknown',
                          icon: FontAwesomeIcons.question,
                          color: Colors.grey,
                        ),
                  );

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: category.color.withOpacity(0.2),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 25,
                      ),
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat(
                        'EEEE, dd/MM/yyyy',
                      ).format(item.datetime.toLocal()),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    trailing: Text(
                      '${showExpenses ? '-' : '+'} \$${item.amount}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: showExpenses ? Colors.red : Colors.green,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
