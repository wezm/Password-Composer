//
//  WMFrontmostBrowser.m
//  Password Composer
//
//  Created by Wesley Moore on 21/06/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WMFrontmostBrowser.h"
#import <stdlib.h>
#import <string.h>

static NSDictionary *browsers = nil;

@implementation WMFrontmostBrowser

- (id)init {
	if((self = [super init]) != nil) {
		if(!browsers) {
			// Initialise the static list of browsers
			NSArray *bundle_identifiers = [NSArray arrayWithObjects:@"com.apple.Safari",
										   // @"org.mozilla.firefox",
										   @"org.mozilla.camino",
										   // @"com.google.Chrome",
										   //@"com.operasoftware.Opera",
										   // @"org.mozilla.minefield",
										   // Flock
										   // Shiira
										   //@"org.chromium.Chromium",
										   @"org.webkit.nightly.WebKit",
										   nil];
			NSArray *browser_names = [NSArray arrayWithObjects:@"getCurrentSafariUrl",
									  //@"Firefox",
									  @"getCurrentCaminoUrl",
									  //@"Google Chrome",
									  //@"Opera",
									  //@"Chromium",
									  @"getCurrentSafariUrl", // WebKit
									  nil];
			browsers = [[NSDictionary alloc] initWithObjects:browser_names forKeys:bundle_identifiers];
		}
		
		// Load the browser AppleScript
		NSDictionary *errors;
		NSBundle *mainBundle = [NSBundle mainBundle];
		NSAssert(mainBundle != nil, @"Unable to get mainBundle");
		
		NSString *scriptPath = [mainBundle pathForResource:@"Browser Scripting"
													ofType:@"scpt"
											   inDirectory:@"Scripts"];
		NSAssert(scriptPath != nil, @"Path to Browser.scpt is nil");
		NSURL *script_url = [NSURL fileURLWithPath:scriptPath];
		NSAssert(script_url != nil, @"script_url is nil");
		browser_script = [[NSAppleScript alloc] initWithContentsOfURL:script_url error:&errors];
		NSAssert1(browser_script != nil, @"Error loading browser scripting %@", errors);
	}
	
	return self;
}

// Runs an AppleScript handler
// Adapted from code available from:
// http://developer.apple.com/technotes/tn2006/tn2084.html
// http://developer.apple.com/qa/qa2001/qa1111.html
- (NSAppleEventDescriptor *)executeASHandler:(NSString *)handler
							   withArguments:(NSAppleEventDescriptor *)arguments
								   onProcess:(NSDictionary *)process
									   error:(NSDictionary **)errorInfo
{
    NSAppleEventDescriptor* event; 
    NSAppleEventDescriptor* targetAddress; 
    NSAppleEventDescriptor* subroutineDescriptor; 
    NSAppleEventDescriptor* result;
	ProcessSerialNumber psn;
	NSNumber *number;
	BOOL argumentsIsOurs = NO;
	
	if(process == nil || handler == nil) return nil;
	
	// Create the target address for the AppleEvent
	number = [process objectForKey:@"NSApplicationProcessSerialNumberHigh"];
	NSAssert(number != nil, @"NSApplicationProcessSerialNumberHigh is nil");	
	psn.highLongOfPSN = [number unsignedLongValue];
	
	number = [process objectForKey:@"NSApplicationProcessSerialNumberLow"];
	NSAssert(number != nil, @"NSApplicationProcessSerialNumberLow is nil");	
	psn.lowLongOfPSN  = [number unsignedLongValue];
	
    targetAddress = [[NSAppleEventDescriptor alloc]
					 initWithDescriptorType:typeProcessSerialNumber
					 bytes:&psn
					 length:sizeof(psn)];
	NSAssert(targetAddress != nil, @"targetAddress is nil");
	
    // Create the AppleEvent
    event = [[NSAppleEventDescriptor alloc] initWithEventClass:'ascr'
													   eventID:kASSubroutineEvent
											  targetDescriptor:targetAddress
													  returnID:kAutoGenerateReturnID
												 transactionID:kAnyTransactionID];
    
    // Add the list of arguments if given
	if(nil == arguments) {
		// No arguments passed, create empty list
		arguments = [[NSAppleEventDescriptor alloc] initListDescriptor];
		argumentsIsOurs = YES;
	}
	NSAssert(arguments != nil, @"argument descriptor list is nil");
    [event setParamDescriptor:arguments forKeyword:keyDirectObject];
    
    // Add handler name
    subroutineDescriptor = [NSAppleEventDescriptor descriptorWithString:[handler lowercaseString]];
    [event setParamDescriptor:subroutineDescriptor forKeyword:keyASSubroutineName];
	
    /* Execute the handler */
    result = [browser_script executeAppleEvent:event error:errorInfo];
    [targetAddress release];
    [event release];
    if(argumentsIsOurs) [arguments release];
	
    return result;
}


- (NSDictionary *)activeBrowser {
	NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
	NSDictionary *activeApp = [workspace activeApplication];
	
	return [self addHandlerNameForBrowser:activeApp];
}

- (NSDictionary *)defaultBrowser {
//	NSURL *appURL = nil;
	CFURLRef default_browser_url = NULL;
	NSString *default_browser_path;
    OSStatus err;
	NSEnumerator *processesEnum;
	NSDictionary *process;
	char default_browser_abs_path[PATH_MAX];
	char application_abs_path[PATH_MAX];
	
    err = LSGetApplicationForURL((CFURLRef)[NSURL URLWithString: @"http:"],
								 kLSRolesAll, NULL, &default_browser_url);

	if (err != noErr) {
		NSLog(@"LSGetApplicationForURL error: %ld", err);
		return nil;
	}
	
	// Get filesystem path from URL
	default_browser_path = (NSString *)CFURLCopyFileSystemPath(default_browser_url, kCFURLPOSIXPathStyle);
	NSAssert(default_browser_path != nil, @"default_browser_path is nil");
	if(realpath([default_browser_path UTF8String], default_browser_abs_path) == NULL) {
		NSLog(@"realpath(%@) == NULL", [default_browser_path UTF8String]);
		return nil;
	}
	
	// appURL autoreleased?
	NSLog(default_browser_path);
	processesEnum = [[[NSWorkspace sharedWorkspace] launchedApplications] objectEnumerator];
	while ((process = [processesEnum nextObject])) {
		NSString *applicationPath = [process objectForKey:@"NSApplicationPath"];
		if(realpath([applicationPath UTF8String], application_abs_path) == NULL) {
			//NSLog(@"realpath(%@) == NULL", [applicationPath UTF8String]);
			return nil;
		}
		
		// Got the normalised paths to the default browser and the application,
		// see if they are the same
		if(strcmp(application_abs_path, default_browser_abs_path) == 0) {
			// Found default browser
			break;
		}
	}
	
	return [self addHandlerNameForBrowser:process];
}

- (NSDictionary *)addHandlerNameForBrowser:(NSDictionary *)browser {
	NSMutableDictionary *browser_with_handler;
	NSString *bundle_id;
	NSString *scripting_handler_name;

	if(browser == nil) return browser;
	
	bundle_id = [browser objectForKey:@"NSApplicationBundleIdentifier"];
	NSAssert(bundle_id != nil, @"addHandlerNameForBrowser NSApplicationBundleIdentifier is nil");
	
	scripting_handler_name = [browsers objectForKey:bundle_id];
	if(scripting_handler_name == nil) return nil; // Unknown app or no handler
	
	browser_with_handler = [NSMutableDictionary dictionaryWithDictionary:browser];
	[browser_with_handler setObject:scripting_handler_name forKey:WMPasswordComposerHandlerName];
	
	return [NSDictionary dictionaryWithDictionary:browser_with_handler];
}

- (NSURL *)currentURL
{
	NSAppleEventDescriptor *result;
	NSDictionary *errors = nil;
	NSDictionary *browser = [self activeBrowser];
	
	if(browser == nil) {
		// See if the default browser is running and use that instead
		browser = [self defaultBrowser];
	}
		
	if(browser == nil) {
		return nil; // No browser running
	}
	
	// Construct the argument to the handler
	NSAppleEventDescriptor *browser_name = [NSAppleEventDescriptor descriptorWithString:[browser objectForKey:@"NSApplicationName"]];
	NSAppleEventDescriptor *args = [NSAppleEventDescriptor listDescriptor];
	[args insertDescriptor:browser_name atIndex:1];
	
	result = [self executeASHandler:[browser objectForKey:WMPasswordComposerHandlerName] 
					  withArguments:args
						  onProcess:browser
							  error:&errors];
	if(nil == result) {
		if(errors != nil) {
			NSLog(@"currentURL Error: %@", [errors description]);
		} else {
			NSLog(@"result was nil and so was errors");
		}
		return nil;
	}
	
	// Extract the string from the result
	//NSLog(@"result descriptorType = %ud", [result descriptorType]);
	if(typeUnicodeText != [result descriptorType]) return nil; /// Not the expected type (could be typeNull)

	return [NSURL URLWithString:[result stringValue]];
}

@end
