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
	NSString *bundle_id;
	NSString *scripting_handler_name;
	NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
	NSDictionary *activeApp = [workspace activeApplication];
	NSMutableDictionary *active_browser;
	NSAssert(activeApp != nil, @"activeApplication is nil");
	
	bundle_id = [activeApp objectForKey:@"NSApplicationBundleIdentifier"];
	NSAssert(bundle_id != nil, @"activeApplication NSApplicationBundleIdentifier is nil");

	scripting_handler_name = [browsers objectForKey:bundle_id];
	if(scripting_handler_name == nil) return nil; // Unknown app or no handler

	active_browser = [NSMutableDictionary dictionaryWithDictionary:activeApp];
	[active_browser setObject:scripting_handler_name forKey:WMPasswordComposerHandlerName];
	
	return active_browser;
}

- (NSURL *)currentURL
{
	NSAppleEventDescriptor *result;
	NSDictionary *errors;
	NSDictionary *browser = [self activeBrowser];
	
	if(browser == nil) return nil; // No browser running
	
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
