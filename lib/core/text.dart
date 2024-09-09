import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  const TextWidget(
      {super.key,
      required this.text,
      this.fontSize = 14,
      this.color = Colors.black,
      this.fontWeight = FontWeight.w500,
      this.textAlign,
      this.lineHeight,
      this.textDecoration,
      this.maxLine,
      this.fontFamily,
      this.textOverflow});
  final String text;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final double? lineHeight;
  final TextDecoration? textDecoration;
  final String? fontFamily;
  final TextOverflow? textOverflow;
  final int? maxLine;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLine,
      overflow: textOverflow,
      textAlign: textAlign,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontSize: fontSize,
            fontWeight: fontWeight,
            overflow: textOverflow,
            color: color,
            decoration: textDecoration,
            height: lineHeight,
            fontFamily: fontFamily,
          ),
    );
  }
}
