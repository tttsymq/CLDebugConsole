// CLDebugConsole/Plugins/Log/CLLogLevel.h

#ifndef CLLogLevel_h
#define CLLogLevel_h

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CLLogLevel) {
    CLLogLevelInfo = 0,
    CLLogLevelWarning,
    CLLogLevelError
};

static inline NSString *CLLogLevelString(CLLogLevel level) {
    switch (level) {
        case CLLogLevelInfo:    return @"Info";
        case CLLogLevelWarning: return @"Warning";
        case CLLogLevelError:   return @"Error";
    }
    return @"Unknown";
}

static inline UIColor *CLLogLevelColor(CLLogLevel level) {
    switch (level) {
        case CLLogLevelInfo:    return [UIColor whiteColor];
        case CLLogLevelWarning: return [UIColor yellowColor];
        case CLLogLevelError:   return [UIColor redColor];
    }
    return [UIColor whiteColor];
}

#endif /* CLLogLevel_h */
