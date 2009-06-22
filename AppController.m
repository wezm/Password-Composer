#import "AppController.h"
#import "WMFrontmostBrowser.h"

@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	NSStatusBar *status_bar = [NSStatusBar systemStatusBar];
	composer = [[WMPasswordComposer alloc] init];
	
	status_item = [status_bar statusItemWithLength:NSSquareStatusItemLength];
	[status_item setTitle:@"★"];
	[status_item setMenu:status_item_menu];
	
	[status_item retain];
}

- (IBAction)generatePassword:(id)sender {
	NSString *pw = [composer generatePasswordForDomain:[domain stringValue] withMasterPassword:[master_password stringValue]];
	NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSGeneralPboard];

	[pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
	[pasteboard setString:pw forType:NSStringPboardType];

	[message_label setStringValue:@"Copied"];
	[message_label setHidden:NO];

	// Cancel any other pending delayed methods
	[self performSelector:@selector(hideMessageLabel) withObject:nil afterDelay:2.0];
}

- (IBAction)getHostnameFromBrowser:(id)sender {
	WMFrontmostBrowser *browser = [[WMFrontmostBrowser alloc] init];
	
	[browser activeBrowser];
	
	[browser release];
}

- (void)hideMessageLabel {
	[message_label setHidden:YES];
}

- (void)dealloc {
	if(composer) [composer release];
	if(status_item) [status_item release];
	
	[super dealloc];
}

@end
