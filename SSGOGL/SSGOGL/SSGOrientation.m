//
//  SSGOrientation.m
//  SSGOGL
//
//  Created by John Stricker on 12/17/13.
//  Copyright (c) 2013 Sway Software. All rights reserved.
//

#import "SSGOrientation.h"
@interface SSGOrientation()
@property (nonatomic,readonly) GLKVector3 upVec,forwardVec,rightVec;
@end

@implementation SSGOrientation
- (id)initWithUpVector:(GLKVector3)uVect upAngle:(GLfloat)uAngle ForwardVector:(GLKVector3)fVect ForwardAngle:(GLfloat)fAngle RightVector:(GLKVector3)rVect RightAngle:(GLfloat)rAngle
{
    self = [super init];
    if(!self)
    {
        return nil;
    }
    _forwardVec = fVect;
    _upVec = uVect;
    _rightVec = rVect;
    _orientation = GLKQuaternionMakeWithAngleAndAxis(uAngle,uVect.x, uVect.y, uVect.z);
    _orientation = GLKQuaternionMultiply(_orientation, GLKQuaternionMakeWithAngleAndAxis(fAngle, fVect.x, fVect.y, fVect.z));
    _orientation = GLKQuaternionMultiply(_orientation, GLKQuaternionMakeWithAngleAndAxis(rAngle, rVect.x, rVect.y, rVect.z));
    
    return self;
}

- (void)yaw:(GLfloat)y
{
    self.orientation = GLKQuaternionMultiply(self.orientation,GLKQuaternionMakeWithAngleAndAxis(y, _upVec.x, _upVec.y, _upVec.z));
}

- (void)resetYawTo:(GLfloat)y
{
 //   self.orientation = GLKQuaternionMakeWithAngleAndAxis(y,_upVec.x,_upVec.y,_upVec.z);
}

- (void)pitch:(GLfloat)p
{
    self.orientation = GLKQuaternionMultiply(self.orientation,GLKQuaternionMakeWithAngleAndAxis(p, _rightVec.x, _rightVec.y, _rightVec.z));
}

- (void)resetPitchTo:(GLfloat)p
{
    //self.orientation = GLKQuaternionMakeWithAngleAndAxis(p, _, <#float y#>, <#float z#>)
}

- (void)roll:(GLfloat)r
{
    self.orientation = GLKQuaternionMultiply(self.orientation,GLKQuaternionMakeWithAngleAndAxis(r, _forwardVec.x, _forwardVec.y, _forwardVec.z));
}

- (void)resetRollTo:(GLfloat)r
{
    
}

- (GLKMatrix4)getRotationMatrix
{
    self.orientation = GLKQuaternionNormalize(self.orientation);
    return GLKMatrix4MakeWithQuaternion(self.orientation);
    
}
@end
