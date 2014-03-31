//
//  PlainViewController.m
//  Removing GLKVC Example
//
//  Created by John Stricker on 3/31/14.
//  Copyright (c) 2014 John Stricker. All rights reserved.
//

#import "PlainViewController.h"
#import <SSGOGL/SSGOpenGLManager.h>
#import <SSGOGL/SSG2DZConverter.h>
#import <SSGOGL/SSGModel.h>
#import <SSGOGL/SSGAssetManager.h>
#import <SSGOGL/SSGPrs.h>
#import <SSGOGL/SSGCommand.h>
#import "ScrollTestViewController.h"


@interface PlainViewController () <GLKViewDelegate>
@property (nonatomic, strong) SSGOpenGLManager *glmgr;
@property (nonatomic, strong) GLKView *glkView;
@property (nonatomic, assign) GLfloat mainZ;
@property (nonatomic, strong) SSGModel *model;
@property (nonatomic, assign) CFTimeInterval timeSinceLastUpdate;
@property (nonatomic, assign) CFTimeInterval lastTimeStamp;
@property (nonatomic, strong) CADisplayLink *displayLink;
@end

@implementation PlainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.glkView = [[GLKView alloc] initWithFrame:self.view.frame];
    self.glkView.delegate = self;
    self.view = self.glkView;
    
    //engine setup
    self.glmgr = [[SSGOpenGLManager alloc] initWithContextRef:((GLKView *)self.view).context andView:(GLKView*)self.view];
    //load the default shader
    [self.glmgr loadDefaultShaderAndSettings];
    
    //main background color of the window (including transparency)
    [self.glmgr setClearColor:GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f)];
    
    //setting up perspective, with the logo you probably don't want too much of a field of view effect, so a 5 degree field of view is used
    self.glmgr.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(20.0f), fabsf(self.view.bounds.size.height / self.view.bounds.size.width), 0.1f, 100.0f);
    
    //settings for max smoothness in animation & display
   // self.preferredFramesPerSecond = 60;
    ((GLKView*)self.view).drawableMultisample = GLKViewDrawableMultisample4X;
    
    //Z location for huds in 3D space
    self.mainZ = -30.0f;
    
    self.glkView.enableSetNeedsDisplay = NO;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.timeSinceLastUpdate = 0.0;
    
    self.model = [[SSGModel alloc] initWithModelFileName:@"oddShape"];
    [self.model setTexture0Id:[SSGAssetManager loadTexture:@"brSwirl" ofType:@"png" shouldLoadWithMipMapping:YES]];
    self.model.projection = self.glmgr.projectionMatrix;
    self.model.defaultShaderSettings = self.glmgr.defaultShaderSettings;
    self.model.prs.pz = self.mainZ;
    self.model.shadowMax = 0.5f;
    
    [self.model.prs setRotationConstantToVector:GLKVector3Make(1.0f, 10.01f, 2.0f)];

}

- (void)render:(CADisplayLink *)displayLink
{
    [self update];
    self.timeSinceLastUpdate = displayLink.timestamp - self.lastTimeStamp;
    [self.glkView display];
    self.lastTimeStamp = displayLink.timestamp;
}

- (void)update
{
    [self.model updateWithTime:(GLfloat)self.timeSinceLastUpdate];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self.model draw];
}



@end
