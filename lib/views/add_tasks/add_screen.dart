import 'package:financea/model/card/card_data.dart';
import 'package:financea/model/datas/add_data.dart';
import 'package:financea/utils/app_colors.dart';
import 'package:financea/utils/app_str.dart';
import 'package:financea/views/add_tasks/widgets/amount_field.dart';
import 'package:financea/views/add_tasks/widgets/background_container.dart';
import 'package:financea/views/add_tasks/widgets/category_dropdown.dart';
import 'package:financea/views/add_tasks/widgets/save_button.dart';
import 'package:financea/views/add_tasks/widgets/type_selector.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final box = Hive.box<AddData>('data');
  DateTime date = DateTime.now();
  String? selectedItem;
  String? selectedItem2;
  final TextEditingController expalin_C = TextEditingController();
  final TextEditingController amount_C = TextEditingController();

  FocusNode ex = FocusNode();
  FocusNode am = FocusNode();

  bool isSub = false;
  final List<String> _item1 = ['Income', 'Expense'];
  List<int> mesesOpciones = [1, 3, 6, 9, 12, 18, 24];
  int selectedMeses = 1;

  final cardBox = Hive.box<CardData>('cardData');
  CardData? selectedCard;
  @override
  void initState() {
    super.initState();
    ex.addListener(() {
      setState(() {});
    });
    am.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    ex.dispose();
    am.dispose();
    expalin_C.dispose();
    amount_C.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            BackgroundContainer(),
            Positioned(top: 120, child: main_container()),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Container main_container() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      height: 750,
      width: MediaQuery.of(context).size.width - 100,
      child: Column(
        children: [
          SizedBox(height: 30),
          CategoryDropdown(
            selectedCategory: selectedItem,
            hintText: AppStr.get('category'),
            onChanged: (value) {
              if (value == 'add_new') {
                setState(() {
                  selectedItem = null;
                });
              } else {
                setState(() {
                  selectedItem = value;
                });
              }
            },
          ),
          SizedBox(height: 30),
          explain(),
          SizedBox(height: 30),
          AmountField(
            controller: amount_C,
            focusNode: am,
            labelText: AppStr.get('amount'),
            focusedBorderColor: AppColors.secondaryColor,
          ),
          SizedBox(height: 30),
          TypeSelector(
            options: _item1,
            initialValue: selectedItem2,
            hintText: AppStr.get('how'),
            onChanged: (String value) {
              setState(() {
                selectedItem2 = value;
              });
            },
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 30),
          datePicker(),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(AppStr.get('isSub')),
                    Checkbox(
                      value: isSub,
                      onChanged: (bool? value) {
                        setState(() {
                          isSub = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  AppStr.get('choosePaymentMethod'),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButton<CardData>(
                  isExpanded: true,
                  value: selectedCard,
                  hint: Text(AppStr.get('paymentMethod')),
                  items:
                      cardBox.values.map((card) {
                        return DropdownMenuItem<CardData>(
                          value: card,
                          child: Text(card.cardName),
                        );
                      }).toList(),
                  onChanged: (CardData? value) {
                    setState(() {
                      selectedCard = value;
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          //Compras a Meses
          if (selectedItem2 == 'Expense' && selectedCard?.isCredit == true)
            meses(),
          Spacer(),
          SaveButton(
            context: context,
            selectedCategory: selectedItem,
            selectedType: selectedItem2,
            amountController: amount_C,
            explanationController: expalin_C,
            selectedDate: date,
            selectedCard: selectedCard,
            isSubscription: isSub,
            selectedMonths: selectedMeses,
            onSuccess: () => Navigator.of(context).pop(),
            dataBox: box,
            cardBox: cardBox,
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Padding meses() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          const Text("MSI:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          DropdownButton<int>(
            value: selectedMeses,
            items:
                mesesOpciones.map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text("$value MSI"),
                  );
                }).toList(),
            onChanged: (int? newValue) {
              setState(() {
                selectedMeses = newValue ?? 1;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget datePicker() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 2, color: Colors.grey[300]!),
      ),
      width: MediaQuery.of(context).size.width - 180,
      child: TextButton(
        onPressed: () async {
          DateTime? newDate = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2010),
            lastDate: DateTime(2100),
          );
          if (newDate == null) return;
          setState(() {
            date = newDate;
          });
        },
        child: Text(
          '${AppStr.get('date')} : ${date.day}/${date.month}/${date.year}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Padding explain() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Container(
        width: MediaQuery.of(context).size.width - 180,
        child: TextField(
          focusNode: ex,
          controller: expalin_C,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            labelText: AppStr.get('explain'),
            labelStyle: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppColors.secondaryColorDark,
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
