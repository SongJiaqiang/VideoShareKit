//
//  ShareContent.m
//  Rokk
//
//  Created by Jarvis on 11/10/2016.
//  Copyright © 2016 Jarvis. All rights reserved.
//

#import "ShareContent.h"

@implementation ShareContent

@end


@implementation SharePhoto

- (id)initWithImage:(UIImage *)image imageURL:(NSURL *)imageURL {
    if (self = [super init]) {
        _image = image;
        _imageURL = imageURL;
    }
    return self;
}

@end

@implementation ShareVideo

-(id)initWithVideoURL:(NSURL *)videoURL {
    if (self = [super init]) {
        _videoURL = videoURL;
    }
    return self;
}

@end

@implementation SharePhotoContent

- (id)initWithPhoto:(SharePhoto *)photo {
    if (self = [super init]) {
        _photo = photo;
    }
    return self;
}

@end

@implementation ShareVideoContent

- (id)initWithVideo:(ShareVideo *)video previewPhoto:(SharePhoto *)previewPhoto {
    if (self = [super init]) {
        _video = video;
        _previewPhoto = previewPhoto;
    }
    return self;
}

@end
