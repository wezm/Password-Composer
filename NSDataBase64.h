//
//  NSDataBase64.h
//  Password Composer
//
//  Created by Wesley Moore on 16/06/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSData (Base64)

- (NSString *)stringWithBase64Encoding;
- (NSString *)stringWithBase64EncodingUsingNewlines:(BOOL)encodeWithNewlines;

@end
