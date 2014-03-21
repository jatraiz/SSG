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
@class SSGBitmapFontShaderSettings;
@class SSG2DZConverter;

@interface SSGOpenGLManager : NSObject
@property (nonatomic, strong) SSGDefaultShaderSettings *defaultShaderSettings;
@property (nonatomic, strong) SSGColoredPSShaderSettings *coloredPSShaderSettings;
@property (nonatomic, strong) SSGBitmapFontShaderSettings *bitmapFontShaderSettings;
@property (nonatomic, strong) SSG2DZConverter *zConverter;
@property (nonatomic, assign) GLKMatrix4 projectionMatrix;

-(instancetype)initWithContextRef:(EAGLContext*)context andView:(GLKView*)view;
-(void)loadDefaultShaderAndSettings;
-(void)loadBitmapFontShaderAndSettings;
-(void)enableDepthTest;
-(void)disableDepthTest;
-(void)setClearColor:(GLKVector4)clearColor;
-(void)unload;
@end
