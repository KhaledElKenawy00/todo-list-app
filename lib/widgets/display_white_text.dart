import 'package:flutter/material.dart';
import 'package:todo_list_app/utils/extensions.dart';

class DisplayWhiteText extends StatelessWidget {
  const DisplayWhiteText({
    super.key,
    required this.text,
    this.size,
    this.fontWeight,
  });
  final String text;
  final double? size;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.textTheme.headlineSmall?.copyWith(
        color: Colors.black,
        fontSize: size,
        fontWeight: fontWeight ?? FontWeight.bold,
      ),
    );
  }
}
