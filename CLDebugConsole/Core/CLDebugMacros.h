// CLDebugConsole/Core/CLDebugMacros.h

#ifndef CLDebugMacros_h
#define CLDebugMacros_h

#import "CLLogLevel.h"

@class CLLogPlugin;

#define CLLogInfo(frmt, ...) \
    [[CLLogPlugin sharedPlugin] logWithLevel:CLLogLevelInfo \
                                   function:__PRETTY_FUNCTION__ \
                                       line:__LINE__ \
                                     format:(frmt), ##__VA_ARGS__]

#define CLLogWarning(frmt, ...) \
    [[CLLogPlugin sharedPlugin] logWithLevel:CLLogLevelWarning \
                                    function:__PRETTY_FUNCTION__ \
                                        line:__LINE__ \
                                      format:(frmt), ##__VA_ARGS__]

#define CLLogError(frmt, ...) \
    [[CLLogPlugin sharedPlugin] logWithLevel:CLLogLevelError \
                                    function:__PRETTY_FUNCTION__ \
                                        line:__LINE__ \
                                      format:(frmt), ##__VA_ARGS__]

#endif /* CLDebugMacros_h */
