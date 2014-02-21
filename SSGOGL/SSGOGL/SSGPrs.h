//
//  SSGPrs.h
//  SSGOGL
//
//  Created by John Stricker on 1/10/14.
//  Copyright (c) 2014 Sway Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface SSGPrs : NSObject
@property (nonatomic) GLKVector3 position;
@property (nonatomic,readonly) GLKVector3 rotation;
@property (nonatomic,readonly) GLKQuaternion rotationQuaternion;
@property (nonatomic) GLKVector3 scale;
-(GLfloat)px;
-(GLfloat)py;
-(GLfloat)pz;
-(void)setPx:(float)x;
-(void)setPy:(float)y;
-(void)setPz:(float)z;
-(void)moveToVector:(GLKVector3)targetVec Duration:(GLfloat)duration Delay:(GLfloat)delay IsAbsolute:(BOOL)isAbsolute;

-(GLfloat)rx;
-(GLfloat)ry;
-(GLfloat)rz;
-(void)setRx:(float)x;
-(void)setRy:(float)y;
-(void)setRz:(float)z;
-(void)addVectorToRotation:(GLKVector3)vector;
-(void)resetRotationWithVector:(GLKVector3)vector;
-(void)setRotationConstantToVector:(GLKVector3)vector;
-(void)removeRotationConstant;
-(void)rotateToVector:(GLKVector3)targetVec Duration:(GLfloat)duration Delay:(GLfloat)delay IsAbsolute:(BOOL)isAbsolute;

-(GLfloat)sx;
-(GLfloat)sy;
-(GLfloat)sz;
-(void)setSx:(float)x;
-(void)setSy:(float)y;
-(void)setSz:(float)z;
-(void)setSxyz:(float)xyz;
-(void)scaleToVector:(GLKVector3)targetVec Duration:(GLfloat)duration Delay:(GLfloat)delay IsAbsolute:(BOOL)isAbsolute;
-(void)updateWithTime:(GLfloat)time;

 @end
