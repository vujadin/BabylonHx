package com.babylonhx.materials;

import com.babylonhx.engine.Engine;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Tmp;
import com.babylonhx.lights.Light;
import com.babylonhx.lights.IShadowLight;
import com.babylonhx.morph.MorphTargetManager;
import com.babylonhx.tools.Tools;
import com.babylonhx.materials.textures.BaseTexture;

import haxe.ds.Vector;

/**
 * ...
 * @author Krtolica Vujadin
 */
class MaterialHelper {
	
	static function setDirectUVPref(defines:MaterialDefines, key:String) {
		switch (key) {
			case "DIFFUSE":
				untyped defines.DIFFUSE = true;
				
			case "BUMP":
				untyped defines.BUMP = true;
				
			case "AMBIENT":
				untyped defines.AMBIENT = true;
				
			case "OPACITY":
				untyped defines.OPACITY = true;
				
			case "EMISSIVE":
				untyped defines.EMISSIVE = true;
				
			case "SPECULAR":
				untyped defines.SPECULAR = true;
				
			case "LIGHTMAP":
				untyped defines.LIGHTMAP = true;
				
			case "ALBEDO":
				untyped defines.ALBEDO = true;
				
			case "REFLECTIVITY":
				untyped defines.REFLECTIVITY = true;
				
			case "MICROSURFACEMAP":
				untyped defines.MICROSURFACEMAP = true;
		}
	}
	
	static function setDirectUV(defines:MaterialDefines, key:String, value:Int) {
		switch (key) {
			case "DIFFUSE":
				untyped defines.DIFFUSEDIRECTUV = value;
				
			case "BUMP":
				untyped defines.BUMPDIRECTUV = value;
				
			case "AMBIENT":
				untyped defines.AMBIENTDIRECTUV = value;
				
			case "OPACITY":
				untyped defines.OPACITYDIRECTUV = value;
				
			case "EMISSIVE":
				untyped defines.EMISSIVEDIRECTUV = value;
				
			case "SPECULAR":
				untyped defines.SPECULARDIRECTUV = value;
				
			case "LIGHTMAP":
				untyped defines.LIGHTMAPDIRECTUV = value;
				
			case "ALBEDO":
				untyped defines.ALBEDODIRECTUV = value;
				
			case "REFLECTIVITY":
				untyped defines.REFLECTIVITYDIRECTUV = value;
				
			case "MICROSURFACEMAP":
				untyped defines.MICROSURFACEMAPDIRECTUV = value;
		}
	}
	
	public static function BindEyePosition(effect:Effect, scene:Scene) {
		if (scene._forcedViewPosition != null) {
			effect.setVector3("vEyePosition", scene._forcedViewPosition);            
			return;
		}
		effect.setVector3("vEyePosition", scene._mirroredCameraPosition != null ? scene._mirroredCameraPosition : scene.activeCamera.globalPosition);      
	}
	
	public static function PrepareDefinesForMergedUV(texture:BaseTexture, defines:MaterialDefines, key:String) {
		defines._needUVs = true;
		setDirectUVPref(defines, key);
		if (texture.getTextureMatrix().isIdentity(true)) {
			setDirectUV(defines, key, texture.coordinatesIndex + 1);
			if (texture.coordinatesIndex == 0) {
				untyped defines.MAINUV1 = true;
			} 
			else {
				untyped defines.MAINUV2 = true;
			}
		} 
		else {
			setDirectUV(defines, key, 0);
		}
	}

	public static function BindTextureMatrix(texture:BaseTexture, uniformBuffer:UniformBuffer, key:String) {
		var matrix = texture.getTextureMatrix();
		
		if (!matrix.isIdentity(true)) {
			uniformBuffer.updateMatrix(key + "Matrix", matrix);
		}
	}
	
	public static function PrepareDefinesForMisc(mesh:AbstractMesh, scene:Scene, useLogarithmicDepth:Bool, pointsCloud:Bool, fogEnabled:Bool, defines:MaterialDefines) {
		if (defines._areMiscDirty) {
			untyped defines.LOGARITHMICDEPTH = useLogarithmicDepth;
			untyped defines.POINTSIZE = (pointsCloud || scene.forcePointsCloud);
			untyped defines.FOG = (scene.fogEnabled && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE && fogEnabled);
			untyped defines.NONUNIFORMSCALING = mesh.nonUniformScaling;
		}
	}

	public static function PrepareDefinesForFrameBoundValues(scene:Scene, engine:Engine, defines:MaterialDefines, useInstances:Bool, forceAlphaTest:Bool = false) {
		var changed:Bool = false;
		
		if (untyped defines.CLIPPLANE != (scene.clipPlane != null)) {
			untyped defines.CLIPPLANE = !defines.CLIPPLANE;
			changed = true;
		}
		
		if (untyped defines.ALPHATEST != engine.getAlphaTesting() || forceAlphaTest) {
			untyped defines.ALPHATEST = !defines.ALPHATEST;
			changed = true;
		}
		
		if (untyped defines.DEPTHPREPASS != !engine.getColorWrite()) {
            untyped defines.DEPTHPREPASS = !defines.DEPTHPREPASS;
            changed = true;
        } 
		
		if (untyped defines.INSTANCES != useInstances) {
			untyped defines.INSTANCES = useInstances;
			changed = true;
		}
		
		if (changed) {
			defines.markAsUnprocessed();
		}
	}

	public static function PrepareDefinesForAttributes(mesh:AbstractMesh, defines:MaterialDefines, useVertexColor:Bool, useBones:Bool, useMorphTargets:Bool = false):Bool {
		if (!defines._areAttributesDirty && defines._needNormals == defines._normals && defines._needUVs == defines._uvs) {
			return false;
		}
		
		defines._normals = defines._needNormals;
		defines._uvs = defines._needUVs;
		
		untyped defines.NORMAL = (defines._needNormals && mesh.isVerticesDataPresent(VertexBuffer.NormalKind));
		
		if (defines._needNormals && mesh.isVerticesDataPresent(VertexBuffer.TangentKind)) {
			untyped defines.TANGENT = true;
		}
		
		if (defines._needUVs) {
			untyped defines.UV1 = mesh.isVerticesDataPresent(VertexBuffer.UVKind);
			untyped defines.UV2 = mesh.isVerticesDataPresent(VertexBuffer.UV2Kind);
		} 
		else {
			untyped defines.UV1 = false;
			untyped defines.UV2 = false;
		}
		
		if (useVertexColor) {
			untyped defines.VERTEXCOLOR = mesh.useVertexColors && mesh.isVerticesDataPresent(VertexBuffer.ColorKind);
			untyped defines.VERTEXALPHA = mesh.hasVertexAlpha;
		}
		
		if (useBones) {
			if (mesh.useBones && mesh.computeBonesUsingShaders) {
				untyped defines.NUM_BONE_INFLUENCERS = mesh.numBoneInfluencers;
				untyped defines.BonesPerMesh = (mesh.skeleton.bones.length + 1);
			} 
			else {
				untyped defines.NUM_BONE_INFLUENCERS = 0;
				untyped defines.BonesPerMesh = 0;
			}           
		}
		
		if (useMorphTargets) {
			if (untyped mesh.morphTargetManager != null) {
				var manager:MorphTargetManager = untyped mesh.morphTargetManager;
				if (manager != null) {
					untyped defines.MORPHTARGETS_TANGENT = manager.supportsTangents && defines.TANGENT;
					untyped defines.MORPHTARGETS_NORMAL = manager.supportsNormals && defines.NORMAL;
					untyped defines.MORPHTARGETS = (manager.numInfluencers > 0);
					untyped defines.NUM_MORPH_INFLUENCERS = manager.numInfluencers;
				}
			} 
			else {
				untyped defines.MORPHTARGETS_TANGENT = false;
				untyped defines.MORPHTARGETS_NORMAL = false;
				untyped defines.MORPHTARGETS = false;
				untyped defines.NUM_MORPH_INFLUENCERS = 0;
			}
		}
		
		return true;
	}

	public static function PrepareDefinesForLights(scene:Scene, mesh:AbstractMesh, defines:MaterialDefines, specularSupported:Bool, maxSimultaneousLights:Int = 4, disableLighting:Bool = false):Bool {
		if (!defines._areLightsDirty) {
			return defines._needNormals;
		}
		
		var lightIndex:Int = 0;
		var needNormals:Bool = false;
		var needRebuild:Bool = false;
		var lightmapMode:Bool = false;
		var shadowEnabled:Bool = false;
		var specularEnabled:Bool = false;
		
		if (scene.lightsEnabled && !disableLighting) {
			for (light in mesh._lightSources) {
				needNormals = true;
				
				/*if (defines.lights[lightIndex] == null) {
					needRebuild = true;
				}*/
				
				defines.lights[lightIndex] = true;				
				defines.spotlights[lightIndex] = false;
				defines.hemilights[lightIndex] = false;
				defines.pointlights[lightIndex] = false;
				defines.dirlights[lightIndex] = false;
				
				switch (light.getTypeID()) {
					case Light.LIGHTTYPEID_SPOTLIGHT:
						defines.spotlights[lightIndex] = true;
						
					case Light.LIGHTTYPEID_HEMISPHERICLIGHT:
						defines.hemilights[lightIndex] = true;
						
					case Light.LIGHTTYPEID_POINTLIGHT:
						defines.pointlights[lightIndex] = true;
						
					case Light.LIGHTTYPEID_DIRECTIONALLIGHT:
						defines.dirlights[lightIndex] = true;
				}
				
				// Specular
				if (specularSupported && !light.specular.equalsFloats(0, 0, 0)) {
					specularEnabled = true;
				}
				
				// Shadows
				defines.shadows[lightIndex] = false;
				defines.shadowpcf[lightIndex] = false;
				defines.shadowesm[lightIndex] = false;
				defines.shadowcube[lightIndex] = false;
				
				if (mesh != null && mesh.receiveShadows && scene.shadowsEnabled && light.shadowEnabled) {
					var shadowGenerator = light.getShadowGenerator();
					if (shadowGenerator != null) {
						shadowEnabled = true;
						shadowGenerator.prepareDefines(defines, lightIndex);
					}
				}
				
				if (light.lightmapMode != Light.LIGHTMAP_DEFAULT ) {
					lightmapMode = true;
					defines.lightmapexcluded[lightIndex] = true;
					defines.lightmapnospecular[lightIndex] = (light.lightmapMode == Light.LIGHTMAP_SHADOWSONLY);
				} 
				else {
					defines.lightmapexcluded[lightIndex] = false;
					defines.lightmapnospecular[lightIndex] = false;
				}
				
				lightIndex++;
				if (lightIndex == maxSimultaneousLights) {
					break;
				}
			}
		}
		
		if (specularSupported) {
			untyped defines.SPECULARTERM = specularEnabled;
		}
		untyped defines.SHADOWS = shadowEnabled;
		
		// Resetting all other lights if any
		for (index in lightIndex...maxSimultaneousLights) {
			if (defines.lights.length > index) {
			//if (defines.lights[index] != null) {
				defines.lights[index] = false;
				defines.hemilights[index] = false;
				defines.pointlights[index] = false;
				defines.dirlights[index] = false;
				defines.spotlights[index] = false;
				defines.shadows[index] = false;
			}
		}
		
		var caps = scene.getEngine().getCaps();
		
		/*if (untyped defines.SHADOWFLOAT == null) {
			needRebuild = true;
		}*/
		
		untyped defines.SHADOWFLOAT = shadowEnabled && 
                                    ((caps.textureFloatRender && caps.textureFloatLinearFiltering) ||
                                         (caps.textureHalfFloatRender && caps.textureHalfFloatLinearFiltering));
		untyped defines.LIGHTMAPEXCLUDED = lightmapMode;
		
		/*if (needRebuild) {
			defines.rebuild();
		}*/
		
		return needNormals;
	}
	
	public static function PrepareUniformsAndSamplersList(uniformsListOrOptions:Dynamic, ?samplersList:Array<String>, ?defines:MaterialDefines, maxSimultaneousLights:Int = 4) {
		var uniformsList:Array<String> = null;
		var uniformBuffersList:Array<String> = null;
		/*var samplersList:Array<String> = null;
		var defines:MaterialDefines = null;*/
		
		if (uniformsListOrOptions.uniformsNames != null) {
			var options:EffectCreationOptions = cast uniformsListOrOptions;
			uniformsList = options.uniformsNames;
			uniformBuffersList = options.uniformBuffersNames;
			samplersList = options.samplers;
			defines = options.defines;
			maxSimultaneousLights = options.maxSimultaneousLights;
		} 
		else {
			uniformsList = cast uniformsListOrOptions;
			if (samplersList == null) {
				samplersList = [];
			}
		}
		
		for (lightIndex in 0...maxSimultaneousLights) {
			if (!defines.lights[lightIndex]) {
				break;
			}
			
			uniformsList.push("vLightData" + lightIndex);
			uniformsList.push("vLightDiffuse" + lightIndex);
			uniformsList.push("vLightSpecular" + lightIndex);
			uniformsList.push("vLightDirection" + lightIndex);
			uniformsList.push("vLightGround" + lightIndex);
			uniformsList.push("lightMatrix" + lightIndex);
			uniformsList.push("shadowsInfo" + lightIndex);
			uniformsList.push("depthValues" + lightIndex);
			
			if (uniformBuffersList != null) {
				uniformBuffersList.push("Light" + lightIndex);
			}
			
			samplersList.push("shadowSampler" + lightIndex);
		}
		
		if (untyped defines.NUM_MORPH_INFLUENCERS > 0) {
			uniformsList.push("morphTargetInfluences");
		}
	}

	public static function HandleFallbacksForShadows(defines:MaterialDefines, fallbacks:EffectFallbacks, maxSimultaneousLights:Int = 4, rank:Int = 0):Int {
		var lightFallbackRank:Int = 0;
		for (lightIndex in 0...maxSimultaneousLights) {
			if (defines.lights.length >= lightIndex || !defines.lights[lightIndex]) {
			//if (defines.lights[lightIndex] == null || !defines.lights[lightIndex]) {
				continue;
			}
			
			if (lightIndex > 0) {
				lightFallbackRank = rank + lightIndex;
				fallbacks.addFallback(lightFallbackRank, "LIGHT" + lightIndex);
			}
			
			if (! untyped defines.SHADOWS) {
				if (defines.shadows[lightIndex]) {
					fallbacks.addFallback(rank, "SHADOW" + lightIndex);
				}
				
				if (defines.shadowpcf[lightIndex]) {
					fallbacks.addFallback(rank, "SHADOWPCF" + lightIndex);
				}
				
				if (defines.shadowesm[lightIndex]) {
					fallbacks.addFallback(rank, "SHADOWESM" + lightIndex);
				}
			}
		}
		return lightFallbackRank++;
	}
	
	public static function PrepareAttributesForMorphTargets(attribs:Array<String>, mesh:AbstractMesh, defines:MaterialDefines) {
		var influencers:Int = untyped defines.NUM_MORPH_INFLUENCERS;

		if (influencers > 0 && Engine.LastCreatedEngine != null) {
			var maxAttributesCount = Engine.LastCreatedEngine.getCaps().maxVertexAttribs;
			var manager = cast (mesh, Mesh).morphTargetManager;
			var normal = manager != null && manager.supportsNormals && untyped defines.NORMAL;
			var tangent = manager != null && manager.supportsTangents && untyped defines.TANGENT;
			for (index in 0...influencers) {
				attribs.push(VertexBuffer.PositionKind + index);
				
				if (normal) {
					attribs.push(VertexBuffer.NormalKind + index);
				}
				
				if (tangent) {
					attribs.push(VertexBuffer.TangentKind + index);
				}
				
				if (attribs.length > maxAttributesCount) {
					Tools.Error("Cannot add more vertex attributes for mesh " + mesh.name);
				}
			}
		}
	}

	inline public static function PrepareAttributesForBones(attribs:Array<String>, mesh:AbstractMesh, numBoneInfluencers:Int, fallbacks:EffectFallbacks) {
		if (numBoneInfluencers > 0) {
			fallbacks.addCPUSkinningFallback(0, mesh);
			
			attribs.push(VertexBuffer.MatricesIndicesKind);
			attribs.push(VertexBuffer.MatricesWeightsKind);
			if (numBoneInfluencers > 4) {
				attribs.push(VertexBuffer.MatricesIndicesExtraKind);
				attribs.push(VertexBuffer.MatricesWeightsExtraKind);
			}
		}
	}

	public static function PrepareAttributesForInstances(attribs:Array<String>, defines:MaterialDefines) {
		if (untyped defines.INSTANCES == true) {
			attribs.push("world0");
			attribs.push("world1");
			attribs.push("world2");
			attribs.push("world3");
		}
	}

	// Bindings
	public static function BindLightShadow(light:Light, scene:Scene, mesh:AbstractMesh, lightIndex:String, effect:Effect) {
		if (light.shadowEnabled && mesh.receiveShadows) {
			var shadowGenerator = light.getShadowGenerator();
			if (shadowGenerator != null) {
				shadowGenerator.bindShadowLight(lightIndex, effect);
			}
		}
	}

	public static function BindLightProperties(light:Light, effect:Effect, lightIndex:Int) {
		light.transferToEffect(effect, lightIndex + "");
	}

	public static function BindLights(scene:Scene, mesh:AbstractMesh, effect:Effect, specularTerm:Bool, maxSimultaneousLights:Int = 4, usePhysicalLightFalloff:Bool = false) {
		var len:Int = cast Math.min(mesh._lightSources.length, maxSimultaneousLights);
		
		for (i in 0...len) {
			var light = mesh._lightSources[i];
			var iAsString = Std.string(i);
			
			var scaledIntensity = light.getScaledIntensity();
			light._uniformBuffer.bindToEffect(effect, "Light" + iAsString);
			
			MaterialHelper.BindLightProperties(light, effect, i);
			
			light.diffuse.scaleToRef(scaledIntensity, Tmp.color3[0]);
			light._uniformBuffer.updateColor4("vLightDiffuse", Tmp.color3[0], usePhysicalLightFalloff ? light.radius : light.range, iAsString);
			if (specularTerm) {
				light.specular.scaleToRef(scaledIntensity, Tmp.color3[1]);
				light._uniformBuffer.updateColor3("vLightSpecular", Tmp.color3[1], iAsString);
			}
			
			// Shadows
			if (scene.shadowsEnabled) {
				BindLightShadow(light, scene, mesh, iAsString, effect);
			}
			light._uniformBuffer.update();
		}
	}

	public static function BindFogParameters(scene:Scene, mesh:AbstractMesh, effect:Effect) {
		if (scene.fogEnabled && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE) {
			effect.setFloat4("vFogInfos", scene.fogMode, scene.fogStart, scene.fogEnd, scene.fogDensity);
			effect.setColor3("vFogColor", scene.fogColor);
		}
	}
	
	public static function BindBonesParameters(mesh:AbstractMesh, ?effect:Effect) {
		if (mesh != null && mesh.useBones && mesh.computeBonesUsingShaders && mesh.skeleton != null) {
			var matrices = mesh.skeleton.getTransformMatrices(mesh);
			
            if (matrices != null && effect != null) {
                effect.setMatrices("mBones", matrices);
            }
		}
	}
	
	public static function BindMorphTargetParameters(abstractMesh:AbstractMesh, effect:Effect) {
		var manager = cast (abstractMesh, Mesh).morphTargetManager;
        if (abstractMesh == null || manager == null) {
            return;
        }
		
		effect.setFloatArray("morphTargetInfluences", manager.influences);
	}
	
	public static function BindLogDepth(logarithmicDepth:Bool, effect:Effect, scene:Scene) {
        if (logarithmicDepth) {
            effect.setFloat("logarithmicDepthConstant", 2.0 / (Math.log(scene.activeCamera.maxZ + 1.0) / 0.6931471805599453));  // Math.LN2
        }
    }

    public static function BindClipPlane(effect:Effect, scene:Scene) {
        if (scene.clipPlane != null) {
            var clipPlane = scene.clipPlane;
            effect.setFloat4("vClipPlane", clipPlane.normal.x, clipPlane.normal.y, clipPlane.normal.z, clipPlane.d);
        }
    }
	
}
