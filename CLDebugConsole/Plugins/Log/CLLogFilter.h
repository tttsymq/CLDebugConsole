// CLDebugConsole/Plugins/Log/CLLogFilter.h

#import <Foundation/Foundation.h>
#import "CLLogLevel.h"

@class CLLogEntry;

@interface CLLogFilter : NSObject

@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, assign) CLLogLevel level;
@property (nonatomic, assign) BOOL levelFilterEnabled;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

+ (instancetype)defaultFilter;
- (BOOL)matchesEntry:(CLLogEntry *)entry;

@end
