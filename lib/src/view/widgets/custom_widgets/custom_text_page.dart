import 'package:flutter/material.dart';

class CustomTextPage extends StatelessWidget {
  const CustomTextPage({super.key, required this.centerText, this.style});
  final String centerText;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        centerText,
        style: style,
      ),
    );
  }
}
