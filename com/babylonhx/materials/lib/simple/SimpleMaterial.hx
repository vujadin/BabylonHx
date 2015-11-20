package com.babylonhx.materials.lib.simple;

import com.babylonhx.math.Matrix;
import com.babylonhx.math.Color3;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.animations.IAnimatable;


/**
 * ...
 * @author Krtolica Vujadin
 */

typedef SMD = SimpleMaterialDefines
 
class SimpleMaterial extends Material {
	
	static var fragmentShader:String = "precision highp float; \n  \n // Constants \n uniform vec3 vEyePosition; \n uniform vec4 vDiffuseColor; \n  \n // Input \n varying vec3 vPositionW; \n  \n #ifdef NORMAL \n varying vec3 vNormalW; \n #endif \n  \n #ifdef VERTEXCOLOR \n varying vec4 vColor; \n #endif \n  \n // Lights \n #ifdef LIGHT0 \n uniform vec4 vLightData0; \n uniform vec4 vLightDiffuse0; \n #ifdef SHADOW0 \n #if defined(SPOTLIGHT0) || defined(DIRLIGHT0) \n varying vec4 vPositionFromLight0; \n uniform sampler2D shadowSampler0; \n #else  uniform samplerCube shadowSampler0; \n #endif \n uniform vec3 shadowsInfo0; \n #endif \n #ifdef SPOTLIGHT0 \n uniform vec4 vLightDirection0; \n #endif \n #ifdef HEMILIGHT0 \n uniform vec3 vLightGround0; \n #endif \n #endif \n  \n #ifdef LIGHT1 \n uniform vec4 vLightData1; \n uniform vec4 vLightDiffuse1; \n #ifdef SHADOW1 \n #if defined(SPOTLIGHT1) || defined(DIRLIGHT1) \n varying vec4 vPositionFromLight1; \n uniform sampler2D shadowSampler1; \n #else  uniform samplerCube shadowSampler1; \n #endif \n uniform vec3 shadowsInfo1; \n #endif \n #ifdef SPOTLIGHT1 \n uniform vec4 vLightDirection1; \n #endif \n #ifdef HEMILIGHT1 \n uniform vec3 vLightGround1; \n #endif \n #endif \n  \n #ifdef LIGHT2 \n uniform vec4 vLightData2; \n uniform vec4 vLightDiffuse2; \n #ifdef SHADOW2# \n if defined(SPOTLIGHT2) || defined(DIRLIGHT2) \n varying vec4 vPositionFromLight2; \n uniform sampler2D shadowSampler2; \n #else  uniform samplerCube shadowSampler2; \n #endif \n uniform vec3 shadowsInfo2; \n #endif \n #ifdef SPOTLIGHT2 \n uniform vec4 vLightDirection2; \n #endif \n #ifdef HEMILIGHT2 \n uniform vec3 vLightGround2; \n #endif \n #endif \n  \n #ifdef LIGHT3 \n uniform vec4 vLightData3; \n uniform vec4 vLightDiffuse3; \n #ifdef SHADOW3# \n if defined(SPOTLIGHT3) || defined(DIRLIGHT3) \n varying vec4 vPositionFromLight3; \n uniform sampler2D shadowSampler3; \n #else  uniform samplerCube shadowSampler3; \n #endif \n uniform vec3 shadowsInfo3; \n #endif \n #ifdef SPOTLIGHT3 \n uniform vec4 vLightDirection3; \n #endif \n #ifdef HEMILIGHT3 \n uniform vec3 vLightGround3; \n #endif \n #endif \n  \n // Samplers \n #ifdef DIFFUSE \n varying vec2 vDiffuseUV; \n uniform sampler2D diffuseSampler; \n uniform vec2 vDiffuseInfos; \n #endif \n  \n // Shadows \n #ifdef SHADOWS \n  \n float unpack(vec4 color) {  const vec4 bit_shift = vec4(1.0 / (255.0 * 255.0 * 255.0), 1.0 / (255.0 * 255.0), 1.0 / 255.0, 1.0);  return dot(color, bit_shift); \n } \n  \n #if defined(POINTLIGHT0) || defined(POINTLIGHT1) || defined(POINTLIGHT2) || defined(POINTLIGHT3) \n float computeShadowCube(vec3 lightPosition, samplerCube shadowSampler, float darkness, float bias) {  vec3 directionToLight = vPositionW - lightPosition;  float depth = length(directionToLight); \n   depth = clamp(depth, 0., 1.); \n   directionToLight.y = 1.0 - directionToLight.y; \n   float shadow = unpack(textureCube(shadowSampler, directionToLight)) + bias; \n   if (depth > shadow) {      return darkness;  }  return 1.0; \n } \n  \n float computeShadowWithPCFCube(vec3 lightPosition, samplerCube shadowSampler, float bias, float darkness) {  vec3 directionToLight = vPositionW - lightPosition;  float depth = length(directionToLight); \n   depth = clamp(depth, 0., 1.); \n   directionToLight.y = 1.0 - directionToLight.y; \n   float visibility = 1.; \n   vec3 poissonDisk[4];  poissonDisk[0] = vec3(-0.094201624, 0.04, -0.039906216);  poissonDisk[1] = vec3(0.094558609, -0.04, -0.076890725);  poissonDisk[2] = vec3(-0.094184101, 0.01, -0.092938870);  poissonDisk[3] = vec3(0.034495938, -0.01, 0.029387760); \n   // Poisson Sampling  float biasedDepth = depth - bias; \n   if (unpack(textureCube(shadowSampler, directionToLight + poissonDisk[0])) < biasedDepth) visibility -= 0.25;  if (unpack(textureCube(shadowSampler, directionToLight + poissonDisk[1])) < biasedDepth) visibility -= 0.25;  if (unpack(textureCube(shadowSampler, directionToLight + poissonDisk[2])) < biasedDepth) visibility -= 0.25;  if (unpack(textureCube(shadowSampler, directionToLight + poissonDisk[3])) < biasedDepth) visibility -= 0.25; \n   return min(1.0, visibility + darkness); \n } \n #endif \n  \n #if defined(SPOTLIGHT0) || defined(SPOTLIGHT1) || defined(SPOTLIGHT2) || defined(SPOTLIGHT3) || defined(DIRLIGHT0) || defined(DIRLIGHT1) || defined(DIRLIGHT2) || defined(DIRLIGHT3) \n float computeShadow(vec4 vPositionFromLight, sampler2D shadowSampler, float darkness, float bias) {  vec3 depth = vPositionFromLight.xyz / vPositionFromLight.w;  depth = 0.5 * depth + vec3(0.5);  vec2 uv = depth.xy; \n   if (uv.x < 0. || uv.x > 1.0 || uv.y < 0. || uv.y > 1.0) {      return 1.0;  } \n   float shadow = unpack(texture2D(shadowSampler, uv)) + bias; \n   if (depth.z > shadow) {      return darkness;  }  return 1.; \n } \n  \n float computeShadowWithPCF(vec4 vPositionFromLight, sampler2D shadowSampler, float mapSize, float bias, float darkness) {  vec3 depth = vPositionFromLight.xyz / vPositionFromLight.w;  depth = 0.5 * depth + vec3(0.5);  vec2 uv = depth.xy; \n   if (uv.x < 0. || uv.x > 1.0 || uv.y < 0. || uv.y > 1.0) {      return 1.0;  } \n   float visibility = 1.; \n   vec2 poissonDisk[4];  poissonDisk[0] = vec2(-0.94201624, -0.39906216);  poissonDisk[1] = vec2(0.94558609, -0.76890725);  poissonDisk[2] = vec2(-0.094184101, -0.92938870);  poissonDisk[3] = vec2(0.34495938, 0.29387760); \n   // Poisson Sampling  float biasedDepth = depth.z - bias; \n   if (unpack(texture2D(shadowSampler, uv + poissonDisk[0] / mapSize)) < biasedDepth) visibility -= 0.25;  if (unpack(texture2D(shadowSampler, uv + poissonDisk[1] / mapSize)) < biasedDepth) visibility -= 0.25;  if (unpack(texture2D(shadowSampler, uv + poissonDisk[2] / mapSize)) < biasedDepth) visibility -= 0.25;  if (unpack(texture2D(shadowSampler, uv + poissonDisk[3] / mapSize)) < biasedDepth) visibility -= 0.25; \n   return min(1.0, visibility + darkness); \n } \n  \n // Thanks to http://devmaster.net/ \n float unpackHalf(vec2 color) {  return color.x + (color.y / 255.0); \n } \n  \n float linstep(float low, float high, float v) {  return clamp((v - low) / (high - low), 0.0, 1.0); \n } \n  \n float ChebychevInequality(vec2 moments, float compare, float bias) {  float p = smoothstep(compare - bias, compare, moments.x);  float variance = max(moments.y - moments.x * moments.x, 0.02);  float d = compare - moments.x;  float p_max = linstep(0.2, 1.0, variance / (variance + d * d)); \n   return clamp(max(p, p_max), 0.0, 1.0); \n } \n  \n float computeShadowWithVSM(vec4 vPositionFromLight, sampler2D shadowSampler, float bias, float darkness) {  vec3 depth = vPositionFromLight.xyz / vPositionFromLight.w;  depth = 0.5 * depth + vec3(0.5);  vec2 uv = depth.xy; \n   if (uv.x < 0. || uv.x > 1.0 || uv.y < 0. || uv.y > 1.0 || depth.z >= 1.0) {      return 1.0;  } \n   vec4 texel = texture2D(shadowSampler, uv); \n   vec2 moments = vec2(unpackHalf(texel.xy), unpackHalf(texel.zw));  return min(1.0, 1.0 - ChebychevInequality(moments, depth.z, bias) + darkness); \n } \n #endif \n #endif \n  \n  \n #ifdef CLIPPLANE \n varying float fClipDistance; \n #endif \n  \n // Fog \n #ifdef FOG \n  \n #define FOGMODE_NONE 0. \n #define FOGMODE_EXP 1. \n #define FOGMODE_EXP2 2. \n #define FOGMODE_LINEAR 3. \n #define E 2.71828 \n  \n uniform vec4 vFogInfos; \n uniform vec3 vFogColor; \n varying float fFogDistance; \n  \n float CalcFogFactor() {  float fogCoeff = 1.0;  float fogStart = vFogInfos.y;  float fogEnd = vFogInfos.z;  float fogDensity = vFogInfos.w; \n   if (FOGMODE_LINEAR == vFogInfos.x) {      fogCoeff = (fogEnd - fFogDistance) / (fogEnd - fogStart);  } else if (FOGMODE_EXP == vFogInfos.x) {      fogCoeff = 1.0 / pow(E, fFogDistance * fogDensity);  } else if (FOGMODE_EXP2 == vFogInfos.x) {      fogCoeff = 1.0 / pow(E, fFogDistance * fFogDistance * fogDensity * fogDensity);  } \n   return clamp(fogCoeff, 0.0, 1.0); \n } \n #endif \n  \n // Light Computing \n struct lightingInfo {  vec3 diffuse; \n }; \n  \n lightingInfo computeLighting(vec3 viewDirectionW, vec3 vNormal, vec4 lightData, vec3 diffuseColor, float range) {  lightingInfo result; \n   vec3 lightVectorW;  float attenuation = 1.0;  if (lightData.w == 0.) {      vec3 direction = lightData.xyz - vPositionW; \n   attenuation = max(0., 1.0 - length(direction) / range);      lightVectorW = normalize(direction);  } else {      lightVectorW = normalize(-lightData.xyz);  } \n   // diffuse  float ndl = max(0., dot(vNormal, lightVectorW));  result.diffuse = ndl * diffuseColor * attenuation; \n   return result; \n } \n  \n lightingInfo computeSpotLighting(vec3 viewDirectionW, vec3 vNormal, vec4 lightData, vec4 lightDirection, vec3 diffuseColor, float range) {  lightingInfo result; \n   vec3 direction = lightData.xyz - vPositionW;  vec3 lightVectorW = normalize(direction);  float attenuation = max(0., 1.0 - length(direction) / range); \n   // diffuse  float cosAngle = max(0., dot(-lightDirection.xyz, lightVectorW));  float spotAtten = 0.0; \n   if (cosAngle >= lightDirection.w) {      cosAngle = max(0., pow(cosAngle, lightData.w));      spotAtten = clamp((cosAngle - lightDirection.w) / (1. - cosAngle), 0.0, 1.0); \n   // Diffuse      float ndl = max(0., dot(vNormal, -lightDirection.xyz));      result.diffuse = ndl * spotAtten * diffuseColor * attenuation; \n   return result;  } \n   result.diffuse = vec3(0.); \n   return result; \n } \n  \n lightingInfo computeHemisphericLighting(vec3 viewDirectionW, vec3 vNormal, vec4 lightData, vec3 diffuseColor, vec3 groundColor) {  lightingInfo result; \n   // Diffuse  float ndl = dot(vNormal, lightData.xyz) * 0.5 + 0.5;  result.diffuse = mix(groundColor, diffuseColor, ndl); \n   return result; \n } \n  \n void main(void) {  // Clip plane  #ifdef CLIPPLANE  if (fClipDistance > 0.0)      discard; \n 	#endif \n   vec3 viewDirectionW = normalize(vEyePosition - vPositionW); \n   // Base color  vec4 baseColor = vec4(1., 1., 1., 1.);  vec3 diffuseColor = vDiffuseColor.rgb; \n   // Alpha  float alpha = vDiffuseColor.a; \n   #ifdef DIFFUSE  baseColor = texture2D(diffuseSampler, vDiffuseUV); \n   #ifdef ALPHATEST  if (baseColor.a < 0.4)      discard; \n 	#endif \n   baseColor.rgb *= vDiffuseInfos.y; \n 	#endif \n   #ifdef VERTEXCOLOR  baseColor.rgb *= vColor.rgb; \n 	#endif \n   // Bump  #ifdef NORMAL  vec3 normalW = normalize(vNormalW); \n 	#else      vec3 normalW = vec3(1.0, 1.0, 1.0); \n 	#endif \n   // Lighting  vec3 diffuseBase = vec3(0., 0., 0.);  float shadow = 1.; \n   #ifdef LIGHT0 \n 	#ifdef SPOTLIGHT0  lightingInfo info = computeSpotLighting(viewDirectionW, normalW, vLightData0, vLightDirection0, vLightDiffuse0.rgb, vLightDiffuse0.a); \n 	#endif \n 	#ifdef HEMILIGHT0  lightingInfo info = computeHemisphericLighting(viewDirectionW, normalW, vLightData0, vLightDiffuse0.rgb, vLightGround0); \n 	#endif \n 	#if defined(POINTLIGHT0) || defined(DIRLIGHT0)  lightingInfo info = computeLighting(viewDirectionW, normalW, vLightData0, vLightDiffuse0.rgb, vLightDiffuse0.a); \n 	#endif \n 	#ifdef SHADOW0 \n 	#ifdef SHADOWVSM0  shadow = computeShadowWithVSM(vPositionFromLight0, shadowSampler0, shadowsInfo0.z, shadowsInfo0.x); \n 	#else \n 	#ifdef SHADOWPCF0#  if defined(POINTLIGHT0)  shadow = computeShadowWithPCFCube(vLightData0.xyz, shadowSampler0, shadowsInfo0.z, shadowsInfo0.x); \n 	#else      shadow = computeShadowWithPCF(vPositionFromLight0, shadowSampler0, shadowsInfo0.y, shadowsInfo0.z, shadowsInfo0.x); \n 	#endif \n 	#else \n 	#if defined(POINTLIGHT0)  shadow = computeShadowCube(vLightData0.xyz, shadowSampler0, shadowsInfo0.x, shadowsInfo0.z); \n 	#else      shadow = computeShadow(vPositionFromLight0, shadowSampler0, shadowsInfo0.x, shadowsInfo0.z); \n 	#endif \n 	#endif \n 	#endif \n 	#else      shadow = 1.;#  endif  diffuseBase += info.diffuse * shadow; \n 	#endif \n   #ifdef LIGHT1 \n 	#ifdef SPOTLIGHT1  info = computeSpotLighting(viewDirectionW, normalW, vLightData1, vLightDirection1, vLightDiffuse1.rgb, vLightDiffuse1.a); \n 	#endif \n 	#ifdef HEMILIGHT1  info = computeHemisphericLighting(viewDirectionW, normalW, vLightData1, vLightDiffuse1.rgb, vLightGround1.a); \n 	#endif \n 	#if defined(POINTLIGHT1) || defined(DIRLIGHT1)  info = computeLighting(viewDirectionW, normalW, vLightData1, vLightDiffuse1.rgb, vLightDiffuse1.a); \n 	#endif \n 	#ifdef SHADOW1 \n 	#ifdef SHADOWVSM1  shadow = computeShadowWithVSM(vPositionFromLight1, shadowSampler1, shadowsInfo1.z, shadowsInfo1.x); \n 	#else \n 	#ifdef SHADOWPCF1 \n 	#if defined(POINTLIGHT1)  shadow = computeShadowWithPCFCube(vLightData1.xyz, shadowSampler1, shadowsInfo1.z, shadowsInfo1.x); \n 	#else      shadow = computeShadowWithPCF(vPositionFromLight1, shadowSampler1, shadowsInfo1.y, shadowsInfo1.z, shadowsInfo1.x); \n 	#endif \n 	#else \n 	#if defined(POINTLIGHT1)  shadow = computeShadowCube(vLightData1.xyz, shadowSampler1, shadowsInfo1.x, shadowsInfo1.z); \n 	#else      shadow = computeShadow(vPositionFromLight1, shadowSampler1, shadowsInfo1.x, shadowsInfo1.z); \n 	#endif \n 	#endif \n 	#endif \n 	#else      shadow = 1.; \n 	#endif  diffuseBase += info.diffuse * shadow; \n 	#endif \n   #ifdef LIGHT2 \n 	#ifdef SPOTLIGHT2  info = computeSpotLighting(viewDirectionW, normalW, vLightData2, vLightDirection2, vLightDiffuse2.rgb, vLightDiffuse2.a); \n 	#endif \n 	#ifdef HEMILIGHT2  info = computeHemisphericLighting(viewDirectionW, normalW, vLightData2, vLightDiffuse2.rgb, vLightGround2); \n 	#endif \n 	#if defined(POINTLIGHT2) || defined(DIRLIGHT2)  info = computeLighting(viewDirectionW, normalW, vLightData2, vLightDiffuse2.rgb, vLightDiffuse2.a); \n 	#endif \n 	#ifdef SHADOW2 \n 	#ifdef SHADOWVSM2  shadow = computeShadowWithVSM(vPositionFromLight2, shadowSampler2, shadowsInfo2.z, shadowsInfo2.x); \n 	#else \n 	#ifdef SHADOWPCF2#  if defined(POINTLIGHT2)  shadow = computeShadowWithPCFCube(vLightData2.xyz, shadowSampler2, shadowsInfo2.z, shadowsInfo2.x); \n 	#else      shadow = computeShadowWithPCF(vPositionFromLight2, shadowSampler2, shadowsInfo2.y, shadowsInfo2.z, shadowsInfo2.x); \n 	#endif \n 	#else \n 	#if defined(POINTLIGHT2)  shadow = computeShadowCube(vLightData2.xyz, shadowSampler2, shadowsInfo2.x, shadowsInfo2.z); \n 	#else      shadow = computeShadow(vPositionFromLight2, shadowSampler2, shadowsInfo2.x, shadowsInfo2.z); \n 	#endif \n 	#endif \n 	#endif \n 	#else      shadow = 1.; \n 	#endif  diffuseBase += info.diffuse * shadow; \n 	#endif \n   #ifdef LIGHT3 \n 	#ifdef SPOTLIGHT3  info = computeSpotLighting(viewDirectionW, normalW, vLightData3, vLightDirection3, vLightDiffuse3.rgb, vLightDiffuse3.a); \n 	#endif \n 	#ifdef HEMILIGHT3  info = computeHemisphericLighting(viewDirectionW, normalW, vLightData3, vLightDiffuse3.rgb, vLightGround3); \n 	#endif \n 	#if defined(POINTLIGHT3) || defined(DIRLIGHT3)  info = computeLighting(viewDirectionW, normalW, vLightData3, vLightDiffuse3.rgb, vLightDiffuse3.a); \n 	#endif \n 	#ifdef SHADOW3 \n 	#ifdef SHADOWVSM3  shadow = computeShadowWithVSM(vPositionFromLight3, shadowSampler3, shadowsInfo3.z, shadowsInfo3.x); \n 	#else \n 	#ifdef SHADOWPCF3 \n 	#if defined(POINTLIGHT3)  shadow = computeShadowWithPCFCube(vLightData3.xyz, shadowSampler3, shadowsInfo3.z, shadowsInfo3.x); \n 	#else      shadow = computeShadowWithPCF(vPositionFromLight3, shadowSampler3, shadowsInfo3.y, shadowsInfo3.z, shadowsInfo3.x); \n 	#endif \n 	#else \n 	#if defined(POINTLIGHT3)  shadow = computeShadowCube(vLightData3.xyz, shadowSampler3, shadowsInfo3.x, shadowsInfo3.z); \n 	#else      shadow = computeShadow(vPositionFromLight3, shadowSampler3, shadowsInfo3.x, shadowsInfo3.z); \n 	#endif \n 	#endif \n 	#endif \n 	#else      shadow = 1.; \n 	#endif  diffuseBase += info.diffuse * shadow; \n 	#endif \n   #ifdef VERTEXALPHA  alpha *= vColor.a;#  endif \n   vec3 finalDiffuse = clamp(diffuseBase * diffuseColor, 0.0, 1.0) * baseColor.rgb; \n   // Composition  vec4 color = vec4(finalDiffuse, alpha); \n   #ifdef FOG  float fog = CalcFogFactor();  color.rgb = fog * color.rgb + (1.0 - fog) * vFogColor; \n 	#endif \n   gl_FragColor = color; \n }";
	
	static var vertexShader:String = "precision highp float;\n\n// Attributes\nattribute vec3 position;\n#ifdef NORMAL\nattribute vec3 normal;\n#endif\n#ifdef UV1\nattribute vec2 uv;\n#endif\n#ifdef UV2\nattribute vec2 uv2;\n#endif\n#ifdef VERTEXCOLOR\nattribute vec4 color;\n#endif\n\n// Uniforms\n\n#ifdef INSTANCES\nattribute vec4 world0;\nattribute vec4 world1;\nattribute vec4 world2;\nattribute vec4 world3;\n#else\nuniform mat4 world;\n#endif\n\nuniform mat4 view;\nuniform mat4 viewProjection;\n\n#ifdef DIFFUSE\nvarying vec2 vDiffuseUV;\nuniform mat4 diffuseMatrix;\nuniform vec2 vDiffuseInfos;\n#endif\n\n#if NUM_BONE_INFLUENCERS > 0\n	uniform mat4 mBones[BonesPerMesh];\n\n	attribute vec4 matricesIndices;\n	attribute vec4 matricesWeights;\n	#if NUM_BONE_INFLUENCERS > 4\n		attribute vec4 matricesIndicesExtra;\n		attribute vec4 matricesWeightsExtra;\n	#endif\n#endif\n\n#ifdef POINTSIZE\nuniform float pointSize;\n#endif\n\n// Output\nvarying vec3 vPositionW;\n#ifdef NORMAL\nvarying vec3 vNormalW;\n#endif\n\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n\n#ifdef CLIPPLANE\nuniform vec4 vClipPlane;\nvarying float fClipDistance;\n#endif\n\n#ifdef FOG\nvarying float fFogDistance;\n#endif\n\n#ifdef SHADOWS\n#if defined(SPOTLIGHT0) || defined(DIRLIGHT0)\nuniform mat4 lightMatrix0;\nvarying vec4 vPositionFromLight0;\n#endif\n#if defined(SPOTLIGHT1) || defined(DIRLIGHT1)\nuniform mat4 lightMatrix1;\nvarying vec4 vPositionFromLight1;\n#endif\n#if defined(SPOTLIGHT2) || defined(DIRLIGHT2)\nuniform mat4 lightMatrix2;\nvarying vec4 vPositionFromLight2;\n#endif\n#if defined(SPOTLIGHT3) || defined(DIRLIGHT3)\nuniform mat4 lightMatrix3;\nvarying vec4 vPositionFromLight3;\n#endif\n#endif\n\nvoid main(void) {\n	mat4 finalWorld;\n\n#ifdef INSTANCES\n	finalWorld = mat4(world0, world1, world2, world3);\n#else\n	finalWorld = world;\n#endif\n\n#if NUM_BONE_INFLUENCERS > 0\n	mat4 influence;\n	influence = mBones[int(matricesIndices[0])] * matricesWeights[0];\n\n	#if NUM_BONE_INFLUENCERS > 1\n		influence += mBones[int(matricesIndices[1])] * matricesWeights[1];\n	#endif \n	#if NUM_BONE_INFLUENCERS > 2\n		influence += mBones[int(matricesIndices[2])] * matricesWeights[2];\n	#endif	\n	#if NUM_BONE_INFLUENCERS > 3\n		influence += mBones[int(matricesIndices[3])] * matricesWeights[3];\n	#endif	\n\n	#if NUM_BONE_INFLUENCERS > 4\n		influence += mBones[int(matricesIndicesExtra[0])] * matricesWeightsExtra[0];\n	#endif\n	#if NUM_BONE_INFLUENCERS > 5\n		influence += mBones[int(matricesIndicesExtra[1])] * matricesWeightsExtra[1];\n	#endif	\n	#if NUM_BONE_INFLUENCERS > 6\n		influence += mBones[int(matricesIndicesExtra[2])] * matricesWeightsExtra[2];\n	#endif	\n	#if NUM_BONE_INFLUENCERS > 7\n		influence += mBones[int(matricesIndicesExtra[3])] * matricesWeightsExtra[3];\n	#endif	\n\n	finalWorld = finalWorld * influence;\n#endif\n\n	gl_Position = viewProjection * finalWorld * vec4(position, 1.0);\n\n	vec4 worldPos = finalWorld * vec4(position, 1.0);\n	vPositionW = vec3(worldPos);\n\n#ifdef NORMAL\n	vNormalW = normalize(vec3(finalWorld * vec4(normal, 0.0)));\n#endif\n\n	// Texture coordinates\n#ifndef UV1\n	vec2 uv = vec2(0., 0.);\n#endif\n#ifndef UV2\n	vec2 uv2 = vec2(0., 0.);\n#endif\n\n#ifdef DIFFUSE\n	if (vDiffuseInfos.x == 0.)\n	{\n		vDiffuseUV = vec2(diffuseMatrix * vec4(uv, 1.0, 0.0));\n	}\n	else\n	{\n		vDiffuseUV = vec2(diffuseMatrix * vec4(uv2, 1.0, 0.0));\n	}\n#endif\n\n	// Clip plane\n#ifdef CLIPPLANE\n	fClipDistance = dot(worldPos, vClipPlane);\n#endif\n\n	// Fog\n#ifdef FOG\n	fFogDistance = (view * worldPos).z;\n#endif\n\n	// Shadows\n#ifdef SHADOWS\n#if defined(SPOTLIGHT0) || defined(DIRLIGHT0)\n	vPositionFromLight0 = lightMatrix0 * worldPos;\n#endif\n#if defined(SPOTLIGHT1) || defined(DIRLIGHT1)\n	vPositionFromLight1 = lightMatrix1 * worldPos;\n#endif\n#if defined(SPOTLIGHT2) || defined(DIRLIGHT2)\n	vPositionFromLight2 = lightMatrix2 * worldPos;\n#endif\n#if defined(SPOTLIGHT3) || defined(DIRLIGHT3)\n	vPositionFromLight3 = lightMatrix3 * worldPos;\n#endif\n#endif\n\n	// Vertex color\n#ifdef VERTEXCOLOR\n	vColor = color;\n#endif\n\n	// Point size\n#ifdef POINTSIZE\n	gl_PointSize = pointSize;\n#endif\n}";
	
	public var diffuseTexture:BaseTexture;

	public var diffuseColor:Color3 = new Color3(1, 1, 1);
	public var disableLighting:Bool = false;

	private var _worldViewProjectionMatrix:Matrix = Matrix.Zero();
	private var _scaledDiffuse:Color3 = new Color3();
	private var _renderId:Int;

	private var _defines:SimpleMaterialDefines = new SimpleMaterialDefines();
	private var _cachedDefines:SimpleMaterialDefines = new SimpleMaterialDefines();
	

	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		if (!ShadersStore.Shaders.exists("simplemat.fragment")) {
			ShadersStore.Shaders.set("simplemat.fragment", fragmentShader);
			ShadersStore.Shaders.set("simplemat.vertex", vertexShader);
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
	private function _checkCache(scene:Scene, ?mesh:AbstractMesh, ?useInstances:Bool = false):Bool {
		if (mesh == null) {
			return true;
		}
		
		if (this._defines.defines[SMD.INSTANCES] != useInstances) {
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
		
		var engine = scene.getEngine();
		var needNormals = false;
		var needUVs = false;
		
		this._defines.reset();
		
		// Textures
		if (scene.texturesEnabled) {
			if (this.diffuseTexture != null && StandardMaterial.DiffuseTextureEnabled) {
				if (!this.diffuseTexture.isReady()) {
					return false;
				} 
				else {
					needUVs = true;
					this._defines.defines[SMD.DIFFUSE]= true;
				}
			}                
		}
		
		// Effect
		if (scene.clipPlane != null) {
			this._defines.defines[SMD.CLIPPLANE] = true;
		}
		
		if (engine.getAlphaTesting()) {
			this._defines.defines[SMD.ALPHATEST] = true;
		}
		
		// Point size
		if (this.pointsCloud || scene.forcePointsCloud) {
			this._defines.defines[SMD.POINTSIZE] = true;
		}
		
		// Fog
		if (scene.fogEnabled && mesh != null && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE && this.fogEnabled) {
			this._defines.defines[SMD.FOG] = true;
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
				this._defines.defines[SMD.LIGHT0 + lightIndex] = true;
				
				var type:Int = this._defines.getLight(light.type, lightIndex);			
				this._defines.defines[type] = true;
				
				// Shadows
				if (scene.shadowsEnabled) {
					var shadowGenerator = light.getShadowGenerator();
					if (mesh != null && mesh.receiveShadows && shadowGenerator != null) {
						this._defines.defines[SMD.SHADOW0 + lightIndex] = true;
						
						this._defines.defines[SMD.SHADOWS] = true;
						
						if (shadowGenerator.useVarianceShadowMap || shadowGenerator.useBlurVarianceShadowMap) {
							this._defines.defines[SMD.SHADOWVSM0 + lightIndex] = true;
						}
						
						if (shadowGenerator.usePoissonSampling) {
							this._defines.defines[SMD.SHADOWPCF0 + lightIndex] = true;
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
				this._defines.defines[SMD.NORMAL] = true;
			}
			if (needUVs) {
				if (mesh.isVerticesDataPresent(VertexBuffer.UVKind)) {
					this._defines.defines[SMD.UV1] = true;
				}
				if (mesh.isVerticesDataPresent(VertexBuffer.UV2Kind)) {
					this._defines.defines[SMD.UV2] = true;
				}
			}
			if (mesh.useVertexColors && mesh.isVerticesDataPresent(VertexBuffer.ColorKind)) {
				this._defines.defines[SMD.VERTEXCOLOR] = true;
				
				if (mesh.hasVertexAlpha) {
					this._defines.defines[SMD.VERTEXALPHA] = true;
				}
			}
			if (mesh.useBones && mesh.computeBonesUsingShaders) {
				this._defines.NUM_BONE_INFLUENCERS = mesh.numBoneInfluencers;
				this._defines.BonesPerMesh = mesh.skeleton.bones.length + 1;
			}
			
			// Instances
			if (useInstances) {
				this._defines.defines[SMD.INSTANCES] = true;
			}
		}
		
		// Get correct effect      
		if (!this._defines.isEqual(this._cachedDefines) || this._effect == null) {
			this._defines.cloneTo(this._cachedDefines);
			
			scene.resetCachedMaterial();
			
			// Fallbacks
			var fallbacks = new EffectFallbacks();             
			if (this._defines.defines[SMD.FOG]) {
				fallbacks.addFallback(1, "FOG");
			}
			
			for (lightIndex in 0...Material.maxSimultaneousLights) {
				if (!this._defines.defines[SMD.LIGHT0 + lightIndex]) {
					continue;
				}
				
				if (lightIndex > 0) {
					fallbacks.addFallback(lightIndex, "LIGHT" + lightIndex);
				}
				
				if (this._defines.defines[SMD.SHADOW0 + lightIndex]) {
					fallbacks.addFallback(0, "SHADOW" + lightIndex);
				}
				
				if (this._defines.defines[SMD.SHADOWPCF0 + lightIndex]) {
					fallbacks.addFallback(0, "SHADOWPCF" + lightIndex);
				}
				
				if (this._defines.defines[SMD.SHADOWVSM0 + lightIndex]) {
					fallbacks.addFallback(0, "SHADOWVSM" + lightIndex);
				}
			}
		 
			if (this._defines.NUM_BONE_INFLUENCERS > 0){
                fallbacks.addCPUSkinningFallback(0, mesh);    
            }
			
			//Attributes
			var attribs:Array<String> = [VertexBuffer.PositionKind];
			
			if (this._defines.defines[SMD.NORMAL]) {
				attribs.push(VertexBuffer.NormalKind);
			}
			
			if (this._defines.defines[SMD.UV1]) {
				attribs.push(VertexBuffer.UVKind);
			}
			
			if (this._defines.defines[SMD.UV2]) {
				attribs.push(VertexBuffer.UV2Kind);
			}
			
			if (this._defines.defines[SMD.VERTEXCOLOR]) {
				attribs.push(VertexBuffer.ColorKind);
			}
			
			if (this._defines.NUM_BONE_INFLUENCERS > 0) {
				attribs.push(VertexBuffer.MatricesIndicesKind);
				attribs.push(VertexBuffer.MatricesWeightsKind);
				if (this._defines.NUM_BONE_INFLUENCERS > 4) {
                    attribs.push(VertexBuffer.MatricesIndicesExtraKind);
                    attribs.push(VertexBuffer.MatricesWeightsExtraKind);
                }
			}
			
			if (this._defines.defines[SMD.INSTANCES]) {
				attribs.push("world0");
				attribs.push("world1");
				attribs.push("world2");
				attribs.push("world3");
			}
			
			// Legacy browser patch
			var shaderName = "simplemat";
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
					"shadowsInfo0", "shadowsInfo1", "shadowsInfo2", "shadowsInfo3"
				],
				["diffuseSampler",
					"shadowSampler0", "shadowSampler1", "shadowSampler2", "shadowSampler3"
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
				mesh._materialDefines = new SimpleMaterialDefines();
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
		
		// View
		if (scene.fogEnabled && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE) {
			this._effect.setMatrix("view", scene.getViewMatrix());
		}
		
		// Fog
		if (scene.fogEnabled && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE) {
			this._effect.setFloat4("vFogInfos", scene.fogMode, scene.fogStart, scene.fogEnd, scene.fogDensity);
			this._effect.setColor3("vFogColor", scene.fogColor);
		}
		
		super.bind(world, mesh);
	}

	public function getAnimatables():Array<IAnimatable> {
		var results:Array<IAnimatable> = [];
		
		if (this.diffuseTexture != null && this.diffuseTexture.animations != null && this.diffuseTexture.animations.length > 0) {
			results.push(this.diffuseTexture);
		}
		
		return results;
	}

	override public function dispose(forceDisposeEffect:Bool = false) {
		if (this.diffuseTexture != null) {
			this.diffuseTexture.dispose();
		}
		
		super.dispose(forceDisposeEffect);
	}

	override public function clone(name:String):SimpleMaterial {
		var newMaterial = new SimpleMaterial(name, this.getScene());
		
		// Base material
		this.copyTo(newMaterial);
		
		// Simple material
		if (this.diffuseTexture != null) {
			newMaterial.diffuseTexture = this.diffuseTexture.clone();
		}
		
		newMaterial.diffuseColor = this.diffuseColor.clone();
		
		return newMaterial;
	}
	
}
