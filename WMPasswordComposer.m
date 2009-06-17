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

@implementation WMPasswordComposer

- (NSString *)generatePasswordForDomain:(NSString *)domain withMasterPassword:(NSString *)master_pass
{
	const char *data;
	NSData *result;
	unsigned char sha1[CC_SHA1_DIGEST_LENGTH];
	NSString *string_data = [NSString stringWithFormat:@"%@:%@", master_pass, domain];
	NSString *password;
	
	data = [string_data UTF8String];
	CC_SHA1(data, strlen(data), sha1);

	result = [NSData dataWithBytes:sha1 length:CC_SHA1_DIGEST_LENGTH];
	password = [[[result stringWithBase64Encoding] substringWithRange:NSMakeRange(0, 8)] stringByAppendingString:@"1e"];
	
	return [password retain];
}

@end
