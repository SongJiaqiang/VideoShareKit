//
//  ShareAlertController.m
//  Rokk
//
//  Created by Jarvis on 11/10/2016.
//  Copyright © 2016 Jarvis. All rights reserved.
//

#import "ShareAlertController.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>


@interface ShareAlertController ()

@property (nonatomic, strong) NSArray *optionTitles;

@end

@implementation ShareAlertController


-(instancetype)initWithTitles:(NSArray *)optionTitles {
    if (self = [super init]) {
        
        _cancelButtonIndex = -1;
        _destructiveButtonIndex = -1;
        
        if (optionTitles) {
            _optionTitles = optionTitles;
        }else {
            _optionTitles = [NSArray array];
        }
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.message = @"More";
    
    
    [self prepareActions];
    
}

- (void)prepareActions {
    NSInteger optionsCount = _optionTitles.count;
    if (optionsCount > 0) {
        for (int i = 0; i < optionsCount; i++) {
            NSString *title = _optionTitles[i];
            __weak typeof(self) wSelf = self;
            UIAlertActionStyle style = UIAlertActionStyleDefault;
            if (_destructiveButtonIndex == i) {
                style = UIAlertActionStyleDestructive;
            }
            if (_cancelButtonIndex == i) {
                style = UIAlertActionStyleCancel;
            }
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction * _Nonnull action) {
                [wSelf actionHandler:i];
            }];
            
            [self addAction:action];
        }
    }
}

- (void)actionHandler:(NSInteger)index {
    NSLog(@"select index %ld", index);
    
    if (_delegate && [_delegate respondsToSelector:@selector(shareAlertController:selectedAtIndex:)]) {
        [_delegate shareAlertController:self selectedAtIndex:index];
    }
}

#pragma mark - add action

- (void)addActionWithTitle:(NSString *)title handler:(ActionHandler)handler {
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:handler];
    [self addAction:action];
}

- (void)addDestructiveActionWithTitle:(NSString *)title handler:(ActionHandler)handler {
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDestructive handler:handler];
    [self addAction:action];
}

- (void)addCancelAction{
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [self addAction:action];
}

- (void)addShareActionWithPlatform:(SharePlatform)platform handler:(ActionHandler)handler {
    NSString *title = nil;
    switch (platform) {
        case SharePlatformAlbum:{
            title = @"Save to Album";
            break;
        }
        case SharePlatformFacebook:{
            title = @"Share to Facebook";
            break;
        }
        case SharePlatformMessenger:{
            title = @"Share to Messenger";
            break;
        }
        case SharePlatformInstagram:{
            title = @"Share to Instagram";
            break;
        }
        case SharePlatformTwitter:{
            title = @"Share to Twitter";
            break;
        }
        default:
            title = @"Undefine Platform";
            break;
    }
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:handler];
    [self addAction:action];
}

/**
 @desc 添加分享类型的Action
 @params
    platform 平台类型。FB、Ins、Twitter、Album
    beforeHandler 前置回调block，非空
 */
- (void)addShareActionWithPlatform:(SharePlatform)platform beforeSharingHandler:(void (^ __nullable)(void (^handler)(NSURL*)))beforeHandler {
    NSString *title = nil;
    ActionHandler handler = nil;
    __weak typeof(self) weakSelf = self;
    switch (platform) {
        case SharePlatformAlbum:{
            title = @"Save to Album";
            handler = ^(UIAlertAction *action) {
                [weakSelf saveToAlbum];
            };
            break;
        }
        case SharePlatformFacebook:{
            title = @"Share to Facebook";
            handler = ^(UIAlertAction *action) {
                [weakSelf shareToFacebook];
            };
            break;
        }
        case SharePlatformInstagram:{
            title = @"Share to Instagram";
            handler = ^(UIAlertAction *action) {
                [weakSelf shareToInstagram];
            };
            break;
        }
        case SharePlatformTwitter:{
            title = @"Share to Twitter";
            handler = ^(UIAlertAction *action) {
                [weakSelf shareToTwitter];
            };
            break;
        }
        default:
            break;
    }
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (beforeHandler) {
            beforeHandler(^(NSURL *url){
                _videoURL = url;
                handler(action);
            });
        } else {
            handler(action);
        }
    }];
    
    [self addAction:action];
}

- (void)addDeleteOrReportAction:(BOOL)isMine{
    NSString *title = isMine ? @"Delete" : @"Report";
    UIAlertAction *action = nil;
    
    if (isMine) {
        action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self deleteVideo];
        }];
    }else {
        action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self reportVideo];
        }];
    }
    
    [self addAction:action];
}

- (void)addPrivacyAction:(BOOL)isPrivacy{
    NSString *title = isPrivacy ? @"Set Public" : @"Set Privacy";
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setPrivacy:!isPrivacy];
    }];
    [self addAction:action];
}



- (void)saveToAlbum {
    NSLog(@"saveToAlbum");
}

- (void)shareToFacebook {
    NSLog(@"shareToFacebook");
}
- (void)shareToTwitter {
    NSLog(@"shareToTwitter");
}
- (void)shareToInstagram {
    NSLog(@"shareToInstagram");
}

- (void)deleteVideo {
    NSLog(@"deleteVideo");
}

- (void)reportVideo {
    NSLog(@"reportVideo");
}

- (void)setPrivacy:(BOOL)isPrivacy {
    NSLog(@"setPrivacy");
}

@end
