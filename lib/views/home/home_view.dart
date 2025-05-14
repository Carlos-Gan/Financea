// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'package:financea/model/category/category_data.dart';
import 'package:financea/model/datas/add_data.dart';
import 'package:financea/utils/app_colors.dart';
import 'package:financea/utils/app_str.dart';
import 'package:financea/views/home/widget/balance_widget.dart';
import 'package:financea/views/home/widget/expenses_widget.dart';
import 'package:financea/views/home/widget/income_widget.dart';
import 'package:financea/views/home/widget/welcome_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class HomeView extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  var history;
  final box = Hive.box<AddData>('data');
  final categoryBox = Hive.box<Category>('categories');

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryColor(context),
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: SafeArea(
          child: ValueListenableBuilder(
            valueListenable: box.listenable(),
            builder: (context, value, child) {
              return Column(
                children: [
                  SizedBox(height: 300, child: _head(context)),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 20,
                      right: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStr.get('transactionHistory'),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        Text(
                          AppStr.get('seeAll'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColorDark(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            history = box.values.toList()[index];
                            return getList(history, index, context);
                          }, childCount: box.length),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget getList(AddData history, int index, BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      onDismissed: (direction) {
        history.delete();
        log('${history.explain} dismissed');
      },
      child: get(index, history, context),
    );
  }

  ListTile get(int index, AddData history, BuildContext context) {
    final category = categoryBox.values.firstWhere(
      (cat) => cat.name == history.name,
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
        backgroundColor: AppColors.primaryColor(context).withOpacity(0.2),
        child: Icon(category.icon, color: category.color, size: 25),
      ),
      title: Text(
        //Invoca al método geter() y obtiene el nombre de la transacción
        history.explain,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      subtitle: Text(
        //Invoca al método geter() y obtiene la fecha de la transacción
        DateFormat('EEEE, dd/MM/yyyy').format(history.datetime.toLocal()),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
        ),
      ),
      trailing: Column(
        children: [
          Text(
            // Invoca al método getter() y obtiene el monto de la transacción
            history.IN == 'Expense'
                ? '- \$${history.amount}'
                : '+ \$${history.amount}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: history.IN == 'Expense' ? Colors.red : Colors.green,
            ),
          ),
          if (history.IN == 'Expense' && history.meses > 1)
            Text(
              '${AppStr.get('For')} ${history.meses} ${AppStr.get('months')}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }
}

Widget _head(BuildContext context) {
  return Stack(
    children: [
      WelcomeWidget(),
      Positioned(
        top: 130,
        left: 0,
        right: 0,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: Container(
              height: 170,
              width: MediaQuery.of(context).size.width * 0.85,
              decoration: BoxDecoration(
                color: AppColors.primaryColorDark(context),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Balance(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [Income(), Expenses()],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
