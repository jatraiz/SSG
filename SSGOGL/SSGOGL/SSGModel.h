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
@class SSGVaoInfo;

@interface SSGModel : NSObject

@property (nonatomic) SSGPrs *prs;
@property (nonatomic) SSGPrs *worldPrs;
@property (nonatomic) BOOL isHidden;
@property (nonatomic) GLKVector4 diffuseColor;
@property (nonatomic) GLfloat alpha;
@property (nonatomic) GLfloat shadowMax;

//properties needed for subclasses: TO DO maybe: implement a protected solution such as dscribed here:
//http://stackoverflow.com/questions/11047351/workaround-to-accomplish-protected-properties-in-objective-c
@property (nonatomic) SSGVaoInfo* vaoInfo;
@property (nonatomic) GLuint texture0Id;
@property (nonatomic) GLKMatrix4 projection;
@property (nonatomic) GLKMatrix3 normalMatrix;
@property (nonatomic) GLKMatrix4 modelViewProjection;
@property (nonatomic) SSGDefaultShaderSettings *defaultShaderSettings;
@property (nonatomic) CGPoint dimensions2d;
@property (nonatomic) NSMutableArray *commands;
@property (nonatomic) NSMutableArray *finishedCommands;

- (instancetype) initWithModelFileName:(NSString*)modelFileName;
- (void)setProjection:(GLKMatrix4)projection;
- (void)setTexture0Id:(GLuint)texture0Id;
- (void)setDefaultShaderSettings:(SSGDefaultShaderSettings*)defaultShaderSettings;
- (void)setDimensions2dX:(GLfloat)x andY:(GLfloat)y;
- (BOOL)isTransformedPointWithinModel2d:(CGPoint)point;
- (void)addCommand:(SSGCommand*)command;
- (void)clearAllCommands;
- (void)clearCommandsOfTypes:(NSArray*)commandTypes;
- (void)clearCommandsOfType:(NSUInteger)commandType;
- (void)updateWithTime:(GLfloat)time;
- (void)processCommand:(SSGCommand*)command withTime:(GLfloat)time;
- (void)updateModelViewProjection;
- (void)draw;
@end
