//
//  TwitterShareDialog.m
//  Rokk
//
//  Created by Jarvis on 09/10/2016.
//  Copyright © 2016 Jarvis. All rights reserved.
//

#import "TwitterShareDialog.h"
#import <UIKit/UIKit.h>
#import "TwitterShareViewController.h"
#import "TwitterVideoUpload.h"

#import <TwitterKit/TwitterKit.h>
#import <TwitterKit/Twitter.h>
#import "MBProgressHUD.h"

@interface TwitterShareDialog () <TwitterShareViewControllerDelegate>

@property (nonatomic, strong) UIView *container;
@property (nonatomic, assign) BOOL isShow;

@end

@implementation TwitterShareDialog

+(instancetype) sharedDialog{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [[TwitterShareDialog alloc] init];
        }
    });
    return instance;
}

+(id)showFromViewController:(UIViewController *)viewController
                          withContent:(ShareContent *)content
                             delegate:(id<TwitterSharingDelegate>)delegate {
    
    TwitterShareDialog *dialog = [TwitterShareDialog sharedDialog];
    dialog.fromViewController = viewController;
    if (content) {
        dialog.shareContent = content;
    }
    if (delegate) {
        dialog.delegate = delegate;
    }
    
    dialog.container = [dialog generateSharingDialog];
    
    dialog.isShow = [dialog show];
 
    return dialog;
}

- (UIView *)generateSharingDialog {
    
    UIView *container = [UIView new];
    container.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    container.frame = [TwitterShareDialog sharedDialog].fromViewController.view.bounds;
    
    TwitterShareViewController *controller = [[TwitterShareViewController alloc] init];
    controller.shareContent = [TwitterShareDialog sharedDialog].shareContent;
    controller.delegate = self;
    // 设置导航栏
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    nav.view.clipsToBounds = YES;
    nav.view.layer.cornerRadius = 10;
    nav.view.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.00];
    nav.view.frame = CGRectMake(30, 84, container.frame.size.width-30*2, 200);
    
    [container addSubview:nav.view];
    [[TwitterShareDialog sharedDialog].fromViewController addChildViewController:nav];
    
    return container;
}


-(BOOL)show {
    
    UIView *container = [TwitterShareDialog sharedDialog].container;
    
    [[TwitterShareDialog sharedDialog].fromViewController.view addSubview:container];
    
    container.alpha = 0;
    
    [UIView animateWithDuration:0.25 animations:^{
        container.alpha = 1;
    }];
    
    
    return YES;
}

- (void)hide {
    
    [UIView animateWithDuration:0.25 animations:^{
        [TwitterShareDialog sharedDialog].container.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [[TwitterShareDialog sharedDialog].container removeFromSuperview];
            [TwitterShareDialog sharedDialog].container = nil;
        }
    }];
    
    
}

-(BOOL)canShow {
    if (_fromViewController) {
        return YES;
    }
    return NO;
}

#pragma mark - TwitterShareViewControllerDelegate
- (void)postTwitter:(NSString *)twitterStatus {
    [[TwitterShareDialog sharedDialog] hide];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_fromViewController.view animated:YES];
    hud.label.text = @"Loading";
    hud.mode = MBProgressHUDModeDeterminate;
    [hud showAnimated:YES];
    
    ShareVideoContent *videoContent = (ShareVideoContent *)_shareContent;
    BOOL status = [[TwitterVideoUpload instance] setVideoURL:videoContent.video.videoURL];
    if (status == FALSE) {
        [hud hideAnimated:YES];
        
        [[TwitterShareDialog sharedDialog] toastMessage:@"Failed reading video file"];
        
        return;
    }
    NSString *tweet = [NSString stringWithFormat:@"#Rokkapp %@", twitterStatus];
    status = [[TwitterVideoUpload instance] uploadTweet:tweet completionHandlerBlock:^(NSString* errorString){
        [hud hideAnimated:YES];
        // Open Twitter app
        NSURL *urlApp = [NSURL URLWithString: [NSString stringWithFormat:@"%@", @"twitter://"]];
        if ([[UIApplication sharedApplication] canOpenURL:urlApp]){
            [[UIApplication sharedApplication] openURL:urlApp];
        }else{
            [[TwitterShareDialog sharedDialog] showSimpleAlertWithMessage:@"You Did Not Install Twitter App"];
        }
    }];
    
    if (status == FALSE) {
        [hud hideAnimated:YES];
        
        [[TwitterShareDialog sharedDialog] toastMessage:@"No Twitter account. Please add Twitter account in Settings>Twitter"];
    }
}

- (void)cancelSharing {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sharerDidCancel:)]) {
        [self.delegate sharerDidCancel:self];
    }
    
    [[TwitterShareDialog sharedDialog] hide];
}

- (void)previewMedia {
    
}


#pragma mark - tool function
- (void)toastMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_fromViewController.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = message;
    });
}

- (void)showSimpleAlertWithMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action0 = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:action0];
        
        [[TwitterShareDialog sharedDialog].fromViewController presentViewController:alertController animated:YES completion:nil];
    });
}

@end



