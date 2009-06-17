#import "AppController.h"
#import "WMPasswordComposer.h"

@implementation AppController

- (IBAction)generatePassword:(id)sender {
    WMPasswordComposer *composer = [[WMPasswordComposer alloc] init];
	NSString *pw = [composer generatePasswordForDomain:[domain stringValue] withMasterPassword:[master_password stringValue]];
	NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSGeneralPboard];

	[pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
	[pasteboard setString:pw forType:NSStringPboardType];

	[message_label setStringValue:@"Copied"];
	[message_label setHidden:NO];
	
	[composer release];
}

@end
