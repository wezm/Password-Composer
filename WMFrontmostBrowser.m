//
//  WMFrontmostBrowser.m
//  Password Composer
//
//  Created by Wesley Moore on 21/06/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WMFrontmostBrowser.h"

static NSDictionary *browsers = nil;

@implementation WMFrontmostBrowser

- (id)init {
	if((self = [super init]) != nil) {
		if(!browsers) {
			// Initialise the static list of browsers
			NSArray *bundle_identifiers = [NSArray arrayWithObjects:@"com.apple.Safari",
										   @"org.mozilla.firefox",
										   @"org.mozilla.camino",
										   @"com.google.Chrome",
										   @"com.operasoftware.Opera",
										   // @"org.mozilla.minefield",
										   // Floss
										   // That Japanese one
										   @"org.chromium.Chromium",
										   @"org.webkit.nightly.WebKit",
										   nil];
			NSArray *browser_names = [NSArray arrayWithObjects:@"Safari",
									  @"Firefox",
									  @"Camino",
									  @"Google Chrome",
									  @"Opera",
									  @"Chromium",
									  @"WebKit",
									  nil];
			browsers = [[NSDictionary alloc] initWithObjects:browser_names forKeys:bundle_identifiers];
		}
	}
	
	return self;
}

- (NSDictionary *)activeBrowser {
	NSString *bundle_id;
	NSString *browser;
	NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
	NSDictionary *activeApp = [workspace activeApplication];
	NSAssert(activeApp != nil, @"activeApplication is nil");
	
	bundle_id = [activeApp objectForKey:@"NSApplicationBundleIdentifier"];
	NSAssert(bundle_id != nil, @"activeApplication NSApplicationBundleIdentifier is nil");
	
	if((browser = [browsers objectForKey:bundle_id]) != nil) {
		NSLog(@"Active App is a browser: %@", browser);
	}
	
	return activeApp;
}


@end
