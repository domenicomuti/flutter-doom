#include "dart_interface.h"

Dart_Port dart_receive_port = ILLEGAL_PORT;

void registerDartPort(Dart_Port port) {
    dart_receive_port = port;
}

void notifyDartFrameReady() {
    if (dart_receive_port == ILLEGAL_PORT) {
        return;
    }
    Dart_PostInteger_DL(dart_receive_port, 0);
}