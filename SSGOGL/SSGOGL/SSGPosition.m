//
//  SSGPosition.m
//  SSGOGL
//
//  Created by John Stricker on 12/13/13.
//  Copyright (c) 2013 Sway Software. All rights reserved.
//

#import "SSGPosition.h"
#import "SSGMoveCommand.h"

@interface SSGPosition()
@property (nonatomic) NSMutableArray *moveCommands;
@end

@implementation SSGPosition
- (instancetype)initWithX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z
{
    self = [super init];
    if(!self)
    {
        return nil;
    }
    _x = x;
    _y = y;
    _z = z;
    return self;
}

- (instancetype)initWithVec3:(GLKVector3)vec3
{
    return [self initWithX:vec3.x Y:vec3.y Z:vec3.z];
}

- (void)assignToVector:(GLKVector3)vec3
{
    self.x = vec3.x;
    self.y = vec3.y;
    self.z = vec3.z;
}

- (GLKVector3) getVector
{
    return GLKVector3Make(self.x, self.y, self.z);
}

- (void)addMoveCommand:(SSGMoveCommand*)cmd
{
    if(!_moveCommands) self.moveCommands = [NSMutableArray new];
    
    [self.moveCommands addObject:cmd];
    _hasMoveCommands = YES;
}

- (void)update:(GLfloat)time
{
    
}

@end
