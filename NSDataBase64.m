//
//  NSDataBase64.m
//  Password Composer
//
//  Created by Wesley Moore on 16/06/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <openssl/bio.h>
#import <openssl/evp.h>

#import "NSDataBase64.h"

// Adapted from http://www.cocoadev.com/index.pl?BaseSixtyFour

@implementation NSData (Base64)

- (NSString *)stringWithBase64Encoding;
{
    return [self stringWithBase64EncodingUsingNewlines:NO];
}

- (NSString *)stringWithBase64EncodingUsingNewlines:(BOOL)encodeWithNewlines;
{
    // Create a memory buffer which will contain the Base64 encoded string
    BIO * mem = BIO_new(BIO_s_mem());
    
    // Push on a Base64 filter so that writing to the buffer encodes the data
    BIO * b64 = BIO_new(BIO_f_base64());
    if (!encodeWithNewlines)
        BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL);
    mem = BIO_push(b64, mem);
    
    // Encode all the data
    BIO_write(mem, [self bytes], [self length]);
    BIO_flush(mem);
    
    // Create a new string from the data in the memory buffer
	char *cp;
    long base64Length = BIO_get_mem_data(mem, &cp);
	NSAssert(base64Length >= 0, @"base64length < 0");
	
    char * base64Pointer = malloc(sizeof(char) * base64Length + 1);
	NSAssert(base64Pointer != NULL, @"Out of memory");
	
	// Have to dup string make it NULL terminated
	// http://archives.seul.org/or/cvs/Jan-2005/msg00049.html
	memcpy(base64Pointer, cp, base64Length);
	base64Pointer[base64Length] = '\0';
		
    NSString * base64String = [NSString stringWithCString:base64Pointer encoding:NSASCIIStringEncoding];
    free(base64Pointer);
	
    // Clean up and go home
    BIO_free_all(mem);
    return [base64String retain];
}

@end
