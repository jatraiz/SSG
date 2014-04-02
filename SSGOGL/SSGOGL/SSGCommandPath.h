//
//  SSGCommandPath.h
//  SSGOGL
//
//  Created by John Stricker on 4/1/14.
//  Copyright (c) 2014 Sway Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKMath.h>

@interface SSGCommandPath : NSObject

@property (nonatomic, strong) NSArray *vectorArray;
@property (nonatomic, assign) BOOL repeat;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, assign, readonly) NSUInteger nVectors;

- (instancetype)initWithVectors:(NSArray*)vects Repeat:(BOOL)repeat;
- (GLKVector4)getFirstVector;
- (GLKVector4)getNextVector;

@end
