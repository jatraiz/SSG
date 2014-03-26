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
@property (nonatomic, strong) NSMutableArray *quads;
@property (nonatomic, assign) BOOL videoSelectionShown;
@property (nonatomic, assign) BOOL videoAnimationShown;
//AV properties
@property UIPopoverController *videoSelectionPopover;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) dispatch_queue_t videoOutputQueue;
@property (nonatomic, strong) AVPlayerItemVideoOutput *videoOutput;
@property (nonatomic, assign) CMTime timePlaying;
@property (nonatomic, assign) CVOpenGLESTextureCacheRef textureCacheRef;
@property (nonatomic, assign) CVOpenGLESTextureRef videoTexture;


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
    self.glmgr.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(50.0f), fabsf(self.view.bounds.size.width / self.view.bounds.size.height), 0.1f, 100.0f);
    self.glmgr.zConverter = [[SSG2DZConverter alloc] initWithScreenHeight:self.view.bounds.size.width ScreenWidth:self.view.bounds.size.height Fov:GLKMathDegreesToRadians(45.0f)];
    
    //settings for max smoothness in animation & display
    self.preferredFramesPerSecond = 60;
    ((GLKView*)self.view).drawableMultisample = GLKViewDrawableMultisample4X;
    
    //Z location for logo in 3D space
    self.mainZ = -7.0f;
    
    int nQuads = 12;
    int nColumns = 3;
    GLfloat leftX = -1.25f;
    GLfloat xSpacing = 1.25f;
    GLfloat ySpacing = -1.5f;
    GLfloat yStart = 2.25f;
    
    int columnCount = 0;
    int rowCount = 0;
    
    self.quads = [[NSMutableArray alloc] init];
    for(int i = 0; i < nQuads; ++i)
    {
        SSGModel *quad;
        
        quad = [[SSGModel alloc] initWithModelFileName:@"quadCropped"];
        [quad setTexture0Id:[SSGAssetManager loadTexture:@"gridTexture" ofType:@"png" shouldLoadWithMipMapping:YES]];
        quad.projection = self.glmgr.projectionMatrix;
        quad.defaultShaderSettings = self.glmgr.defaultShaderSettings;
        quad.shadowMax = 0.9f;
        quad.prs.pz = self.mainZ;
        quad.prs.px = leftX + (xSpacing * columnCount);
        quad.prs.py = yStart + (ySpacing * rowCount);
        quad.prs.sxyz = 0.5f;
        
        [self.quads addObject:quad];
        
        ++columnCount;
        if(columnCount == nColumns){
            columnCount = 0;
            ++rowCount;
        }
    }
    
    // Setting up the player
    self.player = [[AVPlayer alloc] init];
    NSDictionary *pixBuffAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
	self.videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
	self.videoOutputQueue = dispatch_queue_create("myVideoOutputQueue", DISPATCH_QUEUE_SERIAL);
	[[self videoOutput] setDelegate:self queue:self.videoOutputQueue];
    
    CVReturn error = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL,((GLKView*)self.view).context, NULL, &_textureCacheRef);
    if(error != noErr){
        NSLog(@"ERROR setting up CVOpenGLESTextureCache %d", error);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!self.videoSelectionShown){
        [self loadMovieFromCameraRoll];
        self.videoSelectionShown = YES;
    } else if(!self.videoAnimationShown)
    {
        int columncount = 0;
        int nColumns = 3;
        int currentRow = 0;
        GLfloat delay = 0.0f;
        GLfloat zSpacing = 1.0f;
        GLfloat ySpacing = 0.5f;
        GLfloat duration = 10.0f;
        
        for(int i = 0; i < [self.quads count]; ++i)
        {
            SSGModel *m = (SSGModel*)self.quads[i];
            
            GLfloat newZ = 0.0f;
            GLfloat newY = 0.0f;
            if(currentRow == 0){
                newZ = zSpacing * -2;
                newY = ySpacing * -3;
            }
            else if(currentRow == 1){
                newZ = zSpacing * -1;
                newY = ySpacing * -1;
            }
            else if(currentRow == 2){
                newY = ySpacing;
            }
            else if(currentRow == 3){
                newZ = zSpacing * 1;
                newY = ySpacing * 3;
            }
            
            [m.prs moveToVector:GLKVector3Make(0.0f, newY, newZ) Duration:duration Delay:delay IsAbsolute:NO];
            
            if(++columncount == nColumns){
                ++currentRow;
                columncount = 0;
            }
        }
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

- (void)cleanUpTexture
{
    if(self.videoTexture){
        CFRelease(self.videoTexture);
        self.videoTexture = NULL;
    }
}

- (void)updateTexture:(CVPixelBufferRef)pixelBuffer
{
    int frameWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
    int frameHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    
    [self cleanUpTexture];
    CVReturn error =  CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                                   self.textureCacheRef,
                                                                   pixelBuffer,
                                                                   NULL,
                                                                   GL_TEXTURE_2D,
                                                                   GL_RGBA,
                                                                   frameWidth / 2,
                                                                   frameHeight / 2,
                                                                   GL_BGRA,
                                                                   GL_UNSIGNED_BYTE,
                                                                  0,
                                                                   &_videoTexture);
    
    if(error){
        NSLog(@"Error creating GLTextures: %d",error);
    }
    
    for(SSGModel *m in self.quads)
    {
        m.texture0Id =  CVOpenGLESTextureGetName(self.videoTexture);
    }
    
    glBindTexture(GL_TEXTURE_2D, ((SSGModel*)self.quads[0]).texture0Id);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    //makes sure the buffer is released when done w/it
    CFRelease(pixelBuffer);
}

- (void)update
{
    for(SSGModel *m in self.quads)
    {
        [m updateWithTime:self.timeSinceLastUpdate];
    }
    CMTime outputItemTime = self.timePlaying;
    outputItemTime.value +=  CMTimeMakeWithSeconds(self.timeSinceLastUpdate, 10000000).value;
    
    [[self videoOutput] itemTimeForHostTime:outputItemTime.value];
  //  NSLog(@"outputTime: %lli",outputItemTime.value);
    if ([[self videoOutput] hasNewPixelBufferForItemTime :outputItemTime]){
     //   NSLog(@"pixel bufffer!");
        CVPixelBufferRef pixelBuffer = NULL;
        pixelBuffer = [[self videoOutput] copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];
        [self updateTexture:pixelBuffer];
        
    }
    
    self.timePlaying = outputItemTime;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    for(SSGModel *m in self.quads)
    {
        [m draw];
    }
}

@end
