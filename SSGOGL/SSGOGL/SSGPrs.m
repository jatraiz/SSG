//
//  SSGPrs.m
//  SSGOGL
//
//  Created by John Stricker on 1/10/14.
//  Copyright (c) 2014 Sway Software. All rights reserved.
//

#import "SSGPrs.h"
#import "SSGMoveCommand.h"
#import "SSGMathC.h"

@interface SSGPrs()
@property (nonatomic) NSMutableArray *moveCommands;
@property (nonatomic) NSMutableArray *rotationCommands;
@property (nonatomic) NSMutableArray *scaleCommands;
@property (nonatomic,readonly) GLKVector3 rotationConstantVector;
@property (nonatomic) BOOL rotationConstantExists;

-(void)updateConstantRotationWithTime:(GLfloat)time;
@end
@implementation SSGPrs
-(instancetype) init
{
    self = [super init];
    if(!self)return nil;
    
    _position = GLKVector3Make(0.0f, 0.0f, 0.0f);
    _rotation = GLKVector3Make(0.0f, 0.0f, 0.0f);
    _rotationQuaternion = GLKQuaternionMakeWithAngleAndAxis(0.0f, 0.0f, 0.0f, 1.0f);
    _scale = GLKVector3Make(1.0f, 1.0f, 1.0f);
    _moveCommands = [NSMutableArray new];
    _rotationCommands = [NSMutableArray new];
    _scaleCommands = [NSMutableArray new];
    _rotationConstantExists = NO;
    
    return self;
}

#pragma mark position methods
-(GLfloat)px {return _position.x;}
-(GLfloat)py {return _position.y;}
-(GLfloat)pz {return _position.z;}
-(void)setPx:(float)x {_position.x = x;}
-(void)setPy:(float)y; {_position.y = y;}
-(void)setPz:(float)z; {_position.z = z;}
-(void)moveToVector:(GLKVector3)targetVec Duration:(GLfloat)duration Delay:(GLfloat)delay IsAbsolute:(BOOL)isAbsolute
{
    [self.moveCommands addObject: [[SSGMoveCommand alloc] initWithTarget:targetVec Duration:duration Delay:delay isAbsolute:isAbsolute]];
}

#pragma mark rotation methods
-(GLfloat)rx {return _rotation.x;}
-(GLfloat)ry {return _rotation.y;}
-(GLfloat)rz {return _rotation.z;}
-(void)setRx:(float)x {
    _rotationQuaternion = GLKQuaternionMultiply(_rotationQuaternion, GLKQuaternionMakeWithAngleAndAxis(-_rotation.x, 1.0f, 0.0f, 0.0f));
    _rotation.x = SSGMathCloopClampf(x, -TWO_PI, TWO_PI);
    _rotationQuaternion = GLKQuaternionMultiply(_rotationQuaternion, GLKQuaternionMakeWithAngleAndAxis(_rotation.x, 1.0f, 0.0f, 0.0f));}
-(void)setRy:(float)y {
      _rotationQuaternion = GLKQuaternionMultiply(_rotationQuaternion, GLKQuaternionMakeWithAngleAndAxis(-_rotation.y, 0.0f, 1.0f, 0.0f));
    _rotation.y = SSGMathCloopClampf(y, -TWO_PI, TWO_PI);
    _rotationQuaternion = GLKQuaternionMultiply(_rotationQuaternion, GLKQuaternionMakeWithAngleAndAxis(_rotation.y, 0.0f, 1.0f, 0.0f));}
-(void)setRz:(float)z {
      _rotationQuaternion = GLKQuaternionMultiply(_rotationQuaternion, GLKQuaternionMakeWithAngleAndAxis(-_rotation.z, 0.0f, 0.0f, 1.0f));
    _rotation.z = SSGMathCloopClampf(z, -TWO_PI, TWO_PI);
    _rotationQuaternion = GLKQuaternionMultiply(_rotationQuaternion, GLKQuaternionMakeWithAngleAndAxis(_rotation.z, 0.0f, 0.0f, 1.0f));}
-(void)addVectorToRotation:(GLKVector3)vector
{
    if(vector.z != 0.0f) self.rz = vector.z;
    if(vector.y != 0.0f) self.ry = vector.y;
    if(vector.x != 0.0f) self.rx = vector.x;
}
-(void)resetRotationWithVector:(GLKVector3)vector
{
    _rotationQuaternion = GLKQuaternionMakeWithAngleAndAxis(0.0f, 0.0f, 0.0f, 1.0f);
    [self addVectorToRotation:vector];
}
-(void)setRotationConstantToVector:(GLKVector3)vector
{
    self.rotationConstantExists = YES;
    _rotationConstantVector = vector;
}
-(void)removeRotationConstant
{
    self.rotationConstantExists = NO;
}
-(void)updateConstantRotationWithTime:(GLfloat)time
{
    if(_rotationConstantVector.z != 0.0f) _rotationQuaternion = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(_rotationConstantVector.z*time, 0.0f, 0.0f, 1.0f),_rotationQuaternion);
    if(_rotationConstantVector.y != 0.0f) _rotationQuaternion = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(_rotationConstantVector.y*time, 0.0f, 1.0f, 0.0f),_rotationQuaternion);
    if(_rotationConstantVector.x != 0.0f) _rotationQuaternion = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(_rotationConstantVector.x*time, 1.0f, 0.0f, 0.0f),_rotationQuaternion);
}
-(void)rotateToVector:(GLKVector3)targetVec Duration:(GLfloat)duration Delay:(GLfloat)delay IsAbsolute:(BOOL)isAbsolute
{
    [self.rotationCommands addObject: [[SSGMoveCommand alloc] initWithTarget:targetVec Duration:duration Delay:delay isAbsolute:isAbsolute]];
}


#pragma mark scale methods
-(GLfloat)sx {return _scale.x;}
-(GLfloat)sy {return _scale.y;}
-(GLfloat)sz {return _scale.z;}
-(void)setSx:(float)x {_scale.x = x;}
-(void)setSy:(float)y {_scale.y = y;}
-(void)setSz:(float)z {_scale.z = z;}
-(void)setSxyz:(float)xyz {_scale = GLKVector3Make(xyz, xyz, xyz);}
-(void)scaleToVector:(GLKVector3)targetVec Duration:(GLfloat)duration Delay:(GLfloat)delay IsAbsolute:(BOOL)isAbsolute
{
    [self.scaleCommands addObject: [[SSGMoveCommand alloc] initWithTarget:targetVec Duration:duration Delay:delay isAbsolute:isAbsolute]];
}

#pragma mark update methods
-(void)updateWithTime:(GLfloat)time
{
    if([_moveCommands count] > 0)
    {
        SSGMoveCommand *cmd = _moveCommands[0];
        self.position = [cmd updateWithTime:time andCurrentVector:_position];
        if(cmd.isFinished) [self.moveCommands removeObject:cmd];
    }
    if([_rotationCommands count] > 0)
    {
        SSGMoveCommand *cmd = _rotationCommands[0];
        [self addVectorToRotation:[cmd updateWithTime:time andCurrentVector:_rotation]];
        if(cmd.isFinished) [self.rotationCommands removeObject:cmd];
    }
    else if(_rotationConstantExists)
    {
        [self updateConstantRotationWithTime:time];
    }
    if([_scaleCommands count] > 0)
    {
        SSGMoveCommand *cmd = _scaleCommands[0];
        self.scale = [cmd updateWithTime:time andCurrentVector:_scale];
        if(cmd.isFinished) [self.scaleCommands removeObject:cmd];
    }
}

@end
