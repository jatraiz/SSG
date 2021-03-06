//
//  SSGViewController.m
//  SSGFontTester
//
//  Created by John Stricker on 3/7/14.
//  Copyright (c) 2014 John Stricker. All rights reserved.
//
#import <GLKit/GLKit.h>
#import "SSGViewController.h"
#import <SSGOGL/SSGOpenGLManager.h>
#import <SSGOGL/SSG2DZConverter.h>
#import <SSGOGL/SSGModel.h>
#import <SSGOGL/SSGPosition.h>
#import <SSGOGL/SSGOrientation.h>
#import <SSGOGL/SSGAssetManager.h>
#import <SSGOGL/SSGWorldTransformation.h>
#import <SSGOGL/SSGPrs.h>
#import <SSGOGL/SSGCommand.h>
#import <SSGOGL/SSGBMFontModel.h>
#import <SSGOGL/SSGBMFontData.h>


@interface SSGViewController () <UITextFieldDelegate>
@property (nonatomic, strong) SSGOpenGLManager *glmgr;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLKVector4 mainClearColor;
@property (nonatomic, assign) GLfloat mainZ;
@property (nonatomic, strong) NSArray *rzLogo;
@property (nonatomic, strong) SSGBMFontModel *fontModel;
@property (nonatomic, strong) UITextField *textField;
@end

@implementation SSGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.glmgr = [[SSGOpenGLManager alloc] initWithContextRef:self.context andView:(GLKView*)self.view];
    [self.glmgr loadDefaultShaderAndSettings];
    [self.glmgr loadBitmapFontShaderAndSettings];
    self.mainClearColor = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
    [self.glmgr setClearColor:self.mainClearColor];
    self.glmgr.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(5.0f), fabsf(self.view.bounds.size.height / self.view.bounds.size.width), 0.1f, 100.0f);
    self.glmgr.zConverter = [[SSG2DZConverter alloc] initWithScreenHeight:self.view.bounds.size.width ScreenWidth:self.view.bounds.size.height Fov:GLKMathDegreesToRadians(45.0f)];
    self.preferredFramesPerSecond = 60;
    
    GLKView *glkView = (GLKView*)self.view;
    glkView.drawableMultisample = GLKViewDrawableMultisample4X;
    
    self.mainZ = -90.0f;
    
    SSGModel *logo1 = [[SSGModel alloc] initWithModelFileName:@"rzlR"];
    SSGModel *logo2 = [[SSGModel alloc] initWithModelFileName:@"rzlRing1"];
    SSGModel *logo3 = [[SSGModel alloc] initWithModelFileName:@"rzlRing2"];
    SSGModel *logo4 = [[SSGModel alloc] initWithModelFileName:@"rzlRing3"];

    GLfloat sm = 5.0f;
    [logo2.prs setRotationConstantToVector:GLKVector3Make(0.0f, 1.0f*sm, 0.0f)];
    [logo3.prs setRotationConstantToVector:GLKVector3Make(0.75f*sm, 0.0f, 0.0f)];
    [logo4.prs setRotationConstantToVector:GLKVector3Make(-0.5f*sm, -0.5f*sm, 0.0f)];

    self.rzLogo = @[logo1,logo2,logo3,logo4];
    
    for(SSGModel *m in self.rzLogo)
    {
        [m setProjection:self.glmgr.projectionMatrix];
        [m setTexture0Id:[SSGAssetManager loadTexture:@"raizLabsRed" ofType:@"png" shouldLoadWithMipMapping:NO]];
        [m setDefaultShaderSettings:self.glmgr.defaultShaderSettings];
    
        m.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
        m.shadowMax = 0.4f;
        m.prs.pz = self.mainZ;
        m.prs.px = 6.25f;
        m.prs.py = 3.25f;
        m.prs.sxyz = 0.4f;
        m.alpha = 0.0f;
        [m addCommand:[SSGCommand commandWithEnum:kSSGCommand_alpha Target:command1float(0.5f) Duration:30.0f IsAbsolute:YES Delay:0.5f]];
    }
    
    self.fontModel = [[SSGBMFontModel alloc] initWithName:@"fireText" BMFontData:[[SSGBMFontData alloc] initWithFontFile:@"fireText"]];
    [self.fontModel setTexture0Id:[SSGAssetManager loadTexture:@"fireText" ofType:@"png" shouldLoadWithMipMapping:YES]];
    [self.fontModel setProjection:self.glmgr.projectionMatrix];
     self.fontModel.shaderSettings =  self.glmgr.bitmapFontShaderSettings;
    [self.fontModel setupWithCharMax:50];
    self.fontModel.centerHorizontal = YES;
    self.fontModel.centerVertical = NO;
    self.fontModel.prs.pz = -10.0f;
    self.fontModel.prs.py = -0.25f;
    self.fontModel.prs.sxyz = 2.0f;
    self.fontModel.alpha = 1.0f;
    self.fontModel.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    self.fontModel.shadowMax = 0.4f;
    
    self.textField = [UITextField new];
    self.textField.hidden = YES;
    self.textField.delegate = self;
    [self.view addSubview:self.textField];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    GLfloat fontYAdj = 0.1f;
    
    if(self.textField.isFirstResponder)
    {
        [self.textField resignFirstResponder];
        [self.fontModel.prs moveToVector:GLKVector3Make(0.0f, -fontYAdj, 0.0f) Duration:0.2f Delay:0.0f IsAbsolute:NO];
    }
    else
    {
        [self.fontModel.prs moveToVector:GLKVector3Make(0.0f, fontYAdj, 0.0f) Duration:0.2f Delay:0.0f IsAbsolute:NO];
        [self.textField becomeFirstResponder];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([string isEqualToString: @""] && [[self.fontModel getCurrentText] length] <= 1)
    {
        [self.fontModel clearText];
    }
    else
    {
        [self.fontModel updateWithText:[NSString stringWithFormat:@"%@%@",textField.text,string]];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.textField.text = nil;
    [self.fontModel clearText];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.fontModel addCommand:[SSGCommand commandWithEnum:kSSGCommand_font_alternatingSplit Target:command2float(0.5f, 0.5f) Duration:4.0f IsAbsolute:NO Delay:2.0f]];
}

- (void)update
{
    for(SSGModel *m in self.rzLogo)
    {
        [m updateWithTime:self.timeSinceLastUpdate];
    }
   
    [self.fontModel updateWithTime:self.timeSinceLastUpdate];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [_glmgr setClearColor:_mainClearColor];
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
        [self.glmgr enableDepthTest];
   for(SSGModel *m in self.rzLogo)
    {
        [m draw];
    }
   
    [self.glmgr disableDepthTest];
    [self.fontModel draw];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)dealloc
{
    [self.glmgr unload];
}

@end
