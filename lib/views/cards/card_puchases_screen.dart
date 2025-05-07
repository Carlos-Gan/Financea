import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:financea/model/datas/add_data.dart';
import 'package:financea/model/card/card_data.dart';
import 'package:financea/utils/app_colors.dart';
import 'package:financea/utils/app_str.dart';

class CardPurchasesScreen extends StatefulWidget {
  final CardData card;

  const CardPurchasesScreen({super.key, required this.card});

  @override
  State<CardPurchasesScreen> createState() => _CardPurchasesScreenState();
}

class _CardPurchasesScreenState extends State<CardPurchasesScreen> {
  String selectedFilter = 'Todas';

  @override
  Widget build(BuildContext context) {
    final Box<AddData> dataBox = Hive.box<AddData>('data');
    final List<AddData> allPurchases =
        dataBox.values.where((e) => e.pay == widget.card.cardName).toList();

    List<AddData> filteredPurchases;
    if (selectedFilter == 'Suscripciones') {
      filteredPurchases =
          allPurchases.where((e) => e.subscription == true).toList();
    } else if (selectedFilter == 'Meses') {
      final now = DateTime.now();

      final pagosActivos =
          allPurchases.where((item) {
            final fechaFin = item.datetime.add(Duration(days: 30 * item.meses));
            return item.meses > 0 && now.isBefore(fechaFin);
          }).toList();

      final pagosTerminados =
          allPurchases.where((item) {
            final fechaFin = item.datetime.add(Duration(days: 30 * item.meses));
            return item.meses > 0 && now.isAfter(fechaFin);
          }).toList();

      filteredPurchases = [...pagosActivos];
      if (pagosTerminados.isNotEmpty) {
        // marcador divisor
        filteredPurchases.add(
          AddData('DIVISOR', '', '', 'Info', DateTime.now(), '', false, 0),
        );
        filteredPurchases.addAll(pagosTerminados);
      }
    } else if (selectedFilter == 'Pagos/Ingresos') {
      // Filtrar solo los pagos o ingresos
      filteredPurchases =
          allPurchases
              .where((item) => item.IN == 'Income')
              .toList();
    } else {
      filteredPurchases = allPurchases;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Compras - ${widget.card.cardName}'),
        backgroundColor: AppColors.secondaryColor,
        elevation: 4,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Todas', label: Text('Todas')),
                ButtonSegment(
                  value: 'Suscripciones',
                  label: Text('Suscripciones'),
                ),
                ButtonSegment(value: 'Meses', label: Text('Pagos a meses')),
                ButtonSegment(
                  value: 'Pagos/Ingresos',
                  label: Text('Pagos/Ingresos'),
                ),
              ],
              selected: {selectedFilter},
              onSelectionChanged: (newSelection) {
                setState(() {
                  selectedFilter = newSelection.first;
                });
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  AppColors.secondaryColor.withOpacity(0.1),
                ),
              ),
            ),
          ),
          Expanded(
            child:
                filteredPurchases.isEmpty
                    ? Center(
                      child: Text(
                        AppStr.get('noTransactions'),
                        style: const TextStyle(fontSize: 16),
                      ),
                    )
                    : ListView.builder(
                      itemCount: filteredPurchases.length,
                      itemBuilder: (context, index) {
                        final item = filteredPurchases[index];

                        if (item.name == 'DIVISOR') {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Center(
                              child: Text(
                                'Pagos a meses terminados',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          );
                        }

                        final isMeses = item.meses > 0;
                        final amountDouble = double.tryParse(item.amount) ?? 0;
                        final pagoMensual =
                            isMeses ? amountDouble / item.meses : amountDouble;
                        final fechaFin = item.datetime.add(
                          Duration(days: 30 * item.meses),
                        );
                        final mesesRestantes =
                            isMeses
                                ? (fechaFin.difference(DateTime.now()).inDays ~/
                                    30)
                                : 0;
                        final pagoTerminado = isMeses && mesesRestantes <= 0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              title: Text(
                                item.explain,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(item.datetime),
                                  ),
                                  if (isMeses) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      pagoTerminado
                                          ? 'Pago terminado'
                                          : 'Pago mensual: \$${pagoMensual.toStringAsFixed(2)}',
                                    ),
                                    Text(
                                      pagoTerminado
                                          ? 'Pago total \$${(pagoMensual * item.meses).toStringAsFixed(2)}'
                                          : 'Meses restantes: $mesesRestantes',
                                    ),
                                  ],
                                  if (selectedFilter == 'Pagos/Ingresos') ...[
                                    Text(
                                      'Tipo: ${item.IN == "Expense" ? "Ingreso" : "Pago"}',
                                    ),
                                    Text('Monto: \$${item.amount}'),
                                  ],
                                ],
                              ),
                              trailing:
                                  pagoTerminado
                                      ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                      : Text(
                                        '\$${item.amount}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              item.IN == 'Expense'
                                                  ? Colors.red
                                                  : Colors.green,
                                        ),
                                      ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
