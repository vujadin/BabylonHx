// https://github.com/evanw/glfx.js/blob/master/src/filters/fun/ink.js

#ifdef GL_ES
precision mediump float;
#endif

varying vec2 vUV;
uniform sampler2D textureSampler;
uniform float strength;
uniform vec2 screenSize;

void main() {
	vec2 dx = vec2(1.0 / screenSize.x, 0.0);
	vec2 dy = vec2(0.0, 1.0 / screenSize.y);
	vec4 color = texture2D(textureSampler, vUV);
	float bigTotal = 0.0;
	float smallTotal = 0.0;
	vec3 bigAverage = vec3(0.0);
	vec3 smallAverage = vec3(0.0);
	for (float x = -2.0; x <= 2.0; x += 1.0) {
		for (float y = -2.0; y <= 2.0; y += 1.0) {
			vec3 sample = texture2D(textureSampler, vUV + dx * x + dy * y).rgb;
			bigAverage += sample;
			bigTotal += 1.0;
			if (abs(x) + abs(y) < 2.0) {
				smallAverage += sample;
				smallTotal += 1.0;
			}
		}
	}
	
	vec3 edge = max(vec3(0.0), bigAverage / bigTotal - smallAverage / smallTotal);
	gl_FragColor = vec4(color.rgb - dot(edge, edge) * strength * 100000.0, color.a);
}