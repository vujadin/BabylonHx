package com.babylonhx.materials;

import com.babylonhx.Engine;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
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

/**
 * ...
 * @author Krtolica Vujadin
 */

class StandardMaterial extends Material {
	
	// Flags used to enable or disable a type of texture for all Standard Materials
	public static var DiffuseTextureEnabled:Bool = true;
	public static var AmbientTextureEnabled:Bool = true;
	public static var OpacityTextureEnabled:Bool = true;
	public static var ReflectionTextureEnabled:Bool = true;
	public static var EmissiveTextureEnabled:Bool = true;
	public static var SpecularTextureEnabled:Bool = true;
	public static var BumpTextureEnabled:Bool = true;
	
	public var diffuseTexture:Texture = null;
	public var ambientTexture:Texture = null;
	public var opacityTexture:Texture = null;
	public var reflectionTexture:Texture = null;
	public var emissiveTexture:Texture = null;
	public var specularTexture:Texture = null;
	public var bumpTexture:Texture = null;

	public var ambientColor:Color3 = new Color3(0, 0, 0);
	public var diffuseColor:Color3 = new Color3(1, 1, 1);
	public var specularColor:Color3 = new Color3(1, 1, 1);
	public var specularPower:Int = 64;
	public var emissiveColor:Color3 = new Color3(0, 0, 0);
	public var useAlphaFromDiffuseTexture:Bool = false;
	public var useSpecularOverAlpha:Bool = true;
	public var fogEnabled:Bool = true;

	public var diffuseFresnelParameters:FresnelParameters;
	public var opacityFresnelParameters:FresnelParameters;
	public var reflectionFresnelParameters:FresnelParameters;
	public var emissiveFresnelParameters:FresnelParameters;

	private var _cachedDefines:String = null;
	private var _renderTargets:SmartArray = new SmartArray(16);// SmartArray<RenderTargetTexture> = new SmartArray<RenderTargetTexture>(16);
	private var _worldViewProjectionMatrix:Matrix = Matrix.Zero();
	private var _globalAmbientColor:Color3 = new Color3(0, 0, 0);
	private var _scaledDiffuse:Color3 = new Color3();
	private var _scaledSpecular:Color3 = new Color3();
	private var _renderId:Int = -1;
	
	private var maxSimultaneousLights:Int = 4;
	

	public function new(name:String, scene:Scene) {
		super(name, scene);

		this.getRenderTargetTextures = function():SmartArray/*<RenderTargetTexture>*/ {
			this._renderTargets.reset();

			if (this.reflectionTexture != null && this.reflectionTexture.isRenderTarget) {
				this._renderTargets.push(this.reflectionTexture);
			}

			return this._renderTargets;
		}
	}

	override public function needAlphaBlending():Bool {
		return (this.alpha < 1.0) || (this.opacityTexture != null) || this._shouldUseAlphaFromDiffuseTexture() || (this.opacityFresnelParameters != null) && this.opacityFresnelParameters.isEnabled;
	}

	override public function needAlphaTesting():Bool {
		return this.diffuseTexture != null && this.diffuseTexture.hasAlpha && !this.diffuseTexture.getAlphaFromRGB;
	}

	private function _shouldUseAlphaFromDiffuseTexture():Bool {
		return this.diffuseTexture != null && this.diffuseTexture.hasAlpha && this.useAlphaFromDiffuseTexture;
	}

	override public function getAlphaTestTexture():Texture {
		return this.diffuseTexture;
	}

	// Methods   
	override public function isReady(?mesh:AbstractMesh, useInstances:Bool = false/*?useInstances:Bool*/):Bool {
		if (this.checkReadyOnlyOnce) {
			if (this._wasPreviouslyReady) {
				return true;
			}
		}

		var scene = this.getScene();

		if (!this.checkReadyOnEveryCall) {
			if (this._renderId == scene.getRenderId()) {
				return true;
			}
		}

		var engine:Engine = scene.getEngine();
		var defines:Array<String> = [];
		var fallbacks:EffectFallbacks = new EffectFallbacks();

		// Textures
		if (scene.texturesEnabled) {
			if (this.diffuseTexture != null && StandardMaterial.DiffuseTextureEnabled) {
				if (!this.diffuseTexture.isReady()) {
					return false;
				} else {
					defines.push("#define DIFFUSE");
				}
			}

			if (this.ambientTexture != null && StandardMaterial.AmbientTextureEnabled) {
				if (!this.ambientTexture.isReady()) {
					return false;
				} else {
					defines.push("#define AMBIENT");
				}
			}

			if (this.opacityTexture != null && StandardMaterial.OpacityTextureEnabled) {
				if (!this.opacityTexture.isReady()) {
					return false;
				} else {
					defines.push("#define OPACITY");

					if (this.opacityTexture.getAlphaFromRGB) {
						defines.push("#define OPACITYRGB");
					}
				}
			}

			if (this.reflectionTexture != null && StandardMaterial.ReflectionTextureEnabled) {
				if (!this.reflectionTexture.isReady()) {
					return false;
				} else {
					defines.push("#define REFLECTION");
					fallbacks.addFallback(0, "REFLECTION");
				}
			}

			if (this.emissiveTexture != null && StandardMaterial.EmissiveTextureEnabled) {
				if (!this.emissiveTexture.isReady()) {
					return false;
				} else {
					defines.push("#define EMISSIVE");
				}
			}

			if (this.specularTexture != null && StandardMaterial.SpecularTextureEnabled) {
				if (!this.specularTexture.isReady()) {
					return false;
				} else {
					defines.push("#define SPECULAR");
					fallbacks.addFallback(0, "SPECULAR");
				}
			}
		}

		if (scene.getEngine().getCaps().standardDerivatives != null && this.bumpTexture != null && StandardMaterial.BumpTextureEnabled) {
			if (!this.bumpTexture.isReady()) {
				return false;
			} else {
				defines.push("#define BUMP");
				fallbacks.addFallback(0, "BUMP");
			}
		}

		// Effect
		if (this.useSpecularOverAlpha) {
			defines.push("#define SPECULAROVERALPHA");
			fallbacks.addFallback(0, "SPECULAROVERALPHA");
		}

		if (scene.clipPlane != null) {
			defines.push("#define CLIPPLANE");
		}

		if (engine.getAlphaTesting()) {
			defines.push("#define ALPHATEST");
		}

		if (this._shouldUseAlphaFromDiffuseTexture()) {
			defines.push("#define ALPHAFROMDIFFUSE");
		}

		// Point size
		if (this.pointsCloud) {
			defines.push("#define POINTSIZE");
		}

		// Fog
		if (scene.fogMode != Scene.FOGMODE_NONE && this.fogEnabled) {
			defines.push("#define FOG");
			fallbacks.addFallback(1, "FOG");
		}

		var shadowsActivated:Bool = false;
		var lightIndex:Int = 0;
		if (scene.lightsEnabled) {
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

				defines.push("#define LIGHT" + lightIndex);

				if (lightIndex > 0) {
					fallbacks.addFallback(lightIndex, "LIGHT" + lightIndex);
				}

				var type:String = "";
				if (Std.is(light, SpotLight)) {
					type = "#define SPOTLIGHT" + lightIndex;
				} else if (Std.is(light, HemisphericLight)) {
					type = "#define HEMILIGHT" + lightIndex;
				} else {
					type = "#define POINTDIRLIGHT" + lightIndex;
				}

				defines.push(type);
				if (lightIndex > 0) {
					fallbacks.addFallback(lightIndex, StringTools.replace(type, "#define ", ""));
				}

				// Shadows
				if (scene.shadowsEnabled) {
					var shadowGenerator = light.getShadowGenerator();
					if (mesh != null && mesh.receiveShadows && shadowGenerator != null) {
						defines.push("#define SHADOW" + lightIndex);
						fallbacks.addFallback(0, "SHADOW" + lightIndex);

						if (!shadowsActivated) {
							defines.push("#define SHADOWS");
							shadowsActivated = true;
						}

						if (shadowGenerator.useVarianceShadowMap) {
							defines.push("#define SHADOWVSM" + lightIndex);
							if (lightIndex > 0) {
								fallbacks.addFallback(0, "SHADOWVSM" + lightIndex);
							}
						}

						if (shadowGenerator.usePoissonSampling) {
							defines.push("#define SHADOWPCF" + lightIndex);
							if (lightIndex > 0) {
								fallbacks.addFallback(0, "SHADOWPCF" + lightIndex);
							}
						}
					}
				}

				lightIndex++;
				if (lightIndex == maxSimultaneousLights)
					break;
			}
		}

		// Fresnel
		if (this.diffuseFresnelParameters != null && this.diffuseFresnelParameters.isEnabled ||
			this.opacityFresnelParameters != null && this.opacityFresnelParameters.isEnabled ||
			this.emissiveFresnelParameters != null && this.emissiveFresnelParameters.isEnabled ||
			this.reflectionFresnelParameters != null && this.reflectionFresnelParameters.isEnabled) {

			var fresnelRank:Int = 1;

			if (this.diffuseFresnelParameters != null && this.diffuseFresnelParameters.isEnabled) {
				defines.push("#define DIFFUSEFRESNEL");
				fallbacks.addFallback(fresnelRank, "DIFFUSEFRESNEL");
				fresnelRank++;
			}

			if (this.opacityFresnelParameters != null && this.opacityFresnelParameters.isEnabled) {
				defines.push("#define OPACITYFRESNEL");
				fallbacks.addFallback(fresnelRank, "OPACITYFRESNEL");
				fresnelRank++;
			}

			if (this.reflectionFresnelParameters != null && this.reflectionFresnelParameters.isEnabled) {
				defines.push("#define REFLECTIONFRESNEL");
				fallbacks.addFallback(fresnelRank, "REFLECTIONFRESNEL");
				fresnelRank++;
			}

			if (this.emissiveFresnelParameters != null && this.emissiveFresnelParameters.isEnabled) {
				defines.push("#define EMISSIVEFRESNEL");
				fallbacks.addFallback(fresnelRank, "EMISSIVEFRESNEL");
				fresnelRank++;
			}

			defines.push("#define FRESNEL");
			fallbacks.addFallback(fresnelRank - 1, "FRESNEL");
		}


		// Attribs
		var attribs:Array<String> = [VertexBuffer.PositionKind, VertexBuffer.NormalKind];
		if (mesh != null) {
			if (mesh.isVerticesDataPresent(VertexBuffer.UVKind)) {
				attribs.push(VertexBuffer.UVKind);
				defines.push("#define UV1");
			}
			if (mesh.isVerticesDataPresent(VertexBuffer.UV2Kind)) {
				attribs.push(VertexBuffer.UV2Kind);
				defines.push("#define UV2");
			}
			if (mesh.useVertexColors && mesh.isVerticesDataPresent(VertexBuffer.ColorKind)) {
				attribs.push(VertexBuffer.ColorKind);
				defines.push("#define VERTEXCOLOR");
			}
			if (mesh.hasVertexAlpha) {
				defines.push("#define VERTEXALPHA");
			}
			if (mesh.skeleton != null && scene.skeletonsEnabled && mesh.isVerticesDataPresent(VertexBuffer.MatricesIndicesKind) && mesh.isVerticesDataPresent(VertexBuffer.MatricesWeightsKind)) {
				attribs.push(VertexBuffer.MatricesIndicesKind);
				attribs.push(VertexBuffer.MatricesWeightsKind);
				defines.push("#define BONES");
				defines.push("#define BonesPerMesh " + (mesh.skeleton.bones.length + 1));
				defines.push("#define BONES4");
				fallbacks.addFallback(0, "BONES4");
			}
			
			// Instances
			if (useInstances) {
				defines.push("#define INSTANCES");
				attribs.push("world0");
				attribs.push("world1");
				attribs.push("world2");
				attribs.push("world3");
			}
		}
		
		// Get correct effect      
		var join:String = defines.join("\n");
		if (this._cachedDefines != join) {
			this._cachedDefines = join;
			
			scene.resetCachedMaterial();
			
			// Legacy browser patch
			var shaderName = "default";
			if (!scene.getEngine().getCaps().standardDerivatives) {
				shaderName = "legacydefault";
			}
			
			this._effect = scene.getEngine().createEffect(shaderName,
				attribs,
				["world", "view", "viewProjection", "vEyePosition", "vLightsType", "vAmbientColor", "vDiffuseColor", "vSpecularColor", "vEmissiveColor",
					"vLightData0", "vLightDiffuse0", "vLightSpecular0", "vLightDirection0", "vLightGround0", "lightMatrix0",
					"vLightData1", "vLightDiffuse1", "vLightSpecular1", "vLightDirection1", "vLightGround1", "lightMatrix1",
					"vLightData2", "vLightDiffuse2", "vLightSpecular2", "vLightDirection2", "vLightGround2", "lightMatrix2",
					"vLightData3", "vLightDiffuse3", "vLightSpecular3", "vLightDirection3", "vLightGround3", "lightMatrix3",
					"vFogInfos", "vFogColor", "pointSize",
					"vDiffuseInfos", "vAmbientInfos", "vOpacityInfos", "vReflectionInfos", "vEmissiveInfos", "vSpecularInfos", "vBumpInfos",
					"mBones",
					"vClipPlane", "diffuseMatrix", "ambientMatrix", "opacityMatrix", "reflectionMatrix", "emissiveMatrix", "specularMatrix", "bumpMatrix",
					"darkness0", "darkness1", "darkness2", "darkness3",
					"diffuseLeftColor", "diffuseRightColor", "opacityParts", "reflectionLeftColor", "reflectionRightColor", "emissiveLeftColor", "emissiveRightColor"
				],
				["diffuseSampler", "ambientSampler", "opacitySampler", "reflectionCubeSampler", "reflection2DSampler", "emissiveSampler", "specularSampler", "bumpSampler",
					"shadowSampler0", "shadowSampler1", "shadowSampler2", "shadowSampler3"
				],
				join, fallbacks, this.onCompiled, this.onError);
		}
		if (!this._effect.isReady()) {
			return false;
		}
		
		this._renderId = scene.getRenderId();
		this._wasPreviouslyReady = true;
		return true;
	}
	
	override public function unbind() {
		if (this.reflectionTexture != null && this.reflectionTexture.isRenderTarget) {
			this._effect.setTexture("reflection2DSampler", null);
		}
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
		if (mesh.skeleton != null && scene.skeletonsEnabled && mesh.isVerticesDataPresent(VertexBuffer.MatricesIndicesKind) && mesh.isVerticesDataPresent(VertexBuffer.MatricesWeightsKind)) {
			this._effect.setMatrices("mBones", mesh.skeleton.getTransformMatrices());
		}

		if (scene.getCachedMaterial() != this) {
			// Fresnel
			if (this.diffuseFresnelParameters != null && this.diffuseFresnelParameters.isEnabled) {
				this._effect.setColor4("diffuseLeftColor", this.diffuseFresnelParameters.leftColor, this.diffuseFresnelParameters.power);
				this._effect.setColor4("diffuseRightColor", this.diffuseFresnelParameters.rightColor, this.diffuseFresnelParameters.bias);
			}

			if (this.opacityFresnelParameters != null && this.opacityFresnelParameters.isEnabled) {
				this._effect.setColor4("opacityParts", new Color3(this.opacityFresnelParameters.leftColor.toLuminance(), this.opacityFresnelParameters.rightColor.toLuminance(), this.opacityFresnelParameters.bias), this.opacityFresnelParameters.power);
			}

			if (this.reflectionFresnelParameters != null && this.reflectionFresnelParameters.isEnabled) {
				this._effect.setColor4("reflectionLeftColor", this.reflectionFresnelParameters.leftColor, this.reflectionFresnelParameters.power);
				this._effect.setColor4("reflectionRightColor", this.reflectionFresnelParameters.rightColor, this.reflectionFresnelParameters.bias);
			}

			if (this.emissiveFresnelParameters != null && this.emissiveFresnelParameters.isEnabled) {
				this._effect.setColor4("emissiveLeftColor", this.emissiveFresnelParameters.leftColor, this.emissiveFresnelParameters.power);
				this._effect.setColor4("emissiveRightColor", this.emissiveFresnelParameters.rightColor, this.emissiveFresnelParameters.bias);
			}

			// Textures        
			if (this.diffuseTexture != null && StandardMaterial.DiffuseTextureEnabled) {
				this._effect.setTexture("diffuseSampler", this.diffuseTexture);

				this._effect.setFloat2("vDiffuseInfos", this.diffuseTexture.coordinatesIndex, this.diffuseTexture.level);
				this._effect.setMatrix("diffuseMatrix", this.diffuseTexture.getTextureMatrix());
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
				if (this.reflectionTexture.isCube) {
					this._effect.setTexture("reflectionCubeSampler", this.reflectionTexture);
				} else {
					this._effect.setTexture("reflection2DSampler", this.reflectionTexture);
				}

				this._effect.setMatrix("reflectionMatrix", this.reflectionTexture.getReflectionTextureMatrix());
				this._effect.setFloat3("vReflectionInfos", this.reflectionTexture.coordinatesMode, this.reflectionTexture.level, this.reflectionTexture.isCube ? 1 : 0);
			}

			if (this.emissiveTexture != null && StandardMaterial.EmissiveTextureEnabled) {
				this._effect.setTexture("emissiveSampler", this.emissiveTexture);

				this._effect.setFloat2("vEmissiveInfos", this.emissiveTexture.coordinatesIndex, this.emissiveTexture.level);
				this._effect.setMatrix("emissiveMatrix", this.emissiveTexture.getTextureMatrix());
			}

			if (this.specularTexture != null && StandardMaterial.SpecularTextureEnabled) {
				this._effect.setTexture("specularSampler", this.specularTexture);

				this._effect.setFloat2("vSpecularInfos", this.specularTexture.coordinatesIndex, this.specularTexture.level);
				this._effect.setMatrix("specularMatrix", this.specularTexture.getTextureMatrix());
			}

			if (this.bumpTexture != null && scene.getEngine().getCaps().standardDerivatives && StandardMaterial.BumpTextureEnabled) {
				this._effect.setTexture("bumpSampler", this.bumpTexture);

				this._effect.setFloat2("vBumpInfos", this.bumpTexture.coordinatesIndex, 1.0 / this.bumpTexture.level);
				this._effect.setMatrix("bumpMatrix", this.bumpTexture.getTextureMatrix());
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

			// Colors
			scene.ambientColor.multiplyToRef(this.ambientColor, this._globalAmbientColor);

			// Scaling down color according to emissive
			this._scaledSpecular.r = this.specularColor.r * Tools.Clamp(1.0 - this.emissiveColor.r);
			this._scaledSpecular.g = this.specularColor.g * Tools.Clamp(1.0 - this.emissiveColor.g);
			this._scaledSpecular.b = this.specularColor.b * Tools.Clamp(1.0 - this.emissiveColor.b);

			this._effect.setVector3("vEyePosition", scene.activeCamera.position);
			this._effect.setColor3("vAmbientColor", this._globalAmbientColor);
			this._effect.setColor4("vSpecularColor", this._scaledSpecular, this.specularPower);
			this._effect.setColor3("vEmissiveColor", this.emissiveColor);
		}

		// Scaling down color according to emissive
		this._scaledDiffuse.r = this.diffuseColor.r * Tools.Clamp(1.0 - this.emissiveColor.r);
		this._scaledDiffuse.g = this.diffuseColor.g * Tools.Clamp(1.0 - this.emissiveColor.g);
		this._scaledDiffuse.b = this.diffuseColor.b * Tools.Clamp(1.0 - this.emissiveColor.b);

		this._effect.setColor4("vDiffuseColor", this._scaledDiffuse, this.alpha * mesh.visibility);

		if (scene.lightsEnabled) {
			var lightIndex = 0;
			for (index in 0...scene.lights.length) {
				var light = scene.lights[index];

				if (!light.isEnabled()) {
					continue;
				}

				if (!light.canAffectMesh(mesh)) {
					continue;
				}

				if (Std.is(light, PointLight)) {
					// Point Light
					light.transferToEffect(this._effect, "vLightData" + lightIndex);
				} else if (Std.is(light, DirectionalLight)) {
					// Directional Light
					light.transferToEffect(this._effect, "vLightData" + lightIndex);
				} else if (Std.is(light, SpotLight)) {
					// Spot Light
					light.transferToEffect(this._effect, "vLightData" + lightIndex, "vLightDirection" + lightIndex);
				} else if (Std.is(light, HemisphericLight)) {
					// Hemispheric Light
					light.transferToEffect(this._effect, "vLightData" + lightIndex, "vLightGround" + lightIndex);
				}

				light.diffuse.scaleToRef(light.intensity, this._scaledDiffuse);
				light.specular.scaleToRef(light.intensity, this._scaledSpecular);
				this._effect.setColor4("vLightDiffuse" + lightIndex, this._scaledDiffuse, light.range);
				this._effect.setColor3("vLightSpecular" + lightIndex, this._scaledSpecular);

				// Shadows
				if (scene.shadowsEnabled) {
					var shadowGenerator = light.getShadowGenerator();
					if (mesh.receiveShadows && shadowGenerator != null) {
						this._effect.setMatrix("lightMatrix" + lightIndex, shadowGenerator.getTransformMatrix());
						this._effect.setTexture("shadowSampler" + lightIndex, shadowGenerator.getShadowMap());
						this._effect.setFloat("darkness" + lightIndex, shadowGenerator.getDarkness());
					}
				}

				lightIndex++;

				if (lightIndex == maxSimultaneousLights)
					break;
			}
		}

		// View
		if (mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE || this.reflectionTexture != null) {
			this._effect.setMatrix("view", scene.getViewMatrix());
		}

		// Fog
		if (mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE) {
			this._effect.setFloat4("vFogInfos", scene.fogMode, scene.fogStart, scene.fogEnd, scene.fogDensity);
			this._effect.setColor3("vFogColor", scene.fogColor);
		}

		super.bind(world, mesh);
	}

	public function getAnimatables():Array<Dynamic> {
		var results:Array<Dynamic> = [];

		if (this.diffuseTexture != null && this.diffuseTexture.animations != null && this.diffuseTexture.animations.length > 0) {
			results.push(this.diffuseTexture);
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

		if (this.specularTexture != null && this.specularTexture.animations != null && this.specularTexture.animations.length > 0) {
			results.push(this.specularTexture);
		}

		if (this.bumpTexture != null && this.bumpTexture.animations != null && this.bumpTexture.animations.length > 0) {
			results.push(this.bumpTexture);
		}

		return results;
	}

	override public function dispose(forceDisposeEffect:Bool = false/*?forceDisposeEffect:Bool*/) {
		if (this.diffuseTexture != null) {
			this.diffuseTexture.dispose();
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

		if (this.specularTexture != null) {
			this.specularTexture.dispose();
		}

		if (this.bumpTexture != null) {
			this.bumpTexture.dispose();
		}

		super.dispose(forceDisposeEffect);
	}

	public function clone(name:String):StandardMaterial {
		var newStandardMaterial = new StandardMaterial(name, this.getScene());

		// Base material
		newStandardMaterial.checkReadyOnEveryCall = this.checkReadyOnEveryCall;
		newStandardMaterial.alpha = this.alpha;
		newStandardMaterial.fillMode = this.fillMode;
		newStandardMaterial.backFaceCulling = this.backFaceCulling;

		// Standard material
		if (this.diffuseTexture != null) {
			newStandardMaterial.diffuseTexture = this.diffuseTexture.clone();
		}
		if (this.ambientTexture != null) {
			newStandardMaterial.ambientTexture = this.ambientTexture.clone();
		}
		if (this.opacityTexture != null) {
			newStandardMaterial.opacityTexture = this.opacityTexture.clone();
		}
		if (this.reflectionTexture != null) {
			newStandardMaterial.reflectionTexture = this.reflectionTexture.clone();
		}
		if (this.emissiveTexture != null) {
			newStandardMaterial.emissiveTexture = this.emissiveTexture.clone();
		}
		if (this.specularTexture != null) {
			newStandardMaterial.specularTexture = this.specularTexture.clone();
		}
		if (this.bumpTexture != null) {
			newStandardMaterial.bumpTexture = this.bumpTexture.clone();
		}

		newStandardMaterial.ambientColor = this.ambientColor.clone();
		newStandardMaterial.diffuseColor = this.diffuseColor.clone();
		newStandardMaterial.specularColor = this.specularColor.clone();
		newStandardMaterial.specularPower = this.specularPower;
		newStandardMaterial.emissiveColor = this.emissiveColor.clone();

		return newStandardMaterial;
	}

}
