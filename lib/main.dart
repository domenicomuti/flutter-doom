import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterdoom/keyboard.dart';
import 'package:path_provider/path_provider.dart';

final DynamicLibrary dylib = DynamicLibrary.open('libdoom.so');
final void Function(int, int) dartPostInput = dylib.lookup<NativeFunction<Void Function(Int32, Int32)>>('DartPostInput').asFunction();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ByteData wad = await rootBundle.load("doom1.wad");
  Uint8List wadBytes = wad.buffer.asUint8List(wad.offsetInBytes, wad.lengthInBytes);

  final Directory destDirectory = await getApplicationDocumentsDirectory();
  String wadPath = "${destDirectory.path}/doom1.wad";
  final file = File(wadPath);
  await file.writeAsBytes(wadBytes, flush: true);

  runApp(MainApp(wadPath: wadPath));
}

class MainApp extends StatelessWidget {
  final String wadPath;

  final Map<String, SingleKeyModel> keyModels = {
    "KEY_ENTER": SingleKeyModel(),
    "KEY_RCTRL": SingleKeyModel(),
    "SPACE": SingleKeyModel(),
    "KEY_TAB": SingleKeyModel(),
    "KEY_ESCAPE": SingleKeyModel(),
    "KEY_F9": SingleKeyModel(),
    "KEY_F6": SingleKeyModel(),
    "Y": SingleKeyModel()
  };

  MainApp({super.key, required this.wadPath});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const ui.Color.fromARGB(255, 15, 15, 15),
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
                    Row(
                      children: [
                        Expanded(
                          child: SingleKeyListener(
                            label: "ESC",
                            height: 60,
                            model: keyModels["KEY_ESCAPE"]!,
                            dartPostInput: dartPostInput,
                            asciiKey: "KEY_ESCAPE"
                          )
                        ),
                        SizedBox(width: 10.0),
                        Expanded(
                          child: SingleKeyListener(
                            label: "ENTER",
                            height: 60,
                            model: keyModels["KEY_ENTER"]!,
                            dartPostInput: dartPostInput,
                            asciiKey: "KEY_ENTER"
                          )
                        ),
                        SizedBox(width: 10.0),
                        Expanded(
                          child: SingleKeyListener(
                            label: "LOAD",
                            height: 60,
                            model: keyModels["KEY_F9"]!,
                            dartPostInput: dartPostInput,
                            asciiKey: "KEY_F9"
                          )
                        ),
                        SizedBox(width: 10.0),
                        Expanded(
                          child: SingleKeyListener(
                            label: "SAVE",
                            height: 60,
                            model: keyModels["KEY_F6"]!,
                            dartPostInput: dartPostInput,
                            asciiKey: "KEY_F6"
                          )
                        ),
                        SizedBox(width: 10.0),
                        Expanded(
                          child: SingleKeyListener(
                            label: "Y",
                            height: 60,
                            model: keyModels["Y"]!,
                            dartPostInput: dartPostInput,
                            asciiKey: "Y"
                          )
                        )
                      ]
                    ),
                    NumberKeys(dartPostInput: dartPostInput),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DirectionalKeys(dartPostInput: dartPostInput),
                        SingleKeyListener(
                          label: "FIRE",
                          width: 90,
                          height: 90,
                          model: keyModels["KEY_RCTRL"]!,
                          dartPostInput: dartPostInput,
                          asciiKey: "KEY_RCTRL"
                        )
                      ]
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: SingleKeyListener(
                            label: "MAP",
                            height: 60,
                            model: keyModels["KEY_TAB"]!,
                            dartPostInput: dartPostInput,
                            asciiKey: "KEY_TAB"
                          )
                        ),
                        SizedBox(width: 10.0),
                        Expanded(
                          child: SingleKeyListener(
                            label: "OPEN",
                            height: 60,
                            model: keyModels["SPACE"]!,
                            dartPostInput: dartPostInput,
                            asciiKey: "SPACE"
                          )
                        )
                      ]
                    )
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

class Doom extends StatefulWidget {
  final String wadPath;

  const Doom({super.key, required this.wadPath});
  
  @override
  State<Doom> createState() => _DoomState();
}

class _DoomState extends State<Doom> {
  final int framebufferSize = 64000;

  late final Pointer<UnsignedChar> framebuffer = malloc<UnsignedChar>(framebufferSize);
  late final Uint32List framebuffer32 = Uint32List(framebufferSize);
  final Pointer<Uint32> palette = malloc<Uint32>(256);

  ui.Image? frame;

  @override
  void initState() {
    super.initState();

    int Function(Pointer<Void>) dartInitializeApiDL = dylib.lookup<NativeFunction<IntPtr Function(Pointer<Void>)>>('Dart_InitializeApiDL').asFunction();
    dartInitializeApiDL(NativeApi.initializeApiDLData);
    
    void Function(int) registerDartPort = dylib.lookup<NativeFunction<Void Function(Int64)>>('registerDartPort').asFunction();
    ReceivePort receivePort = ReceivePort();
    registerDartPort(receivePort.sendPort.nativePort);

    receivePort.listen((dynamic message) async {
      // Invoked at new frame ready
      for (int i=0; i<framebufferSize; i++) {
        framebuffer32[i] = palette[framebuffer[i]];
      }

      ImmutableBuffer immutableBuffer = await ImmutableBuffer.fromUint8List(framebuffer32.buffer.asUint8List());

      final ui.Codec codec = await ui.ImageDescriptor.raw(
        immutableBuffer,
        width: 320,
        height: 200,
        rowBytes: null,
        pixelFormat: ui.PixelFormat.rgba8888, 
      ).instantiateCodec();

      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      
      setState(() {
        frame = frameInfo.image;
      });
    });

    final void Function(Pointer<Utf8>, Pointer<UnsignedChar>, Pointer<Uint32>) flutterDoomStart = dylib.lookup<NativeFunction<Void Function(Pointer<Utf8>, Pointer<UnsignedChar>, Pointer<Uint32>)>>('FlutterDoomStart').asFunction();
    flutterDoomStart(widget.wadPath.toNativeUtf8(), framebuffer, palette);
  }

  @override
  Widget build(BuildContext context) {
    var destWidth = MediaQuery.of(context).size.width;
    var destHeight = destWidth / 1.6;

    if (frame == null) {
      return Container(
        width: destWidth,
        height: destHeight,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black)
        ),
        child: Center(child: Text("Doom is starting...")),
      );
    }
    else {
      return CustomPaint(
        painter: FramebufferPainter(width: destWidth, height: destHeight, frame: frame!),
        size: ui.Size(destWidth, destHeight)
      );
    }
  }
}

class FramebufferPainter extends CustomPainter {
  double width;
  double height;
  ui.Image frame;

  FramebufferPainter({required this.width, required this.height, required this.frame});

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final Rect src = Rect.fromLTWH(0, 0, frame.width.toDouble(), frame.height.toDouble());
    final Rect dst = Rect.fromLTWH(0, 0, width, height);
    
    canvas.drawImageRect(frame, src, dst, Paint());
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}