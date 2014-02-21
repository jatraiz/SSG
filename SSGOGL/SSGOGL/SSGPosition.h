//
//  SSGPosition.h
//  SSGOGL
//
//  Created by John Stricker on 12/13/13.
//  Copyright (c) 2013 Sway Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class SSGMoveCommand;

@interface SSGPosition : NSObject
@property (nonatomic) GLfloat x;
@property (nonatomic) GLfloat y;
@property (nonatomic) GLfloat z;
@property (nonatomic,readonly) BOOL hasMoveCommands;
- (instancetype)initWithX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z;
- (instancetype)initWithVec3:(GLKVector3)vec3;
- (void)assignToVector:(GLKVector3)vec3;
- (GLKVector3)getVector;
- (void)addMoveCommand:(SSGMoveCommand*)cmd;
- (void)update:(GLfloat)time;
@end
