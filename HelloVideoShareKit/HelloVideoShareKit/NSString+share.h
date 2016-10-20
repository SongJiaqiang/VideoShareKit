//
//  NSString+x.h
//  HelloVideoShareKit
//
//  Created by Jarvis on 20/10/2016.
//  Copyright © 2016 Jarvis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (share)

- (NSString *) MD5;

-(NSString*) URLEncodedString;

-(NSString*) URLDecodedString;

-(int) hexIntValue;

@end
