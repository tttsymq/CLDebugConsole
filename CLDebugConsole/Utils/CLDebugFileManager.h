// CLDebugConsole/Utils/CLDebugFileManager.h

#import <Foundation/Foundation.h>

@interface CLDebugFileManager : NSObject

+ (NSString *)logDirectory;
+ (NSString *)filePathForDate:(NSDate *)date;
+ (NSArray<NSString *> *)availableLogFiles;
+ (BOOL)appendString:(NSString *)string toFile:(NSString *)filePath error:(NSError **)error;
+ (void)deleteFilesOlderThanDays:(NSUInteger)days inDirectory:(NSString *)directory;
+ (BOOL)createDirectoryIfNeeded:(NSString *)directoryPath;

@end
