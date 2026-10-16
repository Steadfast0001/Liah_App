import 'package:intl/intl.dart';

abstract final class XafFormat {
  static final _fmt = NumberFormat('#,##0');

  static String format(int amountXaf) => '${_fmt.format(amountXaf)} XAF';
}
