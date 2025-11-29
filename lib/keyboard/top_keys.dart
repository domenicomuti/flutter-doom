/*
 * Copyright (C) 2025 Domenico Muti
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 31 Milk St # 960789 Boston, MA 02196 USA.
 */

import 'package:flutter/material.dart';
import 'package:flutterdoom/engine.dart';
import 'package:flutterdoom/keyboard/single_key.dart';

class SystemKeys extends StatelessWidget {
  const SystemKeys({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleKeyListener(
            label: "ESC",
            height: 50,
            model: SingleKeyModel(),
            asciiKey: "KEY_ESCAPE"
          )
        ),
        SizedBox(width: 10.0),
        Expanded(
          child: SingleKeyListener(
            label: "ENTER",
            height: 50,
            model: SingleKeyModel(),
            asciiKey: "KEY_ENTER"
          )
        ),
        SizedBox(width: 10.0),
        Expanded(
          child: SingleKeyListener(
            label: "LOAD",
            height: 50,
            model: SingleKeyModel(),
            asciiKey: "KEY_F9"
          )
        ),
        SizedBox(width: 10.0),
        Expanded(
          child: SingleKeyListener(
            label: "SAVE",
            height: 50,
            model: SingleKeyModel(),
            asciiKey: "KEY_F6"
          )
        ),
        SizedBox(width: 10.0),
        Expanded(
          child: SingleKeyListener(
            label: "GAMMA",
            height: 50,
            model: SingleKeyModel(),
            asciiKey: "KEY_F11"
          )
        ),
        SizedBox(width: 10.0),
        Expanded(
          child: SingleKeyListener(
            label: "Y",
            height: 50,
            model: SingleKeyModel(),
            asciiKey: "Y"
          )
        )
      ]
    );
  }
}

class NumericKeys extends StatelessWidget {
  final Engine engine = Engine();

  NumericKeys({super.key});
  
  @override
  Widget build(BuildContext context) {

    double width = (MediaQuery.of(context).size.width * 0.7) / 7.0;
    double height = (width * 0.6);
    if (height < 30) height = 30;

    List<Widget> keys = [];

    for (int i=1; i<=7; i++) {
      String iString = i.toString();
      keys.add(
        SingleKeyListener(
          label: iString,
          width: width,
          height: height,
          model: SingleKeyModel(),
          asciiKey: iString
        )
      );
    }

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: keys);
  }
}