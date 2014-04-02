//
//  SSGMathC.c
//  SSGOGL
//
//  Created by John Stricker on 1/10/14.
//  Copyright (c) 2014 Sway Software. All rights reserved.
//
#import "SSGMathC.h"
#include <stdio.h>

float SSGMathCclampf(float a, float inclusiveMin, float inclusiveMax)
{
    if(a < inclusiveMin) return inclusiveMin;
    if(a > inclusiveMax) return inclusiveMax;
    return a;
}

float SSGMathCloopClampf(float a, float inclusiveMin, float inclusiveMax)
{
    if(a < inclusiveMin) return -fmodf(-a,inclusiveMin);
    if(a > inclusiveMax) return fmodf(a,inclusiveMax);
    
    return a;
}