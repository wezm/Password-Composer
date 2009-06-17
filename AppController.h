#import <Cocoa/Cocoa.h>
#import "WMPasswordComposer.h"

@interface AppController : NSObject {
	WMPasswordComposer *composer;
	
    IBOutlet id domain;
    IBOutlet id generate_button;
    IBOutlet id main_window;
    IBOutlet id master_password;
    IBOutlet id message_label;
}

- (IBAction)generatePassword:(id)sender;


@end
