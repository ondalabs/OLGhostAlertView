OLGhostAlertView
================

Temporary and unobtrusive translucent alert view for iPhone and iPad. [It looks like this.](http://cl.ly/Iuao)


Details
---------------

OLGhostAlertView allows you to present a translucent view with a title and an optional message on the bottom of the screen. Use it to inform your user about temporary issues that do not require any immediate action and are not blocking the flow of your app.

OLGhostAlertView can have a title and an optional message, in a way similar to UIAlertView. It automatically fades out after a configurable time interval and, by default, can be dismissed with a tap. It can automatically adapt its size according to the device it's being deployed on, user interface orientation and length of the strings passed to it.


Usage
---------------

First, copy the files into your project. Then, import the header file like so:

>     #import "OLGhostAlertView.h"

After that, here's how you present an OLGhostAlertView:

>     OLGhostAlertView.h *ghastly = [[OLGhostAlertView.h alloc] initWithTitle:@"I am the walrus." message: @"Sitting on a cornflake, waiting for the van to come."];
    [ghastly show];

There are three convenience methods to `init` OLGhostAlertView:


### initWithTitle:message:timeout:dismissible:

Exposes all of the available options. 

    - (id)initWithTitle:(NSString *)title message:(NSString *)message timeout:(NSTimeInterval)timeout dismissible:(BOOL)dismissible;

#### Parameters
_title_  
&nbsp;&nbsp;&nbsp;&nbsp;The string that appears in the view's title label. It is set in a bold, 17pt font.

_message_  
&nbsp;&nbsp;&nbsp;&nbsp;Descriptive text that provides more details than the title. Set in a regular, 15pt font. Can be `nil`.

_timeout_  
&nbsp;&nbsp;&nbsp;&nbsp;Amount of seconds before the view is automatically dismissed. 

_dismissible_  
&nbsp;&nbsp;&nbsp;&nbsp;Whether the view can be dismissed with a tap or not. 


### initWithTitle:message:

It's equivalent to `initWithTitle:message:timeout:dismissible:`, but assumes default values for `timeout` (6 seconds) and `dismissible` (`YES`). 

    - (id)initWithTitle:(NSString *)title message:(NSString *)message;


### initWithTitle:

It's equivalent to `initWithTitle:message:timeout:dismissible:`, but assumes default values for `message` (`nil`) `timeout` (4 seconds) and `dismissible` (`YES`). 

    - (id)initWithTitle:(NSString *)message;

You're welcome, lazy people.


License
---------------

Do whatever you want with this. If you like it, great! Let us know [on Twitter](http://twitter.com/onda_labs).


Help us make this better
---------------

We built OLGhostAlertView because we needed it for one of our projects. It's definitely not perfect (hell, it was built by a designer) and it doesn't do everything it could. If you improve it in any way, please send us a pull request. Enjoy!