//
//  ViewController.m
//  CareHuds
//
//  Created by John Stricker on 3/27/14.
//  Copyright (c) 2014 John Stricker. All rights reserved.
//

#import "ViewController.h"
#import <SSGOGL/SSGOpenGLManager.h>
#import <SSGOGL/SSG2DZConverter.h>
#import <SSGOGL/SSGModel.h>
#import <SSGOGL/SSGAssetManager.h>
#import <SSGOGL/SSGPrs.h>
#import <SSGOGL/SSGCommand.h>

#define kNhuds 4
#define kRingsAlphaMax 0.4f
#define kSpheresAlphaMax 1.0f
#define kCurvesALphaMax 0.3f
#define kFadeDuration 1.0f

@interface ViewController ()

@property (nonatomic, strong) SSGOpenGLManager *glmgr;
@property (nonatomic, assign) GLfloat mainZ;
@property (nonatomic, strong) NSArray *rings;
@property (nonatomic, strong) NSArray *spheres;
@property (nonatomic, strong) NSArray *curves;
@property (nonatomic, strong) NSArray *spheres2;
@property (nonatomic, strong) NSArray *allModels;
@property (nonatomic, assign) int hudIndex;



@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //engine setup
    self.glmgr = [[SSGOpenGLManager alloc] initWithContextRef:((GLKView *)self.view).context andView:(GLKView*)self.view];
    //load the default shader
    [self.glmgr loadDefaultShaderAndSettings];
    
    //main background color of the window (including transparency)
    [self.glmgr setClearColor:GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f)];
    
    //setting up perspective, with the logo you probably don't want too much of a field of view effect, so a 5 degree field of view is used
    self.glmgr.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(10.0f), fabsf(self.view.bounds.size.width / self.view.bounds.size.height), 0.1f, 100.0f);
    
    //settings for max smoothness in animation & display
    self.preferredFramesPerSecond = 60;
    ((GLKView*)self.view).drawableMultisample = GLKViewDrawableMultisample4X;
    
    //Z location for huds in 3D space
    self.mainZ = -70.0f;
    
    SSGModel *ring1 = [[SSGModel alloc] initWithModelFileName:@"ring1"];
    SSGModel *ring2 = [[SSGModel alloc] initWithModelFileName:@"ring2"];
    SSGModel *ring3 = [[SSGModel alloc] initWithModelFileName:@"ring3"];
    self.rings = @[ring1, ring2, ring3];
    
    SSGModel *sphere1 = [[SSGModel alloc] initWithModelFileName:@"sphere1"];
    SSGModel *sphere2 = [[SSGModel alloc] initWithModelFileName:@"sphere2"];
    SSGModel *sphere3 = [[SSGModel alloc] initWithModelFileName:@"sphere3"];
    self.spheres = @[sphere1, sphere2, sphere3];
    
    SSGModel *curve1 = [[SSGModel alloc] initWithModelFileName:@"curve1"];
    SSGModel *curve2 = [[SSGModel alloc] initWithModelFileName:@"curve2"];
    SSGModel *curve3 = [[SSGModel alloc] initWithModelFileName:@"curve3"];
    self.curves = @[curve1, curve2, curve3];
    
    SSGModel *sphere21 = [[SSGModel alloc] initWithModelFileName:@"sphere1"];
    SSGModel *sphere22 = [[SSGModel alloc] initWithModelFileName:@"sphere2"];
    SSGModel *sphere23 = [[SSGModel alloc] initWithModelFileName:@"sphere3"];
    self.spheres2 = @[sphere21, sphere22, sphere23];
    
    self.allModels = @[ring1, ring2, ring3, sphere1, sphere2, sphere3, curve1, curve2, curve3, sphere21, sphere22, sphere23];
    
    for(SSGModel *m in self.allModels)
    {
        [m setProjection:self.glmgr.projectionMatrix];
        [m setTexture0Id:[SSGAssetManager loadTexture:@"careColors" ofType:@"png" shouldLoadWithMipMapping:YES]];
        [m setDefaultShaderSettings:self.glmgr.defaultShaderSettings];
        //diffuse lighting color
        m.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
        //parameter for how prominent shadows are for the single light source default shader (0 to 0.5, larger values = more shadows)
        m.shadowMax = 0.1f;
        
        m.prs.pz = self.mainZ;
        //setting the scale values for the model
        m.prs.sxyz = 1.0f;
        //alpha (transparency) value
        m.alpha = 0.0f;
        //best to fade in a model on load as there is a bit of stutter in GLKView when it first loads
    }
    
    [self fadeModelArray:self.rings ToAbsoluteAlpha:kRingsAlphaMax WithDuration: kFadeDuration Delay: 1.0f];
    
    [self setVisibilityForModelArray:self.spheres toValue:NO afterDelay:0.0f];
    [self setVisibilityForModelArray:self.curves toValue:NO afterDelay:0.0f];
    
    [self setRotationConstants];
    
    for(SSGModel *m in self.spheres)
    {
        m.prs.sxyz = 1.5f;
    }
    
    for(SSGModel *m in self.spheres2)
    {
        m.prs.sxyz = 1.5f;
        m.prs.py = m.prs.py - 0.5f;
        
    }
    
}

- (void)setRotationConstants
{
    [((SSGModel*)self.rings[0]).prs setRotationConstantToVector:GLKVector3Make(1.0f, -9.0f, 0.0f)];
    [((SSGModel*)self.rings[1]).prs setRotationConstantToVector:GLKVector3Make(-1.0f, 6.0f, 0.0f)];
    [((SSGModel*)self.rings[2]).prs setRotationConstantToVector:GLKVector3Make(1.0f, 6.0f, 0.0f)];
    
    [((SSGModel*)self.spheres[0]).prs setRotationConstantToVector:GLKVector3Make(0.0f, 0.0f, 12.0f)];
    [((SSGModel*)self.spheres[1]).prs setRotationConstantToVector:GLKVector3Make(0.0f, 0.0f, 10.0f)];
    [((SSGModel*)self.spheres[2]).prs setRotationConstantToVector:GLKVector3Make(0.0f, 0.0f, 8.0f)];
    
    [((SSGModel*)self.curves[0]).prs setRotationConstantToVector:GLKVector3Make(0.0f, 20.0f, 3.0f)];
    [((SSGModel*)self.curves[1]).prs setRotationConstantToVector:GLKVector3Make(0.0f, 18.0f, 3.0f)];
    [((SSGModel*)self.curves[2]).prs setRotationConstantToVector:GLKVector3Make(0.0f, 16.0f, 3.0f)];
}

- (void)setSphere2MotionWithStartDelay:(GLfloat)startDelay
{
    GLfloat startingX = -4.0f;
    GLfloat midX = 0.0f;
    GLfloat endingX = 4.0f;
    GLfloat midY = 1.0f;
    GLfloat duration = 0.2f;
    
    for(SSGModel *m in self.spheres2)
    {
        GLfloat initialY = m.prs.py;
        [m clearAllCommands];
        m.prs.px = startingX;
        
        SSGCommand *command = [SSGCommand commandWithEnum:kSSGCommand_moveTo Target:command3float(midX, midY, self.mainZ) Duration:duration IsAbsolute:YES Delay:startDelay];
            command.commandOnFinish = [SSGCommand commandWithEnum:kSSGCommand_moveTo Target:command3float(endingX, initialY, self.mainZ) Duration:duration IsAbsolute:YES Delay:0.0f];
            [m addCommand:command];
      
    }
}


- (void)fadeModelArray:(NSArray *)models ToAbsoluteAlpha:(GLfloat)alpha WithDuration:(GLfloat)duration Delay:(GLfloat)delay
{
    for(SSGModel *m in models)
    {
        [m addCommand:[SSGCommand commandWithEnum:kSSGCommand_alpha Target:command1float(alpha) Duration:duration IsAbsolute:YES Delay:delay]];
    }
    
}

- (void)setVisibilityForModelArray:(NSArray *)models toValue:(BOOL)value afterDelay:(GLfloat)delay
{
    for(SSGModel *m in models)
    {
        [m addCommand:[SSGCommand commandWithEnum:kSSGCommand_visible Target:command1Bool(value) Duration:0 IsAbsolute:YES Delay:delay]];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.hudIndex == 0){
        [self fadeModelArray:self.rings ToAbsoluteAlpha:0.0f WithDuration:kFadeDuration Delay:0.0f];
        [self fadeModelArray:self.spheres ToAbsoluteAlpha:kSpheresAlphaMax WithDuration:kFadeDuration Delay:kFadeDuration];
        [self setVisibilityForModelArray:self.rings toValue:NO afterDelay:kFadeDuration];
        [self setVisibilityForModelArray:self.spheres toValue:YES afterDelay:kFadeDuration];
        ++self.hudIndex;
    } else if(self.hudIndex == 1) {
        [self fadeModelArray:self.spheres ToAbsoluteAlpha:0.0f WithDuration:kFadeDuration Delay:0.0f];
        [self fadeModelArray:self.curves ToAbsoluteAlpha:kCurvesALphaMax WithDuration:kFadeDuration Delay:kFadeDuration];
        [self setVisibilityForModelArray:self.spheres toValue:NO afterDelay:kFadeDuration];
        [self setVisibilityForModelArray:self.curves toValue:YES afterDelay:kFadeDuration];
        ++self.hudIndex;
    } else if(self.hudIndex == 2) {
        [self fadeModelArray:self.curves ToAbsoluteAlpha:0.0f WithDuration:kFadeDuration Delay:0.0f];
        [self fadeModelArray:self.spheres2 ToAbsoluteAlpha:kCurvesALphaMax WithDuration:kFadeDuration Delay:kFadeDuration];
        [self setVisibilityForModelArray:self.curves toValue:NO afterDelay:kFadeDuration];
        [self setVisibilityForModelArray:self.spheres2 toValue:YES afterDelay:kFadeDuration];
        [self setSphere2MotionWithStartDelay:kFadeDuration*2];
        ++self.hudIndex;
    } else if(self.hudIndex == 3) {
        [self fadeModelArray:self.spheres2 ToAbsoluteAlpha:0.0f WithDuration:kFadeDuration Delay:0.0f];
        [self fadeModelArray:self.rings ToAbsoluteAlpha:kCurvesALphaMax WithDuration:kFadeDuration Delay:kFadeDuration];
        [self setVisibilityForModelArray:self.spheres2 toValue:NO afterDelay:kFadeDuration];
        [self setVisibilityForModelArray:self.rings toValue:YES afterDelay:kFadeDuration];
        self.hudIndex = 0;
    }
}

- (void)update
{
    for(SSGModel *m in self.allModels)
    {
        [m updateWithTime:self.timeSinceLastUpdate];
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    for(SSGModel *m in self.allModels)
    {
        [m draw];
    }

}
@end
