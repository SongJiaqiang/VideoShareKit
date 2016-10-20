//
//  TwitterShareDialog.h
//  Rokk
//
//  Created by Jarvis on 09/10/2016.
//  Copyright © 2016 Jarvis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShareContent.h"

@class TwitterShareDialog;

typedef NS_ENUM(NSUInteger, TwitterShareDialogMode)
{
    TwitterShareDialogModeAutomatic = 0,
    TwitterShareDialogModeNative,
    TwitterShareDialogModeShareSheet,
    TwitterShareDialogModeBrowser,
};

#pragma mark - sharing delegate protocol
@protocol TwitterSharingDelegate <NSObject>

- (void)sharer:(TwitterShareDialog *)sharer didCompleteWithResults:(NSDictionary *)results;
- (void)sharer:(TwitterShareDialog *)sharer didFailWithError:(NSError *)error;
- (void)sharerDidCancel:(TwitterShareDialog *)sharer;

@end

#pragma mark - share dialog interface
@interface TwitterShareDialog : NSObject

@property (nonatomic, weak) id<TwitterSharingDelegate> delegate;
@property (nonatomic, strong) ShareContent *shareContent;
@property (nonatomic, assign) BOOL shouldFailOnDataError;

@property (nonatomic, weak) UIViewController *fromViewController;
@property (nonatomic, assign) TwitterShareDialogMode mode;

+ (instancetype)showFromViewController:(UIViewController *)viewController
                           withContent:(ShareContent *)content
                              delegate:(id<TwitterSharingDelegate>)delegate;

- (BOOL)canShow;
- (BOOL)show;

@end


