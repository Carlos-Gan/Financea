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
      title: Text(AppStr.get('getchooseDateCut')),
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
                    hint: Text(AppStr.get('getchooseMonth')),
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
                    hint: Text(AppStr.get('getchooseDay')),
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
          child:  Text(AppStr.get('getselect')),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:  Text(AppStr.get('getcancel')),
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
          title:  Text(AppStr.get('getchooseDateLimit')),
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
                        hint: Text(AppStr.get('getchooseMonth')),
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
                        hint:  Text(AppStr.get('getchooseDay')),
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
              child:  Text(AppStr.get('getselect')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:  Text(AppStr.get('getcancel')),
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
        title:  Text(AppStr.get('getaddCardTitle')),
        backgroundColor: AppColors.secondaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Tipo de método de pago
               Text(
                AppStr.get('getpaymentMethod'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              metodoPago(),

              const SizedBox(height: 12),
              // Campos si se selecciona Tarjeta
              if (selectedPayment == PaymentType.card) ...[
                TextFormField(
                  controller: nameController,
                  decoration:  InputDecoration(labelText: AppStr.get('getnameCard')),
                  validator: (value) => value!.isEmpty ? AppStr.get('getrequired') : null,
                ),
                TextFormField(
                  controller: numberController,
                  decoration:  InputDecoration(
                    labelText: AppStr.get('getnumberCard'),
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: bankController,
                  decoration:  InputDecoration(labelText: AppStr.get('getbank')),
                ),
                SwitchListTile(
                  title:  Text(AppStr.get('getisCredit')),
                  value: isCredit,
                  onChanged: (val) => setState(() => isCredit = val),
                ),
                if (isCredit) ...[
                  //Limite de tarjeta de credito
                  TextFormField(
                    controller: limitController,
                    decoration:  InputDecoration(labelText: AppStr.get('getlimit')),
                    keyboardType: TextInputType.number,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(AppStr.get('getdateLimit')),
                      Row(
                        children: [
                          Text(
                            limitDate != null
                                ? '${limitDate!.day}/${limitDate!.month}'
                                : selectedDayLimite != null &&
                                    selectedMonthLimite != null
                                ? '$selectedDayLimite/${months.indexOf(selectedMonthLimite!) + 1}'
                                : AppStr.get('getchooseDate'),
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
                      Text(AppStr.get('getdateCut')),
                      Row(
                        children: [
                          Text(
                            corteFecha != null
                                ? '${corteFecha!.day}/${corteFecha!.month}'
                                : selectedDayCorte != null &&
                                    selectedMonthCorte != null
                                ? '$selectedDayCorte/${months.indexOf(selectedMonthCorte!) + 1}'
                                : AppStr.get('getchooseDate'),
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
                        ? AppStr.get('getcash')
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
                child: Text(AppStr.get('getaddCard')),
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
          title:  Text(AppStr.get('getcard')),
          value: PaymentType.card,
          groupValue: selectedPayment,
          onChanged: (value) => setState(() => selectedPayment = value!),
        ),
        RadioListTile<PaymentType>(
          title:  Text(AppStr.get('getcash')),
          value: PaymentType.cash,
          groupValue: selectedPayment,
          onChanged: (value) => setState(() => selectedPayment = value!),
        ),
      ],
    );
  }
}
