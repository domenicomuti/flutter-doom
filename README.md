# FlutterDoom

![Video Demo](demo.gif)

A new Doom port based on the original 1997 source code, built for Android, iOS, Linux, macOS and Windows using Flutter and dart:ffi.

For comprehensive details on how it was made, I created a highly detailed post on my blog.

https://bitsparkle.dev/post/flutter-doom/

## How to build

```bash
git clone https://github.com/domenicomuti/flutter-doom

cd flutter-doom

# You need doom1.wad in the assets folder
curl https://distro.ibiblio.org/slitaz/sources/packages/d/doom1.wad --output assets/doom1.wad

flutter pub get

# Run the project

# Android or iOS (make sure that a virtual or physical device is connected first)
flutter run

# macOS
flutter run -d macos

# Linux
flutter run -d linux

# Windows
flutter run -d windows

```

## LICENSE

GPL 2