//
//  SSGOpenGLManager.h
//  SSGOGL
//
//  Created by John Stricker on 12/9/13.
//  Copyright (c) 2013 Sway Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class SSGDefaultShaderSettings;
@class SSGColoredPSShaderSettings;
@class SSG2DZConverter;

@interface SSGOpenGLManager : NSObject
@property (nonatomic) SSGDefaultShaderSettings *defaultShaderSettings;
@property (nonatomic) SSGColoredPSShaderSettings *coloredPSShaderSettings;
@property (nonatomic) SSG2DZConverter *zConverter;
@property (nonatomic) GLKMatrix4 projectionMatrix;

-(instancetype)initWithContextRef:(EAGLContext*)context andView:(GLKView*)view;
-(void)loadDefaultShaderAndSettings;
-(void)enableDepthTest;
-(void)disableDepthTest;
-(void)setClearColor:(GLKVector4)clearColor;
-(void)unload;
@end
