//
//  SSGBitmapFontShaderSettings.m
//  SSGOGL
//
//  Created by John Stricker on 3/7/14.
//  Copyright (c) 2014 Sway Software. All rights reserved.
//

#import "SSGBitmapFontShaderSettings.h"
#import "SSGShaderManager.h"

@interface SSGBitmapFontShaderSettings()

@property (nonatomic, readonly, assign) GLuint mvpIndex, alphaIndex;
@property (nonatomic, assign) GLfloat alpha;
@property (nonatomic, assign) GLKMatrix4 mvp;
@end

@implementation SSGBitmapFontShaderSettings
- (instancetype)initWithProgramId:(GLuint)programId
{
    self = [super init];
    if(self)
    {
        _programId = programId;
        [SSGShaderManager useProgram:programId];
        _alphaIndex = glGetUniformLocation(programId, "u_alpha");
        _mvpIndex = glGetUniformLocation(programId, "u_modelViewProjectionMatrix");
    }
    return self;
}

- (void)setAlpha:(GLfloat)alpha
{
    if(alpha == _alpha)
    {
        return;
    }
    [SSGShaderManager useProgram:_programId];
    glUniform1f(_alphaIndex, alpha);
    _alpha = alpha;
}

- (void)setModelViewProjectionMatrix:(GLKMatrix4)mvp
{
    [SSGShaderManager useProgram:_programId];
    glUniformMatrix4fv(_mvpIndex, 1, GL_FALSE, mvp.m);
    _mvp = GLKMatrix4MakeWithArray(mvp.m);
}

@end
