//
//  SSGAssetManager.h
//  SSGOGL
//
//  Created by John Stricker on 11/20/13.
//  Copyright (c) 2013 Sway Software. All rights reserved.
//
/*
 Responsible for loading and unloading of VAOs, VBOs, and Textures by keeping dictionaries for textures and VAO info
 */

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class SSGVaoInfo;

@interface SSGAssetManager : NSObject

+(GLuint)loadTexture:(NSString*)name ofType:(NSString*)type shouldLoadWithMipMapping:(BOOL)mipMappingOn;
+(SSGVaoInfo*)loadVaoInfo:(NSString*)name;
+(void)destroyVAO:(GLuint) vaoName;
+(void)unload;

@end
