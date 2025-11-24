#ifndef DEBUG_H
#define DEBUG_H

#include <android/log.h>

#ifdef NDEBUG
    #define LOG(...)
#else
    #define LOG(...) __android_log_print(ANDROID_LOG_DEBUG, "flutter", __VA_ARGS__)
#endif

#endif