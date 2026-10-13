import 'package:flutter/material.dart';

import '../formatting/xaf_format.dart';

class AmountText extends StatelessWidget {
  const AmountText(
    this.amountXaf, {
    super.key,
    this.style,
  });

  final int amountXaf;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      XafFormat.format(amountXaf),
      style: style ??
          const TextStyle(
            fontWeight: FontWeight.w700,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
    );
  }
}
