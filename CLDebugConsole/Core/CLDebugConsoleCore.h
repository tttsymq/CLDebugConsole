// CLDebugConsole/Core/CLDebugConsole.h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CLDebugPluginProtocol.h"

@interface CLDebugConsole : NSObject

+ (instancetype)sharedConsole;

- (void)start;
- (void)stop;

- (void)registerPlugin:(id<CLDebugPluginProtocol>)plugin;
- (void)unregisterPlugin:(NSString *)pluginName;
- (NSArray<id<CLDebugPluginProtocol>> *)registeredPlugins;

- (void)show;
- (void)hide;

@end
