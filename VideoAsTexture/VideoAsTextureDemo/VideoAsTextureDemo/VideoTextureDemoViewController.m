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

@interface VideoTextureDemoViewController ()

@property (nonatomic, strong) SSGOpenGLManager *glmgr;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLfloat mainZ;
@property (nonatomic, strong) SSGModel *quad;


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
    
}


- (void)update
{
    [self.quad updateWithTime:self.timeSinceLastUpdate];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
      glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    [self.quad draw];
}

@end
