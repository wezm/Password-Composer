#import <Cocoa/Cocoa.h>
#import "WMPasswordComposer.h"
#import "WMFrontmostBrowser.h"

@interface AppController : NSObject {
	WMPasswordComposer *composer;
	WMFrontmostBrowser *browser;
	NSStatusItem *status_item;
	
    IBOutlet id domain;
    IBOutlet id generate_button;
    IBOutlet id main_window;
    IBOutlet id master_password;
    IBOutlet id message_label;
    IBOutlet id status_item_menu;
    IBOutlet id digest_method;
}

- (IBAction)generatePassword:(id)sender;
- (IBAction)getHostnameFromBrowser:(id)sender;
- (IBAction)getDefaultBrowser:(id)sender;

@end
