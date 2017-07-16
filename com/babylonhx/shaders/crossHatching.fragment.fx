// http://www.geeks3d.com/20110219/shader-library-crosshatching-glsl-filter/

#ifdef GL_ES
precision highp float;
#endif

varying vec2 vUV; 
uniform sampler2D textureSampler;

uniform float vx_offset;
uniform float hatch_y_offset; // 5.0
uniform float lum_threshold_1; // 1.0
uniform float lum_threshold_2; // 0.7
uniform float lum_threshold_3; // 0.5
uniform float lum_threshold_4; // 0.3

void main(void) 
{   
  vec3 tc = vec3(1.0, 0.0, 0.0);
  
  if (vUV.x < vx_offset)
  {
    float lum = length(texture2D(textureSampler, vUV).rgb);
    tc = vec3(1.0, 1.0, 1.0);
  
    if (lum < lum_threshold_1) 
    {
      if (mod(gl_FragCoord.x + gl_FragCoord.y, 10.0) == 0.0) 
        tc = vec3(0.0, 0.0, 0.0);
    }  
  
    if (lum < lum_threshold_2) 
    {
      if (mod(gl_FragCoord.x - gl_FragCoord.y, 10.0) == 0.0) 
        tc = vec3(0.0, 0.0, 0.0);
    }  
  
    if (lum < lum_threshold_3) 
    {
      if (mod(gl_FragCoord.x + gl_FragCoord.y - hatch_y_offset, 10.0) == 0.0) 
        tc = vec3(0.0, 0.0, 0.0);
    }  
  
    if (lum < lum_threshold_4) 
    {
      if (mod(gl_FragCoord.x - gl_FragCoord.y - hatch_y_offset, 10.0) == 0.0) 
        tc = vec3(0.0, 0.0, 0.0);
    }
  }
  else 
  {
    tc = texture2D(textureSampler, vUV).rgb;
  }
  
  gl_FragColor = vec4(tc, 1.0);
}