//
//  SSGMathUtils.m
//  SSGOGL
//
//  Created by John Stricker on 4/2/14.
//  Copyright (c) 2014 Sway Software. All rights reserved.
//

#import "SSGMathUtils.h"
#import <OpenGLES/ES2/gl.h>

@implementation SSGMathUtils

static const GLfloat randPrecision = 1000000;

+ (GLfloat)clampf: (GLfloat)a WithInclusiveMin: (GLfloat)inclusiveMin InclusiveMax: (GLfloat)inclusiveMax
{
    if(a < inclusiveMin) return inclusiveMin;
    if(a > inclusiveMax) return inclusiveMax;
    return a;
}

+ (GLfloat)loopClampf: (GLfloat)a  WithInclusiveMin: (GLfloat)inclusiveMin InclusiveMax: (GLfloat)inclusiveMax
{
    if(a < inclusiveMin) return -fmodf(-a,inclusiveMin);
    if(a > inclusiveMax) return fmodf(a,inclusiveMax);
    return a;
}

+ (GLfloat)randomGLfloatBetweenMin:(GLfloat)min Max:(GLfloat)max
{
    return ((GLfloat)arc4random_uniform(((max-min)*randPrecision)))/randPrecision+min;
}

@end
