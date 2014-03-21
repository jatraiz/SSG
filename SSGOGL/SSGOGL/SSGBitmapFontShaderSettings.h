//
//  SSGBitmapFontShaderSettings.h
//  SSGOGL
//
//  Created by John Stricker on 3/7/14.
//  Copyright (c) 2014 Sway Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
@class SSGBitmapFontShaderSettings;

@interface SSGBitmapFontShaderSettings : NSObject

@property (nonatomic, readonly, assign) GLuint programId;
@property (nonatomic, strong) SSGBitmapFontShaderSettings *shaderSettings;

- (instancetype)initWithProgramId:(GLuint)programId;
- (void)setAlpha:(GLfloat)alpha;
- (void)setModelViewProjectionMatrix:(GLKMatrix4)mvp;

@end
