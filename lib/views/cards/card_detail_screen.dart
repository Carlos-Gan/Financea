import 'package:flutter/material.dart';
import 'package:financea/model/card/card_data.dart';
import 'package:financea/utils/app_colors.dart';
import 'package:intl/intl.dart';

class CardDetailScreen extends StatefulWidget {
  final CardData card;

  const CardDetailScreen({super.key, required this.card});

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  final moneyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  final _interestController = TextEditingController(text: '25');
  double? calculatedInterest;
  int selectedMonths = 1;

  void _calculateInterest() {
    if (widget.card.isCredit &&
        widget.card.currentBalance != null &&
        widget.card.currentBalance! > 0) {
      final interestRate = double.tryParse(_interestController.text) ?? 25.0;
      final monthlyRate = interestRate / 100 / 12;
      final interest =
          widget.card.currentBalance! * monthlyRate * selectedMonths;

      setState(() {
        calculatedInterest = interest;
      });

      _showInterestDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay saldo pendiente para calcular intereses.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showInterestDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cálculo de Intereses'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Si no pagas tu saldo actual de ${moneyFormat.format(widget.card.currentBalance)} en $selectedMonths ${selectedMonths == 1 ? 'mes' : 'meses'}:',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Intereses generados:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      Text(
                        moneyFormat.format(calculatedInterest),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total a pagar:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      Text(
                        moneyFormat.format(
                          (widget.card.currentBalance ?? 0) +
                              (calculatedInterest ?? 0),
                        ),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nota: Este cálculo es estimado y puede variar según las políticas específicas de tu banco.',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Tarjeta'),
        backgroundColor: AppColors.primaryColor(context),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Visual Representation
            Container(
              margin: const EdgeInsets.all(16),
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      widget.card.isCredit
                          ? [Colors.deepPurple, Colors.purple.shade900]
                          : [Colors.blue.shade700, Colors.blue.shade900],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.card.bank!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        widget.card.isCredit ? 'CRÉDITO' : 'DÉBITO',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    widget.card.cardNumber != null &&
                            widget.card.cardNumber!.isNotEmpty
                        ? _formatCardNumber(widget.card.cardNumber!)
                        : 'XXXX XXXX XXXX XXXX',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.card.cardName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Details Section
            Container(
              width: screenSize.width,
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DETALLES DE LA TARJETA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const Divider(thickness: 1),
                      _buildDetailRow('Nombre:', widget.card.cardName),
                      _buildDetailRow('Banco:', widget.card.bank!),
                      _buildDetailRow(
                        'Número:',
                        widget.card.cardNumber != null &&
                                widget.card.cardNumber!.isNotEmpty
                            ? _formatCardNumber(widget.card.cardNumber!)
                            : 'N/A',
                      ),
                      _buildDetailRow(
                        'Tipo:',
                        widget.card.isCredit
                            ? 'Tarjeta de Crédito'
                            : 'Tarjeta de Débito',
                      ),

                      if (widget.card.isCredit &&
                          widget.card.limit != null) ...[
                        _buildDetailRow(
                          'Límite de Crédito:',
                          moneyFormat.format(widget.card.limit),
                        ),
                        _buildDetailRow(
                          'Balance Actual:',
                          moneyFormat.format(widget.card.currentBalance ?? 0),
                        ),

                        // Fechas
                        if (widget.card.limitDate != null)
                          _buildDetailRow(
                            'Fecha límite de pago:',
                            '${widget.card.limitDate!.day}/${widget.card.limitDate!.month}',
                          ),
                        if (widget.card.corteFecha != null)
                          _buildDetailRow(
                            'Fecha de corte:',
                            '${widget.card.corteFecha!.day}/${widget.card.corteFecha!.month}',
                          ),

                        // Información adicional sobre balance
                        const SizedBox(height: 16),
                        _buildProgressIndicator(
                          'Uso de Crédito',
                          (widget.card.currentBalance ?? 0) /
                              (widget.card.limit ?? 1),
                          context,
                        ),

                        // Calculadora de intereses
                        if (widget.card.currentBalance != null &&
                            widget.card.currentBalance! > 0) ...[
                          const SizedBox(height: 24),
                          Text(
                            'CALCULADORA DE INTERESES',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          const Divider(thickness: 1),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _interestController,
                                  decoration: const InputDecoration(
                                    labelText: 'Tasa de interés anual (%)',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              DropdownButton<int>(
                                value: selectedMonths,
                                items:
                                    [1, 2, 3, 6, 12].map((int months) {
                                      return DropdownMenuItem<int>(
                                        value: months,
                                        child: Text(
                                          '$months ${months == 1 ? 'mes' : 'meses'}',
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (int? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      selectedMonths = newValue;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _calculateInterest,
                              icon: const Icon(Icons.calculate),
                              label: const Text(
                                'Calcular intereses si no pago',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(
    String label,
    double value,
    BuildContext context,
  ) {
    Color progressColor;
    if (value < 0.5) {
      progressColor = Colors.green;
    } else if (value < 0.75) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                color: progressColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value >= 0.9
                  ? '¡Cerca del límite!'
                  : value >= 0.75
                  ? 'Uso elevado'
                  : 'Buen manejo',
              style: TextStyle(
                color: progressColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatCardNumber(String number) {
    if (number.length < 4) return number;

    // Solo mostrar los últimos 4 dígitos
    String masked = 'XXXX XXXX XXXX ';
    String lastFour =
        number.length >= 4 ? number.substring(number.length - 4) : number;
    return masked + lastFour;
  }
}
