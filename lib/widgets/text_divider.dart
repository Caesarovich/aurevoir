import 'package:flutter/material.dart';

class TextDivider extends StatelessWidget {
  final String text;
  final double thickness;
  final Color? color;

  const TextDivider({
    super.key,
    required this.text,
    this.thickness = 1.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Divider(
            thickness: thickness,
            color: color ?? Theme.of(context).dividerColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            text,
            style: TextStyle(color: color),
          ),
        ),
        Expanded(
          child: Divider(
            thickness: thickness,
            color: color,
          ),
        ),
      ],
    );
  }
}
