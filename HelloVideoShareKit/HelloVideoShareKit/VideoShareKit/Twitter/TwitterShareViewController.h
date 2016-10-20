//
//  TwitterShareViewController.h
//  Rokk
//
//  Created by Jarvis on 10/10/2016.
//  Copyright © 2016 Jarvis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitterShareDialog.h"

@protocol TwitterShareViewControllerDelegate <NSObject>

- (void)previewMedia;
- (void)cancelSharing;
- (void)postTwitter:(NSString *)twitterStatus;

@end

@interface TwitterShareViewController : UIViewController

@property (nonatomic, assign) id<TwitterShareViewControllerDelegate> delegate;

@property (nonatomic, strong) ShareContent *shareContent;

@end
