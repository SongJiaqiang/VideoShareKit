//
//  TwitterShareViewController.m
//  Rokk
//
//  Created by Jarvis on 10/10/2016.
//  Copyright © 2016 Jarvis. All rights reserved.
//

#import "TwitterShareViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface TwitterShareViewController () <UITextViewDelegate>

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, weak) UILabel *availableCharLabel;

@end

@implementation TwitterShareViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self prepareNavigationItem];
    
    [self prepareUI];
    [_textView becomeFirstResponder];
}

- (void)prepareNavigationItem {
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStylePlain target:self action:@selector(post)];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.navigationItem.rightBarButtonItem = rightItem;
    self.title = @"Twitter";
}

- (void)prepareUI {
    CGFloat imageWidth = 60.0;
    CGRect navViewFrame = self.navigationController.view.frame;
    
    // TextView + ImageView
    UIImageView *imageView = [UIImageView new];
    [self.view addSubview:imageView];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.image = [UIImage imageNamed:@"Chaplin"];
    imageView.frame = CGRectMake(CGRectGetWidth(navViewFrame)-10-imageWidth, 10+44, imageWidth, imageWidth);
    
    UITextView *textView = [UITextView new];
    [self.view addSubview:textView];
    textView.backgroundColor = [UIColor clearColor];
    textView.font = [UIFont systemFontOfSize:16];
    textView.text = @"";
    textView.frame = CGRectMake(0, 44, CGRectGetWidth(navViewFrame)-imageWidth-10, CGRectGetHeight(navViewFrame)-44-20);
    textView.delegate = self;
    
    
    UILabel *availableCharLabel = [UILabel new];
    [self.view addSubview:availableCharLabel];
    availableCharLabel.font = [UIFont systemFontOfSize:14];
    availableCharLabel.textColor = [UIColor grayColor];
    availableCharLabel.text = @"140";
    availableCharLabel.frame = CGRectMake(10, CGRectGetHeight(navViewFrame)-20, 40, 20);
    
    _imageView = imageView;
    _textView = textView;
    _availableCharLabel = availableCharLabel;
    
    
    if (_shareContent) {
        if ([_shareContent isKindOfClass:[SharePhotoContent class]]) {
            SharePhotoContent *photoContent = (SharePhotoContent *)_shareContent;
            imageView.image = photoContent.photo.image;
        } else if ([_shareContent isKindOfClass:[ShareVideoContent class]]) {
            ShareVideoContent *videoContent = (ShareVideoContent *)_shareContent;
            imageView.image = videoContent.previewPhoto.image;
            
            UIButton *playButton = [UIButton new];
            [self.view addSubview:playButton];
            [playButton setTitle:@"PLAY" forState:UIControlStateNormal];
            [playButton addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
            playButton.frame = CGRectMake(CGRectGetMinX(imageView.frame)+(imageWidth-30)/2, CGRectGetMinY(imageView.frame)+(imageWidth-30)/2, 30, 30);
        } else {
            imageView.image = [UIImage imageNamed:@"Chaplin"];
        }
    }
}


- (void)textViewDidChange:(UITextView *)textView {
    
    NSString *text = _textView.text;
    
    NSInteger availableCharCount = 140 - text.length;
    _availableCharLabel.text = [NSString stringWithFormat:@"%ld", (long)availableCharCount];
    
    UIBarButtonItem *rightItem = self.navigationItem.rightBarButtonItem;
    if (availableCharCount < 0) {
        _availableCharLabel.textColor = [UIColor redColor];
        rightItem.tintColor = [UIColor grayColor];
        rightItem.enabled = NO;
    }else {
        _availableCharLabel.textColor = [UIColor grayColor];
        rightItem.tintColor = [UIColor colorWithRed:0.13 green:0.51 blue:0.97 alpha:1.00];
        rightItem.enabled = YES;
    }
    
}


- (void)playVideo {
    ShareVideoContent *videoContent = (ShareVideoContent *)_shareContent;
    NSURL *videoURL = videoContent.video.videoURL;
    AVPlayer *player = [[AVPlayer alloc] initWithURL:videoURL];
    AVPlayerViewController *playerController = [AVPlayerViewController new];
    playerController.player = player;
    [self presentViewController:playerController animated:YES completion:^{
        [player play];
    }];
    
}

- (void)dismiss {
    if (_delegate && [_delegate respondsToSelector:@selector(cancelSharing)]) {
        [_delegate cancelSharing];
    }
}

- (void)post {
    if (_delegate && [_delegate respondsToSelector:@selector(postTwitter:)]) {
        [_delegate postTwitter:_textView.text];
    }
}

@end



