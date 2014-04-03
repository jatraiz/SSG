//
//  DemoViewController.m
//  UIViewToTexture
//
//  Created by John Stricker on 4/3/14.
//  Copyright (c) 2014 John Stricker. All rights reserved.
//

#import "DemoViewController.h"
#import <SSGOGL/SSGOpenGLManager.h>
#import <SSGOGL/SSG2DZConverter.h>
#import <SSGOGL/SSGModel.h>
#import <SSGOGL/SSGAssetManager.h>
#import <SSGOGL/SSGPrs.h>
#import <SSGOGL/SSGCommand.h>
#import <SSGOGL/SSGMathUtils.h>
#import "CardViewController.h"

@interface DemoViewController ()
@property (nonatomic, strong) SSGOpenGLManager *glmgr;
@property (nonatomic, strong) CardViewController *cardViewController;
@end

@implementation DemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //engine setup
    self.glmgr = [[SSGOpenGLManager alloc] initWithContextRef:((GLKView *)self.view).context andView:(GLKView *)self.view];
    //load the default shader
    [self.glmgr loadDefaultShaderAndSettings];
    
    //main background color of the window (including transparency)
    [self.glmgr setClearColor:GLKVector4Make(0.0f, 0.2f, 0.0f, 1.0f)];
    
    //setting up perspective
    self.glmgr.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(5.0f), fabsf(self.view.bounds.size.width / self.view.bounds.size.height), 0.1f, 200.0f);
    self.glmgr.zConverter = [[SSG2DZConverter alloc] initWithScreenHeight:self.view.bounds.size.height ScreenWidth:self.view.bounds.size.width Fov:GLKMathDegreesToRadians(5.0f)];
    
    //settings for max smoothness in animation & display
    self.preferredFramesPerSecond = 60;
    ((GLKView*)self.view).drawableMultisample = GLKViewDrawableMultisample4X;
    
    self.cardViewController = [CardViewController new];
    [self.view addSubview:self.cardViewController.view];
    CGRect frame = self.cardViewController.view.frame;
    frame.origin.x = (self.view.frame.size.width - self.cardViewController.view.frame.size.width) / 2.0f;
    frame.origin.y = (self.view.frame.size.height - self.cardViewController.view.frame.size.height) / 2.0f;
    self.cardViewController.view.frame = frame;
}

- (void)update
{
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
}

@end
