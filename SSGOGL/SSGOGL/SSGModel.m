//
//  SSGModel.m
//  SSGOGL
//
//  Created by John Stricker on 11/20/13.
//  Copyright (c) 2013 Sway Software. All rights reserved.
//

#import "SSGModel.h"
#import "SSGPrs.h"
#import "SSGAssetManager.h"
#import "SSGVaoInfo.h"
#import "SSGShaderManager.h"
#import "SSGDefaultShaderSettings.h"
#import "SSGCommand.h"

@interface SSGModel()

@property (nonatomic) SSGVaoInfo* vaoInfo;
@property (nonatomic) GLuint texture0Id;
@property (nonatomic) GLKMatrix4 projection;
@property (nonatomic) GLKMatrix3 normalMatrix;
@property (nonatomic) GLKMatrix4 modelViewProjection;
@property (nonatomic) SSGDefaultShaderSettings *defaultShaderSettings;
@property (nonatomic) CGPoint dimensions2d;
@property (nonatomic) NSMutableArray *commands;
@property (nonatomic) NSMutableArray *finishedCommands;
@end

@implementation SSGModel

- (instancetype)initWithModelFileName:(NSString*)modelFileName
{
    self = [super init];
    if(!self)
    {
        return nil;
    }
    _prs = [SSGPrs new];
    _vaoInfo = [SSGAssetManager loadVaoInfo:modelFileName];
    _commands = [[NSMutableArray alloc] init];
    _finishedCommands = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)setProjection:(GLKMatrix4)projection
{
    _projection = GLKMatrix4MakeWithArray(projection.m);
}

- (void)setTexture0Id:(GLuint)texture0Id
{
    _texture0Id = texture0Id;
}

- (void)setDefaultShaderSettings:(SSGDefaultShaderSettings *)defaultShaderSettings
{
    _defaultShaderSettings = defaultShaderSettings;
}

- (void)setDimensions2dX:(GLfloat)x andY:(GLfloat)y
{
    _dimensions2d = CGPointMake(x, y);
}

//Assumes point is translated to model's z position
//Currently not taking into account model rotation
- (BOOL)isTransformedPointWithinModel2d:(CGPoint)point
{
    GLKVector3 scale = GLKVector3Make(1.0f, 1.0f, 1.0f);
    GLKVector3 position = _prs.position;
    GLfloat dx = _dimensions2d.x/2.0f*scale.x;
    GLfloat dy = _dimensions2d.y/2.0f*scale.y;
    
    if(point.x <= position.x + dx &&
       point.x >= position.x - dx &&
       point.y <= position.y + dy &&
       point.y >= position.y - dx)
    {
        return YES;
    }
    return NO;
}

- (void)addCommand:(SSGCommand *)command
{
    [self.commands addObject:command];
}

- (void)updateWithTime:(GLfloat)time
{
    [self.prs updateWithTime:time];
    [self updateCommandsWithTime:time];
    [self updateModelViewProjection];
}

- (void)updateCommandsWithTime:(GLfloat)time
{
    //account for delays and process command
    for(SSGCommand *command in self.commands)
    {
        command.delay -= time;
        if(command.delay <= 0.0f)
        {
            [self processCommand:command withTime:time];
        }
        if(command.isFinished)
        {
            if(command.commandOnFinish)
            {
                [self addCommand:command.commandOnFinish];
            }
            [self.finishedCommands addObject:command];
        }
    }
    //clean up finished commands
    for(SSGCommand *command in self.finishedCommands)
    {
        if(command.isFinished)
        {
            [self.commands removeObject:command];
        }
    }
    [self.finishedCommands removeAllObjects];
}

- (void)processCommand:(SSGCommand*)command withTime:(GLfloat)time
{
    switch (command.commandEnum)
    {
        case kSSGCommand_alpha:
            if(command.duration == 0.0f)
            {
                self.alpha = command.target.x;
                command.isFinished = YES;
                return;
            }
            else
            {
                if(!command.isStarted)
                {
                    if(command.isAbsolute)
                    {
                        command.step = command1float((command.target.x - self.alpha)/command.duration);
                    }
                    else
                    {
                        command.step = command1float(command.target.x/command.duration);
                        command.target = command1float(command.target.x+self.alpha);
                    }
                    command.isStarted = YES;
                }
                
                command.duration -= time;
                self.alpha += command.step.x * time;
                if(command.duration <= 0.0f)
                {
                    self.alpha = command.target.x;
                    command.isFinished = YES;
                }
            }
            break;
        case kSSGCommand_visible:
            if(command.target.x == 0.0f)
            {
                self.isHidden = YES;
            }
            else
            {
                self.isHidden = NO;
            }
            command.isFinished = YES;
            break;
        default:
            break;
    }
}

- (void)updateModelViewProjection
{
    
    GLKVector3 scale = _prs.scale;
    GLKMatrix4 transformationMatrix = GLKMatrix4Identity;
    GLKVector3 newPosition = _prs.position;
    if(self.worldPrs)
    {
        /*
        if(self.worldTransform.orientation)
        {
            transformationMatrix = GLKMatrix4Multiply(transformationMatrix, [self.worldTransform.orientation getRotationMatrix]);
        }
        */
        newPosition.x -= _worldPrs.px;
        newPosition.y -= _worldPrs.py;
        newPosition.z -= _worldPrs.pz;
    }
    transformationMatrix = GLKMatrix4Translate(transformationMatrix, newPosition.x, newPosition.y, newPosition.z);
    
    /*
    if(_orientation)
    {
        transformationMatrix = GLKMatrix4Multiply(transformationMatrix, [self.orientation getRotationMatrix]);
    }
     */
    transformationMatrix = GLKMatrix4Multiply(transformationMatrix, GLKMatrix4MakeWithQuaternion(_prs.rotationQuaternion));
    GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(transformationMatrix, GLKMatrix4MakeScale(scale.x, scale.y ,scale.z));
    self.normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    self.modelViewProjection = GLKMatrix4Multiply(_projection, modelViewMatrix);
}


- (void)draw
{
    if(self.isHidden)
    {
        return;
    }
    
    [SSGShaderManager useProgram:self.defaultShaderSettings.programId];
    //set shader uniforms
    [self.defaultShaderSettings setAlpha:_alpha];
    [self.defaultShaderSettings setDiffuseColor:_diffuseColor];
    [self.defaultShaderSettings setShadoMax:_shadowMax];
    [self.defaultShaderSettings setNormalMatrix:_normalMatrix];
    [self.defaultShaderSettings setModelViewProjectionMatrix:_modelViewProjection];
    
    glBindVertexArrayOES(_vaoInfo.vaoIndex);
    glBindTexture(GL_TEXTURE_2D,_texture0Id);
    glDrawArrays(GL_TRIANGLES, 0, _vaoInfo.nVerts);
}

@end
