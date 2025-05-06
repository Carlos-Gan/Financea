import 'package:financea/model/datas/add_data.dart';
import 'package:hive/hive.dart';

/// Calcula el saldo neto (ingresos - gastos)
double calculateTotal() {
  final box = Hive.box<AddData>('data');
  return box.values.fold<double>(0, (sum, record) {
    final amt = double.tryParse(record.amount) ?? 0;
    return sum + (record.IN == 'Income' ? amt : -amt);
  });
}

/// Calcula la suma de todos los ingresos
double calculateTotalIncome() {
  final box = Hive.box<AddData>('data');
  return box.values.fold<double>(0, (sum, record) {
    final amt = double.tryParse(record.amount) ?? 0;
    return sum + (record.IN == 'Income' ? amt : 0);
  });
}

/// Calcula la suma de todos los gastos
double calculateTotalExpense() {
  final box = Hive.box<AddData>('data');
  return box.values.fold<double>(0, (sum, record) {
    final amt = double.tryParse(record.amount) ?? 0;
    return sum + (record.IN == 'Expense' ? amt : 0);
  });
}

/// Devuelve los registros del día actual
List<AddData> today() {
  final box = Hive.box<AddData>('data');
  final now = DateTime.now();
  return box.values.where((record) {
    final dt = record.datetime.toLocal();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }).toList();
}

/// Devuelve los registros de la semana actual (lunes a domingo)
List<AddData> week() {
  final box = Hive.box<AddData>('data');
  final now = DateTime.now();
  final startOfWeek = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - DateTime.monday));
  final endOfWeek = startOfWeek.add(Duration(days: 7));
  return box.values.where((record) {
    final dt = record.datetime.toLocal();
    return !dt.isBefore(startOfWeek) && dt.isBefore(endOfWeek);
  }).toList();
}

/// Devuelve los registros del mes actual
List<AddData> month() {
  final box = Hive.box<AddData>('data');
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final startOfNextMonth = now.month < 12
      ? DateTime(now.year, now.month + 1, 1)
      : DateTime(now.year + 1, 1, 1);
  return box.values.where((record) {
    final dt = record.datetime.toLocal();
    return !dt.isBefore(startOfMonth) && dt.isBefore(startOfNextMonth);
  }).toList();
}

/// Devuelve los registros del año actual
List<AddData> year() {
  final box = Hive.box<AddData>('data');
  final now = DateTime.now();
  final startOfYear = DateTime(now.year, 1, 1);
  final startOfNextYear = DateTime(now.year + 1, 1, 1);
  return box.values.where((record) {
    final dt = record.datetime.toLocal();
    return !dt.isBefore(startOfYear) && dt.isBefore(startOfNextYear);
  }).toList();
}

/// Genera suma acumulada de la lista de registros dados
/// Retorna 0 si la lista está vacía
int totalChart(List<AddData> history) {
  if (history.isEmpty) return 0;
  return history
      .map((r) => (r.IN == 'Income' ? 1 : -1) * (int.tryParse(r.amount) ?? 0))
      .reduce((a, b) => a + b);
}

/// Agrupa y suma transacciones por hora o día, retornando lista de totales por grupo
List<double> timeGroups(List<AddData> history, {bool byHour = false}) {
  if (history.isEmpty) return [];
  final Map<int, double> groupMap = {};
  for (var tx in history) {
    final dt = tx.datetime.toLocal();
    final key = byHour ? dt.hour : dt.day;
    groupMap[key] = (groupMap[key] ?? 0) + (double.tryParse(tx.amount) ?? 0) * (tx.IN == 'Income' ? 1 : -1);
  }
  // Ordena por clave y retorna solo valores
  final sortedKeys = groupMap.keys.toList()..sort();
  return sortedKeys.map((k) => groupMap[k]!).toList();
}
