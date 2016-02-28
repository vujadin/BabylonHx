// https://www.shadertoy.com/view/XlX3D4

#ifdef GL_ES
precision highp float;
#endif

varying vec2 vUV;
uniform sampler2D textureSampler;

uniform vec2 screenSize; 
uniform float elapsedTime;
uniform float waveFrequency;
uniform float waveAmplitude;

void main(void)
{ 
    //Constants
	vec2 baseUV = vUV.xy / screenSize.xy;
    
    //Main distortion   (wavyness)
    float time1 = elapsedTime * 0.6;
	vec2 mainUV = baseUV;
	mainUV.x += sin(time1 + mainUV.y * waveFrequency) * waveAmplitude;
	mainUV.y += sin(time1 + mainUV.x * waveFrequency) * waveAmplitude;
	
    //Composition
    vec2 differenceInUV = mainUV - baseUV;
    
	vec4 surfaceColor = texture2D(textureSampler, baseUV + differenceInUV);
    
	gl_FragColor = vec4(surfaceColor.xyz, 1.0);
}
