//
//  StreamingDemoViewController.m
//  StreamingVideoAsTexture
//
//  Created by John Stricker on 3/26/14.
//  Copyright (c) 2014 John Stricker. All rights reserved.
//

#import "StreamingDemoViewController.h"
#import <SSGOGL/SSGOpenGLManager.h>
#import <SSGOGL/SSG2DZConverter.h>
#import <SSGOGL/SSGModel.h>
#import <SSGOGL/SSGAssetManager.h>
#import <SSGOGL/SSGPrs.h>
#import <SSGOGL/SSGCommand.h>
#import <AVFoundation/AVFoundation.h>

static void *kStreamingPlayerItemStatusObserverContext = &kStreamingPlayerItemStatusObserverContext;


@interface StreamingDemoViewController () <AVPlayerItemOutputPullDelegate>

@property (nonatomic, strong) SSGOpenGLManager *glmgr;
@property (nonatomic, strong) SSGModel *testModel;
@property (nonatomic, assign) GLfloat mainZ;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) dispatch_queue_t videoOutputQueue;
@property (nonatomic, strong) AVPlayerItemVideoOutput *videoOutput;
@property (nonatomic, assign) CMTime timePlaying;
@property (nonatomic, assign) CVOpenGLESTextureCacheRef textureCacheRef;
@property (nonatomic, assign) CVOpenGLESTextureRef videoTexture;
@property (nonatomic, assign) BOOL playerStarted;

#define kTracksKey        @"tracks"
#define kStatusKey        @"status"
#define kRateKey          @"rate"
#define kPlayableKey      @"playable"
#define kTimedMetadataKey @"currentItem.timedMetadata"
//#define kMovieUrlString   @"https://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"
#define kMovieUrlString   @"http://devimages.apple.com/samplecode/adDemo/ad.m3u8"
//#define kMovieUrlString   @"https://devimages.apple.com.edgekey.net/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8"
//#define kMovieUrlString @"http://wac.3119.gravlab.com/003119/lotus/video/new_ideas.mp4"
- (void)loadMovie;
- (void)prepareToPlayAsset:(AVAsset*)asset withKeys:(NSArray*)requestedKeys;

@end

@implementation StreamingDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //engine setup
    self.glmgr = [[SSGOpenGLManager alloc] initWithContextRef:((GLKView*)self.view).context andView:(GLKView*)self.view];
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
    self.testModel = [[SSGModel alloc] initWithModelFileName:@"quad16x9"];
    [self.testModel setTexture0Id:[SSGAssetManager loadTexture:@"iphone5GridTexture" ofType:@"png" shouldLoadWithMipMapping:NO]];
    self.testModel.shadowMax = 0.9f;
    self.testModel.projection = self.glmgr.projectionMatrix;
    self.testModel.defaultShaderSettings = self.glmgr.defaultShaderSettings;
    self.testModel.prs.pz = self.mainZ;
    self.testModel.prs.rz = M_PI;
    [self loadMovie];
    
     CVReturn error = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL,((GLKView*)self.view).context, NULL, &_textureCacheRef);
    if(error != noErr){
        NSLog(@"ERROR setting up CVOpenGLESTextureCache %d", error);
    }
}

- (void)loadMovie
{
    NSLog(@"load movie");
    
    NSURL *movieUrl = [NSURL URLWithString:kMovieUrlString];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:movieUrl options:nil];
    NSArray *requestedKeys = @[kTracksKey,kPlayableKey];
    [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
     ^{
         dispatch_async( dispatch_get_main_queue(),
                        ^{
                            /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
                            [self prepareToPlayAsset:asset withKeys:requestedKeys];
                        });
     }];
}

- (void)assetFailedToPrepareForPlayback:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                        message:[error localizedFailureReason]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)prepareToPlayAsset:(AVAsset *)asset withKeys:(NSArray *)requestedKeys
{
    NSLog(@"prepare to play asset");
    
    /* Make sure that the value of each key has loaded successfully. */
	for (NSString *thisKey in requestedKeys)
	{
		NSError *error = nil;
		AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
		if (keyStatus == AVKeyValueStatusFailed)
		{
            [self assetFailedToPrepareForPlayback:error];
			return;
		}
		/* If you are also implementing the use of -[AVAsset cancelLoading], add your code here to bail
         out properly in the case of cancellation. */
	}
    
    if(!asset.playable)
    {
        NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
		NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
		NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
								   localizedDescription, NSLocalizedDescriptionKey,
								   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
								   nil];
		NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StreamingVideoDemo" code:0 userInfo:errorDict];
        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        
        return;
    }
    
    if(self.playerItem)
    {
        [self.playerItem removeObserver:self forKeyPath:kStatusKey];
    }
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    [self.playerItem addObserver:self forKeyPath:kStatusKey options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context: kStreamingPlayerItemStatusObserverContext];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
}

- (void)startPlaying
{
    NSLog(@"start playing");
    
    NSDictionary *pixBuffAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
	self.videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
	self.videoOutputQueue = dispatch_queue_create("myVideoOutputQueue", DISPATCH_QUEUE_SERIAL);
	[[self videoOutput] setDelegate:self queue:self.videoOutputQueue];
   
    CVReturn error = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL,((GLKView*)self.view).context, NULL, &_textureCacheRef);
    if(error != noErr){
        NSLog(@"ERROR setting up CVOpenGLESTextureCache %d", error);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.playerItem addOutput:self.videoOutput];
        [self.videoOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:0.03f];
        [self.player play];
        self.timePlaying = CMTimeMakeWithSeconds(0, 10000000);
    });
    

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(context == kStreamingPlayerItemStatusObserverContext)
    {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerStatusReadyToPlay:
                if(!self.playerStarted)
                {
                    [self startPlaying];
                    self.playerStarted = YES;
                }
                break;
                
            default:
                break;
        }
    }
    else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
    
    return;
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
                                                                   frameWidth,
                                                                   frameHeight,
                                                                   GL_BGRA,
                                                                   GL_UNSIGNED_BYTE,
                                                                   0,
                                                                   &_videoTexture);
    
    if(error){
        NSLog(@"Error creating GLTextures: %d",error);
    }
    
    self.testModel.texture0Id = CVOpenGLESTextureGetName(self.videoTexture);

    glBindTexture(GL_TEXTURE_2D, self.testModel.texture0Id);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    //makes sure the buffer is released when done w/it
    CFRelease(pixelBuffer);
}

- (void)update
{
    [self.testModel updateWithTime:self.timeSinceLastUpdate];
    
    CMTime outputItemTime = self.timePlaying;
    outputItemTime.value += CMTimeMakeWithSeconds(self.timeSinceLastUpdate, 10000000).value;
    
    [[self videoOutput] itemTimeForHostTime:outputItemTime.value];
    if([[self videoOutput] hasNewPixelBufferForItemTime:outputItemTime])
    {
        [self updateTexture:[[self videoOutput] copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL]];
    }
    self.timePlaying = outputItemTime;
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    [self.testModel draw];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.testModel.prs setRotationConstantToVector:GLKVector3Make(0.0f, 0.0f, 1.0f)];
}

@end
