//
//  RZLogoViewController.m
//  RZLogo
//
//  Created by John Stricker on 3/21/14.
//  Copyright (c) 2014 John Stricker. All rights reserved.
//

#import "RZLogoViewController.h"
#import <SSGOGL/SSGOpenGLManager.h>
#import <SSGOGL/SSG2DZConverter.h>
#import <SSGOGL/SSGModel.h>
#import <SSGOGL/SSGPosition.h>
#import <SSGOGL/SSGOrientation.h>
#import <SSGOGL/SSGAssetManager.h>
#import <SSGOGL/SSGWorldTransformation.h>
#import <SSGOGL/SSGPrs.h>
#import <SSGOGL/SSGCommand.h>
#import <CoreMotion/CoreMotion.h>

@interface RZLogoViewController ()

@property (nonatomic, strong) SSGOpenGLManager *glmgr;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLfloat mainZ;
@property (nonatomic, strong) NSArray *rzLogo;
@property (nonatomic, strong) NSArray *rzLogo2;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, assign) GLKVector3 initialSetting;

@end

@implementation RZLogoViewController

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
    self.glmgr.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(5.0f), fabsf(self.view.bounds.size.height / self.view.bounds.size.width), 0.1f, 100.0f);
    self.glmgr.zConverter = [[SSG2DZConverter alloc] initWithScreenHeight:self.view.bounds.size.width ScreenWidth:self.view.bounds.size.height Fov:GLKMathDegreesToRadians(45.0f)];
    
    //settings for max smoothness in animation & display
    self.preferredFramesPerSecond = 60;
   // ((GLKView*)self.view).drawableMultisample = GLKViewDrawableMultisample4X;
    
    //Z location for logo in 3D space
    self.mainZ = -32.0f;
    
    //loading models
    SSGModel *logo1 = [[SSGModel alloc] initWithModelFileName:@"rzR"];
    SSGModel *logo2 = [[SSGModel alloc] initWithModelFileName:@"rzRing1"];
    SSGModel *logo3 = [[SSGModel alloc] initWithModelFileName:@"rzRing2"];
    SSGModel *logo4 = [[SSGModel alloc] initWithModelFileName:@"rzRing3"];
    
    //put them in the logo array
    self.rzLogo = @[logo1,logo2,logo3,logo4];
    
    //setting the constant rotation values for the rings
    GLfloat sm = 1.0f; //speed modifier
    GLfloat rotationDelay = 15.0f;
   
    [logo2 addCommand:[SSGCommand commandWithEnum:kSSGCommand_constantRotation Target:command3float(0.0f, 1.0f*sm, 0.0f) Duration:0 IsAbsolute:NO Delay:rotationDelay]];
    [logo3 addCommand:[SSGCommand commandWithEnum:kSSGCommand_constantRotation Target:command3float(0.75*sm, 0.0f, 0.0f) Duration:0 IsAbsolute:NO Delay:rotationDelay]];
    [logo4 addCommand:[SSGCommand commandWithEnum:kSSGCommand_constantRotation Target:command3float(-0.5f*sm, -0.5f*sm, 0.0f) Duration:0 IsAbsolute:NO Delay:rotationDelay]];

    for(SSGModel *m in self.rzLogo)
    {
        [m setProjection:self.glmgr.projectionMatrix];
        [m setTexture0Id:[SSGAssetManager loadTexture:@"raizLabsRed" ofType:@"png" shouldLoadWithMipMapping:NO]];
        [m setDefaultShaderSettings:self.glmgr.defaultShaderSettings];
        //diffuse lighting color
        m.diffuseColor = GLKVector4Make(1.0f, 0.0f, 0.0f, 1.0f);
        //parameter for how prominent shadows are for the single light source default shader (0 to 0.5, larger values = more shadows)
        m.shadowMax = 0.3f;
        
        m.prs.pz = self.mainZ;
        //setting the scale values for the model
        m.prs.sxyz = 0.25f;
        //alpha (transparency) value
        m.alpha = 0.0f;
        //best to fade in a model on load as there is a bit of stutter in GLKView when it first loads
        [m addCommand:[SSGCommand commandWithEnum:kSSGCommand_alpha Target:command1float(0.5f) Duration:2.0f IsAbsolute:YES Delay:5.0f]];
    }
    
    SSGModel *logo1b = [[SSGModel alloc] initWithModelFileName:@"rzR"];
    SSGModel *logo2b = [[SSGModel alloc] initWithModelFileName:@"rzRing1"];
    SSGModel *logo3b = [[SSGModel alloc] initWithModelFileName:@"rzRing2"];
    SSGModel *logo4b = [[SSGModel alloc] initWithModelFileName:@"rzRing3"];
    
    //put them in the logo array
    self.rzLogo2 = @[logo1b,logo2b,logo3b,logo4b];
    
    for(SSGModel *m in self.rzLogo2)
    {
        [m setProjection:self.glmgr.projectionMatrix];
        [m setTexture0Id:[SSGAssetManager loadTexture:@"raizLabsRed" ofType:@"png" shouldLoadWithMipMapping:NO]];
        [m setDefaultShaderSettings:self.glmgr.defaultShaderSettings];
        //diffuse lighting color
        m.diffuseColor = GLKVector4Make(1.0f, 0.0f, 0.0f, 1.0f);
        //parameter for how prominent shadows are for the single light source default shader (0 to 0.5, larger values = more shadows)
        m.shadowMax = 0.3f;
        m.prs.py = -1.0f;
        m.prs.pz = self.mainZ;
        //setting the scale values for the model
        m.prs.sxyz = 0.25f;
        //alpha (transparency) value
        m.alpha = 0.0f;
        //best to fade in a model on load as there is a bit of stutter in GLKView when it first loads
        [m addCommand:[SSGCommand commandWithEnum:kSSGCommand_alpha Target:command1float(0.5f) Duration:2.0f IsAbsolute:YES Delay:5.0f]];
    }
    GLfloat scaleValue = 5.0f;
    logo2b.prs.sz = scaleValue;
    logo3b.prs.sz = scaleValue;
    logo4b.prs.sz = scaleValue;
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 1.0/60.0;
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical];
}


- (void)update
{
    static float c = 0.4f;
    
    for(SSGModel *m in self.rzLogo)
    {
        [m updateWithTime:self.timeSinceLastUpdate];
        
        CMAttitude *att = self.motionManager.deviceMotion.attitude;
      //  m.prs.rx = -att.pitch;
        m.prs.ry = -att.roll * c;
    }
    
    for(SSGModel *m in self.rzLogo2)
    {
        [m updateWithTime:self.timeSinceLastUpdate];
        
        CMAttitude *att = self.motionManager.deviceMotion.attitude;
        //  m.prs.rx = -att.pitch;
        m.prs.ry = -att.roll * c;
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    for(SSGModel *m in self.rzLogo)
    {
        [m draw];
    }
    for(SSGModel *m in self.rzLogo2)
    {
        [m draw];
    }
}

@end
