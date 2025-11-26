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
        body: Center(
          child: Doom(wadPath: wadPath)
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
  final int framebufferSize = 64000; // 320 * 200

  late final Pointer<Uint8> framebuffer;
  late final Uint32List framebuffer32;

  final receivePort = ReceivePort();
  late final int nativePort;

  @override
  void initState() {
    super.initState();

    framebuffer = malloc<Uint8>(framebufferSize);
    framebuffer32 = Uint32List(framebufferSize);

    nativePort = receivePort.sendPort.nativePort;

    final dylib = DynamicLibrary.open('libdoom.so');

    final int Function(Pointer<Void>) dartInitializeApiDL = dylib.lookup<NativeFunction<IntPtr Function(Pointer<Void>)>>('Dart_InitializeApiDL').asFunction();
    dartInitializeApiDL(NativeApi.initializeApiDLData);
    
    final void Function(int) registerDartPort = dylib.lookup<NativeFunction<Void Function(Int64)>>('registerDartPort').asFunction();
    registerDartPort(nativePort);

    receivePort.listen((dynamic message) async {
      // Invoked at new frame ready

      for (int i=0; i<framebufferSize; i++) {
        framebuffer32[i] = 0xFF000000 | (framebuffer[i] << 16) | (framebuffer[i] << 8) | (framebuffer[i]);
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

    final void Function(Pointer<Utf8>, Pointer<Uint8>) flutterDoomStart = dylib.lookup<NativeFunction<Void Function(Pointer<Utf8>, Pointer<Uint8>)>>('FlutterDoomStart').asFunction();
    flutterDoomStart(widget.wadPath.toNativeUtf8(), framebuffer);
  }

  @override
  Widget build(BuildContext context) {
    if (frame == null) {
      return Text("Doom is starting...");
    }
    else {
      return CustomPaint(
        painter: FramebufferPainter(),
        size: const ui.Size(320, 200)
      );
    }
  }
}

class FramebufferPainter extends CustomPainter {  
  FramebufferPainter();

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final Rect src = Rect.fromLTWH(0, 0, frame!.width.toDouble(), frame!.height.toDouble());
    
    canvas.drawImageRect(
      frame!,
      src,
      src,
      Paint()
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}