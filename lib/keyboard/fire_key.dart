import 'package:flutter/material.dart';
import 'package:flutterdoom/keyboard/single_key.dart';

class FireKey extends StatelessWidget {
  const FireKey({super.key});

  @override
  Widget build(BuildContext context) {
    double fireButtonSize = MediaQuery.of(context).size.width * 0.125;
    if (fireButtonSize < 80) fireButtonSize = 80;
    
    return SingleKeyListener(
      label: "FIRE",
      width: fireButtonSize,
      height: fireButtonSize,
      model: SingleKeyModel(),
      asciiKey: "KEY_RCTRL",
      background: const Color(0xFF5b0000),
      borderColor: const Color(0xFF7f0000),
      activeColor: const Color(0xFFa70000)
    );
  }
}