//
//  SSGAssetManager.m
//  SSGOGL
//
//  Created by John Stricker on 11/20/13.
//  Copyright (c) 2013 Sway Software. All rights reserved.
//
/*
 Responsible for loading and unloading of VAOs, VBOs, and Textures by keeping dictionaries for textures and VAO info
 */

#import "SSGAssetManager.h"
#import "SSGModelData.h"
#import "SSGVaoInfo.h"
#import <OpenGLES/ES2/gl.h>

static NSMutableDictionary *loadedTextures;
static NSMutableDictionary *loadedVaos;

@implementation SSGAssetManager

+(GLuint)loadTexture:(NSString *)name ofType:(NSString *)type shouldLoadWithMipMapping:(BOOL)mipMappingOn
{
    if((loadedTextures) && [loadedTextures objectForKey:name])
    {
        return ((GLKTextureInfo*)[loadedTextures objectForKey:name]).name;
    }
    
    if(!loadedTextures)
    {
        loadedTextures = [[NSMutableDictionary alloc] init];
    }
   
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:type];
    if(!path)
    {
        NSLog(@"TEXTURE FILE NOT FOUND for:%@.%@",name,type);
        return 0;
    }
    
    NSError *error;
    NSMutableDictionary *options= [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:GLKTextureLoaderOriginBottomLeft];

    if(mipMappingOn)
    {
        [options setObject:[NSNumber numberWithBool:YES] forKey:GLKTextureLoaderGenerateMipmaps];
    }
    
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];

    if(error != nil)
    {
        NSLog(@"ERROR LOADING TEXTURE: %@: %@",path,[error debugDescription]);
        return 0;
    }
    
    return textureInfo.name;
        
}

+(SSGVaoInfo*)loadVaoInfo:(NSString*)name
{
    if((loadedVaos) && [loadedVaos objectForKey:name])
    {
        return (SSGVaoInfo*)[loadedVaos objectForKey:name];
    }
    
    if(!loadedVaos)
    {
        loadedVaos = [[NSMutableDictionary alloc] init];
    }
    
    NSString* filepathname = [[NSBundle mainBundle] pathForResource:name ofType:@"model"];
 
    if(!filepathname)
    {
        NSLog(@"UNABLE TO LOCATE MODEL DATA for %@",name);
        return nil;
    }
    
    GLuint vao,vbo,nVerts;
    generateVaoInfoFromModelAtPath([filepathname cStringUsingEncoding:NSASCIIStringEncoding], &vao, &vbo, &nVerts);
    SSGVaoInfo *vic = [[SSGVaoInfo alloc] initWithVaoIndex:vao vboIndex:vbo andNVerts:nVerts];
    [loadedVaos setValue:vic forKey:name];
    return vic;
}

//straight from iOS GLEssentials
+(void)destroyVAO:(GLuint) vaoName
{
	GLuint index;
	GLuint bufName;
	
	// Bind the VAO so we can get data from it
	glBindVertexArrayOES(vaoName);
	
	// For every possible attribute set in the VAO
	for(index = 0; index < 16; index++)
	{
		// Get the VBO set for that attibute
		glGetVertexAttribiv(index , GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING, (GLint*)&bufName);
		
		// If there was a VBO set...
		if(bufName)
		{
			//...delete the VBO
			glDeleteBuffers(1, &bufName);
		}
	}
    
	
	// Get any element array VBO set in the VAO
	glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, (GLint*)&bufName);
	
	// If there was a element array VBO set in the VAO
	if(bufName)
	{
		//...delete the VBO
		glDeleteBuffers(1, &bufName);
	}
	
	// Finally, delete the VAO
	glDeleteVertexArraysOES(1, &vaoName);
    
}

+(void)unload
{
    // delete textures
    if(loadedTextures)
    {
        [loadedTextures enumerateKeysAndObjectsUsingBlock:^(id key, GLKTextureInfo *obj, BOOL *stop) {
            GLuint textureId = obj.name;
            glDeleteTextures(1,&textureId);
        }];
        loadedTextures = nil;
    }
    // delete VAOs
    if(loadedVaos)
    {
        [loadedVaos enumerateKeysAndObjectsUsingBlock:^(id key, SSGVaoInfo *obj, BOOL *stop) {
            [self destroyVAO:obj.vaoIndex];
        }];
    }
    
}

@end
