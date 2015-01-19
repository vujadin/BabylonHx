package com.babylonhx.lights.shadows;

import com.babylonhx.Engine;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.ShadowGenerator') class ShadowGenerator {
	
	public static var FILTER_NONE:Int = 0;
	public static var FILTER_VARIANCESHADOWMAP:Int = 1;
	public static var FILTER_POISSONSAMPLING:Int = 2;


	// Members
	public var filter:Int = ShadowGenerator.FILTER_VARIANCESHADOWMAP;

	public var useVarianceShadowMap(get, set):Bool;
	private function get_useVarianceShadowMap():Bool {
		return this.filter == ShadowGenerator.FILTER_VARIANCESHADOWMAP;
	}
	private function set_useVarianceShadowMap(value:Bool):Bool {
		this.filter = (value ? ShadowGenerator.FILTER_VARIANCESHADOWMAP : ShadowGenerator.FILTER_NONE);
		return value;
	}

	public var usePoissonSampling(get, set):Bool;
	private function get_usePoissonSampling():Bool {
		return this.filter == ShadowGenerator.FILTER_POISSONSAMPLING;
	}
	private function set_usePoissonSampling(value:Bool):Bool {
		this.filter = (value ? ShadowGenerator.FILTER_POISSONSAMPLING : ShadowGenerator.FILTER_NONE);
		return value;
	}

	private var _light:DirectionalLight;
	private var _scene:Scene;
	private var _shadowMap:RenderTargetTexture;
	private var _darkness:Float = 0;
	private var _transparencyShadow:Bool = false;
	private var _effect:Effect;

	private var _viewMatrix:Matrix = Matrix.Zero();
	private var _projectionMatrix:Matrix = Matrix.Zero();
	private var _transformMatrix:Matrix = Matrix.Zero();
	private var _worldViewProjection:Matrix = Matrix.Zero();
	private var _cachedPosition:Vector3;
	private var _cachedDirection:Vector3;
	private var _cachedDefines:String;

	
	public function new(mapSize:Float, light:DirectionalLight) {
		this._light = light;
		this._scene = light.getScene();
		
		light._shadowGenerator = this;
		
		// Render target
		this._shadowMap = new RenderTargetTexture(light.name + "_shadowMap", mapSize, this._scene, false);
		this._shadowMap.wrapU = Texture.CLAMP_ADDRESSMODE;
		this._shadowMap.wrapV = Texture.CLAMP_ADDRESSMODE;
		this._shadowMap.renderParticles = false;
		
		// Custom render function
		var renderSubMesh = function(subMesh:SubMesh) {
			var mesh:Mesh = subMesh.getRenderingMesh();
			var scene:Scene = this._scene;
			var engine:Engine = scene.getEngine();
			
			// Culling
			engine.setState(subMesh.getMaterial().backFaceCulling);
			
			// Managing instances
			var batch = mesh._getInstancesRenderList(subMesh._id);
			
			if (batch.mustReturn) {
				return;
			}
			
			var hardwareInstancedRendering = (engine.getCaps().instancedArrays != null) && (batch.visibleInstances[subMesh._id] != null);
			
			if (this.isReady(subMesh, hardwareInstancedRendering)) {
				engine.enableEffect(this._effect);
				mesh._bind(subMesh, this._effect, Material.TriangleFillMode);
				var material = subMesh.getMaterial();
				
				this._effect.setMatrix("viewProjection", this.getTransformMatrix());
				
				// Alpha test
				if (material != null && material.needAlphaTesting()) {
					var alphaTexture = material.getAlphaTestTexture();
					this._effect.setTexture("diffuseSampler", alphaTexture);
					this._effect.setMatrix("diffuseMatrix", alphaTexture.getTextureMatrix());
				}
				
				// Bones
				var useBones = mesh.skeleton != null && scene.skeletonsEnabled && mesh.isVerticesDataPresent(VertexBuffer.MatricesIndicesKind) && mesh.isVerticesDataPresent(VertexBuffer.MatricesWeightsKind);
				
				if (useBones) {
					this._effect.setMatrices("mBones", mesh.skeleton.getTransformMatrices());
				}
				
				if (hardwareInstancedRendering) {
					mesh._renderWithInstances(subMesh, Material.TriangleFillMode, batch, this._effect, engine);
				} else {
					if (batch.renderSelf[subMesh._id]) {
						this._effect.setMatrix("world", mesh.getWorldMatrix());
						
						// Draw
						mesh._draw(subMesh, Material.TriangleFillMode);
					}
					
					if (batch.visibleInstances[subMesh._id] != null) {
						for (instanceIndex in 0...batch.visibleInstances[subMesh._id].length) {
							var instance = batch.visibleInstances[subMesh._id][instanceIndex];
							
							this._effect.setMatrix("world", instance.getWorldMatrix());
							
							// Draw
							mesh._draw(subMesh, Material.TriangleFillMode);
						}
					}
				}
			} else {
				// Need to reset refresh rate of the shadowMap
				this._shadowMap.resetRefreshCounter();
			}
		};

		//this._shadowMap.customRenderFunction = function(opaqueSubMeshes:SmartArray<SubMesh>, alphaTestSubMeshes:SmartArray<SubMesh>, transparentSubMeshes:SmartArray<SubMesh>):Void {
		this._shadowMap.customRenderFunction = function(opaqueSubMeshes:SmartArray, alphaTestSubMeshes:SmartArray, transparentSubMeshes:SmartArray):Void {
			
			for (index in 0...opaqueSubMeshes.length) {
				renderSubMesh(opaqueSubMeshes.data[index]);
			}
			
			for (index in 0...alphaTestSubMeshes.length) {
				renderSubMesh(alphaTestSubMeshes.data[index]);
			}
			
			if (this._transparencyShadow) {
				for (index in 0...transparentSubMeshes.length) {
					renderSubMesh(transparentSubMeshes.data[index]);
				}
			}
		};

	}

	public function isReady(subMesh:SubMesh, useInstances:Bool):Bool {
		var defines:Array<String> = [];
		
		if (this.useVarianceShadowMap) {
			defines.push("#define VSM");
		}
		
		var attribs:Array<String> = [VertexBuffer.PositionKind];
		
		var mesh = subMesh.getMesh();
		var scene = mesh.getScene();
		var material = subMesh.getMaterial();
		
		// Alpha test
		if (material != null && material.needAlphaTesting()) {
			defines.push("#define ALPHATEST");
			if (mesh.isVerticesDataPresent(VertexBuffer.UVKind)) {
				attribs.push(VertexBuffer.UVKind);
				defines.push("#define UV1");
			}
			if (mesh.isVerticesDataPresent(VertexBuffer.UV2Kind)) {
				attribs.push(VertexBuffer.UV2Kind);
				defines.push("#define UV2");
			}
		}
		
		// Bones
		if (mesh.skeleton != null && scene.skeletonsEnabled && mesh.isVerticesDataPresent(VertexBuffer.MatricesIndicesKind) && mesh.isVerticesDataPresent(VertexBuffer.MatricesWeightsKind)) {
			attribs.push(VertexBuffer.MatricesIndicesKind);
			attribs.push(VertexBuffer.MatricesWeightsKind);
			defines.push("#define BONES");
			defines.push("#define BonesPerMesh " + (mesh.skeleton.bones.length + 1));
		}
		
		// Instances
		if (useInstances) {
			defines.push("#define INSTANCES");
			attribs.push("world0");
			attribs.push("world1");
			attribs.push("world2");
			attribs.push("world3");
		}
		
		// Get correct effect      
		var join = defines.join("\n");
		if (this._cachedDefines != join) {
			this._cachedDefines = join;
			this._effect = this._scene.getEngine().createEffect("shadowMap",
				attribs,
				["world", "mBones", "viewProjection", "diffuseMatrix"],
				["diffuseSampler"], join);
		}
		
		return this._effect.isReady();
	}

	public function getShadowMap():RenderTargetTexture {
		return this._shadowMap;
	}

	public function getLight():DirectionalLight {
		return this._light;
	}

	// Methods
	public function getTransformMatrix():Matrix {
		var lightPosition = this._light.position;
		var lightDirection = this._light.direction;
		
		if (this._light._computeTransformedPosition()) {
			lightPosition = this._light._transformedPosition;
		}
		
		if (this._cachedPosition == null || this._cachedDirection == null || !lightPosition.equals(this._cachedPosition) || !lightDirection.equals(this._cachedDirection)) {
			
			this._cachedPosition = lightPosition.clone();
			this._cachedDirection = lightDirection.clone();
			
			var activeCamera = this._scene.activeCamera;
			
			Matrix.LookAtLHToRef(lightPosition, this._light.position.add(lightDirection), Vector3.Up(), this._viewMatrix);
			Matrix.PerspectiveFovLHToRef(Math.PI / 2.0, 1.0, activeCamera.minZ, activeCamera.maxZ, this._projectionMatrix);
			
			this._viewMatrix.multiplyToRef(this._projectionMatrix, this._transformMatrix);
		}
		
		return this._transformMatrix;
	}

	public function getDarkness():Float {
		return this._darkness;
	}

	public function setDarkness(darkness:Float) {
		if (darkness >= 1.0)
			this._darkness = 1.0;
		else if (darkness <= 0.0)
			this._darkness = 0.0;
		else
			this._darkness = darkness;
	}

	public function setTransparencyShadow(hasShadow:Bool):Void {
		this._transparencyShadow = hasShadow;
	}

	public function dispose():Void {
		this._shadowMap.dispose();
	}
	
}
