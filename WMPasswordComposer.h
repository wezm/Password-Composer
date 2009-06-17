//
//  WMPasswordComposer.h
//  Password Composer
//
//  Created by Wesley Moore on 16/06/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WMPasswordComposer : NSObject {


}

- (NSString *)generatePasswordForDomain:(NSString *)domain withMasterPassword:(NSString *)master_pass;

@end
