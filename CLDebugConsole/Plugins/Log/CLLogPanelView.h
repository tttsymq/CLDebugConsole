// CLDebugConsole/Plugins/Log/CLLogPanelView.h

#import <UIKit/UIKit.h>

@interface CLLogPanelView : UIView

- (void)refreshLogs;
- (void)setDisplayMode:(BOOL)isDetailed;

@end
