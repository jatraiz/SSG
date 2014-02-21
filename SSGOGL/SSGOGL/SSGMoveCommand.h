//
//  SSGMoveCommand.h
//  SSGOGL
//
//  Created by John Stricker on 1/10/14.
//  Copyright (c) 2014 Sway Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface SSGMoveCommand : NSObject
@property (nonatomic,readonly) GLKVector3 targetVector;
@property (nonatomic,readonly) GLKVector3 stepVector;
@property (nonatomic,readonly) GLfloat duration;
@property (nonatomic) GLfloat delay;
@property (nonatomic,readonly) BOOL isAbsolute;
@property (nonatomic,readonly) BOOL isRunning;
@property (nonatomic,readonly) BOOL isFinished;

-(instancetype)initWithTarget:(GLKVector3)targetVector Duration:(GLfloat)duration Delay:(GLfloat)delay isAbsolute:(BOOL)isAbsolute;
-(GLKVector3)updateWithTime:(GLfloat)time andCurrentVector:(GLKVector3)currentVector;

@end
