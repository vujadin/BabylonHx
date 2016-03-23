package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.Engine;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
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

// Inspired by http://http.developer.nvidia.com/GPUGems3/gpugems3_ch13.html
@:expose('BABYLON.VolumetricLightScatteringPostProcess') class VolumetricLightScatteringPostProcess extends PostProcess {
	
	// Members
	private var _volumetricLightScatteringPass:Effect;
    private var _volumetricLightScatteringRTT:RenderTargetTexture;
	private var _viewPort:Viewport;
	private var _screenCoordinates:Vector2 = Vector2.Zero();
	private var _cachedDefines:String;
	private var _customMeshPosition:Vector3;

	/**
	* Set if the post-process should use a custom position for the light source (true) or the internal mesh position (false)
	*/
	public var useCustomMeshPosition:Bool = false;
	/**
	* If the post-process should inverse the light scattering direction
	*/
	public var invert:Bool = true;
	/**
	* The internal mesh used by the post-process
	*/
	public var mesh:Mesh;	
	/**
	* Set to true to use the diffuseColor instead of the diffuseTexture
	*/
	public var useDiffuseColor:Bool = false;
	
	/**
    * Array containing the excluded meshes not rendered in the internal pass
    */
    public var excludedMeshes:Array<AbstractMesh> = [];

	/**
	* Controls the overall intensity of the post-process
	*/
    public var exposure:Float = 0.3;
	/**
	* Dissipates each sample's contribution in range [0, 1]
	*/
    public var decay:Float = 0.96815;
	/**
	* Controls the overall intensity of each sample
	*/
    public var weight:Float = 0.58767;
	/**
	* Controls the density of each sample
	*/
    public var density:Float = 0.926;
	

	/**
	 * @constructor
	 * @param {string} name - The post-process name
	 * @param {any} ratio - The size of the post-process and/or internal pass (0.5 means that your postprocess will have a width = canvas.width 0.5 and a height = canvas.height 0.5)
	 * @param {BABYLON.Camera} camera - The camera that the post-process will be attached to
	 * @param {BABYLON.Mesh} mesh - The mesh used to create the light scattering
	 * @param {number} samples - The post-process quality, default 100
	 * @param {number} samplingMode - The post-process filtering mode
	 * @param {BABYLON.Engine} engine - The babylon engine
	 * @param {boolean} reusable - If the post-process is reusable
	 * @param {BABYLON.Scene} scene - The constructor needs a scene reference to initialize internal components. If "camera" is null "scene" must be provided
	 */
	public function new(name:String, ratio:Dynamic, ?camera:Camera, ?mesh:Mesh, samples:Int = 100, samplingMode:Int = Texture.BILINEAR_SAMPLINGMODE, ?engine:Engine, ?reusable:Bool, ?scene:Scene) {
		super(name, "volumetricLightScattering", ["decay", "exposure", "weight", "meshPositionOnScreen", "density"], ["lightScatteringSampler"], ratio.postProcessRatio != null ? ratio.postProcessRatio : ratio, camera, samplingMode, engine, reusable, "#define NUM_SAMPLES " + samples);
		if(camera != null) {
			scene = camera.getScene();
		} 
		
		var engine = scene.getEngine();
		this._viewPort = new Viewport(0, 0, 1, 1).toGlobal(engine.getRenderWidth(), engine.getRenderHeight());
		
		// Configure mesh
		this.mesh = (mesh != null) ? mesh : VolumetricLightScatteringPostProcess.CreateDefaultMesh("VolumetricLightScatteringMesh", scene);
		
		// Configure
		this._createPass(scene, ratio.passRatio != null ? ratio.passRatio : ratio);
		
		this.onActivate = function(camera:Camera) {
            if (!this.isSupported) {
                this.dispose(camera);
            }
			
            this.onActivate = null;
        };
		
		this.onApply = function(effect:Effect) {
			this._updateMeshScreenCoordinates(scene);
			
			effect.setTexture("lightScatteringSampler", this._volumetricLightScatteringRTT);
			effect.setFloat("exposure", this.exposure);
			effect.setFloat("decay", this.decay);
			effect.setFloat("weight", this.weight);
			effect.setFloat("density", this.density);
			effect.setVector2("meshPositionOnScreen", this._screenCoordinates);
		};
	}

	public function isReady(subMesh:SubMesh, useInstances:Bool):Bool {
		var mesh:Mesh = cast subMesh.getMesh();
		
		var defines:Array<String> = [];
		var attribs:Array<String> = [VertexBuffer.PositionKind];
		var material:Material = subMesh.getMaterial();
		var needUV:Bool = false;
		
		// Render this.mesh as default
		if (mesh == this.mesh) {
			if (this.useDiffuseColor) {
				defines.push("#define DIFFUSE_COLOR_RENDER");
			} 
			else if (material != null) {
				if (cast(material, StandardMaterial).diffuseTexture != null) {
					defines.push("#define BASIC_RENDER");
				} 
				else {
					defines.push("#define DIFFUSE_COLOR_RENDER");
				}
			}
			defines.push("#define NEED_UV");
			needUV = true;
		}
		
		// Alpha test
		if (material != null) {
			if (material.needAlphaTesting()) {
				defines.push("#define ALPHATEST");
			}
			
			if (cast(material, StandardMaterial).opacityTexture != null) {
                defines.push("#define OPACITY");
				if (cast(material, StandardMaterial).opacityTexture.getAlphaFromRGB) {
                    defines.push("#define OPACITYRGB");
				}
				if (!needUV) {
					defines.push("#define NEED_UV");
				}
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
		if (mesh.useBones && mesh.computeBonesUsingShaders) {
			attribs.push(VertexBuffer.MatricesIndicesKind);
			attribs.push(VertexBuffer.MatricesWeightsKind);
			defines.push("#define NUM_BONE_INFLUENCERS " + mesh.numBoneInfluencers);
			defines.push("#define BonesPerMesh " + (mesh.skeleton.bones.length + 1));
		}
		else {
			defines.push("#define NUM_BONE_INFLUENCERS 0"); 
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
			this._volumetricLightScatteringPass = mesh.getScene().getEngine().createEffect(
				{ vertex: "depth", fragment: "volumetricLightScatteringPass" },
				attribs,
				["world", "mBones", "viewProjection", "diffuseMatrix", "opacityLevel", "color"],
				["diffuseSampler", "opacitySampler"], join);
		}
		
		return this._volumetricLightScatteringPass.isReady();
	}

	/**
	 * Sets the new light position for light scattering effect
	 * @param {BABYLON.Vector3} The new custom light position
	 */
	public function setCustomMeshPosition(position:Vector3) {
		this._customMeshPosition = position;
	}

	/**
	 * Returns the light position for light scattering effect
	 * @return {BABYLON.Vector3} The custom light position
	 */
	public function getCustomMeshPosition():Vector3 {
		return this._customMeshPosition;
	}

	/**
	 * Disposes the internal assets and detaches the post-process from the camera
	 */
	override public function dispose(?camera:Camera) {
		var rttIndex = camera.getScene().customRenderTargets.indexOf(this._volumetricLightScatteringRTT);
		if (rttIndex != -1) {
			camera.getScene().customRenderTargets.splice(rttIndex, 1);
		}
			
		this._volumetricLightScatteringRTT.dispose();
		super.dispose(camera);
	}

	/**
	 * Returns the render target texture used by the post-process
	 * @return {BABYLON.RenderTargetTexture} The render target texture used by the post-process
	 */
	public function getPass():RenderTargetTexture {
		return this._volumetricLightScatteringRTT;
	}
	
	// Private methods
	private function _meshExcluded(mesh:AbstractMesh):Bool {
		if (this.excludedMeshes.length > 0 && this.excludedMeshes.indexOf(mesh) != -1) {
			return true;
		}
		
		return false;
	}

	// Private methods
	private function _createPass(scene:Scene, ratio:Float) {
		var engine = scene.getEngine();
		
		this._volumetricLightScatteringRTT = new RenderTargetTexture("volumetricLightScatteringMap", Std.int(engine.getRenderWidth() * ratio), scene, false, true, Engine.TEXTURETYPE_UNSIGNED_INT);
		this._volumetricLightScatteringRTT.wrapU = Texture.CLAMP_ADDRESSMODE;
		this._volumetricLightScatteringRTT.wrapV = Texture.CLAMP_ADDRESSMODE;
		this._volumetricLightScatteringRTT.renderList = null;
		this._volumetricLightScatteringRTT.renderParticles = false;
		scene.customRenderTargets.push(this._volumetricLightScatteringRTT);
		
		// Custom render function for submeshes
		var renderSubMesh = function(subMesh:SubMesh) {
			var mesh:Mesh = subMesh.getRenderingMesh();
			if (this._meshExcluded(mesh)) {
				return;
			}
			
			var scene = mesh.getScene();
			var engine = scene.getEngine();
			
			// Culling
			engine.setState(subMesh.getMaterial().backFaceCulling);
			
			// Managing instances
			var batch = mesh._getInstancesRenderList(subMesh._id);
			
			if (batch.mustReturn) {
				return;
			}
			
			var hardwareInstancedRendering:Bool = (engine.getCaps().instancedArrays != null) && (batch.visibleInstances[subMesh._id] != null);
			
			if (this.isReady(subMesh, hardwareInstancedRendering)) {
				engine.enableEffect(this._volumetricLightScatteringPass);
				mesh._bind(subMesh, this._volumetricLightScatteringPass, Material.TriangleFillMode);
				var material:Material = subMesh.getMaterial();
				
				this._volumetricLightScatteringPass.setMatrix("viewProjection", scene.getTransformMatrix());
				
				// Alpha test
				if (material != null && (mesh == this.mesh || material.needAlphaTesting() || cast(material, StandardMaterial).opacityTexture != null)) {
					var alphaTexture = material.getAlphaTestTexture();
					
					if ((this.useDiffuseColor && alphaTexture == null) && mesh == this.mesh) {
						this._volumetricLightScatteringPass.setColor3("color", cast(material, StandardMaterial).diffuseColor);
					} 
					if (material.needAlphaTesting() || (mesh == this.mesh && alphaTexture != null && !this.useDiffuseColor)) {
						this._volumetricLightScatteringPass.setTexture("diffuseSampler", alphaTexture);
						if (alphaTexture != null) {
							this._volumetricLightScatteringPass.setMatrix("diffuseMatrix", alphaTexture.getTextureMatrix());
						}
					}
					
					if (cast(material, StandardMaterial).opacityTexture != null) {
						this._volumetricLightScatteringPass.setTexture("opacitySampler", cast(material, StandardMaterial).opacityTexture);
						this._volumetricLightScatteringPass.setFloat("opacityLevel", cast(material, StandardMaterial).opacityTexture.level);
					}
				}
				
				// Bones
				if (mesh.useBones) {
					this._volumetricLightScatteringPass.setMatrices("mBones", mesh.skeleton.getTransformMatrices(mesh));
				}
				
				// Draw
				mesh._processRendering(subMesh, this._volumetricLightScatteringPass, Material.TriangleFillMode, batch, hardwareInstancedRendering, function(isInstance:Bool, world:Matrix) this._volumetricLightScatteringPass.setMatrix("world", world));
			}
		};
		
		// Render target texture callbacks
		var savedSceneClearColor:Color3 = new Color3(0.0, 0.0, 0.0);
		var sceneClearColor:Color3 = new Color3(0.0, 0.0, 0.0);
		
		this._volumetricLightScatteringRTT.onBeforeRender = function(i:Int) {
			savedSceneClearColor = scene.clearColor;
			scene.clearColor = sceneClearColor;
		};
		
		this._volumetricLightScatteringRTT.onAfterRender = function(i:Int) {
			scene.clearColor = savedSceneClearColor;
		};
		
		this._volumetricLightScatteringRTT.customRenderFunction = function(opaqueSubMeshes:SmartArray<SubMesh>, alphaTestSubMeshes:SmartArray<SubMesh>, transparentSubMeshes:SmartArray<SubMesh>) {
			var engine = scene.getEngine();
			
			for (index in 0...opaqueSubMeshes.length) {
				renderSubMesh(opaqueSubMeshes.data[index]);
			}
			
			engine.setAlphaTesting(true);
			for (index in 0...alphaTestSubMeshes.length) {
				renderSubMesh(alphaTestSubMeshes.data[index]);
			}
			
			engine.setAlphaTesting(false);
			
			if (transparentSubMeshes != null && transparentSubMeshes.length > 0) {
				// Sort sub meshes
				for (index in 0...transparentSubMeshes.length) {
					var submesh:SubMesh = cast transparentSubMeshes.data[index];
					submesh._alphaIndex = submesh.getMesh().alphaIndex;
					submesh._distanceToCamera = submesh.getBoundingInfo().boundingSphere.centerWorld.subtract(scene.activeCamera.position).length();
				}
				
				var sortedArray = transparentSubMeshes.data.slice(0, transparentSubMeshes.length);
				sortedArray.sort(function(a:SubMesh, b:SubMesh):Int {
					// Alpha index first
					if (a._alphaIndex > b._alphaIndex) {
						return 1;
					}
					if (a._alphaIndex < b._alphaIndex) {
						return -1;
					}
					
					// Then distance to camera
					if (a._distanceToCamera < b._distanceToCamera) {
						return 1;
					}
					if (a._distanceToCamera > b._distanceToCamera) {
						return -1;
					}
					
					return 0;
				});
				
				// Render sub meshes
				engine.setAlphaMode(Engine.ALPHA_COMBINE);
				for (index in 0...sortedArray.length) {
					renderSubMesh(sortedArray[index]);
				}
				engine.setAlphaMode(Engine.ALPHA_DISABLE);
			}
		};
	}

	private function _updateMeshScreenCoordinates(scene:Scene) {
		var transform:Matrix = scene.getTransformMatrix();
		var meshPosition = this.mesh.parent != null ? this.mesh.getAbsolutePosition() : this.mesh.position;
        var pos = Vector3.Project(this.useCustomMeshPosition ? this._customMeshPosition : meshPosition, Matrix.Identity(), transform, this._viewPort);
		
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
		mesh.billboardMode = AbstractMesh.BILLBOARDMODE_Z;
		mesh.material = new StandardMaterial(name + "Material", scene);
		
		return mesh;
	}
	
}