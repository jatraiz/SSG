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
#import <SSGOGL/SSGModelData.h>

@interface DemoViewController ()
@property (nonatomic, strong) SSGOpenGLManager *glmgr;
@property (nonatomic, assign) GLfloat mainZ;
@property (nonatomic, strong) CardViewController *cardViewController;
@property (nonatomic, strong) SSGModel *flatRect;
@property (nonatomic, strong) GLKTextureInfo *textureInfo;
@property (nonatomic, strong) UIImage *viewImage;
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
    self.glmgr.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(10.0f), fabsf(self.view.bounds.size.width / self.view.bounds.size.height), 0.1f, 200.0f);
    self.glmgr.zConverter = [[SSG2DZConverter alloc] initWithScreenHeight:self.view.bounds.size.height ScreenWidth:self.view.bounds.size.width Fov:GLKMathDegreesToRadians(10.0f)];
    
    self.mainZ = -50.0f;
    
    self.view.opaque = NO;
    
    //settings for max smoothness in animation & display
    self.preferredFramesPerSecond = 60;
    ((GLKView*)self.view).drawableMultisample = GLKViewDrawableMultisample4X;
    
    self.cardViewController = [CardViewController new];
    [self.view addSubview:self.cardViewController.view];
    CGRect frame = self.cardViewController.view.frame;
    frame.origin.x = (self.view.frame.size.width - self.cardViewController.view.frame.size.width) / 2.0f;
    frame.origin.y = (self.view.frame.size.height - self.cardViewController.view.frame.size.height) / 2.0f;
    self.cardViewController.view.frame = frame;
    
    self.flatRect = [[SSGModel alloc] initWithModelFileName:nil];
    self.flatRect.defaultShaderSettings = self.glmgr.defaultShaderSettings;
    self.flatRect.projection = self.glmgr.projectionMatrix;
   // [self.flatRect setTexture0Id:[SSGAssetManager loadTexture:@"brSwirl" ofType:@"png" shouldLoadWithMipMapping:YES]];
    self.flatRect.prs.pz = self.mainZ;
    self.flatRect.alpha = 1.0f;
    self.flatRect.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    
    CGPoint topLeft = [self.glmgr.zConverter convertScreenCoordsX:frame.origin.x Y:frame.origin.y ProjectedZ: self.mainZ];
    CGPoint bottomRight= [self.glmgr.zConverter convertScreenCoordsX:frame.origin.x + frame.size.width Y:frame.origin.y + frame.size.height ProjectedZ:self.mainZ];
    
    [self create2DrectWithTopLeft:topLeft BottomRight:bottomRight];
}

- (void)create2DrectWithTopLeft:(CGPoint)topLeft BottomRight:(CGPoint)bottomRight;
{
    SSGModelData *md = (SSGModelData*)malloc(sizeof(SSGModelData));
    md->arrayCount = 48;
    md->arrayRows = 6;
    md->arraySize = md->arrayCount * sizeof(GLfloat);
    
    /*
    GLfloat px = -1.0f;
    GLfloat px2 = 1.0f;
    GLfloat py = -1.943731f;
    GLfloat py2 = 1.943731;
     */
    GLfloat px = topLeft.x;
    GLfloat px2 = bottomRight.x;
    GLfloat py = bottomRight.y;
    GLfloat py2 = topLeft.y;
    
    GLfloat pz = 0.0f;
    GLfloat nx = 0.0f;
    GLfloat ny = 0.0f;
    GLfloat nz = 1.0f;
    GLfloat u1 = 0.0f;
    GLfloat u2 = 1.0f;
    GLfloat v1 = 0.0;
    GLfloat v2 = 1.0f;
    
    md->vertexArray = (GLfloat*) malloc(md->arraySize);
    
    int i = 0;
    md->vertexArray[i] = px; md->vertexArray[i+1] = py; md->vertexArray[i+2] = pz;
    md->vertexArray[i+3] = nx; md->vertexArray[i+4] = ny; md->vertexArray[i+5] = nz;
    md->vertexArray[i+6] = u1; md->vertexArray[i+7] = v1;

    i += 8;
    md->vertexArray[i] = px2; md->vertexArray[i+1] = py; md->vertexArray[i+2] = pz;
    md->vertexArray[i+3] = nx; md->vertexArray[i+4] = ny; md->vertexArray[i+5] = nz;
    md->vertexArray[i+6] = u2; md->vertexArray[i+7] = v1;
   
    i += 8;
    md->vertexArray[i] = px; md->vertexArray[i+1] = py2; md->vertexArray[i+2] = pz;
    md->vertexArray[i+3] = nx; md->vertexArray[i+4] = ny; md->vertexArray[i+5] = nz;
    md->vertexArray[i+6] = u1; md->vertexArray[i+7] = v2;
   
    i += 8;
    md->vertexArray[i] = px2; md->vertexArray[i+1] = py; md->vertexArray[i+2] = pz;
    md->vertexArray[i+3] = nx; md->vertexArray[i+4] = ny; md->vertexArray[i+5] = nz;
    md->vertexArray[i+6] = u2; md->vertexArray[i+7] = v1;
    
    i += 8;
    md->vertexArray[i] = px2; md->vertexArray[i+1] = py2; md->vertexArray[i+2] = pz;
    md->vertexArray[i+3] = nx; md->vertexArray[i+4] = ny; md->vertexArray[i+5] = nz;
    md->vertexArray[i+6] = u2; md->vertexArray[i+7] = v2;
    
    i += 8;
    md->vertexArray[i] = px; md->vertexArray[i+1] = py2; md->vertexArray[i+2] = pz;
    md->vertexArray[i+3] = nx; md->vertexArray[i+4] = ny; md->vertexArray[i+5] = nz;
    md->vertexArray[i+6] = u1; md->vertexArray[i+7] = v2;

    
    [self.flatRect setVaoInfo:[SSGAssetManager loadVaoInfoFromData:*md AssignName:@"flatRect"]];
    
    free(md->vertexArray);
    free(md);
}

- (UIImage *) imageWithView:(UIView *)view

{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)update
{
    [self.flatRect updateWithTime:self.timeSinceLastUpdate];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    [self.flatRect draw];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.flatRect.prs.position = GLKVector3Make(0.0f, 0.0f, self.mainZ);
    self.viewImage = [self imageWithView:self.cardViewController.view];
    [self.flatRect.prs setRotationConstantToVector:GLKVector3Make(0.0f, 0.0f, 0.0f)];
    [self.flatRect clearAllCommands];
    if(self.textureInfo)
    {
        const unsigned int n = self.textureInfo.name;
        glDeleteTextures(1, &n);
        self.textureInfo = nil;
    }
    
    self.textureInfo = [GLKTextureLoader textureWithCGImage:[self.viewImage CGImage] options:@{GLKTextureLoaderOriginBottomLeft: @1} error:nil];
    
    [self.flatRect setTexture0Id:self.textureInfo.name];
    self.flatRect.isHidden = NO;
   // [self.flatRect addCommand:[SSGCommand commandWithEnum:kSSGCommand_moveTo Target:command3float(1.0f, 20.0f, -100.0f) Duration:2.0 IsAbsolute:YES Delay:0.0f]];
    [self.flatRect addCommand:[SSGCommand commandWithEnum:kSSGCommand_setConstantRotation Target:command3float(0.0f, 0.0f, 30.0f) Duration:0.0f IsAbsolute:NO Delay:0.0f]];
    
    
    self.cardViewController.view.hidden = !self.cardViewController.view.hidden;
}

@end
