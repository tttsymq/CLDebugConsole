// CLDebugConsole/UI/CLDebugWindow.h

#import <UIKit/UIKit.h>

@interface CLDebugWindow : UIWindow

+ (instancetype)sharedWindow;
- (void)makeKeyAndVisibleAboveAllWindows;

@end
