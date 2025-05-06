// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'package:financea/model/datas/add_data.dart';
import 'package:financea/utils/app_colors.dart';
import 'package:financea/utils/app_str.dart';
import 'package:financea/views/home/widget/balance_widget.dart';
import 'package:financea/views/home/widget/expenses_widget.dart';
import 'package:financea/views/home/widget/income_widget.dart';
import 'package:financea/views/home/widget/welcome_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class HomeView extends StatelessWidget {
  var history;
  final box = Hive.box<AddData>('data');

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (context, value, child) {
            return Column(
              children: [
                SizedBox(height: 300, child: _head(context)),
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStr.transactionHistory,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        AppStr.seeAll,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryColorDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          history = box.values.toList()[index];
                          return getList(history, index);
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
    );
  }

  Widget getList(AddData history, int index) {
    return Dismissible(
      key: UniqueKey(),
      onDismissed: (direction) {
        history.delete();
        log('${history.explain} dismissed');
      },
      child: get(index, history),
    );
  }

  ListTile get(int index, AddData history) {
    return ListTile(
      leading: ClipRRect(
        child: Image.asset('img/${history.name}.png', height: 45, width: 45),
      ),
      title: Text(
        //Invoca al método geter() y obtiene el nombre de la transacción
        history.explain,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        //Invoca al método geter() y obtiene la fecha de la transacción
        DateFormat('EEEE, dd/MM/yyyy').format(history.datetime.toLocal()),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.black.withOpacity(0.5),
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
              'A ${history.meses} meses',
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
                color: AppColors.secondaryColorDark,
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
