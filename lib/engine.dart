import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

class Engine {
  static final Engine _instance = Engine._constructor();

  late final DynamicLibrary dylib;
  late final int Function(Pointer<Void>) dartInitializeApiDL;
  late final void Function(int) registerDartPort;
  late final void Function(Pointer<Utf8>, Pointer<UnsignedChar>, Pointer<Uint32>) flutterDoomStart;
  late final void Function(int, int) dartPostInput;

  final int framebufferSize = 64000;
  late final Pointer<UnsignedChar> framebuffer;
  late final Uint32List framebuffer32;
  late final Pointer<Uint32> palette;

  factory Engine() {
    return _instance;
  }

  Engine._constructor() {
    dylib = DynamicLibrary.open('libdoom.so');
    dartInitializeApiDL = dylib.lookup<NativeFunction<IntPtr Function(Pointer<Void>)>>('Dart_InitializeApiDL').asFunction();
    registerDartPort = dylib.lookup<NativeFunction<Void Function(Int64)>>('registerDartPort').asFunction();
    flutterDoomStart = dylib.lookup<NativeFunction<Void Function(Pointer<Utf8>, Pointer<UnsignedChar>, Pointer<Uint32>)>>('FlutterDoomStart').asFunction();
    dartPostInput = dylib.lookup<NativeFunction<Void Function(Int32, Int32)>>('DartPostInput').asFunction();

    framebuffer = malloc<UnsignedChar>(framebufferSize);
    framebuffer32 = Uint32List(framebufferSize);
    palette = malloc<Uint32>(256);
  }
}