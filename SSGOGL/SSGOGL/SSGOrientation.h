//
//  SSGOrientation.h
//  SSGOGL
//
//  Created by John Stricker on 12/17/13.
//  Copyright (c) 2013 Sway Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface SSGOrientation : NSObject
@property (nonatomic) GLKQuaternion orientation;

- (id)initWithUpVector:(GLKVector3)uVect upAngle:(GLfloat)uAngle ForwardVector:(GLKVector3)fVect ForwardAngle:(GLfloat)fAngle RightVector:(GLKVector3)rVect RightAngle:(GLfloat)rAngle;

- (void)yaw:(GLfloat)y;
- (void)resetYawTo:(GLfloat)y;
- (void)pitch:(GLfloat)p;
- (void)resetPitchTo:(GLfloat)p;
- (void)roll:(GLfloat)r;
- (void)resetRollTo:(GLfloat)r;


- (GLKMatrix4)getRotationMatrix;
@end
