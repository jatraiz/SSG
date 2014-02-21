//
//  SSGCommand.h
//  SSGOGL
//
//  Created by John Stricker on 2/21/14.
//  Copyright (c) 2014 Sway Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef NS_ENUM(NSInteger, SSGCommandEnum)
{
    kSSGCommand_alpha,
    kSSGCommand_visible
};

@interface SSGCommand : NSObject

@property (nonatomic) SSGCommandEnum commandEnum;
@property (nonatomic) GLKVector3 target;
@property (nonatomic) GLKVector3 step;
@property (nonatomic) GLfloat duration;
@property (nonatomic) GLfloat delay;
@property (nonatomic) BOOL isAbsolute;
@property (nonatomic) BOOL isStarted;
@property (nonatomic) BOOL isFinished;
@property (nonatomic) SSGCommand *commandOnFinish;

+ (instancetype)commandWithEnum:(SSGCommandEnum) command Target:(GLKVector3)target Duration:(GLfloat)duration IsAbsolute:(BOOL)isAbsolute Delay:(GLfloat)delay;
- (instancetype)initWithCommandEnum:(SSGCommandEnum) command Target:(GLKVector3)target Duration:(GLfloat)duration IsAbsolute:(BOOL)isAbsolute Delay:(GLfloat)delay;

@end
