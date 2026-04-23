
import 'package:intl/intl.dart';

String shortIso(DateTime value) => value.toIso8601String();

String friendlyDate(DateTime value) => DateFormat('dd MMM yyyy').format(value);

String friendlyDateTime(DateTime value) => DateFormat('dd MMM yyyy, HH:mm').format(value);
