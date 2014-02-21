//
//  SSGVaoInfoClass.m
//  SSGOGL
//
//  Created by John Stricker on 11/20/13.
//  Copyright (c) 2013 Sway Software. All rights reserved.
//

#import "SSGVaoInfo.h"

@implementation SSGVaoInfo
-(instancetype) initWithVaoIndex:(GLuint)vaoIndex vboIndex:(GLuint)vboIndex andNVerts:(GLuint)nVerts
{
    self = [super init];
    if(!self)
    {
        return nil;
    }
    
    _vaoIndex = vaoIndex;
    _vboIndex = vboIndex;
    _nVerts = nVerts;
    
    return self;
}

@end
