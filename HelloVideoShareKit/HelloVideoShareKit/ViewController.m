//
//  ViewController.m
//  HelloVideoShareKit
//
//  Created by Jarvis on 20/10/2016.
//  Copyright © 2016 Jarvis. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

#import "ShareAlertController.h"
#import "MBProgressHUD.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *videoInfoView;
@property (weak, nonatomic) IBOutlet UIButton *selfieButton;
@property (weak, nonatomic) IBOutlet UIButton *pickButton;
- (IBAction)selfieButtonPressed:(UIButton *)sender;
- (IBAction)pickButtonPressed:(UIButton *)sender;
- (IBAction)shareButtonPressed:(UIButton *)sender;


@end

@implementation ViewController {
    NSURL *_mediaURL;
    NSURL *_mediaAssetLibURL;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)selfieButtonPressed:(UIButton *)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeMovie]) {
            // Video recording is supported
            
            UIImagePickerController *cameraController = [UIImagePickerController new];
            cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
            cameraController.mediaTypes = @[(NSString *)kUTTypeMovie];
            cameraController.delegate = self;
            // Set front camera
            if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
                cameraController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            cameraController.showsCameraControls = YES;
            
            [self presentViewController:cameraController animated:YES completion:nil];
        }
    }
}

- (IBAction)pickButtonPressed:(UIButton *)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
        pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pickerController.mediaTypes = @[(NSString*)kUTTypeMovie, (NSString*)kUTTypeAVIMovie, (NSString*)kUTTypeVideo, (NSString*)kUTTypeMPEG4];
        pickerController.delegate = self;
        
        [self presentViewController:pickerController animated:YES completion:nil];
    }
}

- (IBAction)shareButtonPressed:(UIButton *)sender {
    
    if (_mediaAssetLibURL == nil) {
        [self toastMessage:@"Please pick or record an video first." inView:self.view];
        
        return;
    }
    
    ShareAlertController *alertController = [ShareAlertController new];
    alertController.title = @"Share Video";
    
    ShareVideo *video = [[ShareVideo alloc] init];
    video.videoURL = _mediaURL;
    video.videoAssetLibraryURL = _mediaAssetLibURL;
    
    [alertController addShareActionWithPlatform:SharePlatformFacebook handler:^(UIAlertAction *action) {
        [ShareTool shareVideo:video fromController:self toPlatform:SharePlatformFacebook];
    }];
    [alertController addShareActionWithPlatform:SharePlatformMessenger handler:^(UIAlertAction *action) {
        [ShareTool shareVideo:video fromController:self toPlatform:SharePlatformMessenger];
    }];
    [alertController addShareActionWithPlatform:SharePlatformInstagram handler:^(UIAlertAction *action) {
        [ShareTool shareVideo:video fromController:self toPlatform:SharePlatformInstagram];
    }];
    [alertController addShareActionWithPlatform:SharePlatformTwitter handler:^(UIAlertAction *action) {
        [ShareTool shareVideo:video fromController:self toPlatform:SharePlatformTwitter];
    }];
    
    [alertController addCancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    NSLog(@"media info >> %@", info);
    _videoInfoView.text = [NSString stringWithFormat:@"%@", info];
    
    _mediaURL = info[UIImagePickerControllerMediaURL];
    _mediaAssetLibURL = info[UIImagePickerControllerReferenceURL];
    if (_mediaAssetLibURL == nil) {
        [ShareTool writeVideoToAlbumWithPath:_mediaURL completion:^(NSURL *assetURL, NSError *error) {
            [self toastMessage:@"Saved video to album." inView:self.view];
            _mediaAssetLibURL = assetURL;
            
            _videoInfoView.text = [NSString stringWithFormat:@"%@ \n %@", _videoInfoView.text, _mediaAssetLibURL];
        }];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)toastMessage:(NSString *)message inView:(UIView *)inView {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:inView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    [hud hideAnimated:YES afterDelay:2];
}

@end
