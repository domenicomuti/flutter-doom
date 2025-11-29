import 'package:flutter/material.dart';
import 'package:flutterdoom/engine.dart';
import 'package:flutterdoom/keyboard/ascii_keys.dart';

class SingleKeyModel extends ChangeNotifier {
  bool pressed = false;

  void setPressed(bool pressed) {
    this.pressed = pressed;
    notifyListeners();
  }
}

class SingleKey extends StatelessWidget {
  final String label;
  final double? width;
  final double? height;
  final SingleKeyModel model;
  final Color background;
  final Color borderColor;
  final Color activeColor;

  const SingleKey({
    super.key,
    required this.label,
    this.width,
    this.height,
    required this.model,
    this.background = const Color.fromARGB(255, 70, 70, 70),
    this.borderColor = const Color.fromARGB(255, 116, 116, 116),
    this.activeColor = const Color.fromARGB(255, 112, 112, 112)
  });
  
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder:(context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: model.pressed ? activeColor : background,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: borderColor),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 3.0, top: 2.0),
            child: Text(label, style: TextStyle(
              fontSize: 12.0,
              color: model.pressed ? const Color.fromARGB(255, 34, 34, 34) : const Color.fromARGB(255, 206, 206, 206))
            )
          )
        );
      },
    );
  }
}

class SingleKeyListener extends SingleKey {
  final Engine engine = Engine();
  final String asciiKey;

  SingleKeyListener({
    super.key,
    required super.label,
    super.width,
    super.height,
    super.background,
    super.borderColor,
    super.activeColor,
    required super.model,
    required this.asciiKey
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        engine.dartPostInput(AsciiKeys.keyCodes[asciiKey]!, 1);
        model.setPressed(true);
      },
      onPointerUp: (event) {
        engine.dartPostInput(AsciiKeys.keyCodes[asciiKey]!, 0);
        model.setPressed(false);
      },
      child: super.build(context)
    );
  }
}