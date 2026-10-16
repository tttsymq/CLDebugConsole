// CLDebugConsole/Core/CLDebugPluginProtocol.h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol CLDebugPluginProtocol <NSObject>

@required
@property (nonatomic, readonly) NSString *pluginName;
@property (nonatomic, readonly) UIImage *pluginIcon;
@property (nonatomic, readonly) UIView *pluginView;

@optional
- (void)pluginDidLoad;
- (void)pluginWillUnload;
- (void)pluginDidActivate;
- (void)pluginDidDeactivate;

@end
