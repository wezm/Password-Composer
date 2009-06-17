#import "AppController.h"
#import "WMPasswordComposer.h"

@implementation AppController

- (IBAction)generatePassword:(id)sender {
    WMPasswordComposer *composer = [[WMPasswordComposer alloc] init];
	
	NSLog(@"Password %@", [composer generatePasswordForDomain:[domain stringValue] withMasterPassword:[master_password stringValue]]);
	
	[composer release];
}

@end
