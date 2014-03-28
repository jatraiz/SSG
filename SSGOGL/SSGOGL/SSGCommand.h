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
    kSSGCommand_visible,
    kSSGCommand_font_alternatingSplit,
    kSSGCommand_setConstantRotation
};

static __inline__ GLKVector4 command1Bool(BOOL boolValue)
{
    GLfloat x = 0.0f;
    if(boolValue)
    {
        x = 1.0f;
    }
    GLKVector4 v = {x, 0.0f, 0.0f, 0.0f};
    return v;
}

static __inline__ GLKVector4 command1float(float x)
{
    GLKVector4 v = { x, 0.0f, 0.0f, 0.0f};
    return v;
}

static __inline__ GLKVector4 command2float(float x, float y)
{
    GLKVector4 v = { x, y, 0.0f, 0.0f};
    return v;
}


static __inline__ GLKVector4 command3float(float x, float y, float z)
{
    GLKVector4 v = {x, y, z,0.0f};
    return v;
}

@interface SSGCommand : NSObject

@property (nonatomic) SSGCommandEnum commandEnum;
@property (nonatomic) GLKVector4 target;
@property (nonatomic) GLKVector4 step;
@property (nonatomic) GLfloat duration;
@property (nonatomic) GLfloat delay;
@property (nonatomic) BOOL isAbsolute;
@property (nonatomic) BOOL isStarted;
@property (nonatomic) BOOL isFinished;
@property (nonatomic) SSGCommand *commandOnFinish;

+ (instancetype)commandWithEnum:(SSGCommandEnum) command Target:(GLKVector4)target Duration:(GLfloat)duration IsAbsolute:(BOOL)isAbsolute Delay:(GLfloat)delay;
- (instancetype)initWithCommandEnum:(SSGCommandEnum) command Target:(GLKVector4)target Duration:(GLfloat)duration IsAbsolute:(BOOL)isAbsolute Delay:(GLfloat)delay;

@end
