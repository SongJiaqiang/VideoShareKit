//
//  ShareTool.h
//  Rokk
//
//  Created by Jarvis on 11/10/2016.
//  Copyright © 2016 Jarvis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ShareContent.h"

typedef NS_ENUM(NSInteger, SharePlatform) {
    SharePlatformAlbum = 0,
    SharePlatformFacebook,
    SharePlatformMessenger,
    SharePlatformInstagram,
    SharePlatformTwitter,
    SharePlatformTumblr,
    SharePlatformPinterest,
};

@interface ShareTool : NSObject

+ (void)shareToPlatform:(SharePlatform)platform
         fromController:(UIViewController *)viewController
            withContent:(ShareContent *)content;

+ (void)sharePhoto:(SharePhoto *)photo fromController:(UIViewController *)viewController toPlatform:(SharePlatform)platform;
+ (void)shareVideo:(ShareVideo *)video fromController:(UIViewController *)viewController toPlatform:(SharePlatform)platform;

+ (void)writeVideoToAlbumWithPath:(NSURL *)videoPath
                       completion:(void(^)(NSURL *assetURL,NSError *error))completion;

+ (void)writeImageToAlbum:(UIImage *)image
               completion:(void(^)(NSURL *assetURL,NSError *error))completion;

+ (UIImage *)getThumbImageFromVideoURL:(NSURL *)videoURL;

@end
