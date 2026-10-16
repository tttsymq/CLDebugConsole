// CLDebugConsole/Utils/CLDebugDateFormatter.h

#import <Foundation/Foundation.h>

@interface CLDebugDateFormatter : NSObject

+ (NSString *)dailyFileNameForDate:(NSDate *)date;
+ (NSDate *)dateFromDailyFileName:(NSString *)fileName;
+ (NSDate *)startOfDay:(NSDate *)date;
+ (NSDate *)endOfDay:(NSDate *)date;
+ (BOOL)isSameDay:(NSDate *)date1 date2:(NSDate *)date2;

@end
