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

@interface StreamingDemoViewController ()
@property (nonatomic, strong) SSGOpenGLManager *glmgr;
@property (nonatomic, strong) SSGModel *testModel;
@property (nonatomic, assign) GLfloat mainZ;
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
    [self.glmgr setClearColor:GLKVector4Make(0.0f, 0.0f, 1.0f, 0.0f)];
    
    //setting up perspective, with the logo you probably don't want too much of a field of view effect, so a 5 degree field of view is used
    self.glmgr.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(50.0f), fabsf(self.view.bounds.size.width / self.view.bounds.size.height), 0.1f, 100.0f);
    self.glmgr.zConverter = [[SSG2DZConverter alloc] initWithScreenHeight:self.view.bounds.size.width ScreenWidth:self.view.bounds.size.height Fov:GLKMathDegreesToRadians(45.0f)];
    
    //settings for max smoothness in animation & display
    self.preferredFramesPerSecond = 60;
    ((GLKView*)self.view).drawableMultisample = GLKViewDrawableMultisample4X;
    
    //Z location for logo in 3D space
    self.mainZ = -7.0f;
    self.testModel = [[SSGModel alloc] initWithModelFileName:@"quadCropped"];
    [self.testModel setTexture0Id:[SSGAssetManager loadTexture:@"iphone5GridTexture" ofType:@"png" shouldLoadWithMipMapping:NO]];
    self.testModel.shadowMax = 0.9f;
    self.testModel.projection = self.glmgr.projectionMatrix;
    self.testModel.defaultShaderSettings = self.glmgr.defaultShaderSettings;
    self.testModel.prs.pz = self.mainZ;
}

- (void)update
{
    [self.testModel updateWithTime:self.timeSinceLastUpdate];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    [self.testModel draw];
}

@end
