import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:financea/model/card/card_data.dart';
import 'package:financea/utils/app_colors.dart';
import 'package:financea/utils/app_str.dart';

enum PaymentType { card, cash }

class AddCardScreen extends StatefulWidget {
  final CardData? editCard;
  const AddCardScreen({super.key, this.editCard});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final bankController = TextEditingController();
  final limitController = TextEditingController();

  bool isCredit = false;
  PaymentType selectedPayment = PaymentType.card;

  DateTime? limitDate;
  DateTime? corteFecha;

  @override
  void initState() {
    super.initState();
    if (widget.editCard != null) {
      nameController.text = widget.editCard!.cardName;
      numberController.text = widget.editCard!.cardNumber ?? '';
      bankController.text = widget.editCard!.bank ?? '';
      isCredit = widget.editCard!.isCredit;
      limitDate = widget.editCard!.limitDate;
      corteFecha = widget.editCard!.corteFecha;

      if (isCredit) {
        limitController.text = widget.editCard!.limit?.toString() ?? '';
      }
    }
  }

  List<String> months = [
    AppStr.get('enero'),
    AppStr.get('febrero'),
    AppStr.get('marzo'),
    AppStr.get('abril'),
    AppStr.get('mayo'),
    AppStr.get('junio'),
    AppStr.get('julio'),
    AppStr.get('agosto'),
    AppStr.get('septiembre'),
    AppStr.get('octubre'),
    AppStr.get('noviembre'),
    AppStr.get('diciembre'),
  ];

  List<int> days = List.generate(31, (index) => index + 1);

  // Variables separadas para cada fecha
  String? selectedMonthCorte;
  String? selectedMonthLimite;
  int? selectedDayCorte;
  int? selectedDayLimite;

  // Función para mostrar un diálogo y seleccionar la fecha de corte
  Future<void> _selectCorteDate(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return dialogoFechas(context);
      },
    );
  }

  AlertDialog dialogoFechas(BuildContext context) {
    return AlertDialog(
      title: Text(AppStr.get('chooseDateCut')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedMonthCorte,
                    hint: Text(AppStr.get('chooseMonth')),
                    onChanged: (String? newMonth) {
                      setDialogState(() {
                        selectedMonthCorte = newMonth;
                      });
                      setState(() {
                        selectedMonthCorte = newMonth;
                      });
                    },
                    items:
                        months.map((String month) {
                          return DropdownMenuItem<String>(
                            value: month,
                            child: Text(month),
                          );
                        }).toList(),
                  ),
                  DropdownButton<int>(
                    value: selectedDayCorte,
                    hint: Text(AppStr.get('chooseDay')),
                    onChanged: (int? newDay) {
                      setDialogState(() {
                        selectedDayCorte = newDay;
                      });
                      setState(() {
                        selectedDayCorte = newDay;
                      });
                    },
                    items:
                        days.map((int day) {
                          return DropdownMenuItem<int>(
                            value: day,
                            child: Text(day.toString()),
                          );
                        }).toList(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            if (selectedMonthCorte != null && selectedDayCorte != null) {
              final monthIndex = months.indexOf(selectedMonthCorte!) + 1;
              final selectedDate = DateTime(
                DateTime.now().year,
                monthIndex,
                selectedDayCorte!,
              );

              // Actualizamos la interfaz
              setState(() {
                corteFecha = selectedDate;
              });

              Navigator.pop(context);
            }
          },
          child: Text(AppStr.get('select')),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppStr.get('cancel')),
        ),
      ],
    );
  }

  // Función para mostrar un diálogo y seleccionar la fecha límite
  Future<void> _selectLimiteDate(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppStr.get('chooseDateLimit')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatefulBuilder(
                builder: (context, setDialogState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButton<String>(
                        value: selectedMonthLimite,
                        hint: Text(AppStr.get('chooseMonth')),
                        onChanged: (String? newMonth) {
                          setDialogState(() {
                            selectedMonthLimite = newMonth;
                          });
                          setState(() {
                            selectedMonthLimite = newMonth;
                          });
                        },
                        items:
                            months.map((String month) {
                              return DropdownMenuItem<String>(
                                value: month,
                                child: Text(month),
                              );
                            }).toList(),
                      ),
                      DropdownButton<int>(
                        value: selectedDayLimite,
                        hint: Text(AppStr.get('chooseDay')),
                        onChanged: (int? newDay) {
                          setDialogState(() {
                            selectedDayLimite = newDay;
                          });
                          setState(() {
                            selectedDayLimite = newDay;
                          });
                        },
                        items:
                            days.map((int day) {
                              return DropdownMenuItem<int>(
                                value: day,
                                child: Text(day.toString()),
                              );
                            }).toList(),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (selectedMonthLimite != null && selectedDayLimite != null) {
                  final monthIndex = months.indexOf(selectedMonthLimite!) + 1;
                  final selectedDate = DateTime(
                    DateTime.now().year,
                    monthIndex,
                    selectedDayLimite!,
                  );

                  // Actualizamos la interfaz
                  setState(() {
                    limitDate = selectedDate;
                  });

                  Navigator.pop(context);
                }
              },
              child: Text(AppStr.get('select')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStr.get('cancel')),
            ),
          ],
        );
      },
    );
  }

  void _onSubmit() {
    if (selectedPayment == PaymentType.card &&
        !_formKey.currentState!.validate()) {
      return;
    }

    final card = CardData(
      selectedPayment == PaymentType.cash
          ? AppStr.get('cash')
          : nameController.text,
      selectedPayment == PaymentType.cash ? null : numberController.text,
      selectedPayment == PaymentType.cash ? 'N/A' : bankController.text,
      selectedPayment == PaymentType.cash ? false : isCredit,
      selectedPayment == PaymentType.cash || !isCredit
          ? null
          : double.tryParse(limitController.text),
      selectedPayment == PaymentType.cash || !isCredit
          ? 0.0
          : widget.editCard?.currentBalance ?? 0.0,
      selectedPayment == PaymentType.cash || !isCredit ? null : limitDate,
      selectedPayment == PaymentType.cash || !isCredit ? null : corteFecha,
    );

    final box = Hive.box<CardData>('cardData');
    if (widget.editCard != null) {
      final index = box.values.toList().indexOf(widget.editCard!);
      box.putAt(index, card);
    } else {
      box.add(card);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryColorDark(context),
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          centerTitle: true,
          title: Text(
            AppStr.get('addCardTitle'),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.primaryColorDark(context),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 10),
                Text(
                  AppStr.get('paymentMethod'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primaryColorDark(context),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: metodoPago(),
                ),

                const SizedBox(height: 20),
                if (selectedPayment == PaymentType.card) ...[
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      filled: true,
                      labelText: AppStr.get('nameCard'),
                      prefixIcon: Icon(Icons.credit_card),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator:
                        (value) =>
                            value!.isEmpty ? AppStr.get('required') : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: numberController,
                    decoration: InputDecoration(
                      filled: true,
                      labelText: AppStr.get('numberCard'),
                      prefixIcon: Icon(Icons.numbers),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: bankController,
                    decoration: InputDecoration(
                      filled: true,
                      labelText: AppStr.get('bank'),
                      prefixIcon: Icon(Icons.account_balance),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: Text(AppStr.get('isCredit')),
                    value: isCredit,
                    activeColor: AppColors.primaryColorDark(context),
                    onChanged: (val) => setState(() => isCredit = val),
                  ),
                  if (isCredit) ...[
                    TextFormField(
                      controller: limitController,
                      decoration: InputDecoration(
                        filled: true,
                        labelText: AppStr.get('limit'),
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                      child: ListTile(
                        title: Text(AppStr.get('dateLimit')),
                        subtitle: Text(
                          limitDate != null
                              ? '${limitDate!.day}/${limitDate!.month}'
                              : AppStr.get('chooseDate'),
                        ),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () => _selectLimiteDate(context),
                      ),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                      child: ListTile(
                        title: Text(AppStr.get('dateCut')),
                        subtitle: Text(
                          corteFecha != null
                              ? '${corteFecha!.day}/${corteFecha!.month}'
                              : AppStr.get('chooseDate'),
                        ),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () => _selectCorteDate(context),
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _onSubmit,
                  icon: Icon(
                    Icons.save,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  label: Text(
                    AppStr.get('addCard'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColorDark(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column metodoPago() {
    return Column(
      children: [
        RadioListTile<PaymentType>(
          title: Text(AppStr.get('card')),
          value: PaymentType.card,
          groupValue: selectedPayment,
          onChanged: (value) => setState(() => selectedPayment = value!),
        ),
        RadioListTile<PaymentType>(
          title: Text(AppStr.get('cash')),
          value: PaymentType.cash,
          groupValue: selectedPayment,
          onChanged: (value) => setState(() => selectedPayment = value!),
        ),
      ],
    );
  }
}
