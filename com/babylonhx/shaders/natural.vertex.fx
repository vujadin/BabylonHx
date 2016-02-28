// https://github.com/hrydgard/ppsspp/blob/master/assets/shaders/natural.vsh

#ifdef GL_ES
precision highp float;
#endif

// Uniforms
uniform vec2 u_texelDelta;

// Attributes
attribute vec2 position;

// Output
varying vec2 vUV;
varying vec4 v_texcoord0;
varying vec4 v_texcoord1;
varying vec4 v_texcoord2;
varying vec4 v_texcoord3;

const vec2 madd = vec2(0.5, 0.5);

void main()
{
	vUV = position * madd + madd;
	gl_Position = vec4(position, 0.0, 1.0);
    
	v_texcoord0 = vUV.xyxy + vec4(-0.5,-0.5,-1.5,-1.5) * u_texelDelta.xyxy;
	v_texcoord1 = vUV.xyxy + vec4( 0.5,-0.5, 1.5,-1.5) * u_texelDelta.xyxy;
	v_texcoord2 = vUV.xyxy + vec4(-0.5, 0.5,-1.5, 1.5) * u_texelDelta.xyxy;
	v_texcoord3 = vUV.xyxy + vec4( 0.5, 0.5, 1.5, 1.5) * u_texelDelta.xyxy;
}