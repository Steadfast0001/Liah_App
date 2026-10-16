import 'package:intl/intl.dart';

abstract final class AppDateFormat {
  static final _date = DateFormat('dd MMM yyyy');

  static String formatDate(DateTime dateTime) {
    return _date.format(dateTime.toLocal());
  }

  static String shortDate(DateTime dateTime) => formatDate(dateTime);
}
