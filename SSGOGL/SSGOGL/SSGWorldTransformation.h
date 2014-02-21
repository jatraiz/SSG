//
//  SSGWorldTransformation.h
//  SSGOGLDevSpace
//
//  Created by John Stricker on 12/13/13.
//  Copyright (c) 2013 Sway Software. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SSGPosition;
@class SSGOrientation;

@interface SSGWorldTransformation : NSObject
@property SSGPosition *position;
@property SSGOrientation *orientation;
@end
