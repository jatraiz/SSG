//
//  SSGColoredPointSpriteUI.m
//  SSGOGL
//
//  Created by John Stricker on 11/20/13.
//  Copyright (c) 2013 Sway Software. All rights reserved.
//
/* 
 Program ID & Uniform indices for a colored point srite shader
*/

#import "SSGColoredPSShaderSettings.h"
#import "SSGShaderManager.h"

@interface SSGColoredPSShaderSettings()

@property (nonatomic,readonly) GLuint mvpIndex, colorMapIndex, colorIndex, sizeIndex;
@property (nonatomic) GLfloat size;
@property (nonatomic) GLKVector4 color;
@property (nonatomic) GLKMatrix4 mvp;

@end

@implementation SSGColoredPSShaderSettings

-(id)initWithProgramId:(GLuint)programId
{
    self = [super init];
    if(!self)
    {
        return nil;
    }
    
    _programId = programId;
    [SSGShaderManager useProgram:programId];
    
    //get indexes for uniforms
    _colorIndex = glGetUniformLocation(programId, "u_color");
    _mvpIndex = glGetUniformLocation(programId, "u_mvp");
    _colorMapIndex = glGetUniformLocation(programId, "u_colorMap");
    _sizeIndex = glGetUniformLocation(programId, "u_size");
   
    return self;
}

-(void) setMvpForTextureCoordinates
{
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0,1, 0, 1, -1, 1);
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    GLKMatrix4 mvp = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    [self setMvpMatrix:mvp];
}

-(void)setColor:(GLKVector4)color
{
    if(GLKVector4AllEqualToVector4(_color, color))
    {
        return;
    }
    
    [SSGShaderManager useProgram:_programId];
    glUniform4fv(_colorIndex, 1, color.v);
    _color = GLKVector4MakeWithArray(color.v);
}
-(void)setSize:(GLfloat)size
{
    if(size == _size)
    {
        return;
    }
    
    [SSGShaderManager useProgram:_programId];
    glUniform1f(_sizeIndex, size);
    _size = size;
}

-(void)setMvpMatrix:(GLKMatrix4)mvp
{
    [SSGShaderManager useProgram:_programId];
    glUniformMatrix4fv(_mvpIndex, 1, GL_FALSE, mvp.m);
    _mvp = GLKMatrix4MakeWithArray(mvp.m);
}





@end
