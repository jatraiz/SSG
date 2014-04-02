//
//  SSGMathUtils.h
//  SSGOGL
//
//  Created by John Stricker on 4/2/14.
//  Copyright (c) 2014 Sway Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface SSGMathUtils : NSObject

+ (GLfloat)clampf: (GLfloat)a WithInclusiveMin: (GLfloat)inclusiveMin InclusiveMax: (GLfloat)inclusiveMax;
+ (GLfloat)loopClampf: (GLfloat)a  WithInclusiveMin: (GLfloat)inclusiveMin InclusiveMax: (GLfloat)inclusiveMax;
+ (GLfloat)randomGLfloatBetweenMin: (GLfloat)min Max: (GLfloat)max;
@end
