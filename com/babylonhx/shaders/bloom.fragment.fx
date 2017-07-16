// Simple Bloom shader; created to use in PPSSPP.
// Without excessive samples and complex nested loops
// (to make it compatible with low-end GPUs and to ensure ps_2_0 compatibility).

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D textureSampler;
varying vec2 vUV;	

float amount = 0.60; // suitable range = 0.00 - 1.00
float power = 0.5; // suitable range = 0.0 - 1.0

void main()
{
	vec3 color = texture2D(textureSampler, vUV.xy).xyz;
	vec4 sum = vec4(0);
	vec3 bloom;
  
	for(int i= -3 ;i < 3; i++)
	{
		sum += texture2D(textureSampler, vUV + vec2(-1, i) * 0.004) * amount;
		sum += texture2D(textureSampler, vUV + vec2(0, i) * 0.004) * amount;
		sum += texture2D(textureSampler, vUV + vec2(1, i) * 0.004) * amount;
	}
      
	if (color.r < 0.3 && color.g < 0.3 && color.b < 0.3)
	{
		bloom = sum.xyz * sum.xyz * 0.012 + color;
	}
	else
	{
		if (color.r < 0.5 && color.g < 0.5 && color.b < 0.5)
		{
			bloom = sum.xyz * sum.xyz * 0.009 + color;
		}
		else
		{
			bloom = sum.xyz * sum.xyz * 0.0075 + color;
		}
	}
  
	bloom = mix(color, bloom, power);
	gl_FragColor.rgb = bloom;
	gl_FragColor.a = 1.0;
}