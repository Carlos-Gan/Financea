import 'package:financea/model/card/card_data.dart';
import 'package:financea/utils/app_colors.dart';
import 'package:financea/utils/app_str.dart';
import 'package:financea/views/cards/add_card_screen.dart';
import 'package:financea/views/cards/card_detail_screen.dart';
import 'package:financea/views/cards/card_puchases_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CardsView extends StatefulWidget {
  const CardsView({super.key});

  @override
  State<CardsView> createState() => _CardsViewState();
}

class _CardsViewState extends State<CardsView> {
  Box<CardData>? cardBox;

  @override
  void initState() {
    super.initState();
    _initHiveBox(); // Inicializa la caja Hive de forma asíncrona
  }

  Future<void> _initHiveBox() async {
    await Hive.openBox<CardData>('cardData');
    setState(() {
      cardBox = Hive.box<CardData>('cardData');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (cardBox == null || !Hive.isBoxOpen('cardData')) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStr.get('paymentMethods'),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor(context),
      ),
      body: Column(
        children: [
          // Botón para agregar tarjeta
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddCardScreen()),
                );
                setState(() {}); // Refresca luego de volver
              },
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '+ ${AppStr.get('addCardTitle')}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // Lista de tarjetas
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: cardBox!.listenable(),
              builder: (context, Box<CardData> box, _) {
                if (box.isEmpty) {
                  return Center(child: Text(AppStr.get('nocards')));
                }

                return ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final card = box.getAt(index);

                    if (card == null) return const SizedBox();

                    // Verifica si es una tarjeta de crédito
                    bool isCreditCard = card.isCredit;
                    double creditAvailable = 0.0;
                    double progress = 0.0;

                    if (isCreditCard &&
                        card.limit != null &&
                        card.currentBalance != null &&
                        card.limit! > 0) {
                      creditAvailable = card.limit! - card.currentBalance!;
                      progress = creditAvailable / card.limit!;
                      if (progress < 0) progress = 0;
                      if (progress > 1) progress = 1;
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CardDetailScreen(card: card),
                                ),
                              );
                            },
                            child: ListTile(
                              leading: Icon(
                                isCreditCard
                                    ? FontAwesomeIcons.creditCard
                                    : FontAwesomeIcons.moneyBill,
                                color: AppColors.primaryColor(context),
                              ),
                              title: Text(card.cardName),
                              subtitle: Text(
                                '${card.bank} - ${card.cardNumber ?? AppStr.get('noNumber')}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(AppStr.get('areYouSure')),
                                        content: Text(
                                          AppStr.get('deleteCardMessage'),
                                        ),
                                        actions: [
                                          TextButton(
                                            child: Text(AppStr.get('cancel')),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text(
                                              AppStr.get('delete'),
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                            onPressed: () {
                                              cardBox!.deleteAt(index);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),

                          // Barra de progreso solo si es tarjeta de crédito
                          if (isCreditCard)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    progress > 1
                                        ? '¡Tarjeta sobregirada! Uso: ${(progress * 100).toStringAsFixed(0)}%'
                                        : '${AppStr.get('creditAvailable')}: \$${creditAvailable.toStringAsFixed(2)} (${(progress * 100).toStringAsFixed(0)}%)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          progress > 1
                                              ? Colors.red
                                              : Theme.of(
                                                context,
                                              ).colorScheme.onPrimary,
                                    ),
                                  ),
                                  LinearProgressIndicator(
                                    value: progress > 1 ? 1 : progress,
                                    color:
                                        progress > 1
                                            ? Colors.red
                                            : AppColors.primaryColor(context),
                                    backgroundColor: Colors.grey[300],
                                  ),
                                ],
                              ),
                            ),
                          //Botones debajo de la tarjeta
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) =>
                                                AddCardScreen(editCard: card),
                                      ),
                                    );
                                    setState(
                                      () {},
                                    ); // Refrescar la vista después de editar
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  label: Text(
                                    AppStr.get('editar'),
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor(
                                      context,
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Aquí deberías navegar a una pantalla que liste las compras con esta tarjeta
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) =>
                                                CardPurchasesScreen(card: card),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.receipt_long,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  label: Text(
                                    AppStr.get('PurchasesButton'),
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
