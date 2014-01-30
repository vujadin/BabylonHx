package com.gamestudiohx.babylonhx.materials;

import com.gamestudiohx.babylonhx.Engine;
import com.gamestudiohx.babylonhx.materials.textures.Texture;
import com.gamestudiohx.babylonhx.postprocess.PostProcess;
import com.gamestudiohx.babylonhx.tools.math.Color3;
import com.gamestudiohx.babylonhx.tools.math.Matrix;
import com.gamestudiohx.babylonhx.tools.math.Vector2;
import com.gamestudiohx.babylonhx.tools.math.Vector3;
import com.gamestudiohx.babylonhx.tools.Tools;
import openfl.Assets;
import openfl.gl.GL;
import openfl.utils.Float32Array;

import openfl.gl.GLProgram;
import openfl.gl.GLUniformLocation;


/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class Effect {
		
	public static var ShadersStore:Map<String, String> = [
		"blackAndWhitePixelShader" => "#ifdef GL_ES\nprecision mediump float;\n#endif\n\n// Samplers\nvarying vec2 vUV;\nuniform sampler2D textureSampler;\n\nvoid main(void) \n{\n	float luminance = dot(texture2D(textureSampler, vUV).rgb, vec3(0.3, 0.59, 0.11));\n	gl_FragColor = vec4(luminance, luminance, luminance, 1.0);\n}",
		"blurPixelShader" => "#ifdef GL_ES\nprecision mediump float;\n#endif\n\n// Samplers\nvarying vec2 vUV;\nuniform sampler2D textureSampler;\n\n// Parameters\nuniform vec2 screenSize;\nuniform vec2 direction;\nuniform float blurWidth;\n\nvoid main(void)\n{\n	float weights[7];\n	weights[0] = 0.05;\n	weights[1] = 0.1;\n	weights[2] = 0.2;\n	weights[3] = 0.3;\n	weights[4] = 0.2;\n	weights[5] = 0.1;\n	weights[6] = 0.05;\n\n	vec2 texelSize = vec2(1.0 / screenSize.x, 1.0 / screenSize.y);\n	vec2 texelStep = texelSize * direction * blurWidth;\n	vec2 start = vUV - 3.0 * texelStep;\n\n	vec4 baseColor = vec4(0., 0., 0., 0.);\n	vec2 texelOffset = vec2(0., 0.);\n\n	for (int i = 0; i < 7; i++)\n	{\n		baseColor += texture2D(textureSampler, start + texelOffset) * weights[i];\n		texelOffset += texelStep;\n	}\n\n	gl_FragColor = baseColor;\n}",
		"convolutionPixelShader" => "#ifdef GL_ES\nprecision mediump float;\n#endif\n\n// Samplers\nvarying vec2 vUV;\nuniform sampler2D textureSampler;\n\nuniform mat4 kernelMatrix;\n\nvoid main(void) \n{\n	vec3 baseColor = texture2D(textureSampler, vUV).rgb;\n	vec3 updatedColor = (kernelMatrix * vec4(baseColor, 1.0)).rgb;\n\n	gl_FragColor = vec4(updatedColor, 1.0);\n}",
		"defaultPixelShader" => "#ifdef GL_ES\nprecision mediump float;\n#endif\n\n#define MAP_EXPLICIT	0.\n#define MAP_SPHERICAL	1.\n#define MAP_PLANAR		2.\n#define MAP_CUBIC		3.\n#define MAP_PROJECTION	4.\n#define MAP_SKYBOX		5.\n\n// Constants\nuniform vec3 vEyePosition;\nuniform vec3 vAmbientColor;\nuniform vec4 vDiffuseColor;\nuniform vec4 vSpecularColor;\nuniform vec3 vEmissiveColor;\n\n// Input\nvarying vec3 vPositionW;\nvarying vec3 vNormalW;\n\n#ifdef VERTEXCOLOR\nvarying vec3 vColor;\n#endif\n\n// Lights\n#ifdef LIGHT0\nuniform vec4 vLightData0;\nuniform vec3 vLightDiffuse0;\nuniform vec3 vLightSpecular0;\n#ifdef SHADOW0\nvarying vec4 vPositionFromLight0;\nuniform sampler2D shadowSampler0;\n#endif\n#ifdef SPOTLIGHT0\nuniform vec4 vLightDirection0;\n#endif\n#ifdef HEMILIGHT0\nuniform vec3 vLightGround0;\n#endif\n#endif\n\n#ifdef LIGHT1\nuniform vec4 vLightData1;\nuniform vec3 vLightDiffuse1;\nuniform vec3 vLightSpecular1;\n#ifdef SHADOW1\nvarying vec4 vPositionFromLight1;\nuniform sampler2D shadowSampler1;\n#endif\n#ifdef SPOTLIGHT1\nuniform vec4 vLightDirection1;\n#endif\n#ifdef HEMILIGHT1\nuniform vec3 vLightGround1;\n#endif\n#endif\n\n#ifdef LIGHT2\nuniform vec4 vLightData2;\nuniform vec3 vLightDiffuse2;\nuniform vec3 vLightSpecular2;\n#ifdef SHADOW2\nvarying vec4 vPositionFromLight2;\nuniform sampler2D shadowSampler2;\n#endif\n#ifdef SPOTLIGHT2\nuniform vec4 vLightDirection2;\n#endif\n#ifdef HEMILIGHT2\nuniform vec3 vLightGround2;\n#endif\n#endif\n\n#ifdef LIGHT3\nuniform vec4 vLightData3;\nuniform vec3 vLightDiffuse3;\nuniform vec3 vLightSpecular3;\n#ifdef SHADOW3\nvarying vec4 vPositionFromLight3;\nuniform sampler2D shadowSampler3;\n#endif\n#ifdef SPOTLIGHT3\nuniform vec4 vLightDirection3;\n#endif\n#ifdef HEMILIGHT3\nuniform vec3 vLightGround3;\n#endif\n#endif\n\n// Samplers\n#ifdef DIFFUSE\nvarying vec2 vDiffuseUV;\nuniform sampler2D diffuseSampler;\nuniform vec2 vDiffuseInfos;\n#endif\n\n#ifdef AMBIENT\nvarying vec2 vAmbientUV;\nuniform sampler2D ambientSampler;\nuniform vec2 vAmbientInfos;\n#endif\n\n#ifdef OPACITY	\nvarying vec2 vOpacityUV;\nuniform sampler2D opacitySampler;\nuniform vec2 vOpacityInfos;\n#endif\n\n#ifdef EMISSIVE\nvarying vec2 vEmissiveUV;\nuniform vec2 vEmissiveInfos;\nuniform sampler2D emissiveSampler;\n#endif\n\n#ifdef SPECULAR\nvarying vec2 vSpecularUV;\nuniform vec2 vSpecularInfos;\nuniform sampler2D specularSampler;\n#endif\n\n// Reflection\n#ifdef REFLECTION\nvarying vec3 vPositionUVW;\nuniform samplerCube reflectionCubeSampler;\nuniform sampler2D reflection2DSampler;\nuniform vec3 vReflectionInfos;\nuniform mat4 reflectionMatrix;\nuniform mat4 view;\n\nvec3 computeReflectionCoords(float mode, vec4 worldPos, vec3 worldNormal)\n{\n	if (mode == MAP_SPHERICAL)\n	{\n		vec3 coords = vec3(view * vec4(worldNormal, 0.0));\n\n		return vec3(reflectionMatrix * vec4(coords, 1.0));\n	}\n	else if (mode == MAP_PLANAR)\n	{\n		vec3 viewDir = worldPos.xyz - vEyePosition;\n		vec3 coords = normalize(reflect(viewDir, worldNormal));\n\n		return vec3(reflectionMatrix * vec4(coords, 1));\n	}\n	else if (mode == MAP_CUBIC)\n	{\n		vec3 viewDir = worldPos.xyz - vEyePosition;\n		vec3 coords = reflect(viewDir, worldNormal);\n\n		return vec3(reflectionMatrix * vec4(coords, 0));\n	}\n	else if (mode == MAP_PROJECTION)\n	{\n		return vec3(reflectionMatrix * (view * worldPos));\n	}\n	else if (mode == MAP_SKYBOX)\n	{\n		return vPositionUVW;\n	}\n\n	return vec3(0, 0, 0);\n}\n#endif\n\n// Shadows\n#ifdef SHADOWS\n\nfloat unpack(vec4 color)\n{\n	const vec4 bitShift = vec4(1. / (255. * 255. * 255.), 1. / (255. * 255.), 1. / 255., 1.);\n	return dot(color, bitShift);\n}\n\nfloat unpackHalf(vec2 color)\n{\n	return color.x + (color.y / 255.0);\n}\n\nfloat computeShadow(vec4 vPositionFromLight, sampler2D shadowSampler)\n{\n	vec3 depth = vPositionFromLight.xyz / vPositionFromLight.w;\n	vec2 uv = 0.5 * depth.xy + vec2(0.5, 0.5);\n\n	if (uv.x < 0. || uv.x > 1.0 || uv.y < 0. || uv.y > 1.0)\n	{\n		return 1.0;\n	}\n\n	float shadow = unpack(texture2D(shadowSampler, uv));\n\n	if (depth.z > shadow)\n	{\n		return 0.;\n	}\n	return 1.;\n}\n\n// Thanks to http://devmaster.net/\nfloat ChebychevInequality(vec2 moments, float t)\n{\n	if (t <= moments.x)\n	{\n		return 1.0;\n	}\n\n	float variance = moments.y - (moments.x * moments.x);\n	variance = max(variance, 0.);\n\n	float d = t - moments.x;\n	return variance / (variance + d * d);\n}\n\nfloat computeShadowWithVSM(vec4 vPositionFromLight, sampler2D shadowSampler)\n{\n	vec3 depth = vPositionFromLight.xyz / vPositionFromLight.w;\n	vec2 uv = 0.5 * depth.xy + vec2(0.5, 0.5);\n\n	if (uv.x < 0. || uv.x > 1.0 || uv.y < 0. || uv.y > 1.0)\n	{\n		return 1.0;\n	}\n\n	vec4 texel = texture2D(shadowSampler, uv);\n\n	vec2 moments = vec2(unpackHalf(texel.xy), unpackHalf(texel.zw));\n	return clamp(1.3 - ChebychevInequality(moments, depth.z), 0., 1.0);\n}\n#endif\n\n// Bump\n#ifdef BUMP\n#extension GL_OES_standard_derivatives : enable\nvarying vec2 vBumpUV;\nuniform vec2 vBumpInfos;\nuniform sampler2D bumpSampler;\n\n// Thanks to http://www.thetenthplanet.de/archives/1180\nmat3 cotangent_frame(vec3 normal, vec3 p, vec2 uv)\n{\n	// get edge vectors of the pixel triangle\n	vec3 dp1 = dFdx(p);\n	vec3 dp2 = dFdy(p);\n	vec2 duv1 = dFdx(uv);\n	vec2 duv2 = dFdy(uv);\n\n	// solve the linear system\n	vec3 dp2perp = cross(dp2, normal);\n	vec3 dp1perp = cross(normal, dp1);\n	vec3 tangent = dp2perp * duv1.x + dp1perp * duv2.x;\n	vec3 binormal = dp2perp * duv1.y + dp1perp * duv2.y;\n\n	// construct a scale-invariant frame \n	float invmax = inversesqrt(max(dot(tangent, tangent), dot(binormal, binormal)));\n	return mat3(tangent * invmax, binormal * invmax, normal);\n}\n\nvec3 perturbNormal(vec3 viewDir)\n{\n	vec3 map = texture2D(bumpSampler, vBumpUV).xyz * vBumpInfos.y;\n	map = map * 255. / 127. - 128. / 127.;\n	mat3 TBN = cotangent_frame(vNormalW, -viewDir, vBumpUV);\n	return normalize(TBN * map);\n}\n#endif\n\n#ifdef CLIPPLANE\nvarying float fClipDistance;\n#endif\n\n// Fog\n#ifdef FOG\n\n#define FOGMODE_NONE    0.\n#define FOGMODE_EXP     1.\n#define FOGMODE_EXP2    2.\n#define FOGMODE_LINEAR  3.\n#define E 2.71828\n\nuniform vec4 vFogInfos;\nuniform vec3 vFogColor;\nvarying float fFogDistance;\n\nfloat CalcFogFactor()\n{\n	float fogCoeff = 1.0;\n	float fogStart = vFogInfos.y;\n	float fogEnd = vFogInfos.z;\n	float fogDensity = vFogInfos.w;\n\n	if (FOGMODE_LINEAR == vFogInfos.x)\n	{\n		fogCoeff = (fogEnd - fFogDistance) / (fogEnd - fogStart);\n	}\n	else if (FOGMODE_EXP == vFogInfos.x)\n	{\n		fogCoeff = 1.0 / pow(E, fFogDistance * fogDensity);\n	}\n	else if (FOGMODE_EXP2 == vFogInfos.x)\n	{\n		fogCoeff = 1.0 / pow(E, fFogDistance * fFogDistance * fogDensity * fogDensity);\n	}\n\n	return clamp(fogCoeff, 0.0, 1.0);\n}\n#endif\n\n// Light Computing\nstruct lightingInfo\n{\n	vec3 diffuse;\n	vec3 specular;\n};\n\nlightingInfo computeLighting(vec3 viewDirectionW, vec3 vNormal, vec4 lightData, vec3 diffuseColor, vec3 specularColor) {\n	lightingInfo result;\n\n	vec3 lightVectorW;\n	if (lightData.w == 0.)\n	{\n		lightVectorW = normalize(lightData.xyz - vPositionW);\n	}\n	else\n	{\n		lightVectorW = normalize(-lightData.xyz);\n	}\n\n	// diffuse\n	float ndl = max(0., dot(vNormal, lightVectorW));\n\n	// Specular\n	vec3 angleW = normalize(viewDirectionW + lightVectorW);\n	float specComp = max(0., dot(vNormal, angleW));\n	specComp = pow(specComp, vSpecularColor.a);\n\n	result.diffuse = ndl * diffuseColor;\n	result.specular = specComp * specularColor;\n\n	return result;\n}\n\nlightingInfo computeSpotLighting(vec3 viewDirectionW, vec3 vNormal, vec4 lightData, vec4 lightDirection, vec3 diffuseColor, vec3 specularColor) {\n	lightingInfo result;\n\n	vec3 lightVectorW = normalize(lightData.xyz - vPositionW);\n\n	// diffuse\n	float cosAngle = max(0., dot(-lightDirection.xyz, lightVectorW));\n	float spotAtten = 0.0;\n\n	if (cosAngle >= lightDirection.w)\n	{\n		cosAngle = max(0., pow(cosAngle, lightData.w));\n		spotAtten = max(0., (cosAngle - lightDirection.w) / (1. - cosAngle));\n\n		// Diffuse\n		float ndl = max(0., dot(vNormal, -lightDirection.xyz));\n\n		// Specular\n		vec3 angleW = normalize(viewDirectionW - lightDirection.xyz);\n		float specComp = max(0., dot(vNormal, angleW));\n		specComp = pow(specComp, vSpecularColor.a);\n\n		result.diffuse = ndl * spotAtten * diffuseColor;\n		result.specular = specComp * specularColor * spotAtten;\n\n		return result;\n	}\n\n	result.diffuse = vec3(0.);\n	result.specular = vec3(0.);\n\n	return result;\n}\n\nlightingInfo computeHemisphericLighting(vec3 viewDirectionW, vec3 vNormal, vec4 lightData, vec3 diffuseColor, vec3 specularColor, vec3 groundColor) {\n	lightingInfo result;\n\n	// Diffuse\n	float ndl = dot(vNormal, lightData.xyz) * 0.5 + 0.5;\n\n	// Specular\n	vec3 angleW = normalize(viewDirectionW + lightData.xyz);\n	float specComp = max(0., dot(vNormal, angleW));\n	specComp = pow(specComp, vSpecularColor.a);\n\n	result.diffuse = mix(groundColor, diffuseColor, ndl);\n	result.specular = specComp * specularColor;\n\n	return result;\n}\n\nvoid main(void) {\n	// Clip plane\n#ifdef CLIPPLANE\n	if (fClipDistance > 0.0)\n		discard;\n#endif\n\n	vec3 viewDirectionW = normalize(vEyePosition - vPositionW);\n\n	// Base color\n	vec4 baseColor = vec4(1., 1., 1., 1.);\n	vec3 diffuseColor = vDiffuseColor.rgb;\n\n#ifdef VERTEXCOLOR\n	diffuseColor *= vColor;\n#endif\n\n#ifdef DIFFUSE\n	baseColor = texture2D(diffuseSampler, vDiffuseUV);\n\n#ifdef ALPHATEST\n	if (baseColor.a < 0.4)\n		discard;\n#endif\n\n	baseColor.rgb *= vDiffuseInfos.y;\n#endif\n\n	// Bump\n	vec3 normalW = vNormalW;\n\n#ifdef BUMP\n	normalW = perturbNormal(viewDirectionW);\n#endif\n\n	// Ambient color\n	vec3 baseAmbientColor = vec3(1., 1., 1.);\n\n#ifdef AMBIENT\n	baseAmbientColor = texture2D(ambientSampler, vAmbientUV).rgb * vAmbientInfos.y;\n#endif\n\n	// Lighting\n	vec3 diffuseBase = vec3(0., 0., 0.);\n	vec3 specularBase = vec3(0., 0., 0.);\n	float shadow = 1.;\n\n#ifdef LIGHT0\n#ifdef SPOTLIGHT0\n	lightingInfo info = computeSpotLighting(viewDirectionW, normalW, vLightData0, vLightDirection0, vLightDiffuse0, vLightSpecular0);\n#endif\n#ifdef HEMILIGHT0\n	lightingInfo info = computeHemisphericLighting(viewDirectionW, normalW, vLightData0, vLightDiffuse0, vLightSpecular0, vLightGround0);\n#endif\n#ifdef POINTDIRLIGHT0\n	lightingInfo info = computeLighting(viewDirectionW, normalW, vLightData0, vLightDiffuse0, vLightSpecular0);\n#endif\n#ifdef SHADOW0\n#ifdef SHADOWVSM0\n	shadow = computeShadowWithVSM(vPositionFromLight0, shadowSampler0);\n#else\n	shadow = computeShadow(vPositionFromLight0, shadowSampler0);\n#endif\n#else\n	shadow = 1.;\n#endif\n	diffuseBase += info.diffuse * shadow;\n	specularBase += info.specular * shadow;\n#endif\n\n#ifdef LIGHT1\n#ifdef SPOTLIGHT1\n	info = computeSpotLighting(viewDirectionW, normalW, vLightData1, vLightDirection1, vLightDiffuse1, vLightSpecular1);\n#endif\n#ifdef HEMILIGHT1\n	info = computeHemisphericLighting(viewDirectionW, normalW, vLightData1, vLightDiffuse1, vLightSpecular1, vLightGround1);\n#endif\n#ifdef POINTDIRLIGHT1\n	info = computeLighting(viewDirectionW, normalW, vLightData1, vLightDiffuse1, vLightSpecular1);\n#endif\n#ifdef SHADOW1\n#ifdef SHADOWVSM1\n	shadow = computeShadowWithVSM(vPositionFromLight1, shadowSampler1);\n#else\n	shadow = computeShadow(vPositionFromLight1, shadowSampler1);\n#endif\n#else\n	shadow = 1.;\n#endif\n	diffuseBase += info.diffuse * shadow;\n	specularBase += info.specular * shadow;\n#endif\n\n#ifdef LIGHT2\n#ifdef SPOTLIGHT2\n	info = computeSpotLighting(viewDirectionW, normalW, vLightData2, vLightDirection2, vLightDiffuse2, vLightSpecular2);\n#endif\n#ifdef HEMILIGHT2\n	info = computeHemisphericLighting(viewDirectionW, normalW, vLightData2, vLightDiffuse2, vLightSpecular2, vLightGround2);\n#endif\n#ifdef POINTDIRLIGHT2\n	info = computeLighting(viewDirectionW, normalW, vLightData2, vLightDiffuse2, vLightSpecular2);\n#endif\n#ifdef SHADOW2\n#ifdef SHADOWVSM2\n	shadow = computeShadowWithVSM(vPositionFromLight2, shadowSampler2);\n#else\n	shadow = computeShadow(vPositionFromLight2, shadowSampler2);\n#endif	\n#else\n	shadow = 1.;\n#endif\n	diffuseBase += info.diffuse * shadow;\n	specularBase += info.specular * shadow;\n#endif\n\n#ifdef LIGHT3\n#ifdef SPOTLIGHT3\n	info = computeSpotLighting(viewDirectionW, normalW, vLightData3, vLightDirection3, vLightDiffuse3, vLightSpecular3);\n#endif\n#ifdef HEMILIGHT3\n	info = computeHemisphericLighting(viewDirectionW, normalW, vLightData3, vLightDiffuse3, vLightSpecular3, vLightGround3);\n#endif\n#ifdef POINTDIRLIGHT3\n	info = computeLighting(viewDirectionW, normalW, vLightData3, vLightDiffuse3, vLightSpecular3);\n#endif\n#ifdef SHADOW3\n#ifdef SHADOWVSM3\n	shadow = computeShadowWithVSM(vPositionFromLight3, shadowSampler3);\n#else\n	shadow = computeShadow(vPositionFromLight3, shadowSampler3);\n#endif	\n#else\n	shadow = 1.;\n#endif\n	diffuseBase += info.diffuse * shadow;\n	specularBase += info.specular * shadow;\n#endif\n\n	// Reflection\n	vec3 reflectionColor = vec3(0., 0., 0.);\n\n#ifdef REFLECTION\n	vec3 vReflectionUVW = computeReflectionCoords(vReflectionInfos.x, vec4(vPositionW, 1.0), normalW);\n\n	if (vReflectionInfos.z != 0.0)\n	{\n		reflectionColor = textureCube(reflectionCubeSampler, vReflectionUVW).rgb * vReflectionInfos.y;\n	}\n	else\n	{\n		vec2 coords = vReflectionUVW.xy;\n\n		if (vReflectionInfos.x == MAP_PROJECTION)\n		{\n			coords /= vReflectionUVW.z;\n		}\n\n		coords.y = 1.0 - coords.y;\n\n		reflectionColor = texture2D(reflection2DSampler, coords).rgb * vReflectionInfos.y;\n	}\n#endif\n\n	// Alpha\n	float alpha = vDiffuseColor.a;\n\n#ifdef OPACITY\n	vec4 opacityMap = texture2D(opacitySampler, vOpacityUV);\n	opacityMap.rgb = opacityMap.rgb * vec3(0.3, 0.59, 0.11) * opacityMap.a;\n	alpha *= (opacityMap.x + opacityMap.y + opacityMap.z)* vOpacityInfos.y;\n#endif\n\n	// Emissive\n	vec3 emissiveColor = vEmissiveColor;\n#ifdef EMISSIVE\n	emissiveColor += texture2D(emissiveSampler, vEmissiveUV).rgb * vEmissiveInfos.y;\n#endif\n\n	// Specular map\n	vec3 specularColor = vSpecularColor.rgb;\n#ifdef SPECULAR\n	specularColor = texture2D(specularSampler, vSpecularUV).rgb * vSpecularInfos.y;\n#endif\n\n	// Composition\n	vec3 finalDiffuse = clamp(diffuseBase * diffuseColor + emissiveColor + vAmbientColor, 0.0, 1.0) * baseColor.rgb;\n	vec3 finalSpecular = specularBase * specularColor;\n\n	vec4 color = vec4(finalDiffuse * baseAmbientColor + finalSpecular + reflectionColor, alpha);\n\n#ifdef FOG\n	float fog = CalcFogFactor();\n	color.rgb = fog * color.rgb + (1.0 - fog) * vFogColor;\n#endif\n\n	gl_FragColor = color;\n}",
		"defaultVertexShader" => "#ifdef GL_ES\nprecision mediump float;\n#endif\n\n// Attributes\nattribute vec3 position;\nattribute vec3 normal;\n#ifdef UV1\nattribute vec2 uv;\n#endif\n#ifdef UV2\nattribute vec2 uv2;\n#endif\n#ifdef VERTEXCOLOR\nattribute vec3 color;\n#endif\n#ifdef BONES\nattribute vec4 matricesIndices;\nattribute vec4 matricesWeights;\n#endif\n\n// Uniforms\nuniform mat4 world;\nuniform mat4 view;\nuniform mat4 viewProjection;\n\n#ifdef DIFFUSE\nvarying vec2 vDiffuseUV;\nuniform mat4 diffuseMatrix;\nuniform vec2 vDiffuseInfos;\n#endif\n\n#ifdef AMBIENT\nvarying vec2 vAmbientUV;\nuniform mat4 ambientMatrix;\nuniform vec2 vAmbientInfos;\n#endif\n\n#ifdef OPACITY\nvarying vec2 vOpacityUV;\nuniform mat4 opacityMatrix;\nuniform vec2 vOpacityInfos;\n#endif\n\n#ifdef EMISSIVE\nvarying vec2 vEmissiveUV;\nuniform vec2 vEmissiveInfos;\nuniform mat4 emissiveMatrix;\n#endif\n\n#ifdef SPECULAR\nvarying vec2 vSpecularUV;\nuniform vec2 vSpecularInfos;\nuniform mat4 specularMatrix;\n#endif\n\n#ifdef BUMP\nvarying vec2 vBumpUV;\nuniform vec2 vBumpInfos;\nuniform mat4 bumpMatrix;\n#endif\n\n#ifdef BONES\nuniform mat4 mBones[BonesPerMesh];\n#endif\n\n// Output\nvarying vec3 vPositionW;\nvarying vec3 vNormalW;\n\n#ifdef VERTEXCOLOR\nvarying vec3 vColor;\n#endif\n\n#ifdef CLIPPLANE\nuniform vec4 vClipPlane;\nvarying float fClipDistance;\n#endif\n\n#ifdef FOG\nvarying float fFogDistance;\n#endif\n\n#ifdef SHADOWS\n#ifdef LIGHT0\nuniform mat4 lightMatrix0;\nvarying vec4 vPositionFromLight0;\n#endif\n#ifdef LIGHT1\nuniform mat4 lightMatrix1;\nvarying vec4 vPositionFromLight1;\n#endif\n#ifdef LIGHT2\nuniform mat4 lightMatrix2;\nvarying vec4 vPositionFromLight2;\n#endif\n#ifdef LIGHT3\nuniform mat4 lightMatrix3;\nvarying vec4 vPositionFromLight3;\n#endif\n#endif\n\n#ifdef REFLECTION\nvarying vec3 vPositionUVW;\n#endif\n\nvoid main(void) {\n	mat4 finalWorld;\n\n#ifdef REFLECTION\n	vPositionUVW = position;\n#endif \n\n#ifdef BONES\n	mat4 m0 = mBones[int(matricesIndices.x)] * matricesWeights.x;\n	mat4 m1 = mBones[int(matricesIndices.y)] * matricesWeights.y;\n	mat4 m2 = mBones[int(matricesIndices.z)] * matricesWeights.z;\n\n#ifdef BONES4\n	mat4 m3 = mBones[int(matricesIndices.w)] * matricesWeights.w;\n	finalWorld = world * (m0 + m1 + m2 + m3);\n#else\n	finalWorld = world * (m0 + m1 + m2);\n#endif \n\n#else\n	finalWorld = world;\n#endif\n	gl_Position = viewProjection * finalWorld * vec4(position, 1.0);\n\n	vec4 worldPos = finalWorld * vec4(position, 1.0);\n	vPositionW = vec3(worldPos);\n	vNormalW = normalize(vec3(finalWorld * vec4(normal, 0.0)));\n\n	// Texture coordinates\n#ifndef UV1\n	vec2 uv = vec2(0., 0.);\n#endif\n#ifndef UV2\n	vec2 uv2 = vec2(0., 0.);\n#endif\n\n#ifdef DIFFUSE\n	if (vDiffuseInfos.x == 0.)\n	{\n		vDiffuseUV = vec2(diffuseMatrix * vec4(uv, 1.0, 0.0));\n	}\n	else\n	{\n		vDiffuseUV = vec2(diffuseMatrix * vec4(uv2, 1.0, 0.0));\n	}\n#endif\n\n#ifdef AMBIENT\n	if (vAmbientInfos.x == 0.)\n	{\n		vAmbientUV = vec2(ambientMatrix * vec4(uv, 1.0, 0.0));\n	}\n	else\n	{\n		vAmbientUV = vec2(ambientMatrix * vec4(uv2, 1.0, 0.0));\n	}\n#endif\n\n#ifdef OPACITY\n	if (vOpacityInfos.x == 0.)\n	{\n		vOpacityUV = vec2(opacityMatrix * vec4(uv, 1.0, 0.0));\n	}\n	else\n	{\n		vOpacityUV = vec2(opacityMatrix * vec4(uv2, 1.0, 0.0));\n	}\n#endif\n\n#ifdef EMISSIVE\n	if (vEmissiveInfos.x == 0.)\n	{\n		vEmissiveUV = vec2(emissiveMatrix * vec4(uv, 1.0, 0.0));\n	}\n	else\n	{\n		vEmissiveUV = vec2(emissiveMatrix * vec4(uv2, 1.0, 0.0));\n	}\n#endif\n\n#ifdef SPECULAR\n	if (vSpecularInfos.x == 0.)\n	{\n		vSpecularUV = vec2(specularMatrix * vec4(uv, 1.0, 0.0));\n	}\n	else\n	{\n		vSpecularUV = vec2(specularMatrix * vec4(uv2, 1.0, 0.0));\n	}\n#endif\n\n#ifdef BUMP\n	if (vBumpInfos.x == 0.)\n	{\n		vBumpUV = vec2(bumpMatrix * vec4(uv, 1.0, 0.0));\n	}\n	else\n	{\n		vBumpUV = vec2(bumpMatrix * vec4(uv2, 1.0, 0.0));\n	}\n#endif\n\n	// Clip plane\n#ifdef CLIPPLANE\n	fClipDistance = dot(worldPos, vClipPlane);\n#endif\n\n	// Fog\n#ifdef FOG\n	fFogDistance = (view * worldPos).z;\n#endif\n\n	// Shadows\n#ifdef SHADOWS\n#ifdef LIGHT0\n	vPositionFromLight0 = lightMatrix0 * vec4(position, 1.0);\n#endif\n#ifdef LIGHT1\n	vPositionFromLight1 = lightMatrix1 * vec4(position, 1.0);\n#endif\n#ifdef LIGHT2\n	vPositionFromLight2 = lightMatrix2 * vec4(position, 1.0);\n#endif\n#ifdef LIGHT3\n	vPositionFromLight3 = lightMatrix3 * vec4(position, 1.0);\n#endif\n#endif\n\n	// Vertex color\n#ifdef VERTEXCOLOR\n	vColor = color;\n#endif\n}",
		"fxaaPixelShader" => "#ifdef GL_ES\nprecision mediump float;\n#endif\n\n#define FXAA_REDUCE_MIN   (1.0/128.0)\n#define FXAA_REDUCE_MUL   (1.0/8.0)\n#define FXAA_SPAN_MAX     8.0\n\nvarying vec2 vUV;\nuniform sampler2D textureSampler;\nuniform vec2 texelSize;\n\nvoid main(){\n	vec2 localTexelSize = texelSize;\n	vec3 rgbNW = texture2D(textureSampler, (vUV + vec2(-1.0, -1.0) * localTexelSize)).xyz;\n	vec3 rgbNE = texture2D(textureSampler, (vUV + vec2(1.0, -1.0) * localTexelSize)).xyz;\n	vec3 rgbSW = texture2D(textureSampler, (vUV + vec2(-1.0, 1.0) * localTexelSize)).xyz;\n	vec3 rgbSE = texture2D(textureSampler, (vUV + vec2(1.0, 1.0) * localTexelSize)).xyz;\n	vec3 rgbM = texture2D(textureSampler, vUV ).xyz;\n	vec3 luma = vec3(0.299, 0.587, 0.114);\n	float lumaNW = dot(rgbNW, luma);\n	float lumaNE = dot(rgbNE, luma);\n	float lumaSW = dot(rgbSW, luma);\n	float lumaSE = dot(rgbSE, luma);\n	float lumaM = dot(rgbM, luma);\n	float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));\n	float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));\n\n	vec2 dir = vec2(-((lumaNW + lumaNE) - (lumaSW + lumaSE)), ((lumaNW + lumaSW) - (lumaNE + lumaSE)));\n\n	float dirReduce = max(\n		(lumaNW + lumaNE + lumaSW + lumaSE) * (0.25 * FXAA_REDUCE_MUL),\n		FXAA_REDUCE_MIN);\n\n	float rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);\n	dir = min(vec2(FXAA_SPAN_MAX, FXAA_SPAN_MAX),\n		max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX),\n		dir * rcpDirMin)) * localTexelSize;\n\n	vec3 rgbA = 0.5 * (\n		texture2D(textureSampler, vUV + dir * (1.0 / 3.0 - 0.5)).xyz +\n		texture2D(textureSampler, vUV + dir * (2.0 / 3.0 - 0.5)).xyz);\n\n	vec3 rgbB = rgbA * 0.5 + 0.25 * (\n		texture2D(textureSampler, vUV + dir *  -0.5).xyz +\n		texture2D(textureSampler, vUV + dir * 0.5).xyz);\n	float lumaB = dot(rgbB, luma);\n	if ((lumaB < lumaMin) || (lumaB > lumaMax)) {\n		gl_FragColor = vec4(rgbA, 1.0);\n	}\n	else {\n		gl_FragColor = vec4(rgbB, 1.0);\n	}\n}",
		"iedefaultPixelShader" => "#ifdef GL_ES\nprecision mediump float;\n#endif\n\n#define MAP_PROJECTION	4.\n\n// Constants\nuniform vec3 vEyePosition;\nuniform vec3 vAmbientColor;\nuniform vec4 vDiffuseColor;\nuniform vec4 vSpecularColor;\nuniform vec3 vEmissiveColor;\n\n// Input\nvarying vec3 vPositionW;\nvarying vec3 vNormalW;\n\n#ifdef VERTEXCOLOR\nvarying vec3 vColor;\n#endif\n\n// Lights\n#ifdef LIGHT0\nuniform vec4 vLightData0;\nuniform vec3 vLightDiffuse0;\nuniform vec3 vLightSpecular0;\n#ifdef SHADOW0\nvarying vec4 vPositionFromLight0;\nuniform sampler2D shadowSampler0;\n#endif\n#ifdef SPOTLIGHT0\nuniform vec4 vLightDirection0;\n#endif\n#ifdef HEMILIGHT0\nuniform vec3 vLightGround0;\n#endif\n#endif\n\n#ifdef LIGHT1\nuniform vec4 vLightData1;\nuniform vec3 vLightDiffuse1;\nuniform vec3 vLightSpecular1;\n#ifdef SHADOW1\nvarying vec4 vPositionFromLight1;\nuniform sampler2D shadowSampler1;\n#endif\n#ifdef SPOTLIGHT1\nuniform vec4 vLightDirection1;\n#endif\n#ifdef HEMILIGHT1\nuniform vec3 vLightGround1;\n#endif\n#endif\n\n#ifdef LIGHT2\nuniform vec4 vLightData2;\nuniform vec3 vLightDiffuse2;\nuniform vec3 vLightSpecular2;\n#ifdef SHADOW2\nvarying vec4 vPositionFromLight2;\nuniform sampler2D shadowSampler2;\n#endif\n#ifdef SPOTLIGHT2\nuniform vec4 vLightDirection2;\n#endif\n#ifdef HEMILIGHT2\nuniform vec3 vLightGround2;\n#endif\n#endif\n\n#ifdef LIGHT3\nuniform vec4 vLightData3;\nuniform vec3 vLightDiffuse3;\nuniform vec3 vLightSpecular3;\n#ifdef SHADOW3\nvarying vec4 vPositionFromLight3;\nuniform sampler2D shadowSampler3;\n#endif\n#ifdef SPOTLIGHT3\nuniform vec4 vLightDirection3;\n#endif\n#ifdef HEMILIGHT3\nuniform vec3 vLightGround3;\n#endif\n#endif\n\n// Samplers\n#ifdef DIFFUSE\nvarying vec2 vDiffuseUV;\nuniform sampler2D diffuseSampler;\nuniform vec2 vDiffuseInfos;\n#endif\n\n#ifdef AMBIENT\nvarying vec2 vAmbientUV;\nuniform sampler2D ambientSampler;\nuniform vec2 vAmbientInfos;\n#endif\n\n#ifdef OPACITY	\nvarying vec2 vOpacityUV;\nuniform sampler2D opacitySampler;\nuniform vec2 vOpacityInfos;\n#endif\n\n#ifdef REFLECTION\nvarying vec3 vReflectionUVW;\nuniform samplerCube reflectionCubeSampler;\nuniform sampler2D reflection2DSampler;\nuniform vec3 vReflectionInfos;\n#endif\n\n#ifdef EMISSIVE\nvarying vec2 vEmissiveUV;\nuniform vec2 vEmissiveInfos;\nuniform sampler2D emissiveSampler;\n#endif\n\n#ifdef SPECULAR\nvarying vec2 vSpecularUV;\nuniform vec2 vSpecularInfos;\nuniform sampler2D specularSampler;\n#endif\n\n// Shadows\n#ifdef SHADOWS\n\nfloat unpack(vec4 color)\n{\n	const vec4 bitShift = vec4(1. / (255. * 255. * 255.), 1. / (255. * 255.), 1. / 255., 1.);\n	return dot(color, bitShift);\n}\n\nfloat unpackHalf(vec2 color)\n{\n	return color.x + (color.y / 255.0);\n}\n\nfloat computeShadow(vec4 vPositionFromLight, sampler2D shadowSampler)\n{\n	vec3 depth = vPositionFromLight.xyz / vPositionFromLight.w;\n	vec2 uv = 0.5 * depth.xy + vec2(0.5, 0.5);\n\n	if (uv.x < 0. || uv.x > 1.0 || uv.y < 0. || uv.y > 1.0)\n	{\n		return 1.0;\n	}\n\n	float shadow = unpack(texture2D(shadowSampler, uv));\n\n	if (depth.z > shadow)\n	{\n		return 0.;\n	}\n	return 1.;\n}\n\n// Thanks to http://devmaster.net/\nfloat ChebychevInequality(vec2 moments, float t)\n{\n	if (t <= moments.x)\n	{\n		return 1.0;\n	}\n\n	float variance = moments.y - (moments.x * moments.x);\n	variance = max(variance, 0.);\n\n	float d = t - moments.x;\n	return variance / (variance + d * d);\n}\n\nfloat computeShadowWithVSM(vec4 vPositionFromLight, sampler2D shadowSampler)\n{\n	vec3 depth = vPositionFromLight.xyz / vPositionFromLight.w;\n	vec2 uv = 0.5 * depth.xy + vec2(0.5, 0.5);\n\n	if (uv.x < 0. || uv.x > 1.0 || uv.y < 0. || uv.y > 1.0)\n	{\n		return 1.0;\n	}\n\n	vec4 texel = texture2D(shadowSampler, uv);\n\n	vec2 moments = vec2(unpackHalf(texel.xy), unpackHalf(texel.zw));\n	return clamp(1.3 - ChebychevInequality(moments, depth.z), 0., 1.0);\n}\n#endif\n\n#ifdef CLIPPLANE\nvarying float fClipDistance;\n#endif\n\n// Fog\n#ifdef FOG\n\n#define FOGMODE_NONE    0.\n#define FOGMODE_EXP     1.\n#define FOGMODE_EXP2    2.\n#define FOGMODE_LINEAR  3.\n#define E 2.71828\n\nuniform vec4 vFogInfos;\nuniform vec3 vFogColor;\nvarying float fFogDistance;\n\nfloat CalcFogFactor()\n{\n	float fogCoeff = 1.0;\n	float fogStart = vFogInfos.y;\n	float fogEnd = vFogInfos.z;\n	float fogDensity = vFogInfos.w;\n\n	if (FOGMODE_LINEAR == vFogInfos.x)\n	{\n		fogCoeff = (fogEnd - fFogDistance) / (fogEnd - fogStart);\n	}\n	else if (FOGMODE_EXP == vFogInfos.x)\n	{\n		fogCoeff = 1.0 / pow(E, fFogDistance * fogDensity);\n	}\n	else if (FOGMODE_EXP2 == vFogInfos.x)\n	{\n		fogCoeff = 1.0 / pow(E, fFogDistance * fFogDistance * fogDensity * fogDensity);\n	}\n\n	return clamp(fogCoeff, 0.0, 1.0);\n}\n#endif\n\n// Light Computing\nmat3 computeLighting(vec3 viewDirectionW, vec3 vNormal, vec4 lightData, vec3 diffuseColor, vec3 specularColor) {\n	mat3 result;\n\n	vec3 lightVectorW;\n	if (lightData.w == 0.)\n	{\n		lightVectorW = normalize(lightData.xyz - vPositionW);\n	}\n	else\n	{\n		lightVectorW = normalize(-lightData.xyz);\n	}\n\n	// diffuse\n	float ndl = max(0., dot(vNormal, lightVectorW));\n\n	// Specular\n	vec3 angleW = normalize(viewDirectionW + lightVectorW);\n	float specComp = max(0., dot(vNormal, angleW));\n	specComp = max(0., pow(specComp, max(1.0, vSpecularColor.a)));\n\n	result[0] = ndl * diffuseColor;\n	result[1] = specComp * specularColor;\n	result[2] = vec3(0.);\n\n	return result;\n}\n\nmat3 computeSpotLighting(vec3 viewDirectionW, vec3 vNormal, vec4 lightData, vec4 lightDirection, vec3 diffuseColor, vec3 specularColor) {\n	mat3 result;\n\n	vec3 lightVectorW = normalize(lightData.xyz - vPositionW);\n\n	// diffuse\n	float cosAngle = max(0., dot(-lightDirection.xyz, lightVectorW));\n	float spotAtten = 0.0;\n\n	if (cosAngle >= lightDirection.w)\n	{\n		cosAngle = max(0., pow(cosAngle, lightData.w));\n		spotAtten = max(0., (cosAngle - lightDirection.w) / (1. - cosAngle));\n\n		// Diffuse\n		float ndl = max(0., dot(vNormal, -lightDirection.xyz));\n\n		// Specular\n		vec3 angleW = normalize(viewDirectionW - lightDirection.xyz);\n		float specComp = max(0., dot(vNormal, angleW));\n		specComp = pow(specComp, vSpecularColor.a);\n\n		result[0] = ndl * spotAtten * diffuseColor;\n		result[1] = specComp * specularColor * spotAtten;\n		result[2] = vec3(0.);\n\n		return result;\n	}\n\n	result[0] = vec3(0.);\n	result[1] = vec3(0.);\n	result[2] = vec3(0.);\n\n	return result;\n}\n\nmat3 computeHemisphericLighting(vec3 viewDirectionW, vec3 vNormal, vec4 lightData, vec3 diffuseColor, vec3 specularColor, vec3 groundColor) {\n	mat3 result;\n\n	// Diffuse\n	float ndl = dot(vNormal, lightData.xyz) * 0.5 + 0.5;\n\n	// Specular\n	vec3 angleW = normalize(viewDirectionW + lightData.xyz);\n	float specComp = max(0., dot(vNormal, angleW));\n	specComp = pow(specComp, vSpecularColor.a);\n\n	result[0] = mix(groundColor, diffuseColor, ndl);\n	result[1] = specComp * specularColor;\n	result[2] = vec3(0.);\n\n	return result;\n}\n\nvoid main(void) {\n	// Clip plane\n#ifdef CLIPPLANE\n	if (fClipDistance > 0.0)\n		discard;\n#endif\n\n	vec3 viewDirectionW = normalize(vEyePosition - vPositionW);\n\n	// Base color\n	vec4 baseColor = vec4(1., 1., 1., 1.);\n	vec3 diffuseColor = vDiffuseColor.rgb;\n\n#ifdef VERTEXCOLOR\n	diffuseColor *= vColor;\n#endif\n\n#ifdef DIFFUSE\n	baseColor = texture2D(diffuseSampler, vDiffuseUV);\n\n#ifdef ALPHATEST\n	if (baseColor.a < 0.4)\n		discard;\n#endif\n\n	baseColor.rgb *= vDiffuseInfos.y;\n#endif\n\n	// Bump\n	vec3 normalW = vNormalW;\n\n	// Ambient color\n	vec3 baseAmbientColor = vec3(1., 1., 1.);\n\n#ifdef AMBIENT\n	baseAmbientColor = texture2D(ambientSampler, vAmbientUV).rgb * vAmbientInfos.y;\n#endif\n\n	// Lighting\n	vec3 diffuseBase = vec3(0., 0., 0.);\n	vec3 specularBase = vec3(0., 0., 0.);\n	float shadow = 1.;\n\n#ifdef LIGHT0\n#ifdef SPOTLIGHT0\n	mat3 info = computeSpotLighting(viewDirectionW, normalW, vLightData0, vLightDirection0, vLightDiffuse0, vLightSpecular0);\n#endif\n#ifdef HEMILIGHT0\n	mat3 info = computeHemisphericLighting(viewDirectionW, normalW, vLightData0, vLightDiffuse0, vLightSpecular0, vLightGround0);\n#endif\n#ifdef POINTDIRLIGHT0\n	mat3 info = computeLighting(viewDirectionW, normalW, vLightData0, vLightDiffuse0, vLightSpecular0);\n#endif\n#ifdef SHADOW0\n#ifdef SHADOWVSM0\n	shadow = computeShadowWithVSM(vPositionFromLight0, shadowSampler0);\n#else\n	shadow = computeShadow(vPositionFromLight0, shadowSampler0);\n#endif\n#else\n	shadow = 1.;\n#endif\n	diffuseBase += info[0] * shadow;\n	specularBase += info[1] * shadow;\n#endif\n\n#ifdef LIGHT1\n#ifdef SPOTLIGHT1\n	info = computeSpotLighting(viewDirectionW, normalW, vLightData1, vLightDirection1, vLightDiffuse1, vLightSpecular1);\n#endif\n#ifdef HEMILIGHT1\n	info = computeHemisphericLighting(viewDirectionW, normalW, vLightData1, vLightDiffuse1, vLightSpecular1, vLightGround1);\n#endif\n#ifdef POINTDIRLIGHT1\n	info = computeLighting(viewDirectionW, normalW, vLightData1, vLightDiffuse1, vLightSpecular1);\n#endif\n#ifdef SHADOW1\n#ifdef SHADOWVSM1\n	shadow = computeShadowWithVSM(vPositionFromLight1, shadowSampler1);\n#else\n	shadow = computeShadow(vPositionFromLight1, shadowSampler1);\n#endif\n#else\n	shadow = 1.;\n#endif\n	diffuseBase += info[0] * shadow;\n	specularBase += info[1] * shadow;\n#endif\n\n#ifdef LIGHT2\n#ifdef SPOTLIGHT2\n	info = computeSpotLighting(viewDirectionW, normalW, vLightData2, vLightDirection2, vLightDiffuse2, vLightSpecular2);\n#endif\n#ifdef HEMILIGHT2\n	info = computeHemisphericLighting(viewDirectionW, normalW, vLightData2, vLightDiffuse2, vLightSpecular2, vLightGround2);\n#endif\n#ifdef POINTDIRLIGHT2\n	info = computeLighting(viewDirectionW, normalW, vLightData2, vLightDiffuse2, vLightSpecular2);\n#endif\n#ifdef SHADOW2\n#ifdef SHADOWVSM2\n	shadow = computeShadowWithVSM(vPositionFromLight2, shadowSampler2);\n#else\n	shadow = computeShadow(vPositionFromLight2, shadowSampler2);\n#endif	\n#else\n	shadow = 1.;\n#endif\n	diffuseBase += info[0] * shadow;\n	specularBase += info[1] * shadow;\n#endif\n\n#ifdef LIGHT3\n#ifdef SPOTLIGHT3\n	info = computeSpotLighting(viewDirectionW, normalW, vLightData3, vLightDirection3, vLightDiffuse3, vLightSpecular3);\n#endif\n#ifdef HEMILIGHT3\n	info = computeHemisphericLighting(viewDirectionW, normalW, vLightData3, vLightDiffuse3, vLightSpecular3, vLightGround3);\n#endif\n#ifdef POINTDIRLIGHT3\n	info = computeLighting(viewDirectionW, normalW, vLightData3, vLightDiffuse3, vLightSpecular3);\n#endif\n#ifdef SHADOW3\n#ifdef SHADOWVSM3\n	shadow = computeShadowWithVSM(vPositionFromLight3, shadowSampler3);\n#else\n	shadow = computeShadow(vPositionFromLight3, shadowSampler3);\n#endif	\n#else\n	shadow = 1.;\n#endif\n	diffuseBase += info[0] * shadow;\n	specularBase += info[1] * shadow;\n#endif\n\n	// Reflection\n	vec3 reflectionColor = vec3(0., 0., 0.);\n\n#ifdef REFLECTION\n	if (vReflectionInfos.z != 0.0)\n	{\n		reflectionColor = textureCube(reflectionCubeSampler, vReflectionUVW).rgb * vReflectionInfos.y;\n	}\n	else\n	{\n		vec2 coords = vReflectionUVW.xy;\n\n		if (vReflectionInfos.x == MAP_PROJECTION)\n		{\n			coords /= vReflectionUVW.z;\n		}\n\n		coords.y = 1.0 - coords.y;\n\n		reflectionColor = texture2D(reflection2DSampler, coords).rgb * vReflectionInfos.y;\n	}\n#endif\n\n	// Alpha\n	float alpha = vDiffuseColor.a;\n\n#ifdef OPACITY\n	vec4 opacityMap = texture2D(opacitySampler, vOpacityUV);\n	opacityMap.rgb = opacityMap.rgb * vec3(0.3, 0.59, 0.11) * opacityMap.a;\n	alpha *= (opacityMap.x + opacityMap.y + opacityMap.z)* vOpacityInfos.y;\n#endif\n\n	// Emissive\n	vec3 emissiveColor = vEmissiveColor;\n#ifdef EMISSIVE\n	emissiveColor += texture2D(emissiveSampler, vEmissiveUV).rgb * vEmissiveInfos.y;\n#endif\n\n	// Specular map\n	vec3 specularColor = vSpecularColor.rgb;\n#ifdef SPECULAR\n	specularColor = texture2D(specularSampler, vSpecularUV).rgb * vSpecularInfos.y;\n#endif\n\n	// Composition\n	vec3 finalDiffuse = clamp(diffuseBase * diffuseColor + emissiveColor + vAmbientColor, 0.0, 1.0) * baseColor.rgb;\n	vec3 finalSpecular = specularBase * specularColor;\n\n	vec4 color = vec4(finalDiffuse * baseAmbientColor + finalSpecular + reflectionColor, alpha);\n\n#ifdef FOG\n	float fog = CalcFogFactor();\n	color.rgb = fog * color.rgb + (1.0 - fog) * vFogColor;\n#endif\n\n	gl_FragColor = color;\n}",
		"iedefaultVertexShader" => "#ifdef GL_ES\nprecision mediump float;\n#endif\n\n#define MAP_EXPLICIT	0.\n#define MAP_SPHERICAL	1.\n#define MAP_PLANAR		2.\n#define MAP_CUBIC		3.\n#define MAP_PROJECTION	4.\n#define MAP_SKYBOX		5.\n\n// Attributes\nattribute vec3 position;\nattribute vec3 normal;\n#ifdef UV1\nattribute vec2 uv;\n#endif\n#ifdef UV2\nattribute vec2 uv2;\n#endif\n#ifdef VERTEXCOLOR\nattribute vec3 color;\n#endif\n#ifdef BONES\nattribute vec4 matricesIndices;\nattribute vec4 matricesWeights;\n#endif\n\n// Uniforms\nuniform mat4 world;\nuniform mat4 view;\nuniform mat4 viewProjection;\n\n#ifdef DIFFUSE\nvarying vec2 vDiffuseUV;\nuniform mat4 diffuseMatrix;\nuniform vec2 vDiffuseInfos;\n#endif\n\n#ifdef AMBIENT\nvarying vec2 vAmbientUV;\nuniform mat4 ambientMatrix;\nuniform vec2 vAmbientInfos;\n#endif\n\n#ifdef OPACITY\nvarying vec2 vOpacityUV;\nuniform mat4 opacityMatrix;\nuniform vec2 vOpacityInfos;\n#endif\n\n#ifdef REFLECTION\nuniform vec3 vEyePosition;\nvarying vec3 vReflectionUVW;\nuniform vec3 vReflectionInfos;\nuniform mat4 reflectionMatrix;\n#endif\n\n#ifdef EMISSIVE\nvarying vec2 vEmissiveUV;\nuniform vec2 vEmissiveInfos;\nuniform mat4 emissiveMatrix;\n#endif\n\n#ifdef SPECULAR\nvarying vec2 vSpecularUV;\nuniform vec2 vSpecularInfos;\nuniform mat4 specularMatrix;\n#endif\n\n#ifdef BUMP\nvarying vec2 vBumpUV;\nuniform vec2 vBumpInfos;\nuniform mat4 bumpMatrix;\n#endif\n\n#ifdef BONES\nuniform mat4 mBones[BonesPerMesh];\n#endif\n\n// Output\nvarying vec3 vPositionW;\nvarying vec3 vNormalW;\n\n#ifdef VERTEXCOLOR\nvarying vec3 vColor;\n#endif\n\n#ifdef CLIPPLANE\nuniform vec4 vClipPlane;\nvarying float fClipDistance;\n#endif\n\n#ifdef FOG\nvarying float fFogDistance;\n#endif\n\n#ifdef SHADOWS\n#ifdef LIGHT0\nuniform mat4 lightMatrix0;\nvarying vec4 vPositionFromLight0;\n#endif\n#ifdef LIGHT1\nuniform mat4 lightMatrix1;\nvarying vec4 vPositionFromLight1;\n#endif\n#ifdef LIGHT2\nuniform mat4 lightMatrix2;\nvarying vec4 vPositionFromLight2;\n#endif\n#ifdef LIGHT3\nuniform mat4 lightMatrix3;\nvarying vec4 vPositionFromLight3;\n#endif\n#endif\n\n#ifdef REFLECTION\nvec3 computeReflectionCoords(float mode, vec4 worldPos, vec3 worldNormal)\n{\n	if (mode == MAP_SPHERICAL)\n	{\n		vec3 coords = vec3(view * vec4(worldNormal, 0.0));\n\n		return vec3(reflectionMatrix * vec4(coords, 1.0));\n	}\n	else if (mode == MAP_PLANAR)\n	{\n		vec3 viewDir = worldPos.xyz - vEyePosition;\n		vec3 coords = normalize(reflect(viewDir, worldNormal));\n\n		return vec3(reflectionMatrix * vec4(coords, 1));\n	}\n	else if (mode == MAP_CUBIC)\n	{\n		vec3 viewDir = worldPos.xyz - vEyePosition;\n		vec3 coords = reflect(viewDir, worldNormal);\n\n		return vec3(reflectionMatrix * vec4(coords, 0));\n	}\n	else if (mode == MAP_PROJECTION)\n	{\n		return vec3(reflectionMatrix * (view * worldPos));\n	}\n	else if (mode == MAP_SKYBOX)\n	{\n		return position;\n	}\n\n	return vec3(0, 0, 0);\n}\n#endif\n\nvoid main(void) {\n	mat4 finalWorld;\n\n#ifdef BONES\n	mat4 m0 = mBones[int(matricesIndices.x)] * matricesWeights.x;\n	mat4 m1 = mBones[int(matricesIndices.y)] * matricesWeights.y;\n	mat4 m2 = mBones[int(matricesIndices.z)] * matricesWeights.z;\n\n#ifdef BONES4\n	mat4 m3 = mBones[int(matricesIndices.w)] * matricesWeights.w;\n	finalWorld = world * (m0 + m1 + m2 + m3);\n#else\n	finalWorld = world * (m0 + m1 + m2);\n#endif \n\n#else\n	finalWorld = world;\n#endif\n\n	gl_Position = viewProjection * finalWorld * vec4(position, 1.0);\n\n	vec4 worldPos = finalWorld * vec4(position, 1.0);\n	vPositionW = vec3(worldPos);\n	vNormalW = normalize(vec3(finalWorld * vec4(normal, 0.0)));\n\n	// Texture coordinates\n#ifndef UV1\n	vec2 uv = vec2(0., 0.);\n#endif\n#ifndef UV2\n	vec2 uv2 = vec2(0., 0.);\n#endif\n\n#ifdef DIFFUSE\n	if (vDiffuseInfos.x == 0.)\n	{\n		vDiffuseUV = vec2(diffuseMatrix * vec4(uv, 1.0, 0.0));\n	}\n	else\n	{\n		vDiffuseUV = vec2(diffuseMatrix * vec4(uv2, 1.0, 0.0));\n	}\n#endif\n\n#ifdef AMBIENT\n	if (vAmbientInfos.x == 0.)\n	{\n		vAmbientUV = vec2(ambientMatrix * vec4(uv, 1.0, 0.0));\n	}\n	else\n	{\n		vAmbientUV = vec2(ambientMatrix * vec4(uv2, 1.0, 0.0));\n	}\n#endif\n\n#ifdef OPACITY\n	if (vOpacityInfos.x == 0.)\n	{\n		vOpacityUV = vec2(opacityMatrix * vec4(uv, 1.0, 0.0));\n	}\n	else\n	{\n		vOpacityUV = vec2(opacityMatrix * vec4(uv2, 1.0, 0.0));\n	}\n#endif\n\n#ifdef REFLECTION\n	vReflectionUVW = computeReflectionCoords(vReflectionInfos.x, vec4(vPositionW, 1.0), vNormalW);\n#endif\n\n#ifdef EMISSIVE\n	if (vEmissiveInfos.x == 0.)\n	{\n		vEmissiveUV = vec2(emissiveMatrix * vec4(uv, 1.0, 0.0));\n	}\n	else\n	{\n		vEmissiveUV = vec2(emissiveMatrix * vec4(uv2, 1.0, 0.0));\n	}\n#endif\n\n#ifdef SPECULAR\n	if (vSpecularInfos.x == 0.)\n	{\n		vSpecularUV = vec2(specularMatrix * vec4(uv, 1.0, 0.0));\n	}\n	else\n	{\n		vSpecularUV = vec2(specularMatrix * vec4(uv2, 1.0, 0.0));\n	}\n#endif\n\n#ifdef BUMP\n	if (vBumpInfos.x == 0.)\n	{\n		vBumpUV = vec2(bumpMatrix * vec4(uv, 1.0, 0.0));\n	}\n	else\n	{\n		vBumpUV = vec2(bumpMatrix * vec4(uv2, 1.0, 0.0));\n	}\n#endif\n\n	// Clip plane\n#ifdef CLIPPLANE\n	fClipDistance = dot(worldPos, vClipPlane);\n#endif\n\n	// Fog\n#ifdef FOG\n	fFogDistance = (view * worldPos).z;\n#endif\n\n	// Shadows\n#ifdef SHADOWS\n#ifdef LIGHT0\n	vPositionFromLight0 = lightMatrix0 * vec4(position, 1.0);\n#endif\n#ifdef LIGHT1\n	vPositionFromLight1 = lightMatrix1 * vec4(position, 1.0);\n#endif\n#ifdef LIGHT2\n	vPositionFromLight2 = lightMatrix2 * vec4(position, 1.0);\n#endif\n#ifdef LIGHT3\n	vPositionFromLight3 = lightMatrix3 * vec4(position, 1.0);\n#endif\n#endif\n\n	// Vertex color\n#ifdef VERTEXCOLOR\n	vColor = color;\n#endif\n}",
		"layerPixelShader" => "#ifdef GL_ES\nprecision mediump float;\n#endif\n\n// Samplers\nvarying vec2 vUV;\nuniform sampler2D textureSampler;\n\n// Color\nuniform vec4 color;\n\nvoid main(void) {\n	vec4 baseColor = texture2D(textureSampler, vUV);\n\n	gl_FragColor = baseColor * color;\n}",
		"layerVertexShader" => "#ifdef GL_ES\nprecision mediump float;\n#endif\n\n// Attributes\nattribute vec2 position;\n\n// Uniforms\nuniform mat4 textureMatrix;\n\n// Output\nvarying vec2 vUV;\n\nconst vec2 madd = vec2(0.5, 0.5);\n\nvoid main(void) {	\n\n	vUV = vec2(textureMatrix * vec4(position * madd + madd, 1.0, 0.0));\n	gl_Position = vec4(position, 0.0, 1.0);\n}",
		"lensFlarePixelShader" => "#ifdef GL_ES\nprecision mediump float;\n#endif\n\n// Samplers\nvarying vec2 vUV;\nuniform sampler2D textureSampler;\n\n// Color\nuniform vec4 color;\n\nvoid main(void) {\n	vec4 baseColor = texture2D(textureSampler, vUV);\n\n	gl_FragColor = baseColor * color;\n}",
		"lensFlareVertexShader" => "#ifdef GL_ES\nprecision mediump float;\n#endif\n\n// Attributes\nattribute vec2 position;\n\n// Uniforms\nuniform mat4 viewportMatrix;\n\n// Output\nvarying vec2 vUV;\n\nconst vec2 madd = vec2(0.5, 0.5);\n\nvoid main(void) {	\n\n	vUV = position * madd + madd;\n	gl_Position = viewportMatrix * vec4(position, 0.0, 1.0);\n}",
		"particlesPixelShader" => "#ifdef GL_ES\nprecision mediump float;\n#endif\n\n// Samplers\nvarying vec2 vUV;\nvarying vec4 vColor;\nuniform vec4 textureMask;\nuniform sampler2D diffuseSampler;\n\n#ifdef CLIPPLANE\nvarying float fClipDistance;\n#endif\n\nvoid main(void) {\n#ifdef CLIPPLANE\n	if (fClipDistance > 0.0)\n		discard;\n#endif\n	vec4 baseColor = texture2D(diffuseSampler, vUV);\n\n	gl_FragColor = (baseColor * textureMask + (vec4(1., 1., 1., 1.) - textureMask)) * vColor;\n}",
		"particlesVertexShader" => "#ifdef GL_ES\nprecision mediump float;\n#endif\n\n// Attributes\nattribute vec3 position;\nattribute vec4 color;\nattribute vec4 options;\n\n// Uniforms\nuniform mat4 view;\nuniform mat4 projection;\n\n// Output\nvarying vec2 vUV;\nvarying vec4 vColor;\n\n#ifdef CLIPPLANE\nuniform vec4 vClipPlane;\nuniform mat4 invView;\nvarying float fClipDistance;\n#endif\n\nvoid main(void) {	\n	vec3 viewPos = (view * vec4(position, 1.0)).xyz; \n	vec3 cornerPos;\n	float size = options.y;\n	float angle = options.x;\n	vec2 offset = options.zw;\n\n	cornerPos = vec3(offset.x - 0.5, offset.y  - 0.5, 0.) * size;\n\n	// Rotate\n	vec3 rotatedCorner;\n	rotatedCorner.x = cornerPos.x * cos(angle) - cornerPos.y * sin(angle);\n	rotatedCorner.y = cornerPos.x * sin(angle) + cornerPos.y * cos(angle);\n	rotatedCorner.z = 0.;\n\n	// Position\n	viewPos += rotatedCorner;\n	gl_Position = projection * vec4(viewPos, 1.0);   \n	\n	vColor = color;\n	vUV = offset;\n\n	// Clip plane\n#ifdef CLIPPLANE\n	vec4 worldPos = invView * vec4(viewPos, 1.0);\n	fClipDistance = dot(worldPos, vClipPlane);\n#endif\n}",
		"passPixelShader" => "#ifdef GL_ES\nprecision mediump float;\n#endif\n\n// Samplers\nvarying vec2 vUV;\nuniform sampler2D textureSampler;\n\nvoid main(void) \n{\n	gl_FragColor = texture2D(textureSampler, vUV);\n}",
		"postprocessVertexShader" => "#ifdef GL_ES\nprecision mediump float;\n#endif\n\n// Attributes\nattribute vec2 position;\n\n// Output\nvarying vec2 vUV;\n\nconst vec2 madd = vec2(0.5, 0.5);\n\nvoid main(void) {	\n\n	vUV = position * madd + madd;\n	gl_Position = vec4(position, 0.0, 1.0);\n}",
		"refractionPixelShader" => "#ifdef GL_ES\nprecision mediump float;\n#endif\n\n// Samplers\nvarying vec2 vUV;\nuniform sampler2D textureSampler;\nuniform sampler2D refractionSampler;\n\n// Parameters\nuniform vec3 baseColor;\nuniform float depth;\nuniform float colorLevel;\n\nvoid main() {\n	float ref = 1.0 - texture2D(refractionSampler, vUV).r;\n\n	vec2 uv = vUV - vec2(0.5);\n	vec2 offset = uv * depth * ref;\n	vec3 sourceColor = texture2D(textureSampler, vUV - offset).rgb;\n\n	gl_FragColor = vec4(sourceColor + sourceColor * ref * colorLevel, 1.0);\n}",
		"shadowMapPixelShader" => "#ifdef GL_ES\nprecision mediump float;\n#endif\n\nvec4 pack(float depth)\n{\n	const vec4 bitOffset = vec4(255. * 255. * 255., 255. * 255., 255., 1.);\n	const vec4 bitMask = vec4(0., 1. / 255., 1. / 255., 1. / 255.);\n	\n	vec4 comp = fract(depth * bitOffset);\n	comp -= comp.xxyz * bitMask;\n	\n	return comp;\n}\n\n// Thanks to http://devmaster.net/\nvec2 packHalf(float depth) \n{ \n	const vec2 bitOffset = vec2(1.0 / 255., 0.);\n	vec2 color = vec2(depth, fract(depth * 255.));\n\n	return color - (color.yy * bitOffset);\n}\n\n#ifndef VSM\nvarying vec4 vPosition;\n#endif\n\nvoid main(void)\n{\n#ifdef VSM\n	float moment1 = gl_FragCoord.z / gl_FragCoord.w;\n	float moment2 = moment1 * moment1;\n	gl_FragColor = vec4(packHalf(moment1), packHalf(moment2));\n#else\n	gl_FragColor = pack(vPosition.z / vPosition.w);\n#endif\n}",
		"shadowMapVertexShader" => "#ifdef GL_ES\nprecision mediump float;\n#endif\n\n// Attribute\nattribute vec3 position;\n#ifdef BONES\nattribute vec4 matricesIndices;\nattribute vec4 matricesWeights;\n#endif\n\n// Uniform\n#ifdef BONES\nuniform mat4 world;\nuniform mat4 mBones[BonesPerMesh];\nuniform mat4 viewProjection;\n#else\nuniform mat4 worldViewProjection;\n#endif\n\n#ifndef VSM\nvarying vec4 vPosition;\n#endif\n\nvoid main(void)\n{\n#ifdef BONES\n	mat4 m0 = mBones[int(matricesIndices.x)] * matricesWeights.x;\n	mat4 m1 = mBones[int(matricesIndices.y)] * matricesWeights.y;\n	mat4 m2 = mBones[int(matricesIndices.z)] * matricesWeights.z;\n	mat4 m3 = mBones[int(matricesIndices.w)] * matricesWeights.w;\n	mat4 finalWorld = world * (m0 + m1 + m2 + m3);\n	gl_Position = viewProjection * finalWorld * vec4(position, 1.0);\n#else\n#ifndef VSM\n	vPosition = worldViewProjection * vec4(position, 1.0);\n#endif\n	gl_Position = worldViewProjection * vec4(position, 1.0);\n#endif\n}",
		"spritesPixelShader" => "#ifdef GL_ES\nprecision mediump float;\n#endif\n\nuniform bool alphaTest;\n\nvarying vec4 vColor;\n\n// Samplers\nvarying vec2 vUV;\nuniform sampler2D diffuseSampler;\n\n// Fog\n#ifdef FOG\n\n#define FOGMODE_NONE    0.\n#define FOGMODE_EXP     1.\n#define FOGMODE_EXP2    2.\n#define FOGMODE_LINEAR  3.\n#define E 2.71828\n\nuniform vec4 vFogInfos;\nuniform vec3 vFogColor;\nvarying float fFogDistance;\n\nfloat CalcFogFactor()\n{\n	float fogCoeff = 1.0;\n	float fogStart = vFogInfos.y;\n	float fogEnd = vFogInfos.z;\n	float fogDensity = vFogInfos.w;\n\n	if (FOGMODE_LINEAR == vFogInfos.x)\n	{\n		fogCoeff = (fogEnd - fFogDistance) / (fogEnd - fogStart);\n	}\n	else if (FOGMODE_EXP == vFogInfos.x)\n	{\n		fogCoeff = 1.0 / pow(E, fFogDistance * fogDensity);\n	}\n	else if (FOGMODE_EXP2 == vFogInfos.x)\n	{\n		fogCoeff = 1.0 / pow(E, fFogDistance * fFogDistance * fogDensity * fogDensity);\n	}\n\n	return min(1., max(0., fogCoeff));\n}\n#endif\n\n\nvoid main(void) {\n	vec4 baseColor = texture2D(diffuseSampler, vUV);\n\n	if (alphaTest) \n	{\n		if (baseColor.a < 0.95)\n			discard;\n	}\n\n	baseColor *= vColor;\n\n#ifdef FOG\n	float fog = CalcFogFactor();\n	baseColor.rgb = fog * baseColor.rgb + (1.0 - fog) * vFogColor;\n#endif\n\n	gl_FragColor = baseColor;\n}",
		"spritesVertexShader" => "#ifdef GL_ES\nprecision mediump float;\n#endif\n\n// Attributes\nattribute vec3 position;\nattribute vec4 options;\nattribute vec4 cellInfo;\nattribute vec4 color;\n\n// Uniforms\nuniform vec2 textureInfos;\nuniform mat4 view;\nuniform mat4 projection;\n\n// Output\nvarying vec2 vUV;\nvarying vec4 vColor;\n\n#ifdef FOG\nvarying float fFogDistance;\n#endif\n\nvoid main(void) {	\n	vec3 viewPos = (view * vec4(position, 1.0)).xyz; \n	vec3 cornerPos;\n	\n	float angle = options.x;\n	float size = options.y;\n	vec2 offset = options.zw;\n	vec2 uvScale = textureInfos.xy;\n\n	cornerPos = vec3(offset.x - 0.5, offset.y  - 0.5, 0.) * size;\n\n	// Rotate\n	vec3 rotatedCorner;\n	rotatedCorner.x = cornerPos.x * cos(angle) - cornerPos.y * sin(angle);\n	rotatedCorner.y = cornerPos.x * sin(angle) + cornerPos.y * cos(angle);\n	rotatedCorner.z = 0.;\n\n	// Position\n	viewPos += rotatedCorner;\n	gl_Position = projection * vec4(viewPos, 1.0);   \n\n	// Color\n	vColor = color;\n	\n	// Texture\n	vec2 uvOffset = vec2(abs(offset.x - cellInfo.x), 1.0 - abs(offset.y - cellInfo.y));\n\n	vUV = (uvOffset + cellInfo.zw) * uvScale;\n\n	// Fog\n#ifdef FOG\n	fFogDistance = viewPos.z;\n#endif\n}"
	];
	
	public var name:Dynamic;
	public var _engine:Engine;
	public var defines:String;
	public var _uniforms:Array<GLUniformLocation>;
	public var _uniformsNames:Array<String>;
	public var _samplers:Array<String>;
	public var _isReady:Bool;
	public var _compilationError:String;
	public var _attributes:Array<Int>;
	public var _attributesNames:Array<String>;
	
	public var _valueCache:Map<String, Array<Float>>;		// TODO
	public var _program:GLProgram;
	

	public function new(baseName:Dynamic, attributesNames:Array<String>, uniformsNames:Array<String>, samplers:Array<String>, engine:Engine, defines:String, optionalDefines:Array<String> = null) {
		this._engine = engine;
        this.name = baseName;
        this.defines = defines;
        this._uniformsNames = uniformsNames.concat(samplers);
        this._samplers = samplers;
        this._isReady = false;
        this._compilationError = "";
        this._attributesNames = attributesNames;
		
        var vertex:String = Reflect.field(baseName, "vertex") != null ? baseName.vertex : baseName;
        var fragment:String = Reflect.field(baseName, "fragment") != null ? baseName.fragment : baseName;
						
		var vertexShaderUrl:String = "";
        if (vertex.charAt(0) == ".") {
            vertexShaderUrl = vertex;
        } else {
            vertexShaderUrl = Engine.ShadersRepository + vertex;
        }
		var fragmentShaderUrl:String = "";
        if (fragment.charAt(0) == ".") {
            fragmentShaderUrl = fragment;
        } else {
            fragmentShaderUrl = Engine.ShadersRepository + fragment;
        }
		
		var _vertexCode:String = ""; 
		if (Effect.ShadersStore.exists(vertex + "VertexShader")) {
			_vertexCode = Effect.ShadersStore.get(vertex + "VertexShader");
		} else {
			_vertexCode = StringTools.trim(Assets.getText(vertexShaderUrl + ".vertex.txt"));
		}
		
		var _fragmentCode:String = "";
		if (Effect.ShadersStore.exists(fragment + "PixelShader")) {
			_fragmentCode = Effect.ShadersStore.get(fragment + "PixelShader");
		} else {
			_fragmentCode = StringTools.trim(Assets.getText(fragmentShaderUrl + ".fragment.txt"));	
		}
		
		this._prepareEffect(_vertexCode, _fragmentCode, attributesNames, defines, optionalDefines, false);		
		
        // Cache
        this._valueCache = new Map<String, Array<Float>>();
	}
	
	public function isReady():Bool {
        return this._isReady;
    }
	
	public function getProgram():GLProgram {
        return this._program;
    }
	
	public function getAttributesNames():Array<String> {
        return this._attributesNames;
    }
	
	public function getAttribute(index:Int):Int {
        return this._attributes[index];
    }
	
	public function getAttributesCount():Int {
        return this._attributes.length;
    }
	
	public function getUniformIndex(uniformName:String):Int {
        return Lambda.indexOf(this._uniformsNames, uniformName);
    }
	
	public function getUniform(uniformName:String):GLUniformLocation {	
        return this._uniforms[Lambda.indexOf(this._uniformsNames, uniformName)];
    }
	
	public function getSamplers():Array<String> {
        return this._samplers;
    }
	
	public function getCompilationError():String {
        return this._compilationError;
    }
	
	//public function _loadVertexShader(vertex:String, callbackFn:String->Void) {
	public function _loadVertexShader(vertex:String, callbackFn:String->Void) {
        // Is in local store ?
        if (Effect.ShadersStore.exists(vertex + "VertexShader")) {
            callbackFn(Effect.ShadersStore.get(vertex + "VertexShader"));
            return;
        }
        
        var vertexShaderUrl:String = "";

        if (vertex.charAt(0) == ".") {
            vertexShaderUrl = vertex;
        } else {
            vertexShaderUrl = Engine.ShadersRepository + vertex;
        }

        // Vertex shader
        Tools.LoadFile(vertexShaderUrl + ".vertex.fx", callbackFn);
    }
	
	public function _loadFragmentShader(fragment:String, callbackFn:String->Void) {
        // Is in local store ?
        if (Effect.ShadersStore.exists(fragment + "PixelShader")) {
            callbackFn(Effect.ShadersStore.get(fragment + "PixelShader"));
            return;
        }
        
        var fragmentShaderUrl:String = "";

        if (fragment.charAt(0) == ".") {
            fragmentShaderUrl = fragment;
        } else {
            fragmentShaderUrl = Engine.ShadersRepository + fragment;
        }

        // Fragment shader
        Tools.LoadFile(fragmentShaderUrl + ".fragment.fx", callbackFn);
    }
	
	public function _prepareEffect(vertexSourceCode:String, fragmentSourceCode:String, attributesNames:Array<String>, defines:String, optionalDefines:Array<String>, useFallback:Bool) {
        try {
            var engine:Engine = this._engine;
            this._program = engine.createShaderProgram(vertexSourceCode, fragmentSourceCode, defines);

            this._uniforms = engine.getUniforms(this._program, this._uniformsNames);
            this._attributes = engine.getAttributes(this._program, attributesNames);			
			
			var index:Int = 0;
			while(index < this._samplers.length) {
                var sampler = this.getUniform(this._samplers[index]);
				#if html5
				if (sampler == null) {
				#else
                if (sampler < 0) {
				#end
                    this._samplers.splice(index, 1);
                    index--;
                }
				
				index++;
            }
			
            engine.bindSamplers(this);

            this._isReady = true;
        } catch (e:Dynamic) {
			trace(e);
            if (!useFallback && optionalDefines != null) {
                for (index in 0...optionalDefines.length) {
                    defines = StringTools.replace(defines, optionalDefines[index], "");
                }
                this._prepareEffect(vertexSourceCode, fragmentSourceCode, attributesNames, defines, optionalDefines, true);
            } else {
                trace("Unable to compile effect: " + this.name);
                trace("Defines: " + defines);
                trace("Optional defines: " + optionalDefines);
                this._compilationError = cast e;
            }
        }
    }
	
	public function _bindTexture(channel:String, texture:BabylonTexture) {
        this._engine._bindTexture(Lambda.indexOf(this._samplers, channel), texture);
    }
	
	public function setTexture(channel:String, texture:Texture) {
        this._engine.setTexture(Lambda.indexOf(this._samplers, channel), texture);
    }
	
	public function setTextureFromPostProcess(channel:String, postProcess:PostProcess) {
        this._engine.setTextureFromPostProcess(Lambda.indexOf(this._samplers, channel), postProcess);
    }
	
	//public function _cacheMatrix = function (uniformName, matrix) {
    //    if (!this._valueCache[uniformName]) {
    //        this._valueCache[uniformName] = new BABYLON.Matrix();
    //    }

    //    for (var index = 0; index < 16; index++) {
    //        this._valueCache[uniformName].m[index] = matrix.m[index];
    //    }
    //};

    inline public function _cacheFloat2(uniformName:String, x:Float, y:Float) {
        if (!this._valueCache.exists(uniformName)) {
            this._valueCache.set(uniformName, [x, y]);
        } else {
			this._valueCache.get(uniformName)[0] = x;
			this._valueCache.get(uniformName)[1] = y;
		}
    }

	inline public function _cacheFloat3(uniformName:String, x:Float, y:Float, z:Float) {
        if (!this._valueCache.exists(uniformName)) {
            this._valueCache.set(uniformName, [x, y, z]);
        } else {
			this._valueCache.get(uniformName)[0] = x;
			this._valueCache.get(uniformName)[1] = y;
			this._valueCache.get(uniformName)[2] = z;
		}
    }

    inline public function _cacheFloat4(uniformName:String, x:Float, y:Float, z:Float, w:Float) {		
        if (!this._valueCache.exists(uniformName)) {
            this._valueCache.set(uniformName, [x, y, z, w]);
        } else {
			this._valueCache.get(uniformName)[0] = x;
			this._valueCache.get(uniformName)[1] = y;
			this._valueCache.get(uniformName)[2] = z;
			this._valueCache.get(uniformName)[3] = w;
		}
    }
	
	inline public function setMatrices(uniformName:String, matrices:Array<Float> /*Float32Array*/) {
        this._engine.setMatrices(this.getUniform(uniformName), matrices);
    }

    inline public function setMatrix(uniformName:String, matrix:Matrix) {
        //if (this._valueCache[uniformName] && this._valueCache[uniformName].equals(matrix))
        //    return;

        //this._cacheMatrix(uniformName, matrix);
        this._engine.setMatrix(this.getUniform(uniformName), matrix);
    }

    inline public function setFloat(uniformName:String, value:Float) {
        if (!(this._valueCache.exists(uniformName) && this._valueCache.get(uniformName)[0] == value)) {
			this._valueCache.set(uniformName, [value]);
			this._engine.setFloat(this.getUniform(uniformName), value);
		}
    }

    inline public function setBool(uniformName:String, bool:Bool) {
        if (!(this._valueCache.exists(uniformName) && this._valueCache.get(uniformName)[0] == (bool ? 1.0 : 0.0))) {
			this._valueCache.set(uniformName, (bool ? [1.0] : [0.0]));
			this._engine.setBool(this.getUniform(uniformName), bool);
		}
    }
    
    inline public function setVector2(uniformName:String, vector2:Vector2) {
        if (!(this._valueCache.exists(uniformName) && this._valueCache.get(uniformName)[0] == vector2.x && this._valueCache.get(uniformName)[1] == vector2.y)) {
			this._cacheFloat2(uniformName, vector2.x, vector2.y);
			this._engine.setFloat2(this.getUniform(uniformName), vector2.x, vector2.y);
		}
    }

    inline public function setFloat2(uniformName:String, x:Float, y:Float) {
        if (!(this._valueCache.exists(uniformName) && this._valueCache.get(uniformName)[0] == x && this._valueCache.get(uniformName)[1] == y)) {
			this._cacheFloat2(uniformName, x, y);
			this._engine.setFloat2(this.getUniform(uniformName), x, y);
		}
    }
    
    inline public function setVector3(uniformName:String, vector3:Vector3) {
        if (!(this._valueCache.exists(uniformName) && this._valueCache.get(uniformName)[0] == vector3.x && this._valueCache.get(uniformName)[1] == vector3.y && this._valueCache.get(uniformName)[2] == vector3.z)) {
			this._cacheFloat3(uniformName, vector3.x, vector3.y, vector3.z);
			this._engine.setFloat3(this.getUniform(uniformName), vector3.x, vector3.y, vector3.z);
		}
    }

    inline public function setFloat3(uniformName:String, x:Float, y:Float, z:Float) {		
        if (!(this._valueCache.exists(uniformName) && this._valueCache.get(uniformName)[0] == x && this._valueCache.get(uniformName)[1] == y && this._valueCache.get(uniformName)[2] == z)) {		
			this._cacheFloat3(uniformName, x, y, z);
			this._engine.setFloat3(this.getUniform(uniformName), x, y, z);
		}
    }

    inline public function setFloat4(uniformName:String, x:Float, y:Float, z:Float, w:Float) {
        if (!(this._valueCache.exists(uniformName) && this._valueCache.get(uniformName)[0] == x && this._valueCache.get(uniformName)[1] == y && this._valueCache.get(uniformName)[2] == z && this._valueCache.get(uniformName)[3] == w)) {
			this._cacheFloat4(uniformName, x, y, z, w);
			this._engine.setFloat4(this.getUniform(uniformName), x, y, z, w);
		}
    }

    inline public function setColor3(uniformName:String, color3:Color3) {
        if (!(this._valueCache.exists(uniformName) && this._valueCache.get(uniformName)[0] == color3.r && this._valueCache.get(uniformName)[1] == color3.g && this._valueCache.get(uniformName)[2] == color3.b)) {
			this._cacheFloat3(uniformName, color3.r, color3.g, color3.b);
			this._engine.setColor3(this.getUniform(uniformName), color3);
		}
    }

    inline public function setColor4(uniformName:String, color3:Color3, alpha:Float) {
        if (!(this._valueCache.exists(uniformName) && this._valueCache.get(uniformName)[0] == color3.r && this._valueCache.get(uniformName)[1] == color3.g && this._valueCache.get(uniformName)[2] == color3.b && this._valueCache.get(uniformName)[3] == alpha)) {
			this._cacheFloat4(uniformName, color3.r, color3.g, color3.b, alpha);
			this._engine.setColor4(this.getUniform(uniformName), color3, alpha);
		}
    }
	
}
