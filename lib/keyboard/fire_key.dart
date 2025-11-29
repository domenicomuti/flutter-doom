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