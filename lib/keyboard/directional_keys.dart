import 'package:flutter/material.dart';
import 'package:flutterdoom/engine.dart';
import 'package:flutterdoom/keyboard/ascii_keys.dart';
import 'package:flutterdoom/keyboard/single_key.dart';

class DirectionalKeys extends StatefulWidget {
  const DirectionalKeys({super.key});
  
  @override
  State<DirectionalKeys> createState() => _DirectionalKeysState();
}

class _DirectionalKeysState extends State<DirectionalKeys> {
  Engine engine = Engine();
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
            engine.dartPostInput(AsciiKeys.keyCodes["KEY_UPARROW"]!, 0);
            engine.dartPostInput(AsciiKeys.keyCodes[pressedKeys[pointer]! == "KEY_UPLEFTARROW" ? "KEY_LEFTARROW" : "KEY_RIGHTARROW"]!, 0);
          }
          else {
            engine.dartPostInput(AsciiKeys.keyCodes[pressedKeys[pointer]!]!, 0);
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
      engine.dartPostInput(AsciiKeys.keyCodes["KEY_UPARROW"]!, down);
      engine.dartPostInput(AsciiKeys.keyCodes[key == "KEY_UPLEFTARROW" ? "KEY_LEFTARROW" : "KEY_RIGHTARROW"]!, down);
    }
    else {
      engine.dartPostInput(AsciiKeys.keyCodes[key]!, down);
    }
    models[key]!.setPressed(down == 1);
  }

  void handleGesture(PointerEvent event, int down, double size, double sizeDiv2, double sizeDiv3, double sizeDiv3Mul2) {
    if (
      event.localPosition.dy < 0 ||
      event.localPosition.dy >= size ||
      event.localPosition.dx < 0 ||
      event.localPosition.dx >= size
    ) {
      // If the finger moves out the area, release all the pressed buttons
      pressedKeys.forEach((key, value) {
        if (value == "KEY_UPLEFTARROW" || value == "KEY_UPRIGHTARROW") {
          engine.dartPostInput(AsciiKeys.keyCodes["KEY_UPARROW"]!, 0);
          engine.dartPostInput(AsciiKeys.keyCodes[value == "KEY_UPLEFTARROW" ? "KEY_LEFTARROW" : "KEY_RIGHTARROW"]!, 0);
        }
        else {
          engine.dartPostInput(AsciiKeys.keyCodes[value]!, 0);
        }
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
    final Color mainDirectionalColor = const Color(0xFF00006b);
    final Color mainDirectionalBorderColor = const Color(0xFF1b1bff);
    final Color mainDirectionalActiveColor = const Color(0xFF3737ff);

    double size = MediaQuery.of(context).size.width * 0.3;
    if (size < 200) size = 200;
    double sizeDiv2 = size / 2.0;
    double sizeDiv3 = size / 3.0;
    double sizeDiv3Mul2 = sizeDiv3 * 2.0;
    
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) => handleGesture(event, 1, size, sizeDiv2, sizeDiv3, sizeDiv3Mul2),
      onPointerMove: (event) => handleGesture(event, 2, size, sizeDiv2, sizeDiv3, sizeDiv3Mul2),
      onPointerUp: (event) => handleGesture(event, 0, size, sizeDiv2, sizeDiv3, sizeDiv3Mul2),
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
                  Expanded(child: SingleKey(label: "UP", model: models["KEY_UPARROW"]!, height: double.infinity,
                    background: mainDirectionalColor, borderColor: mainDirectionalBorderColor, activeColor: mainDirectionalActiveColor)),
                  SizedBox(width: 5.0),
                  Expanded(child: SingleKey(label: "UP R", model: models["KEY_UPRIGHTARROW"]!, height: double.infinity))
                ]
              )
            ),
            SizedBox(height: 5.0),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: SingleKey(label: "LEFT", model: models["KEY_LEFTARROW"]!, height: double.infinity,
                    background: mainDirectionalColor, borderColor: mainDirectionalBorderColor, activeColor: mainDirectionalActiveColor)),
                  SizedBox(width: 5.0),
                  Expanded(child: SingleKey(label: "RIGHT", model: models["KEY_RIGHTARROW"]!, height: double.infinity,
                    background: mainDirectionalColor, borderColor: mainDirectionalBorderColor, activeColor: mainDirectionalActiveColor))
                ]
              )
            ),
            SizedBox(height: 5.0),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: SingleKey(label: "STRAFE\nL", model: models[","]!, height: double.infinity)),
                  SizedBox(width: 5.0),
                  Expanded(child: SingleKey(label: "DOWN", model: models["KEY_DOWNARROW"]!, height: double.infinity,
                    background: mainDirectionalColor, borderColor: mainDirectionalBorderColor, activeColor: mainDirectionalActiveColor)),
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