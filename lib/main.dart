import 'dart:ffi' hide Size;
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart' hide Size;
import 'package:flutter/services.dart' hide Size;
import 'package:path_provider/path_provider.dart';


ui.Image? frame;
final DynamicLibrary dylib = DynamicLibrary.open('libdoom.so');
final void Function(int, int) dartPostInput = dylib.lookup<NativeFunction<Void Function(Int32, Int32)>>('DartPostInput').asFunction();
enum DartKeys {dartUp, dartDown, dartLeft, dartRight, dartEnter, dartFire, dartSpace, dartEscape, dartTab}



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

  const MainApp({super.key, required this.wadPath});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Doom(wadPath: wadPath),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(children: [
                          Listener(
                            onPointerDown: (event) => dartPostInput(DartKeys.dartUp.index, 1),
                            onPointerUp: (event) => dartPostInput(DartKeys.dartUp.index, 0),
                            child: makeButton('UP')
                          ),
                          SizedBox(height: 10.0),
                          Row(children: [
                            Listener(
                              onPointerDown: (event) => dartPostInput(DartKeys.dartLeft.index, 1),
                              onPointerUp: (event) => dartPostInput(DartKeys.dartLeft.index, 0),
                              child: makeButton('LEFT')
                            ),
                            SizedBox(width: 20),
                            Listener(
                              onPointerDown: (event) => dartPostInput(DartKeys.dartRight.index, 1),
                              onPointerUp: (event) => dartPostInput(DartKeys.dartRight.index, 0),
                              child: makeButton('RIGHT')
                            ),
                          ]),
                          SizedBox(height: 10.0),
                          Listener(
                            onPointerDown: (event) => dartPostInput(DartKeys.dartDown.index, 1),
                            onPointerUp: (event) => dartPostInput(DartKeys.dartDown.index, 0),
                            child: makeButton('DOWN')
                          )
                        ]),

                        Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Listener(
                                onPointerDown: (event) => dartPostInput(DartKeys.dartEscape.index, 1),
                                onPointerUp: (event) => dartPostInput(DartKeys.dartEscape.index, 0),
                                child: makeButton('ESC')
                              ),
                              SizedBox(width: 20.0),
                              Listener(
                                onPointerDown: (event) => dartPostInput(DartKeys.dartEnter.index, 1),
                                onPointerUp: (event) => dartPostInput(DartKeys.dartEnter.index, 0),
                                child: makeButton('ENTER')
                              )
                            ]
                          ),
                          SizedBox(height: 20.0),
                          Row(children: [
                            Listener(
                              onPointerDown: (event) => dartPostInput(DartKeys.dartFire.index, 1),
                              onPointerUp: (event) => dartPostInput(DartKeys.dartFire.index, 0),
                              child: makeButton('CTRL')
                            ),
                          ])
                        ])
                      ]
                    ),
                    SizedBox(height: 20.0),
                    Row(children: [
                      Expanded(child: Listener(
                        onPointerDown: (event) => dartPostInput(DartKeys.dartTab.index, 1),
                        onPointerUp: (event) => dartPostInput(DartKeys.dartTab.index, 0),
                        child: makeButton('TAB')
                      )),
                      SizedBox(width: 20.0),
                      Expanded(child: Listener(
                        onPointerDown: (event) => dartPostInput(DartKeys.dartSpace.index, 1),
                        onPointerUp: (event) => dartPostInput(DartKeys.dartSpace.index, 0),
                        child: makeButton('SPACE')
                      ))
                    ])
                  ]
                )
              )
            ]
          )
        )
      )
    );
  }

  Widget makeButton(String label) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: const ui.Color.fromARGB(255, 207, 207, 207),
        border: Border.all(color: const ui.Color.fromARGB(255, 151, 151, 151))
      ),
      child: Padding(padding: EdgeInsets.only(left: 3.0, top: 3.0), child: Text(label)),
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
  final int framebufferSize = 64000; // 320 * 200

  late final Pointer<UnsignedChar> framebuffer;
  late final Uint32List framebuffer32;
  late final Pointer<Uint32> palette;

  final receivePort = ReceivePort();
  late final int nativePort;

  @override
  void initState() {
    super.initState();

    framebuffer = malloc<UnsignedChar>(framebufferSize);
    framebuffer32 = Uint32List(framebufferSize);

    palette = malloc<Uint32>(256);

    final int Function(Pointer<Void>) dartInitializeApiDL = dylib.lookup<NativeFunction<IntPtr Function(Pointer<Void>)>>('Dart_InitializeApiDL').asFunction();
    dartInitializeApiDL(NativeApi.initializeApiDLData);
    
    nativePort = receivePort.sendPort.nativePort;
    final void Function(int) registerDartPort = dylib.lookup<NativeFunction<Void Function(Int64)>>('registerDartPort').asFunction();
    registerDartPort(nativePort);

    receivePort.listen((dynamic message) async {
      // Invoked at new frame ready
      for (int i=0; i<framebufferSize; i++) {
        framebuffer32[i] = palette[framebuffer[i]];
      }

      var immutableBuffer = await ImmutableBuffer.fromUint8List(framebuffer32.buffer.asUint8List());

      final ui.Codec codec = await ui.ImageDescriptor.raw(
        immutableBuffer,
        width: 320,
        height: 200,
        rowBytes: null,
        pixelFormat: ui.PixelFormat.rgba8888, 
      ).instantiateCodec();

      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      frame = frameInfo.image;
      
      setState(() {});
    });

    final void Function(Pointer<Utf8>, Pointer<UnsignedChar>, Pointer<Uint32>) flutterDoomStart = dylib.lookup<NativeFunction<Void Function(Pointer<Utf8>, Pointer<UnsignedChar>, Pointer<Uint32>)>>('FlutterDoomStart').asFunction();
    flutterDoomStart(widget.wadPath.toNativeUtf8(), framebuffer, palette);
  }

  @override
  Widget build(BuildContext context) {
    if (frame == null) {
      return Text("Doom is starting...");
    }
    else {
      var destWidth = MediaQuery.of(context).size.width;
      var destHeight = destWidth / 1.6;

      return CustomPaint(
        painter: FramebufferPainter(width: destWidth, height: destHeight),
        size: ui.Size(destWidth, destHeight)
      );
    }
  }
}

class FramebufferPainter extends CustomPainter {
  double width;
  double height;

  FramebufferPainter({required this.width, required this.height});

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final Rect src = Rect.fromLTWH(0, 0, frame!.width.toDouble(), frame!.height.toDouble());
    final Rect dst = Rect.fromLTWH(0, 0, width, height);
    
    canvas.drawImageRect(frame!, src, dst, Paint());
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}