//
//  ShareContent.h
//  Rokk
//
//  Created by Jarvis on 11/10/2016.
//  Copyright © 2016 Jarvis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 请使用子类SharePhotoContent、ShareVideoContent
@interface ShareContent : NSObject

@property (nonatomic, copy) NSURL *contentURL;
@property (nonatomic, copy) NSArray *peopleIDs;
@property (nonatomic, copy) NSString *placeID;
@property (nonatomic, copy) NSString *ref;
@property (nonatomic, copy) NSString *comment;

@end


@interface SharePhoto : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSURL *imageAssetLibraryURL;
@property (nonatomic, strong) NSURL *imageWebURL;

- (id)initWithImage:(UIImage *)image imageURL:(NSURL *)imageURL;

@end


@interface ShareVideo : NSObject

@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) NSURL *videoAssetLibraryURL;

-(id)initWithVideoURL:(NSURL *)videoURL;

@end


@interface SharePhotoContent : ShareContent

@property (nonatomic, strong) SharePhoto *photo;

- (id)initWithPhoto:(SharePhoto *)photo;

@end

@interface ShareVideoContent : ShareContent

@property (nonatomic, strong) SharePhoto *previewPhoto;
@property (nonatomic, strong) ShareVideo *video;

- (id)initWithVideo:(ShareVideo *)video previewPhoto:(SharePhoto *)previewPhoto;

@end
