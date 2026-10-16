// CLDebugConsole/Utils/CLDebugDateFormatter.m

#import "CLDebugDateFormatter.h"

@implementation CLDebugDateFormatter

static NSDateFormatter *_dailyFormatter(void) {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    });
    return formatter;
}

+ (NSString *)dailyFileNameForDate:(NSDate *)date {
    return [_dailyFormatter() stringFromDate:date];
}

+ (NSDate *)dateFromDailyFileName:(NSString *)fileName {
    NSString *name = [fileName stringByReplacingOccurrencesOfString:@".log" withString:@""];
    return [_dailyFormatter() dateFromString:name];
}

+ (NSDate *)startOfDay:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [calendar dateFromComponents:components];
}

+ (NSDate *)endOfDay:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *startOfNextDay = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:[self startOfDay:date] options:0];
    return [startOfNextDay dateByAddingTimeInterval:-1];
}

+ (BOOL)isSameDay:(NSDate *)date1 date2:(NSDate *)date2 {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar isDate:date1 inSameDayAsDate:date2];
}

@end
