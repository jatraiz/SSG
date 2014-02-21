//
//  SSGDrawableTexture.h
//  SSGOGL
//
//  Created by John Stricker on 11/22/13.
//  Copyright (c) 2013 Sway Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class  SSGColoredPSShaderSettings;

@interface SSGDrawableTexture : NSObject

@property (nonatomic, readonly) GLuint textureId;

-(id)initWithWidth:(GLfloat)width Height:(GLfloat)height andColoredShaderSettings:(SSGColoredPSShaderSettings*)coloredShaderSettings;
-(void)setDrawingSize:(GLfloat)size;
-(void)setdrawingTexture:(GLuint)drawingTextureId;
-(void)setdrawingColor:(GLKVector4)drawingColor;
-(void)setClearColor:(GLKVector4)clearColor;
-(void)clear;
-(void)clearWithColor:(GLKVector4)clearColor;
-(void)drawPoint:(CGPoint)point;
-(void)drawLineFromPoint:(CGPoint)startPt toPoint:(CGPoint)endPt;
-(void)unload;
@end
