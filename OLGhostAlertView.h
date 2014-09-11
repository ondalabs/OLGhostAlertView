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

/**
 Equivalent to `initWithTitle:message:timeout:dismissible:`, but assumes default values for `message` (nil) `timeout` (4 seconds) and `dismissible` (YES).
 @param title The string that appears in the view's title label.
 */
- (id)initWithTitle:(NSString *)title;

/**
 Equivalent to `initWithTitle:message:timeout:dismissible:`, but assumes default values for `timeout` (6 seconds) and `dismissible` (YES).
 @param title The string that appears in the view's title label.
 @param message Descriptive text that provides more details than the title. Can be nil.
 */
- (id)initWithTitle:(NSString *)title message:(NSString *)message;

/**
 Initializes a new OLGhostAlertView instance.
 @param title The string that appears in the view's title label.
 @param message Descriptive text that provides more details than the title. Can be nil.
 @param timeout Time interval before the alert is automatically dismissed.
 @param dismissible Whether the alert can be dismissed with a tap or not.
 */
- (id)initWithTitle:(NSString *)title message:(NSString *)message timeout:(NSTimeInterval)timeout dismissible:(BOOL)dismissible;

/**
 Shows the OLGhostAlertView on top of the frontmost view controller.
 */
- (void)show;

/**
 Shows the OLGhostAlertView on top of the given `view`.
 */
- (void)showInView:(UIView *)view;

/**
 Hides the OLGhostAlertView.
 */
- (void)hide;


/**
 The vertical position of the view. 
 
 The default value is `OLGhostAlertViewPositionBottom`.
 */
@property (nonatomic) OLGhostAlertViewPosition position;

/**
 The visual style of the view.
 
 The view can have either light text on a dark background (`OLGhostAlertViewStyleDark`) or dark text over a light background (`OLGhostAlertViewStyleLight`).
 
 The default value is `OLGhostAlertViewStyleDefault`, which maps to `OLGhostAlertViewStyleLight`.
 */
@property (nonatomic) OLGhostAlertViewStyle style;

/**
 A margin that prevents the alert from drawing above it.
 */
@property (nonatomic) CGFloat topContentMargin;

/**
 A margin that prevents the alert from drawing below it.
 */
@property (nonatomic) CGFloat bottomContentMargin;

/**
 A block to execute after the instance has been dismissed.
 */
@property (nonatomic, copy) void (^completionBlock)(void);

/**
 The string that appears in the title of the alert.
 */
@property (nonatomic) NSString *title;

/**
 Descriptive text that provides more details than the title.
 */
@property (nonatomic) NSString *message;

/**
 The label that displays the title.
 */
@property (nonatomic, strong) UILabel *titleLabel;

/**
 The label that displays the message.
 */
@property (nonatomic, strong) UILabel *messageLabel;

/**
 Time interval before the alert is automatically dismissed.
 */
@property (nonatomic) NSTimeInterval timeout;

/**
 Whether the alert can be dismissed with a tap or not.
 */
@property (nonatomic) BOOL dismissible;

/**
 A Boolean value that indicates whether the view is currently visible on the screen.
 */
@property (nonatomic, readonly, getter=isVisible) BOOL visible;

@end