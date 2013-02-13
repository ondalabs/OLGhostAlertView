# OLGhostAlertView

Temporary and unobtrusive translucent alert view for iPhone and iPad. Here's what it looks like: [iPad](http://cl.ly/Iuao) / [iPhone](http://cl.ly/IvD7)


## Details

OLGhostAlertView allows you to present a translucent view with a title and an optional message on the bottom of the screen. Use it to inform your user about temporary issues that do not require any immediate action and are not blocking the flow of your app.

OLGhostAlertView can have a title and an optional message, in a way similar to UIAlertView. It automatically fades out after a configurable time interval and, by default, can be dismissed with a tap. It can automatically adapt its size according to the device it's being deployed on, user interface orientation and length of the strings passed to it.


## Usage

OLGhostAlertView requires that you include the QuartzCore.framework in your project. Once you have done that, add the OLGhostAlertView files to your project and import the header in the file where you'll be using it, like so:

    #import "OLGhostAlertView.h"

After that, here's how you present an OLGhostAlertView:

    OLGhostAlertView *ghastly = [[OLGhostAlertView alloc] initWithTitle:@"I am the walrus." message: @"Sitting on a cornflake, waiting for the van to come."];
    [ghastly show];

Just like with UIAlertView, the dismissal of the view is handled by the view itself, so there's no need to call anything else. If you do want to dismiss it manually, just call `hide` on the instance.

OLGhostAlertView has to be `show`n in or after `viewDidAppear:` is invoked on the Root View Controller. If you attempt to call `show` before that, the instance may not be visible on the screen.

### Init methods


#### initWithTitle:message:timeout:dismissible:

Exposes all of the available options. 

    - (id)initWithTitle:(NSString *)title message:(NSString *)message timeout:(NSTimeInterval)timeout dismissible:(BOOL)dismissible;

##### Parameters
_title_  
&nbsp;&nbsp;&nbsp;&nbsp;The string that appears in the view's title label. It is set in a bold, 17pt font.

_message_  
&nbsp;&nbsp;&nbsp;&nbsp;Descriptive text that provides more details than the title. Set in a regular, 15pt font. Can be `nil`.

_timeout_  
&nbsp;&nbsp;&nbsp;&nbsp;Amount of seconds before the view is automatically dismissed. 

_dismissible_  
&nbsp;&nbsp;&nbsp;&nbsp;Whether the view can be dismissed with a tap or not. 


#### initWithTitle:message:

Equivalent to `initWithTitle:message:timeout:dismissible:`, but assumes default values for `timeout` (`6` seconds) and `dismissible` (`YES`). 

    - (id)initWithTitle:(NSString *)title message:(NSString *)message;


#### initWithTitle:

Equivalent to `initWithTitle:message:timeout:dismissible:`, but assumes default values for `message` (`nil`) `timeout` (`4` seconds) and `dismissible` (`YES`). 

    - (id)initWithTitle:(NSString *)title;

You're welcome, lazy people.

### Properties

#### position
The vertical position of the view.

	@property (nonatomic, strong) OLGhostAlertViewPosition position;

This property controls the origin of the view on the Y axis.

The default value is `OLGhostAlertViewPositionBottom`.

#### bgOpacity
The opacity of the background color.

	@property (nonatomic) float bgOpacity;

This property controls alpha property for the backgroundColor of the view.

The default value is 0.45.

#### completionBlock
A block to execute after the instance has been dismissed.

	@property (nonatomic, copy) void (^completionBlock)(void);


Known Issues
---------------

Here are some current limitations in OLGhostAlertView:

 - Adding an OLGhostAlertView while displaying a keyboard will cause it to be placed under the keyboard ([#3](https://github.com/ondalabs/OLGhostAlertView/issues/3)). This can be worked around using the `position` property. 
Another way to go around this is described on leberwurstsaft's [comment on the issue](https://github.com/ondalabs/OLGhostAlertView/issues/3#issuecomment-9201846).
 - If interacting with a UIScrollView, OLGhostAlertView doesn't `hide` until touch tracking actions are complete ([#7](https://github.com/ondalabs/OLGhostAlertView/issues/7)). A workaround is available on the issue thread.
 
You can find an up-to-date list with full descriptions and discussion at [the Issues page](https://github.com/ondalabs/OLGhostAlertView/issues).


Help us make this better
---------------

We built OLGhostAlertView because we needed it for one of our projects. It's definitely not perfect (hell, it was built by a designer) and it doesn't do everything it could. If you improve it in any way, please send us a pull request. Enjoy!
