import 'package:flutter/material.dart';

class AsciiKeys {
  static const Map<String, int> keyCodes = {
    "KEY_RIGHTARROW": 0xae,
    "KEY_LEFTARROW": 0xac,
    "KEY_UPARROW": 0xad,
    "KEY_DOWNARROW": 0xaf,
    "KEY_ESCAPE": 27,
    "KEY_ENTER": 13,
    "KEY_TAB": 9,
    "KEY_F1": 0x80+0x3b,
    "KEY_F2": 0x80+0x3c,
    "KEY_F3": 0x80+0x3d,
    "KEY_F4": 0x80+0x3e,
    "KEY_F5": 0x80+0x3f,
    "KEY_F6": 0x80+0x40,
    "KEY_F7": 0x80+0x41,
    "KEY_F8": 0x80+0x42,
    "KEY_F9": 0x80+0x43,
    "KEY_F10": 0x80+0x44,
    "KEY_F11": 0x80+0x57,
    "KEY_F12": 0x80+0x58,
    "KEY_BACKSPACE": 127,
    "KEY_PAUSE": 0xff,
    "KEY_EQUALS": 0x3d,
    "KEY_MINUS": 0x2d,
    "KEY_RSHIFT": 0x80+0x36,
    "KEY_RCTRL": 0x80+0x1d,
    "KEY_RALT": 0x80+0x38,
    "KEY_LALT": 0x80+0x38,
    ",": 44,
    ".": 46,
    "SPACE": 32,
    "1": 49,
    "2": 50,
    "3": 51,
    "4": 52,
    "5": 53,
    "6": 54,
    "7": 55,
    "Y": 121
  };
}

class DirectionalKeys extends StatefulWidget {
  final void Function(int, int) dartPostInput;

  const DirectionalKeys({super.key, required this.dartPostInput});
  
  @override
  State<DirectionalKeys> createState() => _DirectionalKeysState();
}

class _DirectionalKeysState extends State<DirectionalKeys> {
  final double size = 200.0;
  late double sizeDiv2 = size / 2.0;
  late double sizeDiv3 = size / 3.0;
  late double sizeDiv3Mul2 = sizeDiv3 * 2.0;

  final Map<int, String> pressedKeys = {};

  final Map<String, SingleKeyModel> models = {
    "KEY_UPLEFTARROW": SingleKeyModel(),
    "KEY_UPRIGHTARROW": SingleKeyModel(),
    "KEY_UPARROW": SingleKeyModel(),
    "KEY_DOWNARROW": SingleKeyModel(),
    "KEY_LEFTARROW": SingleKeyModel(),
    "KEY_RIGHTARROW": SingleKeyModel(),
    ",": SingleKeyModel(),
    ".": SingleKeyModel()
  };

  void setKey(String key, int pointer, int down) {

    // If finger is moving 
    if (down == 2) {
      
      // If there's a previus button pressed (it means the finger went from inside the area)
      if (pressedKeys[pointer] != null) {

        // If it's the same button, exit
        if (pressedKeys[pointer] == key) {
          return;
        }
        else {
          // If it's a different button, release the previus button and set the new one
          //debugPrint("RELEASE ${pressedKeys[pointer]}");
          if (pressedKeys[pointer]! == "KEY_UPLEFTARROW" || pressedKeys[pointer]! == "KEY_UPRIGHTARROW") {
            widget.dartPostInput(AsciiKeys.keyCodes["KEY_UPARROW"]!, 0);
            widget.dartPostInput(AsciiKeys.keyCodes[pressedKeys[pointer]! == "KEY_UPLEFTARROW" ? "KEY_LEFTARROW" : "KEY_RIGHTARROW"]!, 0);
          }
          else {
            widget.dartPostInput(AsciiKeys.keyCodes[pressedKeys[pointer]!]!, 0);
          }         
          models[pressedKeys[pointer]!]!.setPressed(false);
          down = 1; // Goto gesture down
        }
      }
      else {
        // If there's no previus button pressed (it means the finger went from outside the area)
        down = 1; // Goto gesture down
      }
    }

    if (down == 0) {
      // Gesture up
      //debugPrint("RELEASE $key");
      pressedKeys.remove(pointer);
    }
    else {
      // Gesture down
      //debugPrint("SET $key");
      pressedKeys[pointer] = key;
    }

    if (key == "KEY_UPLEFTARROW" || key == "KEY_UPRIGHTARROW") {
      widget.dartPostInput(AsciiKeys.keyCodes["KEY_UPARROW"]!, down);
      widget.dartPostInput(AsciiKeys.keyCodes[key == "KEY_UPLEFTARROW" ? "KEY_LEFTARROW" : "KEY_RIGHTARROW"]!, down);
    }
    else {
      widget.dartPostInput(AsciiKeys.keyCodes[key]!, down);
    }
    models[key]!.setPressed(down == 1);
  }

  void handleGesture(PointerEvent event, int down) {
    if (
      event.localPosition.dy < 0 ||
      event.localPosition.dy >= size ||
      event.localPosition.dx < 0 ||
      event.localPosition.dx >= size
    ) {
      // If the finger moves out the area, release all the pressed buttons
      pressedKeys.forEach((key, value) {
        widget.dartPostInput(AsciiKeys.keyCodes[value]!, 0);
        models[value]!.setPressed(false);
      });
      pressedKeys.clear();
    }
    else if (event.localPosition.dy < sizeDiv3) {
      // Row 1
      if (event.localPosition.dx < sizeDiv3) {
        setKey("KEY_UPLEFTARROW", event.pointer, down);
      }
      else if (event.localPosition.dx < sizeDiv3Mul2) {
        setKey("KEY_UPARROW", event.pointer, down);
      }
      else {
        setKey("KEY_UPRIGHTARROW", event.pointer, down);
      }
    }
    else if (event.localPosition.dy < sizeDiv3Mul2) {
      // Row 2
      if (event.localPosition.dx < sizeDiv2) {
        setKey("KEY_LEFTARROW", event.pointer, down);
      }
      else {
        setKey("KEY_RIGHTARROW", event.pointer, down);
      }
    }
    else {
      // Row 3
      if (event.localPosition.dx < sizeDiv3) {
        setKey(",", event.pointer, down);
      }
      else if (event.localPosition.dx < sizeDiv3Mul2) {
        setKey("KEY_DOWNARROW", event.pointer, down);
      }
      else {
        setKey(".", event.pointer, down);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) => handleGesture(event, 1),
      onPointerMove: (event) => handleGesture(event, 2),
      onPointerUp: (event) => handleGesture(event, 0),
      child: SizedBox(
        width: size,
        height: size,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: SingleKey(label: "UP L", model: models["KEY_UPLEFTARROW"]!, height: double.infinity)),
                  SizedBox(width: 5.0),
                  Expanded(child: SingleKey(label: "UP", model: models["KEY_UPARROW"]!, height: double.infinity)),
                  SizedBox(width: 5.0),
                  Expanded(child: SingleKey(label: "UP R", model: models["KEY_UPRIGHTARROW"]!, height: double.infinity))
                ]
              )
            ),
            SizedBox(height: 5.0),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: SingleKey(label: "LEFT", model: models["KEY_LEFTARROW"]!, height: double.infinity)),
                  SizedBox(width: 5.0),
                  Expanded(child: SingleKey(label: "RIGHT", model: models["KEY_RIGHTARROW"]!, height: double.infinity))
                ]
              )
            ),
            SizedBox(height: 5.0),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: SingleKey(label: "STRAFE\nL", model: models[","]!, height: double.infinity)),
                  SizedBox(width: 5.0),
                  Expanded(child: SingleKey(label: "DOWN", model: models["KEY_DOWNARROW"]!, height: double.infinity)),
                  SizedBox(width: 5.0),
                  Expanded(child: SingleKey(label: "STRAFE\nR", model: models["."]!, height: double.infinity))
                ]
              )
            )
          ]
        )
      )
    );
  }
}

class NumberKeys extends StatelessWidget {
  final void Function(int, int) dartPostInput;

  final Map<String, SingleKeyModel> models = {
    "1": SingleKeyModel(),
    "2": SingleKeyModel(),
    "3": SingleKeyModel(),
    "4": SingleKeyModel(),
    "5": SingleKeyModel(),
    "6": SingleKeyModel(),
    "7": SingleKeyModel()
  };

  NumberKeys({super.key, required this.dartPostInput});
  
  @override
  Widget build(BuildContext context) {
    List<Widget> keys = [];

    for (int i=1; i<=7; i++) {
      String iString = i.toString();
      keys.add(
        SingleKeyListener(
          label: iString,
          width: 40,
          height: 40,
          model: models[iString]!,
          dartPostInput: dartPostInput,
          asciiKey: iString
        )
      );
    }

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: keys);
  }
  
}

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

  final Color background = const Color.fromARGB(255, 70, 70, 70);
  final Color borderColor = const Color.fromARGB(255, 116, 116, 116);
  final Color activeButton = const Color.fromARGB(255, 112, 112, 112);
  const SingleKey({super.key, required this.label, this.width, this.height, required this.model});
  
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder:(context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: model.pressed ? activeButton : background,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: borderColor),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 3.0, top: 3.0),
            child: Text(label, style: TextStyle(color: model.pressed ? const Color.fromARGB(255, 34, 34, 34) : const Color.fromARGB(255, 206, 206, 206)))
          )
        );
      },
    );
  }
}

class SingleKeyListener extends SingleKey {
  final void Function(int, int) dartPostInput;
  final String asciiKey;

  const SingleKeyListener({
    super.key,
    required super.label,
    super.width,
    super.height,
    required super.model,
    required this.dartPostInput,
    required this.asciiKey
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        dartPostInput(AsciiKeys.keyCodes[asciiKey]!, 1);
        model.setPressed(true);
      },
      onPointerUp: (event) {
        dartPostInput(AsciiKeys.keyCodes[asciiKey]!, 0);
        model.setPressed(false);
      },
      child: super.build(context)
    );
  }
}