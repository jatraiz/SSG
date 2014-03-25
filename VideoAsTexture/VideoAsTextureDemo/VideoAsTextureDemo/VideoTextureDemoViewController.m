//
//  VideoTextureDemoViewController.m
//  VideoAsTextureDemo
//
//  Created by John Stricker on 3/25/14.
//  Copyright (c) 2014 John Stricker. All rights reserved.
//

#import "VideoTextureDemoViewController.h"
#import <SSGOGL/SSGOpenGLManager.h>
#import <SSGOGL/SSG2DZConverter.h>
#import <SSGOGL/SSGModel.h>
#import <SSGOGL/SSGAssetManager.h>
#import <SSGOGL/SSGWorldTransformation.h>
#import <SSGOGL/SSGPrs.h>
#import <SSGOGL/SSGCommand.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface VideoTextureDemoViewController () <AVPlayerItemOutputPullDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate>
//openGL properties
@property (nonatomic, strong) SSGOpenGLManager *glmgr;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLfloat mainZ;
@property (nonatomic, strong) SSGModel *quad;
@property (nonatomic, assign) BOOL viewControllerAppeared;
//AV properties
@property UIPopoverController *videoSelectionPopover;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) dispatch_queue_t videoOutputQueue;
@property (nonatomic, strong) AVPlayerItemVideoOutput *videoOutput;
@property (nonatomic, assign) CMTime timePlaying;

- (void)loadMovieFromCameraRoll;
- (void)setupPlaybackForURL:(NSURL *)url;

@end

@implementation VideoTextureDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //engine setup
    self.glmgr = [[SSGOpenGLManager alloc] initWithContextRef:self.context andView:(GLKView*)self.view];
    //load the default shader
    [self.glmgr loadDefaultShaderAndSettings];
    
    //main background color of the window (including transparency)
    [self.glmgr setClearColor:GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f)];
    
    //setting up perspective, with the logo you probably don't want too much of a field of view effect, so a 5 degree field of view is used
    self.glmgr.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(5.0f), fabsf(self.view.bounds.size.width / self.view.bounds.size.height), 0.1f, 100.0f);
    self.glmgr.zConverter = [[SSG2DZConverter alloc] initWithScreenHeight:self.view.bounds.size.width ScreenWidth:self.view.bounds.size.height Fov:GLKMathDegreesToRadians(45.0f)];
    
    //settings for max smoothness in animation & display
    self.preferredFramesPerSecond = 60;
    ((GLKView*)self.view).drawableMultisample = GLKViewDrawableMultisample4X;
    
    //Z location for logo in 3D space
    self.mainZ = -50.0f;
    
    self.quad = [[SSGModel alloc] initWithModelFileName:@"quad"];
    [self.quad setTexture0Id:[SSGAssetManager loadTexture:@"gridTexture" ofType:@"png" shouldLoadWithMipMapping:YES]];
    self.quad.projection = self.glmgr.projectionMatrix;
    self.quad.defaultShaderSettings = self.glmgr.defaultShaderSettings;
    self.quad.prs.pz = self.mainZ;
    self.quad.shadowMax = 0.9f;
    
    [self.quad.prs setRotationConstantToVector:GLKVector3Make(0.0f, 0.0f, 2.0f)];
    
    // Setting up the player
    self.player = [[AVPlayer alloc] init];
    NSDictionary *pixBuffAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
	self.videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
	self.videoOutputQueue = dispatch_queue_create("myVideoOutputQueue", DISPATCH_QUEUE_SERIAL);
	[[self videoOutput] setDelegate:self queue:self.videoOutputQueue];

}

- (void)viewDidAppear:(BOOL)animated
{
    if(!self.viewControllerAppeared)
    {
        [self loadMovieFromCameraRoll];
        self.viewControllerAppeared = YES;
    }
}

- (void)loadMovieFromCameraRoll
{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    pickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    pickerController.mediaTypes = @[(NSString*)kUTTypeMovie];
    [self presentViewController:pickerController animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:NO completion:nil];
    
    [self setupPlaybackForURL:info[UIImagePickerControllerReferenceURL]];
}


- (void)setupPlaybackForURL:(NSURL *)url
{
    [[self.player currentItem] removeOutput:self.videoOutput];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    AVAsset *asset = [item asset];
    
 	[asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        
		if ([asset statusOfValueForKey:@"tracks" error:nil] == AVKeyValueStatusLoaded) {
			NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
			if ([tracks count] > 0) {
				// Choose the first video track.
				AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
				[videoTrack loadValuesAsynchronouslyForKeys:@[@"preferredTransform"] completionHandler:^{
					
					if ([videoTrack statusOfValueForKey:@"preferredTransform" error:nil] == AVKeyValueStatusLoaded) {
						//CGAffineTransform preferredTransform = [videoTrack preferredTransform];
						
						/*
                         The orientation of the camera while recording affects the orientation of the images received from an AVPlayerItemVideoOutput. Here we compute a rotation that is used to correctly orientate the video.
                         */
						//self.playerView.preferredRotation = -1 * atan2(preferredTransform.b, preferredTransform.a);
						
						//[self addDidPlayToEndTimeNotificationForPlayerItem:item];
						
						dispatch_async(dispatch_get_main_queue(), ^{
							[item addOutput:self.videoOutput];
							[self.player replaceCurrentItemWithPlayerItem:item];
							[self.videoOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:0.03f];
							[self.player play];
                            self.timePlaying = CMTimeMakeWithSeconds(0, 10000000);
						});
						
					}
					
				}];
			}
		}
		
	}];
}

- (void)updateTexture:(CVPixelBufferRef)pixelBufferRef
{
    
}

- (void)update
{
    [self.quad updateWithTime:self.timeSinceLastUpdate];
    
    CMTime outputItemTime = self.timePlaying;
    outputItemTime.value +=  CMTimeMakeWithSeconds(self.timeSinceLastUpdate, 10000000).value;
    
    [[self videoOutput] itemTimeForHostTime:outputItemTime.value];
  //  NSLog(@"outputTime: %lli",outputItemTime.value);
    if ([[self videoOutput] hasNewPixelBufferForItemTime :outputItemTime]){
     //   NSLog(@"pixel bufffer!");
        CVPixelBufferRef pixelBuffer = NULL;
        pixelBuffer = [[self videoOutput] copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];
        CFRelease(pixelBuffer);
        
    }
    
    self.timePlaying = outputItemTime;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
      glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    [self.quad draw];
}

@end
