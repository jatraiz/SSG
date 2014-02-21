//
//  SSGMoveCommand.m
//  SSGOGL
//
//  Created by John Stricker on 1/10/14.
//  Copyright (c) 2014 Sway Software. All rights reserved.
//

#import "SSGMoveCommand.h"

@interface SSGMoveCommand()
@property (nonatomic) GLKVector3 stepVector;
@property (nonatomic) GLfloat timeElapsed;
-(void)startRunningWithCurrentVector:(GLKVector3)currentVector;
@end

@implementation SSGMoveCommand

-(instancetype)initWithTarget:(GLKVector3)targetVector Duration:(GLfloat)duration Delay:(GLfloat)delay isAbsolute:(BOOL)isAbsolute;
{
    self = [super init];
    if(!self) return nil;

    _targetVector = targetVector;
    _duration = duration;
    _delay = delay;
    _isAbsolute = isAbsolute;
    _isFinished = NO;
    _isRunning = NO;
    _timeElapsed = 0.0f;
    
    return self;
}

-(void)startRunningWithCurrentVector:(GLKVector3)currentVector
{
    _isRunning = YES;
    if(!_isAbsolute)
    {
        _stepVector = GLKVector3DivideScalar(_targetVector, _duration);
        _targetVector = GLKVector3Add(_targetVector, currentVector);
    }
    else
    {
        _stepVector = GLKVector3DivideScalar(GLKVector3Subtract(_targetVector,currentVector), _duration);
    }
}

-(GLKVector3)updateWithTime:(GLfloat)time andCurrentVector:(GLKVector3)currentVector
{
    if(_delay > 0.0f)
    {
        self.delay -= time;
        return currentVector;
    }
    
    if(!_isRunning)
        [self startRunningWithCurrentVector:currentVector];
    
    currentVector = GLKVector3Add(currentVector,GLKVector3MultiplyScalar(_stepVector, time));
    
    self.timeElapsed += time;
    if(_timeElapsed >= _duration)
    {
        currentVector = _targetVector;
        _isFinished = YES;
    }
    
    return currentVector;
}


@end
