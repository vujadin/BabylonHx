#ifdef GL_ES
precision highp float;
#endif 

varying vec2 vUV; 
uniform sampler2D textureSampler; 

void main (void) { 
	vec4 c = texture2D(textureSampler, vUV); 
	c += texture2D(textureSampler, vUV + 0.001); 
	c += texture2D(textureSampler, vUV + 0.003); 
	c += texture2D(textureSampler, vUV + 0.005); 
	c += texture2D(textureSampler, vUV + 0.007); 
	c += texture2D(textureSampler, vUV + 0.009); 
	c += texture2D(textureSampler, vUV + 0.011); 
	c += texture2D(textureSampler, vUV - 0.001); 
	c += texture2D(textureSampler, vUV - 0.003); 
	c += texture2D(textureSampler, vUV - 0.005); 
	c += texture2D(textureSampler, vUV - 0.007); 
	c += texture2D(textureSampler, vUV - 0.009); 
	c += texture2D(textureSampler, vUV - 0.011); 
	c.rgb = vec3((c.r + c.g + c.b) / 3.0); 
	c = c / 9.5; 
	
	gl_FragColor = c; 
}