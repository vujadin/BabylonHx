package com.babylonhx.materials;

import com.babylonhx.engine.Engine;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Tmp;
import com.babylonhx.math.Tools as MathTools;
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
/**
 * "Static Class" containing the most commonly used helper while dealing with material for 
 * rendering purpose.
 * 
 * It contains the basic tools to help defining defines, binding uniform for the common part of the materials.
 * 
 * This works by convention in BabylonJS but is meant to be use only with shader following the in place naming rules and conventions.
 */
class MaterialHelper {
	
	// BHX only !
	static function setDirectUVPref(defines:MaterialDefines, key:String) {
		switch (key) {
			case "DIFFUSE":
				untyped defines.DIFFUSE = 1;
				
			case "BUMP":
				untyped defines.BUMP = 1;
				
			case "AMBIENT":
				untyped defines.AMBIENT = 1;
				
			case "OPACITY":
				untyped defines.OPACITY = 1;
				
			case "EMISSIVE":
				untyped defines.EMISSIVE = 1;
				
			case "SPECULAR":
				untyped defines.SPECULAR = 1;
				
			case "LIGHTMAP":
				untyped defines.LIGHTMAP = 1;
				
			case "ALBEDO":
				untyped defines.ALBEDO = 1;
				
			case "REFLECTIVITY":
				untyped defines.REFLECTIVITY = 1;
				
			case "MICROSURFACEMAP":
				untyped defines.MICROSURFACEMAP = 1;
				
			default:
				throw "BHX: Unknown directUVpref!";
		}
	}
	
	// BHX only !
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
				
			default:
				throw "BHX: Unknown directUV!";
		}
	}
	
	/**
	 * Bind the current view position to an effect.
	 * @param effect The effect to be bound
	 * @param scene The scene the eyes position is used from
	 */
	public static function BindEyePosition(effect:Effect, scene:Scene) {
		if (scene._forcedViewPosition != null) {
			effect.setVector3("vEyePosition", scene._forcedViewPosition);            
			return;
		}
		effect.setVector3("vEyePosition", scene._mirroredCameraPosition != null ? scene._mirroredCameraPosition : scene.activeCamera.globalPosition);      
	}
	
	/**
	 * Helps preparing the defines values about the UVs in used in the effect.
	 * UVs are shared as much as we can accross chanels in the shaders.
	 * @param texture The texture we are preparing the UVs for
	 * @param defines The defines to update
	 * @param key The chanel key "diffuse", "specular"... used in the shader
	 */
	public static function PrepareDefinesForMergedUV(texture:BaseTexture, defines:MaterialDefines, key:String) {
		defines._needUVs = true;
		setDirectUVPref(defines, key);
		if (texture.getTextureMatrix().isIdentity(true)) {
			setDirectUV(defines, key, texture.coordinatesIndex + 1);
			if (texture.coordinatesIndex == 0) {
				untyped defines.MAINUV1 = 1;
			} 
			else {
				untyped defines.MAINUV2 = 1;
			}
		} 
		else {
			setDirectUV(defines, key, 0);
		}
	}

	/**
	 * Binds a texture matrix value to its corrsponding uniform
	 * @param texture The texture to bind the matrix for 
	 * @param uniformBuffer The uniform buffer receivin the data
	 * @param key The chanel key "diffuse", "specular"... used in the shader
	 */
	public static function BindTextureMatrix(texture:BaseTexture, uniformBuffer:UniformBuffer, key:String) {
		var matrix = texture.getTextureMatrix();
		
		if (!matrix.isIdentity(true)) {
			uniformBuffer.updateMatrix(key + "Matrix", matrix);
		}
	}
	
	/**
     * Helper used to prepare the list of defines associated with misc. values for shader compilation
     * @param mesh defines the current mesh
     * @param scene defines the current scene
     * @param useLogarithmicDepth defines if logarithmic depth has to be turned on
     * @param pointsCloud defines if point cloud rendering has to be turned on
     * @param fogEnabled defines if fog has to be turned on
     * @param alphaTest defines if alpha testing has to be turned on
     * @param defines defines the current list of defines
     */
	public static function PrepareDefinesForMisc(mesh:AbstractMesh, scene:Scene, useLogarithmicDepth:Bool, pointsCloud:Bool, fogEnabled:Bool, alphaTest:Bool, defines:MaterialDefines) {
		if (defines._areMiscDirty) {
			untyped defines.LOGARITHMICDEPTH = useLogarithmicDepth ? 1 : 0;
			untyped defines.POINTSIZE = (pointsCloud || scene.forcePointsCloud) ? 1 : 0;
			untyped defines.FOG = (scene.fogEnabled && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE && fogEnabled) ? 1 : 0;
			untyped defines.NONUNIFORMSCALING = mesh.nonUniformScaling ? 1 : 0;
			untyped defines.ALPHATEST = alphaTest ? 1 : 0;
		}
	}

	/**
     * Helper used to prepare the list of defines associated with frame values for shader compilation
     * @param scene defines the current scene
     * @param engine defines the current engine
     * @param defines specifies the list of active defines
     * @param useInstances defines if instances have to be turned on
     * @param alphaTest defines if alpha testing has to be turned on
     */
	public static function PrepareDefinesForFrameBoundValues(scene:Scene, engine:Engine, defines:MaterialDefines, useInstances:Bool, useClipPlane:Bool = null) {
		var changed:Bool = false;
		
		if (useClipPlane == null) {
			useClipPlane = (scene.clipPlane != null);
		}
		
		if (untyped defines.CLIPPLANE != (useClipPlane ? 1 : 0)) {
			untyped defines.CLIPPLANE = (useClipPlane ? 1 : 0);
			changed = true;
		}
		
		if (untyped defines.DEPTHPREPASS != !engine.getColorWrite() ? 1 : 0) {
            untyped defines.DEPTHPREPASS = defines.DEPTHPREPASS == 0 ? 1 : 0;
            changed = true;
        } 
		
		if (untyped defines.INSTANCES != (useInstances ? 1 : 0)) {
			untyped defines.INSTANCES = (useInstances ? 1 : 0);
			changed = true;
		}
		
		if (changed) {
			defines.markAsUnprocessed();
		}
	}

	/**
	 * Prepares the defines used in the shader depending on the attributes data available in the mesh
	 * @param mesh The mesh containing the geometry data we will draw
	 * @param defines The defines to update
	 * @param useVertexColor Precise whether vertex colors should be used or not (override mesh info)
	 * @param useBones Precise whether bones should be used or not (override mesh info)
	 * @param useMorphTargets Precise whether morph targets should be used or not (override mesh info)
	 * @param useVertexAlpha Precise whether vertex alpha should be used or not (override mesh info)
	 * @returns false if defines are considered not dirty and have not been checked
	 */
	public static function PrepareDefinesForAttributes(mesh:AbstractMesh, defines:MaterialDefines, useVertexColor:Bool, useBones:Bool, useMorphTargets:Bool = false, useVertexAlpha:Bool = true):Bool {
		if (!defines._areAttributesDirty && defines._needNormals == defines._normals && defines._needUVs == defines._uvs) {
			return false;
		}
		
		defines._normals = defines._needNormals;
		defines._uvs = defines._needUVs;
		
		untyped defines.NORMAL = (defines._needNormals && mesh.isVerticesDataPresent(VertexBuffer.NormalKind)) ? 1 : 0;
		
		if (defines._needNormals && mesh.isVerticesDataPresent(VertexBuffer.TangentKind)) {
			untyped defines.TANGENT = 1;
		}
		
		if (defines._needUVs) {
			untyped defines.UV1 = mesh.isVerticesDataPresent(VertexBuffer.UVKind) ? 1 : 0;
			untyped defines.UV2 = mesh.isVerticesDataPresent(VertexBuffer.UV2Kind) ? 1 : 0;
		} 
		else {
			untyped defines.UV1 = 0;
			untyped defines.UV2 = 0;
		}
		
		if (useVertexColor) {
			var hasVertexColors = mesh.useVertexColors && mesh.isVerticesDataPresent(VertexBuffer.ColorKind);
			untyped defines.VERTEXCOLOR = hasVertexColors;
			untyped defines.VERTEXALPHA = (mesh.hasVertexAlpha && hasVertexColors && useVertexAlpha) ? 1 : 0;
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
					untyped defines.MORPHTARGETS_TANGENT = manager.supportsTangents && defines.TANGENT ? 1 : 0;
					untyped defines.MORPHTARGETS_NORMAL = manager.supportsNormals && defines.NORMAL ? 1 : 0;
					untyped defines.MORPHTARGETS = (manager.numInfluencers > 0) ? 1 : 0;
					untyped defines.NUM_MORPH_INFLUENCERS = manager.numInfluencers;
				}
			} 
			else {
				untyped defines.MORPHTARGETS_TANGENT = 0;
				untyped defines.MORPHTARGETS_NORMAL = 0;
				untyped defines.MORPHTARGETS = 0;
				untyped defines.NUM_MORPH_INFLUENCERS = 0;
			}
		}
		
		return true;
	}

	/**
	 * Prepares the defines related to the light information passed in parameter
	 * @param scene The scene we are intending to draw
	 * @param mesh The mesh the effect is compiling for
	 * @param defines The defines to update
	 * @param specularSupported Specifies whether specular is supported or not (override lights data)
	 * @param maxSimultaneousLights Specfies how manuy lights can be added to the effect at max
	 * @param disableLighting Specifies whether the lighting is disabled (override scene and light)
	 * @returns true if normals will be required for the rest of the effect
	 */
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
						var spotLight:SpotLight = cast light;
						defines.PROJECTEDLIGHTTEXTURE[lightIndex] = spotLight.projectionTexture != null ? spotLight.projectionTexture.isReady() : false;
						
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
		
		untyped defines.SPECULARTERM = specularEnabled ? 1 : 0;		
		untyped defines.SHADOWS = shadowEnabled ? 1 : 0;
		
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
		
		untyped defines.SHADOWFLOAT = (shadowEnabled && 
                                    ((caps.textureFloatRender && caps.textureFloatLinearFiltering) ||
                                         (caps.textureHalfFloatRender && caps.textureHalfFloatLinearFiltering))) ? 1 : 0;
		untyped defines.LIGHTMAPEXCLUDED = lightmapMode;
		
		/*if (needRebuild) {
			defines.rebuild();
		}*/
		
		return needNormals;
	}
	
	/**
	 * Prepares the uniforms and samplers list to be used in the effect. This can automatically remove from the list uniforms 
	 * that won t be acctive due to defines being turned off.
	 * @param uniformsListOrOptions The uniform names to prepare or an EffectCreationOptions containing the liist and extra information
	 * @param samplersList The samplers list
	 * @param defines The defines helping in the list generation
	 * @param maxSimultaneousLights The maximum number of simultanous light allowed in the effect
	 */
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
			
			if (defines.PROJECTEDLIGHTTEXTURE[lightIndex]) {
				samplersList.push("projectionLightSampler" + lightIndex);
				uniformsList.push("textureProjectionMatrix" + lightIndex);
			}
		}
		
		if (untyped defines.NUM_MORPH_INFLUENCERS > 0) {
			uniformsList.push("morphTargetInfluences");
		}
	}

	/**
	 * This helps decreasing rank by rank the shadow quality (0 being the highest rank and quality)
	 * @param defines The defines to update while falling back
	 * @param fallbacks The authorized effect fallbacks
	 * @param maxSimultaneousLights The maximum number of lights allowed
	 * @param rank the current rank of the Effect
	 * @returns The newly affected rank
	 */
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
	
	/**
	 * Prepares the list of attributes required for morph targets according to the effect defines.
	 * @param attribs The current list of supported attribs
	 * @param mesh The mesh to prepare the morph targets attributes for
	 * @param defines The current Defines of the effect
	 */
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

	/**
	 * Prepares the list of attributes required for bones according to the effect defines.
	 * @param attribs The current list of supported attribs
	 * @param mesh The mesh to prepare the bones attributes for
	 * @param defines The current Defines of the effect
	 * @param fallbacks The current efffect fallback strategy
	 */
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

	/**
	 * Prepares the list of attributes required for instances according to the effect defines.
	 * @param attribs The current list of supported attribs
	 * @param defines The current Defines of the effect
	 */
	public static function PrepareAttributesForInstances(attribs:Array<String>, defines:MaterialDefines) {
		if (untyped defines.INSTANCES == true) {
			attribs.push("world0");
			attribs.push("world1");
			attribs.push("world2");
			attribs.push("world3");
		}
	}

	/**
	 * Binds the light shadow information to the effect for the given mesh.
	 * @param light The light containing the generator
	 * @param scene The scene the lights belongs to
	 * @param mesh The mesh we are binding the information to render 
	 * @param lightIndex The light index in the effect used to render the mesh
	 * @param effect The effect we are binding the data to
	 */
	public static function BindLightShadow(light:Light, scene:Scene, mesh:AbstractMesh, lightIndex:String, effect:Effect) {
		if (light.shadowEnabled && mesh.receiveShadows) {
			var shadowGenerator = light.getShadowGenerator();
			if (shadowGenerator != null) {
				shadowGenerator.bindShadowLight(lightIndex, effect);
			}
		}
	}

	/**
	 * Binds the light information to the effect.
	 * @param light The light containing the generator
	 * @param effect The effect we are binding the data to
	 * @param lightIndex The light index in the effect used to render
	 */
	public static function BindLightProperties(light:Light, effect:Effect, lightIndex:Int) {
		light.transferToEffect(effect, lightIndex + "");
	}

	/**
	 * Binds the lights information from the scene to the effect for the given mesh.
	 * @param scene The scene the lights belongs to
	 * @param mesh The mesh we are binding the information to render 
	 * @param effect The effect we are binding the data to
	 * @param defines The generated defines for the effect
	 * @param maxSimultaneousLights The maximum number of light that can be bound to the effect
	 * @param usePhysicalLightFalloff Specifies whether the light falloff is defined physically or not
	 */
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

	/**
	 * Binds the fog information from the scene to the effect for the given mesh.
	 * @param scene The scene the lights belongs to
	 * @param mesh The mesh we are binding the information to render 
	 * @param effect The effect we are binding the data to
	 */
	public static function BindFogParameters(scene:Scene, mesh:AbstractMesh, effect:Effect) {
		if (scene.fogEnabled && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE) {
			effect.setFloat4("vFogInfos", scene.fogMode, scene.fogStart, scene.fogEnd, scene.fogDensity);
			effect.setColor3("vFogColor", scene.fogColor);
		}
	}
	
	/**
	 * Binds the bones information from the mesh to the effect.
	 * @param mesh The mesh we are binding the information to render 
	 * @param effect The effect we are binding the data to
	 */
	public static function BindBonesParameters(mesh:AbstractMesh, ?effect:Effect) {
		if (mesh != null && mesh.useBones && mesh.computeBonesUsingShaders && mesh.skeleton != null) {
			var matrices = mesh.skeleton.getTransformMatrices(mesh);
			
            if (matrices != null && effect != null) {
                effect.setMatrices("mBones", matrices);
            }
		}
	}
	
	/**
	 * Binds the morph targets information from the mesh to the effect.
	 * @param abstractMesh The mesh we are binding the information to render 
	 * @param effect The effect we are binding the data to
	 */
	public static function BindMorphTargetParameters(abstractMesh:AbstractMesh, effect:Effect) {
		var manager = cast (abstractMesh, Mesh).morphTargetManager;
        if (abstractMesh == null || manager == null) {
            return;
        }
		
		effect.setFloatArray("morphTargetInfluences", manager.influences);
	}
	
	/**
	 * Binds the logarithmic depth information from the scene to the effect for the given defines.
	 * @param defines The generated defines used in the effect
	 * @param effect The effect we are binding the data to
	 * @param scene The scene we are willing to render with logarithmic scale for
	 */
	public static function BindLogDepth(logarithmicDepth:Bool, effect:Effect, scene:Scene) {
        if (logarithmicDepth) {
            effect.setFloat("logarithmicDepthConstant", 2.0 / (Math.log(scene.activeCamera.maxZ + 1.0) / MathTools.LN2));  // Math.LN2
        }
    }

	/**
	 * Binds the clip plane information from the scene to the effect.
	 * @param scene The scene the clip plane information are extracted from
	 * @param effect The effect we are binding the data to
	 */
    public static function BindClipPlane(effect:Effect, scene:Scene) {
        if (scene.clipPlane != null) {
            var clipPlane = scene.clipPlane;
            effect.setFloat4("vClipPlane", clipPlane.normal.x, clipPlane.normal.y, clipPlane.normal.z, clipPlane.d);
        }
    }
	
}
