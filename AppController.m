#import "AppController.h"
#import "WMFrontmostBrowser.h"

@implementation AppController

- (id)init {
	if((self = [super init]) != nil) {
		composer = [[WMPasswordComposer alloc] init];
	}
	
	return self;
}

- (IBAction)generatePassword:(id)sender {
	NSString *pw = [composer generatePasswordForDomain:[domain stringValue] withMasterPassword:[master_password stringValue]];
	NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSGeneralPboard];

	[pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
	[pasteboard setString:pw forType:NSStringPboardType];

	[message_label setStringValue:@"Copied"];
	[message_label setHidden:NO];

	WMFrontmostBrowser *browser = [[WMFrontmostBrowser alloc] init];
	[browser activeBrowser];
	[browser release];
	
	// Cancel any other pending delayed methods
	[self performSelector:@selector(hideMessageLabel) withObject:nil afterDelay:2.0];
}

- (void)hideMessageLabel {
	[message_label setHidden:YES];
	NSLog(@"hideMessageLobel");
}

- (void)dealloc {
	[composer release];
	
	[super dealloc];
}

@end
