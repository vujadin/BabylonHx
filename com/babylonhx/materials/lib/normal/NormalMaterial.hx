package com.babylonhx.materials.lib.normal;

import com.babylonhx.math.Color3;
import com.babylonhx.math.Matrix;
import com.babylonhx.lights.IShadowLight;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.tools.Tags;
import com.babylonhx.animations.IAnimatable;

/**
 * ...
 * @author Krtolica Vujadin
 */

typedef NMD = NormalMaterialDefines
 
class NormalMaterial extends Material {
	
	static var fragmentShader:String = "precision highp float;\r\n\r\n// Constants\r\nuniform vec3 vEyePosition;\r\nuniform vec4 vDiffuseColor;\r\n\r\n// Input\r\nvarying vec3 vPositionW;\r\n\r\n#ifdef NORMAL\r\nvarying vec3 vNormalW;\r\n#endif\r\n\r\n#ifdef VERTEXCOLOR\r\nvarying vec4 vColor;\r\n#endif\r\n\r\n// Lights\r\n#ifdef LIGHT0\r\nuniform vec4 vLightData0;\r\nuniform vec4 vLightDiffuse0;\r\n#ifdef SHADOW0\r\n#if defined(SPOTLIGHT0) || defined(DIRLIGHT0)\r\nvarying vec4 vPositionFromLight0;\r\nuniform sampler2D shadowSampler0;\r\n#else\r\nuniform samplerCube shadowSampler0;\r\n#endif\r\nuniform vec3 shadowsInfo0;\r\n#endif\r\n#ifdef SPOTLIGHT0\r\nuniform vec4 vLightDirection0;\r\n#endif\r\n#ifdef HEMILIGHT0\r\nuniform vec3 vLightGround0;\r\n#endif\r\n#endif\r\n\r\n#ifdef LIGHT1\r\nuniform vec4 vLightData1;\r\nuniform vec4 vLightDiffuse1;\r\n#ifdef SHADOW1\r\n#if defined(SPOTLIGHT1) || defined(DIRLIGHT1)\r\nvarying vec4 vPositionFromLight1;\r\nuniform sampler2D shadowSampler1;\r\n#else\r\nuniform samplerCube shadowSampler1;\r\n#endif\r\nuniform vec3 shadowsInfo1;\r\n#endif\r\n#ifdef SPOTLIGHT1\r\nuniform vec4 vLightDirection1;\r\n#endif\r\n#ifdef HEMILIGHT1\r\nuniform vec3 vLightGround1;\r\n#endif\r\n#endif\r\n\r\n#ifdef LIGHT2\r\nuniform vec4 vLightData2;\r\nuniform vec4 vLightDiffuse2;\r\n#ifdef SHADOW2\r\n#if defined(SPOTLIGHT2) || defined(DIRLIGHT2)\r\nvarying vec4 vPositionFromLight2;\r\nuniform sampler2D shadowSampler2;\r\n#else\r\nuniform samplerCube shadowSampler2;\r\n#endif\r\nuniform vec3 shadowsInfo2;\r\n#endif\r\n#ifdef SPOTLIGHT2\r\nuniform vec4 vLightDirection2;\r\n#endif\r\n#ifdef HEMILIGHT2\r\nuniform vec3 vLightGround2;\r\n#endif\r\n#endif\r\n\r\n#ifdef LIGHT3\r\nuniform vec4 vLightData3;\r\nuniform vec4 vLightDiffuse3;\r\n#ifdef SHADOW3\r\n#if defined(SPOTLIGHT3) || defined(DIRLIGHT3)\r\nvarying vec4 vPositionFromLight3;\r\nuniform sampler2D shadowSampler3;\r\n#else\r\nuniform samplerCube shadowSampler3;\r\n#endif\r\nuniform vec3 shadowsInfo3;\r\n#endif\r\n#ifdef SPOTLIGHT3\r\nuniform vec4 vLightDirection3;\r\n#endif\r\n#ifdef HEMILIGHT3\r\nuniform vec3 vLightGround3;\r\n#endif\r\n#endif\r\n\r\n// Samplers\r\n#ifdef DIFFUSE\r\nvarying vec2 vDiffuseUV;\r\nuniform sampler2D diffuseSampler;\r\nuniform vec2 vDiffuseInfos;\r\n#endif\r\n\r\n// Shadows\r\n#ifdef SHADOWS\r\n\r\nfloat unpack(vec4 color)\r\n{\r\n\tconst vec4 bit_shift = vec4(1.0 / (255.0 * 255.0 * 255.0), 1.0 / (255.0 * 255.0), 1.0 / 255.0, 1.0);\r\n\treturn dot(color, bit_shift);\r\n}\r\n\r\n#if defined(POINTLIGHT0) || defined(POINTLIGHT1) || defined(POINTLIGHT2) || defined(POINTLIGHT3)\r\nuniform vec2 depthValues;\r\n\r\nfloat computeShadowCube(vec3 lightPosition, samplerCube shadowSampler, float darkness, float bias)\r\n{\r\n\tvec3 directionToLight = vPositionW - lightPosition;\r\n\tfloat depth = length(directionToLight);\r\n\tdepth = clamp(depth, 0., 1.0);\r\n\r\n\tdirectionToLight = normalize(directionToLight);\r\n\tdirectionToLight.y = - directionToLight.y;\r\n\r\n\tfloat shadow = unpack(textureCube(shadowSampler, directionToLight)) + bias;\r\n\r\n\tif (depth > shadow)\r\n\t{\r\n\t\treturn darkness;\r\n\t}\r\n\treturn 1.0;\r\n}\r\n\r\nfloat computeShadowWithPCFCube(vec3 lightPosition, samplerCube shadowSampler, float bias, float darkness, float mapSize)\r\n{\r\n\tvec3 directionToLight = vPositionW - lightPosition;\r\n\tfloat depth = length(directionToLight);\r\n\r\n\tdepth = clamp(depth, 0., 1.0);\r\n\tfloat diskScale = 2.0 / mapSize;\r\n\r\n\tdirectionToLight = normalize(directionToLight);\r\n\tdirectionToLight.y = -directionToLight.y;\r\n\r\n\tfloat visibility = 1.;\r\n\r\n\tvec3 poissonDisk[4];\r\n\tpoissonDisk[0] = vec3(-0.094201624, 0.04, -0.039906216);\r\n\tpoissonDisk[1] = vec3(0.094558609, -0.04, -0.076890725);\r\n\tpoissonDisk[2] = vec3(-0.094184101, 0.01, -0.092938870);\r\n\tpoissonDisk[3] = vec3(0.034495938, -0.01, 0.029387760);\r\n\r\n\t// Poisson Sampling\r\n\tfloat biasedDepth = depth - bias;\r\n\r\n\tif (unpack(textureCube(shadowSampler, directionToLight + poissonDisk[0])) < biasedDepth) visibility -= 0.25;\r\n\tif (unpack(textureCube(shadowSampler, directionToLight + poissonDisk[1])) < biasedDepth) visibility -= 0.25;\r\n\tif (unpack(textureCube(shadowSampler, directionToLight + poissonDisk[2])) < biasedDepth) visibility -= 0.25;\r\n\tif (unpack(textureCube(shadowSampler, directionToLight + poissonDisk[3])) < biasedDepth) visibility -= 0.25;\r\n\r\n\treturn  min(1.0, visibility + darkness);\r\n}\r\n#endif\r\n\r\n#if defined(SPOTLIGHT0) || defined(SPOTLIGHT1) || defined(SPOTLIGHT2) || defined(SPOTLIGHT3) ||  defined(DIRLIGHT0) || defined(DIRLIGHT1) || defined(DIRLIGHT2) || defined(DIRLIGHT3)\r\nfloat computeShadow(vec4 vPositionFromLight, sampler2D shadowSampler, float darkness, float bias)\r\n{\r\n\tvec3 depth = vPositionFromLight.xyz / vPositionFromLight.w;\r\n\tdepth = 0.5 * depth + vec3(0.5);\r\n\tvec2 uv = depth.xy;\r\n\r\n\tif (uv.x < 0. || uv.x > 1.0 || uv.y < 0. || uv.y > 1.0)\r\n\t{\r\n\t\treturn 1.0;\r\n\t}\r\n\r\n\tfloat shadow = unpack(texture2D(shadowSampler, uv)) + bias;\r\n\r\n\tif (depth.z > shadow)\r\n\t{\r\n\t\treturn darkness;\r\n\t}\r\n\treturn 1.;\r\n}\r\n\r\nfloat computeShadowWithPCF(vec4 vPositionFromLight, sampler2D shadowSampler, float mapSize, float bias, float darkness)\r\n{\r\n\tvec3 depth = vPositionFromLight.xyz / vPositionFromLight.w;\r\n\tdepth = 0.5 * depth + vec3(0.5);\r\n\tvec2 uv = depth.xy;\r\n\r\n\tif (uv.x < 0. || uv.x > 1.0 || uv.y < 0. || uv.y > 1.0)\r\n\t{\r\n\t\treturn 1.0;\r\n\t}\r\n\r\n\tfloat visibility = 1.;\r\n\r\n\tvec2 poissonDisk[4];\r\n\tpoissonDisk[0] = vec2(-0.94201624, -0.39906216);\r\n\tpoissonDisk[1] = vec2(0.94558609, -0.76890725);\r\n\tpoissonDisk[2] = vec2(-0.094184101, -0.92938870);\r\n\tpoissonDisk[3] = vec2(0.34495938, 0.29387760);\r\n\r\n\t// Poisson Sampling\r\n\tfloat biasedDepth = depth.z - bias;\r\n\r\n\tif (unpack(texture2D(shadowSampler, uv + poissonDisk[0] / mapSize)) < biasedDepth) visibility -= 0.25;\r\n\tif (unpack(texture2D(shadowSampler, uv + poissonDisk[1] / mapSize)) < biasedDepth) visibility -= 0.25;\r\n\tif (unpack(texture2D(shadowSampler, uv + poissonDisk[2] / mapSize)) < biasedDepth) visibility -= 0.25;\r\n\tif (unpack(texture2D(shadowSampler, uv + poissonDisk[3] / mapSize)) < biasedDepth) visibility -= 0.25;\r\n\r\n\treturn  min(1.0, visibility + darkness);\r\n}\r\n\r\n// Thanks to http://devmaster.net/\r\nfloat unpackHalf(vec2 color)\r\n{\r\n\treturn color.x + (color.y / 255.0);\r\n}\r\n\r\nfloat linstep(float low, float high, float v) {\r\n\treturn clamp((v - low) / (high - low), 0.0, 1.0);\r\n}\r\n\r\nfloat ChebychevInequality(vec2 moments, float compare, float bias)\r\n{\r\n\tfloat p = smoothstep(compare - bias, compare, moments.x);\r\n\tfloat variance = max(moments.y - moments.x * moments.x, 0.02);\r\n\tfloat d = compare - moments.x;\r\n\tfloat p_max = linstep(0.2, 1.0, variance / (variance + d * d));\r\n\r\n\treturn clamp(max(p, p_max), 0.0, 1.0);\r\n}\r\n\r\nfloat computeShadowWithVSM(vec4 vPositionFromLight, sampler2D shadowSampler, float bias, float darkness)\r\n{\r\n\tvec3 depth = vPositionFromLight.xyz / vPositionFromLight.w;\r\n\tdepth = 0.5 * depth + vec3(0.5);\r\n\tvec2 uv = depth.xy;\r\n\r\n\tif (uv.x < 0. || uv.x > 1.0 || uv.y < 0. || uv.y > 1.0 || depth.z >= 1.0)\r\n\t{\r\n\t\treturn 1.0;\r\n\t}\r\n\r\n\tvec4 texel = texture2D(shadowSampler, uv);\r\n\r\n\tvec2 moments = vec2(unpackHalf(texel.xy), unpackHalf(texel.zw));\r\n\treturn min(1.0, 1.0 - ChebychevInequality(moments, depth.z, bias) + darkness);\r\n}\r\n#endif\r\n#endif\r\n\r\n\r\n#ifdef CLIPPLANE\r\nvarying float fClipDistance;\r\n#endif\r\n\r\n// Fog\r\n#ifdef FOG\r\n\r\n#define FOGMODE_NONE    0.\r\n#define FOGMODE_EXP     1.\r\n#define FOGMODE_EXP2    2.\r\n#define FOGMODE_LINEAR  3.\r\n#define E 2.71828\r\n\r\nuniform vec4 vFogInfos;\r\nuniform vec3 vFogColor;\r\nvarying float fFogDistance;\r\n\r\nfloat CalcFogFactor()\r\n{\r\n\tfloat fogCoeff = 1.0;\r\n\tfloat fogStart = vFogInfos.y;\r\n\tfloat fogEnd = vFogInfos.z;\r\n\tfloat fogDensity = vFogInfos.w;\r\n\r\n\tif (FOGMODE_LINEAR == vFogInfos.x)\r\n\t{\r\n\t\tfogCoeff = (fogEnd - fFogDistance) / (fogEnd - fogStart);\r\n\t}\r\n\telse if (FOGMODE_EXP == vFogInfos.x)\r\n\t{\r\n\t\tfogCoeff = 1.0 / pow(E, fFogDistance * fogDensity);\r\n\t}\r\n\telse if (FOGMODE_EXP2 == vFogInfos.x)\r\n\t{\r\n\t\tfogCoeff = 1.0 / pow(E, fFogDistance * fFogDistance * fogDensity * fogDensity);\r\n\t}\r\n\r\n\treturn clamp(fogCoeff, 0.0, 1.0);\r\n}\r\n#endif\r\n\r\n// Light Computing\r\nstruct lightingInfo\r\n{\r\n\tvec3 diffuse;\r\n};\r\n\r\nlightingInfo computeLighting(vec3 viewDirectionW, vec3 vNormal, vec4 lightData, vec3 diffuseColor, float range) {\r\n\tlightingInfo result;\r\n\r\n\tvec3 lightVectorW;\r\n\tfloat attenuation = 1.0;\r\n\tif (lightData.w == 0.)\r\n\t{\r\n\t\tvec3 direction = lightData.xyz - vPositionW;\r\n\r\n\t\tattenuation = max(0., 1.0 - length(direction) / range);\r\n\t\tlightVectorW = normalize(direction);\r\n\t}\r\n\telse\r\n\t{\r\n\t\tlightVectorW = normalize(-lightData.xyz);\r\n\t}\r\n\r\n\t// diffuse\r\n\tfloat ndl = max(0., dot(vNormal, lightVectorW));\r\n\tresult.diffuse = ndl * diffuseColor * attenuation;\r\n\r\n\treturn result;\r\n}\r\n\r\nlightingInfo computeSpotLighting(vec3 viewDirectionW, vec3 vNormal, vec4 lightData, vec4 lightDirection, vec3 diffuseColor, float range) {\r\n\tlightingInfo result;\r\n\r\n\tvec3 direction = lightData.xyz - vPositionW;\r\n\tvec3 lightVectorW = normalize(direction);\r\n\tfloat attenuation = max(0., 1.0 - length(direction) / range);\r\n\r\n\t// diffuse\r\n\tfloat cosAngle = max(0., dot(-lightDirection.xyz, lightVectorW));\r\n\tfloat spotAtten = 0.0;\r\n\r\n\tif (cosAngle >= lightDirection.w)\r\n\t{\r\n\t\tcosAngle = max(0., pow(cosAngle, lightData.w));\r\n\t\tspotAtten = clamp((cosAngle - lightDirection.w) / (1. - cosAngle), 0.0, 1.0);\r\n\r\n\t\t// Diffuse\r\n\t\tfloat ndl = max(0., dot(vNormal, -lightDirection.xyz));\r\n\t\tresult.diffuse = ndl * spotAtten * diffuseColor * attenuation;\r\n\r\n\t\treturn result;\r\n\t}\r\n\r\n\tresult.diffuse = vec3(0.);\r\n\r\n\treturn result;\r\n}\r\n\r\nlightingInfo computeHemisphericLighting(vec3 viewDirectionW, vec3 vNormal, vec4 lightData, vec3 diffuseColor, vec3 groundColor) {\r\n\tlightingInfo result;\r\n\r\n\t// Diffuse\r\n\tfloat ndl = dot(vNormal, lightData.xyz) * 0.5 + 0.5;\r\n\tresult.diffuse = mix(groundColor, diffuseColor, ndl);\r\n\r\n\treturn result;\r\n}\r\n\r\nvoid main(void) {\r\n\t// Clip plane\r\n#ifdef CLIPPLANE\r\n\tif (fClipDistance > 0.0)\r\n\t\tdiscard;\r\n#endif\r\n\r\n\tvec3 viewDirectionW = normalize(vEyePosition - vPositionW);\r\n\r\n\t// Base color\r\n\tvec4 baseColor = vec4(1., 1., 1., 1.);\r\n\tvec3 diffuseColor = vDiffuseColor.rgb;\r\n\r\n\t// Alpha\r\n\tfloat alpha = vDiffuseColor.a;\r\n\r\n#ifdef DIFFUSE\r\n\tbaseColor = texture2D(diffuseSampler, vDiffuseUV);\r\n\r\n#ifdef ALPHATEST\r\n\tif (baseColor.a < 0.4)\r\n\t\tdiscard;\r\n#endif\r\n\r\n\tbaseColor.rgb *= vDiffuseInfos.y;\r\n#endif\r\n\r\n\t// Mix with normal color\r\n\tbaseColor = mix(baseColor, vec4(vNormalW, 1.0), 0.5);\r\n\r\n#ifdef VERTEXCOLOR\r\n\tbaseColor.rgb *= vColor.rgb;\r\n#endif\r\n\r\n\t// Bump\r\n#ifdef NORMAL\r\n\tvec3 normalW = normalize(vNormalW);\r\n#else\r\n\tvec3 normalW = vec3(1.0, 1.0, 1.0);\r\n#endif\r\n\r\n\t// Lighting\r\n\tvec3 diffuseBase = vec3(0., 0., 0.);\r\n\tfloat shadow = 1.;\r\n\r\n#ifdef LIGHT0\r\n#ifdef SPOTLIGHT0\r\n\tlightingInfo info = computeSpotLighting(viewDirectionW, normalW, vLightData0, vLightDirection0, vLightDiffuse0.rgb, vLightDiffuse0.a);\r\n#endif\r\n#ifdef HEMILIGHT0\r\n\tlightingInfo info = computeHemisphericLighting(viewDirectionW, normalW, vLightData0, vLightDiffuse0.rgb, vLightGround0);\r\n#endif\r\n#if defined(POINTLIGHT0) || defined(DIRLIGHT0)\r\n\tlightingInfo info = computeLighting(viewDirectionW, normalW, vLightData0, vLightDiffuse0.rgb, vLightDiffuse0.a);\r\n#endif\r\n#ifdef SHADOW0\r\n#ifdef SHADOWVSM0\r\n\tshadow = computeShadowWithVSM(vPositionFromLight0, shadowSampler0, shadowsInfo0.z, shadowsInfo0.x);\r\n#else\r\n#ifdef SHADOWPCF0\r\n\t#if defined(POINTLIGHT0)\r\n\tshadow = computeShadowWithPCFCube(vLightData0.xyz, shadowSampler0, shadowsInfo0.z, shadowsInfo0.x, shadowsInfo0.y);\r\n\t#else\r\n\tshadow = computeShadowWithPCF(vPositionFromLight0, shadowSampler0, shadowsInfo0.y, shadowsInfo0.z, shadowsInfo0.x);\r\n\t#endif\r\n#else\r\n\t#if defined(POINTLIGHT0)\r\n\tshadow = computeShadowCube(vLightData0.xyz, shadowSampler0, shadowsInfo0.x, shadowsInfo0.z);\r\n\t#else\r\n\tshadow = computeShadow(vPositionFromLight0, shadowSampler0, shadowsInfo0.x, shadowsInfo0.z);\r\n\t#endif\r\n#endif\r\n#endif\r\n#else\r\n\tshadow = 1.;\r\n#endif\r\n\tdiffuseBase += info.diffuse * shadow;\r\n#endif\r\n\r\n#ifdef LIGHT1\r\n#ifdef SPOTLIGHT1\r\n\tinfo = computeSpotLighting(viewDirectionW, normalW, vLightData1, vLightDirection1, vLightDiffuse1.rgb, vLightDiffuse1.a);\r\n#endif\r\n#ifdef HEMILIGHT1\r\n\tinfo = computeHemisphericLighting(viewDirectionW, normalW, vLightData1, vLightDiffuse1.rgb, vLightGround1.a);\r\n#endif\r\n#if defined(POINTLIGHT1) || defined(DIRLIGHT1)\r\n\tinfo = computeLighting(viewDirectionW, normalW, vLightData1, vLightDiffuse1.rgb, vLightDiffuse1.a);\r\n#endif\r\n#ifdef SHADOW1\r\n#ifdef SHADOWVSM1\r\n\tshadow = computeShadowWithVSM(vPositionFromLight1, shadowSampler1, shadowsInfo1.z, shadowsInfo1.x);\r\n#else\r\n#ifdef SHADOWPCF1\r\n#if defined(POINTLIGHT1)\r\n\tshadow = computeShadowWithPCFCube(vLightData1.xyz, shadowSampler1, shadowsInfo1.z, shadowsInfo1.x, shadowsInfo1.y);\r\n#else\r\n\tshadow = computeShadowWithPCF(vPositionFromLight1, shadowSampler1, shadowsInfo1.y, shadowsInfo1.z, shadowsInfo1.x);\r\n#endif\r\n#else\r\n\t#if defined(POINTLIGHT1)\r\n\tshadow = computeShadowCube(vLightData1.xyz, shadowSampler1, shadowsInfo1.x, shadowsInfo1.z);\r\n\t#else\r\n\tshadow = computeShadow(vPositionFromLight1, shadowSampler1, shadowsInfo1.x, shadowsInfo1.z);\r\n\t#endif\r\n#endif\r\n#endif\r\n#else\r\n\tshadow = 1.;\r\n#endif\r\n\tdiffuseBase += info.diffuse * shadow;\r\n#endif\r\n\r\n#ifdef LIGHT2\r\n#ifdef SPOTLIGHT2\r\n\tinfo = computeSpotLighting(viewDirectionW, normalW, vLightData2, vLightDirection2, vLightDiffuse2.rgb, vLightDiffuse2.a);\r\n#endif\r\n#ifdef HEMILIGHT2\r\n\tinfo = computeHemisphericLighting(viewDirectionW, normalW, vLightData2, vLightDiffuse2.rgb, vLightGround2);\r\n#endif\r\n#if defined(POINTLIGHT2) || defined(DIRLIGHT2)\r\n\tinfo = computeLighting(viewDirectionW, normalW, vLightData2, vLightDiffuse2.rgb, vLightDiffuse2.a);\r\n#endif\r\n#ifdef SHADOW2\r\n#ifdef SHADOWVSM2\r\n\tshadow = computeShadowWithVSM(vPositionFromLight2, shadowSampler2, shadowsInfo2.z, shadowsInfo2.x);\r\n#else\r\n#ifdef SHADOWPCF2\r\n#if defined(POINTLIGHT2)\r\n\tshadow = computeShadowWithPCFCube(vLightData2.xyz, shadowSampler2, shadowsInfo2.z, shadowsInfo2.x, shadowsInfo2.y);\r\n#else\r\n\tshadow = computeShadowWithPCF(vPositionFromLight2, shadowSampler2, shadowsInfo2.y, shadowsInfo2.z, shadowsInfo2.x);\r\n#endif\r\n#else\r\n\t#if defined(POINTLIGHT2)\r\n\tshadow = computeShadowCube(vLightData2.xyz, shadowSampler2, shadowsInfo2.x, shadowsInfo2.z);\r\n\t#else\r\n\tshadow = computeShadow(vPositionFromLight2, shadowSampler2, shadowsInfo2.x, shadowsInfo2.z);\r\n\t#endif\r\n#endif\t\r\n#endif\t\r\n#else\r\n\tshadow = 1.;\r\n#endif\r\n\tdiffuseBase += info.diffuse * shadow;\r\n#endif\r\n\r\n#ifdef LIGHT3\r\n#ifdef SPOTLIGHT3\r\n\tinfo = computeSpotLighting(viewDirectionW, normalW, vLightData3, vLightDirection3, vLightDiffuse3.rgb, vLightDiffuse3.a);\r\n#endif\r\n#ifdef HEMILIGHT3\r\n\tinfo = computeHemisphericLighting(viewDirectionW, normalW, vLightData3, vLightDiffuse3.rgb, vLightGround3);\r\n#endif\r\n#if defined(POINTLIGHT3) || defined(DIRLIGHT3)\r\n\tinfo = computeLighting(viewDirectionW, normalW, vLightData3, vLightDiffuse3.rgb, vLightDiffuse3.a);\r\n#endif\r\n#ifdef SHADOW3\r\n#ifdef SHADOWVSM3\r\n\t\tshadow = computeShadowWithVSM(vPositionFromLight3, shadowSampler3, shadowsInfo3.z, shadowsInfo3.x);\r\n#else\r\n#ifdef SHADOWPCF3\r\n#if defined(POINTLIGHT3)\r\n\tshadow = computeShadowWithPCFCube(vLightData3.xyz, shadowSampler3, shadowsInfo3.z, shadowsInfo3.x, shadowsInfo3.y);\r\n#else\r\n\tshadow = computeShadowWithPCF(vPositionFromLight3, shadowSampler3, shadowsInfo3.y, shadowsInfo3.z, shadowsInfo3.x);\r\n#endif\r\n#else\r\n\t#if defined(POINTLIGHT3)\r\n\tshadow = computeShadowCube(vLightData3.xyz, shadowSampler3, shadowsInfo3.x, shadowsInfo3.z);\r\n\t#else\r\n\tshadow = computeShadow(vPositionFromLight3, shadowSampler3, shadowsInfo3.x, shadowsInfo3.z);\r\n\t#endif\r\n#endif\t\r\n#endif\t\r\n#else\r\n\tshadow = 1.;\r\n#endif\r\n\tdiffuseBase += info.diffuse * shadow;\r\n#endif\r\n\r\n#ifdef VERTEXALPHA\r\n\talpha *= vColor.a;\r\n#endif\r\n\r\n\tvec3 finalDiffuse = clamp(diffuseBase * diffuseColor, 0.0, 1.0) * baseColor.rgb;\r\n\r\n\t// Composition\r\n\tvec4 color = vec4(finalDiffuse, alpha);\r\n\r\n#ifdef FOG\r\n\tfloat fog = CalcFogFactor();\r\n\tcolor.rgb = fog * color.rgb + (1.0 - fog) * vFogColor;\r\n#endif\r\n\r\n\tgl_FragColor = color;\r\n}";

	static var vertexShader:String = "precision highp float;\n\n// Attributes\nattribute vec3 position;\n#ifdef NORMAL\nattribute vec3 normal;\n#endif\n#ifdef UV1\nattribute vec2 uv;\n#endif\n#ifdef UV2\nattribute vec2 uv2;\n#endif\n#ifdef VERTEXCOLOR\nattribute vec4 color;\n#endif\n\n#if NUM_BONE_INFLUENCERS > 0\n	uniform mat4 mBones[BonesPerMesh];\n\n	attribute vec4 matricesIndices;\n	attribute vec4 matricesWeights;\n	#if NUM_BONE_INFLUENCERS > 4\n		attribute vec4 matricesIndicesExtra;\n		attribute vec4 matricesWeightsExtra;\n	#endif\n#endif\n\n// Uniforms\n\n#ifdef INSTANCES\nattribute vec4 world0;\nattribute vec4 world1;\nattribute vec4 world2;\nattribute vec4 world3;\n#else\nuniform mat4 world;\n#endif\n\nuniform mat4 view;\nuniform mat4 viewProjection;\n\n#ifdef DIFFUSE\nvarying vec2 vDiffuseUV;\nuniform mat4 diffuseMatrix;\nuniform vec2 vDiffuseInfos;\n#endif\n\n\n#ifdef POINTSIZE\nuniform float pointSize;\n#endif\n\n// Output\nvarying vec3 vPositionW;\n#ifdef NORMAL\nvarying vec3 vNormalW;\n#endif\n\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n\n#ifdef CLIPPLANE\nuniform vec4 vClipPlane;\nvarying float fClipDistance;\n#endif\n\n#ifdef FOG\nvarying float fFogDistance;\n#endif\n\n#ifdef SHADOWS\n#if defined(SPOTLIGHT0) || defined(DIRLIGHT0)\nuniform mat4 lightMatrix0;\nvarying vec4 vPositionFromLight0;\n#endif\n#if defined(SPOTLIGHT1) || defined(DIRLIGHT1)\nuniform mat4 lightMatrix1;\nvarying vec4 vPositionFromLight1;\n#endif\n#if defined(SPOTLIGHT2) || defined(DIRLIGHT2)\nuniform mat4 lightMatrix2;\nvarying vec4 vPositionFromLight2;\n#endif\n#if defined(SPOTLIGHT3) || defined(DIRLIGHT3)\nuniform mat4 lightMatrix3;\nvarying vec4 vPositionFromLight3;\n#endif\n#endif\n\nvoid main(void) {\n	mat4 finalWorld;\n\n#ifdef INSTANCES\n	finalWorld = mat4(world0, world1, world2, world3);\n#else\n	finalWorld = world;\n#endif\n\n#if NUM_BONE_INFLUENCERS > 0\n	mat4 influence;\n	influence = mBones[int(matricesIndices[0])] * matricesWeights[0];\n\n	#if NUM_BONE_INFLUENCERS > 1\n		influence += mBones[int(matricesIndices[1])] * matricesWeights[1];\n	#endif \n	#if NUM_BONE_INFLUENCERS > 2\n		influence += mBones[int(matricesIndices[2])] * matricesWeights[2];\n	#endif	\n	#if NUM_BONE_INFLUENCERS > 3\n		influence += mBones[int(matricesIndices[3])] * matricesWeights[3];\n	#endif	\n\n	#if NUM_BONE_INFLUENCERS > 4\n		influence += mBones[int(matricesIndicesExtra[0])] * matricesWeightsExtra[0];\n	#endif\n	#if NUM_BONE_INFLUENCERS > 5\n		influence += mBones[int(matricesIndicesExtra[1])] * matricesWeightsExtra[1];\n	#endif	\n	#if NUM_BONE_INFLUENCERS > 6\n		influence += mBones[int(matricesIndicesExtra[2])] * matricesWeightsExtra[2];\n	#endif	\n	#if NUM_BONE_INFLUENCERS > 7\n		influence += mBones[int(matricesIndicesExtra[3])] * matricesWeightsExtra[3];\n	#endif	\n\n	finalWorld = finalWorld * influence;\n#endif\n	gl_Position = viewProjection * finalWorld * vec4(position, 1.0);\n\n	vec4 worldPos = finalWorld * vec4(position, 1.0);\n	vPositionW = vec3(worldPos);\n\n#ifdef NORMAL\n	vNormalW = normalize(vec3(finalWorld * vec4(normal, 0.0)));\n#endif\n\n	// Texture coordinates\n#ifndef UV1\n	vec2 uv = vec2(0., 0.);\n#endif\n#ifndef UV2\n	vec2 uv2 = vec2(0., 0.);\n#endif\n\n#ifdef DIFFUSE\n	if (vDiffuseInfos.x == 0.)\n	{\n		vDiffuseUV = vec2(diffuseMatrix * vec4(uv, 1.0, 0.0));\n	}\n	else\n	{\n		vDiffuseUV = vec2(diffuseMatrix * vec4(uv2, 1.0, 0.0));\n	}\n#endif\n\n	// Clip plane\n#ifdef CLIPPLANE\n	fClipDistance = dot(worldPos, vClipPlane);\n#endif\n\n	// Fog\n#ifdef FOG\n	fFogDistance = (view * worldPos).z;\n#endif\n\n	// Shadows\n#ifdef SHADOWS\n#if defined(SPOTLIGHT0) || defined(DIRLIGHT0)\n	vPositionFromLight0 = lightMatrix0 * worldPos;\n#endif\n#if defined(SPOTLIGHT1) || defined(DIRLIGHT1)\n	vPositionFromLight1 = lightMatrix1 * worldPos;\n#endif\n#if defined(SPOTLIGHT2) || defined(DIRLIGHT2)\n	vPositionFromLight2 = lightMatrix2 * worldPos;\n#endif\n#if defined(SPOTLIGHT3) || defined(DIRLIGHT3)\n	vPositionFromLight3 = lightMatrix3 * worldPos;\n#endif\n#endif\n\n	// Vertex color\n#ifdef VERTEXCOLOR\n	vColor = color;\n#endif\n\n	// Point size\n#ifdef POINTSIZE\n	gl_PointSize = pointSize;\n#endif\n}";
	
	
	public var diffuseTexture:BaseTexture;
	
	public var diffuseColor:Color3 = new Color3(1, 1, 1);
	public var disableLighting:Bool = false;

	private var _worldViewProjectionMatrix:Matrix = Matrix.Zero();
	private var _scaledDiffuse:Color3 = new Color3();
	private var _renderId:Int;

	private var _defines:NormalMaterialDefines = new NormalMaterialDefines();
	private var _cachedDefines:NormalMaterialDefines = new NormalMaterialDefines();
	

	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		if (!ShadersStore.Shaders.exists("normalmat.fragment")) {
			ShadersStore.Shaders.set("normalmat.fragment", fragmentShader);
			ShadersStore.Shaders.set("normalmat.vertex", vertexShader);
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
	private function _checkCache(scene:Scene, ?mesh:AbstractMesh, useInstances:Bool):Bool {
		if (mesh == null) {
			return true;
		}
		
		if (this._defines.defines[NMD.INSTANCES] != useInstances) {
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
					this._defines.defines[NMD.DIFFUSE] = true;
				}
			}                
		}
		
		// Effect
		if (scene.clipPlane != null) {
			this._defines.defines[NMD.CLIPPLANE] = true;
		}
		
		if (engine.getAlphaTesting()) {
			this._defines.defines[NMD.ALPHATEST] = true;
		}
		
		// Point size
		if (this.pointsCloud || scene.forcePointsCloud) {
			this._defines.defines[NMD.POINTSIZE] = true;
		}
		
		// Fog
		if (scene.fogEnabled && mesh != null && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE && this.fogEnabled) {
			this._defines.defines[NMD.FOG] = true;
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
				this._defines.defines[NMD.LIGHT0 + lightIndex] = true;
				
				var type:Int = this._defines.getLight(light.type, lightIndex);
				this._defines.defines[type] = true;

				// Shadows
				if (scene.shadowsEnabled) {
					var shadowGenerator = light.getShadowGenerator();
					if (mesh != null && mesh.receiveShadows && shadowGenerator != null) {
						this._defines.defines[NMD.SHADOW0 + lightIndex] = true;
						
						this._defines.defines[NMD.SHADOWS] = true;
						
						if (shadowGenerator.useVarianceShadowMap || shadowGenerator.useBlurVarianceShadowMap) {
							this._defines.defines[NMD.SHADOWVSM0 + lightIndex] = true;
						}
						
						if (shadowGenerator.usePoissonSampling) {
							this._defines.defines[NMD.SHADOWPCF0 + lightIndex] = true;
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
				this._defines.defines[NMD.NORMAL] = true;
			}
			if (needUVs) {
				if (mesh.isVerticesDataPresent(VertexBuffer.UVKind)) {
					this._defines.defines[NMD.UV1] = true;
				}
				if (mesh.isVerticesDataPresent(VertexBuffer.UV2Kind)) {
					this._defines.defines[NMD.UV2] = true;
				}
			}
			if (mesh.useVertexColors && mesh.isVerticesDataPresent(VertexBuffer.ColorKind)) {
				this._defines.defines[NMD.VERTEXCOLOR] = true;
				
				if (mesh.hasVertexAlpha) {
					this._defines.defines[NMD.VERTEXALPHA] = true;
				}
			}
			if (mesh.useBones && mesh.computeBonesUsingShaders) {
				this._defines.NUM_BONE_INFLUENCERS = mesh.numBoneInfluencers;
				this._defines.BonesPerMesh = (mesh.skeleton.bones.length + 1);
			}
			
			// Instances
			if (useInstances) {
				this._defines.defines[NMD.INSTANCES] = true;
			}
		}
		
		// Get correct effect      
		if (!this._defines.isEqual(this._cachedDefines) || this._effect == null) {
			this._defines.cloneTo(this._cachedDefines);
			
			scene.resetCachedMaterial();
			
			// Fallbacks
			var fallbacks:EffectFallbacks = new EffectFallbacks();             
			if (this._defines.defines[NMD.FOG]) {
				fallbacks.addFallback(1, "FOG");
			}
			
			for (lightIndex in 0...Material.maxSimultaneousLights) {
				if (!this._defines.defines[NMD.LIGHT0 + lightIndex]) {
					continue;
				}
				
				if (lightIndex > 0) {
					fallbacks.addFallback(lightIndex, "LIGHT" + lightIndex);
				}
				
				if (this._defines.defines[NMD.SHADOW0 + lightIndex]) {
					fallbacks.addFallback(0, "SHADOW" + lightIndex);
				}
				
				if (this._defines.defines[NMD.SHADOWPCF0 + lightIndex]) {
					fallbacks.addFallback(0, "SHADOWPCF" + lightIndex);
				}
				
				if (this._defines.defines[NMD.SHADOWVSM0 + lightIndex]) {
					fallbacks.addFallback(0, "SHADOWVSM" + lightIndex);
				}
			}
		 
			if (this._defines.NUM_BONE_INFLUENCERS > 0){
                fallbacks.addCPUSkinningFallback(0, mesh);    
            }
			
			//Attributes
			var attribs:Array<String> = [VertexBuffer.PositionKind];
			
			if (this._defines.defines[NMD.NORMAL]) {
				attribs.push(VertexBuffer.NormalKind);
			}
			
			if (this._defines.defines[NMD.UV1]) {
				attribs.push(VertexBuffer.UVKind);
			}
			
			if (this._defines.defines[NMD.UV2]) {
				attribs.push(VertexBuffer.UV2Kind);
			}
			
			if (this._defines.defines[NMD.VERTEXCOLOR]) {
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
			
			if (this._defines.defines[NMD.INSTANCES]) {
				attribs.push("world0");
				attribs.push("world1");
				attribs.push("world2");
				attribs.push("world3");
			}
			
			// Legacy browser patch
			var shaderName:String = "normalmat";
			var join = this._defines.toString();
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
					"shadowsInfo0", "shadowsInfo1", "shadowsInfo2", "shadowsInfo3", "depthValues",
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
				mesh._materialDefines = new NormalMaterialDefines();
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
						if (!cast(light, IShadowLight).needCube()) {
							effect.setMatrix("lightMatrix" + lightIndex, shadowGenerator.getTransformMatrix());
						} 
						else {
							if (!depthValuesAlreadySet) {
								depthValuesAlreadySet = true;
								effect.setFloat2("depthValues", scene.activeCamera.minZ, scene.activeCamera.maxZ);
							}
						}
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
		
		// View and Fog
		if (scene.fogEnabled && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE) {
			this._effect.setMatrix("view", scene.getViewMatrix());
			
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

	override public function clone(name:String, cloneChildren:Bool = false):NormalMaterial {
		var newMaterial = new NormalMaterial(name, this.getScene());
		
		// Base material
		this.copyTo(newMaterial);
		
		// Normal material
		if (this.diffuseTexture != null) {
			newMaterial.diffuseTexture = this.diffuseTexture.clone();
		}
		
		newMaterial.diffuseColor = this.diffuseColor.clone();
		
		return newMaterial;
	}
	
	override public function serialize():Dynamic {		
		var serializationObject = super.serialize();
		
		serializationObject.customType 		= "normal";
		serializationObject.diffuseColor    = this.diffuseColor.asArray();
		serializationObject.disableLighting = this.disableLighting;
		
		return serializationObject;
	}

	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):NormalMaterial {
		var material = new NormalMaterial(source.name, scene);
		
		material.diffuseColor    = Color3.FromArray(source.diffuseColor);
		material.disableLighting = source.disableLighting;
		
		material.alpha = source.alpha;
		
		material.id = source.id;
		
		Tags.AddTagsTo(material, source.tags);
		material.backFaceCulling = source.backFaceCulling;
		material.wireframe = source.wireframe;
		
		if (source.diffuseTexture != null) {
			material.diffuseTexture = Texture.Parse(source.diffuseTexture, scene, rootUrl);
		}
		
		if (source.checkReadyOnlyOnce != null) {
			material.checkReadyOnlyOnce = source.checkReadyOnlyOnce;
		}
		
		return material;
	}
	
}
