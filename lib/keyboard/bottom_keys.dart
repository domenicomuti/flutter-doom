import 'package:flutter/material.dart';
import 'package:flutterdoom/keyboard/single_key.dart';

class BottomKeys extends StatelessWidget {
  const BottomKeys({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleKeyListener(
            label: "MAP",
            height: 60,
            model: SingleKeyModel(),
            asciiKey: "KEY_TAB"
          )
        ),
        SizedBox(width: 10.0),
        Expanded(
          child: SingleKeyListener(
            label: "OPEN",
            height: 60,
            model: SingleKeyModel(),
            asciiKey: "SPACE",
            background: const Color(0xFF17330f),
            borderColor: const Color(0xFF2f6323),
            activeColor: const Color(0xFF3f832f)
          )
        ),
        SizedBox(width: 10.0),
        Expanded(
          child: SingleKeyListener(
            label: "RUN",
            height: 60,
            model: SingleKeyModel(),
            asciiKey: "KEY_RSHIFT"
          )
        )
      ]
    );
  }
}