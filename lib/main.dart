import 'package:flutter/material.dart';
import 'dart:ffi' as ffi;

late final ffi.DynamicLibrary dylib;
late final void Function() doomMain;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();

    dylib = ffi.DynamicLibrary.open('libdoom.so');
    doomMain = dylib.lookup<ffi.NativeFunction<ffi.Void Function()>>('D_DoomMain').asFunction();
    doomMain();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
