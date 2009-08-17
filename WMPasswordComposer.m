//
//  WMPasswordComposer.m
//  Password Composer
//
//  Created by Wesley Moore on 16/06/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "WMPasswordComposer.h"
#import "NSDataBase64.h"
#import "BNZHex.h"

@implementation WMPasswordComposer

- (NSString *)generateMD5PasswordForDomain:(NSString *)domain withMasterPassword:(NSString *)master_pass
{
	return [self generatePasswordForDomain:domain withMasterPassword:master_pass usingDigest:WMPasswordComposerMD5Digest base64Encode:NO ensureAlphnumeric:NO];
}

- (NSString *)generateSHA1PasswordForDomain:(NSString *)domain withMasterPassword:(NSString *)master_pass
{
	return [self generatePasswordForDomain:domain withMasterPassword:master_pass usingDigest:WMPasswordComposerSHA1Digest base64Encode:YES ensureAlphnumeric:YES];
}

- (NSString *)generatePasswordForDomain:(NSString *)domain withMasterPassword:(NSString *)master_pass usingDigest:(WMPasswordComposerDigest)digest_method base64Encode:(bool)base64_encode ensureAlphnumeric:(bool)ensure_alphanumeric;
{
	const char *data;
	NSData *result;
	NSString *string_data = [NSString stringWithFormat:@"%@:%@", master_pass, domain];
	NSMutableString *password;
	
	data = [string_data UTF8String];
	switch(digest_method) {
		case WMPasswordComposerMD5Digest:
			result = [[self class] md5:data];
			break;
		case WMPasswordComposerSHA1Digest:
			result = [[self class] sha1:data];
			break;
		default:
			NSLog(@"generatePasswordForDomain: Unknown digest type");
			return nil;
	}

	if(base64_encode) {
		password = [NSMutableString stringWithString:[result stringWithBase64Encoding]];
	}
	else {
		password = [NSMutableString stringWithString:[result hexString]];
	}

	NSRange truncate_range = NSMakeRange(WMPasswordComposerBaseLen, [password length] - WMPasswordComposerBaseLen);
	[password deleteCharactersInRange:truncate_range];
	
	if(ensure_alphanumeric) [password appendString:@"1a"];
	
	return password;
}

// This is ugly and should be a category or a protocol and classes or something
+ (NSData *)md5:(const char *)data {
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5(data, strlen(data), digest);
	return [NSData dataWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
}

+ (NSData *)sha1:(const char *)data {
	unsigned char digest[CC_SHA1_DIGEST_LENGTH];

	CC_SHA1(data, strlen(data), digest);
	return [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
}


@end
