//
//  SSGShaderManager.h
//  SSGOGL
//
//  Created by John Stricker on 11/20/13.
//  Copyright (c) 2013 Sway Software. All rights reserved.
//
/* 
 Contains methods for loading each specific type of shader, each method returns the shader's program ID. Shader loading/linking/compiling code largely taken from Apple's default OpenGL project template.
 
 [SSGShaderManger useProgram: ] should be called instead of glUseProgram() so that program use is tracked
 */
#import <Foundation/Foundation.h>

@interface SSGShaderManager : NSObject
+ (unsigned int)loadModelDefaultShader;
+ (unsigned int)loadColoredPointSpriteShader;
+ (unsigned int)loadBitmapFontShader;
+ (void)useProgram:(unsigned int)programId;
@end
