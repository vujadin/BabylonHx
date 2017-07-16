// https://github.com/evanw/glfx.js/blob/master/src/filters/adjust/vibrance.js

#ifdef GL_ES
precision highp float;
#endif

varying vec2 vUV;
uniform sampler2D textureSampler;
uniform float amount;

void main() {
	vec4 color = texture2D(textureSampler, vUV);
	float average = (color.r + color.g + color.b) / 3.0;
	float mx = max(color.r, max(color.g, color.b));
	float amt = (mx - average) * (-amount * 3.0);
	color.rgb = mix(color.rgb, vec3(mx), amt);
	
	gl_FragColor = color;
}