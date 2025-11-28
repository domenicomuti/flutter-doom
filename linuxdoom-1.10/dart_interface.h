#ifndef DART_INTERFACE_H
#define DART_INTERFACE_H

#include "dart/dart_api_dl.h"

void registerDartPort(Dart_Port port);

void notifyDartFrameReady();

#endif