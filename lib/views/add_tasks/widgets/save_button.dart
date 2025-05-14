import 'package:financea/utils/app_colors.dart';
import 'package:financea/utils/app_str.dart';
import 'package:flutter/material.dart';
import 'package:financea/model/datas/add_data.dart';
import 'package:financea/model/card/card_data.dart';
import 'package:hive/hive.dart';

class SaveButton extends StatelessWidget {
  final BuildContext context;
  final String? selectedCategory;
  final String? selectedType;
  final TextEditingController amountController;
  final TextEditingController explanationController;
  final DateTime selectedDate;
  final CardData? selectedCard;
  final bool isSubscription;
  final int selectedMonths;
  final VoidCallback onSuccess;
  final Box<AddData> dataBox;
  final Box<CardData> cardBox;

  const SaveButton({
    super.key,
    required this.context,
    required this.selectedCategory,
    required this.selectedType,
    required this.amountController,
    required this.explanationController,
    required this.selectedDate,
    required this.selectedCard,
    required this.isSubscription,
    required this.selectedMonths,
    required this.onSuccess,
    required this.dataBox,
    required this.cardBox,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _saveTransaction,
      child: Container(
        alignment: Alignment.center,
        height: 50,
        width: MediaQuery.of(context).size.width - 200,
        decoration: BoxDecoration(
          color: AppColors.primaryColor(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          AppStr.get('save'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _saveTransaction() {
    if (!_validateFields()) return;

    final amount = double.tryParse(amountController.text);
    if (amount == null) {
      _showError(AppStr.get('invalidAmount'));
      return;
    }

    final transaction = _createTransaction();
    _saveToDatabase(transaction);
    _updateCardBalance(amount);
    _logTransaction(transaction);
    onSuccess();
  }

  bool _validateFields() {
    if (selectedCategory == null || 
        selectedType == null || 
        amountController.text.isEmpty) {
      _showError(AppStr.get('fillAllFields'));
      return false;
    }
    return true;
  }

  AddData _createTransaction() {
    return AddData(
      selectedCategory!,
      explanationController.text,
      amountController.text,
      selectedType!,
      selectedDate,
      selectedCard?.cardName ?? AppStr.get('noPaymentMethod'),
      isSubscription,
      selectedType == 'Expense' && selectedCard?.isCredit == true 
          ? selectedMonths 
          : 1,
    );
  }

  void _saveToDatabase(AddData transaction) {
    dataBox.add(transaction);
  }

  void _updateCardBalance(double amount) {
    if (selectedCard == null || !selectedCard!.isCredit) return;

    final currentBalance = selectedCard!.currentBalance ?? 0.0;
    final cardIndex = cardBox.values.toList().indexOf(selectedCard!);

    if (cardIndex != -1) {
      selectedCard!.currentBalance = selectedType == 'Expense'
          ? currentBalance + amount
          : currentBalance - amount;
      cardBox.putAt(cardIndex, selectedCard!);
    }
  }

  void _logTransaction(AddData transaction) {
    debugPrint(
      'Transaction saved: ${transaction.name}, '
      '${transaction.explain}, ${transaction.amount}, '
      '${transaction.IN}, ${transaction.datetime}',
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}