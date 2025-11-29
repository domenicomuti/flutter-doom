import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterdoom/doom.dart';
import 'package:flutterdoom/engine.dart';
import 'package:flutterdoom/keyboard/bottom_keys.dart';
import 'package:flutterdoom/keyboard/directional_keys.dart';
import 'package:flutterdoom/keyboard/fire_key.dart';
import 'package:flutterdoom/keyboard/upper_keys.dart';
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

  runApp(MainApp(wadPath: wadPath));
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
              ))
            ]
          )
        )
      )
    );
  }
}