// https://www.shadertoy.com/view/XssSDs

#ifdef GL_ES
precision highp float;
#endif

varying vec2 vUV;
uniform sampler2D textureSampler;
uniform vec2 screenSize; 

vec2 Circle(float Start, float Points, float Point) 
{
	float Rad = (3.141592 * 2.0 * (1.0 / Points)) * (Point + Start);
	return vec2(sin(Rad), cos(Rad));
}

void main()
{
    vec2 PixelOffset = 1.0 / screenSize.xy;
    
    float Start = 2.0 / 14.0;
	vec2 Scale = 0.66 * 4.0 * 2.0 * PixelOffset.xy;
    
    vec3 N0 = texture2D(textureSampler, vUV + Circle(Start, 14.0, 0.0) * Scale).rgb;
    vec3 N1 = texture2D(textureSampler, vUV + Circle(Start, 14.0, 1.0) * Scale).rgb;
    vec3 N2 = texture2D(textureSampler, vUV + Circle(Start, 14.0, 2.0) * Scale).rgb;
    vec3 N3 = texture2D(textureSampler, vUV + Circle(Start, 14.0, 3.0) * Scale).rgb;
    vec3 N4 = texture2D(textureSampler, vUV + Circle(Start, 14.0, 4.0) * Scale).rgb;
    vec3 N5 = texture2D(textureSampler, vUV + Circle(Start, 14.0, 5.0) * Scale).rgb;
    vec3 N6 = texture2D(textureSampler, vUV + Circle(Start, 14.0, 6.0) * Scale).rgb;
    vec3 N7 = texture2D(textureSampler, vUV + Circle(Start, 14.0, 7.0) * Scale).rgb;
    vec3 N8 = texture2D(textureSampler, vUV + Circle(Start, 14.0, 8.0) * Scale).rgb;
    vec3 N9 = texture2D(textureSampler, vUV + Circle(Start, 14.0, 9.0) * Scale).rgb;
    vec3 N10 = texture2D(textureSampler, vUV + Circle(Start, 14.0, 10.0) * Scale).rgb;
    vec3 N11 = texture2D(textureSampler, vUV + Circle(Start, 14.0, 11.0) * Scale).rgb;
    vec3 N12 = texture2D(textureSampler, vUV + Circle(Start, 14.0, 12.0) * Scale).rgb;
    vec3 N13 = texture2D(textureSampler, vUV + Circle(Start, 14.0, 13.0) * Scale).rgb;
    vec3 N14 = texture2D(textureSampler, vUV).rgb;
    
    float W = 1.0 / 15.0;
    
    vec3 color = vec3(0,0,0);
    
	color.rgb = 
		(N0 * W) +
		(N1 * W) +
		(N2 * W) +
		(N3 * W) +
		(N4 * W) +
		(N5 * W) +
		(N6 * W) +
		(N7 * W) +
		(N8 * W) +
		(N9 * W) +
		(N10 * W) +
		(N11 * W) +
		(N12 * W) +
		(N13 * W) +
		(N14 * W);
    
    gl_FragColor = vec4(color.rgb,1.0);
}