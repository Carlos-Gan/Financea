import 'package:flutter/material.dart';
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
    AppStr.enero,
    AppStr.febrero,
    AppStr.marzo,
    AppStr.abril,
    AppStr.mayo,
    AppStr.junio,
    AppStr.julio,
    AppStr.agosto,
    AppStr.septiembre,
    AppStr.octubre,
    AppStr.noviembre,
    AppStr.diciembre,
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
      title: const Text(AppStr.chooseDateCut),
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
                    hint: const Text(AppStr.chooseMonth),
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
                    hint: const Text(AppStr.chooseDay),
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
          child: const Text(AppStr.select),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStr.cancel),
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
          title: const Text(AppStr.chooseDateLimit),
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
                        hint: const Text(AppStr.chooseMonth),
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
                        hint: const Text(AppStr.chooseDay),
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
              child: const Text(AppStr.select),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppStr.cancel),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(AppStr.addCardTitle),
        backgroundColor: AppColors.secondaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Tipo de método de pago
              const Text(
                AppStr.paymentMethod,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              metodoPago(),

              const SizedBox(height: 12),
              // Campos si se selecciona Tarjeta
              if (selectedPayment == PaymentType.card) ...[
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: AppStr.nameCard),
                  validator: (value) => value!.isEmpty ? AppStr.required : null,
                ),
                TextFormField(
                  controller: numberController,
                  decoration: const InputDecoration(
                    labelText: AppStr.numberCard,
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: bankController,
                  decoration: const InputDecoration(labelText: AppStr.bank),
                ),
                SwitchListTile(
                  title: const Text(AppStr.isCredit),
                  value: isCredit,
                  onChanged: (val) => setState(() => isCredit = val),
                ),
                if (isCredit) ...[
                  //Limite de tarjeta de credito
                  TextFormField(
                    controller: limitController,
                    decoration: const InputDecoration(labelText: AppStr.limit),
                    keyboardType: TextInputType.number,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(AppStr.dateLimit),
                      Row(
                        children: [
                          Text(
                            limitDate != null
                                ? '${limitDate!.day}/${limitDate!.month}'
                                : selectedDayLimite != null &&
                                    selectedMonthLimite != null
                                ? '$selectedDayLimite/${months.indexOf(selectedMonthLimite!) + 1}'
                                : AppStr.chooseDate,
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectLimiteDate(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(AppStr.dateCut),
                      Row(
                        children: [
                          Text(
                            corteFecha != null
                                ? '${corteFecha!.day}/${corteFecha!.month}'
                                : selectedDayCorte != null &&
                                    selectedMonthCorte != null
                                ? '$selectedDayCorte/${months.indexOf(selectedMonthCorte!) + 1}'
                                : AppStr.chooseDate,
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectCorteDate(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (selectedPayment == PaymentType.card &&
                      !_formKey.currentState!.validate()) {
                    return;
                  }

                  final card = CardData(
                    selectedPayment == PaymentType.cash
                        ? AppStr.cash
                        : nameController.text,
                    selectedPayment == PaymentType.cash
                        ? null
                        : numberController.text,
                    selectedPayment == PaymentType.cash
                        ? 'N/A'
                        : bankController.text,
                    selectedPayment == PaymentType.cash ? false : isCredit,
                    selectedPayment == PaymentType.cash || !isCredit
                        ? null
                        : double.tryParse(limitController.text),
                    selectedPayment == PaymentType.cash || !isCredit
                        ? 0.0
                        : widget.editCard?.currentBalance ?? 0.0,
                    selectedPayment == PaymentType.cash || !isCredit
                        ? null
                        : limitDate,
                    selectedPayment == PaymentType.cash || !isCredit
                        ? null
                        : corteFecha,
                  );

                  if (widget.editCard != null) {
                    final cardBox = Hive.box<CardData>('cardData');
                    final index = cardBox.values.toList().indexOf(
                      widget.editCard!,
                    ); // Encontramos el índice de la tarjeta que estamos editando
                    cardBox.putAt(
                      index,
                      card,
                    ); // Actualizamos la tarjeta existente
                  } else {
                    // Si no estamos editando, agregamos la tarjeta como nueva
                    Hive.box<CardData>('cardData').add(card);
                  }

                  Navigator.pop(context);
                },
                child: const Text(AppStr.addCard),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column metodoPago() {
    return Column(
      children: [
        RadioListTile<PaymentType>(
          title: const Text(AppStr.card),
          value: PaymentType.card,
          groupValue: selectedPayment,
          onChanged: (value) => setState(() => selectedPayment = value!),
        ),
        RadioListTile<PaymentType>(
          title: const Text(AppStr.cash),
          value: PaymentType.cash,
          groupValue: selectedPayment,
          onChanged: (value) => setState(() => selectedPayment = value!),
        ),
      ],
    );
  }
}
