//
//  OLGhostAlertView.h
//
//  Originally created by Radu Dutzan.
//  (c) 2012 Onda.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, OLGhostAlertViewPosition) {
    OLGhostAlertViewPositionBottom,
    OLGhostAlertViewPositionCenter,
    OLGhostAlertViewPositionTop
};

typedef NS_ENUM(NSUInteger, OLGhostAlertViewStyle) {
    OLGhostAlertViewStyleDefault, // defaults to OLGhostAlertViewStyleDark
    OLGhostAlertViewStyleLight,
    OLGhostAlertViewStyleDark
};

@interface OLGhostAlertView : UIView

- (id)initWithTitle:(NSString *)title;
- (id)initWithTitle:(NSString *)title message:(NSString *)message;
- (id)initWithTitle:(NSString *)title message:(NSString *)message timeout:(NSTimeInterval)timeout dismissible:(BOOL)dismissible;
- (void)show;
- (void)showInView:(UIView *)view;
- (void)hide;

@property (nonatomic) OLGhostAlertViewPosition position;
@property (nonatomic) OLGhostAlertViewStyle style;
@property (nonatomic, copy) void (^completionBlock)(void);
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *message;
@property (nonatomic) NSTimeInterval timeout;
@property (nonatomic) BOOL dismissible;
@property (nonatomic, readonly, getter=isVisible) BOOL visible;

@end