//
//  SSGHud.h
//  SSGOGLDevSpace
//
//  Created by John Stricker on 12/13/13.
//  Copyright (c) 2013 Sway Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSGHudDelegate.h"

typedef NS_ENUM(NSUInteger, SSGHudTransformationState)
{
    SSGHudTransformationStateTranslate,
    SSGHudTransformationStateRotateX,
    SSGHudTransformationStateRotateY,
    SSGHudTransformationStateRotateZ
};

@interface SSGHud : UIViewController
@property (nonatomic) BOOL switchOn;
@property (nonatomic) BOOL moveObj;
@property (nonatomic,readonly) SSGHudTransformationState currentState;
@property (nonatomic,assign) id <SSGHudDelegate>delegate;
@end
