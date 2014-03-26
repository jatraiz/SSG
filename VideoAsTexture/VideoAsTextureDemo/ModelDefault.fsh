//
//  ModelDefault.fsh
//  SSGOGL
//
//  Created by John Stricker on 3/9/12.
//  Copyright (c) 2012 Stricker Software. All rights reserved.
//

precision mediump float;
varying highp vec4 v_colorVarying;
varying vec2 v_texCoord;
uniform sampler2D u_colorMap;
uniform float u_alpha;
void main()
{
    gl_FragColor = texture2D(u_colorMap,v_texCoord) * v_colorVarying;
    gl_FragColor.rgba *=u_alpha;
}