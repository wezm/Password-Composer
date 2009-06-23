//
//  WMPasswordComposer.h
//  Password Composer
//
//  Created by Wesley Moore on 16/06/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum _WMPasswordComposerDigest {
	WMPasswordComposerMD5Digest = 1,
	WMPasswordComposerSHA1Digest
} WMPasswordComposerDigest;

@interface WMPasswordComposer : NSObject {

}

- (NSString *)generateMD5PasswordForDomain:(NSString *)domain withMasterPassword:(NSString *)master_pass;
- (NSString *)generateSHA1PasswordForDomain:(NSString *)domain withMasterPassword:(NSString *)master_pass;
- (NSString *)generatePasswordForDomain:(NSString *)domain withMasterPassword:(NSString *)master_pass usingDigest:(WMPasswordComposerDigest)digest_method base64Encode:(bool)base64_encode ensureAlphnumeric:(bool)ensure_alphanumeric;

@end
