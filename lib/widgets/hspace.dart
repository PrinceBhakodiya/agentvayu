import 'package:flutter/material.dart';

class Hspace extends StatelessWidget {
  final double hspace;
  const Hspace(this.hspace, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: hspace,
    );
  }
}
