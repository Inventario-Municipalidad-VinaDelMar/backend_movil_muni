import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  // Definir el formato deseado: día, mes completo y año
  final DateFormat formatter = DateFormat('d \'de\' MMMM \'de\' y', 'es_ES');

  // Formatear la fecha de acuerdo al formato definido
  return formatter.format(date);
}
