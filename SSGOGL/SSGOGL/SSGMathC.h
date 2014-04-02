//
//  SSGMathC.h
//  SSGOGL
//
//  Created by John Stricker on 1/10/14.
//  Copyright (c) 2014 Sway Software. All rights reserved.
//

#ifndef SSGOGL_SSGMathC_h
#define SSGOGL_SSGMathC_h
#include <math.h>

static const float TWO_PI = 2.0f * M_PI;
float SSGMathCclampf(float a, float inclusiveMin, float inclusiveMax);
float SSGMathCloopClampf(float a, float inclusiveMin, float inclusiveMax);
#endif
