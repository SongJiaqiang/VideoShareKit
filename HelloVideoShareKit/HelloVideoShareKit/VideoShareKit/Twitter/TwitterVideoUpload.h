//
//  TwitterVideoUpload.h
//  Rokk
//
//  Created by Jarvis on 10/10/2016.
//  Copyright © 2016年 Jarvis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

#define DispatchMainThread(block, ...) if(block) dispatch_async(dispatch_get_main_queue(), ^{ block(__VA_ARGS__); })

typedef void(^CbUploadComplete)(NSString* errStr);

@interface TwitterVideoUpload : NSObject

@property (nonatomic) NSString* statusContent;

@property (nonatomic, readonly) NSString* videoFileName;

@property (nonatomic) ACAccount* account;

+ (BOOL) userHasAccessToTwitter;

+ (TwitterVideoUpload*) instance;

- (BOOL) setVideo:(NSString*)videoFileName;

- (BOOL) setVideoURL:(NSURL *)videoURL;

- (BOOL) setVideoData:(NSData *)vidData;

- (BOOL) upload:(CbUploadComplete)completionHandler;
- (BOOL) uploadTweet:(NSString *)tweet completionHandlerBlock:(CbUploadComplete)completion;

@end

