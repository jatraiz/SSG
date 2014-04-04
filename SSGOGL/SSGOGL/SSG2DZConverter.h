//
//  SSG2DZConverter.h
//  SSGOGL
//
//  Created by John Stricker on 11/20/13.
//  Copyright (c) 2013 Sway Software. All rights reserved.
//
/*
 Utility to translate coordinates given screen size, fov, and a specific z value. Useful for boundry detection, hit detection, & translating touches to a point in 3D space
 */
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface SSG2DZConverter : NSObject

-(instancetype)initWithScreenHeight:(GLfloat)sh ScreenWidth:(GLfloat)sw Fov:(GLfloat) f;
-(void)resetWithScreenHeight:(GLfloat)sh ScreenWidth:(GLfloat)sw Fov:(GLfloat)f;
-(GLKVector2)convertScreenCoordsX:(GLfloat)x Y:(GLfloat)y ProjectedZ:(GLfloat)pz;
-(GLKVector2)convertScreenPt:(CGPoint)pt ProjecteZ:(GLfloat)pz;
-(GLKVector2)getScreenEdgesForZ:(GLfloat)z;

@end
