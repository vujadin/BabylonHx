package com.babylonhx.materials.lib.water;

import com.babylonhx.math.Plane;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.animations.IAnimatable;
import com.babylonhx.materials.ShaderMaterial;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.tools.Tags;

/**
 * ...
 * @author Krtolica Vujadin
 */

typedef WMD = WaterMaterialDefines
 
class WaterMaterial extends Material {
	
	static var fragmentShader:String = "precision highp float;\n\nuniform vec3 vEyePosition;\nuniform vec4 vDiffuseColor;\n#ifdef SPECULARTERM\nuniform vec4 vSpecularColor;\n#endif\n\nvarying vec3 vPositionW;\n#ifdef NORMAL\nvarying vec3 vNormalW;\n#endif\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n\n#ifdef LIGHT0\nuniform vec4 vLightData0;\nuniform vec4 vLightDiffuse0;\n#ifdef SPECULARTERM\nuniform vec3 vLightSpecular0;\n#endif\n#ifdef SHADOW0\n#if defined(SPOTLIGHT0) || defined(DIRLIGHT0)\nvarying vec4 vPositionFromLight0;\nuniform sampler2D shadowSampler0;\n#else\nuniform samplerCube shadowSampler0;\n#endif\nuniform vec3 shadowsInfo0;\n#endif\n#ifdef SPOTLIGHT0\nuniform vec4 vLightDirection0;\n#endif\n#ifdef HEMILIGHT0\nuniform vec3 vLightGround0;\n#endif\n#endif\n#ifdef LIGHT1\nuniform vec4 vLightData1;\nuniform vec4 vLightDiffuse1;\n#ifdef SPECULARTERM\nuniform vec3 vLightSpecular1;\n#endif\n#ifdef SHADOW1\n#if defined(SPOTLIGHT1) || defined(DIRLIGHT1)\nvarying vec4 vPositionFromLight1;\nuniform sampler2D shadowSampler1;\n#else\nuniform samplerCube shadowSampler1;\n#endif\nuniform vec3 shadowsInfo1;\n#endif\n#ifdef SPOTLIGHT1\nuniform vec4 vLightDirection1;\n#endif\n#ifdef HEMILIGHT1\nuniform vec3 vLightGround1;\n#endif\n#endif\n#ifdef LIGHT2\nuniform vec4 vLightData2;\nuniform vec4 vLightDiffuse2;\n#ifdef SPECULARTERM\nuniform vec3 vLightSpecular2;\n#endif\n#ifdef SHADOW2\n#if defined(SPOTLIGHT2) || defined(DIRLIGHT2)\nvarying vec4 vPositionFromLight2;\nuniform sampler2D shadowSampler2;\n#else\nuniform samplerCube shadowSampler2;\n#endif\nuniform vec3 shadowsInfo2;\n#endif\n#ifdef SPOTLIGHT2\nuniform vec4 vLightDirection2;\n#endif\n#ifdef HEMILIGHT2\nuniform vec3 vLightGround2;\n#endif\n#endif\n#ifdef LIGHT3\nuniform vec4 vLightData3;\nuniform vec4 vLightDiffuse3;\n#ifdef SPECULARTERM\nuniform vec3 vLightSpecular3;\n#endif\n#ifdef SHADOW3\n#if defined(SPOTLIGHT3) || defined(DIRLIGHT3)\nvarying vec4 vPositionFromLight3;\nuniform sampler2D shadowSampler3;\n#else\nuniform samplerCube shadowSampler3;\n#endif\nuniform vec3 shadowsInfo3;\n#endif\n#ifdef SPOTLIGHT3\nuniform vec4 vLightDirection3;\n#endif\n#ifdef HEMILIGHT3\nuniform vec3 vLightGround3;\n#endif\n#endif\n\n#ifdef BUMP\nvarying vec2 vNormalUV;\nuniform sampler2D normalSampler;\nuniform vec2 vNormalInfos;\n#endif\nuniform sampler2D refractionSampler;\nuniform sampler2D reflectionSampler;\n\nconst float LOG2=1.442695;\nuniform vec3 cameraPosition;\nuniform vec4 waterColor;\nuniform float colorBlendFactor;\nuniform float bumpHeight;\n\nvarying vec3 vRefractionMapTexCoord;\nvarying vec3 vReflectionMapTexCoord;\nvarying vec3 vPosition;\n\n#ifdef SHADOWS\nfloat unpack(vec4 color)\n{\nconst vec4 bit_shift=vec4(1.0/(255.0*255.0*255.0),1.0/(255.0*255.0),1.0/255.0,1.0);\nreturn dot(color,bit_shift);\n}\n#if defined(POINTLIGHT0) || defined(POINTLIGHT1) || defined(POINTLIGHT2) || defined(POINTLIGHT3)\nfloat computeShadowCube(vec3 lightPosition,samplerCube shadowSampler,float darkness,float bias)\n{\nvec3 directionToLight=vPositionW-lightPosition;\nfloat depth=length(directionToLight);\ndepth=clamp(depth,0.,1.0);\ndirectionToLight=normalize(directionToLight);\ndirectionToLight.y =-directionToLight.y;\nfloat shadow=unpack(textureCube(shadowSampler,directionToLight))+bias;\nif (depth>shadow)\n{\nreturn darkness;\n}\nreturn 1.0;\n}\nfloat computeShadowWithPCFCube(vec3 lightPosition,samplerCube shadowSampler,float bias,float darkness,float mapSize)\n{\nvec3 directionToLight=vPositionW-lightPosition;\nfloat depth=length(directionToLight);\ndepth=clamp(depth,0.,1.0);\nfloat diskScale=2.0/mapSize;\ndirectionToLight=normalize(directionToLight);\ndirectionToLight.y=-directionToLight.y;\nfloat visibility=1.;\nvec3 poissonDisk[4];\npoissonDisk[0]=vec3(-0.094201624,0.04,-0.039906216);\npoissonDisk[1]=vec3(0.094558609,-0.04,-0.076890725);\npoissonDisk[2]=vec3(-0.094184101,0.01,-0.092938870);\npoissonDisk[3]=vec3(0.034495938,-0.01,0.029387760);\n\nfloat biasedDepth=depth-bias;\nif (unpack(textureCube(shadowSampler,directionToLight+poissonDisk[0]))<biasedDepth) visibility-=0.25;\nif (unpack(textureCube(shadowSampler,directionToLight+poissonDisk[1]))<biasedDepth) visibility-=0.25;\nif (unpack(textureCube(shadowSampler,directionToLight+poissonDisk[2]))<biasedDepth) visibility-=0.25;\nif (unpack(textureCube(shadowSampler,directionToLight+poissonDisk[3]))<biasedDepth) visibility-=0.25;\nreturn min(1.0,visibility+darkness);\n}\n#endif\n#if defined(SPOTLIGHT0) || defined(SPOTLIGHT1) || defined(SPOTLIGHT2) || defined(SPOTLIGHT3) || defined(DIRLIGHT0) || defined(DIRLIGHT1) || defined(DIRLIGHT2) || defined(DIRLIGHT3)\nfloat computeShadow(vec4 vPositionFromLight,sampler2D shadowSampler,float darkness,float bias)\n{\nvec3 depth=vPositionFromLight.xyz/vPositionFromLight.w;\ndepth=0.5*depth+vec3(0.5);\nvec2 uv=depth.xy;\nif (uv.x<0. || uv.x>1.0 || uv.y<0. || uv.y>1.0)\n{\nreturn 1.0;\n}\nfloat shadow=unpack(texture2D(shadowSampler,uv))+bias;\nif (depth.z>shadow)\n{\nreturn darkness;\n}\nreturn 1.;\n}\nfloat computeShadowWithPCF(vec4 vPositionFromLight,sampler2D shadowSampler,float mapSize,float bias,float darkness)\n{\nvec3 depth=vPositionFromLight.xyz/vPositionFromLight.w;\ndepth=0.5*depth+vec3(0.5);\nvec2 uv=depth.xy;\nif (uv.x<0. || uv.x>1.0 || uv.y<0. || uv.y>1.0)\n{\nreturn 1.0;\n}\nfloat visibility=1.;\nvec2 poissonDisk[4];\npoissonDisk[0]=vec2(-0.94201624,-0.39906216);\npoissonDisk[1]=vec2(0.94558609,-0.76890725);\npoissonDisk[2]=vec2(-0.094184101,-0.92938870);\npoissonDisk[3]=vec2(0.34495938,0.29387760);\n\nfloat biasedDepth=depth.z-bias;\nif (unpack(texture2D(shadowSampler,uv+poissonDisk[0]/mapSize))<biasedDepth) visibility-=0.25;\nif (unpack(texture2D(shadowSampler,uv+poissonDisk[1]/mapSize))<biasedDepth) visibility-=0.25;\nif (unpack(texture2D(shadowSampler,uv+poissonDisk[2]/mapSize))<biasedDepth) visibility-=0.25;\nif (unpack(texture2D(shadowSampler,uv+poissonDisk[3]/mapSize))<biasedDepth) visibility-=0.25;\nreturn min(1.0,visibility+darkness);\n}\n\nfloat unpackHalf(vec2 color)\n{\nreturn color.x+(color.y/255.0);\n}\nfloat linstep(float low,float high,float v) {\nreturn clamp((v-low)/(high-low),0.0,1.0);\n}\nfloat ChebychevInequality(vec2 moments,float compare,float bias)\n{\nfloat p=smoothstep(compare-bias,compare,moments.x);\nfloat variance=max(moments.y-moments.x*moments.x,0.02);\nfloat d=compare-moments.x;\nfloat p_max=linstep(0.2,1.0,variance/(variance+d*d));\nreturn clamp(max(p,p_max),0.0,1.0);\n}\nfloat computeShadowWithVSM(vec4 vPositionFromLight,sampler2D shadowSampler,float bias,float darkness)\n{\nvec3 depth=vPositionFromLight.xyz/vPositionFromLight.w;\ndepth=0.5*depth+vec3(0.5);\nvec2 uv=depth.xy;\nif (uv.x<0. || uv.x>1.0 || uv.y<0. || uv.y>1.0 || depth.z>=1.0)\n{\nreturn 1.0;\n}\nvec4 texel=texture2D(shadowSampler,uv);\nvec2 moments=vec2(unpackHalf(texel.xy),unpackHalf(texel.zw));\nreturn min(1.0,1.0-ChebychevInequality(moments,depth.z,bias)+darkness);\n}\n#endif\n#endif\n#ifdef CLIPPLANE\nvarying float fClipDistance;\n#endif\n\n#ifdef FOG\n#define FOGMODE_NONE 0.\n#define FOGMODE_EXP 1.\n#define FOGMODE_EXP2 2.\n#define FOGMODE_LINEAR 3.\n#define E 2.71828\nuniform vec4 vFogInfos;\nuniform vec3 vFogColor;\nvarying float fFogDistance;\nfloat CalcFogFactor()\n{\nfloat fogCoeff=1.0;\nfloat fogStart=vFogInfos.y;\nfloat fogEnd=vFogInfos.z;\nfloat fogDensity=vFogInfos.w;\nif (FOGMODE_LINEAR == vFogInfos.x)\n{\nfogCoeff=(fogEnd-fFogDistance)/(fogEnd-fogStart);\n}\nelse if (FOGMODE_EXP == vFogInfos.x)\n{\nfogCoeff=1.0/pow(E,fFogDistance*fogDensity);\n}\nelse if (FOGMODE_EXP2 == vFogInfos.x)\n{\nfogCoeff=1.0/pow(E,fFogDistance*fFogDistance*fogDensity*fogDensity);\n}\nreturn clamp(fogCoeff,0.0,1.0);\n}\n#endif\n\nstruct lightingInfo\n{\nvec3 diffuse;\n#ifdef SPECULARTERM\nvec3 specular;\n#endif\n};\nlightingInfo computeLighting(vec3 viewDirectionW,vec3 vNormal,vec4 lightData,vec3 diffuseColor,vec3 specularColor,float range,float glossiness,vec3 bumpColor) {\nlightingInfo result;\nvec3 lightVectorW;\nfloat attenuation=1.0;\nif (lightData.w == 0.)\n{\nvec3 direction=lightData.xyz-vPositionW;\nattenuation=max(0.,1.0-length(direction)/range);\nlightVectorW=normalize(direction);\n}\nelse\n{\nlightVectorW=normalize(-lightData.xyz);\n}\n\nfloat ndl=max(0.,dot(vNormal,lightVectorW));\nresult.diffuse=ndl*diffuseColor*attenuation;\n\n#ifdef SPECULARTERM\nvec3 angleW=normalize(viewDirectionW+lightVectorW);\nvec3 perturbation=bumpHeight*(bumpColor.rgb-0.5);\nvec3 halfvec=normalize(angleW+lightVectorW+vec3(perturbation.x,perturbation.y,perturbation.z));\nfloat temp=max(0.,dot(vNormal,halfvec));\ntemp=pow(temp,max(1.,glossiness));\nresult.specular=temp*specularColor*attenuation;\n#endif\nreturn result;\n}\nlightingInfo computeSpotLighting(vec3 viewDirectionW,vec3 vNormal,vec4 lightData,vec4 lightDirection,vec3 specularColor,vec3 diffuseColor,float range,float glossiness,vec3 bumpColor) {\nlightingInfo result;\nvec3 direction=lightData.xyz-vPositionW;\nvec3 lightVectorW=normalize(direction);\nfloat attenuation=max(0.,1.0-length(direction)/range);\n\nfloat cosAngle=max(0.,dot(-lightDirection.xyz,lightVectorW));\nfloat spotAtten=0.0;\nif (cosAngle>=lightDirection.w)\n{\ncosAngle=max(0.,pow(cosAngle,lightData.w));\nspotAtten=clamp((cosAngle-lightDirection.w)/(1.-cosAngle),0.0,1.0);\n\nfloat ndl=max(0.,dot(vNormal,-lightDirection.xyz));\nresult.diffuse=ndl*spotAtten*diffuseColor*attenuation;\n\n#ifdef SPECULARTERM \nvec3 angleW=normalize(viewDirectionW-lightDirection.xyz);\nvec3 perturbation=bumpHeight*(bumpColor.rgb-0.5);\nvec3 halfvec=normalize(angleW+vec3(perturbation.x,perturbation.y,perturbation.z));\nfloat temp=max(0.,dot(vNormal,halfvec));\ntemp=pow(temp,max(1.,glossiness));\nresult.specular=specularColor*temp*spotAtten*attenuation;\n#endif\nreturn result;\n}\nresult.diffuse=vec3(0.);\n#ifdef SPECULARTERM\nresult.specular=vec3(0.);\n#endif\nreturn result;\n}\nlightingInfo computeHemisphericLighting(vec3 viewDirectionW,vec3 vNormal,vec4 lightData,vec3 diffuseColor,vec3 specularColor,vec3 groundColor,float glossiness,vec3 bumpColor) {\nlightingInfo result;\n\nfloat ndl=dot(vNormal,lightData.xyz)*0.5+0.5;\nresult.diffuse=mix(groundColor,diffuseColor,ndl);\n\n#ifdef SPECULARTERM\nvec3 angleW=normalize(viewDirectionW+lightData.xyz);\nvec3 perturbation=bumpHeight*(bumpColor.rgb-0.5);\nvec3 halfvec=normalize(angleW+vec3(perturbation.x,perturbation.y,perturbation.z));\nfloat temp=max(0.0,dot(vNormal,halfvec));\ntemp=pow(temp,max(1.0,glossiness));\nresult.specular=temp*specularColor;\n#endif\nreturn result;\n}\nvoid main(void) {\n\n#ifdef CLIPPLANE\nif (fClipDistance>0.0)\ndiscard;\n#endif\nvec3 viewDirectionW=normalize(vEyePosition-vPositionW);\n\nvec4 baseColor=vec4(1.,1.,1.,1.);\nvec3 diffuseColor=vDiffuseColor.rgb;\n#ifdef SPECULARTERM\nfloat glossiness=vSpecularColor.a;\nvec3 specularColor=vSpecularColor.rgb;\n#else\nfloat glossiness=0.;\n#endif\n\nfloat alpha=vDiffuseColor.a;\n#ifdef BUMP\nbaseColor=texture2D(normalSampler,vNormalUV);\nvec3 bumpColor=baseColor.rgb;\n#ifdef ALPHATEST\nif (baseColor.a<0.4)\ndiscard;\n#endif\nbaseColor.rgb*=vNormalInfos.y;\n#else\nvec3 bumpColor=vec3(1.0);\n#endif\n#ifdef VERTEXCOLOR\nbaseColor.rgb*=vColor.rgb;\n#endif\n\n#ifdef NORMAL\nvec3 normalW=normalize(vNormalW);\nvec2 perturbation=bumpHeight*(baseColor.rg-0.5);\n#else\nvec3 normalW=vec3(1.0,1.0,1.0);\nvec2 perturbation=bumpHeight*(vec2(1.0,1.0)-0.5);\n#endif\n#ifdef REFLECTION\n\nvec3 eyeVector=normalize(vEyePosition-vPosition);\nvec2 projectedRefractionTexCoords=clamp(vRefractionMapTexCoord.xy/vRefractionMapTexCoord.z+perturbation,0.0,1.0);\nvec4 refractiveColor=texture2D(refractionSampler,projectedRefractionTexCoords);\nvec2 projectedReflectionTexCoords=clamp(vReflectionMapTexCoord.xy/vReflectionMapTexCoord.z+perturbation,0.0,1.0);\nvec4 reflectiveColor=texture2D(reflectionSampler,projectedReflectionTexCoords);\nvec3 upVector=vec3(0.0,1.0,0.0);\nfloat fresnelTerm=max(dot(eyeVector,upVector),0.0);\nvec4 combinedColor=refractiveColor*fresnelTerm+reflectiveColor*(1.0-fresnelTerm);\nbaseColor=colorBlendFactor*waterColor+(1.0-colorBlendFactor)*combinedColor;\n#endif\n\nvec3 diffuseBase=vec3(0.,0.,0.);\n#ifdef SPECULARTERM\nvec3 specularBase=vec3(0.,0.,0.);\n#endif\nfloat shadow=1.;\n#ifdef LIGHT0\n#ifndef SPECULARTERM\nvec3 vLightSpecular0=vec3(0.0);\n#endif\n#ifdef SPOTLIGHT0\nlightingInfo info=computeSpotLighting(viewDirectionW,normalW,vLightData0,vLightDirection0,vLightDiffuse0.rgb,vLightSpecular0,vLightDiffuse0.a,glossiness,bumpColor);\n#endif\n#ifdef HEMILIGHT0\nlightingInfo info=computeHemisphericLighting(viewDirectionW,normalW,vLightData0,vLightDiffuse0.rgb,vLightSpecular0,vLightGround0,glossiness,bumpColor);\n#endif\n#if defined(POINTLIGHT0) || defined(DIRLIGHT0)\nlightingInfo info=computeLighting(viewDirectionW,normalW,vLightData0,vLightDiffuse0.rgb,vLightSpecular0,vLightDiffuse0.a,glossiness,bumpColor);\n#endif\n#ifdef SHADOW0\n#ifdef SHADOWVSM0\nshadow=computeShadowWithVSM(vPositionFromLight0,shadowSampler0,shadowsInfo0.z,shadowsInfo0.x);\n#else\n#ifdef SHADOWPCF0\n#if defined(POINTLIGHT0)\nshadow=computeShadowWithPCFCube(vLightData0.xyz,shadowSampler0,shadowsInfo0.z,shadowsInfo0.x,shadowsInfo0.y);\n#else\nshadow=computeShadowWithPCF(vPositionFromLight0,shadowSampler0,shadowsInfo0.y,shadowsInfo0.z,shadowsInfo0.x);\n#endif\n#else\n#if defined(POINTLIGHT0)\nshadow=computeShadowCube(vLightData0.xyz,shadowSampler0,shadowsInfo0.x,shadowsInfo0.z);\n#else\nshadow=computeShadow(vPositionFromLight0,shadowSampler0,shadowsInfo0.x,shadowsInfo0.z);\n#endif\n#endif\n#endif\n#else\nshadow=1.;\n#endif\ndiffuseBase+=info.diffuse*shadow;\n#ifdef SPECULARTERM\nspecularBase+=info.specular*shadow;\n#endif\n#endif\n#ifdef LIGHT1\n#ifndef SPECULARTERM\nvec3 vLightSpecular1=vec3(0.0);\n#endif\n#ifdef SPOTLIGHT1\ninfo=computeSpotLighting(viewDirectionW,normalW,vLightData1,vLightDirection1,vLightDiffuse1.rgb,vLightSpecular1,vLightDiffuse1.a,glossiness,bumpColor);\n#endif\n#ifdef HEMILIGHT1\ninfo=computeHemisphericLighting(viewDirectionW,normalW,vLightData1,vLightDiffuse1.rgb,vLightSpecular1,vLightGround1.a,glossiness,bumpColor);\n#endif\n#if defined(POINTLIGHT1) || defined(DIRLIGHT1)\ninfo=computeLighting(viewDirectionW,normalW,vLightData1,vLightDiffuse1.rgb,vLightSpecular1,vLightDiffuse1.a,glossiness,bumpColor);\n#endif\n#ifdef SHADOW1\n#ifdef SHADOWVSM1\nshadow=computeShadowWithVSM(vPositionFromLight1,shadowSampler1,shadowsInfo1.z,shadowsInfo1.x);\n#else\n#ifdef SHADOWPCF1\n#if defined(POINTLIGHT1)\nshadow=computeShadowWithPCFCube(vLightData1.xyz,shadowSampler1,shadowsInfo1.z,shadowsInfo1.x,shadowsInfo1.y);\n#else\nshadow=computeShadowWithPCF(vPositionFromLight1,shadowSampler1,shadowsInfo1.y,shadowsInfo1.z,shadowsInfo1.x);\n#endif\n#else\n#if defined(POINTLIGHT1)\nshadow=computeShadowCube(vLightData1.xyz,shadowSampler1,shadowsInfo1.x,shadowsInfo1.z);\n#else\nshadow=computeShadow(vPositionFromLight1,shadowSampler1,shadowsInfo1.x,shadowsInfo1.z);\n#endif\n#endif\n#endif\n#else\nshadow=1.;\n#endif\ndiffuseBase+=info.diffuse*shadow;\n#ifdef SPECULARTERM\nspecularBase+=info.specular*shadow;\n#endif\n#endif\n#ifdef LIGHT2\n#ifndef SPECULARTERM\nvec3 vLightSpecular2=vec3(0.0);\n#endif\n#ifdef SPOTLIGHT2\ninfo=computeSpotLighting(viewDirectionW,normalW,vLightData2,vLightDirection2,vLightDiffuse2.rgb,vLightSpecular2,vLightDiffuse2.a,glossiness,bumpColor);\n#endif\n#ifdef HEMILIGHT2\ninfo=computeHemisphericLighting(viewDirectionW,normalW,vLightData2,vLightDiffuse2.rgb,vLightSpecular2,vLightGround2,glossiness,bumpColor);\n#endif\n#if defined(POINTLIGHT2) || defined(DIRLIGHT2)\ninfo=computeLighting(viewDirectionW,normalW,vLightData2,vLightDiffuse2.rgb,vLightSpecular2,vLightDiffuse2.a,glossiness,bumpColor);\n#endif\n#ifdef SHADOW2\n#ifdef SHADOWVSM2\nshadow=computeShadowWithVSM(vPositionFromLight2,shadowSampler2,shadowsInfo2.z,shadowsInfo2.x);\n#else\n#ifdef SHADOWPCF2\n#if defined(POINTLIGHT2)\nshadow=computeShadowWithPCFCube(vLightData2.xyz,shadowSampler2,shadowsInfo2.z,shadowsInfo2.x,shadowsInfo2.y);\n#else\nshadow=computeShadowWithPCF(vPositionFromLight2,shadowSampler2,shadowsInfo2.y,shadowsInfo2.z,shadowsInfo2.x);\n#endif\n#else\n#if defined(POINTLIGHT2)\nshadow=computeShadowCube(vLightData2.xyz,shadowSampler2,shadowsInfo2.x,shadowsInfo2.z);\n#else\nshadow=computeShadow(vPositionFromLight2,shadowSampler2,shadowsInfo2.x,shadowsInfo2.z);\n#endif\n#endif \n#endif \n#else\nshadow=1.;\n#endif\ndiffuseBase+=info.diffuse*shadow;\n#ifdef SPECULARTERM\nspecularBase+=info.specular*shadow;\n#endif\n#endif\n#ifdef LIGHT3\n#ifndef SPECULARTERM\nvec3 vLightSpecular3=vec3(0.0);\n#endif\n#ifdef SPOTLIGHT3\ninfo=computeSpotLighting(viewDirectionW,normalW,vLightData3,vLightDirection3,vLightDiffuse3.rgb,vLightSpecular3,vLightDiffuse3.a,glossiness,bumpColor);\n#endif\n#ifdef HEMILIGHT3\ninfo=computeHemisphericLighting(viewDirectionW,normalW,vLightData3,vLightDiffuse3.rgb,vLightSpecular3,vLightGround3,glossiness,bumpColor);\n#endif\n#if defined(POINTLIGHT3) || defined(DIRLIGHT3)\ninfo=computeLighting(viewDirectionW,normalW,vLightData3,vLightDiffuse3.rgb,vLightSpecular3,vLightDiffuse3.a,glossiness,bumpColor);\n#endif\n#ifdef SHADOW3\n#ifdef SHADOWVSM3\nshadow=computeShadowWithVSM(vPositionFromLight3,shadowSampler3,shadowsInfo3.z,shadowsInfo3.x);\n#else\n#ifdef SHADOWPCF3\n#if defined(POINTLIGHT3)\nshadow=computeShadowWithPCFCube(vLightData3.xyz,shadowSampler3,shadowsInfo3.z,shadowsInfo3.x,shadowsInfo3.y);\n#else\nshadow=computeShadowWithPCF(vPositionFromLight3,shadowSampler3,shadowsInfo3.y,shadowsInfo3.z,shadowsInfo3.x);\n#endif\n#else\n#if defined(POINTLIGHT3)\nshadow=computeShadowCube(vLightData3.xyz,shadowSampler3,shadowsInfo3.x,shadowsInfo3.z);\n#else\nshadow=computeShadow(vPositionFromLight3,shadowSampler3,shadowsInfo3.x,shadowsInfo3.z);\n#endif\n#endif \n#endif \n#else\nshadow=1.;\n#endif\ndiffuseBase+=info.diffuse*shadow;\n#ifdef SPECULARTERM\nspecularBase+=info.specular*shadow;\n#endif\n#endif\n#ifdef VERTEXALPHA\nalpha*=vColor.a;\n#endif\n#ifdef SPECULARTERM\nvec3 finalSpecular=specularBase*specularColor;\n#else\nvec3 finalSpecular=vec3(0.0);\n#endif\nvec3 finalDiffuse=clamp(diffuseBase*diffuseColor,0.0,1.0)*baseColor.rgb;\n\nvec4 color=vec4(finalDiffuse+finalSpecular,alpha);\n#ifdef FOG\nfloat fog=CalcFogFactor();\ncolor.rgb=fog*color.rgb+(1.0-fog)*vFogColor;\n#endif\ngl_FragColor=color;\n}";
	
	static var vertexShader:String = "precision highp float;\n\nattribute vec3 position;\n#ifdef NORMAL\nattribute vec3 normal;\n#endif\n#ifdef UV1\nattribute vec2 uv;\n#endif\n#ifdef UV2\nattribute vec2 uv2;\n#endif\n#ifdef VERTEXCOLOR\nattribute vec4 color;\n#endif\n#ifdef BONES\nattribute vec4 matricesIndices;\nattribute vec4 matricesWeights;\n#endif\n\n#ifdef INSTANCES\nattribute vec4 world0;\nattribute vec4 world1;\nattribute vec4 world2;\nattribute vec4 world3;\n#else\nuniform mat4 world;\n#endif\nuniform mat4 view;\nuniform mat4 viewProjection;\n#ifdef BUMP\nvarying vec2 vNormalUV;\nuniform mat4 normalMatrix;\nuniform vec2 vNormalInfos;\n#endif\n#ifdef BONES\nuniform mat4 mBones[BonesPerMesh];\n#endif\n#ifdef POINTSIZE\nuniform float pointSize;\n#endif\n\nvarying vec3 vPositionW;\n#ifdef NORMAL\nvarying vec3 vNormalW;\n#endif\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n#ifdef CLIPPLANE\nuniform vec4 vClipPlane;\nvarying float fClipDistance;\n#endif\n#ifdef FOG\nvarying float fFogDistance;\n#endif\n#ifdef SHADOWS\n#if defined(SPOTLIGHT0) || defined(DIRLIGHT0)\nuniform mat4 lightMatrix0;\nvarying vec4 vPositionFromLight0;\n#endif\n#if defined(SPOTLIGHT1) || defined(DIRLIGHT1)\nuniform mat4 lightMatrix1;\nvarying vec4 vPositionFromLight1;\n#endif\n#if defined(SPOTLIGHT2) || defined(DIRLIGHT2)\nuniform mat4 lightMatrix2;\nvarying vec4 vPositionFromLight2;\n#endif\n#if defined(SPOTLIGHT3) || defined(DIRLIGHT3)\nuniform mat4 lightMatrix3;\nvarying vec4 vPositionFromLight3;\n#endif\n#endif\n\nuniform mat4 worldReflectionViewProjection;\nuniform vec2 windDirection;\nuniform float waveLength;\nuniform float time;\nuniform float windForce;\nuniform float waveHeight;\nuniform float waveSpeed;\n\nvarying vec3 vPosition;\nvarying vec3 vRefractionMapTexCoord;\nvarying vec3 vReflectionMapTexCoord;\nvoid main(void) {\nmat4 finalWorld;\n#ifdef INSTANCES\nfinalWorld=mat4(world0,world1,world2,world3);\n#else\nfinalWorld=world;\n#endif\n#ifdef BONES\nmat4 m0=mBones[int(matricesIndices.x)]*matricesWeights.x;\nmat4 m1=mBones[int(matricesIndices.y)]*matricesWeights.y;\nmat4 m2=mBones[int(matricesIndices.z)]*matricesWeights.z;\n#ifdef BONES4\nmat4 m3=mBones[int(matricesIndices.w)]*matricesWeights.w;\nfinalWorld=finalWorld*(m0+m1+m2+m3);\n#else\nfinalWorld=finalWorld*(m0+m1+m2);\n#endif \n#endif\nvec4 worldPos=finalWorld*vec4(position,1.0);\nvPositionW=vec3(worldPos);\n#ifdef NORMAL\nvNormalW=normalize(vec3(finalWorld*vec4(normal,0.0)));\n#endif\n\n#ifndef UV1\nvec2 uv=vec2(0.,0.);\n#endif\n#ifndef UV2\nvec2 uv2=vec2(0.,0.);\n#endif\n#ifdef BUMP\nif (vNormalInfos.x == 0.)\n{\nvNormalUV=vec2(normalMatrix*vec4((uv*1.0)/waveLength+time*windForce*windDirection,1.0,0.0));\n}\nelse\n{\nvNormalUV=vec2(normalMatrix*vec4((uv2*1.0)/waveLength+time*windForce*windDirection,1.0,0.0));\n}\n#endif\n\n#ifdef CLIPPLANE\nfClipDistance=dot(worldPos,vClipPlane);\n#endif\n\n#ifdef FOG\nfFogDistance=(view*worldPos).z;\n#endif\n\n#ifdef SHADOWS\n#if defined(SPOTLIGHT0) || defined(DIRLIGHT0)\nvPositionFromLight0=lightMatrix0*worldPos;\n#endif\n#if defined(SPOTLIGHT1) || defined(DIRLIGHT1)\nvPositionFromLight1=lightMatrix1*worldPos;\n#endif\n#if defined(SPOTLIGHT2) || defined(DIRLIGHT2)\nvPositionFromLight2=lightMatrix2*worldPos;\n#endif\n#if defined(SPOTLIGHT3) || defined(DIRLIGHT3)\nvPositionFromLight3=lightMatrix3*worldPos;\n#endif\n#endif\n\n#ifdef VERTEXCOLOR\nvColor=color;\n#endif\n\n#ifdef POINTSIZE\ngl_PointSize=pointSize;\n#endif\nvec3 p=position;\nfloat newY=(sin(((p.x/0.05)+time*waveSpeed))*waveHeight*windDirection.x*5.0)\n+(cos(((p.z/0.05)+time*waveSpeed))*waveHeight*windDirection.y*5.0);\np.y+=abs(newY);\ngl_Position=viewProjection*finalWorld*vec4(p,1.0);\n#ifdef REFLECTION\nworldPos=viewProjection*finalWorld*vec4(p,1.0);\n\nvPosition=position;\nvRefractionMapTexCoord.x=0.5*(worldPos.w+worldPos.x);\nvRefractionMapTexCoord.y=0.5*(worldPos.w+worldPos.y);\nvRefractionMapTexCoord.z=worldPos.w;\nworldPos=worldReflectionViewProjection*vec4(position,1.0);\nvReflectionMapTexCoord.x=0.5*(worldPos.w+worldPos.x);\nvReflectionMapTexCoord.y=0.5*(worldPos.w+worldPos.y);\nvReflectionMapTexCoord.z=worldPos.w;\n#endif\n}\n";
	
	/*
	* Public members
	*/
	public var bumpTexture:BaseTexture;
	public var diffuseColor:Color3 = new Color3(1, 1, 1);
	public var specularColor:Color3 = new Color3(0, 0, 0);
	public var specularPower:Int = 64;
	public var disableLighting:Bool = false;
	
	/**
	* @param {number}: Represents the wind force
	*/
	public var windForce:Float = 6;
	/**
	* @param {Vector2}: The direction of the wind in the plane (X, Z)
	*/
	public var windDirection:Vector2 = new Vector2(0, 1);
	/**
	* @param {number}: Wave height, represents the height of the waves
	*/
	public var waveHeight:Float = 0.4;
	/**
	* @param {number}: Bump height, represents the bump height related to the bump map
	*/
	public var bumpHeight:Float = 0.4;
	/**
	* @param {number}: The water color blended with the reflection and refraction samplers
	*/
	public var waterColor:Color3 = new Color3(0.1, 0.1, 0.6);
	/**
	* @param {number}: The blend factor related to the water color
	*/
	public var colorBlendFactor:Float = 0.2;
	/**
	* @param {number}: Represents the maximum length of a wave
	*/
	public var waveLength:Float = 0.1;
	
	public var renderTargetSize:Vector2;
	
	/**
    * @param {number}: Defines the waves speed
	*/
    public var waveSpeed:Float = 1.0;
	
	public var refractionTexture(get, never):RenderTargetTexture;
	public var reflectionTexture(get, never):RenderTargetTexture;
	
	/*
	* Private members
	*/	
	private var _mesh:Mesh;
	
	private var _refractionRTT:RenderTargetTexture;
	private var _reflectionRTT:RenderTargetTexture;
	
	private var _material:ShaderMaterial;
	
	private var _reflectionTransform:Matrix = Matrix.Zero();
	private var _lastTime:Float = 0;
	
	private var _scaledDiffuse:Color3 = new Color3();
	private var _scaledSpecular:Color3 = new Color3();
	private var _renderId:Int;

	private var _defines:WaterMaterialDefines = new WaterMaterialDefines();
	private var _cachedDefines:WaterMaterialDefines = new WaterMaterialDefines();
	

	public function new(name:String, scene:Scene, sourceMesh:Mesh = null, ?renderTargetSize:Vector2) {
		super(name, scene);
		
		if (!ShadersStore.Shaders.exists("watermat.fragment")) {
			ShadersStore.Shaders.set("watermat.fragment", fragmentShader);
			ShadersStore.Shaders.set("watermat.vertex", vertexShader);
		}
		
		if (renderTargetSize == null) {
			renderTargetSize = new Vector2(512, 512);
		}
		
		this.renderTargetSize = renderTargetSize;
		
		this._cachedDefines.BonesPerMesh = -1;
				
		// Create render targets
		this._createRenderTargets(scene, renderTargetSize);
	}
	
	private function get_refractionTexture():RenderTargetTexture {
		return _refractionRTT;
	}
	
	private function get_reflectionTexture():RenderTargetTexture {
		return _reflectionRTT;
	}
	
	// Methods
	public function addToRenderList(node:AbstractMesh) {
		this._refractionRTT.renderList.push(node);
		this._reflectionRTT.renderList.push(node);
	}
	
	public function enableRenderTargets(enable:Bool) {
		var refreshRate = enable ? 1 : 0;
		
		this._refractionRTT.refreshRate = refreshRate;
		this._reflectionRTT.refreshRate = refreshRate;
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
	 
	private function _checkCache(scene:Scene, ?mesh:AbstractMesh, useInstances:Bool = false):Bool {
		if (mesh == null) {
			return true;
		}
		
		if (this._defines.defines[WMD.INSTANCES] != useInstances) {
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
		
		this._mesh = cast mesh;
		
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
			if (this.bumpTexture != null && StandardMaterial.BumpTextureEnabled) {
				if (!this.bumpTexture.isReady()) {
					return false;
				} 
				else {
					needUVs = true;
					this._defines.defines[WMD.BUMP] = true;
				}
			}
			
			if (StandardMaterial.ReflectionTextureEnabled) {
				this._defines.defines[WMD.REFLECTION] = true;
			}
		}
		
		// Effect
		if (scene.clipPlane != null) {
			this._defines.defines[WMD.CLIPPLANE] = true;
		}
		
		if (engine.getAlphaTesting()) {
			this._defines.defines[WMD.ALPHATEST] = true;
		}
		
		// Point size
		if (this.pointsCloud || scene.forcePointsCloud) {
			this._defines.defines[WMD.POINTSIZE] = true;
		}
		
		// Fog
		if (scene.fogEnabled && mesh != null && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE && this.fogEnabled) {
			this._defines.defines[WMD.FOG] = true;
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
				this._defines.defines[WMD.LIGHT0 + lightIndex] = true;
				
				var type:Int = this._defines.getLight(light.type, lightIndex);
				this._defines.defines[type] = true;
				
				// Specular
                if (!light.specular.equalsFloats(0, 0, 0)) {
                    this._defines.defines[WMD.SPECULARTERM] = true;
                }
				
				// Shadows
				if (scene.shadowsEnabled) {
					var shadowGenerator = light.getShadowGenerator();
					if (mesh != null && mesh.receiveShadows && shadowGenerator != null) {
						this._defines.defines[WMD.SHADOW0 + lightIndex] = true;
						
						this._defines.defines[WMD.SHADOWS] = true;
						
						if (shadowGenerator.useVarianceShadowMap || shadowGenerator.useBlurVarianceShadowMap) {
							this._defines.defines[WMD.SHADOWVSM0 + lightIndex] = true;
						}
						
						if (shadowGenerator.usePoissonSampling) {
							this._defines.defines[WMD.SHADOWPCF0 + lightIndex] = true;
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
				this._defines.defines[WMD.NORMAL] = true;
			}
			if (needUVs) {
				if (mesh.isVerticesDataPresent(VertexBuffer.UVKind)) {
					this._defines.defines[WMD.UV1] = true;
				}
				if (mesh.isVerticesDataPresent(VertexBuffer.UV2Kind)) {
					this._defines.defines[WMD.UV2] = true;
				}
			}
			if (mesh.useVertexColors && mesh.isVerticesDataPresent(VertexBuffer.ColorKind)) {
				this._defines.defines[WMD.VERTEXCOLOR] = true;
				
				if (mesh.hasVertexAlpha) {
					this._defines.defines[WMD.VERTEXALPHA] = true;
				}
			}
			if (mesh.useBones && mesh.computeBonesUsingShaders) {
				this._defines.NUM_BONE_INFLUENCERS = mesh.numBoneInfluencers;
				this._defines.BonesPerMesh = mesh.skeleton.bones.length + 1;
			}
			
			// Instances
			if (useInstances) {
				this._defines.defines[WMD.INSTANCES] = true;
			}
		}
		
		// Get correct effect      
		if (!this._defines.isEqual(this._cachedDefines) || this._effect == null) {
			this._defines.cloneTo(this._cachedDefines);
			
			scene.resetCachedMaterial();
			
			// Fallbacks
			var fallbacks:EffectFallbacks = new EffectFallbacks();             
			if (this._defines.defines[WMD.FOG]) {
				fallbacks.addFallback(1, "FOG");
			}
			
			for (lightIndex in 0...Material.maxSimultaneousLights) {
				if (!this._defines.defines[WMD.LIGHT0 + lightIndex]) {
					continue;
				}
				
				if (lightIndex > 0) {
					fallbacks.addFallback(lightIndex, "LIGHT" + lightIndex);
				}
				
				if (this._defines.defines[WMD.SHADOW0 + lightIndex]) {
					fallbacks.addFallback(0, "SHADOW" + lightIndex);
				}
				
				if (this._defines.defines[WMD.SHADOWPCF0 + lightIndex]) {
					fallbacks.addFallback(0, "SHADOWPCF" + lightIndex);
				}
				
				if (this._defines.defines[WMD.SHADOWVSM0 + lightIndex]) {
					fallbacks.addFallback(0, "SHADOWVSM" + lightIndex);
				}
			}
		 
			if (this._defines.NUM_BONE_INFLUENCERS > 0){
                fallbacks.addCPUSkinningFallback(0, mesh);    
            }
			
			//Attributes
			var attribs:Array<String> = [VertexBuffer.PositionKind];
			
			if (this._defines.defines[WMD.NORMAL]) {
				attribs.push(VertexBuffer.NormalKind);
			}
			
			if (this._defines.defines[WMD.UV1]) {
				attribs.push(VertexBuffer.UVKind);
			}
			
			if (this._defines.defines[WMD.UV2]) {
				attribs.push(VertexBuffer.UV2Kind);
			}
			
			if (this._defines.defines[WMD.VERTEXCOLOR]) {
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
			
			if (this._defines.defines[WMD.INSTANCES]) {
				attribs.push("world0");
				attribs.push("world1");
				attribs.push("world2");
				attribs.push("world3");
			}
			
			// Legacy browser patch
			var shaderName:String = "watermat";
			var join = this._defines.toString();
			
			this._effect = scene.getEngine().createEffect(shaderName,
				attribs,
				["world", "view", "viewProjection", "vEyePosition", "vLightsType", "vDiffuseColor", "vSpecularColor",
					"vLightData0", "vLightDiffuse0", "vLightSpecular0", "vLightDirection0", "vLightGround0", "lightMatrix0",
					"vLightData1", "vLightDiffuse1", "vLightSpecular1", "vLightDirection1", "vLightGround1", "lightMatrix1",
					"vLightData2", "vLightDiffuse2", "vLightSpecular2", "vLightDirection2", "vLightGround2", "lightMatrix2",
					"vLightData3", "vLightDiffuse3", "vLightSpecular3", "vLightDirection3", "vLightGround3", "lightMatrix3",
					"vFogInfos", "vFogColor", "pointSize",
					"vNormalInfos", 
					"mBones",
					"vClipPlane", "normalMatrix",
					"shadowsInfo0", "shadowsInfo1", "shadowsInfo2", "shadowsInfo3",
					// Water
					"worldReflectionViewProjection", "windDirection", "waveLength", "time", "windForce",
					"cameraPosition", "bumpHeight", "waveHeight", "waterColor", "colorBlendFactor", "waveSpeed"
				],
				["normalSampler",
					"shadowSampler0", "shadowSampler1", "shadowSampler2", "shadowSampler3",
					// Water
					"refractionSampler", "reflectionSampler"
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
				mesh._materialDefines = new WaterMaterialDefines();
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
			this._effect.setMatrices("mBones", mesh.skeleton.getTransformMatrices(mesh));
		}
		
		if (scene.getCachedMaterial() != this) {
			// Textures        
			if (this.bumpTexture != null && StandardMaterial.BumpTextureEnabled) {
				this._effect.setTexture("normalSampler", this.bumpTexture);
				
				this._effect.setFloat2("vNormalInfos", this.bumpTexture.coordinatesIndex, this.bumpTexture.level);
				this._effect.setMatrix("normalMatrix", this.bumpTexture.getTextureMatrix());
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
		
		if (this._defines.defines[WMD.SPECULARTERM]) {
            this._effect.setColor4("vSpecularColor", this.specularColor, this.specularPower);
        }
		
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
				
				if (this._defines.defines[WMD.SPECULARTERM]) {
                    light.specular.scaleToRef(light.intensity, this._scaledSpecular);
                    this._effect.setColor3("vLightSpecular" + lightIndex, this._scaledSpecular);
                }
				
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
		
		// View and Fog
		if (scene.fogEnabled && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE) {
			this._effect.setMatrix("view", scene.getViewMatrix());
			
			this._effect.setFloat4("vFogInfos", scene.fogMode, scene.fogStart, scene.fogEnd, scene.fogDensity);
			this._effect.setColor3("vFogColor", scene.fogColor);
		}
		
		// Water
		if (StandardMaterial.ReflectionTextureEnabled) {
			this._effect.setTexture("refractionSampler", this._refractionRTT);
			this._effect.setTexture("reflectionSampler", this._reflectionRTT);
		}
		
		var wrvp = this._mesh.getWorldMatrix().multiply(this._reflectionTransform).multiply(scene.getProjectionMatrix());
		this._lastTime += scene.getEngine().getDeltaTime();
		
		this._effect.setMatrix("worldReflectionViewProjection", wrvp);
		this._effect.setVector2("windDirection", this.windDirection);
		this._effect.setFloat("waveLength", this.waveLength);
		this._effect.setFloat("time", this._lastTime / 100000);
		this._effect.setFloat("windForce", this.windForce);
		this._effect.setFloat("waveHeight", this.waveHeight);
		this._effect.setFloat("bumpHeight", this.bumpHeight);
		this._effect.setColor4("waterColor", this.waterColor, 1.0);
		this._effect.setFloat("colorBlendFactor", this.colorBlendFactor);
		this._effect.setFloat("waveSpeed", this.waveSpeed);
		
		super.bind(world, mesh);
	}
	
	private function _createRenderTargets(scene:Scene, renderTargetSize:Vector2) {
		// Render targets
		this._refractionRTT = new RenderTargetTexture(name + "_refraction", { width: renderTargetSize.x, height: renderTargetSize.y }, scene, false, true);
		this._reflectionRTT = new RenderTargetTexture(name + "_reflection", { width: renderTargetSize.x, height: renderTargetSize.y }, scene, false, true);
		
		scene.customRenderTargets.push(this._refractionRTT);
		scene.customRenderTargets.push(this._reflectionRTT);
		
		var isVisible:Bool = true;
		var clipPlane:Plane = new Plane(0, 0, 0, 0);
		var savedViewMatrix:Matrix = null;
		var mirrorMatrix:Matrix = Matrix.Zero();
		
		this._refractionRTT.onBeforeRender = function(val:Int = 0) {
			if (this._mesh != null) {
				isVisible = this._mesh.isVisible;
				this._mesh.isVisible = false;
			}
			// Clip plane
			clipPlane = scene.clipPlane;
			
			var positiony = this._mesh != null ? this._mesh.position.y : 0.0;
			scene.clipPlane = Plane.FromPositionAndNormal(new Vector3(0, positiony + 0.05, 0), new Vector3(0, 1, 0));
		};
		
		this._refractionRTT.onAfterRender = function(val:Int = 0) {
			if (this._mesh != null) {
				this._mesh.isVisible = isVisible;
			}
			
			// Clip plane
			scene.clipPlane = clipPlane;
		};
		
		this._reflectionRTT.onBeforeRender = function(val:Int = 0) {
			if (this._mesh != null) {
				isVisible = this._mesh.isVisible;
				this._mesh.isVisible = false;
			}
			
			// Clip plane
			clipPlane = scene.clipPlane;
			
			var positiony = this._mesh != null ? this._mesh.position.y : 0.0;
			scene.clipPlane = Plane.FromPositionAndNormal(new Vector3(0, positiony - 0.05, 0), new Vector3(0, -1, 0));
			
			// Transform
			Matrix.ReflectionToRef(scene.clipPlane, mirrorMatrix);
			savedViewMatrix = scene.getViewMatrix();
			
			mirrorMatrix.multiplyToRef(savedViewMatrix, this._reflectionTransform);
			scene.setTransformMatrix(this._reflectionTransform, scene.getProjectionMatrix());
			scene.getEngine().cullBackFaces = false;
			scene._mirroredCameraPosition = Vector3.TransformCoordinates(scene.activeCamera.position, mirrorMatrix);
		};
		
		this._reflectionRTT.onAfterRender = function(val:Int = 0) {
			if (this._mesh != null) {
				this._mesh.isVisible = isVisible;
			}
			
			// Clip plane
			scene.clipPlane = clipPlane;
			
			// Transform
			scene.setTransformMatrix(savedViewMatrix, scene.getProjectionMatrix());
			scene.getEngine().cullBackFaces = true;
			scene._mirroredCameraPosition = null;
		};
	}
	
	public function getAnimatables():Array<IAnimatable> {
		var results:Array<IAnimatable> = [];
		
		if (this.bumpTexture != null && this.bumpTexture.animations != null && this.bumpTexture.animations.length > 0) {
			results.push(this.bumpTexture);
		}
		if (this._reflectionRTT != null && this._reflectionRTT.animations != null && this._reflectionRTT.animations.length > 0) {
			results.push(this._reflectionRTT);
		}
		if (this._refractionRTT != null && this._refractionRTT.animations != null && this._refractionRTT.animations.length > 0) {
			results.push(this._refractionRTT);
		}
		
		return results;
	}

	override public function dispose(forceDisposeEffect:Bool = false, forceDisposeTextures:Bool = true) {
		if (forceDisposeTextures) {
			if (this.bumpTexture != null) {
				this.bumpTexture.dispose();
			}
		}
		
		var index:Int = this.getScene().customRenderTargets.indexOf(this._refractionRTT);
		if (index != -1) {
			this.getScene().customRenderTargets.splice(index, 1);
		}
		index = -1;
		index = this.getScene().customRenderTargets.indexOf(this._reflectionRTT);
		if (index != -1) {
			this.getScene().customRenderTargets.splice(index, 1);
		}
		
		if (this._reflectionRTT != null) {
			this._reflectionRTT.dispose();
		}
		if (this._refractionRTT != null) {
			this._refractionRTT.dispose();
		}
		
		super.dispose(forceDisposeEffect);
	}

	override public function clone(name:String, cloneChildren:Bool = false):WaterMaterial {
		var newMaterial = new WaterMaterial(name, this.getScene());
		
		// Base material
		this.copyTo(newMaterial);
		
		// water material
		if (this.bumpTexture != null) {
			newMaterial.bumpTexture = this.bumpTexture.clone();
		}
		
		newMaterial.diffuseColor = this.diffuseColor.clone();
		
		return newMaterial;
	}
	
	override public function serialize():Dynamic {		        		
		var serializationObject = super.serialize();
		
		serializationObject.customType 			= "water";
		serializationObject.diffuseColor    	= this.diffuseColor.asArray();
		serializationObject.specularColor   	= this.specularColor.asArray();
		serializationObject.specularPower   	= this.specularPower;
		serializationObject.disableLighting 	= this.disableLighting;
		serializationObject.windForce     		= this.windForce;
		serializationObject.windDirection 		= this.windDirection.asArray();
		serializationObject.waveHeight      	= this.waveHeight;
		serializationObject.bumpHeight 			= this.bumpHeight;
		serializationObject.waterColor 			= this.waterColor.asArray();
		serializationObject.colorBlendFactor	= this.colorBlendFactor;
		serializationObject.waveLength 			= this.waveLength;
		serializationObject.renderTargetSize	= this.renderTargetSize.asArray();
		
		if (this.bumpTexture != null) {
			serializationObject.bumpTexture 	= this.bumpTexture.serialize();
		}
		
		return serializationObject;
	}

	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):WaterMaterial {		
		var renderTargetSize = source.renderTargetSize != null ? Vector2.FromArray(source.renderTargetSize) : null;
			
		var material = new WaterMaterial(source.name, scene, renderTargetSize);
		
		material.diffuseColor    	= Color3.FromArray(source.diffuseColor);
		material.specularColor   	= Color3.FromArray(source.specularColor);
		material.specularPower   	= source.specularPower;
		material.disableLighting 	= source.disableLighting;
		material.windForce     		= source.windForce;
		material.windDirection 		= Vector2.FromArray(source.windDirection);
		material.waveHeight      	= source.waveHeight;
		material.bumpHeight 		= source.bumpHeight;
		material.waterColor 		= Color3.FromArray(source.waterColor);
		material.colorBlendFactor	= source.colorBlendFactor;
		material.waveLength 		= source.waveLength;
		material.renderTargetSize	= Vector2.FromArray(source.renderTargetSize);
		
		material.alpha = source.alpha;
		
		material.id = source.id;
		
		Tags.AddTagsTo(material, source.tags);
		material.backFaceCulling = source.backFaceCulling;
		material.wireframe = source.wireframe;
		
		if (source.bumpTexture != null) {
			material.bumpTexture = Texture.Parse(source.bumpTexture, scene, rootUrl);
		}
		
		if (source.checkReadyOnlyOnce != null) {
			material.checkReadyOnlyOnce = source.checkReadyOnlyOnce;
		}
		
		return material;
	}
	
	public static function CreateDefaultMesh(name:String, scene:Scene):Mesh {
		var mesh = Mesh.CreateGround(name, 512, 512, 32, scene);
		
		return mesh;
	}
	
}
