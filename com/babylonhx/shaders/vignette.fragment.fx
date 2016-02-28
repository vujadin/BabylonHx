// https://github.com/01010111/PostProcess-GLSL/blob/master/shaders/vignette.frag

#ifdef GL_ES
precision mediump float;
#endif

varying vec2 vUV;
uniform sampler2D textureSampler;
uniform vec2 resolution;
uniform float outerRadius; 
uniform float innerRadius; 
uniform float intensity;

void main(void)
{
	vec4 color = texture2D(textureSampler, vUV);
	
	vec2 relativePosition = gl_FragCoord.xy / resolution - 0.5;
	float len = length(relativePosition);
	float vignette = smoothstep(outerRadius, innerRadius, len);
	color.rgb = mix(color.rgb, color.rgb * vignette, intensity);
	
	gl_FragColor = color;
}