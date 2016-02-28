
varying vec2 vUV;
uniform sampler2D textureSampler;
uniform vec2 resolution;
uniform vec2 tileSize;
uniform float threads;

void main(void) 
{
  vec2 posInTile = mod(vUV, tileSize);
  vec2 tileNum = floor(vUV / tileSize);

  vec2 nrmPosInTile = posInTile / tileSize;
  tileNum.y += floor(abs(nrmPosInTile.x - 0.5) + nrmPosInTile.y);

  vec2 texCoord = tileNum * tileSize / resolution.xy;
 
  vec3 color = texture2D(textureSampler, texCoord).rgb;

  color *= fract((nrmPosInTile.y + abs(nrmPosInTile.x - 0.5)) * floor(threads));

  gl_FragColor = vec4(color, 1.0);

}