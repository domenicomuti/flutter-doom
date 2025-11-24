import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'dart:ffi';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

late final DynamicLibrary dylib;
late final void Function(Pointer<Utf8>) doomMain;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ByteData wad = await rootBundle.load("doom1.wad");
  Uint8List wadBytes = wad.buffer.asUint8List(
    wad.offsetInBytes,
    wad.lengthInBytes,
  );

  final Directory destDirectory = await getApplicationDocumentsDirectory();
  String wadPath = "${destDirectory.path}/doom1.wad";
  final file = File(wadPath);
  await file.writeAsBytes(wadBytes, flush: true);

  runApp(MainApp(wadPath: wadPath));
}

class MainApp extends StatefulWidget {
  final String wadPath;

  const MainApp({super.key, required this.wadPath});
  
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    dylib = DynamicLibrary.open('libdoom.so');
    doomMain = dylib.lookup<NativeFunction<Void Function(Pointer<Utf8>)>>('D_DoomMain').asFunction();
    doomMain(widget.wadPath.toNativeUtf8());
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
