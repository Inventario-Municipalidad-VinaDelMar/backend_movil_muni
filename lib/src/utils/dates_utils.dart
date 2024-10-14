import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  // Definir el formato deseado: día, mes completo y año
  final DateFormat formatter = DateFormat('d \'de\' MMMM \'de\' y', 'es_ES');

  // Formatear la fecha de acuerdo al formato definido
  return formatter.format(date);
}

// Función para obtener la fecha en formato "yyyy-mm-dd"
String getFormattedDate() {
  DateTime today = DateTime.now();

  // Si hoy es sábado (6) o domingo (7), restar días para obtener el viernes (5)
  if (today.weekday == DateTime.saturday) {
    today = today.subtract(Duration(days: 1)); // Restar 1 día (viernes)
  } else if (today.weekday == DateTime.sunday) {
    today = today.subtract(Duration(days: 2)); // Restar 2 días (viernes)
  }

  // Formato "yyyy-mm-dd"
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  return formatter.format(today);
}
