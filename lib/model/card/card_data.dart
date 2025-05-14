import 'package:hive/hive.dart';

part 'card_data.g.dart';
@HiveType(typeId: 2)
class CardData {
  @HiveField(0)
  final String cardName;
  @HiveField(1)
  final String? cardNumber;
  @HiveField(2)
  final String? bank;
  @HiveField(3)
  final bool isCredit;
  @HiveField(4)
  double? limit; 
  @HiveField(5)
  double? currentBalance;
  @HiveField(6)
  DateTime? limitDate;
  @HiveField(7)
  DateTime? corteFecha;



  CardData(this.cardName, this.cardNumber, this.bank, this.isCredit, this.limit, this.currentBalance, this.limitDate, this.corteFecha);
}