package com.babylonhx.materials.lib.lava;

import com.babylonhx.math.Color3;
import com.babylonhx.math.Matrix;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.animations.IAnimatable;

/**
 * ...
 * @author Krtolica Vujadin
 */
class LavaMaterial extends Material {
	
	static var fragmentShader:String = "precision highp float; \n\n// Constants \nuniform vec3 vEyePosition; \nuniform vec4 vDiffuseColor; \n\n// Input \nvarying vec3 vPositionW; \n\n// MAGMAAAA \nuniform float time; \nuniform float speed; \nuniform vec3 fogColor; \nuniform sampler2D noiseTexture; \n\n// Varying \nvarying float noise; \n\n#ifdef NORMAL \nvarying vec3 vNormalW; \n#endif \n\n#ifdef VERTEXCOLOR \nvarying vec4 vColor; \n#endif \n\n// Lights \n#ifdef LIGHT0 \nuniform vec4 vLightData0; \nuniform vec4 vLightDiffuse0; \n#ifdef SHADOW0 \n#if defined(SPOTLIGHT0) || defined(DIRLIGHT0) \nvarying vec4 vPositionFromLight0; \nuniform sampler2D shadowSampler0; \n#else \nuniform samplerCube shadowSampler0; \n#endif \nuniform vec3 shadowsInfo0; \n#endif \n#ifdef SPOTLIGHT0 \nuniform vec4 vLightDirection0; \n#endif \n#ifdef HEMILIGHT0 \nuniform vec3 vLightGround0; \n#endif \n#endif \n\n#ifdef LIGHT1 \nuniform vec4 vLightData1; \nuniform vec4 vLightDiffuse1; \n#ifdef SHADOW1 \n#if defined(SPOTLIGHT1) || defined(DIRLIGHT1) \nvarying vec4 vPositionFromLight1; \nuniform sampler2D shadowSampler1; \n#else \nuniform samplerCube shadowSampler1; \n#endif \nuniform vec3 shadowsInfo1; \n#endif \n#ifdef SPOTLIGHT1 \nuniform vec4 vLightDirection1; \n#endif \n#ifdef HEMILIGHT1 \nuniform vec3 vLightGround1; \n#endif \n#endif \n\n#ifdef LIGHT2 \nuniform vec4 vLightData2; \nuniform vec4 vLightDiffuse2; \n#ifdef SHADOW2 \n#if defined(SPOTLIGHT2) || defined(DIRLIGHT2) \nvarying vec4 vPositionFromLight2; \nuniform sampler2D shadowSampler2; \n#else \nuniform samplerCube shadowSampler2; \n#endif \nuniform vec3 shadowsInfo2; \n#endif \n#ifdef SPOTLIGHT2 \nuniform vec4 vLightDirection2; \n#endif \n#ifdef HEMILIGHT2 \nuniform vec3 vLightGround2; \n#endif \n#endif \n\n#ifdef LIGHT3 \nuniform vec4 vLightData3; \nuniform vec4 vLightDiffuse3; \n#ifdef SHADOW3 \n#if defined(SPOTLIGHT3) || defined(DIRLIGHT3) \nvarying vec4 vPositionFromLight3; \nuniform sampler2D shadowSampler3; \n#else \nuniform samplerCube shadowSampler3; \n#endif \nuniform vec3 shadowsInfo3; \n#endif \n#ifdef SPOTLIGHT3 \nuniform vec4 vLightDirection3; \n#endif \n#ifdef HEMILIGHT3 \nuniform vec3 vLightGround3; \n#endif \n#endif \n\n// Samplers \n#ifdef DIFFUSE \nvarying vec2 vDiffuseUV; \nuniform sampler2D diffuseSampler; \nuniform vec2 vDiffuseInfos; \n#endif \n\n// Shadows \n#ifdef SHADOWS \n\nfloat unpack(vec4 color) \n{ \n	const vec4 bit_shift = vec4(1.0 / (255.0 * 255.0 * 255.0), 1.0 / (255.0 * 255.0), 1.0 / 255.0, 1.0); \n	return dot(color, bit_shift); \n} \n\n#if defined(POINTLIGHT0) || defined(POINTLIGHT1) || defined(POINTLIGHT2) || defined(POINTLIGHT3) \nfloat computeShadowCube(vec3 lightPosition, samplerCube shadowSampler, float darkness, float bias) \n{ \n	vec3 directionToLight = vPositionW - lightPosition; \n	float depth = length(directionToLight); \n\n	depth = clamp(depth, 0., 1.); \n\n	directionToLight.y = 1.0 - directionToLight.y; \n\n	float shadow = unpack(textureCube(shadowSampler, directionToLight)) + bias; \n\n	if (depth > shadow) \n	{ \n		return darkness; \n	} \n	return 1.0; \n} \n\nfloat computeShadowWithPCFCube(vec3 lightPosition, samplerCube shadowSampler, float bias, float darkness) \n{ \n	vec3 directionToLight = vPositionW - lightPosition; \n	float depth = length(directionToLight); \n\n	depth = clamp(depth, 0., 1.); \n\n	directionToLight.y = 1.0 - directionToLight.y; \n\n	float visibility = 1.; \n\n	vec3 poissonDisk[4]; \n	poissonDisk[0] = vec3(-0.094201624, 0.04, -0.039906216); \n	poissonDisk[1] = vec3(0.094558609, -0.04, -0.076890725); \n	poissonDisk[2] = vec3(-0.094184101, 0.01, -0.092938870); \n	poissonDisk[3] = vec3(0.034495938, -0.01, 0.029387760); \n\n	// Poisson Sampling \n	float biasedDepth = depth - bias; \n\n	if (unpack(textureCube(shadowSampler, directionToLight + poissonDisk[0])) < biasedDepth) visibility -= 0.25; \n	if (unpack(textureCube(shadowSampler, directionToLight + poissonDisk[1])) < biasedDepth) visibility -= 0.25; \n	if (unpack(textureCube(shadowSampler, directionToLight + poissonDisk[2])) < biasedDepth) visibility -= 0.25; \n	if (unpack(textureCube(shadowSampler, directionToLight + poissonDisk[3])) < biasedDepth) visibility -= 0.25; \n\n	return  min(1.0, visibility + darkness); \n} \n#endif \n\n#if defined(SPOTLIGHT0) || defined(SPOTLIGHT1) || defined(SPOTLIGHT2) || defined(SPOTLIGHT3) ||  defined(DIRLIGHT0) || defined(DIRLIGHT1) || defined(DIRLIGHT2) || defined(DIRLIGHT3) \nfloat computeShadow(vec4 vPositionFromLight, sampler2D shadowSampler, float darkness, float bias) \n{ \n	vec3 depth = vPositionFromLight.xyz / vPositionFromLight.w; \n	depth = 0.5 * depth + vec3(0.5); \n	vec2 uv = depth.xy; \n\n	if (uv.x < 0. || uv.x > 1.0 || uv.y < 0. || uv.y > 1.0) \n	{ \n		return 1.0; \n	} \n\n	float shadow = unpack(texture2D(shadowSampler, uv)) + bias; \n\n	if (depth.z > shadow) \n	{ \n		return darkness; \n	} \n	return 1.; \n} \n\nfloat computeShadowWithPCF(vec4 vPositionFromLight, sampler2D shadowSampler, float mapSize, float bias, float darkness) \n{ \n	vec3 depth = vPositionFromLight.xyz / vPositionFromLight.w; \n	depth = 0.5 * depth + vec3(0.5); \n	vec2 uv = depth.xy; \n\n	if (uv.x < 0. || uv.x > 1.0 || uv.y < 0. || uv.y > 1.0) \n	{ \n		return 1.0; \n	} \n\n	float visibility = 1.; \n\n	vec2 poissonDisk[4]; \n	poissonDisk[0] = vec2(-0.94201624, -0.39906216); \n	poissonDisk[1] = vec2(0.94558609, -0.76890725); \n	poissonDisk[2] = vec2(-0.094184101, -0.92938870); \n	poissonDisk[3] = vec2(0.34495938, 0.29387760); \n\n	// Poisson Sampling \n	float biasedDepth = depth.z - bias; \n\n	if (unpack(texture2D(shadowSampler, uv + poissonDisk[0] / mapSize)) < biasedDepth) visibility -= 0.25; \n	if (unpack(texture2D(shadowSampler, uv + poissonDisk[1] / mapSize)) < biasedDepth) visibility -= 0.25; \n	if (unpack(texture2D(shadowSampler, uv + poissonDisk[2] / mapSize)) < biasedDepth) visibility -= 0.25; \n	if (unpack(texture2D(shadowSampler, uv + poissonDisk[3] / mapSize)) < biasedDepth) visibility -= 0.25; \n\n	return  min(1.0, visibility + darkness); \n} \n\n// Thanks to http://devmaster.net/ \nfloat unpackHalf(vec2 color) \n{ \n	return color.x + (color.y / 255.0); \n} \n\nfloat linstep(float low, float high, float v) { \n	return clamp((v - low) / (high - low), 0.0, 1.0); \n} \n\nfloat ChebychevInequality(vec2 moments, float compare, float bias) \n{ \n	float p = smoothstep(compare - bias, compare, moments.x); \n	float variance = max(moments.y - moments.x * moments.x, 0.02); \n	float d = compare - moments.x; \n	float p_max = linstep(0.2, 1.0, variance / (variance + d * d)); \n\n	return clamp(max(p, p_max), 0.0, 1.0); \n} \n\nfloat computeShadowWithVSM(vec4 vPositionFromLight, sampler2D shadowSampler, float bias, float darkness) \n{ \n	vec3 depth = vPositionFromLight.xyz / vPositionFromLight.w; \n	depth = 0.5 * depth + vec3(0.5); \n	vec2 uv = depth.xy; \n\n	if (uv.x < 0. || uv.x > 1.0 || uv.y < 0. || uv.y > 1.0 || depth.z >= 1.0) \n	{ \n		return 1.0; \n	} \n\n	vec4 texel = texture2D(shadowSampler, uv); \n\n	vec2 moments = vec2(unpackHalf(texel.xy), unpackHalf(texel.zw)); \n	return min(1.0, 1.0 - ChebychevInequality(moments, depth.z, bias) + darkness); \n} \n#endif \n#endif \n\n\n#ifdef CLIPPLANE \nvarying float fClipDistance; \n#endif \n\n// Fog \n#ifdef FOG \n\n#define FOGMODE_NONE    0. \n#define FOGMODE_EXP     1. \n#define FOGMODE_EXP2    2. \n#define FOGMODE_LINEAR  3. \n#define E 2.71828 \n\nuniform vec4 vFogInfos; \nuniform vec3 vFogColor; \nvarying float fFogDistance; \n\nfloat CalcFogFactor() \n{ \n	float fogCoeff = 1.0; \n	float fogStart = vFogInfos.y; \n	float fogEnd = vFogInfos.z; \n	float fogDensity = vFogInfos.w; \n\n	if (FOGMODE_LINEAR == vFogInfos.x) \n	{ \n		fogCoeff = (fogEnd - fFogDistance) / (fogEnd - fogStart); \n	} \n	else if (FOGMODE_EXP == vFogInfos.x) \n	{ \n		fogCoeff = 1.0 / pow(E, fFogDistance * fogDensity); \n	} \n	else if (FOGMODE_EXP2 == vFogInfos.x) \n	{ \n		fogCoeff = 1.0 / pow(E, fFogDistance * fFogDistance * fogDensity * fogDensity); \n	} \n\n	return clamp(fogCoeff, 0.0, 1.0); \n} \n#endif \n\n// Light Computing \nstruct lightingInfo \n{ \n	vec3 diffuse; \n}; \n\nlightingInfo computeLighting(vec3 viewDirectionW, vec3 vNormal, vec4 lightData, vec3 diffuseColor, float range) { \n	lightingInfo result; \n\n	vec3 lightVectorW; \n	float attenuation = 1.0; \n	if (lightData.w == 0.) \n	{ \n		vec3 direction = lightData.xyz - vPositionW; \n\n		attenuation = max(0., 1.0 - length(direction) / range); \n		lightVectorW = normalize(direction); \n	} \n	else \n	{ \n		lightVectorW = normalize(-lightData.xyz); \n	} \n\n	// diffuse \n	float ndl = max(0., dot(vNormal, lightVectorW)); \n	result.diffuse = ndl * diffuseColor * attenuation; \n\n	return result; \n} \n\nlightingInfo computeSpotLighting(vec3 viewDirectionW, vec3 vNormal, vec4 lightData, vec4 lightDirection, vec3 diffuseColor, float range) { \n	lightingInfo result; \n\n	vec3 direction = lightData.xyz - vPositionW; \n	vec3 lightVectorW = normalize(direction); \n	float attenuation = max(0., 1.0 - length(direction) / range); \n\n	// diffuse \n	float cosAngle = max(0., dot(-lightDirection.xyz, lightVectorW)); \n	float spotAtten = 0.0; \n\n	if (cosAngle >= lightDirection.w) \n	{ \n		cosAngle = max(0., pow(cosAngle, lightData.w)); \n		spotAtten = clamp((cosAngle - lightDirection.w) / (1. - cosAngle), 0.0, 1.0); \n\n		// Diffuse \n		float ndl = max(0., dot(vNormal, -lightDirection.xyz)); \n		result.diffuse = ndl * spotAtten * diffuseColor * attenuation; \n\n		return result; \n	} \n\n	result.diffuse = vec3(0.); \n\n	return result; \n} \n\nlightingInfo computeHemisphericLighting(vec3 viewDirectionW, vec3 vNormal, vec4 lightData, vec3 diffuseColor, vec3 groundColor) { \n	lightingInfo result; \n\n	// Diffuse \n	float ndl = dot(vNormal, lightData.xyz) * 0.5 + 0.5; \n	result.diffuse = mix(groundColor, diffuseColor, ndl); \n\n	return result; \n} \n\n\nfloat random( vec3 scale, float seed ){ \nreturn fract( sin( dot( gl_FragCoord.xyz + seed, scale ) ) * 43758.5453 + seed ) ; \n} \n\n\nvoid main(void) { \n	// Clip plane \n#ifdef CLIPPLANE \n	if (fClipDistance > 0.0) \n		discard; \n#endif \n\n	vec3 viewDirectionW = normalize(vEyePosition - vPositionW); \n\n	// Base color \n	vec4 baseColor = vec4(1., 1., 1., 1.); \n	vec3 diffuseColor = vDiffuseColor.rgb; \n\n	// Alpha \n	float alpha = vDiffuseColor.a; \n\n\n\n#ifdef DIFFUSE \n////// MAGMA /// \n\n	vec4 noiseTex = texture2D( noiseTexture, vDiffuseUV ); \n	vec2 T1 = vDiffuseUV + vec2( 1.5, -1.5 ) * time  * 0.02; \n	vec2 T2 = vDiffuseUV + vec2( -0.5, 2.0 ) * time * 0.01 * speed; \n\n	T1.x += noiseTex.x * 2.0; \n	T1.y += noiseTex.y * 2.0; \n	T2.x -= noiseTex.y * 0.2; \n	T2.y += noiseTex.z * 0.2; \n\n	float p = texture2D( noiseTexture, T1 * 3.0 ).a; \n\n	vec4 lavaColor = texture2D( diffuseSampler, T2 * 4.0); \n	vec4 temp = lavaColor * ( vec4( p, p, p, p ) * 2.0 ) + ( lavaColor * lavaColor - 0.1 ); \n\n	baseColor = temp; \n\n	float fogDensity = 0.15; \n	float depth = gl_FragCoord.z * 4.0; \n	const float LOG2 = 1.442695; \nfloat fogFactor = exp2( - fogDensity * fogDensity * depth * depth * LOG2 ); \nfogFactor = 1.0 - clamp( fogFactor, 0.0, 1.0 ); \n\nbaseColor = mix( baseColor, vec4( fogColor, baseColor.w ), fogFactor ); \n\n///// END MAGMA //// \n\n\n\n//	baseColor = texture2D(diffuseSampler, vDiffuseUV); \n\n#ifdef ALPHATEST \n	if (baseColor.a < 0.4) \n		discard; \n#endif \n\n	baseColor.rgb *= vDiffuseInfos.y; \n#endif \n\n#ifdef VERTEXCOLOR \n	baseColor.rgb *= vColor.rgb; \n#endif \n\n	// Bump \n#ifdef NORMAL \n	vec3 normalW = normalize(vNormalW); \n#else \n	vec3 normalW = vec3(1.0, 1.0, 1.0); \n#endif \n\n	// Lighting \n	vec3 diffuseBase = vec3(0., 0., 0.); \n	float shadow = 1.; \n\n#ifdef LIGHT0 \n#ifdef SPOTLIGHT0 \n	lightingInfo info = computeSpotLighting(viewDirectionW, normalW, vLightData0, vLightDirection0, vLightDiffuse0.rgb, vLightDiffuse0.a); \n#endif \n#ifdef HEMILIGHT0 \n	lightingInfo info = computeHemisphericLighting(viewDirectionW, normalW, vLightData0, vLightDiffuse0.rgb, vLightGround0); \n#endif \n#if defined(POINTLIGHT0) || defined(DIRLIGHT0) \n	lightingInfo info = computeLighting(viewDirectionW, normalW, vLightData0, vLightDiffuse0.rgb, vLightDiffuse0.a); \n#endif \n#ifdef SHADOW0 \n#ifdef SHADOWVSM0 \n	shadow = computeShadowWithVSM(vPositionFromLight0, shadowSampler0, shadowsInfo0.z, shadowsInfo0.x); \n#else \n#ifdef SHADOWPCF0 \n	#if defined(POINTLIGHT0) \n	shadow = computeShadowWithPCFCube(vLightData0.xyz, shadowSampler0, shadowsInfo0.z, shadowsInfo0.x); \n	#else \n	shadow = computeShadowWithPCF(vPositionFromLight0, shadowSampler0, shadowsInfo0.y, shadowsInfo0.z, shadowsInfo0.x); \n	#endif \n#else \n	#if defined(POINTLIGHT0) \n	shadow = computeShadowCube(vLightData0.xyz, shadowSampler0, shadowsInfo0.x, shadowsInfo0.z); \n	#else \n	shadow = computeShadow(vPositionFromLight0, shadowSampler0, shadowsInfo0.x, shadowsInfo0.z); \n	#endif \n#endif \n#endif \n#else \n	shadow = 1.; \n#endif \n	diffuseBase += info.diffuse * shadow; \n#endif \n\n#ifdef LIGHT1 \n#ifdef SPOTLIGHT1 \n	info = computeSpotLighting(viewDirectionW, normalW, vLightData1, vLightDirection1, vLightDiffuse1.rgb, vLightDiffuse1.a); \n#endif \n#ifdef HEMILIGHT1 \n	info = computeHemisphericLighting(viewDirectionW, normalW, vLightData1, vLightDiffuse1.rgb, vLightGround1.a); \n#endif \n#if defined(POINTLIGHT1) || defined(DIRLIGHT1) \n	info = computeLighting(viewDirectionW, normalW, vLightData1, vLightDiffuse1.rgb, vLightDiffuse1.a); \n#endif \n#ifdef SHADOW1 \n#ifdef SHADOWVSM1 \n	shadow = computeShadowWithVSM(vPositionFromLight1, shadowSampler1, shadowsInfo1.z, shadowsInfo1.x); \n#else \n#ifdef SHADOWPCF1 \n#if defined(POINTLIGHT1) \n	shadow = computeShadowWithPCFCube(vLightData1.xyz, shadowSampler1, shadowsInfo1.z, shadowsInfo1.x); \n#else \n	shadow = computeShadowWithPCF(vPositionFromLight1, shadowSampler1, shadowsInfo1.y, shadowsInfo1.z, shadowsInfo1.x); \n#endif \n#else \n	#if defined(POINTLIGHT1) \n	shadow = computeShadowCube(vLightData1.xyz, shadowSampler1, shadowsInfo1.x, shadowsInfo1.z); \n	#else \n	shadow = computeShadow(vPositionFromLight1, shadowSampler1, shadowsInfo1.x, shadowsInfo1.z); \n	#endif \n#endif \n#endif \n#else \n	shadow = 1.; \n#endif \n	diffuseBase += info.diffuse * shadow; \n#endif \n\n#ifdef LIGHT2 \n#ifdef SPOTLIGHT2 \n	info = computeSpotLighting(viewDirectionW, normalW, vLightData2, vLightDirection2, vLightDiffuse2.rgb, vLightDiffuse2.a); \n#endif \n#ifdef HEMILIGHT2 \n	info = computeHemisphericLighting(viewDirectionW, normalW, vLightData2, vLightDiffuse2.rgb, vLightGround2); \n#endif \n#if defined(POINTLIGHT2) || defined(DIRLIGHT2) \n	info = computeLighting(viewDirectionW, normalW, vLightData2, vLightDiffuse2.rgb, vLightDiffuse2.a); \n#endif \n#ifdef SHADOW2 \n#ifdef SHADOWVSM2 \n	shadow = computeShadowWithVSM(vPositionFromLight2, shadowSampler2, shadowsInfo2.z, shadowsInfo2.x); \n#else \n#ifdef SHADOWPCF2 \n#if defined(POINTLIGHT2) \n	shadow = computeShadowWithPCFCube(vLightData2.xyz, shadowSampler2, shadowsInfo2.z, shadowsInfo2.x); \n#else \n	shadow = computeShadowWithPCF(vPositionFromLight2, shadowSampler2, shadowsInfo2.y, shadowsInfo2.z, shadowsInfo2.x); \n#endif \n#else \n	#if defined(POINTLIGHT2) \n	shadow = computeShadowCube(vLightData2.xyz, shadowSampler2, shadowsInfo2.x, shadowsInfo2.z); \n	#else \n	shadow = computeShadow(vPositionFromLight2, shadowSampler2, shadowsInfo2.x, shadowsInfo2.z); \n	#endif \n#endif	 \n#endif	 \n#else \n	shadow = 1.; \n#endif \n	diffuseBase += info.diffuse * shadow; \n#endif \n\n#ifdef LIGHT3 \n#ifdef SPOTLIGHT3 \n	info = computeSpotLighting(viewDirectionW, normalW, vLightData3, vLightDirection3, vLightDiffuse3.rgb, vLightDiffuse3.a); \n#endif \n#ifdef HEMILIGHT3 \n	info = computeHemisphericLighting(viewDirectionW, normalW, vLightData3, vLightDiffuse3.rgb, vLightGround3); \n#endif \n#if defined(POINTLIGHT3) || defined(DIRLIGHT3) \n	info = computeLighting(viewDirectionW, normalW, vLightData3, vLightDiffuse3.rgb, vLightDiffuse3.a); \n#endif \n#ifdef SHADOW3 \n#ifdef SHADOWVSM3 \n		shadow = computeShadowWithVSM(vPositionFromLight3, shadowSampler3, shadowsInfo3.z, shadowsInfo3.x); \n#else \n#ifdef SHADOWPCF3 \n#if defined(POINTLIGHT3) \n	shadow = computeShadowWithPCFCube(vLightData3.xyz, shadowSampler3, shadowsInfo3.z, shadowsInfo3.x); \n#else \n	shadow = computeShadowWithPCF(vPositionFromLight3, shadowSampler3, shadowsInfo3.y, shadowsInfo3.z, shadowsInfo3.x); \n#endif \n#else \n	#if defined(POINTLIGHT3) \n	shadow = computeShadowCube(vLightData3.xyz, shadowSampler3, shadowsInfo3.x, shadowsInfo3.z); \n	#else \n	shadow = computeShadow(vPositionFromLight3, shadowSampler3, shadowsInfo3.x, shadowsInfo3.z); \n	#endif \n#endif	 \n#endif	 \n#else \n	shadow = 1.; \n#endif \n	diffuseBase += info.diffuse * shadow; \n#endif \n\n#ifdef VERTEXALPHA \n	alpha *= vColor.a; \n#endif \n\n	vec3 finalDiffuse = clamp(diffuseBase * diffuseColor, 0.0, 1.0) * baseColor.rgb; \n\n	// Composition \n	vec4 color = vec4(finalDiffuse, alpha); \n\n#ifdef FOG \n	float fog = CalcFogFactor(); \n	color.rgb = fog * color.rgb + (1.0 - fog) * vFogColor; \n#endif \n\n\n	gl_FragColor = color; \n}";
	
	static var vertexShader:String = "precision highp float; \n// Inputs \nuniform float time; \nuniform float speed; \n// Varying \nvarying float noise; \n\n// Attributes \nattribute vec3 position; \n#ifdef NORMAL \nattribute vec3 normal; \n#endif \n#ifdef UV1 \nattribute vec2 uv; \n#endif \n#ifdef UV2 \nattribute vec2 uv2; \n#endif \n#ifdef VERTEXCOLOR \nattribute vec4 color; \n#endif \n#ifdef BONES \nattribute vec4 matricesIndices; \nattribute vec4 matricesWeights; \n#endif \n\n// Uniforms \n\n#ifdef INSTANCES \nattribute vec4 world0; \nattribute vec4 world1; \nattribute vec4 world2; \nattribute vec4 world3; \n#else \nuniform mat4 world; \n#endif \n\nuniform mat4 view; \nuniform mat4 viewProjection; \n\n#ifdef DIFFUSE \nvarying vec2 vDiffuseUV; \nuniform mat4 diffuseMatrix; \nuniform vec2 vDiffuseInfos; \n#endif \n\n#ifdef BONES \nuniform mat4 mBones[BonesPerMesh]; \n#endif \n\n#ifdef POINTSIZE \nuniform float pointSize; \n#endif \n\n// Output \nvarying vec3 vPositionW; \n#ifdef NORMAL \nvarying vec3 vNormalW; \n#endif \n\n#ifdef VERTEXCOLOR \nvarying vec4 vColor; \n#endif \n\n#ifdef CLIPPLANE \nuniform vec4 vClipPlane; \nvarying float fClipDistance; \n#endif \n\n#ifdef FOG \nvarying float fFogDistance; \n#endif \n\n#ifdef SHADOWS \n#if defined(SPOTLIGHT0) || defined(DIRLIGHT0) \nuniform mat4 lightMatrix0; \nvarying vec4 vPositionFromLight0; \n#endif \n#if defined(SPOTLIGHT1) || defined(DIRLIGHT1) \nuniform mat4 lightMatrix1; \nvarying vec4 vPositionFromLight1; \n#endif \n#if defined(SPOTLIGHT2) || defined(DIRLIGHT2) \nuniform mat4 lightMatrix2; \nvarying vec4 vPositionFromLight2; \n#endif \n#if defined(SPOTLIGHT3) || defined(DIRLIGHT3) \nuniform mat4 lightMatrix3; \nvarying vec4 vPositionFromLight3; \n#endif \n#endif \n\n/* NOISE FUNCTIONS */ \n////// ASHIMA webgl noise \n////// https://github.com/ashima/webgl-noise/blob/master/src/classicnoise3D.glsl \nvec3 mod289(vec3 x) \n{ \n return x - floor(x * (1.0 / 289.0)) * 289.0; \n} \n\nvec4 mod289(vec4 x) \n{ \n return x - floor(x * (1.0 / 289.0)) * 289.0; \n} \n\nvec4 permute(vec4 x) \n{ \n return mod289(((x*34.0)+1.0)*x); \n} \n\nvec4 taylorInvSqrt(vec4 r) \n{ \n return 1.79284291400159 - 0.85373472095314 * r; \n} \n\nvec3 fade(vec3 t) { \n return t*t*t*(t*(t*6.0-15.0)+10.0); \n} \n\n// Classic Perlin noise, periodic variant \nfloat pnoise(vec3 P, vec3 rep) \n{ \n vec3 Pi0 = mod(floor(P), rep); // Integer part, modulo period \n vec3 Pi1 = mod(Pi0 + vec3(1.0), rep); // Integer part + 1, mod period \n Pi0 = mod289(Pi0); \n Pi1 = mod289(Pi1); \n vec3 Pf0 = fract(P); // Fractional part for interpolation \n vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0 \n vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x); \n vec4 iy = vec4(Pi0.yy, Pi1.yy); \n vec4 iz0 = Pi0.zzzz; \n vec4 iz1 = Pi1.zzzz; \n\n vec4 ixy = permute(permute(ix) + iy); \n vec4 ixy0 = permute(ixy + iz0); \n vec4 ixy1 = permute(ixy + iz1); \n\n vec4 gx0 = ixy0 * (1.0 / 7.0); \n vec4 gy0 = fract(floor(gx0) * (1.0 / 7.0)) - 0.5; \n gx0 = fract(gx0); \n vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0); \n vec4 sz0 = step(gz0, vec4(0.0)); \n gx0 -= sz0 * (step(0.0, gx0) - 0.5); \n gy0 -= sz0 * (step(0.0, gy0) - 0.5); \n\n vec4 gx1 = ixy1 * (1.0 / 7.0); \n vec4 gy1 = fract(floor(gx1) * (1.0 / 7.0)) - 0.5; \n gx1 = fract(gx1); \n vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1); \n vec4 sz1 = step(gz1, vec4(0.0)); \n gx1 -= sz1 * (step(0.0, gx1) - 0.5); \n gy1 -= sz1 * (step(0.0, gy1) - 0.5); \n\n vec3 g000 = vec3(gx0.x,gy0.x,gz0.x); \n vec3 g100 = vec3(gx0.y,gy0.y,gz0.y); \n vec3 g010 = vec3(gx0.z,gy0.z,gz0.z); \n vec3 g110 = vec3(gx0.w,gy0.w,gz0.w); \n vec3 g001 = vec3(gx1.x,gy1.x,gz1.x); \n vec3 g101 = vec3(gx1.y,gy1.y,gz1.y); \n vec3 g011 = vec3(gx1.z,gy1.z,gz1.z); \n vec3 g111 = vec3(gx1.w,gy1.w,gz1.w); \n\n vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110))); \n g000 *= norm0.x; \n g010 *= norm0.y; \n g100 *= norm0.z; \n g110 *= norm0.w; \n vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111))); \n g001 *= norm1.x; \n g011 *= norm1.y; \n g101 *= norm1.z; \n g111 *= norm1.w; \n\n float n000 = dot(g000, Pf0); \n float n100 = dot(g100, vec3(Pf1.x, Pf0.yz)); \n float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z)); \n float n110 = dot(g110, vec3(Pf1.xy, Pf0.z)); \n float n001 = dot(g001, vec3(Pf0.xy, Pf1.z)); \n float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z)); \n float n011 = dot(g011, vec3(Pf0.x, Pf1.yz)); \n float n111 = dot(g111, Pf1); \n\n vec3 fade_xyz = fade(Pf0); \n vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z); \n vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y); \n float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x); \n return 2.2 * n_xyz; \n} \n/* END FUNCTION */ \n\nfloat turbulence( vec3 p ) { \nfloat w = 100.0; \nfloat t = -.5; \nfor (float f = 1.0 ; f <= 10.0 ; f++ ){ \nfloat power = pow( 2.0, f ); \nt += abs( pnoise( vec3( power * p ), vec3( 10.0, 10.0, 10.0 ) ) / power ); \n} \nreturn t; \n} \n\nvoid main(void) { \n	mat4 finalWorld; \n\n#ifdef INSTANCES \n	finalWorld = mat4(world0, world1, world2, world3); \n#else \n	finalWorld = world; \n#endif \n\n#ifdef BONES \n	mat4 m0 = mBones[int(matricesIndices.x)] * matricesWeights.x; \n	mat4 m1 = mBones[int(matricesIndices.y)] * matricesWeights.y; \n	mat4 m2 = mBones[int(matricesIndices.z)] * matricesWeights.z; \n\n#ifdef BONES4 \n	mat4 m3 = mBones[int(matricesIndices.w)] * matricesWeights.w; \n	finalWorld = finalWorld * (m0 + m1 + m2 + m3); \n#else \n	finalWorld = finalWorld * (m0 + m1 + m2); \n#endif  \n\n#endif \n\n\n// get a turbulent 3d noise using the normal, normal to high freq \nnoise = 10.0 *  -.10 * turbulence( .5 * normal + time*1.15 ); \n// get a 3d noise using the position, low frequency \nfloat b = 5.0 * pnoise( 0.05 * position +vec3(time*1.025), vec3( 100.0 ) ); \n// compose both noises \nfloat displacement = - 1.5 * noise + b; \n\n// move the position along the normal and transform it \nvec3 newPosition = position + normal * displacement; \ngl_Position = viewProjection * finalWorld * vec4( newPosition, 1.0 ); \n\n\n	vec4 worldPos = finalWorld * vec4(newPosition, 1.0); \n	vPositionW = vec3(worldPos); \n\n#ifdef NORMAL \n	vNormalW = normalize(vec3(finalWorld * vec4(normal, 0.0))); \n#endif \n\n	// Texture coordinates \n#ifndef UV1 \n	vec2 uv = vec2(0., 0.); \n#endif \n#ifndef UV2 \n	vec2 uv2 = vec2(0., 0.); \n#endif \n\n#ifdef DIFFUSE \n	if (vDiffuseInfos.x == 0.) \n	{ \n		vDiffuseUV = vec2(diffuseMatrix * vec4(uv, 1.0, 0.0)); \n	} \n	else \n	{ \n		vDiffuseUV = vec2(diffuseMatrix * vec4(uv2, 1.0, 0.0)); \n	} \n#endif \n\n	// Clip plane \n#ifdef CLIPPLANE \n	fClipDistance = dot(worldPos, vClipPlane); \n#endif \n\n	// Fog \n#ifdef FOG \n	fFogDistance = (view * worldPos).z; \n#endif \n\n	// Shadows \n#ifdef SHADOWS \n#if defined(SPOTLIGHT0) || defined(DIRLIGHT0) \n	vPositionFromLight0 = lightMatrix0 * worldPos; \n#endif \n#if defined(SPOTLIGHT1) || defined(DIRLIGHT1) \n	vPositionFromLight1 = lightMatrix1 * worldPos; \n#endif \n#if defined(SPOTLIGHT2) || defined(DIRLIGHT2) \n	vPositionFromLight2 = lightMatrix2 * worldPos; \n#endif \n#if defined(SPOTLIGHT3) || defined(DIRLIGHT3) \n	vPositionFromLight3 = lightMatrix3 * worldPos; \n#endif \n#endif \n\n	// Vertex color \n#ifdef VERTEXCOLOR \n	vColor = color; \n#endif \n\n	// Point size \n#ifdef POINTSIZE \n	gl_PointSize = pointSize; \n#endif \n}";
	

	public var diffuseTexture:BaseTexture;
	public var noiseTexture:BaseTexture;
	public var fogColor:Color3;
	public var speed:Float = 1;

	private var _lastTime:Float = 0;

	public var diffuseColor:Color3 = new Color3(1, 1, 1);
	public var disableLighting:Bool = false;

	private var _worldViewProjectionMatrix:Matrix = Matrix.Zero();
	private var _scaledDiffuse:Color3 = new Color3();
	private var _renderId:Int;

	private var _defines:LavaMaterialDefines = new LavaMaterialDefines();
	private var _cachedDefines:LavaMaterialDefines = new LavaMaterialDefines();
	

	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		if (!ShadersStore.Shaders.exists("lavamat.fragment")) {
			ShadersStore.Shaders.set("lavamat.fragment", fragmentShader);
			ShadersStore.Shaders.set("lavamat.vertex", vertexShader);
		}
		
		this._cachedDefines.BonesPerMesh = -1;
	}

	override public function needAlphaBlending():Bool {
		return (this.alpha < 1.0);
	}

	override public function needAlphaTesting():Bool {
		return false;
	}

	override public function getAlphaTestTexture():BaseTexture {
		return null;
	}

	// Methods   
	private function _checkCache(scene:Scene, ?mesh:AbstractMesh, useInstances:Bool = false):Bool {
		if (mesh == null) {
			return true;
		}
		
		if (this._defines.defines["INSTANCES"] != useInstances) {
			return false;
		}
		
		if (mesh._materialDefines != null && mesh._materialDefines.isEqual(this._defines)) {
			return true;
		}
		
		return false;
	}

	override public function isReady(?mesh:AbstractMesh, useInstances:Bool = false):Bool {
		if (this.checkReadyOnlyOnce) {
			if (this._wasPreviouslyReady) {
				return true;
			}
		}
		
		var scene = this.getScene();
		
		if (!this.checkReadyOnEveryCall) {
			if (this._renderId == scene.getRenderId()) {
				if (this._checkCache(scene, mesh, useInstances)) {
					return true;
				}
			}
		}
		
		var engine:Engine = scene.getEngine();
		var needNormals:Bool = false;
		var needUVs:Bool = false;
		
		this._defines.reset();
		
		// Textures
		if (scene.texturesEnabled) {
			if (this.diffuseTexture != null && StandardMaterial.DiffuseTextureEnabled) {
				if (!this.diffuseTexture.isReady()) {
					return false;
				} 
				else {
					needUVs = true;
					this._defines.defines["DIFFUSE"] = true;
				}
			}                
		}
		
		// Effect
		if (scene.clipPlane != null) {
			this._defines.defines["CLIPPLANE"] = true;
		}
		
		if (engine.getAlphaTesting()) {
			this._defines.defines["ALPHATEST"] = true;
		}
		
		// Point size
		if (this.pointsCloud || scene.forcePointsCloud) {
			this._defines.defines["POINTSIZE"] = true;
		}
		
		// Fog
		if (scene.fogEnabled && mesh != null && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE && this.fogEnabled) {
			this._defines.defines["FOG"] = true;
		}
		
		var lightIndex:Int = 0;
		if (scene.lightsEnabled && !this.disableLighting) {
			for (index in 0...scene.lights.length) {
				var light = scene.lights[index];
				
				if (!light.isEnabled()) {
					continue;
				}
				
				// Excluded check
				if (light._excludedMeshesIds.length > 0) {
					for (excludedIndex in 0...light._excludedMeshesIds.length) {
						var excludedMesh = scene.getMeshByID(light._excludedMeshesIds[excludedIndex]);
						
						if (excludedMesh != null) {
							light.excludedMeshes.push(excludedMesh);
						}
					}
					
					light._excludedMeshesIds = [];
				}
				
				// Included check
				if (light._includedOnlyMeshesIds.length > 0) {
					for (includedOnlyIndex in 0...light._includedOnlyMeshesIds.length) {
						var includedOnlyMesh = scene.getMeshByID(light._includedOnlyMeshesIds[includedOnlyIndex]);
						
						if (includedOnlyMesh != null) {
							light.includedOnlyMeshes.push(includedOnlyMesh);
						}
					}
					
					light._includedOnlyMeshesIds = [];
				}
				
				if (!light.canAffectMesh(mesh)) {
					continue;
				}
				needNormals = true;
				this._defines.defines["LIGHT" + lightIndex] = true;
				
				var type:String = light.type + lightIndex;
				this._defines.defines[type] = true;
				
				// Shadows
				if (scene.shadowsEnabled) {
					var shadowGenerator = light.getShadowGenerator();
					if (mesh != null && mesh.receiveShadows && shadowGenerator != null) {
						this._defines.defines["SHADOW" + lightIndex] = true;
						
						this._defines.defines["SHADOWS"] = true;
						
						if (shadowGenerator.useVarianceShadowMap || shadowGenerator.useBlurVarianceShadowMap) {
							this._defines.defines["SHADOWVSM" + lightIndex] = true;
						}
						
						if (shadowGenerator.usePoissonSampling) {
							this._defines.defines["SHADOWPCF" + lightIndex] = true;
						}
					}
				}
				
				lightIndex++;
				if (lightIndex == Material.maxSimultaneousLights) {
					break;
				}
			}
		}
		
		// Attribs
		if (mesh != null) {
			if (needNormals && mesh.isVerticesDataPresent(VertexBuffer.NormalKind)) {
				this._defines.defines["NORMAL"] = true;
			}
			if (needUVs) {
				if (mesh.isVerticesDataPresent(VertexBuffer.UVKind)) {
					this._defines.defines["UV1"] = true;
				}
				if (mesh.isVerticesDataPresent(VertexBuffer.UV2Kind)) {
					this._defines.defines["UV2"] = true;
				}
			}
			if (mesh.useVertexColors && mesh.isVerticesDataPresent(VertexBuffer.ColorKind)) {
				this._defines.defines["VERTEXCOLOR"] = true;
				
				if (mesh.hasVertexAlpha) {
					this._defines.defines["VERTEXALPHA"] = true;
				}
			}
			if (mesh.useBones && mesh.computeBonesUsingShaders) {
				this._defines.defines["BONES"] = true;
				this._defines.BonesPerMesh = (mesh.skeleton.bones.length + 1);
				this._defines.defines["BONES4"] = true;
			}
			
			// Instances
			if (useInstances) {
				this._defines.defines["INSTANCES"] = true;
			}
		}
		
		// Get correct effect      
		if (!this._defines.isEqual(this._cachedDefines) || this._effect == null) {
			this._defines.cloneTo(this._cachedDefines);
			
			scene.resetCachedMaterial();
			
			// Fallbacks
			var fallbacks:EffectFallbacks = new EffectFallbacks();             
			if (this._defines.defines["FOG"]) {
				fallbacks.addFallback(1, "FOG");
			}
			
			for (lightIndex in 0...Material.maxSimultaneousLights) {
				if (!this._defines.defines["LIGHT" + lightIndex]) {
					continue;
				}
				
				if (lightIndex > 0) {
					fallbacks.addFallback(lightIndex, "LIGHT" + lightIndex);
				}
				
				if (this._defines.defines["SHADOW" + lightIndex]) {
					fallbacks.addFallback(0, "SHADOW" + lightIndex);
				}
				
				if (this._defines.defines["SHADOWPCF" + lightIndex]) {
					fallbacks.addFallback(0, "SHADOWPCF" + lightIndex);
				}
				
				if (this._defines.defines["SHADOWVSM" + lightIndex]) {
					fallbacks.addFallback(0, "SHADOWVSM" + lightIndex);
				}
			}
					 
			if (this._defines.defines["BONES4"]) {
				fallbacks.addFallback(0, "BONES4");
			}
			
			//Attributes
			var attribs:Array<String> = [VertexBuffer.PositionKind];
			
			if (this._defines.defines["NORMAL"]) {
				attribs.push(VertexBuffer.NormalKind);
			}
			
			if (this._defines.defines["UV1"]) {
				attribs.push(VertexBuffer.UVKind);
			}
			
			if (this._defines.defines["UV2"]) {
				attribs.push(VertexBuffer.UV2Kind);
			}
			
			if (this._defines.defines["VERTEXCOLOR"]) {
				attribs.push(VertexBuffer.ColorKind);
			}
			
			if (this._defines.defines["BONES"]) {
				attribs.push(VertexBuffer.MatricesIndicesKind);
				attribs.push(VertexBuffer.MatricesWeightsKind);
			}
			
			if (this._defines.defines["INSTANCES"]) {
				attribs.push("world0");
				attribs.push("world1");
				attribs.push("world2");
				attribs.push("world3");
			}
			
			// Legacy browser patch
			var shaderName:String = "lavamat";
			var join:String = this._defines.toString();
			this._effect = scene.getEngine().createEffect(shaderName,
				attribs,
				["world", "view", "viewProjection", "vEyePosition", "vLightsType", "vDiffuseColor",
					"vLightData0", "vLightDiffuse0", "vLightSpecular0", "vLightDirection0", "vLightGround0", "lightMatrix0",
					"vLightData1", "vLightDiffuse1", "vLightSpecular1", "vLightDirection1", "vLightGround1", "lightMatrix1",
					"vLightData2", "vLightDiffuse2", "vLightSpecular2", "vLightDirection2", "vLightGround2", "lightMatrix2",
					"vLightData3", "vLightDiffuse3", "vLightSpecular3", "vLightDirection3", "vLightGround3", "lightMatrix3",
					"vFogInfos", "vFogColor", "pointSize",
					"vDiffuseInfos", 
					"mBones",
					"vClipPlane", "diffuseMatrix",
					"shadowsInfo0", "shadowsInfo1", "shadowsInfo2", "shadowsInfo3","time", "speed", "fogColor"
				],
				["diffuseSampler",
					"shadowSampler0", "shadowSampler1", "shadowSampler2", "shadowSampler3", "noiseTexture"
				],
				join, fallbacks, this.onCompiled, this.onError);
		}
		if (!this._effect.isReady()) {
			return false;
		}
		
		this._renderId = scene.getRenderId();
		this._wasPreviouslyReady = true;
		
		if (mesh != null) {
			if (mesh._materialDefines == null) {
				mesh._materialDefines = new LavaMaterialDefines();
			}
			
			this._defines.cloneTo(mesh._materialDefines);
		}
		
		return true;
	}

	override public function bindOnlyWorldMatrix(world:Matrix) {
		this._effect.setMatrix("world", world);
	}
	
	override public function bind(world:Matrix, ?mesh:Mesh) {
		var scene = this.getScene();
		
		// Matrices        
		this.bindOnlyWorldMatrix(world);
		this._effect.setMatrix("viewProjection", scene.getTransformMatrix());
		
		// Bones
		if (mesh != null && mesh.useBones && mesh.computeBonesUsingShaders) {
			this._effect.setMatrices("mBones", mesh.skeleton.getTransformMatrices());
		}
		
		if (scene.getCachedMaterial() != this) {
			// Textures        
			if (this.diffuseTexture != null && StandardMaterial.DiffuseTextureEnabled) {
				this._effect.setTexture("diffuseSampler", this.diffuseTexture);
				
				this._effect.setFloat2("vDiffuseInfos", this.diffuseTexture.coordinatesIndex, this.diffuseTexture.level);
				this._effect.setMatrix("diffuseMatrix", this.diffuseTexture.getTextureMatrix());
			}
			
			if (this.noiseTexture != null) {
				this._effect.setTexture("noiseTexture", this.noiseTexture);
			}
			
			// Clip plane
			if (scene.clipPlane != null) {
				var clipPlane = scene.clipPlane;
				this._effect.setFloat4("vClipPlane", clipPlane.normal.x, clipPlane.normal.y, clipPlane.normal.z, clipPlane.d);
			}
			
			// Point size
			if (this.pointsCloud) {
				this._effect.setFloat("pointSize", this.pointSize);
			}
			
			this._effect.setVector3("vEyePosition", scene._mirroredCameraPosition != null ? scene._mirroredCameraPosition : scene.activeCamera.position);                
		}
		
		this._effect.setColor4("vDiffuseColor", this._scaledDiffuse, this.alpha * mesh.visibility);

		if (scene.lightsEnabled && !this.disableLighting) {
			var lightIndex:Int = 0;
			for (index in 0...scene.lights.length) {
				var light = scene.lights[index];
				
				if (!light.isEnabled()) {
					continue;
				}
				
				if (!light.canAffectMesh(mesh)) {
					continue;
				}
				
				switch (light.type) {
					case "POINTLIGHT":
						light.transferToEffect(this._effect, "vLightData" + lightIndex);
						
					case "DIRLIGHT":
						light.transferToEffect(this._effect, "vLightData" + lightIndex);
						
					case "SPOTLIGHT":
						light.transferToEffect(this._effect, "vLightData" + lightIndex, "vLightDirection" + lightIndex);
						
					case "HEMILIGHT":
						light.transferToEffect(this._effect, "vLightData" + lightIndex, "vLightGround" + lightIndex);
						
				}
								
				light.diffuse.scaleToRef(light.intensity, this._scaledDiffuse);
				this._effect.setColor4("vLightDiffuse" + lightIndex, this._scaledDiffuse, light.range);
				
				// Shadows
				if (scene.shadowsEnabled) {
					var shadowGenerator = light.getShadowGenerator();
					if (mesh.receiveShadows && shadowGenerator != null) {
						this._effect.setMatrix("lightMatrix" + lightIndex, shadowGenerator.getTransformMatrix());
						this._effect.setTexture("shadowSampler" + lightIndex, shadowGenerator.getShadowMapForRendering());
						this._effect.setFloat3("shadowsInfo" + lightIndex, shadowGenerator.getDarkness(), shadowGenerator.getShadowMap().getSize().width, shadowGenerator.bias);
					}
				}
				
				lightIndex++;
				
				if (lightIndex == Material.maxSimultaneousLights) {
					break;
				}
			}
		}
		
		// View && Fog
		if (scene.fogEnabled && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE) {
			this._effect.setMatrix("view", scene.getViewMatrix());
			
			this._effect.setFloat4("vFogInfos", scene.fogMode, scene.fogStart, scene.fogEnd, scene.fogDensity);
			this._effect.setColor3("vFogColor", scene.fogColor);
		}
		
		this._lastTime += scene.getEngine().getDeltaTime();
		this._effect.setFloat("time", this._lastTime * this.speed / 1000);
		
		if (this.fogColor == null) {
			this.fogColor = Color3.Black();
		}
		this._effect.setColor3("fogColor", this.fogColor);
		
		super.bind(world, mesh);
	}

	public function getAnimatables():Array<IAnimatable> {
		var results:Array<IAnimatable> = [];
		
		if (this.diffuseTexture  != null && this.diffuseTexture.animations != null && this.diffuseTexture.animations.length > 0) {
			results.push(this.diffuseTexture);
		}
		
		if (this.noiseTexture != null && this.noiseTexture.animations != null && this.noiseTexture.animations.length > 0) {
			results.push(this.noiseTexture);
		}
		
		return results;
	}

	override public function dispose(forceDisposeEffect:Bool = false) {
		if (this.diffuseTexture != null) {
			this.diffuseTexture.dispose();
		}
		if (this.noiseTexture != null) {
			this.noiseTexture.dispose();
		}
		
		super.dispose(forceDisposeEffect);
	}

	override public function clone(name:String):LavaMaterial {
		var newMaterial:LavaMaterial = new LavaMaterial(name, this.getScene());
		
		// Base material
		this.copyTo(newMaterial);
		
		// Lava material
		if (this.diffuseTexture != null) {
			newMaterial.diffuseTexture = this.diffuseTexture.clone();
		}
		if (this.noiseTexture != null) {
			newMaterial.noiseTexture = this.noiseTexture.clone();
		}
		if (this.fogColor != null) {
			newMaterial.fogColor = this.fogColor.clone();
		}
		
		return newMaterial;
	}
	
}
