//
//  ShareAlertController.h
//  Rokk
//
//  Created by Jarvis on 11/10/2016.
//  Copyright © 2016 Jarvis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareTool.h"

@class ShareAlertController;

typedef void (^ActionHandler)(UIAlertAction *);

@protocol ShareAlertControllerDelegate <NSObject>

- (void)shareAlertController:(ShareAlertController *)alertController selectedAtIndex:(NSInteger)index;

@end

@interface ShareAlertController : UIAlertController

@property (nonatomic, assign) id<ShareAlertControllerDelegate> delegate;

@property(nonatomic) NSInteger cancelButtonIndex;
@property(nonatomic) NSInteger destructiveButtonIndex;

@property (nonatomic, strong) NSURL *videoURL;

-(instancetype)initWithTitles:(NSArray *)optionTitles;


#pragma mark - Add Action
- (void)addCancelAction;
- (void)addActionWithTitle:(NSString *)title handler:(ActionHandler)handler;
- (void)addDestructiveActionWithTitle:(NSString *)title handler:(ActionHandler)handler;
- (void)addShareActionWithPlatform:(SharePlatform)platform handler:(ActionHandler)handler;
- (void)addShareActionWithPlatform:(SharePlatform)platform beforeSharingHandler:(void (^)(void (^handler)(NSURL*)))beforeHandler;

@end
