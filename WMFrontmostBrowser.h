//
//  WMFrontmostBrowser.h
//  Password Composer
//
//  Created by Wesley Moore on 21/06/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

#define WMPasswordComposerHandlerName @"WMPasswordComposerHandlerName"

@interface WMFrontmostBrowser : NSObject {
	NSAppleScript *browser_script;
}

- (NSDictionary *)activeBrowser;
- (NSURL *)currentURL;

@end
