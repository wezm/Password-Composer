#import "AppController.h"

@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	NSStatusBar *status_bar = [NSStatusBar systemStatusBar];
	composer = [[WMPasswordComposer alloc] init];
	browser = [[WMFrontmostBrowser alloc] init];

	status_item = [status_bar statusItemWithLength:NSSquareStatusItemLength];
	[status_item setTitle:@"★"];
	[status_item setMenu:status_item_menu];
	[status_item setHighlightMode:YES];
	
	[status_item retain];
}

- (IBAction)generatePassword:(id)sender {
	NSString *pw;
	NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSGeneralPboard];

	switch([digest_method indexOfSelectedItem] + 1) // TODO make this nicer
	{
		case WMPasswordComposerMD5Digest:
			pw = [composer generateMD5PasswordForDomain:[domain stringValue] withMasterPassword:[master_password stringValue]];
			break;
		case WMPasswordComposerSHA1Digest:
			pw = [composer generateSHA1PasswordForDomain:[domain stringValue] withMasterPassword:[master_password stringValue]];
			break;
		default:
			NSLog(@"Unknown digest method selected");
			return;
	}

	[pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
	[pasteboard setString:pw forType:NSStringPboardType];

	[message_label setStringValue:@"Copied"];
	[message_label setHidden:NO];

	// Cancel any other pending delayed methods
	[self performSelector:@selector(hideMessageLabel) withObject:nil afterDelay:2.0];
}

- (IBAction)getHostnameFromBrowser:(id)sender {
	NSURL *url = [browser currentURL];
	
	if(url != nil) {
		[domain setStringValue:[url host]];
	}
}

- (IBAction)summonWindow:(id)sender {
	[self getHostnameFromBrowser:sender];
	
	if (![NSApp isActive]) {
		[NSApp activateIgnoringOtherApps:YES];
		//[NSApp arrangeInFront:nil];
	}
	[main_window makeKeyAndOrderFront:sender];
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
