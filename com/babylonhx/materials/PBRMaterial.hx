package com.babylonhx.materials;

import com.babylonhx.Engine;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.lights.IShadowLight;
import com.babylonhx.lights.Light;
import com.babylonhx.materials.EffectFallbacks;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.materials.textures.HDRCubeTexture;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.materials.textures.RefractionTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.SphericalPolynomial;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector4;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Matrix;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.tools.Tools;
import com.babylonhx.tools.Tags;
import com.babylonhx.tools.serialization.SerializationHelper;
import com.babylonhx.animations.IAnimatable;
import com.babylonhx.math.Tools in MathTools;


/**
 * ...
 * @author Krtolica Vujadin
 */

typedef PBRM = PBRMaterialDefines
 
class PBRMaterial extends Material {
	
	public static var fragmentShader:String = "#ifdef BUMP\n#extension GL_OES_standard_derivatives : enable\n#endif\n#ifdef LODBASEDMICROSFURACE\n#extension GL_EXT_shader_texture_lod : enable\n#endif\n#ifdef LOGARITHMICDEPTH\n#extension GL_EXT_frag_depth : enable\n#endif\nprecision highp float;\nuniform vec3 vEyePosition;\nuniform vec3 vAmbientColor;\nuniform vec3 vReflectionColor;\nuniform vec4 vAlbedoColor;\n\nuniform vec4 vLightingIntensity;\nuniform vec4 vCameraInfos;\n#ifdef OVERLOADEDVALUES\nuniform vec4 vOverloadedIntensity;\nuniform vec3 vOverloadedAmbient;\nuniform vec3 vOverloadedAlbedo;\nuniform vec3 vOverloadedReflectivity;\nuniform vec3 vOverloadedEmissive;\nuniform vec3 vOverloadedReflection;\nuniform vec3 vOverloadedMicroSurface;\n#endif\n#ifdef OVERLOADEDSHADOWVALUES\nuniform vec4 vOverloadedShadowIntensity;\n#endif\n#if defined(REFLECTION) || defined(REFRACTION)\nuniform vec2 vMicrosurfaceTextureLods;\n#endif\nuniform vec4 vReflectivityColor;\nuniform vec3 vEmissiveColor;\n\nvarying vec3 vPositionW;\n#ifdef NORMAL\nvarying vec3 vNormalW;\n#endif\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n\n#include<lightFragmentDeclaration>[0..maxSimultaneousLights]\n\n#ifdef ALBEDO\nvarying vec2 vAlbedoUV;\nuniform sampler2D albedoSampler;\nuniform vec2 vAlbedoInfos;\n#endif\n#ifdef AMBIENT\nvarying vec2 vAmbientUV;\nuniform sampler2D ambientSampler;\nuniform vec2 vAmbientInfos;\n#endif\n#ifdef OPACITY \nvarying vec2 vOpacityUV;\nuniform sampler2D opacitySampler;\nuniform vec2 vOpacityInfos;\n#endif\n#ifdef EMISSIVE\nvarying vec2 vEmissiveUV;\nuniform vec2 vEmissiveInfos;\nuniform sampler2D emissiveSampler;\n#endif\n#ifdef LIGHTMAP\nvarying vec2 vLightmapUV;\nuniform vec2 vLightmapInfos;\nuniform sampler2D lightmapSampler;\n#endif\n#if defined(REFLECTIVITY)\nvarying vec2 vReflectivityUV;\nuniform vec2 vReflectivityInfos;\nuniform sampler2D reflectivitySampler;\n#endif\n\n#include<fresnelFunction>\n#ifdef OPACITYFRESNEL\nuniform vec4 opacityParts;\n#endif\n#ifdef EMISSIVEFRESNEL\nuniform vec4 emissiveLeftColor;\nuniform vec4 emissiveRightColor;\n#endif\n\n#if defined(REFLECTIONMAP_SPHERICAL) || defined(REFLECTIONMAP_PROJECTION) || defined(REFRACTION)\nuniform mat4 view;\n#endif\n\n#ifdef REFRACTION\nuniform vec4 vRefractionInfos;\n#ifdef REFRACTIONMAP_3D\nuniform samplerCube refractionCubeSampler;\n#else\nuniform sampler2D refraction2DSampler;\nuniform mat4 refractionMatrix;\n#endif\n#endif\n\n#ifdef REFLECTION\nuniform vec2 vReflectionInfos;\n#ifdef REFLECTIONMAP_3D\nuniform samplerCube reflectionCubeSampler;\n#else\nuniform sampler2D reflection2DSampler;\n#endif\n#ifdef REFLECTIONMAP_SKYBOX\nvarying vec3 vPositionUVW;\n#else\n#ifdef REFLECTIONMAP_EQUIRECTANGULAR_FIXED\nvarying vec3 vDirectionW;\n#endif\n#if defined(REFLECTIONMAP_PLANAR) || defined(REFLECTIONMAP_CUBIC) || defined(REFLECTIONMAP_PROJECTION)\nuniform mat4 reflectionMatrix;\n#endif\n#endif\n#include<reflectionFunction>\n#endif\n#ifdef CAMERACOLORGRADING\nuniform sampler2D cameraColorGrading2DSampler;\nuniform vec4 vCameraColorGradingInfos;\nuniform vec4 vCameraColorGradingScaleOffset;\n#endif\n\n#include<pbrShadowFunctions>\n#include<pbrFunctions>\n#include<harmonicsFunctions>\n#include<pbrLightFunctions>\n#include<bumpFragmentFunctions>\n#include<clipPlaneFragmentDeclaration>\n#include<logDepthDeclaration>\n\n#include<fogFragmentDeclaration>\nvoid main(void) {\n#include<clipPlaneFragment>\nvec3 viewDirectionW=normalize(vEyePosition-vPositionW);\n\nvec4 surfaceAlbedo=vec4(1.,1.,1.,1.);\nvec3 surfaceAlbedoContribution=vAlbedoColor.rgb;\n\nfloat alpha=vAlbedoColor.a;\n#ifdef ALBEDO\nsurfaceAlbedo=texture2D(albedoSampler,vAlbedoUV);\nsurfaceAlbedo=vec4(toLinearSpace(surfaceAlbedo.rgb),surfaceAlbedo.a);\n#ifndef LINKREFRACTIONTOTRANSPARENCY\n#ifdef ALPHATEST\nif (surfaceAlbedo.a<0.4)\ndiscard;\n#endif\n#endif\n#ifdef ALPHAFROMALBEDO\nalpha*=surfaceAlbedo.a;\n#endif\nsurfaceAlbedo.rgb*=vAlbedoInfos.y;\n#else\n\nsurfaceAlbedo.rgb=surfaceAlbedoContribution;\nsurfaceAlbedoContribution=vec3(1.,1.,1.);\n#endif\n#ifdef VERTEXCOLOR\nsurfaceAlbedo.rgb*=vColor.rgb;\n#endif\n#ifdef OVERLOADEDVALUES\nsurfaceAlbedo.rgb=mix(surfaceAlbedo.rgb,vOverloadedAlbedo,vOverloadedIntensity.y);\n#endif\n\n#ifdef NORMAL\nvec3 normalW=normalize(vNormalW);\n#else\nvec3 normalW=vec3(1.0,1.0,1.0);\n#endif\n#include<bumpFragment>\n\nvec3 ambientColor=vec3(1.,1.,1.);\n#ifdef AMBIENT\nambientColor=texture2D(ambientSampler,vAmbientUV).rgb*vAmbientInfos.y;\n#ifdef OVERLOADEDVALUES\nambientColor.rgb=mix(ambientColor.rgb,vOverloadedAmbient,vOverloadedIntensity.x);\n#endif\n#endif\n\nfloat microSurface=vReflectivityColor.a;\nvec3 surfaceReflectivityColor=vReflectivityColor.rgb;\n#ifdef OVERLOADEDVALUES\nsurfaceReflectivityColor.rgb=mix(surfaceReflectivityColor.rgb,vOverloadedReflectivity,vOverloadedIntensity.z);\n#endif\n#ifdef REFLECTIVITY\nvec4 surfaceReflectivityColorMap=texture2D(reflectivitySampler,vReflectivityUV);\nsurfaceReflectivityColor=surfaceReflectivityColorMap.rgb;\nsurfaceReflectivityColor=toLinearSpace(surfaceReflectivityColor);\n#ifdef OVERLOADEDVALUES\nsurfaceReflectivityColor=mix(surfaceReflectivityColor,vOverloadedReflectivity,vOverloadedIntensity.z);\n#endif\n#ifdef MICROSURFACEFROMREFLECTIVITYMAP\nmicroSurface=surfaceReflectivityColorMap.a;\n#else\n#ifdef MICROSURFACEAUTOMATIC\nmicroSurface=computeDefaultMicroSurface(microSurface,surfaceReflectivityColor);\n#endif\n#endif\n#endif\n#ifdef OVERLOADEDVALUES\nmicroSurface=mix(microSurface,vOverloadedMicroSurface.x,vOverloadedMicroSurface.y);\n#endif\n\nfloat NdotV=max(0.00000000001,dot(normalW,viewDirectionW));\n\nmicroSurface=clamp(microSurface,0.,1.)*0.98;\n\nfloat roughness=clamp(1.-microSurface,0.000001,1.0);\n\nvec3 lightDiffuseContribution=vec3(0.,0.,0.);\n#ifdef OVERLOADEDSHADOWVALUES\nvec3 shadowedOnlyLightDiffuseContribution=vec3(1.,1.,1.);\n#endif\n#ifdef SPECULARTERM\nvec3 lightSpecularContribution=vec3(0.,0.,0.);\n#endif\nfloat notShadowLevel=1.; \nfloat NdotL=-1.;\nlightingInfo info;\n#include<pbrLightFunctionsCall>[0..maxSimultaneousLights]\n#ifdef SPECULARTERM\nlightSpecularContribution*=vLightingIntensity.w;\n#endif\n#ifdef OPACITY\nvec4 opacityMap=texture2D(opacitySampler,vOpacityUV);\n#ifdef OPACITYRGB\nopacityMap.rgb=opacityMap.rgb*vec3(0.3,0.59,0.11);\nalpha*=(opacityMap.x+opacityMap.y+opacityMap.z)* vOpacityInfos.y;\n#else\nalpha*=opacityMap.a*vOpacityInfos.y;\n#endif\n#endif\n#ifdef VERTEXALPHA\nalpha*=vColor.a;\n#endif\n#ifdef OPACITYFRESNEL\nfloat opacityFresnelTerm=computeFresnelTerm(viewDirectionW,normalW,opacityParts.z,opacityParts.w);\nalpha+=opacityParts.x*(1.0-opacityFresnelTerm)+opacityFresnelTerm*opacityParts.y;\n#endif\n\nvec3 surfaceRefractionColor=vec3(0.,0.,0.);\n\n#ifdef LODBASEDMICROSFURACE\nfloat alphaG=convertRoughnessToAverageSlope(roughness);\n#endif\n#ifdef REFRACTION\nvec3 refractionVector=refract(-viewDirectionW,normalW,vRefractionInfos.y);\n#ifdef LODBASEDMICROSFURACE\n#ifdef USEPMREMREFRACTION\nfloat lodRefraction=getMipMapIndexFromAverageSlopeWithPMREM(vMicrosurfaceTextureLods.y,alphaG);\n#else\nfloat lodRefraction=getMipMapIndexFromAverageSlope(vMicrosurfaceTextureLods.y,alphaG);\n#endif\n#else\nfloat biasRefraction=(vMicrosurfaceTextureLods.y+2.)*(1.0-microSurface);\n#endif\n#ifdef REFRACTIONMAP_3D\nrefractionVector.y=refractionVector.y*vRefractionInfos.w;\nif (dot(refractionVector,viewDirectionW)<1.0)\n{\n#ifdef LODBASEDMICROSFURACE\n#ifdef USEPMREMREFRACTION\n\nif ((vMicrosurfaceTextureLods.y-lodRefraction)>4.0)\n{\n\nfloat scaleRefraction=1.-exp2(lodRefraction)/exp2(vMicrosurfaceTextureLods.y); \nfloat maxRefraction=max(max(abs(refractionVector.x),abs(refractionVector.y)),abs(refractionVector.z));\nif (abs(refractionVector.x) != maxRefraction) refractionVector.x*=scaleRefraction;\nif (abs(refractionVector.y) != maxRefraction) refractionVector.y*=scaleRefraction;\nif (abs(refractionVector.z) != maxRefraction) refractionVector.z*=scaleRefraction;\n}\n#endif\nsurfaceRefractionColor=textureCubeLodEXT(refractionCubeSampler,refractionVector,lodRefraction).rgb*vRefractionInfos.x;\n#else\nsurfaceRefractionColor=textureCube(refractionCubeSampler,refractionVector,biasRefraction).rgb*vRefractionInfos.x;\n#endif\n}\n#ifndef REFRACTIONMAPINLINEARSPACE\nsurfaceRefractionColor=toLinearSpace(surfaceRefractionColor.rgb);\n#endif\n#else\nvec3 vRefractionUVW=vec3(refractionMatrix*(view*vec4(vPositionW+refractionVector*vRefractionInfos.z,1.0)));\nvec2 refractionCoords=vRefractionUVW.xy/vRefractionUVW.z;\nrefractionCoords.y=1.0-refractionCoords.y;\n#ifdef LODBASEDMICROSFURACE\nsurfaceRefractionColor=texture2DLodEXT(refraction2DSampler,refractionCoords,lodRefraction).rgb*vRefractionInfos.x;\n#else\nsurfaceRefractionColor=texture2D(refraction2DSampler,refractionCoords,biasRefraction).rgb*vRefractionInfos.x;\n#endif \nsurfaceRefractionColor=toLinearSpace(surfaceRefractionColor.rgb);\n#endif\n#endif\n\nvec3 environmentRadiance=vReflectionColor.rgb;\nvec3 environmentIrradiance=vReflectionColor.rgb;\n#ifdef REFLECTION\nvec3 vReflectionUVW=computeReflectionCoords(vec4(vPositionW,1.0),normalW);\n#ifdef LODBASEDMICROSFURACE\n#ifdef USEPMREMREFLECTION\nfloat lodReflection=getMipMapIndexFromAverageSlopeWithPMREM(vMicrosurfaceTextureLods.x,alphaG);\n#else\nfloat lodReflection=getMipMapIndexFromAverageSlope(vMicrosurfaceTextureLods.x,alphaG);\n#endif\n#else\nfloat biasReflection=(vMicrosurfaceTextureLods.x+2.)*(1.0-microSurface);\n#endif\n#ifdef REFLECTIONMAP_3D\n#ifdef LODBASEDMICROSFURACE\n#ifdef USEPMREMREFLECTION\n\nif ((vMicrosurfaceTextureLods.y-lodReflection)>4.0)\n{\n\nfloat scaleReflection=1.-exp2(lodReflection)/exp2(vMicrosurfaceTextureLods.x); \nfloat maxReflection=max(max(abs(vReflectionUVW.x),abs(vReflectionUVW.y)),abs(vReflectionUVW.z));\nif (abs(vReflectionUVW.x) != maxReflection) vReflectionUVW.x*=scaleReflection;\nif (abs(vReflectionUVW.y) != maxReflection) vReflectionUVW.y*=scaleReflection;\nif (abs(vReflectionUVW.z) != maxReflection) vReflectionUVW.z*=scaleReflection;\n}\n#endif\nenvironmentRadiance=textureCubeLodEXT(reflectionCubeSampler,vReflectionUVW,lodReflection).rgb*vReflectionInfos.x;\n#else\nenvironmentRadiance=textureCube(reflectionCubeSampler,vReflectionUVW,biasReflection).rgb*vReflectionInfos.x;\n#endif\n#ifdef USESPHERICALFROMREFLECTIONMAP\n#ifndef REFLECTIONMAP_SKYBOX\nvec3 normalEnvironmentSpace=(reflectionMatrix*vec4(normalW,1)).xyz;\nenvironmentIrradiance=EnvironmentIrradiance(normalEnvironmentSpace);\n#endif\n#else\nenvironmentRadiance=toLinearSpace(environmentRadiance.rgb);\nenvironmentIrradiance=textureCube(reflectionCubeSampler,normalW,20.).rgb*vReflectionInfos.x;\nenvironmentIrradiance=toLinearSpace(environmentIrradiance.rgb);\nenvironmentIrradiance*=0.2; \n#endif\n#else\nvec2 coords=vReflectionUVW.xy;\n#ifdef REFLECTIONMAP_PROJECTION\ncoords/=vReflectionUVW.z;\n#endif\ncoords.y=1.0-coords.y;\n#ifdef LODBASEDMICROSFURACE\nenvironmentRadiance=texture2DLodEXT(reflection2DSampler,coords,lodReflection).rgb*vReflectionInfos.x;\n#else\nenvironmentRadiance=texture2D(reflection2DSampler,coords,biasReflection).rgb*vReflectionInfos.x;\n#endif\nenvironmentRadiance=toLinearSpace(environmentRadiance.rgb);\nenvironmentIrradiance=texture2D(reflection2DSampler,coords,20.).rgb*vReflectionInfos.x;\nenvironmentIrradiance=toLinearSpace(environmentIrradiance.rgb);\n#endif\n#endif\n#ifdef OVERLOADEDVALUES\nenvironmentIrradiance=mix(environmentIrradiance,vOverloadedReflection,vOverloadedMicroSurface.z);\nenvironmentRadiance=mix(environmentRadiance,vOverloadedReflection,vOverloadedMicroSurface.z);\n#endif\nenvironmentRadiance*=vLightingIntensity.z;\nenvironmentIrradiance*=vLightingIntensity.z;\n\nvec3 specularEnvironmentR0=surfaceReflectivityColor.rgb;\nvec3 specularEnvironmentR90=vec3(1.0,1.0,1.0);\nvec3 specularEnvironmentReflectance=FresnelSchlickEnvironmentGGX(clamp(NdotV,0.,1.),specularEnvironmentR0,specularEnvironmentR90,sqrt(microSurface));\n\nvec3 refractance=vec3(0.0,0.0,0.0);\n#ifdef REFRACTION\nvec3 transmission=vec3(1.0,1.0,1.0);\n#ifdef LINKREFRACTIONTOTRANSPARENCY\n\ntransmission*=(1.0-alpha);\n\n\nvec3 mixedAlbedo=surfaceAlbedoContribution.rgb*surfaceAlbedo.rgb;\nfloat maxChannel=max(max(mixedAlbedo.r,mixedAlbedo.g),mixedAlbedo.b);\nvec3 tint=clamp(maxChannel*mixedAlbedo,0.0,1.0);\n\nsurfaceAlbedoContribution*=alpha;\n\nenvironmentIrradiance*=alpha;\n\nsurfaceRefractionColor*=tint;\n\nalpha=1.0;\n#endif\n\nvec3 bounceSpecularEnvironmentReflectance=(2.0*specularEnvironmentReflectance)/(1.0+specularEnvironmentReflectance);\nspecularEnvironmentReflectance=mix(bounceSpecularEnvironmentReflectance,specularEnvironmentReflectance,alpha);\n\ntransmission*=1.0-specularEnvironmentReflectance;\n\nrefractance=surfaceRefractionColor*transmission;\n#endif\n\nfloat reflectance=max(max(surfaceReflectivityColor.r,surfaceReflectivityColor.g),surfaceReflectivityColor.b);\nsurfaceAlbedo.rgb=(1.-reflectance)*surfaceAlbedo.rgb;\nrefractance*=vLightingIntensity.z;\nenvironmentRadiance*=specularEnvironmentReflectance;\n\nvec3 surfaceEmissiveColor=vEmissiveColor;\n#ifdef EMISSIVE\nvec3 emissiveColorTex=texture2D(emissiveSampler,vEmissiveUV).rgb;\nsurfaceEmissiveColor=toLinearSpace(emissiveColorTex.rgb)*surfaceEmissiveColor*vEmissiveInfos.y;\n#endif\n#ifdef OVERLOADEDVALUES\nsurfaceEmissiveColor=mix(surfaceEmissiveColor,vOverloadedEmissive,vOverloadedIntensity.w);\n#endif\n#ifdef EMISSIVEFRESNEL\nfloat emissiveFresnelTerm=computeFresnelTerm(viewDirectionW,normalW,emissiveRightColor.a,emissiveLeftColor.a);\nsurfaceEmissiveColor*=emissiveLeftColor.rgb*(1.0-emissiveFresnelTerm)+emissiveFresnelTerm*emissiveRightColor.rgb;\n#endif\n\n#ifdef EMISSIVEASILLUMINATION\nvec3 finalDiffuse=max(lightDiffuseContribution*surfaceAlbedoContribution+vAmbientColor,0.0)*surfaceAlbedo.rgb;\n#ifdef OVERLOADEDSHADOWVALUES\nshadowedOnlyLightDiffuseContribution=max(shadowedOnlyLightDiffuseContribution*surfaceAlbedoContribution+vAmbientColor,0.0)*surfaceAlbedo.rgb;\n#endif\n#else\n#ifdef LINKEMISSIVEWITHALBEDO\nvec3 finalDiffuse=max((lightDiffuseContribution+surfaceEmissiveColor)*surfaceAlbedoContribution+vAmbientColor,0.0)*surfaceAlbedo.rgb;\n#ifdef OVERLOADEDSHADOWVALUES\nshadowedOnlyLightDiffuseContribution=max((shadowedOnlyLightDiffuseContribution+surfaceEmissiveColor)*surfaceAlbedoContribution+vAmbientColor,0.0)*surfaceAlbedo.rgb;\n#endif\n#else\nvec3 finalDiffuse=max(lightDiffuseContribution*surfaceAlbedoContribution+surfaceEmissiveColor+vAmbientColor,0.0)*surfaceAlbedo.rgb;\n#ifdef OVERLOADEDSHADOWVALUES\nshadowedOnlyLightDiffuseContribution=max(shadowedOnlyLightDiffuseContribution*surfaceAlbedoContribution+surfaceEmissiveColor+vAmbientColor,0.0)*surfaceAlbedo.rgb;\n#endif\n#endif\n#endif\n#ifdef OVERLOADEDSHADOWVALUES\nfinalDiffuse=mix(finalDiffuse,shadowedOnlyLightDiffuseContribution,(1.0-vOverloadedShadowIntensity.y));\n#endif\n#ifdef SPECULARTERM\nvec3 finalSpecular=lightSpecularContribution*surfaceReflectivityColor;\n#else\nvec3 finalSpecular=vec3(0.0);\n#endif\n#ifdef SPECULAROVERALPHA\nalpha=clamp(alpha+getLuminance(finalSpecular),0.,1.);\n#endif\n#ifdef RADIANCEOVERALPHA\nalpha=clamp(alpha+getLuminance(environmentRadiance),0.,1.);\n#endif\n\n\n#ifdef EMISSIVEASILLUMINATION\nvec4 finalColor=vec4(finalDiffuse*ambientColor*vLightingIntensity.x+surfaceAlbedo.rgb*environmentIrradiance+finalSpecular*vLightingIntensity.x+environmentRadiance+surfaceEmissiveColor*vLightingIntensity.y+refractance,alpha);\n#else\nvec4 finalColor=vec4(finalDiffuse*ambientColor*vLightingIntensity.x+surfaceAlbedo.rgb*environmentIrradiance+finalSpecular*vLightingIntensity.x+environmentRadiance+refractance,alpha);\n#endif\n#ifdef LIGHTMAP\nvec3 lightmapColor=texture2D(lightmapSampler,vLightmapUV).rgb*vLightmapInfos.y;\n#ifdef USELIGHTMAPASSHADOWMAP\nfinalColor.rgb*=lightmapColor;\n#else\nfinalColor.rgb+=lightmapColor;\n#endif\n#endif\nfinalColor=max(finalColor,0.0);\n#ifdef CAMERATONEMAP\nfinalColor.rgb=toneMaps(finalColor.rgb);\n#endif\nfinalColor.rgb=toGammaSpace(finalColor.rgb);\n#include<logDepthFragment>\n#include<fogFragment>(color,finalColor)\n#ifdef CAMERACONTRAST\nfinalColor=contrasts(finalColor);\n#endif\nfinalColor.rgb=clamp(finalColor.rgb,0.,1.);\n#ifdef CAMERACOLORGRADING\nfinalColor=colorGrades(finalColor,cameraColorGrading2DSampler,vCameraColorGradingInfos,vCameraColorGradingScaleOffset);\n#endif\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\ngl_FragColor=finalColor;\n}";
	
	public static var vertexShader:String = "precision highp float;\n\nattribute vec3 position;\n#ifdef NORMAL\nattribute vec3 normal;\n#endif\n#ifdef UV1\nattribute vec2 uv;\n#endif\n#ifdef UV2\nattribute vec2 uv2;\n#endif\n#ifdef VERTEXCOLOR\nattribute vec4 color;\n#endif\n#include<bonesDeclaration>\n\n#include<instancesDeclaration>\nuniform mat4 view;\nuniform mat4 viewProjection;\n#ifdef ALBEDO\nvarying vec2 vAlbedoUV;\nuniform mat4 albedoMatrix;\nuniform vec2 vAlbedoInfos;\n#endif\n#ifdef AMBIENT\nvarying vec2 vAmbientUV;\nuniform mat4 ambientMatrix;\nuniform vec2 vAmbientInfos;\n#endif\n#ifdef OPACITY\nvarying vec2 vOpacityUV;\nuniform mat4 opacityMatrix;\nuniform vec2 vOpacityInfos;\n#endif\n#ifdef EMISSIVE\nvarying vec2 vEmissiveUV;\nuniform vec2 vEmissiveInfos;\nuniform mat4 emissiveMatrix;\n#endif\n#ifdef LIGHTMAP\nvarying vec2 vLightmapUV;\nuniform vec2 vLightmapInfos;\nuniform mat4 lightmapMatrix;\n#endif\n#if defined(REFLECTIVITY)\nvarying vec2 vReflectivityUV;\nuniform vec2 vReflectivityInfos;\nuniform mat4 reflectivityMatrix;\n#endif\n#ifdef BUMP\nvarying vec2 vBumpUV;\nuniform vec3 vBumpInfos;\nuniform mat4 bumpMatrix;\n#endif\n#ifdef POINTSIZE\nuniform float pointSize;\n#endif\n\nvarying vec3 vPositionW;\n#ifdef NORMAL\nvarying vec3 vNormalW;\n#endif\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n#include<clipPlaneVertexDeclaration>\n#include<fogVertexDeclaration>\n#include<shadowsVertexDeclaration>\n#ifdef REFLECTIONMAP_SKYBOX\nvarying vec3 vPositionUVW;\n#endif\n#ifdef REFLECTIONMAP_EQUIRECTANGULAR_FIXED\nvarying vec3 vDirectionW;\n#endif\n#include<logDepthDeclaration>\nvoid main(void) {\n#ifdef REFLECTIONMAP_SKYBOX\nvPositionUVW=position;\n#endif \n#include<instancesVertex>\n#include<bonesVertex>\ngl_Position=viewProjection*finalWorld*vec4(position,1.0);\nvec4 worldPos=finalWorld*vec4(position,1.0);\nvPositionW=vec3(worldPos);\n#ifdef NORMAL\nvNormalW=normalize(vec3(finalWorld*vec4(normal,0.0)));\n#endif\n#ifdef REFLECTIONMAP_EQUIRECTANGULAR_FIXED\nvDirectionW=normalize(vec3(finalWorld*vec4(position,0.0)));\n#endif\n\n#ifndef UV1\nvec2 uv=vec2(0.,0.);\n#endif\n#ifndef UV2\nvec2 uv2=vec2(0.,0.);\n#endif\n#ifdef ALBEDO\nif (vAlbedoInfos.x == 0.)\n{\nvAlbedoUV=vec2(albedoMatrix*vec4(uv,1.0,0.0));\n}\nelse\n{\nvAlbedoUV=vec2(albedoMatrix*vec4(uv2,1.0,0.0));\n}\n#endif\n#ifdef AMBIENT\nif (vAmbientInfos.x == 0.)\n{\nvAmbientUV=vec2(ambientMatrix*vec4(uv,1.0,0.0));\n}\nelse\n{\nvAmbientUV=vec2(ambientMatrix*vec4(uv2,1.0,0.0));\n}\n#endif\n#ifdef OPACITY\nif (vOpacityInfos.x == 0.)\n{\nvOpacityUV=vec2(opacityMatrix*vec4(uv,1.0,0.0));\n}\nelse\n{\nvOpacityUV=vec2(opacityMatrix*vec4(uv2,1.0,0.0));\n}\n#endif\n#ifdef EMISSIVE\nif (vEmissiveInfos.x == 0.)\n{\nvEmissiveUV=vec2(emissiveMatrix*vec4(uv,1.0,0.0));\n}\nelse\n{\nvEmissiveUV=vec2(emissiveMatrix*vec4(uv2,1.0,0.0));\n}\n#endif\n#ifdef LIGHTMAP\nif (vLightmapInfos.x == 0.)\n{\nvLightmapUV=vec2(lightmapMatrix*vec4(uv,1.0,0.0));\n}\nelse\n{\nvLightmapUV=vec2(lightmapMatrix*vec4(uv2,1.0,0.0));\n}\n#endif\n#if defined(REFLECTIVITY)\nif (vReflectivityInfos.x == 0.)\n{\nvReflectivityUV=vec2(reflectivityMatrix*vec4(uv,1.0,0.0));\n}\nelse\n{\nvReflectivityUV=vec2(reflectivityMatrix*vec4(uv2,1.0,0.0));\n}\n#endif\n#ifdef BUMP\nif (vBumpInfos.x == 0.)\n{\nvBumpUV=vec2(bumpMatrix*vec4(uv,1.0,0.0));\n}\nelse\n{\nvBumpUV=vec2(bumpMatrix*vec4(uv2,1.0,0.0));\n}\n#endif\n\n#include<clipPlaneVertex>\n\n#include<fogVertex>\n\n#include<shadowsVertex>\n\n#ifdef VERTEXCOLOR\nvColor=color;\n#endif\n\n#ifdef POINTSIZE\ngl_PointSize=pointSize;\n#endif\n\n#include<logDepthVertex>\n}";
	

	/**
	 * Intensity of the direct lights e.g. the four lights available in your scene.
	 * This impacts both the direct diffuse and specular highlights.
	 */
	@serialize()
	public var directIntensity:Float = 1.0;
	
	/**
	 * Intensity of the emissive part of the material.
	 * This helps controlling the emissive effect without modifying the emissive color.
	 */
	@serialize()
	public var emissiveIntensity:Float = 1.0;
	
	/**
	 * Intensity of the environment e.g. how much the environment will light the object
	 * either through harmonics for rough material or through the refelction for shiny ones.
	 */
	@serialize()
	public var environmentIntensity:Float = 1.0;
	
	/**
	 * This is a special control allowing the reduction of the specular highlights coming from the 
	 * four lights of the scene. Those highlights may not be needed in full environment lighting.
	 */
	@serialize()
	public var specularIntensity:Float = 1.0;

	private var _lightingInfos:Vector4;
	
	/**
	 * Debug Control allowing disabling the bump map on this material.
	 */
	@serialize()
	public var disableBumpMap:Bool = false;

	/**
	 * Debug Control helping enforcing or dropping the darkness of shadows.
	 * 1.0 means the shadows have their normal darkness, 0.0 means the shadows are not visible.
	 */
	@serialize()
	public var overloadedShadowIntensity:Float = 1.0;
	
	/**
	 * Debug Control helping dropping the shading effect coming from the diffuse lighting.
	 * 1.0 means the shade have their normal impact, 0.0 means no shading at all.
	 */
	@serialize()
	public var overloadedShadeIntensity:Float = 1.0;

	private var _overloadedShadowInfos:Vector4;

	/**
	 * The camera exposure used on this material.
	 * This property is here and not in the camera to allow controlling exposure without full screen post process.
	 * This corresponds to a photographic exposure.
	 */
	@serialize()
	public var cameraExposure:Float = 1.0;
	
	/**
	 * The camera contrast used on this material.
	 * This property is here and not in the camera to allow controlling contrast without full screen post process.
	 */
	@serialize()
	public var cameraContrast:Float = 1.0;
	
	/**
	 * Color Grading 2D Lookup Texture.
	 * This allows special effects like sepia, black and white to sixties rendering style. 
	 */
	@serializeAsTexture()
	public var cameraColorGradingTexture:BaseTexture = null;

	private var _cameraColorGradingScaleOffset:Vector4 = new Vector4(1.0, 1.0, 0.0, 0.0);
	private var _cameraColorGradingInfos:Vector4 = new Vector4(1.0, 1.0, 0.0, 0.0);
	
	private var _cameraInfos:Vector4 = new Vector4(1.0, 1.0, 0.0, 0.0);

	private var _microsurfaceTextureLods:Vector2 = new Vector2(0.0, 0.0);

	/**
	 * Debug Control allowing to overload the ambient color.
	 * This as to be use with the overloadedAmbientIntensity parameter.
	 */
	@serializeAsColor3()
	public var overloadedAmbient:Color3 = Color3.White();

	/**
	 * Debug Control indicating how much the overloaded ambient color is used against the default one.
	 */
	@serialize()
	public var overloadedAmbientIntensity:Float = 0.0;
	
	/**
	 * Debug Control allowing to overload the albedo color.
	 * This as to be use with the overloadedAlbedoIntensity parameter.
	 */
	@serializeAsColor3()
	public var overloadedAlbedo:Color3 = Color3.White();
	
	/**
	 * Debug Control indicating how much the overloaded albedo color is used against the default one.
	 */
	@serialize()
	public var overloadedAlbedoIntensity:Float = 0.0;
	
	/**
	 * Debug Control allowing to overload the reflectivity color.
	 * This as to be use with the overloadedReflectivityIntensity parameter.
	 */
	@serializeAsColor3()
	public var overloadedReflectivity:Color3 = new Color3(0.3, 0.3, 0.3);
	
	/**
	 * Debug Control indicating how much the overloaded reflectivity color is used against the default one.
	 */
	@serialize()
	public var overloadedReflectivityIntensity:Float = 0.0;
	
	/**
	 * Debug Control allowing to overload the emissive color.
	 * This as to be use with the overloadedEmissiveIntensity parameter.
	 */
	@serializeAsColor3()
	public var overloadedEmissive:Color3 = Color3.White();
	
	/**
	 * Debug Control indicating how much the overloaded emissive color is used against the default one.
	 */
	@serialize()
	public var overloadedEmissiveIntensity:Float = 0.0;

	private var _overloadedIntensity:Vector4;
	
	/**
	 * Debug Control allowing to overload the reflection color.
	 * This as to be use with the overloadedReflectionIntensity parameter.
	 */
	@serializeAsColor3()
	public var overloadedReflection:Color3 = Color3.White();
	
	/**
	 * Debug Control indicating how much the overloaded reflection color is used against the default one.
	 */
	@serialize()
	public var overloadedReflectionIntensity:Float = 0.0;

	/**
	 * Debug Control allowing to overload the microsurface.
	 * This as to be use with the overloadedMicroSurfaceIntensity parameter.
	 */
	@serialize()
	public var overloadedMicroSurface:Float = 0.0;
	
	/**
	 * Debug Control indicating how much the overloaded microsurface is used against the default one.
	 */
	@serialize()
	public var overloadedMicroSurfaceIntensity:Float = 0.0;

	private var _overloadedMicroSurface:Vector3;

	/**
	 * AKA Diffuse Texture in standard nomenclature.
	 */
	@serializeAsTexture()
	public var albedoTexture:BaseTexture;
	
	/**
	 * AKA Occlusion Texture in other nomenclature.
	 */
	@serializeAsTexture()
	public var ambientTexture:BaseTexture;

	@serializeAsTexture()
	public var opacityTexture:BaseTexture;

	@serializeAsTexture()
	public var reflectionTexture:BaseTexture;

	@serializeAsTexture()
	public var emissiveTexture:BaseTexture;
	
	/**
	 * AKA Specular texture in other nomenclature.
	 */
	@serializeAsTexture()
	public var reflectivityTexture:BaseTexture;

	@serializeAsTexture()
	public var bumpTexture:BaseTexture;

	@serializeAsTexture()
	public var lightmapTexture:BaseTexture;

	@serializeAsTexture()
	public var refractionTexture:BaseTexture;

	@serializeAsColor3("ambient")
	public var ambientColor:Color3 = new Color3(0, 0, 0);
	
	/**
	 * AKA Diffuse Color in other nomenclature.
	 */
	@serializeAsColor3("albedo")
	public var albedoColor:Color3 = new Color3(1, 1, 1);
	
	/**
	 * AKA Specular Color in other nomenclature.
	 */
	@serializeAsColor3("reflectivity")
	public var reflectivityColor:Color3 = new Color3(1, 1, 1);

	@serializeAsColor3("reflection")
	public var reflectionColor:Color3 = new Color3(0.5, 0.5, 0.5);

	@serializeAsColor3("emissive")
	public var emissiveColor:Color3 = new Color3(0, 0, 0);
	
	/**
	 * AKA Glossiness in other nomenclature.
	 */
	@serialize()
	public var microSurface:Float = 0.9;
	
	/**
	 * source material index of refraction (IOR)' / 'destination material IOR.
	 */
	@serialize()
	public var indexOfRefraction:Float = 0.66;
	
	/**
	 * Controls if refraction needs to be inverted on Y. This could be usefull for procedural texture.
	 */
	@serialize()
	public var invertRefractionY:Bool = false;

	@serializeAsFresnelParameters()
	public var opacityFresnelParameters:FresnelParameters;

	@serializeAsFresnelParameters()
	public var emissiveFresnelParameters:FresnelParameters;

	/**
	 * This parameters will make the material used its opacity to control how much it is refracting aginst not.
	 * Materials half opaque for instance using refraction could benefit from this control.
	 */
	@serialize()
	public var linkRefractionWithTransparency:Bool = false;
	
	/**
	 * The emissive and albedo are linked to never be more than one (Energy conservation).
	 */
	@serialize()
	public var linkEmissiveWithAlbedo:Bool = false;

	@serialize()
	public var useLightmapAsShadowmap:Bool = false;
	
	/**
	 * In this mode, the emissive informtaion will always be added to the lighting once.
	 * A light for instance can be thought as emissive.
	 */
	@serialize()
	public var useEmissiveAsIllumination:Bool = false;
	
	/**
	 * Secifies that the alpha is coming form the albedo channel alpha channel.
	 */
	@serialize()
	public var useAlphaFromAlbedoTexture:Bool = false;
	
	/**
	 * Specifies that the material will keeps the specular highlights over a transparent surface (only the most limunous ones).
	 * A car glass is a good exemple of that. When sun reflects on it you can not see what is behind.
	 */
	@serialize()
	public var useSpecularOverAlpha:Bool = true;
	
	/**
	 * Specifies if the reflectivity texture contains the glossiness information in its alpha channel.
	 */
	@serialize()
	public var useMicroSurfaceFromReflectivityMapAlpha:Bool = false;
	
	/**
	 * In case the reflectivity map does not contain the microsurface information in its alpha channel,
	 * The material will try to infer what glossiness each pixel should be.
	 */
	@serialize()
	public var useAutoMicroSurfaceFromReflectivityMap:Bool = false;
	
	/**
	 * Allows to work with scalar in linear mode. This is definitely a matter of preferences and tools used during
	 * the creation of the material.
	 */
	@serialize()
	public var useScalarInLinearSpace:Bool = false;
	
	/**
	 * BJS is using an harcoded light falloff based on a manually sets up range.
	 * In PBR, one way to represents the fallof is to use the inverse squared root algorythm.
	 * This parameter can help you switch back to the BJS mode in order to create scenes using both materials.
	 */
	@serialize()
	public var usePhysicalLightFalloff:Bool = true;
	
	/**
	 * Specifies that the material will keeps the reflection highlights over a transparent surface (only the most limunous ones).
	 * A car glass is a good exemple of that. When the street lights reflects on it you can not see what is behind.
	 */
	@serialize()
	public var useRadianceOverAlpha:Bool = true;
	
	/**
	 * Allows using the bump map in parallax mode.
	 */
	@serialize()
	public var useParallax:Bool = false;

	/**
	 * Allows using the bump map in parallax occlusion mode.
	 */
	@serialize()
	public var useParallaxOcclusion:Bool = false;

	/**
	 * Controls the scale bias of the parallax mode.
	 */
	@serialize()
	public var parallaxScaleBias:Float = 0.05;
	
	/**
	 * If sets to true, disables all the lights affecting the material.
	 */
	@serialize()
	public var disableLighting:Bool = false;

	/**
	 * Number of Simultaneous lights allowed on the material.
	 */
	@serialize()
	public var maxSimultaneousLights:Int = 4;  

	private var _renderTargets:SmartArray<RenderTargetTexture> = new SmartArray<RenderTargetTexture>(16);
	private var _worldViewProjectionMatrix:Matrix = Matrix.Zero();
	private var _globalAmbientColor:Color3 = new Color3(0, 0, 0);
	private var _tempColor:Color3 = new Color3();
	private var _renderId:Int;

	private var _defines:PBRMaterialDefines = new PBRMaterialDefines();
	private var _cachedDefines:PBRMaterialDefines = new PBRMaterialDefines();

	@serialize("useLogarithmicDepth")
	private var _useLogarithmicDepth:Bool;
	public var useLogarithmicDepth(get, set):Bool;
	

	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		this._cachedDefines.BonesPerMesh = -1;
		
		if (!ShadersStore.Shaders.exists("pbrmat.fragment")) {
			var textureLODExt = scene.getEngine().getCaps().textureLODExt;
			var textureCubeLod = scene.getEngine().getCaps().textureCubeLodFnName;			
			fragmentShader = StringTools.replace(fragmentShader, "GL_EXT_shader_texture_lod", textureLODExt);
			fragmentShader = StringTools.replace(fragmentShader, "textureCubeLodEXT", textureCubeLod);
			//fragmentShader = StringTools.replace(fragmentShader, "texture2DLodEXT", "textureLod");
			
			ShadersStore.Shaders.set("pbrmat.fragment", fragmentShader);
			ShadersStore.Shaders.set("pbrmat.vertex", vertexShader);
		}
		
		this._lightingInfos = new Vector4(this.directIntensity, this.emissiveIntensity, this.environmentIntensity, this.specularIntensity);
		this._overloadedShadowInfos = new Vector4(this.overloadedShadowIntensity, this.overloadedShadeIntensity, 0.0, 0.0);
		this._overloadedIntensity = new Vector4(this.overloadedAmbientIntensity, this.overloadedAlbedoIntensity, this.overloadedReflectivityIntensity, this.overloadedEmissiveIntensity);
		this._overloadedMicroSurface = new Vector3(this.overloadedMicroSurface, this.overloadedMicroSurfaceIntensity, this.overloadedReflectionIntensity);
		
		this.getRenderTargetTextures = function():SmartArray<RenderTargetTexture> {
			this._renderTargets.reset();
			
			if (this.reflectionTexture != null && this.reflectionTexture.isRenderTarget) {
				this._renderTargets.push(cast this.reflectionTexture);
			}
			
			if (this.refractionTexture != null && this.refractionTexture.isRenderTarget) {
				this._renderTargets.push(cast this.refractionTexture);
			}
			
			return this._renderTargets;
		};
	}

	private function get_useLogarithmicDepth():Bool {
		return this._useLogarithmicDepth;
	}
	private function set_useLogarithmicDepth(value:Bool):Bool {
		this._useLogarithmicDepth = value && this.getScene().getEngine().getCaps().fragmentDepthSupported;
		
		return value;
	}

	override public function needAlphaBlending():Bool {
		if (this.linkRefractionWithTransparency) {
			return false;
		}
		
		return (this.alpha < 1.0) || (this.opacityTexture != null) || this._shouldUseAlphaFromAlbedoTexture() || this.opacityFresnelParameters != null && this.opacityFresnelParameters.isEnabled;
	}

	override public function needAlphaTesting():Bool {
		if (this.linkRefractionWithTransparency) {
			return false;
		}
		
		return this.albedoTexture != null && this.albedoTexture.hasAlpha;
	}

	private function _shouldUseAlphaFromAlbedoTexture():Bool {
		return this.albedoTexture != null && this.albedoTexture.hasAlpha && this.useAlphaFromAlbedoTexture;
	}

	override public function getAlphaTestTexture():BaseTexture {
		return this.albedoTexture;
	}

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

	inline private function convertColorToLinearSpaceToRef(color:Color3, ref:Color3) {
		PBRMaterial._convertColorToLinearSpaceToRef(color, ref, this.useScalarInLinearSpace);
	}

	inline private static function _convertColorToLinearSpaceToRef(color:Color3, ref:Color3, useScalarInLinear:Bool) {
		if (!useScalarInLinear) {
			color.toLinearSpaceToRef(ref);
		} 
		else {
			ref.r = color.r;
			ref.g = color.g;
			ref.b = color.b;
		}
	}

	private static var _scaledAlbedo = new Color3();
	private static var _scaledReflectivity = new Color3();
	private static var _scaledEmissive = new Color3();
	private static var _scaledReflection = new Color3();

	public static function BindLights(scene:Scene, mesh:AbstractMesh, effect:Effect, defines:MaterialDefines, useScalarInLinearSpace:Bool, maxSimultaneousLights:Int, usePhysicalLightFalloff:Bool) {
		var lightIndex:Int = 0;
		var depthValuesAlreadySet:Bool = false;
		for (index in 0...scene.lights.length) {
			var light = scene.lights[index];
			
			if (!light.isEnabled()) {
				continue;
			}
			
			if (!light.canAffectMesh(mesh)) {
				continue;
			}
			
			MaterialHelper.BindLightProperties(light, effect, lightIndex);
			
			// GAMMA CORRECTION.
			_convertColorToLinearSpaceToRef(light.diffuse, PBRMaterial._scaledAlbedo, useScalarInLinearSpace);
			
			PBRMaterial._scaledAlbedo.scaleToRef(light.intensity, PBRMaterial._scaledAlbedo);
			effect.setColor4("vLightDiffuse" + lightIndex, PBRMaterial._scaledAlbedo, usePhysicalLightFalloff ? light.radius : light.range);
			
			if (defines.defines["SPECULARTERM"]) {
				_convertColorToLinearSpaceToRef(light.specular, PBRMaterial._scaledReflectivity, useScalarInLinearSpace);
				
				PBRMaterial._scaledReflectivity.scaleToRef(light.intensity, PBRMaterial._scaledReflectivity);
				effect.setColor3("vLightSpecular" + lightIndex, PBRMaterial._scaledReflectivity);
			}
			
			// Shadows
			if (scene.shadowsEnabled) {
				depthValuesAlreadySet = MaterialHelper.BindLightShadow(light, scene, mesh, lightIndex, effect, depthValuesAlreadySet);
			}
			
			lightIndex++;
			
			if (lightIndex == maxSimultaneousLights) {
				break;
			}
		}
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
		
		if (scene.texturesEnabled) {
			// Textures
			if (scene.texturesEnabled) {
				if (scene.getEngine().getCaps().textureLOD) {
					this._defines.defines["LODBASEDMICROSFURACE"] = true;
				}
				
				if (this.albedoTexture != null && StandardMaterial.DiffuseTextureEnabled) {
					if (!this.albedoTexture.isReady()) {
						return false;
					} 
					else {
						needUVs = true;
						this._defines.defines["ALBEDO"] = true;
					}
				}
				
				if (this.ambientTexture != null && StandardMaterial.AmbientTextureEnabled) {
					if (!this.ambientTexture.isReady()) {
						return false;
					} 
					else {
						needUVs = true;
						this._defines.defines["AMBIENT"] = true;
					}
				}
				
				if (this.opacityTexture != null && StandardMaterial.OpacityTextureEnabled) {
					if (!this.opacityTexture.isReady()) {
						return false;
					} 
					else {
						needUVs = true;
						this._defines.defines["OPACITY"] = true;
						
						if (this.opacityTexture.getAlphaFromRGB) {
							this._defines.defines["OPACITYRGB"] = true;
						}
					}
				}
				
				if (this.reflectionTexture != null && StandardMaterial.ReflectionTextureEnabled) {
					if (!this.reflectionTexture.isReady()) {
						return false;
					} 
					else {
						needNormals = true;
						this._defines.defines["REFLECTION"] = true;
						
						if (this.reflectionTexture.coordinatesMode == Texture.INVCUBIC_MODE) {
							this._defines.defines["INVERTCUBICMAP"] = true;
						}
						
						this._defines.defines["REFLECTIONMAP_3D"] = this.reflectionTexture.isCube;
						
						switch (this.reflectionTexture.coordinatesMode) {
							case Texture.CUBIC_MODE, Texture.INVCUBIC_MODE:
								this._defines.defines["REFLECTIONMAP_CUBIC"] = true;
								
							case Texture.EXPLICIT_MODE:
								this._defines.defines["REFLECTIONMAP_EXPLICIT"] = true;
								
							case Texture.PLANAR_MODE:
								this._defines.defines["REFLECTIONMAP_PLANAR"] = true;
								
							case Texture.PROJECTION_MODE:
								this._defines.defines["REFLECTIONMAP_PROJECTION"] = true;
								
							case Texture.SKYBOX_MODE:
								this._defines.defines["REFLECTIONMAP_SKYBOX"] = true;
								
							case Texture.SPHERICAL_MODE:
								this._defines.defines["REFLECTIONMAP_SPHERICAL"] = true;
								
							case Texture.EQUIRECTANGULAR_MODE:
								this._defines.defines["REFLECTIONMAP_EQUIRECTANGULAR"] = true;
								
						}
						
						if (Std.is(this.reflectionTexture, HDRCubeTexture)) {
							this._defines.defines["USESPHERICALFROMREFLECTIONMAP"] = true;
							needNormals = true;
							
							if (untyped this.reflectionTexture.isPMREM) {
								this._defines.defines["USEPMREMREFLECTION"] = true;
							}
						}
					}
				}
				
				if (this.lightmapTexture != null && StandardMaterial.LightmapTextureEnabled) {
					if (!this.lightmapTexture.isReady()) {
						return false;
					} 
					else {
						needUVs = true;
						this._defines.defines["LIGHTMAP"] = true;
						this._defines.defines["USELIGHTMAPASSHADOWMAP"] = this.useLightmapAsShadowmap;
					}
				}
				
				if (this.emissiveTexture != null && StandardMaterial.EmissiveTextureEnabled) {
					if (!this.emissiveTexture.isReady()) {
						return false;
					} 
					else {
						needUVs = true;
						this._defines.defines["EMISSIVE"] = true;
					}
				}
				
				if (this.reflectivityTexture != null && StandardMaterial.SpecularTextureEnabled) {
					if (!this.reflectivityTexture.isReady()) {
						return false;
					} 
					else {
						needUVs = true;
						this._defines.defines["REFLECTIVITY"] = true;
						this._defines.defines["MICROSURFACEFROMREFLECTIVITYMAP"] = this.useMicroSurfaceFromReflectivityMapAlpha;
						this._defines.defines["MICROSURFACEAUTOMATIC"] = this.useAutoMicroSurfaceFromReflectivityMap;
					}
				}
			}
			
			if (scene.getEngine().getCaps().standardDerivatives && this.bumpTexture != null && StandardMaterial.BumpTextureEnabled && !this.disableBumpMap) {
				if (!this.bumpTexture.isReady()) {
					return false;
				} 
				else {
					needUVs = true;
					this._defines.defines["BUMP"] = true;
					
					if (this.useParallax) {
						this._defines.defines["PARALLAX"] = true;
						if (this.useParallaxOcclusion) {
							this._defines.defines["PARALLAXOCCLUSION"] = true;
						}
					}
				}
			}
			
			if (this.refractionTexture != null && StandardMaterial.RefractionTextureEnabled) {
				if (!this.refractionTexture.isReady()) {
					return false;
				} 
				else {
					needUVs = true;
					this._defines.defines["REFRACTION"] = true;
					this._defines.defines["REFRACTIONMAP_3D"] = this.refractionTexture.isCube;
					
					if (this.linkRefractionWithTransparency) {
						this._defines.defines["LINKREFRACTIONTOTRANSPARENCY"] = true;
					}
					if (Std.is(this.refractionTexture, HDRCubeTexture)) {
						this._defines.defines["REFRACTIONMAPINLINEARSPACE"] = true;
						
						if (untyped this.refractionTexture.isPMREM) {
							this._defines.defines["USEPMREMREFRACTION"] = true;
						}
					}
				}
			}
			
			if (this.cameraColorGradingTexture != null) {
				if (!this.cameraColorGradingTexture.isReady()) {
					return false;
				} 
				else {
					this._defines.defines["CAMERACOLORGRADING"] = true;
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
		
		if (this._shouldUseAlphaFromAlbedoTexture()) {
			this._defines.defines["ALPHAFROMALBEDO"] = true;
		}
		
		if (this.useEmissiveAsIllumination) {
			this._defines.defines["EMISSIVEASILLUMINATION"] = true;
		}
		
		if (this.linkEmissiveWithAlbedo) {
			this._defines.defines["LINKEMISSIVEWITHALBEDO"] = true;
		}
		
		if (this.useLogarithmicDepth) {
			this._defines.defines["LOGARITHMICDEPTH"] = true;
		}
		
		if (this.cameraContrast != 1) {
			this._defines.defines["CAMERACONTRAST"] = true;
		}
		
		if (this.cameraExposure != 1) {
			this._defines.defines["CAMERATONEMAP"] = true;
		}
		
		if (this.overloadedShadeIntensity != 1 ||
			this.overloadedShadowIntensity != 1) {
			this._defines.defines["OVERLOADEDSHADOWVALUES"] = true;
		}
		
		if (this.overloadedMicroSurfaceIntensity > 0 ||
			this.overloadedEmissiveIntensity > 0 ||
			this.overloadedReflectivityIntensity > 0 ||
			this.overloadedAlbedoIntensity > 0 ||
			this.overloadedAmbientIntensity > 0 ||
			this.overloadedReflectionIntensity > 0) {
			this._defines.defines["OVERLOADEDVALUES"] = true;
		}
		
		// Point size
		if (this.pointsCloud || scene.forcePointsCloud) {
			this._defines.defines["POINTSIZE"] = true;
		}
		
		// Fog
		if (scene.fogEnabled && mesh != null && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE && this.fogEnabled) {
			this._defines.defines["FOG"] = true;
		}
		
		if (scene.lightsEnabled && !this.disableLighting) {
			needNormals = MaterialHelper.PrepareDefinesForLights(scene, mesh, this._defines, this.maxSimultaneousLights);
		}
		
		if (StandardMaterial.FresnelEnabled) {
			// Fresnel
			if (this.opacityFresnelParameters != null && this.opacityFresnelParameters.isEnabled ||
				this.emissiveFresnelParameters != null && this.emissiveFresnelParameters.isEnabled) {
				
				if (this.opacityFresnelParameters != null && this.opacityFresnelParameters.isEnabled) {
					this._defines.defines["OPACITYFRESNEL"] = true;
				}
				
				if (this.emissiveFresnelParameters != null && this.emissiveFresnelParameters.isEnabled) {
					this._defines.defines["EMISSIVEFRESNEL"] = true;
				}
				
				needNormals = true;
				this._defines.defines["FRESNEL"] = true;
			}
		}
		
		if (this._defines.defines["SPECULARTERM"] && this.useSpecularOverAlpha) {
			this._defines.defines["SPECULAROVERALPHA"] = true;
		}
		
		if (this.usePhysicalLightFalloff) {
			this._defines.defines["USEPHYSICALLIGHTFALLOFF"] = true;
		}
		
		if (this.useRadianceOverAlpha) {
			this._defines.defines["RADIANCEOVERALPHA"] = true;
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
				this._defines.NUM_BONE_INFLUENCERS = mesh.numBoneInfluencers;
				this._defines.BonesPerMesh = (mesh.skeleton.bones.length + 1);
			}
			
			// Instances
			if (useInstances) {
				this._defines.defines["INSTANCES"] = true;
			}
		}
		
		// Get correct effect
		if (!this._defines.isEqual(this._cachedDefines)) {
			this._defines.cloneTo(this._cachedDefines);
			
			scene.resetCachedMaterial();
			
			// Fallbacks
			var fallbacks = new EffectFallbacks();
			if (this._defines.defines["REFLECTION"]) {
				fallbacks.addFallback(0, "REFLECTION");
			}
			
			if (this._defines.defines["REFRACTION"]) {
				fallbacks.addFallback(0, "REFRACTION");
			}
			
			if (this._defines.defines["REFLECTIVITY"]) {
				fallbacks.addFallback(0, "REFLECTIVITY");
			}
			
			if (this._defines.defines["BUMP"]) {
				fallbacks.addFallback(0, "BUMP");
			}
			
			if (this._defines.defines["PARALLAX"]) {
				fallbacks.addFallback(1, "PARALLAX");
			}
			
			if (this._defines.defines["PARALLAXOCCLUSION"]) {
				fallbacks.addFallback(0, "PARALLAXOCCLUSION");
			}
			
			if (this._defines.defines["SPECULAROVERALPHA"]) {
				fallbacks.addFallback(0, "SPECULAROVERALPHA");
			}
			
			if (this._defines.defines["FOG"]) {
				fallbacks.addFallback(1, "FOG");
			}
			
			if (this._defines.defines["POINTSIZE"]) {
				fallbacks.addFallback(0, "POINTSIZE");
			}
			
			if (this._defines.defines["LOGARITHMICDEPTH"]) {
				fallbacks.addFallback(0, "LOGARITHMICDEPTH");
			}
			
			MaterialHelper.HandleFallbacksForShadows(this._defines, fallbacks, this.maxSimultaneousLights);
			
			if (this._defines.defines["SPECULARTERM"]) {
				fallbacks.addFallback(0, "SPECULARTERM");
			}
			
			if (this._defines.defines["OPACITYFRESNEL"]) {
				fallbacks.addFallback(1, "OPACITYFRESNEL");
			}
			
			if (this._defines.defines["EMISSIVEFRESNEL"]) {
				fallbacks.addFallback(2, "EMISSIVEFRESNEL");
			}
			
			if (this._defines.defines["FRESNEL"]) {
				fallbacks.addFallback(3, "FRESNEL");
			}
			
			if (this._defines.NUM_BONE_INFLUENCERS > 0) {
				fallbacks.addCPUSkinningFallback(0, mesh);
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
			
			MaterialHelper.PrepareAttributesForBones(attribs, mesh, this._defines, fallbacks);
			MaterialHelper.PrepareAttributesForInstances(attribs, this._defines);
			
			// Legacy browser patch
			var shaderName:String = "pbrmat";
			if (!scene.getEngine().getCaps().standardDerivatives) {
				shaderName = "legacypbrmat";
			}
			var join:String = this._defines.toString();
			
			var uniforms:Array<String> = ["world", "view", "viewProjection", "vEyePosition", "vLightsType", "vAmbientColor", "vAlbedoColor", "vReflectivityColor", "vEmissiveColor", "vReflectionColor",
				"vFogInfos", "vFogColor", "pointSize",
				"vAlbedoInfos", "vAmbientInfos", "vOpacityInfos", "vReflectionInfos", "vEmissiveInfos", "vReflectivityInfos", "vBumpInfos", "vLightmapInfos", "vRefractionInfos",
				"mBones",
				"vClipPlane", "albedoMatrix", "ambientMatrix", "opacityMatrix", "reflectionMatrix", "emissiveMatrix", "reflectivityMatrix", "bumpMatrix", "lightmapMatrix", "refractionMatrix",
				"depthValues",
				"opacityParts", "emissiveLeftColor", "emissiveRightColor",
				"vLightingIntensity", "vOverloadedShadowIntensity", "vOverloadedIntensity", "vOverloadedAlbedo", "vOverloadedReflection", "vOverloadedReflectivity", "vOverloadedEmissive", "vOverloadedMicroSurface",
				"logarithmicDepthConstant",
				"vSphericalX", "vSphericalY", "vSphericalZ",
				"vSphericalXX", "vSphericalYY", "vSphericalZZ",
				"vSphericalXY", "vSphericalYZ", "vSphericalZX",
				"vMicrosurfaceTextureLods",
				"vCameraInfos", "vCameraColorGradingInfos", "vCameraColorGradingScaleOffset"
			];
			
			var samplers:Array<String> = ["albedoSampler", "ambientSampler", "opacitySampler", "reflectionCubeSampler", "reflection2DSampler", "emissiveSampler", "reflectivitySampler", "bumpSampler", "lightmapSampler", "refractionCubeSampler", "refraction2DSampler", "cameraColorGrading2DSampler"];
			
			MaterialHelper.PrepareUniformsAndSamplersList(uniforms, samplers, this._defines, this.maxSimultaneousLights); 
			
			this._effect = scene.getEngine().createEffect(shaderName,
				attribs, uniforms, samplers,
				join, fallbacks, this.onCompiled, this.onError, { maxSimultaneousLights: this.maxSimultaneousLights });
		}
		if (!this._effect.isReady()) {
			return false;
		}
		
		this._renderId = scene.getRenderId();
		this._wasPreviouslyReady = true;
		
		if (mesh != null) {
			if (mesh._materialDefines == null) {
				mesh._materialDefines = new PBRMaterialDefines();
			}
			
			this._defines.cloneTo(mesh._materialDefines);
		}
		
		return true;
	}


	override public function unbind() {
		if (this.reflectionTexture != null && this.reflectionTexture.isRenderTarget) {
			this._effect.setTexture("reflection2DSampler", null);
		}
		
		if (this.refractionTexture != null && this.refractionTexture.isRenderTarget) {
			this._effect.setTexture("refraction2DSampler", null);
		}
		
		super.unbind();
	}

	override public function bindOnlyWorldMatrix(world:Matrix) {
		this._effect.setMatrix("world", world);
	}

	private var _myScene:Scene = null;
	private var _myShadowGenerator:ShadowGenerator = null;

	override public function bind(world:Matrix, ?mesh:Mesh) {
		this._myScene = this.getScene();
		
		// Matrices        
		this.bindOnlyWorldMatrix(world);
		
		// Bones
		MaterialHelper.BindBonesParameters(mesh, this._effect);
		
		if (this._myScene.getCachedMaterial() != this) {
			this._effect.setMatrix("viewProjection", this._myScene.getTransformMatrix());
			
			if (StandardMaterial.FresnelEnabled) {
				if (this.opacityFresnelParameters != null && this.opacityFresnelParameters.isEnabled) {
					this._effect.setColor4("opacityParts", new Color3(this.opacityFresnelParameters.leftColor.toLuminance(), this.opacityFresnelParameters.rightColor.toLuminance(), this.opacityFresnelParameters.bias), this.opacityFresnelParameters.power);
				}
				
				if (this.emissiveFresnelParameters != null && this.emissiveFresnelParameters.isEnabled) {
					this._effect.setColor4("emissiveLeftColor", this.emissiveFresnelParameters.leftColor, this.emissiveFresnelParameters.power);
					this._effect.setColor4("emissiveRightColor", this.emissiveFresnelParameters.rightColor, this.emissiveFresnelParameters.bias);
				}
			}
			
			// Textures        
			if (this._myScene.texturesEnabled) {
				if (this.albedoTexture != null && StandardMaterial.DiffuseTextureEnabled) {
					this._effect.setTexture("albedoSampler", this.albedoTexture);
					
					this._effect.setFloat2("vAlbedoInfos", this.albedoTexture.coordinatesIndex, this.albedoTexture.level);
					this._effect.setMatrix("albedoMatrix", this.albedoTexture.getTextureMatrix());
				}
				
				if (this.ambientTexture != null && StandardMaterial.AmbientTextureEnabled) {
					this._effect.setTexture("ambientSampler", this.ambientTexture);
					
					this._effect.setFloat2("vAmbientInfos", this.ambientTexture.coordinatesIndex, this.ambientTexture.level);
					this._effect.setMatrix("ambientMatrix", this.ambientTexture.getTextureMatrix());
				}
				
				if (this.opacityTexture != null && StandardMaterial.OpacityTextureEnabled) {
					this._effect.setTexture("opacitySampler", this.opacityTexture);
					
					this._effect.setFloat2("vOpacityInfos", this.opacityTexture.coordinatesIndex, this.opacityTexture.level);
					this._effect.setMatrix("opacityMatrix", this.opacityTexture.getTextureMatrix());
				}
				
				if (this.reflectionTexture != null && StandardMaterial.ReflectionTextureEnabled) {
					this._microsurfaceTextureLods.x = Math.round(Math.log(this.reflectionTexture.getSize().width) * MathTools.LOG2E);
					
					if (this.reflectionTexture.isCube) {
						this._effect.setTexture("reflectionCubeSampler", this.reflectionTexture);
					} 
					else {
						this._effect.setTexture("reflection2DSampler", this.reflectionTexture);
					}
					
					this._effect.setMatrix("reflectionMatrix", this.reflectionTexture.getReflectionTextureMatrix());
					this._effect.setFloat2("vReflectionInfos", this.reflectionTexture.level, 0);
					
					if (this._defines.defines["USESPHERICALFROMREFLECTIONMAP"]) {
						var sp = cast (this.reflectionTexture, HDRCubeTexture).sphericalPolynomial;
						this._effect.setFloat3("vSphericalX", sp.x.x, sp.x.y, sp.x.z);
						this._effect.setFloat3("vSphericalY", sp.y.x, sp.y.y, sp.y.z);
						this._effect.setFloat3("vSphericalZ", sp.z.x, sp.z.y, sp.z.z);
						this._effect.setFloat3("vSphericalXX", sp.xx.x, sp.xx.y, sp.xx.z);
						this._effect.setFloat3("vSphericalYY", sp.yy.x, sp.yy.y, sp.yy.z);
						this._effect.setFloat3("vSphericalZZ", sp.zz.x, sp.zz.y, sp.zz.z);
						this._effect.setFloat3("vSphericalXY", sp.xy.x, sp.xy.y, sp.xy.z);
						this._effect.setFloat3("vSphericalYZ", sp.yz.x, sp.yz.y, sp.yz.z);
						this._effect.setFloat3("vSphericalZX", sp.zx.x, sp.zx.y, sp.zx.z);
					}
				}
				
				if (this.emissiveTexture != null && StandardMaterial.EmissiveTextureEnabled) {
					this._effect.setTexture("emissiveSampler", this.emissiveTexture);
					
					this._effect.setFloat2("vEmissiveInfos", this.emissiveTexture.coordinatesIndex, this.emissiveTexture.level);
					this._effect.setMatrix("emissiveMatrix", this.emissiveTexture.getTextureMatrix());
				}
				
				if (this.lightmapTexture != null && StandardMaterial.LightmapTextureEnabled) {
					this._effect.setTexture("lightmapSampler", this.lightmapTexture);
					
					this._effect.setFloat2("vLightmapInfos", this.lightmapTexture.coordinatesIndex, this.lightmapTexture.level);
					this._effect.setMatrix("lightmapMatrix", this.lightmapTexture.getTextureMatrix());
				}
				
				if (this.reflectivityTexture != null && StandardMaterial.SpecularTextureEnabled) {
					this._effect.setTexture("reflectivitySampler", this.reflectivityTexture);
					
					this._effect.setFloat2("vReflectivityInfos", this.reflectivityTexture.coordinatesIndex, this.reflectivityTexture.level);
					this._effect.setMatrix("reflectivityMatrix", this.reflectivityTexture.getTextureMatrix());
				}
				
				if (this.bumpTexture != null && this._myScene.getEngine().getCaps().standardDerivatives && StandardMaterial.BumpTextureEnabled && !this.disableBumpMap) {
					this._effect.setTexture("bumpSampler", this.bumpTexture);
					
					this._effect.setFloat3("vBumpInfos", this.bumpTexture.coordinatesIndex, 1.0 / this.bumpTexture.level, this.parallaxScaleBias);
					this._effect.setMatrix("bumpMatrix", this.bumpTexture.getTextureMatrix());
				}
				
				if (this.refractionTexture != null && StandardMaterial.RefractionTextureEnabled) {
					this._microsurfaceTextureLods.y = Math.round(Math.log(this.refractionTexture.getSize().width) * MathTools.LOG2E);
					
					var depth = 1.0;
					if (this.refractionTexture.isCube) {
						this._effect.setTexture("refractionCubeSampler", this.refractionTexture);
					} 
					else {
						this._effect.setTexture("refraction2DSampler", this.refractionTexture);
						this._effect.setMatrix("refractionMatrix", this.refractionTexture.getReflectionTextureMatrix());
						
						if (Std.is(this.refractionTexture, RefractionTexture)) {
							depth = untyped this.refractionTexture.depth;
						}
					}
					this._effect.setFloat4("vRefractionInfos", this.refractionTexture.level, this.indexOfRefraction, depth, this.invertRefractionY ? -1 : 1);
				}
				
				if ((this.reflectionTexture != null || this.refractionTexture != null)) {
					this._effect.setFloat2("vMicrosurfaceTextureLods", this._microsurfaceTextureLods.x, this._microsurfaceTextureLods.y);
				}
				
				if (this.cameraColorGradingTexture != null) {
					this._effect.setTexture("cameraColorGrading2DSampler", this.cameraColorGradingTexture);
					
					this._cameraColorGradingInfos.x = this.cameraColorGradingTexture.level;                     // Texture Level
					this._cameraColorGradingInfos.y = this.cameraColorGradingTexture.getSize().height;          // Texture Size example with 8
					this._cameraColorGradingInfos.z = this._cameraColorGradingInfos.y - 1.0;                    // SizeMinusOne 8 - 1
					this._cameraColorGradingInfos.w = 1 / this._cameraColorGradingInfos.y;                      // Space of 1 slice 1 / 8
					
					this._effect.setFloat4("vCameraColorGradingInfos", 
						this._cameraColorGradingInfos.x,
						this._cameraColorGradingInfos.y,
						this._cameraColorGradingInfos.z,
						this._cameraColorGradingInfos.w);
						
					var slicePixelSizeU = this._cameraColorGradingInfos.w / this._cameraColorGradingInfos.y;    // Space of 1 pixel in U direction, e.g. 1/64
					var slicePixelSizeV = 1.0 / this._cameraColorGradingInfos.y;							    // Space of 1 pixel in V direction, e.g. 1/8
					this._cameraColorGradingScaleOffset.x = this._cameraColorGradingInfos.z * slicePixelSizeU;  // Extent of lookup range in U for a single slice so that range corresponds to (size-1) texels, for example 7/64
					this._cameraColorGradingScaleOffset.y = this._cameraColorGradingInfos.z / this._cameraColorGradingInfos.y; // Extent of lookup range in V for a single slice so that range corresponds to (size-1) texels, for example 7/8
					this._cameraColorGradingScaleOffset.z = 0.5 * slicePixelSizeU;						        // Offset of lookup range in U to align sample position with texel centre, for example 0.5/64 
					this._cameraColorGradingScaleOffset.w = 0.5 * slicePixelSizeV;						        // Offset of lookup range in V to align sample position with texel centre, for example 0.5/8
					
					this._effect.setFloat4("vCameraColorGradingScaleOffset", 
						this._cameraColorGradingScaleOffset.x,
						this._cameraColorGradingScaleOffset.y,
						this._cameraColorGradingScaleOffset.z,
						this._cameraColorGradingScaleOffset.w);
				}
			}
			
			// Clip plane
			MaterialHelper.BindClipPlane(this._effect, this._myScene);
			
			// Point size
			if (this.pointsCloud) {
				this._effect.setFloat("pointSize", this.pointSize);
			}
			
			// Colors
			this._myScene.ambientColor.multiplyToRef(this.ambientColor, this._globalAmbientColor);
			
			// GAMMA CORRECTION.
			this.convertColorToLinearSpaceToRef(this.reflectivityColor, PBRMaterial._scaledReflectivity);
			
			this._effect.setVector3("vEyePosition", this._myScene._mirroredCameraPosition != null ? this._myScene._mirroredCameraPosition : this._myScene.activeCamera.position);
			this._effect.setColor3("vAmbientColor", this._globalAmbientColor);
			this._effect.setColor4("vReflectivityColor", PBRMaterial._scaledReflectivity, this.microSurface);
			
			// GAMMA CORRECTION.
			this.convertColorToLinearSpaceToRef(this.emissiveColor, PBRMaterial._scaledEmissive);
			this._effect.setColor3("vEmissiveColor", PBRMaterial._scaledEmissive);
			
			// GAMMA CORRECTION.
			this.convertColorToLinearSpaceToRef(this.reflectionColor, PBRMaterial._scaledReflection);
			this._effect.setColor3("vReflectionColor", PBRMaterial._scaledReflection);
		}

		if (this._myScene.getCachedMaterial() != this || !this.isFrozen) {
			// GAMMA CORRECTION.
			this.convertColorToLinearSpaceToRef(this.albedoColor, PBRMaterial._scaledAlbedo);
			this._effect.setColor4("vAlbedoColor", PBRMaterial._scaledAlbedo, this.alpha * mesh.visibility);
			
			// Lights
			if (this._myScene.lightsEnabled && !this.disableLighting) {
				PBRMaterial.BindLights(this._myScene, mesh, this._effect, this._defines, this.useScalarInLinearSpace, this.maxSimultaneousLights, this.usePhysicalLightFalloff);
			}
			
			// View
			if (this._myScene.fogEnabled && mesh.applyFog && this._myScene.fogMode != Scene.FOGMODE_NONE || this.reflectionTexture != null) {
				this._effect.setMatrix("view", this._myScene.getViewMatrix());
			}
			
			// Fog
			MaterialHelper.BindFogParameters(this._myScene, mesh, this._effect);
			
			this._lightingInfos.x = this.directIntensity;
			this._lightingInfos.y = this.emissiveIntensity;
			this._lightingInfos.z = this.environmentIntensity;
			this._lightingInfos.w = this.specularIntensity;
			
			this._effect.setVector4("vLightingIntensity", this._lightingInfos);
			
			this._overloadedShadowInfos.x = this.overloadedShadowIntensity;
			this._overloadedShadowInfos.y = this.overloadedShadeIntensity;
			this._effect.setVector4("vOverloadedShadowIntensity", this._overloadedShadowInfos);
			
			this._cameraInfos.x = this.cameraExposure;
			this._cameraInfos.y = this.cameraContrast;
			this._effect.setVector4("vCameraInfos", this._cameraInfos);
			
			this._overloadedIntensity.x = this.overloadedAmbientIntensity;
			this._overloadedIntensity.y = this.overloadedAlbedoIntensity;
			this._overloadedIntensity.z = this.overloadedReflectivityIntensity;
			this._overloadedIntensity.w = this.overloadedEmissiveIntensity;
			this._effect.setVector4("vOverloadedIntensity", this._overloadedIntensity);
			
			this.convertColorToLinearSpaceToRef(this.overloadedAmbient, this._tempColor);
			this._effect.setColor3("vOverloadedAmbient", this._tempColor);
			this.convertColorToLinearSpaceToRef(this.overloadedAlbedo, this._tempColor);
			this._effect.setColor3("vOverloadedAlbedo", this._tempColor);
			this.convertColorToLinearSpaceToRef(this.overloadedReflectivity, this._tempColor);
			this._effect.setColor3("vOverloadedReflectivity", this._tempColor);
			this.convertColorToLinearSpaceToRef(this.overloadedEmissive, this._tempColor);
			this._effect.setColor3("vOverloadedEmissive", this._tempColor);
			this.convertColorToLinearSpaceToRef(this.overloadedReflection, this._tempColor);
			this._effect.setColor3("vOverloadedReflection", this._tempColor);
			
			this._overloadedMicroSurface.x = this.overloadedMicroSurface;
			this._overloadedMicroSurface.y = this.overloadedMicroSurfaceIntensity;
			this._overloadedMicroSurface.z = this.overloadedReflectionIntensity;
			this._effect.setVector3("vOverloadedMicroSurface", this._overloadedMicroSurface);
			
			// Log. depth
			MaterialHelper.BindLogDepth(this._defines, this._effect, this._myScene);
		}
		super.bind(world, mesh);
		
		this._myScene = null;
	}

	public function getAnimatables():Array<IAnimatable> {
		var results:Array<IAnimatable> = [];
		
		if (this.albedoTexture != null && this.albedoTexture.animations != null && this.albedoTexture.animations.length > 0) {
			results.push(this.albedoTexture);
		}
		
		if (this.ambientTexture != null && this.ambientTexture.animations != null && this.ambientTexture.animations.length > 0) {
			results.push(this.ambientTexture);
		}
		
		if (this.opacityTexture != null && this.opacityTexture.animations != null && this.opacityTexture.animations.length > 0) {
			results.push(this.opacityTexture);
		}
		
		if (this.reflectionTexture != null && this.reflectionTexture.animations != null && this.reflectionTexture.animations.length > 0) {
			results.push(this.reflectionTexture);
		}
		
		if (this.emissiveTexture != null && this.emissiveTexture.animations != null && this.emissiveTexture.animations.length > 0) {
			results.push(this.emissiveTexture);
		}
		
		if (this.reflectivityTexture != null && this.reflectivityTexture.animations != null && this.reflectivityTexture.animations.length > 0) {
			results.push(this.reflectivityTexture);
		}
		
		if (this.bumpTexture != null && this.bumpTexture.animations != null && this.bumpTexture.animations.length > 0) {
			results.push(this.bumpTexture);
		}
		
		if (this.lightmapTexture != null && this.lightmapTexture.animations != null && this.lightmapTexture.animations.length > 0) {
			results.push(this.lightmapTexture);
		}
		
		if (this.refractionTexture != null && this.refractionTexture.animations != null && this.refractionTexture.animations.length > 0) {
			results.push(this.refractionTexture);
		}
		
		if (this.cameraColorGradingTexture != null && this.cameraColorGradingTexture.animations != null && this.cameraColorGradingTexture.animations.length > 0) {
			results.push(this.cameraColorGradingTexture);
		}
		
		return results;
	}

	override public function dispose(forceDisposeEffect:Bool = false, forceDisposeTextures:Bool = true) {
		if (forceDisposeTextures) {
			if (this.albedoTexture != null) {
				this.albedoTexture.dispose();
			}
			
			if (this.ambientTexture != null) {
				this.ambientTexture.dispose();
			}
			
			if (this.opacityTexture != null) {
				this.opacityTexture.dispose();
			}
			
			if (this.reflectionTexture != null) {
				this.reflectionTexture.dispose();
			}
			
			if (this.emissiveTexture != null) {
				this.emissiveTexture.dispose();
			}
			
			if (this.reflectivityTexture != null) {
				this.reflectivityTexture.dispose();
			}
			
			if (this.bumpTexture != null) {
				this.bumpTexture.dispose();
			}
			
			if (this.lightmapTexture != null) {
				this.lightmapTexture.dispose();
			}
			
			if (this.refractionTexture != null) {
				this.refractionTexture.dispose();
			}
			
			if (this.cameraColorGradingTexture != null) {
				this.cameraColorGradingTexture.dispose();
			}
		}
		
		super.dispose(forceDisposeEffect, forceDisposeTextures);
	}

	override public function clone(name:String, cloneChildren:Bool = false):PBRMaterial {
		// TODO
		//return SerializationHelper.Clone(() => new PBRMaterial(name, this.getScene()), this);
		return null;
	}

	override public function serialize():Dynamic {
		return SerializationHelper.Serialize(PBRMaterial, this, super.serialize());
	}

	// Statics
	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):PBRMaterial {
		// TODO
		//return SerializationHelper.Parse(() => new PBRMaterial(source.name, scene), source, scene, rootUrl);
		return null;
	}
	
}
