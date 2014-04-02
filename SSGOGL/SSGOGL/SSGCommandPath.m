//
//  SSGCommandPath.m
//  SSGOGL
//
//  Created by John Stricker on 4/1/14.
//  Copyright (c) 2014 Sway Software. All rights reserved.
//

#import "SSGCommandPath.h"
#import "SSGCommand.h"

@implementation SSGCommandPath

- (instancetype)initWithVectors:(NSArray*)vects Repeat:(BOOL)repeat
{
    self = [super init];
    if(self)
    {
        _nVectors = [vects count];
        _vectorArray = [vects copy];
        _repeat = repeat;
        _currentIndex = 0;
    }
    return self;
}

- (GLKVector4)getFirstVector
{
    NSArray *arr = self.vectorArray[0];
    return [SSGCommand vectorFromArray:arr];
}

- (GLKVector4)getNextVector
{
    if(self.currentIndex + 1 >= self.nVectors)
    {
        self.currentIndex = 0;
    }
    else
    {
        ++self.currentIndex;
    }
    
    NSArray *arr = self.vectorArray[self.currentIndex];
    return [SSGCommand vectorFromArray:arr];
}

@end
