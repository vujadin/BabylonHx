// https://github.com/neilmendoza/ofxPostProcessing/blob/master/src/LimbDarkeningPass.cpp

#ifdef GL_ES
precision mediump float;
#endif

varying vec2 vUV;
uniform sampler2D textureSampler;

uniform float fAspect;

uniform vec3 startColor;
uniform vec3 endColor;

uniform float radialScale;
uniform float brightness;

void main() {
	vec2 vSunPositionScreenSpace = vec2(0.5);
	
	vec2 diff = vUV - vSunPositionScreenSpace;
	// Correct for aspect ratio
	diff.x *= fAspect;
	float prop = length( diff ) / radialScale;
	prop = clamp( 2.5 * pow( 1.0 - prop, 3.0 ), 0.0, 1.0 );
	
	vec3 color = mix( startColor, endColor, 1.0 - prop );
	vec4 base = texture2D(textureSampler, vUV);
	gl_FragColor = vec4(base.xyz * color, 1.0);
}