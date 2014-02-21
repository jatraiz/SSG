//
//  SSGModel.h
//  SSGOGL
//
//  Created by John Stricker on 11/20/13.
//  Copyright (c) 2013 Sway Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class SSGDefaultShaderSettings;
@class SSGPrs;
@class SSGCommand;

@interface SSGModel : NSObject

@property (nonatomic) SSGPrs *prs;
@property (nonatomic) SSGPrs *worldPrs;
@property (nonatomic) BOOL isHidden;
@property (nonatomic) GLKVector4 diffuseColor;
@property (nonatomic) GLfloat alpha;
@property (nonatomic) GLfloat shadowMax;

-(instancetype) initWithModelFileName:(NSString*)modelFileName;
-(void) setProjection:(GLKMatrix4)projection;
-(void) setTexture0Id:(GLuint)texture0Id;
-(void) setDefaultShaderSettings:(SSGDefaultShaderSettings*)defaultShaderSettings;
-(void) setDimensions2dX:(GLfloat)x andY:(GLfloat)y;
-(BOOL) isTransformedPointWithinModel2d:(CGPoint)point;
-(void) addCommand:(SSGCommand*)command;
-(void) updateWithTime:(GLfloat)time;
-(void) updateModelViewProjection;
-(void) draw;
@end
