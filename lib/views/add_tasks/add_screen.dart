import 'dart:developer';
import 'package:financea/model/card/card_data.dart';
import 'package:financea/model/datas/add_data.dart';
import 'package:financea/utils/app_colors.dart';
import 'package:financea/utils/app_str.dart';
import 'package:financea/views/add_tasks/widgets/background_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  final List<String> _item = ['Food', 'Transfer', 'Transport', 'Education'];
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
          categoryName(),
          SizedBox(height: 30),
          explain(),
          SizedBox(height: 30),
          amount(),
          SizedBox(height: 30),
          how(),
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
                    Text(AppStr.isSub),
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
                const Text(
                  AppStr.choosePaymentMethod,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButton<CardData>(
                  isExpanded: true,
                  value: selectedCard,
                  hint: const Text(AppStr.paymentMethod),
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
          save(),
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
                const Text(
                  "MSI:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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

  GestureDetector save() {
    return GestureDetector(
      onTap: () {
        if (selectedItem == null ||
            selectedItem2 == null ||
            amount_C.text.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text(AppStr.fillAllFields)));
          return;
        }

        double? amount = double.tryParse(amount_C.text);
        if (amount == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text(AppStr.invalidAmount)));
          return;
        }

        var add = AddData(
          selectedItem!,
          expalin_C.text,
          amount_C.text,
          selectedItem2!,
          date,
          selectedCard?.cardName ?? AppStr.noPaymentMethod,
          isSub,
          selectedItem2 == 'Expense' && selectedCard?.isCredit == true ? selectedMeses : 1,
        );
        box.add(add);
        //Si es gasto, restar de la tarjeta y sino suma a la tarjeta
        if (selectedCard != null && selectedCard!.isCredit) {
          double current = selectedCard!.currentBalance ?? 0.0;
          double amount = double.tryParse(amount_C.text) ?? 0.0;

          if (selectedItem2 == 'Expense') {
            selectedCard!.currentBalance = current + amount;
          } else if (selectedItem2 == 'Income') {
            selectedCard!.currentBalance = current - amount;
          }

          final cardIndex = cardBox.values.toList().indexOf(selectedCard!);
          if (cardIndex != -1) {
            cardBox.putAt(cardIndex, selectedCard!);
          }
        }
        log(
          '${add.name}, ${add.explain}, ${add.amount}, ${add.IN}, ${add.datetime}',
        );
        Navigator.of(context).pop();
      },
      child: Container(
        alignment: Alignment.center,
        height: 50,
        width: MediaQuery.of(context).size.width - 200,
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          AppStr.save,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
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
            date = newDate!;
          });
        },
        child: Text(
          '${AppStr.date} : ${date.day}/${date.month}/${date.year}',
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
            labelText: AppStr.explain,
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

  Padding amount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Container(
        width: MediaQuery.of(context).size.width - 180,
        child: TextField(
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          focusNode: am,
          controller: amount_C,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            labelText: AppStr.amount,
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

  Padding categoryName() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        width: MediaQuery.of(context).size.width - 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: Colors.grey[300]!),
        ),
        child: DropdownButton<String>(
          value: selectedItem,
          onChanged: (value) {
            setState(() {
              selectedItem = value!;
            });
          },
          items:
              _item
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            //Agregar imagenes de e
                            child: Image.asset('img/$e.png'),
                          ),
                          SizedBox(width: 10),
                          Text(
                            e,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
          selectedItemBuilder:
              (context) =>
                  _item
                      .map(
                        (e) => Row(
                          children: [
                            SizedBox(
                              width: 42,
                              child: Image.asset('img/$e.png'),
                            ),
                            SizedBox(width: 10),
                            Text(
                              e,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
          hint: Text(
            AppStr.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          dropdownColor: Colors.white,
          isExpanded: true,
          underline: Container(),
        ),
      ),
    );
  }

  Padding how() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        width: MediaQuery.of(context).size.width - 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: Colors.grey[300]!),
        ),
        child: DropdownButton<String>(
          value: selectedItem2,
          onChanged: (value) {
            setState(() {
              selectedItem2 = value!;
            });
          },
          items:
              _item1
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            //Agregar imagenes de e
                            child: Image.asset('img/$e.png'),
                          ),
                          SizedBox(width: 10),
                          Text(
                            e,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
          selectedItemBuilder:
              (context) =>
                  _item1
                      .map(
                        (e) => Row(
                          children: [
                            SizedBox(
                              width: 42,
                              child: Image.asset('img/$e.png'),
                            ),
                            SizedBox(width: 10),
                            Text(
                              e,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
          hint: Text(
            AppStr.how,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          dropdownColor: Colors.white,
          isExpanded: true,
          underline: Container(),
        ),
      ),
    );
  }
}
