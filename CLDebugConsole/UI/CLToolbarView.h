// CLDebugConsole/UI/CLToolbarView.h

#import <UIKit/UIKit.h>
#import "CLDebugPluginProtocol.h"

@class CLToolbarView;

@protocol CLToolbarViewDelegate <NSObject>
- (void)toolbarView:(CLToolbarView *)toolbar didTapPlugin:(id<CLDebugPluginProtocol>)plugin;
- (void)toolbarViewDidTapMinimize:(CLToolbarView *)toolbar;
- (void)toolbarViewDidTapFullscreen:(CLToolbarView *)toolbar;
@end

@interface CLToolbarView : UIView

@property (nonatomic, weak) id<CLToolbarViewDelegate> delegate;
@property (nonatomic, assign) BOOL isFullscreen;

- (void)updatePlugins:(NSArray<id<CLDebugPluginProtocol>> *)plugins;
- (void)showFromPoint:(CGPoint)point inView:(UIView *)view;
- (void)dismiss;

@end
