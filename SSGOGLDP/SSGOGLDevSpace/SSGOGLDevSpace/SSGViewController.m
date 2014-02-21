//
//  SSGViewController.m
//  SSGOGLDevSpace
//
//  Created by John Stricker on 12/9/13.
//  Copyright (c) 2013 Sway Software. All rights reserved.
//

#import "SSGViewController.h"

#import <SSGOGL/SSGOpenGLManager.h>
#import <SSGOGL/SSG2DZConverter.h>
#import <SSGOGL/SSGModel.h>
#import <SSGOGL/SSGPosition.h>
#import <SSGOGL/SSGOrientation.h>
#import <SSGOGL/SSGAssetManager.h>
#import <SSGOGL/SSGWorldTransformation.h>
#import <SSGOGL/SSGPrs.h>
#import "SSGHud.h"

@interface SSGViewController ()
@property (nonatomic) SSGOpenGLManager *glmgr;
@property (nonatomic) EAGLContext *context;
@property (nonatomic) GLKVector4 mainClearColor;
@property (nonatomic) SSGModel *ship;
@property (nonatomic) SSGModel *ship2;
@property (nonatomic) SSGHud *hudVC;
@property (nonatomic) BOOL firstLoadComplete;
@property (nonatomic) BOOL touchDownOccured;
@property (nonatomic) BOOL rotationStarted;
@property (nonatomic) GLfloat mainZ;
@property (nonatomic) SSGWorldTransformation *worldTransformation;
@end

@implementation SSGViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
   // [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.glmgr = [[SSGOpenGLManager alloc] initWithContextRef:self.context andView:(GLKView*)self.view];
    [self.glmgr loadDefaultShaderAndSettings];
    self.mainClearColor = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
    [self.glmgr setClearColor:self.mainClearColor];
    self.glmgr.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45.0f), fabsf(self.view.bounds.size.height / self.view.bounds.size.width), 0.1f, 100.0f);
    self.glmgr.zConverter = [[SSG2DZConverter alloc] initWithScreenHeight:self.view.bounds.size.width ScreenWidth:self.view.bounds.size.height Fov:GLKMathDegreesToRadians(45.0f)];
    self.view.multipleTouchEnabled = YES;
    self.preferredFramesPerSecond = 60;
    self.view.multipleTouchEnabled = YES;
    
    self.mainZ = -8.0f;
    
    self.worldTransformation = [[SSGWorldTransformation alloc] init];
    self.worldTransformation.position = [[SSGPosition alloc] initWithX:0 Y:0 Z:0];
    self.worldTransformation.orientation = [[SSGOrientation alloc] initWithUpVector:GLKVector3Make(0, 1, 0) upAngle:0 ForwardVector:GLKVector3Make(0, 0, 1) ForwardAngle:0 RightVector:GLKVector3Make(1, 0, 0) RightAngle:0];
    
    self.ship = [[SSGModel alloc] initWithModelFileName:@"raizlabsLogo"];
    [self.ship setProjection:_glmgr.projectionMatrix];
    [self.ship setTexture0Id:[SSGAssetManager loadTexture:@"raizLabsRed" ofType:@"png" shouldLoadWithMipMapping:YES]];
    [self.ship setDefaultShaderSettings:_glmgr.defaultShaderSettings];
    [self.ship setDimensions2dX:1.0f andY:1.0f];
    self.ship.alpha = 1.0f;
    self.ship.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    self.ship.shadowMax = 0.4f;
    self.ship.prs.pz = _mainZ;
    [self.ship.prs moveToVector:GLKVector3Make(-1.0f, 1.0f, 0.0f) Duration:2.0f Delay:1.0f IsAbsolute:NO];
    [self.ship.prs moveToVector:GLKVector3Make(2.0f, -1.0f, self.mainZ) Duration:1.0f Delay:0.0f IsAbsolute:YES];
    [self.ship.prs setRotationConstantToVector:GLKVector3Make(0.0f, -M_PI, 0.0f)];
    [self.ship.prs rotateToVector:GLKVector3Make(0.0f,0.0f, M_PI) Duration:2.0f Delay:2.0f IsAbsolute:YES];
    [self.ship.prs rotateToVector:GLKVector3Make(0.0f, 0.0f, 0.0f) Duration:2.0f Delay:4.0f IsAbsolute:YES];
    [self.ship.prs scaleToVector:GLKVector3Make(2.0f, 2.0f, 2.0f) Duration:1.0f Delay:4.0f IsAbsolute:YES];
    [self.ship.prs scaleToVector:GLKVector3Make(0.5f, 0.5f, 0.5f) Duration:1.0f Delay:0.0f IsAbsolute:YES];
    
    self.ship2 = [[SSGModel alloc] initWithModelFileName:@"torus"];
    [self.ship2 setProjection:_glmgr.projectionMatrix];
    [self.ship2 setTexture0Id:[SSGAssetManager loadTexture:@"aquaTile" ofType:@"png" shouldLoadWithMipMapping:YES]];
    [self.ship2 setDefaultShaderSettings:_glmgr.defaultShaderSettings];
    [self.ship2 setDimensions2dX:1.0f andY:1.0f];
    self.ship2.alpha = 1.0f;
    self.ship2.diffuseColor = GLKVector4Make(0.0f, 0.0f, 1.0f, 1.0f);
    self.ship2.shadowMax = 0.4f;
    self.ship2.prs.px = -1.0f;
    self.ship2.prs.pz = _mainZ;
    [self.ship2.prs setRotationConstantToVector:GLKVector3Make(M_PI, -M_PI_2, -1.0f)];
     UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchDetected:)];
    [self.view addGestureRecognizer:pinchRecognizer];

}
-(void)viewDidAppear:(BOOL)animated
{
    if(!_firstLoadComplete)
    {
        self.firstLoadComplete = YES;
        self.hudVC = [[SSGHud alloc] initWithNibName:@"SSGHud" bundle:nil];
        self.hudVC.view.frame = CGRectMake(0, self.view.frame.size.width - _hudVC.view.frame.size.height, self.hudVC.view.frame.size.width, self.hudVC.view.frame.size.height);
        [self.view addSubview:self.hudVC.view];
        self.hudVC.delegate = self;
        self.paused = YES;
    }
}

-(void)hudResetToStartingPosition
{
    self.ship.prs.px = 0.0f;
    self.ship.prs.py = 0.0f;
    self.ship.prs.pz = _mainZ;
    
    self.glmgr.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45.0f), fabsf(self.view.bounds.size.width / self.view.bounds.size.height), 0.1f, 100.0f);
    [self.ship setProjection:_glmgr.projectionMatrix];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!_hudVC.switchOn)
    {
        self.paused = !self.paused;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!_hudVC || !_hudVC.switchOn)
    {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint cLoc = [touch locationInView:self.view];
    CGPoint tCloc = [self.glmgr.zConverter convertScreenCoordsX:cLoc.x Y:cLoc.y ProjectedZ:_ship.prs.pz];
    
    CGPoint pLoc = [touch previousLocationInView:self.view];
    CGPoint tPloc = [self.glmgr.zConverter convertScreenCoordsX:pLoc.x Y:pLoc.y ProjectedZ:_ship.prs.pz];
    CGPoint transMovePt = CGPointMake(tCloc.x - tPloc.x, tCloc.y - tPloc.y);
    
    if(_hudVC.moveObj)
    {
        if(_hudVC.currentState != SSGHudTransformationStateTranslate)
        {
            if(_rotationStarted)
            {
                /*
                GLfloat angle = (transMovePt.x + transMovePt.y)*1.1f;
                if(_hudVC.currentState == SSGHudTransformationStateRotateX)
                {
                    [self.ship.orientation pitch:angle];
                }
                else if(_hudVC.currentState == SSGHudTransformationStateRotateY)
                {
                    [self.ship.orientation roll:angle];
                }
                else if(_hudVC.currentState == SSGHudTransformationStateRotateZ)
                {
                    [self.ship.orientation yaw:angle];
                }
                 */
            }
            else
            {
                _rotationStarted = YES;
            }
        }
        else
        {
            self.ship.prs.px += transMovePt.x;
            self.ship.prs.py += transMovePt.y;
        }
      //  NSLog(@"touch diff:(%f,%f)",transMovePt.x,transMovePt.y);
    }
    else
    {
        if(_hudVC.currentState != SSGHudTransformationStateTranslate)
        {
            if(_hudVC.currentState == SSGHudTransformationStateRotateX)
            {
                [self.worldTransformation.orientation pitch:((transMovePt.x + transMovePt.y)*1.1f)];
            }
            else if(_hudVC.currentState == SSGHudTransformationStateRotateY)
            {
                [self.worldTransformation.orientation yaw:((transMovePt.x + transMovePt.y)*1.1f)];
            }
            else if(_hudVC.currentState == SSGHudTransformationStateRotateZ)
            {
                [self.worldTransformation.orientation roll:((transMovePt.x + transMovePt.y)*1.1f)];
            }
        }
        else
        {
            self.worldTransformation.position.x += transMovePt.x;
            self.worldTransformation.position.y += transMovePt.y;
        }
    }
}

- (void)pinchDetected:(UIPinchGestureRecognizer *)pinchRecognizer
{
    if(!_hudVC || !_hudVC.switchOn)
    {
        return;
    }
    
    CGFloat scale = pinchRecognizer.scale -1.0f;
    pinchRecognizer.scale = 1.0;
    if(_hudVC.moveObj)
    {
        _ship.prs.pz += scale;
    }
    else
    {
        self.worldTransformation.position.z += scale;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.rotationStarted = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.rotationStarted = NO;
}

- (void)update
{
    
    [self.ship2 updateWithTime:self.timeSinceLastUpdate];
    [self.ship updateWithTime:self.timeSinceLastUpdate];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
   [_glmgr setClearColor:_mainClearColor];
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
   [_ship draw];
   [_ship2 draw];
}

- (void)dealloc
{
    [self.glmgr unload];
    [SSGAssetManager unload];
}

@end
