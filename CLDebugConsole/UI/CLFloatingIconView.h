// CLDebugConsole/UI/CLFloatingIconView.h

#import <UIKit/UIKit.h>

@class CLFloatingIconView;

@protocol CLFloatingIconViewDelegate <NSObject>
- (void)floatingIconDidTap:(CLFloatingIconView *)iconView;
@end

@interface CLFloatingIconView : UIView

@property (nonatomic, weak) id<CLFloatingIconViewDelegate> delegate;

- (void)showInView:(UIView *)view;
- (void)hide;

@end
