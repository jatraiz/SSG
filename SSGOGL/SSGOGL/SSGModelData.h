//
//  SSGModelData.h
//  SSGOGL
//
//  Created by John Stricker on 11/20/13.
//  Copyright (c) 2013 Sway Software. All rights reserved.
//
/*
 Designed to read and work with interleaved binary data (xyzxyzuv: vertex position: xyz, normals: xyz, and texture mapping: uv). Also can generate a Vertex Array Object (VAO) and Vertex Buffer Object (VBO)based on the data
 */

#ifndef SSGOGL_SSGModelData_h
#define SSGOGL_SSGModelData_h
#import <OpenGLES/ES2/gl.h>

typedef struct SSGModelData
{
    GLint arrayRows;
    GLint arraySize;
    GLint arrayCount;
    GLfloat * vertexArray;
}SSGModelData;

//load data only
SSGModelData* loadModelAtPath(const char *filepath);

//load data and return a VAO
//assumes an active OpenGL context
void generateVaoInfoFromModelAtPath(const char *filepath, GLuint *vaoIndex, GLuint *vboIndex, GLuint *nVerts);

#endif
