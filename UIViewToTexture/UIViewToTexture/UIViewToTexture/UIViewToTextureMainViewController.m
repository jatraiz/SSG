//
//  UIViewToTextureMainViewController.m
//  UIViewToTexture
//
//  Created by John Stricker on 4/4/14.
//  Copyright (c) 2014 John Stricker. All rights reserved.
//

#import "UIViewToTextureMainViewController.h"
#import <SSGOGL/SSGOpenGLManager.h>
#import <SSGOGL/SSG2DZConverter.h>
#import <SSGOGL/SSGModel.h>
#import <SSGOGL/SSGAssetManager.h>
#import <SSGOGL/SSGPrs.h>
#import <SSGOGL/SSGCommand.h>
#import "CardViewController.h"

@interface UIViewToTextureMainViewController ()<GLKViewDelegate>

@property (nonatomic, strong) SSGOpenGLManager *glmgr;
@property (nonatomic, strong) GLKView *glkView;
@property (nonatomic, assign) GLfloat mainZ;
@property (nonatomic, assign) CFTimeInterval timeSinceLastUpdate;
@property (nonatomic, assign) CFTimeInterval lastTimeStamp;
@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, strong) CardViewController *cardViewController;
@property (nonatomic, strong) SSGModel *flatRect;
@property (nonatomic, strong) GLKTextureInfo *textureInfo;
@property (nonatomic, strong) UIImage *viewImage;

@end

@implementation UIViewToTextureMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //settings for max smoothness in animation & display
    self.glkView = [[GLKView alloc] initWithFrame:self.view.frame];
    self.glkView.delegate = self;
    self.view = self.glkView;
    self.glkView.drawableMultisample = GLKViewDrawableMultisample4X;
    
    //engine setup
    self.glmgr = [[SSGOpenGLManager alloc] initWithContextRef:((GLKView *)self.view).context andView:(GLKView*)self.view];
    //load the default shader
    [self.glmgr loadDefaultShaderAndSettings];
    
    //main background color of the window (including transparency)
    [self.glmgr setClearColor:GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f)];
    
    self.glmgr.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(10.0f), fabsf(self.view.bounds.size.width / self.view.bounds.size.height), 0.1f, 200.0f);
    self.glmgr.zConverter = [[SSG2DZConverter alloc] initWithScreenHeight:self.view.bounds.size.height ScreenWidth:self.view.bounds.size.width Fov:GLKMathDegreesToRadians(10.0f)];
    self.mainZ = -50.0f;
    
    self.view.opaque = NO;
    
    //setup displaylink
    self.glkView.enableSetNeedsDisplay = NO;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.timeSinceLastUpdate = 0.0;

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
    
    GLKVector2 topLeft = [self.glmgr.zConverter convertScreenCoordsX:frame.origin.x Y:frame.origin.y ProjectedZ: self.mainZ];
    GLKVector2 bottomRight= [self.glmgr.zConverter convertScreenCoordsX:frame.origin.x + frame.size.width Y:frame.origin.y + frame.size.height ProjectedZ:self.mainZ];
    
    [self create2DrectWithTopLeft:topLeft BottomRight:bottomRight];
    
    [self.flatRect setVaoInfo:[self generateVaoInfo2DGLRectWithTopLeft:topLeft BottomRight:bottomRight andQuadrant:4]];
}

- (SSGVaoInfo*)generateVaoInfo2DGLRectWithTopLeft:(GLKVector2)topLeft BottomRight:(GLKVector2)bottomRight andQuadrant:(GLint)quadrant
{
    //!!! Y is reversed what it should be in model space
    
    GLKVector2 uvBottomLeft = GLKVector2Make(0.0f, 0.0f);
    GLKVector2 uvTopRight = GLKVector2Make(1.0f, 1.0f);
    
    if(quadrant == 0)
    {
        return [self generateVaoInfo2DGLRectWithTopLeft:topLeft BottomRight:bottomRight UVbottomLeft:uvBottomLeft UVTopRight:uvTopRight];
    }
    
    GLfloat modelWidth =  fabsf(bottomRight.x - topLeft.x);
    GLfloat modelHeight = fabsf(bottomRight.y - topLeft.y);
    GLKVector2 adjTopLeft = GLKVector2Make(0.0f, 0.0f);
    GLKVector2 adjBottomRight = GLKVector2Make(0.0f, 0.0f);
    
    if(quadrant == 1)
    {
        adjTopLeft.x = topLeft.x;
        adjBottomRight.x = bottomRight.x - modelWidth * 0.5f;
        adjTopLeft.y = topLeft.y;
        adjBottomRight.y = topLeft.y - modelHeight * 0.5f;
        uvBottomLeft.x = 0.0f;
        uvBottomLeft.y = 0.5f;
        uvTopRight.x = 0.5f;
        uvTopRight.y = 1.0f;
        
    }
    else if(quadrant == 2)
    {
        adjTopLeft.x = topLeft.x + modelWidth * 0.5f;
        adjBottomRight.x = bottomRight.x;
        adjTopLeft.y = topLeft.y;
        adjBottomRight.y = topLeft.y - modelWidth * 0.5f;
        uvBottomLeft.x = 0.5f;
        uvBottomLeft.y = 0.5f;
        uvTopRight.x = 1.0f;
        uvTopRight.y = 1.0f;
    }
    else if(quadrant == 3)
    {
        adjTopLeft.x = topLeft.x;
        adjBottomRight.x = bottomRight.x - modelWidth * 0.5f;
        adjBottomRight.y = bottomRight.y;
        adjTopLeft.y = topLeft.y - modelHeight * 0.5f;
        uvBottomLeft.x = 0.0f;
        uvBottomLeft.y = 0.0f;
        uvTopRight.x = 0.5f;
        uvTopRight.y = 0.5f;
    }
    else if(quadrant == 4)
    {
        adjTopLeft.x = topLeft.x + 0.5 * modelWidth;
        adjBottomRight.x = bottomRight.x;
        adjTopLeft.y = topLeft.y - 0.5f * modelHeight;
        adjBottomRight.y = bottomRight.y;
        
        uvBottomLeft.x = 0.5f;
        uvBottomLeft.y = 0.0f;
        uvTopRight.x = 1.0f;
        uvTopRight.y = 0.5f;
    }
    
    return [self generateVaoInfo2DGLRectWithTopLeft:adjTopLeft BottomRight:adjBottomRight UVbottomLeft:uvBottomLeft UVTopRight:uvTopRight];
}

- (SSGVaoInfo*)generateVaoInfo2DGLRectWithTopLeft:(GLKVector2)topLeft BottomRight:(GLKVector2)bottomRight UVbottomLeft:(GLKVector2)uvBottomLeft UVTopRight:(GLKVector2)uvTopRight
{
    static GLint modelCounter = 0;
    ++modelCounter;
    
    SSGModelData *md = (SSGModelData*)malloc(sizeof(SSGModelData));
    md->arrayCount = 48;
    md->arrayRows = 6;
    md->arraySize = md->arrayCount * sizeof(GLfloat);
    
    GLfloat px = topLeft.x;
    GLfloat px2 = bottomRight.x;
    GLfloat py = bottomRight.y;
    GLfloat py2 = topLeft.y;;
    
    GLfloat pz = 0.0f;
    GLfloat nx = 0.0f;
    GLfloat ny = 0.0f;
    GLfloat nz = 1.0f;
    GLfloat u1 = uvBottomLeft.x; //left corner
    GLfloat u2 = uvTopRight.x;
    GLfloat v1 = uvBottomLeft.y; //bottom corder
    GLfloat v2 = uvTopRight.y;
    
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
    
    SSGVaoInfo *info = [SSGAssetManager loadVaoInfoFromData:*md AssignName:[NSString stringWithFormat:@"flatRect%i",modelCounter]];
    
    free(md->vertexArray);
    free(md);
    
    return info;
}

- (void)create2DrectWithTopLeft:(GLKVector2)topLeft BottomRight:(GLKVector2)bottomRight;
{
    SSGModelData *md = (SSGModelData*)malloc(sizeof(SSGModelData));
    md->arrayCount = 48;
    md->arrayRows = 6;
    md->arraySize = md->arrayCount * sizeof(GLfloat);
    
    GLfloat modelWidth =  fabsf(bottomRight.x - topLeft.x);
    GLfloat modelHeight = fabsf(bottomRight.y - topLeft.y);
    
    GLfloat px = topLeft.x;
    GLfloat px2 = bottomRight.x - modelWidth * 0.5f;
    GLfloat py = bottomRight.y;
    GLfloat py2 = topLeft.y - modelHeight * 0.5f;
    
    GLfloat pz = 0.0f;
    GLfloat nx = 0.0f;
    GLfloat ny = 0.0f;
    GLfloat nz = 1.0f;
    GLfloat u1 = 0.0f; //left corner
    GLfloat u2 = 0.5f;
    GLfloat v1 = 0.0f; //bottom corder
    GLfloat v2 = 0.5f;
    
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

- (void)render:(CADisplayLink *)displayLink
{
    [self update];
    self.timeSinceLastUpdate = displayLink.timestamp - self.lastTimeStamp;
    [self.glkView display];
    self.lastTimeStamp = displayLink.timestamp;
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
    if(!self.cardViewController.view.isHidden)
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
        //     [self.flatRect addCommand:[SSGCommand commandWithEnum:kSSGCommand_moveTo Target:command3float(0.0f, 5.0f, -100.0f) Duration:0.2f IsAbsolute:YES Delay:0.0f]];
        self.cardViewController.view.hidden = YES;
        self.flatRect.isHidden = NO;
   //      [self.flatRect addCommand:[SSGCommand commandWithEnum:kSSGCommand_moveTo Target:command3float(1.0f, 20.0f, -100.0f) Duration:1.0 IsAbsolute:YES Delay:0.0f]];
   //       [self.flatRect addCommand:[SSGCommand commandWithEnum:kSSGCommand_setConstantRotation Target:command3float(0.0f, 0.0f, 30.0f) Duration:0.0f IsAbsolute:NO Delay:0.0f]];
    }
    else
    {
        self.cardViewController.view.hidden = NO;
        self.flatRect.isHidden = YES;
    }
}


@end
