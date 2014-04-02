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
#import "SSGCommandPath.h"

@interface SSGModel()


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
    //for some subclasses a .model file will not be used on init
    if(modelFileName)
    {
        _vaoInfo = [SSGAssetManager loadVaoInfo:modelFileName];
        _alpha = 1.0f;
        _diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    }
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

- (void)clearAllCommands
{
    [self.commands removeAllObjects];
}

- (void)clearCommandsOfTypes:(NSArray *)commandTypes
{
    NSMutableArray *commandsToErase = [[NSMutableArray alloc] init];
    for(NSNumber *commandEnum in commandTypes)
    {
        for(SSGCommand *command in self.commands)
        {
            if(command.commandEnum == [commandEnum integerValue])
            {
                [commandsToErase addObject:command];
            }
        }
    }
    [self.commands removeObjectsInArray:commandsToErase];
}

- (void)clearCommandsOfType:(NSUInteger)commandType
{
    [self clearCommandsOfTypes:@[[NSNumber numberWithUnsignedInteger:commandType]]];
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
        // ALPHA //
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
        
        // VISIBILITY //
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
            
        // CONSTANT ROTATION //
        case kSSGCommand_setConstantRotation:
            [self.prs setRotationConstantToVector:GLKVector3Make(command.target.x, command.target.y, command.target.z)];
            command.isFinished = YES;
            break;
            
        // MOVE TO //
        case kSSGCommand_moveTo:
            if(!command.isStarted)
            {
                command.isStarted = YES;
                
                if(!command.isAbsolute)
                {
                    command.step = GLKVector4Make(command.target.x / command.duration, command.target.y / command.duration, command.target.z / command.duration, 0.0f);
                    command.target = GLKVector4Make(command.target.x + self.prs.px, command.target.y + self.prs.py, command.target.z + self.prs.pz, 0.0f);
                }
                else
                {
                    command.step = GLKVector4Make((command.target.x - self.prs.px) / command.duration, (command.target.y - self.prs.py) / command.duration, (command.target.z - self.prs.pz) / command.duration, 0.0f);
                }
            }
            
            command.duration -= time;
            
            if(command.duration <= 0.0f)
            {
                self.prs.position = GLKVector3Make(command.target.x, command.target.y, command.target.z);
                command.isFinished = YES;
            }
            else
            {
                self.prs.position = GLKVector3Make(self.prs.px + command.step.x * time, self.prs.py + command.step.y * time, self.prs.pz + command.step.z * time);
            }
            break;
            
        // MOVE ALONG PATH //
        case kSSGCommand_moveAlongPath:
            if(!command.isStarted)
            {
                command.isStarted = YES;
                
                GLKVector4 target = [command.path getFirstVector];
                command.target = target;
                command.duration = target.w;
                
                if(!command.isAbsolute)
                {
                    command.step = GLKVector4Make(command.target.x / command.duration, command.target.y / command.duration, command.target.z / command.duration, 0.0f);
                    command.target = GLKVector4Make(command.target.x + self.prs.px, command.target.y + self.prs.py, command.target.z + self.prs.pz, 0.0f);
                }
                else
                {
                    command.step = GLKVector4Make((command.target.x - self.prs.px) / command.duration, (command.target.y - self.prs.py) / command.duration, (command.target.z - self.prs.pz) / command.duration, 0.0f);
                }
            }
            
            command.duration -= time;
            
            if(command.duration <= 0.0f)
            {
                self.prs.position = GLKVector3Make(command.target.x, command.target.y, command.target.z);
                if(command.path.currentIndex < command.path.nVectors || command.path.repeat)
                {
                    GLKVector4 target = [command.path getNextVector];
                    command.target = target;
                    command.duration = target.w;
                    
                    if(!command.isAbsolute)
                    {
                        command.step = GLKVector4Make(command.target.x / command.duration, command.target.y / command.duration, command.target.z / command.duration, 0.0f);
                        command.target = GLKVector4Make(command.target.x + self.prs.px, command.target.y + self.prs.py, command.target.z + self.prs.pz, 0.0f);
                    }
                    else
                    {
                        command.step = GLKVector4Make((command.target.x - self.prs.px) / command.duration, (command.target.y - self.prs.py) / command.duration, (command.target.z - self.prs.pz) / command.duration, 0.0f);
                    }
                }
                else
                {
                    command.isFinished = YES;
                }
            }
            else
            {
                self.prs.position = GLKVector3Make(self.prs.px + command.step.x * time, self.prs.py + command.step.y * time, self.prs.pz + command.step.z * time);
            }
            
            break;
            
            // ROTATE //
        case kSSGCommand_rotateTo:
            if(!command.isStarted)
            {
                command.isStarted = YES;
                
                if(!command.isAbsolute)
                {
                    command.step = GLKVector4Make(command.target.x / command.duration, command.target.y / command.duration, command.target.z / command.duration, 0.0f);
                    command.target = GLKVector4Make(command.target.x + self.prs.rx, command.target.y + self.prs.ry, command.target.z + self.prs.rz, 0.0f);
                }
                else
                {
                    command.step = GLKVector4Make((command.target.x - self.prs.rx) / command.duration, (command.target.y - self.prs.ry) / command.duration, (command.target.z - self.prs.rz) / command.duration, 0.0f);
                }
            }
            
            command.duration -= time;
            
            if(command.duration <= 0.0f)
            {
                [self.prs addVectorToRotation:GLKVector3Make(command.target.x, command.target.y, command.target.z)];
                command.isFinished = YES;
            }
            else
            {
                [self.prs addVectorToRotation: GLKVector3Make(self.prs.rx + command.step.x * time, self.prs.ry + command.step.y * time, self.prs.rz + command.step.z * time)];
            }
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
