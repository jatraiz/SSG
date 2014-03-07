//
//  SSGVaoInfoClass.h
//  SSGOGL
//
//  Created by John Stricker on 11/20/13.
//  Copyright (c) 2013 Sway Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface SSGVaoInfo : NSObject
@property (nonatomic, assign) GLuint vaoIndex, vboIndex, nVerts;
-(instancetype) initWithVaoIndex:(GLuint)vaoIndex vboIndex:(GLuint)vboIndex andNVerts:(GLuint)nVerts;
@end
