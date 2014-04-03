//
//  SSGModelData.c
//  SSGOGL
//
//  Created by John Stricker on 11/20/13.
//  Copyright (c) 2013 Sway Software. All rights reserved.
//

#import "SSGModelData.h"
#import <stdio.h>
#import <stdlib.h>
#import <OpenGLES/ES2/glext.h>

//load data only
//make sure the data is freed by the caller
SSGModelData* loadModelFromPath(const char* filepath)
{
    FILE* curFile = fopen(filepath,"r");
    if(!curFile)
    {
        return NULL;
    }
    
    SSGModelData *md = (SSGModelData*)malloc(sizeof(SSGModelData));
    fread(&md->arrayRows,sizeof(GLint),1,curFile);
    md->arrayRows *= 3;
    md->arraySize = md->arrayRows * 8 * sizeof(GLfloat);
    md->vertexArray = (GLfloat*) malloc(md->arraySize);
    fread(md->vertexArray,1,md->arraySize,curFile);
    md->arrayCount = md->arrayRows * 8;
    fclose(curFile);
    
    //used for testing model output
    
    int colCount = 0;
    for(int i = 0; i < md->arrayCount; ++i)
    {
        printf("%f",md->vertexArray[i]);
        if(++colCount == 8)
        {
            printf("\n");
            colCount = 0;
        }
        else
        {
            printf(", ");
        }
    }
     
    return md;
}

//load data and return a VAO
//assumes an active OpenGL context
void generateVaoInfoFromModelAtPath(const char *filepath, GLuint *vaoIndex, GLuint *vboIndex, GLuint *nVerts)
{
    SSGModelData *data = loadModelFromPath(filepath);
  
    if(!data)
    {
        return;
    }
    
    GLuint vao,vbo;

    glGenVertexArraysOES(1,&vao);
    glBindVertexArrayOES(vao);
    
    glGenBuffers(1,&vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, data->arraySize,data->vertexArray, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 32, (char*)NULL + 0);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 32, (char*)NULL + 12);
    glEnableVertexAttribArray(2);
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 32, (char*)NULL + 24);
    
    *nVerts = data->arrayRows;
    *vaoIndex = vao;
    *vboIndex = vbo;
    
    free(data->vertexArray);
    free(data);
}
void generateVaoInfoFromModelData(SSGModelData *data, GLuint *vaoIndex, GLuint *vboIndex, GLuint *nVerts)
{
    if(!data)
    {
        return;
    }
    
    GLuint vao,vbo;
    
    glGenVertexArraysOES(1,&vao);
    glBindVertexArrayOES(vao);
    
    glGenBuffers(1,&vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, data->arraySize,data->vertexArray, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 32, (char*)NULL + 0);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 32, (char*)NULL + 12);
    glEnableVertexAttribArray(2);
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 32, (char*)NULL + 24);
    
    *nVerts = data->arrayRows;
    *vaoIndex = vao;
    *vboIndex = vbo;

}