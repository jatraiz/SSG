//
//  SSG2DZConverter.m
//  SSGOGL
//
//  Created by John Stricker on 11/20/13.
//  Copyright (c) 2013 Sway Software. All rights reserved.
//

#import "SSG2DZConverter.h"
@interface SSG2DZConverter()

@property (nonatomic) GLfloat ratioX, ratioY, aspectRatio, fov, halfScreenWidth, halfScreenHeight;

@end

@implementation SSG2DZConverter

-(instancetype)initWithScreenHeight:(GLfloat)sh ScreenWidth:(GLfloat)sw Fov:(GLfloat) f
{
    self = [super init];
    if(!self)
    {
        return nil;
    }
    _aspectRatio = fabsf(sw/sh);
    _fov = f;
    _halfScreenHeight = sh/2.0f;
    _halfScreenWidth = sw/2.0f;
    _ratioY = fabsf(tanf(_fov/2.0f));
    _ratioX = _ratioY*_aspectRatio;
    
    return self;
}

-(void)resetWithScreenHeight:(GLfloat)sh ScreenWidth:(GLfloat)sw Fov:(GLfloat)f
{
    self.aspectRatio = fabsf(sw/sh);
    self.fov = f;
    self.halfScreenHeight = sh/2.0f;
    self.halfScreenWidth = sw/2.0f;
    self.ratioY = fabsf(tanf(_fov/2.0f));
    self.ratioX = _ratioY*_aspectRatio;
}

-(CGPoint)convertScreenCoordsX:(GLfloat)x Y:(GLfloat)y ProjectedZ:(GLfloat)pz
{
    GLfloat xEdge = pz * _ratioX;
    GLfloat yEdge = -pz * _ratioY;
    GLfloat newX = xEdge - (xEdge/_halfScreenWidth)*x;
    GLfloat newY = yEdge - (yEdge/_halfScreenHeight)*y;
    //NSLog(@"Ratio:%f Edges:(%f,%f)",ratioX,xEdge,yEdge);
    //NSLog(@"Edge translation:(%f,%f)",newX,newY);
    return CGPointMake(newX, newY);
}

-(CGPoint)convertScreenPt:(CGPoint)pt ProjecteZ:(GLfloat)pz
{
    return [self convertScreenCoordsX:pt.x Y:pt.y ProjectedZ:pz];
}

-(GLKVector2)getScreenEdgesForZ:(GLfloat)z
{
     return GLKVector2Make(fabsf(z*_ratioX), fabsf(z*_ratioY));
}

@end
