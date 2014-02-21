//
//  SSGDefaultModelShaderInfo.h
//  SSGOGL
//
//  Created by John Stricker on 11/20/13.
//  Copyright (c) 2013 Sway Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface SSGDefaultShaderSettings : NSObject

@property (nonatomic,readonly) GLuint programId;

-(id) initWithProgramId:(GLuint)programId;
-(void) setAlpha:(GLfloat)alpha;
-(void) setDiffuseColor:(GLKVector4)diffuseColor;
-(void) setShadoMax:(GLfloat)shadowMax;
-(void) setNormalMatrix:(GLKMatrix3)normalMatrix;
-(void) setModelViewProjectionMatrix:(GLKMatrix4)mvp;
@end
