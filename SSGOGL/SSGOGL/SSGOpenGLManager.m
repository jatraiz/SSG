//
//  SSGOpenGLManager.m
//  SSGOGL
//
//  Created by John Stricker on 12/9/13.
//  Copyright (c) 2013 Sway Software. All rights reserved.
//

#import "SSGOpenGLManager.h"
#import "SSGShaderManager.h"
#import "SSGDefaultShaderSettings.h"


static BOOL depthTestEnabled;
static GLKVector4 lastClearColor;

@interface SSGOpenGLManager()
@end

@implementation SSGOpenGLManager
-(instancetype)initWithContextRef:(EAGLContext*)context andView:(GLKView*)view
{
    self = [super init];
    if(! self)
    {
        return nil;
    }
    
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if(!context)
    {
        NSLog(@"ERROR: Failed to create ES context");
        return nil;
    }
        
    [EAGLContext setCurrentContext:context];
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_CULL_FACE);
    glEnable(GL_BLEND);
    glEnable(GL_DEPTH_TEST);
    depthTestEnabled = YES;

    view.context = context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    view.multipleTouchEnabled = NO;
    
    return self;
}

-(void)loadDefaultShaderAndSettings
{
    GLuint programId = [SSGShaderManager loadModelDefaultShader];
    self.defaultShaderSettings = [[SSGDefaultShaderSettings alloc] initWithProgramId:programId];
}

//Assumes that depth testing is only changed via a manager class
-(void)enableDepthTest
{
    if(!depthTestEnabled)
    {
        glEnable(GL_DEPTH_TEST);
        depthTestEnabled = YES;
    }
}

//Assumes that depth testing is only changed via a manager class
-(void)disableDepthTest
{
    if(depthTestEnabled)
    {
        glDisable(GL_DEPTH_TEST);
        depthTestEnabled = NO;
    }
}

//Assumes that clear color is only changed via a manager class
-(void)setClearColor:(GLKVector4)clearColor
{
    if(!GLKVector4AllEqualToVector4(clearColor, lastClearColor))
    {
        glClearColor(clearColor.r, clearColor.g, clearColor.b, clearColor.a);
        lastClearColor = clearColor;
    }
}

-(void) unload
{
    if(_defaultShaderSettings)
    {
        glDeleteProgram(_defaultShaderSettings.programId);
    }
}
@end
