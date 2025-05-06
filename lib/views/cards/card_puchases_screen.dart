import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:financea/model/datas/add_data.dart';
import 'package:financea/model/card/card_data.dart';
import 'package:financea/utils/app_colors.dart';
import 'package:financea/utils/app_str.dart';

class CardPurchasesScreen extends StatelessWidget {
  final CardData card;

  const CardPurchasesScreen({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final Box<AddData> dataBox = Hive.box<AddData>('data');
    final List<AddData> purchases = dataBox.values
        .where((e) => e.pay == card.cardName)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Compras - ${card.cardName}'),
        backgroundColor: AppColors.secondaryColor,
      ),
      body: purchases.isEmpty
          ? const Center(child: Text(AppStr.noTransactions))
          : ListView.builder(
              itemCount: purchases.length,
              itemBuilder: (context, index) {
                final item = purchases[index];
                return ListTile(
                  title: Text(item.explain),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy').format(item.datetime),
                  ),
                  trailing: Text(
                    '\$${item.amount}',
                    style: TextStyle(
                      color: item.IN == 'Expense' ? Colors.red : Colors.green,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
