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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterdoom/doom.dart';
import 'package:flutterdoom/engine.dart';
import 'package:flutterdoom/keyboard/bottom_keys.dart';
import 'package:flutterdoom/keyboard/directional_keys.dart';
import 'package:flutterdoom/keyboard/fire_key.dart';
import 'package:flutterdoom/keyboard/top_keys.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ByteData wad = await rootBundle.load("doom1.wad");
  Uint8List wadBytes = wad.buffer.asUint8List(wad.offsetInBytes, wad.lengthInBytes);

  final Directory destDirectory = await getApplicationDocumentsDirectory();
  String wadPath = "${destDirectory.path}/doom1.wad";
  final file = File(wadPath);
  await file.writeAsBytes(wadBytes, flush: true);

  Engine();   // Initialize the singleton Engine

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ])
  .then((_) {
    runApp(MainApp(wadPath: wadPath));
  });
}

class MainApp extends StatelessWidget {
  final String wadPath;

  const MainApp({super.key, required this.wadPath});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'BigBlue_TerminalPlus'
      ),
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
          child: child!
        );
      },
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 15, 15, 15),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Doom(wadPath: wadPath),
              Expanded(child: Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SystemKeys(),
                      NumericKeys(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DirectionalKeys(),
                          FireKey()
                        ]
                      ),
                      BottomKeys()
                    ]
                  )
                )
              )
            ]
          )
        )
      )
    );
  }
}