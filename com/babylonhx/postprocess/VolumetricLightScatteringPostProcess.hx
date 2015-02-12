package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.Engine;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Viewport;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.tools.SmartArray;

/**
 * ...
 * @author Krtolica Vujadin
 */

class VolumetricLightScatteringPostProcess extends PostProcess {
	
	// Members
	private var _godRaysPass:Effect;
	private var _godRaysRTT:RenderTargetTexture;
	private var _viewPort:Viewport;
	private var _screenCoordinates:Vector2 = Vector2.Zero();
	private var _cachedDefines:String;
	private var _customLightPosition:Vector3;

	/**
	* Set if the post-process should use a custom position for the light source (true) or the internal mesh position (false)
	* @type {boolean}
	*/
	public var useCustomLightPosition:Bool = false;
	/**
	* If the post-process should inverse the light scattering direction
	* @type {boolean}
	*/
	public var invert:Bool = true;
	/**
	* The internal mesh used by the post-process
	* @type {boolean}
	*/
	public var mesh:Mesh;
	

	/**
	 * @constructor
	 * @param {string} name - The post-process name
	 * @param {number} ratio - The size of the postprocesses (0.5 means that your postprocess will have a width = canvas.width 0.5 and a height = canvas.height 0.5)
	 * @param {BABYLON.Camera} camera - The camera that the post-process will be attached to
	 * @param {BABYLON.Mesh} mesh - The mesh used to create the light scattering
	 * @param {number} samplingMode - The post-process filtering mode
	 * @param {BABYLON.Engine} engine - The babylon engine
	 * @param {boolean} reusable - If the post-process is reusable
	 */
	public function new(name:String, ratio:Float, camera:Camera, ?mesh:Mesh, ?samplingMode:Int, ?engine:Engine, ?reusable:Bool) {
		super(name, "volumetricLightScattering", ["lightPositionOnScreen"], ["lightScatteringSampler"], ratio, camera, samplingMode, engine, reusable);
		var scene = camera.getScene();
		
		this._viewPort = new Viewport(0, 0, 1, 1).toGlobal(scene.getEngine());
		
		// Configure mesh
		this.mesh = (mesh != null) ? mesh : VolumetricLightScatteringPostProcess.CreateDefaultMesh("VolumetricLightScatteringMesh", scene);
		
		// Configure
		this._createPass(scene);
		
		this.onApply = function(effect:Effect) {
			this._updateScreenCoordinates(scene);
			
			effect.setTexture("lightScatteringSampler", this._godRaysRTT);
			effect.setVector2("lightPositionOnScreen", this._screenCoordinates);
		};
	}

	public function isReady(subMesh:SubMesh, useInstances:Bool):Bool {
		var mesh:Mesh = subMesh.getMesh();
		var scene:Scene = mesh.getScene();
		
		var defines:Array<String> = [];
		var attribs:Array<String> = [VertexBuffer.PositionKind];
		var material:Material = subMesh.getMaterial();
		
		// Render this.mesh as default
		if (mesh == this.mesh) {
			defines.push("#define BASIC_RENDER");
		}
		
		// Alpha test
		if (material != null) {
			if (material.needAlphaTesting() || mesh == this.mesh) {
				defines.push("#define ALPHATEST");
			}
			
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
		if (mesh.useBones) {
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
			this._godRaysPass = mesh.getScene().getEngine().createEffect(
				{ vertexElement: "depth", fragmentElement: "volumetricLightScatteringPass" },
				attribs,
				["world", "mBones", "viewProjection", "diffuseMatrix", "far"],
				["diffuseSampler"], join);
		}
		
		return this._godRaysPass.isReady();
	}

	/**
	 * Sets the new light position for light scattering effect
	 * @param {BABYLON.Vector3} The new custom light position
	 */
	public function setLightPosition(position:Vector3) {
		this._customLightPosition = position;
	}

	/**
	 * Returns the light position for light scattering effect
	 * @return {BABYLON.Vector3} The custom light position
	 */
	public function getLightPosition():Vector3 {
		return this._customLightPosition;
	}

	/**
	 * Disposes the internal assets and detaches the post-process from the camera
	 */
	public function dispose(camera:Camera) {
		this._godRaysRTT.dispose();
		super.dispose(camera);
	}

	/**
	 * Returns the render target texture used by the post-process
	 * @return {BABYLON.RenderTargetTexture} The render target texture used by the post-process
	 */
	public function getPass():RenderTargetTexture {
		return this._godRaysRTT;
	}

	// Private methods
	private function _createPass(scene:Scene) {
		var engine = scene.getEngine();
		
		this._godRaysRTT = new RenderTargetTexture("volumetricLightScatteringMap", { width: engine.getRenderWidth(), height: engine.getRenderHeight() }, scene, false, true, Engine.TEXTURETYPE_UNSIGNED_INT);
		this._godRaysRTT.wrapU = Texture.CLAMP_ADDRESSMODE;
		this._godRaysRTT.wrapV = Texture.CLAMP_ADDRESSMODE;
		this._godRaysRTT.renderList = null;
		this._godRaysRTT.renderParticles = false;
		scene.customRenderTargets.push(this._godRaysRTT);
		
		// Custom render function for submeshes
		var renderSubMesh = function(subMesh:SubMesh) {
			var mesh:Mesh = subMesh.getRenderingMesh();
			var scene:Scene = mesh.getScene();
			var engine:Engine = scene.getEngine();
			
			// Culling
			engine.setState(subMesh.getMaterial().backFaceCulling);
			
			// Managing instances
			var batch = mesh._getInstancesRenderList(subMesh._id);
			
			if (batch.mustReturn) {
				return;
			}
			
			var hardwareInstancedRendering:Bool = (engine.getCaps().instancedArrays != null) && (batch.visibleInstances[subMesh._id] != null);
			
			if (this.isReady(subMesh, hardwareInstancedRendering)) {
				engine.enableEffect(this._godRaysPass);
				mesh._bind(subMesh, this._godRaysPass, Material.TriangleFillMode);
				var material:Material = subMesh.getMaterial();
				
				this._godRaysPass.setMatrix("viewProjection", scene.getTransformMatrix());
				
				// Alpha test
				if (material != null && (mesh == this.mesh || material.needAlphaTesting())) {
					var alphaTexture = material.getAlphaTestTexture();
					this._godRaysPass.setTexture("diffuseSampler", alphaTexture);
					this._godRaysPass.setMatrix("diffuseMatrix", alphaTexture.getTextureMatrix());
				}
				
				// Bones
				if (mesh.useBones) {
					this._godRaysPass.setMatrices("mBones", mesh.skeleton.getTransformMatrices());
				}
				
				// Draw
				mesh._processRendering(subMesh, this._godRaysPass, Material.TriangleFillMode, batch, hardwareInstancedRendering,
					(isInstance, world) => this._godRaysPass.setMatrix("world", world));
			}
		};
		
		// Render target texture callbacks
		var savedSceneClearColor:Color3;
		var sceneClearColor:Color3 = new Color3(0.0, 0.0, 0.0);
		
		this._godRaysRTT.onBeforeRender = function() {
			savedSceneClearColor = scene.clearColor;
			scene.clearColor = sceneClearColor;
		};
		
		this._godRaysRTT.onAfterRender = function() {
			scene.clearColor = savedSceneClearColor;
		};
		
		this._godRaysRTT.customRenderFunction = function(opaqueSubMeshes:SmartArray, alphaTestSubMeshes:SmartArray) {
			for (index in 0...opaqueSubMeshes.length) {
				renderSubMesh(opaqueSubMeshes.data[index]);
			}
			
			for (index in 0...alphaTestSubMeshes.length) {
				renderSubMesh(alphaTestSubMeshes.data[index]);
			}
		};
	}

	private function _updateScreenCoordinates(scene:Scene) {
		var transform:Matrix = scene.getTransformMatrix();
		var pos = Vector3.Project(this.useCustomLightPosition ? this._customLightPosition : this.mesh.position, Matrix.Identity(), transform, this._viewPort);
		
		this._screenCoordinates.x = pos.x / this._viewPort.width;
		this._screenCoordinates.y = pos.y / this._viewPort.height;
		
		if (this.invert) {
			this._screenCoordinates.y = 1.0 - this._screenCoordinates.y;
		}
	}

	// Static methods
	
	/**
	* Creates a default mesh for the Volumeric Light Scattering post-process
	* @param {string} The mesh name
	* @param {BABYLON.Scene} The scene where to create the mesh
	* @return {BABYLON.Mesh} the default mesh
	*/
	public static function CreateDefaultMesh(name:String, scene:Scene):Mesh {
		var mesh = Mesh.CreatePlane(name, 1, scene);
		mesh.billboardMode = AbstractMesh.BILLBOARDMODE_ALL;
		mesh.material = new StandardMaterial(name + "Material", scene);
		
		return mesh;
	}
	
}
