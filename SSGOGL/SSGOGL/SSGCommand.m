//
//  SSGCommand.m
//  SSGOGL
//
//  Created by John Stricker on 2/21/14.
//  Copyright (c) 2014 Sway Software. All rights reserved.
//

#import "SSGCommand.h"
#import <GLKit/GLKit.h>

@implementation SSGCommand
+ (instancetype)SSGCommandWithCommand:(SSGCommandEnum) command Target:(GLKVector3)target Duration:(GLfloat)duration IsAbsolute:(BOOL)isAbsolute Delay:(GLfloat)delay;

{
    return [[SSGCommand alloc] initWithCommand:command Target:target Duration:duration IsAbsolute:isAbsolute Delay:delay];
}
- (instancetype)initWithCommand:(SSGCommandEnum) command Target:(GLKVector3)target Duration:(GLfloat)duration IsAbsolute:(BOOL)isAbsolute Delay:(GLfloat)delay
{
    self = [super init];
    if(self)
    {
        _command = command;
        _target = target;
        _duration = duration;
        _isAbsolute = isAbsolute;
        _delay = delay;
    }
    return self;
}

@end
