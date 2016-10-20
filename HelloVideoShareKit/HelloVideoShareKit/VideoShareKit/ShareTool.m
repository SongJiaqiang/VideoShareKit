//
//  ShareTool.m
//  Rokk
//
//  Created by Jarvis on 11/10/2016.
//  Copyright © 2016 Jarvis. All rights reserved.
//

#import "ShareTool.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>
#import "TwitterShareDialog.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <TwitterKit/TwitterKit.h>
#import "MBProgressHUD.h"
#import "NSString+share.h"

@implementation ShareTool

+ (void)shareToPlatform:(SharePlatform)platform
         fromController:(UIViewController *)viewController
            withContent:(ShareContent *)content {
    
    switch (platform) {
        case SharePlatformFacebook:{
            if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]]) {
                [ShareTool showAlertDialogWithTitle:@"NOTICE" andMessage:@"You Did Not Install Facebook" fromViewController:viewController];
                break;
            }
            
            if ([content isKindOfClass:[ShareVideoContent class]]) {
                ShareVideoContent *videoContent = (ShareVideoContent *)content;
                
                FBSDKShareVideo *fbVideo = [[FBSDKShareVideo alloc] init];
                FBSDKShareVideoContent *fbVideoContent = [[FBSDKShareVideoContent alloc] init];
                fbVideo.videoURL = videoContent.video.videoAssetLibraryURL;
                fbVideoContent.video = fbVideo;
                fbVideoContent.previewPhoto = [FBSDKSharePhoto photoWithImage:videoContent.previewPhoto.image userGenerated:YES];
                
                FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
                dialog.mode = FBSDKShareDialogModeNative;
                dialog.fromViewController = viewController;
                dialog.shareContent = fbVideoContent;
                dialog.delegate = nil;
                [dialog show];
            }
            else if ([content isKindOfClass:[SharePhotoContent class]]) {
                SharePhotoContent *photoContent = (SharePhotoContent *)content;
                
                FBSDKSharePhotoContent *fbPhotoContent = [[FBSDKSharePhotoContent alloc] init];
                FBSDKSharePhoto *photo = [FBSDKSharePhoto photoWithImage:photoContent.photo.image userGenerated:YES];
                fbPhotoContent.photos = @[photo];
                
                FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
                dialog.mode = FBSDKShareDialogModeNative;
                dialog.fromViewController = viewController;
                dialog.shareContent = fbPhotoContent;
                dialog.delegate = nil;
                [dialog show];
            }
            
            break;
        }
        case SharePlatformMessenger:{
            if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb-messenger-api://"]]) {
                [ShareTool showAlertDialogWithTitle:@"NOTICE" andMessage:@"You Did Not Install Messeger" fromViewController:viewController];
                break;
            }
            
            if ([content isKindOfClass:[ShareVideoContent class]]) {
                ShareVideoContent *videoContent = (ShareVideoContent *)content;
                
                NSData *videoData = [NSData dataWithContentsOfFile:videoContent.video.videoURL.path];
                [FBSDKMessengerSharer shareVideo:videoData withOptions:nil];
            }
            else if ([content isKindOfClass:[SharePhotoContent class]]) {
                SharePhotoContent *photoContent = (SharePhotoContent *)content;
                
                [FBSDKMessengerSharer shareImage:photoContent.photo.image withOptions:nil];
            }
            
            break;
        }
        case SharePlatformInstagram:{
            
            NSString *escapedString = nil;
            NSString *escapedCaption = nil;
            
            if ([content isKindOfClass:[ShareVideoContent class]]) {
                ShareVideoContent *videoContent = (ShareVideoContent *)content;
                escapedString = [videoContent.video.videoAssetLibraryURL.absoluteString URLEncodedString];
                escapedCaption = [videoContent.comment URLEncodedString];
            }
            else if ([content isKindOfClass:[SharePhotoContent class]]) {
                SharePhotoContent *photoContent = (SharePhotoContent *)content;
                escapedString = [photoContent.photo.imageAssetLibraryURL.absoluteString URLEncodedString];
                escapedCaption = [photoContent.comment URLEncodedString];
            }
            
            NSURL *instagramURL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://library?AssetPath=%@&InstagramCaption=%@", escapedString, escapedCaption]];
            
            if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
                [[UIApplication sharedApplication] openURL:instagramURL];
            }else{
                [ShareTool showAlertDialogWithTitle:@"NOTICE" andMessage:@"You Did Not Install Instagram" fromViewController:viewController];
            }
            break;
        }
        case SharePlatformTwitter:{
            if ([content isKindOfClass:[ShareVideoContent class]]) {
                ShareVideoContent *videoContent = (ShareVideoContent *)content;
                [TwitterShareDialog showFromViewController:viewController withContent:videoContent delegate:nil];
            } else if ([content isKindOfClass:[SharePhotoContent class]]) {
                SharePhotoContent *photoContent = (SharePhotoContent *)content;
                UIImage *image =  photoContent.photo.image;
                [ShareTool postImageWithMessageOnTwitter:image shareMessage:@"#RokkApp"];
            }
            break;
        }
        case SharePlatformAlbum:{
            if ([content isKindOfClass:[ShareVideoContent class]]) {
                ShareVideoContent *videoContent = (ShareVideoContent *)content;
                [ShareTool writeVideoToAlbumWithPath:videoContent.video.videoURL completion:^(NSURL *assetURL, NSError *error) {
                    if (!error) {
                        NSLog(@"Save video success.");
                    }else {
                        NSLog(@"Save video to album failed.");
                    }
                }];

            }else if ([content isKindOfClass:[SharePhotoContent class]]) {
                SharePhotoContent *photoContent = (SharePhotoContent *)content;
                [ShareTool writeImageToAlbum:photoContent.photo.image completion:^(NSURL *assetURL, NSError *error) {
                    if (!error) {
                        NSLog(@"Save photo success.");
                    }else {
                        NSLog(@"Save photo to album failed.");
                    }
                }];
            }
            
            break;
        }
        default:
            break;
    }
}

/** Share image */
+ (void)sharePhoto:(SharePhoto *)photo fromController:(UIViewController *)viewController toPlatform:(SharePlatform)platform {
    
    SharePhotoContent *photoContent = [[SharePhotoContent alloc] init];
    photoContent.photo = photo;
    photoContent.comment = @"＃Rokkapp";
    [ShareTool shareToPlatform:platform fromController:viewController withContent:photoContent];
    
    //    [ShareTool writeImageToAlbum:[self getThumbImage:_videoURL] completion:^(NSURL *assetURL, NSError *error) {
    //        SharePhotoContent *photoContent = [[SharePhotoContent alloc] init];
    //        SharePhoto *photo = [[SharePhoto alloc] initWithImage:[self getThumbImage:_videoURL] imageURL:nil];
    //        photo.imageAssetLibraryURL = assetURL;
    //        photoContent.photo = photo;
    //        photoContent.comment = @"＃Rokkapp";
    //        [ShareTool shareToPlatform:platform fromController:self withContent:photoContent andResult:nil];
    //    }];
}

/** Share video */
+ (void)shareVideo:(ShareVideo *)video fromController:(UIViewController *)viewController toPlatform:(SharePlatform)platform {
    
    ShareVideoContent *content = [[ShareVideoContent alloc] init];
    content.video = video;
    UIImage *previewImage = [ShareTool getThumbImageFromVideoURL:content.video.videoURL];
    content.previewPhoto = [[SharePhoto alloc] initWithImage:previewImage imageURL:nil];
    content.comment = @"#Rokkapp";
    
    [ShareTool shareToPlatform:platform fromController:viewController withContent:content];
}

+(void) postImageWithMessageOnTwitter:(UIImage *)image shareMessage:(NSString *)message{

    SLComposeViewController *mySLComposerSheet;
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        mySLComposerSheet = [[SLComposeViewController alloc] init]; //initiate the Social Controller
        mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter]; //Tell him with what social plattform to use it, e.g. facebook or twitter
        [mySLComposerSheet setInitialText:[NSString stringWithFormat:message,mySLComposerSheet.serviceType]]; //the message you want to post
        [mySLComposerSheet addImage:image];
        
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
    [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        NSString *output;
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                output = @"Action Cancelled";
                break;
            case SLComposeViewControllerResultDone:
                output = @"Post Successfull";
                break;
            default:
                break;
        } //check if everything worked properly. Give out a message on the state.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }];
}

+ (void)writeVideoToAlbumWithPath:(NSURL *)videoPath completion:(void(^)(NSURL *assetURL,NSError *error))completion {
    NSURL *exportURL = videoPath;
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:exportURL]){
        [library writeVideoAtPathToSavedPhotosAlbum:exportURL completionBlock:^(NSURL *assetURL, NSError *error) {
             if (!error){
                 if (completion) {
                     completion(assetURL, nil);
                 }
             }else{
                 if (completion) {
                     completion(nil,error);
                 }
             }
         }];
    } else {
        completion(nil, [NSError errorWithDomain:@"rokkapp.com" code:444 userInfo:@{@"message":@"Can't save to album"}]);
    }
    
    
}

+ (void)writeImageToAlbum:(UIImage *)image completion:(void(^)(NSURL *assetURL,NSError *error))completion {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        if (!error){
            if (completion) {
                completion(assetURL, nil);
            }
        }else{
            if (completion) {
                completion(nil,error);
            }
        }
    }];
}

+ (UIImage *)getThumbImageFromVideoURL:(NSURL *)videoURL{
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(1.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    
    return thumb;
}

+ (void)showAlertDialogWithTitle:(NSString *)title andMessage:(NSString *)message fromViewController:(UIViewController *)viewController {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [viewController presentViewController:alertController animated:YES completion:nil];
}

@end
