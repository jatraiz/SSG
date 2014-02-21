//
//  SSGColoredPointSpriteUI.h
//  SSGOGL
//
//  Created by John Stricker on 11/20/13.
//  Copyright (c) 2013 Sway Software. All rights reserved.
//
/*
 Program ID & Uniform indices for a colored point srite shader
 */
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface SSGColoredPSShaderSettings : NSObject

@property (nonatomic, readonly) GLuint programId;

-(id)initWithProgramId:(GLuint)programId;
-(void)setMvpForTextureCoordinates;
-(void)setColor:(GLKVector4)color;
-(void)setSize:(GLfloat)size;
-(void)setMvpMatrix:(GLKMatrix4)mvp;
@end
