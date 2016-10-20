//
//  NSString+share.m
//  HelloVideoShareKit
//
//  Created by Jarvis on 20/10/2016.
//  Copyright © 2016 Jarvis. All rights reserved.
//

#import "NSString+share.h"


#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import <CommonCrypto/CommonDigest.h>

@implementation NSString (share)


- (NSString *) MD5
{
    const char *cStr = [self UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  [output uppercaseString];
    
}

-(NSString *) URLEncodedString {
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(__bridge CFStringRef)self,NULL, CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                             kCFStringEncodingUTF8));
    return result;
}

-(NSString*) URLDecodedString {
    char words[self.length];
    int k = 0;
    
    for (int i = 0; i < self.length; i++, k++) {
        unichar ch = [self characterAtIndex:i];
        if (ch == '%') {
            NSString* s = [self substringWithRange:NSMakeRange(i+1, 2)];
            int n = [s hexIntValue];
            if (n >= 128) {
                n -= 256;
            }
            words[k] = n;
            i += 2;
        } else {
            words[k] = ch;
        }
    }
    
    words[k] = 0;
    
    return [NSString stringWithUTF8String:words];
}

-(int) hexIntValue {
    NSString* hex = [self lowercaseString];
    if ([hex hasPrefix:@"0x"]) {
        hex = [hex substringFromIndex:2];
    }
    int ret = 0;
    const char* ch = [hex UTF8String];
    int length = (int)hex.length;
    for (int i = length - 1; i >= 0; i--) {
        if (ch[i] >= '0' && ch[i] <= '9') {
            ret += (ch[i] - '0') * powf(16, (length - 1 - i));
        } else if(ch[i] >= 'a' && ch[i] <= 'f') {
            ret += (ch[i] - 'a' + 10) * powf(16, (length - 1 - i));
        }
    }
    return ret;
}


@end
