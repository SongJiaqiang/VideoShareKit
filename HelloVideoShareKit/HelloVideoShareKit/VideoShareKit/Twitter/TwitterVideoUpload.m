//
//  TwitterVideoUpload.m
//  Rokk
//
//  Created by Jarvis on 10/10/2016.
//  Copyright © 2016年 Jarvis. All rights reserved.
//


#import "TwitterVideoUpload.h"

@interface TwitterVideoUpload ()
{
    NSData* videoData;
    NSString* mediaID;
    NSURL* twitterPostURL;
    NSURL* twitterUpdateURL;
    CbUploadComplete completionHandler;
    
    NSMutableArray* paramList;
}

@end


@implementation TwitterVideoUpload

static TwitterVideoUpload *sInstance = nil;

+ (TwitterVideoUpload*) instance {
    if (sInstance == nil) {
        sInstance = [TwitterVideoUpload new];
        [sInstance initialize];
    }
    return sInstance;
}

#define KB (1<<10)
#define MB (1<<20)
#define VIDEO_CHUNK_SIZE 5000000
#define MAX_VIDEO_SIZE (15 * MB)

- (void) initialize {
    twitterPostURL = [[NSURL alloc] initWithString:@"https://upload.twitter.com/1.1/media/upload.json"];
    twitterUpdateURL = [[NSURL alloc] initWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
    paramList = [NSMutableArray arrayWithCapacity:4];
}

+ (BOOL) userHasAccessToTwitter {
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void) getAccount:(BOOL)toSendVideo {
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [account requestAccessToAccountsWithType:accountType options:nil
                                  completion:^(BOOL granted, NSError *error)
     {
         if (granted == YES) {
             NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
             if ([arrayOfAccounts count] > 0) {
                 ACAccount *twitterAccount = [arrayOfAccounts lastObject];
                 if (twitterAccount == nil) {
                     NSLog(@"ACAccount = nil");
                     return;
                 }
                 
                 self.account = twitterAccount;
                 
                 if (toSendVideo && paramList.count > 0)
                     [self sendCommand:0];
             }
         } else {
             NSLog(@"Access denied");
         }
     }];
}

- (ACAccount *)account {
    if (_account == nil) {
        [self getAccount:NO];
    }
    return _account;
}

- (BOOL) setVideo:(NSString *)videoFileName {
    
    if (videoFileName == nil || videoFileName.length == 0) {
        NSLog(@"Video file is not set");
        return FALSE;
    }
    _videoFileName = videoFileName;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:self.videoFileName ofType:@"mp4"];
    if (path == nil) {
        NSLog(@"File is not found");
        return FALSE;
    }
    
    return [self setVideoData:[NSData dataWithContentsOfFile:path]];
}

- (BOOL) setVideoURL:(NSURL *)videoURL{
    NSData *vidData = [NSData dataWithContentsOfURL:videoURL];
    
    return [self setVideoData:vidData];
}

- (BOOL) setVideoData:(NSData *)vidData {
    
    videoData = vidData;
    if (videoData == nil) {
        NSLog(@"Error while reading file");
        return FALSE;
    }
//    
//    NSLog(@"Video size: %d B = %.1f KB = %.2f MB", videoData.length, (float)videoData.length / (float)KB, (float)videoData.length / (float)MB);
    
    if (videoData.length == 0) {
        NSLog(@"Video is too small");
        return FALSE;
    }
    
    if (videoData.length > MAX_VIDEO_SIZE) {
        NSLog(@"Video is too big");
        return FALSE;
    }
    
    return TRUE;
}

- (BOOL) upload:(CbUploadComplete)completionHandlerBlock {
    
    return [self uploadTweet:@"" completionHandlerBlock:completionHandlerBlock];
}

- (BOOL) uploadTweet:(NSString *)tweet completionHandlerBlock:(CbUploadComplete)completion {
    
    self.statusContent = tweet;
    
    if ([TwitterVideoUpload userHasAccessToTwitter] == FALSE) {
        NSLog(@"No Twitter account. Please add twitter account to Settings app.");
        return FALSE;
    }
    
    completionHandler = completion;
    
    if (videoData == nil) {
        NSLog(@"No video data set");
        return FALSE;
    }
    NSString* sizeStr = @(videoData.length).stringValue;
    
    [paramList removeAllObjects];
    paramList[0] = @{@"command": @"INIT",
                     @"total_bytes" : sizeStr,
                     @"media_type" : @"video/mp4"
                     };
    
    if (self.account != nil) [self sendCommand:0];
    else [self getAccount:TRUE];
    return TRUE;
}



- (void) processInitResp:(NSData*)responseData {
    NSError* error = nil;
    NSMutableDictionary *returnedData = [NSJSONSerialization JSONObjectWithData:responseData
                                                                        options:NSJSONReadingMutableContainers error:&error];
    
    mediaID = [NSString stringWithFormat:@"%@", [returnedData valueForKey:@"media_id_string"]];
    NSLog(@"mediaID = %@", mediaID);
    
    int cmdIndex = 0;
    int segment = 0;
    for (; segment*VIDEO_CHUNK_SIZE < videoData.length; segment++) {
        paramList[++cmdIndex] = @{@"command": @"APPEND",
                                  @"media_id" : mediaID,
                                  @"segment_index" : @(segment).stringValue
                                  };
    }
    
    paramList[++cmdIndex] = @{@"command": @"FINALIZE",
                              @"media_id" : mediaID };
    
    paramList[++cmdIndex] = @{@"status": self.statusContent,
                              @"media_ids" : @[mediaID]};
}

- (void) addVideoChunk:(SLRequest*)request {
    
    NSData* videoChunk;
    
    if (videoData.length > VIDEO_CHUNK_SIZE) {
        int segment_index = [request.parameters[@"segment_index"] intValue];
        
        NSRange range = NSMakeRange(segment_index * VIDEO_CHUNK_SIZE, VIDEO_CHUNK_SIZE);
        int maxPos = (int)NSMaxRange(range);
        if (maxPos >= videoData.length) {
            range.length = videoData.length - range.location;
        }
        videoChunk = [videoData subdataWithRange:range];
        NSLog(@"\tsegment_index %d: loc=%lu len=%lu", segment_index, range.location, range.length);
    } else {
        videoChunk = videoData;
    }
    
    [request addMultipartData:videoChunk withName:@"media" type:@"video/mp4" filename:@"video"];
}

- (void) sendCommand:(int)i {
    
    if (i >= paramList.count) {
        NSLog(@"Invalid command index %d", i);
        return;
    }
    
    NSDictionary* postParams = paramList[i];
    NSURL* url = (i == paramList.count-1 && i > 0) ? twitterUpdateURL : twitterPostURL;
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST
                                                      URL:url
                                               parameters:postParams];
    request.account = self.account;
    
    NSString* cmdStr = postParams[@"command"];
    if (cmdStr == nil) cmdStr = @"";
    NSLog(@"%d >> %@", i, cmdStr);
    
    if ([cmdStr isEqualToString:@"APPEND"]) {
        [self addVideoChunk:request];
    }
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        NSString* statusStr = [NSString stringWithFormat:@"HTTP status %ld %@", (long)[urlResponse statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[urlResponse statusCode]]];
        NSLog(@"%d << %@: %@", i, cmdStr, statusStr);
        
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            
            BOOL is2XX = ([urlResponse statusCode] / 100) == 2;
            if (!is2XX) {
                NSString* respStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                NSLog(@"%@", respStr);
                
                NSString* errStr = statusStr;
                
                NSMutableDictionary *returnedData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
                if (returnedData && (returnedData[@"error"] || returnedData[@"errors"])) {
                    errStr = respStr;
                }
                
                DispatchMainThread(^() {
                    completionHandler(errStr);
                });
                return;
            }
            
            if (i == 0) {
                [self processInitResp:responseData];
            }
            else if (i == paramList.count-1) {
                if (completionHandler != nil) {
                    DispatchMainThread(^() {
                        completionHandler(nil);
                    });
                }
                return;
            }
            
            [self sendCommand:i+1];
        }
    }];
}

@end

