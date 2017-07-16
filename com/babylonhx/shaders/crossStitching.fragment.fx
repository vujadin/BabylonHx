// http://www.geeks3d.com/20110408/cross-stitching-post-processing-shader-glsl-filter-geexlab-pixel-bender/

#ifdef GL_ES
precision highp float;
#endif

varying vec2 vUV; 
uniform sampler2D textureSampler;
uniform float rt_w;
uniform float rt_h;
uniform float stitching_size;
uniform float invert;
 
vec4 PostFX(sampler2D tex, vec2 uv)
{
  vec4 c = vec4(0.0);
  vec2 cPos = uv * vec2(rt_w, rt_h);
  vec2 tlPos = floor(cPos / vec2(stitching_size, stitching_size));
  tlPos *= stitching_size;
  int remX = int(mod(cPos.x, stitching_size));
  int remY = int(mod(cPos.y, stitching_size));
  if (remX == 0 && remY == 0)
    tlPos = cPos;
  vec2 blPos = tlPos;
  blPos.y += (stitching_size - 1.0);
  if ((remX == remY) || 
     (((int(cPos.x) - int(blPos.x)) == (int(blPos.y) - int(cPos.y)))))
  {
    if (invert == 1.0)
      c = vec4(0.2, 0.15, 0.05, 1.0);
    else
      c = texture2D(tex, tlPos * vec2(1.0/rt_w, 1.0/rt_h)) * 1.4;
  }
  else
  {
    if (invert == 1.0)
      c = texture2D(tex, tlPos * vec2(1.0/rt_w, 1.0/rt_h)) * 1.4;
    else
      c = vec4(0.0, 0.0, 0.0, 1.0);
  }
  return c;
}
 
void main (void)
{
  vec2 uv = vUV.st;
  gl_FragColor = PostFX(textureSampler, uv);
}