// CLDebugConsole/Utils/CLDebugFileManager.m

#import "CLDebugFileManager.h"
#import "CLDebugDateFormatter.h"

@implementation CLDebugFileManager

+ (NSString *)logDirectory {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [documentsPath stringByAppendingPathComponent:@"CLDebugLogs"];
}

+ (NSString *)filePathForDate:(NSDate *)date {
    NSString *fileName = [NSString stringWithFormat:@"%@.log", [CLDebugDateFormatter dailyFileNameForDate:date]];
    return [[self logDirectory] stringByAppendingPathComponent:fileName];
}

+ (NSArray<NSString *> *)availableLogFiles {
    NSString *directory = [self logDirectory];
    NSFileManager *fm = [NSFileManager defaultManager];

    if (![fm fileExistsAtPath:directory]) {
        return @[];
    }

    NSArray *files = [fm contentsOfDirectoryAtPath:directory error:nil];
    NSMutableArray *logFiles = [NSMutableArray array];

    for (NSString *file in files) {
        if ([file hasSuffix:@".log"]) {
            [logFiles addObject:[directory stringByAppendingPathComponent:file]];
        }
    }

    [logFiles sortUsingSelector:@selector(compare:)];
    return [logFiles copy];
}

+ (BOOL)appendString:(NSString *)string toFile:(NSString *)filePath error:(NSError **)error {
    [self createDirectoryIfNeeded:[filePath stringByDeletingLastPathComponent]];

    NSData *data = [[string stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding];

    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return [data writeToFile:filePath options:NSDataWritingAtomic error:error];
    }

    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    if (!handle) {
        if (error) {
            *error = [NSError errorWithDomain:@"CLDebugConsole" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Failed to open file"}];
        }
        return NO;
    }

    [handle seekToEndOfFile];
    [handle writeData:data];
    [handle closeFile];
    return YES;
}

+ (void)deleteFilesOlderThanDays:(NSUInteger)days inDirectory:(NSString *)directory {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *files = [fm contentsOfDirectoryAtPath:directory error:nil];
    NSDate *cutoffDate = [NSDate dateWithTimeIntervalSinceNow:-(days * 24 * 60 * 60)];

    for (NSString *file in files) {
        if (![file hasSuffix:@".log"]) continue;

        NSString *fullPath = [directory stringByAppendingPathComponent:file];
        NSDate *fileDate = [CLDebugDateFormatter dateFromDailyFileName:file];

        if (fileDate && [fileDate compare:cutoffDate] == NSOrderedAscending) {
            [fm removeItemAtPath:fullPath error:nil];
        }
    }
}

+ (BOOL)createDirectoryIfNeeded:(NSString *)directoryPath {
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:directoryPath]) {
        return [fm createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return YES;
}

@end
