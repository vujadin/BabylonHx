// https://github.com/evanw/glfx.js/blob/master/src/filters/adjust/huesaturation.js

#ifdef GL_ES
precision mediump float;
#endif

varying vec2 vUV;
uniform sampler2D textureSampler;
uniform float hue;
uniform float saturation;

void main() {
	vec4 color = texture2D(textureSampler, vUV);
	
	/* hue adjustment, wolfram alpha: RotationTransform[angle, {1, 1, 1}][{x, y, z}] */
	float angle = hue * 3.14159265;
	float s = sin(angle), c = cos(angle);
	vec3 weights = (vec3(2.0 * c, -sqrt(3.0) * s - c, sqrt(3.0) * s - c) + 1.0) / 3.0;
	float len = length(color.rgb);
	color.rgb = vec3(
		dot(color.rgb, weights.xyz),
		dot(color.rgb, weights.zxy),
		dot(color.rgb, weights.yzx)
	);
	
	/* saturation adjustment */
	float average = (color.r + color.g + color.b) / 3.0;
	if (saturation > 0.0) {
		color.rgb += (average - color.rgb) * (1.0 - 1.0 / (1.001 - saturation));
	} else {
		color.rgb += (average - color.rgb) * (-saturation);
	}
	
	gl_FragColor = color;
}