// CLDebugConsole/Plugins/Log/CLLogFilter.m

#import "CLLogFilter.h"
#import "CLLogEntry.h"

@implementation CLLogFilter

+ (instancetype)defaultFilter {
    CLLogFilter *filter = [[CLLogFilter alloc] init];
    filter.levelFilterEnabled = NO;
    return filter;
}

- (BOOL)matchesEntry:(CLLogEntry *)entry {
    if (!entry) return NO;

    // Keyword filter
    if (self.keyword.length > 0) {
        NSRange range = [entry.message rangeOfString:self.keyword
                                             options:NSCaseInsensitiveSearch];
        if (range.location == NSNotFound) return NO;
    }

    // Level filter
    if (self.levelFilterEnabled && entry.level != self.level) {
        return NO;
    }

    // Date range filter
    if (self.startDate && [entry.timestamp compare:self.startDate] == NSOrderedAscending) {
        return NO;
    }
    if (self.endDate && [entry.timestamp compare:self.endDate] == NSOrderedDescending) {
        return NO;
    }

    return YES;
}

@end
