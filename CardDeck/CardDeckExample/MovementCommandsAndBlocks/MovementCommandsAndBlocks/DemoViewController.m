//
//  DemoViewController.m
//  MovementCommandsAndBlocks
//
//  Created by John Stricker on 3/28/14.
//  Copyright (c) 2014 John Stricker. All rights reserved.
//

#import "DemoViewController.h"
#import <SSGOGL/SSGOpenGLManager.h>
#import <SSGOGL/SSG2DZConverter.h>
#import <SSGOGL/SSGModel.h>
#import <SSGOGL/SSGAssetManager.h>
#import <SSGOGL/SSGPrs.h>
#import <SSGOGL/SSGCommand.h>

@interface DemoViewController ()

@property (nonatomic, strong) SSGOpenGLManager *glmgr;
@property (nonatomic, strong) SSGModel *model;

@end

@implementation DemoViewController

static const GLfloat mainZ = -50.0f;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.glmgr = [[SSGOpenGLManager alloc] initWithContextRef:((GLKView *)self.view).context andView:(GLKView*)self.view];
    //load the default shader
    [self.glmgr loadDefaultShaderAndSettings];
    
    //main background color of the window (including transparency)
    [self.glmgr setClearColor:GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f)];
    
    //setting up perspective, with the logo you probably don't want too much of a field of view effect, so a 5 degree field of view is used
    self.glmgr.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(10.0f), fabsf(self.view.bounds.size.width / self.view.bounds.size.height), 0.1f, 100.0f);
    
    //settings for max smoothness in animation & display
    self.preferredFramesPerSecond = 60;
    ((GLKView*)self.view).drawableMultisample = GLKViewDrawableMultisample4X;
    
    self.model = [[SSGModel alloc] initWithModelFileName:@"oddShape"];
    [self.model setTexture0Id: [SSGAssetManager loadTexture:@"brSwirl" ofType:@"png" shouldLoadWithMipMapping:YES]];
    self.model.projection = self.glmgr.projectionMatrix;
    self.model.defaultShaderSettings = self.glmgr.defaultShaderSettings;
    self.model.prs.pz = mainZ;
    [self.model.prs setRotationConstantToVector:GLKVector3Make(0.3f, -0.3f, 0.2f)];
    
    [self.model addCommand:[SSGCommand commandWithEnum:kSSGCommand_moveTo Target:command3float(0.5f, 2.0f, 0.0f) Duration:2.0f IsAbsolute:NO Delay:1.0f]];
    [self.model addCommand:[SSGCommand commandWithEnum:kSSGCommand_moveTo Target:command3float(-1.0f, -4.0f, 0.0f) Duration:2.0f IsAbsolute:NO Delay:3.0f]];
    
    
}

- (void)update
{
    [self.model updateWithTime:self.timeSinceLastUpdate];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    [self.model draw];
}

@end
