//
//  SSGCommand.h
//  SSGOGL
//
//  Created by John Stricker on 2/21/14.
//  Copyright (c) 2014 Sway Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class SSGCommandPath;

typedef NS_ENUM(NSInteger, SSGCommandEnum)
{
    kSSGCommand_alpha,
    kSSGCommand_visible,
    kSSGCommand_font_alternatingSplit,
    kSSGCommand_rotateTo,
    kSSGCommand_rotateAlongPath,
    kSSGCommand_scaleTo,
    kSSGCommand_scaleAlongPath,
    kSSGCommand_setConstantRotation,
    kSSGCommand_moveTo,
    kSSGCommand_moveAlongPath
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

@property (nonatomic, assign) SSGCommandEnum commandEnum;
@property (nonatomic, assign) GLKVector4 target;
@property (nonatomic, assign) GLKVector4 step;
@property (nonatomic, assign) GLfloat duration;
@property (nonatomic, assign) GLfloat delay;
@property (nonatomic, assign) BOOL isAbsolute;
@property (nonatomic, assign) BOOL isStarted;
@property (nonatomic, assign) BOOL isFinished;
@property (nonatomic, strong) SSGCommandPath *path;

+ (instancetype)commandWithEnum:(SSGCommandEnum) command Target:(GLKVector4)target Duration:(GLfloat)duration IsAbsolute:(BOOL)isAbsolute Delay:(GLfloat)delay;
- (instancetype)initWithCommandEnum:(SSGCommandEnum) command Target:(GLKVector4)target Duration:(GLfloat)duration IsAbsolute:(BOOL)isAbsolute Delay:(GLfloat)delay;
+ (instancetype)commandWithEnum:(SSGCommandEnum) command Path:(SSGCommandPath *)path IsAbsolute:(BOOL)isAbsolute Delay:(GLfloat)delay;
- (instancetype)initWithCommandEnum:(SSGCommandEnum) command Path:(SSGCommandPath *)path IsAbsolute:(BOOL)isAbsolute Delay:(GLfloat)delay;

+ (NSArray *)arrayFromX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z W:(GLfloat)w;
+ (GLKVector4)vectorFromArray:(NSArray*)arr;
@end
