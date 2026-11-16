// CLDebugConsole/Core/CLDebugMacros.h

#ifndef CLDebugMacros_h
#define CLDebugMacros_h

@class CLLogPlugin;

// Log level constants (must match CLLogLevel enum in LogPlugin)
static const NSInteger CLDebugLogLevelInfo = 0;
static const NSInteger CLDebugLogLevelWarning = 1;
static const NSInteger CLDebugLogLevelError = 2;

#define CLLogInfo(frmt, ...) \
    [[CLLogPlugin sharedPlugin] logWithLevel:CLDebugLogLevelInfo \
                                   function:__PRETTY_FUNCTION__ \
                                       line:__LINE__ \
                                     format:(frmt), ##__VA_ARGS__]

#define CLLogWarning(frmt, ...) \
    [[CLLogPlugin sharedPlugin] logWithLevel:CLDebugLogLevelWarning \
                                    function:__PRETTY_FUNCTION__ \
                                        line:__LINE__ \
                                      format:(frmt), ##__VA_ARGS__]

#define CLLogError(frmt, ...) \
    [[CLLogPlugin sharedPlugin] logWithLevel:CLDebugLogLevelError \
                                    function:__PRETTY_FUNCTION__ \
                                        line:__LINE__ \
                                      format:(frmt), ##__VA_ARGS__]

#endif /* CLDebugMacros_h */
