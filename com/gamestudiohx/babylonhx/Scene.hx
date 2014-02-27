package com.gamestudiohx.babylonhx;

import com.gamestudiohx.babylonhx.animations._Animatable;
import com.gamestudiohx.babylonhx.cameras.Camera;
import com.gamestudiohx.babylonhx.collisions.Collider;
import com.gamestudiohx.babylonhx.collisions.PickingInfo;
import com.gamestudiohx.babylonhx.culling.BoundingSphere;
import com.gamestudiohx.babylonhx.culling.octrees.Octree;
import com.gamestudiohx.babylonhx.culling.octrees.OctreeBlock;
import com.gamestudiohx.babylonhx.layer.Layer;
import com.gamestudiohx.babylonhx.lights.Light;
import com.gamestudiohx.babylonhx.mesh.Mesh;
import com.gamestudiohx.babylonhx.mesh.SubMesh;
import com.gamestudiohx.babylonhx.tools.math.Plane;
import com.gamestudiohx.babylonhx.tools.math.Frustum;
import com.gamestudiohx.babylonhx.tools.math.Ray;
import com.gamestudiohx.babylonhx.tools.math.Color3;
import com.gamestudiohx.babylonhx.tools.math.Color4;
import com.gamestudiohx.babylonhx.tools.math.Vector3;
import com.gamestudiohx.babylonhx.tools.math.Matrix;
import com.gamestudiohx.babylonhx.sprites.SpriteManager;
import com.gamestudiohx.babylonhx.lensflare.LensFlareSystem;
import com.gamestudiohx.babylonhx.bones.Skeleton;
import com.gamestudiohx.babylonhx.tools.SmartArray;
import com.gamestudiohx.babylonhx.tools.Tools;
import com.gamestudiohx.babylonhx.materials.Material;
import com.gamestudiohx.babylonhx.materials.MultiMaterial;
import com.gamestudiohx.babylonhx.materials.Effect;
import com.gamestudiohx.babylonhx.materials.StandardMaterial;
import com.gamestudiohx.babylonhx.materials.textures.Texture;
import com.gamestudiohx.babylonhx.materials.textures.BaseTexture;
import com.gamestudiohx.babylonhx.particles.ParticleSystem;
import com.gamestudiohx.babylonhx.rendering.RenderingManager;
import com.gamestudiohx.babylonhx.postprocess.PostProcessManager;
import flash.geom.Rectangle;
import flash.Lib;
import openfl.gl.GL;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class Scene {
	
	public static var FOGMODE_NONE:Int = 0;
	public static var FOGMODE_EXP:Int = 1;
	public static var FOGMODE_EXP2:Int = 2;
	public static var FOGMODE_LINEAR:Int = 3;
	
	private var _engine:Engine;
	
	public var beforeRender:Void->Void;
	public var afterRender:Void->Void;
	
	public var _viewMatrix:Matrix;
	public var _projectionMatrix:Matrix;
	
	public var _physicsEngine:Dynamic;
	
	public var useDelayedTextureLoading:Bool;
	
	public var _totalVertices:Int;
	public var _activeVertices:Int;
	public var _activeParticles:Int;
	public var _lastFrameDuration:Float;
	public var _evaluateActiveMeshesDuration:Float;
	public var _renderTargetsDuration:Float;
	public var _renderDuration:Float;
	public var _particlesDuration:Float;
	public var _spritesDuration:Float;
	public var _animationRatio:Float;
	
	public var _renderId:Int;
	public var _executeWhenReadyTimeoutId:Int;
	
	public var _frustumPlanes:Array<Plane>;
	public var _selectionOctree:Octree;
	
	public var _toBeDisposed:SmartArray;
	
	public var _onReadyCallbacks:Array<Dynamic>;
	public var _pendingData:Array<Dynamic>;
	
	public var _onBeforeRenderCallbacks:Array<Void->Void>;
	
	public var _pickWithRayInverseMatrix:Matrix;
	
	public var autoClear:Bool;
	public var forceWireframe:Bool;
	public var clearColor:Color4;
	public var ambientColor:Color3;

	public var fogMode:Int;
	public var fogColor:Color3;
	public var fogDensity:Float;
	public var fogStart:Float;
	public var fogEnd:Float;
	
	public var _activeMeshes:SmartArray; 	
	public var _processedMaterials:SmartArray; 		
	public var _renderTargets:SmartArray; 
	public var _activeParticleSystems:SmartArray; 
	public var _activeSkeletons:SmartArray; 		
	
	public var renderTargetsEnabled:Bool;
	public var customRenderTargets:Array<Dynamic>;
	public var _scaledVelocity:Vector3;
	public var _scaledPosition:Vector3;
	public var _transformMatrix:Matrix;
	public var _activeAnimatables:Array<_Animatable>;
	public var lensFlareSystems:Array<LensFlareSystem>;
	public var _renderingManager:RenderingManager;

	public var lightsEnabled:Bool;
	public var lights:Array<Light>;
	public var cameras:Array<Camera>;
	public var activeCamera:Camera;
	public var activeCameras:Array<Camera>;
	public var meshes:Array<Mesh>;
	public var materials:Array<Material>;
	public var multiMaterials:Array<MultiMaterial>;
	public var defaultMaterial:StandardMaterial;
	public var texturesEnabled:Bool;
	public var textures:Array<BaseTexture>;
	public var particlesEnabled:Bool;
	public var particleSystems:Array<ParticleSystem>;
	public var spriteManagers:Array<SpriteManager>;
	public var layers:Array<Layer>;
	public var skeletons:Array<Skeleton>;
	public var collisionsEnabled:Bool;
	public var gravity:Vector3;
	public var postProcessesEnabled:Bool;
	public var postProcessManager:PostProcessManager;
	public var _animationStartDate:Int = -1;
	

	public function new(engine:Engine) {
		this._engine = engine;
        this.autoClear = true;
        this.clearColor = new Color4(0.2, 0.2, 0.3);
        this.ambientColor = new Color3(0, 0, 0);

        engine.scenes.push(this);

        this._totalVertices = 0;
        this._activeVertices = 0;
        this._activeParticles = 0;
        this._lastFrameDuration = 0;
        this._evaluateActiveMeshesDuration = 0;
        this._renderTargetsDuration = 0;
        this._renderDuration = 0;

        this._renderId = 0;
        this._executeWhenReadyTimeoutId = -1;

        this._toBeDisposed = new SmartArray();// (256);

        this._onReadyCallbacks = [];
        this._pendingData = [];

        this._onBeforeRenderCallbacks = [];

        // Fog
        this.fogMode = Scene.FOGMODE_NONE;
        this.fogColor = new Color3(0.2, 0.2, 0.3);
        this.fogDensity = 0.1;
        this.fogStart = 0;
        this.fogEnd = 1000.0;

        // Lights
        this.lightsEnabled = true;
        this.lights = [];

        // Cameras
        this.cameras = [];
        this.activeCamera = null;

        // Meshes
        this.meshes = [];

        // Internal smart arrays
        this._activeMeshes = new SmartArray();
        this._processedMaterials = new SmartArray();
        this._renderTargets = new SmartArray();
        this._activeParticleSystems = new SmartArray();
        this._activeSkeletons = new SmartArray();

        // Rendering groups
        this._renderingManager = new RenderingManager(this);

        // Materials
        this.materials = [];
        this.multiMaterials = [];
        this.defaultMaterial = new StandardMaterial("default material", this);

        // Textures
        this.texturesEnabled = true;
        this.textures = [];

        // Particles
        this.particlesEnabled = true;
        this.particleSystems = [];

        // Sprites
        this.spriteManagers = [];

        // Layers
        this.layers = [];

        // Skeletons
        this.skeletons = [];
        
        // Lens flares
        this.lensFlareSystems = [];

        // Collisions
        this.collisionsEnabled = true;
        this.gravity = new Vector3(0, -9.0, 0);

        // Animations
        this._activeAnimatables = [];

        // Matrices
        this._transformMatrix = Matrix.Zero();

        // Internals
        this._scaledPosition = Vector3.Zero();
        this._scaledVelocity = Vector3.Zero();

        // Postprocesses
        this.postProcessesEnabled = true;
        this.postProcessManager = new PostProcessManager(this);

        // Customs render targets
        this.renderTargetsEnabled = true;
        this.customRenderTargets = [];

        // Multi-cameras
        this.activeCameras = [];
	}

	public function getEngine():Engine {
		return this._engine;
	}
	
	public function getTotalVertices():Int {
		return this._totalVertices;
	}
	
	public function getActiveVertices():Int {
		return this._activeVertices;
	}
	
	public function getActiveParticles():Int {
		return this._activeParticles;
	}
	
	public function getLastFrameDuration():Float {
		return this._lastFrameDuration;
	}
	
	public function getEvaluateActiveMeshesDuration():Float {
		return this._evaluateActiveMeshesDuration;
	}
	
	public function getRenderTargetsDuration():Float {
		return this._renderTargetsDuration;
	}
	
	public function getRenderDuration():Float {
		return this._renderDuration;
	}
	
	public function getParticlesDuration():Float {
		return this._particlesDuration;
	}
	
	public function getSpritesDuration():Float {
		return this._spritesDuration;
	}
	
	public function getAnimationRatio():Float {
		return this._animationRatio;
	}
	
	public function getRenderId():Int {
		return this._renderId;
	}

	public function isReady():Bool {
		if (this._pendingData.length > 0) {
            return false;
        }

        for (index in 0...this.meshes.length) {
            var mesh = this.meshes[index];
            var mat = mesh.material;

            /*if (mesh.delayLoadState == Engine.DELAYLOADSTATE_LOADING) {
                return false;
            }*/

            if (mat != null) {
                if (!mat.isReady(mesh)) {
                    return false;
                }
            }
        }

        return true;
	}
	
	public function registerBeforeRender(func:Dynamic) {
		this._onBeforeRenderCallbacks.push(func);
	}
	
	public function unregisterBeforeRender(func:Dynamic) {
		var index = Lambda.indexOf(this._onBeforeRenderCallbacks, func);

        if (index > -1) {
            this._onBeforeRenderCallbacks.splice(index, 1);
        }
	}
	
	public function _addPendingData(data:Dynamic) {
        this._pendingData.push(data);
    }

	public function _removePendingData(data:Dynamic) {
        var index = Lambda.indexOf(this._pendingData, data);

        if (index != -1) {
            this._pendingData.splice(index, 1);
        }
    }

    public function getWaitingItemsCount():Int {
        return this._pendingData.length;
    }
	
	public function executeWhenReady(func:Dynamic) {
		this._onReadyCallbacks.push(func);

        if (this._executeWhenReadyTimeoutId != -1) {
            return;
        }
		
		this._checkIsReady();

        /*this._executeWhenReadyTimeoutId = setTimeout(function () {
            this._checkIsReady();
        }, 150);*/
	}
	
	private function _checkIsReady() {
		if (this.isReady()) {
            for(func in this._onReadyCallbacks) {
                func();
            }

            this._onReadyCallbacks = [];
            this._executeWhenReadyTimeoutId = -1;
            return;
        }

        /*this._executeWhenReadyTimeoutId = setTimeout(function () {
            this._checkIsReady();
        }, 150);*/
	}
	
	public function beginAnimation(target:Dynamic, from:Float, to:Float, loop:Bool, speedRatio:Float = 1.0, onAnimationEnd:Void->Void = null) {			
        // Local animations
        if (target.animations != null) {
            this.stopAnimation(target);

            var animatable = new _Animatable(target, from, to, loop, speedRatio, onAnimationEnd);

            this._activeAnimatables.push(animatable);
        }

        // Children animations		
        if (Reflect.getProperty(target, "getAnimatables") != null) {
            var animatables:Array<Dynamic> = target.getAnimatables();
			for (animatable in animatables) {
				this.beginAnimation(animatable, from, to, loop, speedRatio, onAnimationEnd);
			}
        }
	}
	
	public function stopAnimation(target:Dynamic) {
		for (index in 0...this._activeAnimatables.length) {
            if (this._activeAnimatables[index].target == target) {
                this._activeAnimatables.splice(index, 1);
                return;
            }
        }
	}
	
	public function _animate() {
        if (this._animationStartDate == -1) {
            this._animationStartDate = Lib.getTimer();
        }
        // Getting time
        var delay = Lib.getTimer() - this._animationStartDate;

		var index:Int = 0;
		while (index < this._activeAnimatables.length) {
            if (!this._activeAnimatables[index]._animate(delay)) {
                this._activeAnimatables.splice(index, 1);
                index--;
            }
			index++;
        }
    }

	public function getViewMatrix():Matrix {
		return this._viewMatrix;
	}
	
	public function getProjectionMatrix():Matrix {
		return this._projectionMatrix;
	}
	
	inline public function getTransformMatrix():Matrix {
		return this._transformMatrix;
	}	
	
	inline public function setTransformMatrix(view:Matrix, projection:Matrix) {
		this._viewMatrix = view;
        this._projectionMatrix = projection;

        this._viewMatrix.multiplyToRef(this._projectionMatrix, this._transformMatrix);
	}
	
	public function activeCameraByID(id:String) {
		for (index in 0...this.cameras.length) {
            if (this.cameras[index].id == id) {
                this.activeCamera = this.cameras[index];
                return;
            }
        }
	}
	
	public function getMaterialByID(id:String):Material {
		for (index in 0...this.materials.length) {
            if (this.materials[index].id == id) {
                return this.materials[index];
            }
        }

        return null;
	}
	
	public function getMaterialByName(name:String):Material {
		for (index in 0...this.materials.length) {
            if (this.materials[index].name == name) {
                return this.materials[index];
            }
        }

        return null;
	}
	
	public function getLightByID(id:String):Light {
		for (index in 0...this.lights.length) {
            if (this.lights[index].id == id) {
                return this.lights[index];
            }
        }

        return null;
	}
	
	public function getMeshByID(id:String):Mesh {
		for (index in 0...this.meshes.length) {
            if (this.meshes[index].id == id) {
                return this.meshes[index];
            }
        }

        return null;
	}
	
	public function getLastMeshByID(id:String):Mesh {
		var index:Int = this.meshes.length - 1;
		while(index >= 0) {
            if (this.meshes[index].id == id) {
                return this.meshes[index];
            }
			index--;
        }

        return null;
	}
	
	public function getLastEntryByID(id:String):Dynamic {
		var index:Int = this.meshes.length - 1;
		while(index >= 0) {
            if (this.meshes[index].id == id) {
                return this.meshes[index];
            }
			index--;
        }

		index = this.cameras.length - 1;
		while(index >= 0) {
            if (this.cameras[index].id == id) {
                return this.cameras[index];
            }
			index--;
        }
        
		index = this.lights.length - 1;
		while(index >= 0) {
            if (this.lights[index].id == id) {
                return this.lights[index];
            }
			index--;
        }

        return null;
    }
	
	public function getMeshByName(name:String):Mesh {
		for (index in 0...this.meshes.length) {
            if (this.meshes[index].name == name) {
                return this.meshes[index];
            }
        }

        return null;
	}
	
	public function isActiveMesh(mesh:Mesh):Bool {
		return (this._activeMeshes.indexOf(mesh) != -1);
	}
	
	public function getLastSkeletonByID(id:String):Skeleton {
		var index:Int = this.skeletons.length - 1;
		while(index >= 0) {
            if (this.skeletons[index].id == id) {
                return this.skeletons[index];
            }
			index--;
        }

        return null;
	}
	
	public function getSkeletonByID(id:String):Skeleton {
		for (index in 0...this.skeletons.length) {
            if (this.skeletons[index].id == id) {
                return this.skeletons[index];
            }
        }

        return null;
	}
	
	public function getSkeletonByName(name:String):Skeleton {
		for (index in 0...this.skeletons.length) {
            if (this.skeletons[index].name == name) {
                return this.skeletons[index];
            }
        }

        return null;
	}

	inline public function _evaluateSubMesh(subMesh:SubMesh, mesh:Mesh) {
		if (mesh.subMeshes.length == 1 || subMesh.isInFrustrum(this._frustumPlanes)) {
            var material = subMesh.getMaterial();

            if (material != null) {
                // Render targets
                if (Reflect.field(material, "getRenderTargetTextures") != null) {
                    if (this._processedMaterials.indexOf(material) == -1) {
                        this._processedMaterials.push(material);

						this._renderTargets.concat(material.getRenderTargetTextures());
                    }
                }

                // Dispatch
                this._activeVertices += subMesh.verticesCount;
                this._renderingManager.dispatch(subMesh);
            }
        }
	}
	
	inline public function _evaluateActiveMeshes() {
		this._activeMeshes.reset();
        this._renderingManager.reset(); 
        this._processedMaterials.reset();
        this._activeParticleSystems.reset();
        this._activeSkeletons.reset();

        if (this._frustumPlanes == null) {
            this._frustumPlanes = Frustum.GetPlanes(this._transformMatrix);
        } else {
            this._frustumPlanes = Frustum.GetPlanesToRef(this._transformMatrix, this._frustumPlanes);
        }

        // Meshes
        if (this._selectionOctree != null) { // Octree
            var selection:Array<OctreeBlock> = this._selectionOctree.select(this._frustumPlanes);

            for (blockIndex in 0...selection.length) {
                var block:OctreeBlock = selection[blockIndex]; // selection.data[blockIndex];     TODO - this should be smart array

                for (meshIndex in 0...block.meshes.length) {
                    var mesh:Mesh = block.meshes[meshIndex];

                    if (mesh._renderId != this._renderId) {		// Math.abs ??    TODO
                        this._totalVertices += mesh.getTotalVertices();

                        if (!mesh.isReady()) {
                            continue;
                        }

                        mesh.computeWorldMatrix();
                        mesh._renderId = 0;
                    }

                    if (mesh._renderId == this._renderId || (mesh._renderId == 0 && mesh.isEnabled() && mesh.isVisible && mesh.visibility > 0 && mesh.isInFrustrum(this._frustumPlanes))) {
                        if (mesh._renderId == 0) {
                            this._activeMeshes.push(mesh);
                        }
                        mesh._renderId = this._renderId;
						
                        if (mesh.skeleton != null) {
							if(this._activeSkeletons.indexOf(mesh.skeleton) != -1) {
								this._activeSkeletons.pushNoDuplicate(mesh.skeleton);
							}
                        }

                        var subMeshes:Array<SubMesh> = block.subMeshes[meshIndex];
                        for (subIndex in 0...subMeshes.length) {
                            var subMesh:SubMesh = subMeshes[subIndex];

                            if (subMesh._renderId == this._renderId) {
                                continue;
                            }
                            subMesh._renderId = this._renderId;

                            this._evaluateSubMesh(subMesh, mesh);
                        }
                    } else {
                        mesh._renderId = -this._renderId;
                    }
                }
            }
        } else { // Full scene traversal
            for (meshIndex in 0...this.meshes.length) {
                var mesh:Mesh = this.meshes[meshIndex];

                this._totalVertices += mesh.getTotalVertices();

                if (!mesh.isReady()) {
                    continue;
                }

                mesh.computeWorldMatrix();

                if (mesh.isEnabled() && mesh.isVisible && mesh.visibility > 0 && mesh.isInFrustrum(this._frustumPlanes)) {
                    this._activeMeshes.push(mesh);

                    if (mesh.skeleton != null) {						
						this._activeSkeletons.pushNoDuplicate(mesh.skeleton);
                    }

                    for (subIndex in 0...mesh.subMeshes.length) {
                        var subMesh:SubMesh = mesh.subMeshes[subIndex];

                        this._evaluateSubMesh(subMesh, mesh);
                    }
                }
            }
        }

        // Particle systems
        var beforeParticlesDate = Lib.getTimer();
        if (this.particlesEnabled) {
            for (particleIndex in 0...this.particleSystems.length) {
                var particleSystem = this.particleSystems[particleIndex];

                if (!particleSystem.emitter.position || (particleSystem.emitter && particleSystem.emitter.isEnabled())) {
                    this._activeParticleSystems.push(particleSystem);
                    particleSystem.animate();
                }
            }
        }
        this._particlesDuration += Lib.getTimer() - beforeParticlesDate;
	}
	
	inline public function _renderForCamera(camera:Camera = null, mustClearDepth:Bool = false) {
        var engine:Engine = this._engine;

        this.activeCamera = camera;

        if (this.activeCamera == null)
            throw("Active camera not set");

        // Viewport
        engine.setViewport(this.activeCamera.viewport);
		
		// Clear
        if (mustClearDepth) {
            this._engine.clear(this.clearColor, false, true);
        }

        // Camera
        this._renderId++;
        this.setTransformMatrix(this.activeCamera.getViewMatrix(), this.activeCamera.getProjectionMatrix());

        // Meshes
        var beforeEvaluateActiveMeshesDate = Lib.getTimer();
        this._evaluateActiveMeshes();
        this._evaluateActiveMeshesDuration += Lib.getTimer() - beforeEvaluateActiveMeshesDate;

        // Skeletons
        for (skeletonIndex in 0...this._activeSkeletons.length) {
            var skeleton:Skeleton = this._activeSkeletons.data[skeletonIndex];
            skeleton.prepare();
        }

        // Customs render targets registration
        for (customIndex in 0...this.customRenderTargets.length) {
            this._renderTargets.push(this.customRenderTargets[customIndex]);
        }

        // Render targets
        var beforeRenderTargetDate = Lib.getTimer();
        if (this.renderTargetsEnabled) {
            for (renderIndex in 0...this._renderTargets.length) {
                var renderTarget = this._renderTargets.data[renderIndex];
                this._renderId++;
                renderTarget.render();
            }
        }

        if (this._renderTargets.length > 0) { // Restore back buffer
            engine.restoreDefaultFramebuffer();
        }
        this._renderTargetsDuration = Lib.getTimer() - beforeRenderTargetDate;

        // Prepare Frame
        this.postProcessManager._prepareFrame();

        var beforeRenderDate = Lib.getTimer();        
        // Backgrounds
        if (this.layers.length > 0) {
            engine.setDepthBuffer(false);
            var layer:Layer = null;
            for (layerIndex in 0...this.layers.length) {
                layer = this.layers[layerIndex];
                if (layer.isBackground) {
                    layer.render();
                }
            }
            engine.setDepthBuffer(true);
        }

        // Render
        this._renderingManager.render(null, null, true, true);
        
        // Lens flares
        for (lensFlareSystemIndex in 0...this.lensFlareSystems.length) {
            this.lensFlareSystems[lensFlareSystemIndex].render();
        }

        // Foregrounds
        if (this.layers.length > 0) {
            engine.setDepthBuffer(false);
            for (layerIndex in 0...this.layers.length) {
                var layer = this.layers[layerIndex];
                if (!layer.isBackground) {
                    layer.render();
                }
            }
            engine.setDepthBuffer(true);
        }

        this._renderDuration += Lib.getTimer() - beforeRenderDate;

        // Finalize frame
        this.postProcessManager._finalizeFrame();

        // Update camera
        this.activeCamera._update();
        
        // Reset some special arrays
        this._renderTargets.reset();
	}
		
	inline public function render(rect:Rectangle = null) {
		var startDate = Lib.getTimer();
        this._particlesDuration = 0;
        this._spritesDuration = 0;
        this._activeParticles = 0;
        this._renderDuration = 0;
        this._evaluateActiveMeshesDuration = 0;
        this._totalVertices = 0;
        this._activeVertices = 0;

        // Before render
        if (this.beforeRender != null) {
            this.beforeRender();
        }

        for (callbackIndex in 0...this._onBeforeRenderCallbacks.length) {
            this._onBeforeRenderCallbacks[callbackIndex]();
        }
        
        // Animations
        var deltaTime = Tools.GetDeltaTime();
        this._animationRatio = deltaTime * (60.0 / 1000.0);
        this._animate();
        
        // Physics
        if (this._physicsEngine != null) {
            this._physicsEngine._runOneStep(deltaTime / 1000.0);
        }
        
        // Clear
        this._engine.clear(this.clearColor, this.autoClear || this.forceWireframe, true);
        
        // Shadows
        for (lightIndex in 0...this.lights.length) {
            var light:Light = this.lights[lightIndex];
            var shadowGenerator = light.getShadowGenerator();

            if (light.isEnabled() && shadowGenerator != null) {
                this._renderTargets.push(shadowGenerator.getShadowMap());
            }
        }

        // Multi-cameras?
        if (this.activeCameras.length > 0) {
            var currentRenderId = this._renderId;
            for (cameraIndex in 0...this.activeCameras.length) {
                this._renderId = currentRenderId;
                this._renderForCamera(this.activeCameras[cameraIndex], cameraIndex != 0);
            }
        } else {
            this._renderForCamera(this.activeCamera);
        }

        // After render
        if (this.afterRender != null) {
            this.afterRender();
        }

        // Cleaning
        for (index in 0...this._toBeDisposed.length) {
            this._toBeDisposed.data[index].dispose();            
        }		

        this._toBeDisposed.reset();
		
		// TESTING: clearing GL state to allow mixing with OpenFL display list
		GL.disable(GL.CULL_FACE);
		GL.bindBuffer (GL.ARRAY_BUFFER, null);		

        this._lastFrameDuration = Lib.getTimer() - startDate;
	}
	
	public function dispose() {
		this.beforeRender = null;
        this.afterRender = null;

        this.skeletons = [];

        // Detach cameras
		// TODO
        /*var canvas = this._engine.getRenderingCanvas();
        var index;
        for (index = 0; index < this.cameras.length; index++) {
            this.cameras[index].detachControl(canvas);
        }*/

        // Release lights
        while (this.lights.length > 0) {
            this.lights[0].dispose();
			this.lights.remove(this.lights[0]);
        }

        // Release meshes
        while (this.meshes.length > 0) {
            this.meshes[0].dispose(true);
			this.meshes.remove(this.meshes[0]);
        }

        // Release cameras
        while (this.cameras.length > 0) {
            this.cameras[0].dispose();
			this.cameras.remove(this.cameras[0]);
        }

        // Release materials
        while (this.materials.length > 0) {
            this.materials[0].dispose();
			this.materials.remove(this.materials[0]);
        }

        // Release particles
        while (this.particleSystems.length > 0) {
            this.particleSystems[0].dispose();
			this.particleSystems.remove(this.particleSystems[0]);
        }

        // Release sprites
        while (this.spriteManagers.length > 0) {
            this.spriteManagers[0].dispose();
			this.spriteManagers.remove(this.spriteManagers[0]);
        }

        // Release layers
        while (this.layers.length > 0) {
            this.layers[0].dispose();
			this.layers.remove(this.layers[0]);
        }

        // Release textures
        while (this.textures.length > 0) {
            this.textures[0].dispose();
			this.textures.remove(this.textures[0]);
        }

        // Post-processes
        this.postProcessManager.dispose();
        
        // Physics
		// TODO
        /*if (this._physicsEngine != null) {
            this.disablePhysicsEngine();
        }*/

        // Remove from engine
        /*var index = Lambda.indexOf(this._engine.scenes, this);
        this._engine.scenes.splice(index, 1);*/
		this._engine.scenes.remove(this);

        this._engine.wipeCaches();
	}
	
	inline public function _getNewPosition(position:Vector3, velocity:Vector3, collider:Collider, maximumRetry:Int, finalPosition:Vector3) {
		position.divideToRef(collider.radius, this._scaledPosition);
        velocity.divideToRef(collider.radius, this._scaledVelocity);

        collider.retry = 0;
        collider.initialVelocity = this._scaledVelocity;
        collider.initialPosition = this._scaledPosition;
        this._collideWithWorld(this._scaledPosition, this._scaledVelocity, collider, maximumRetry, finalPosition);

        finalPosition.multiplyInPlace(collider.radius);
	}
	
	inline public function _collideWithWorld(position:Vector3, velocity:Vector3, collider:Collider, maximumRetry:Int, finalPosition:Vector3):Void {
		var closeDistance = Engine.collisionsEpsilon * 10.0;

        if (collider.retry >= maximumRetry) {
            finalPosition.copyFrom(position);
            //return;
        } else {

			collider._initialize(position, velocity, closeDistance);

			// Check all meshes
			for (index in 0...this.meshes.length) {
				var mesh:Mesh = this.meshes[index];
				if (mesh.isEnabled() && mesh.checkCollisions) {
					mesh._checkCollision(collider);
				}
			}

			if (!collider.collisionFound) {
				position.addToRef(velocity, finalPosition);
				//return;
			} else {
				if (velocity.x != 0 || velocity.y != 0 || velocity.z != 0) {
					collider._getResponse(position, velocity);
				}

				if (velocity.length() <= closeDistance) {
					finalPosition.copyFrom(position);
					//return;
				} else {
					collider.retry++;
					this._collideWithWorld(position, velocity, collider, maximumRetry, finalPosition);
				}
			}
		}
	}

	inline public function createOrUpdateSelectionOctree() {
		if (this._selectionOctree == null) {
            this._selectionOctree = new Octree();
        }

        // World limits
        function checkExtends(v:Vector3, min:Vector3, max:Vector3) {
            if (v.x < min.x)
                min.x = v.x;
            if (v.y < min.y)
                min.y = v.y;
            if (v.z < min.z)
                min.z = v.z;

            if (v.x > max.x)
                max.x = v.x;
            if (v.y > max.y)
                max.y = v.y;
            if (v.z > max.z)
                max.z = v.z;
        }

        var min = new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
        var max = new Vector3(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);
        for (index in 0...this.meshes.length) {
            var mesh:Mesh = this.meshes[index];

            mesh.computeWorldMatrix();
            var minBox = mesh.getBoundingInfo().boundingBox.minimumWorld;
            var maxBox = mesh.getBoundingInfo().boundingBox.maximumWorld;

            checkExtends(minBox, min, max);
            checkExtends(maxBox, min, max);
        }

        // Update octree
        this._selectionOctree.update(min, max, this.meshes);
	}
	
	inline public function createPickingRay(x:Float, y:Float, world:Matrix = null, camera:Camera = null):Ray {
		var engine = this._engine;

        if (camera == null) {
            if (this.activeCamera == null)
                throw("Active camera not set");

            //this.setTransformMatrix(this.activeCamera.getViewMatrix(), this.activeCamera.getProjectionMatrix());
			camera = this.activeCamera;
        }
        var viewport = this.activeCamera.viewport.toGlobal(engine);

        //return Ray.CreateNew(x, y, viewport.width, viewport.height, world != null ? world : Matrix.Identity(), this._viewMatrix, this._projectionMatrix);
		var viewport = camera.viewport.toGlobal(engine);
        return Ray.CreateNew(x, y, viewport.width, viewport.height, world != null ? world : Matrix.Identity(), camera.getViewMatrix(), camera.getProjectionMatrix());
	}
	
	inline public function _internalPick(rayFunction:Matrix->Ray, predicate:Mesh->Bool, fastCheck:Bool):PickingInfo {
		var pickingInfo:PickingInfo = null;

        for (meshIndex in 0...this.meshes.length) {
            var mesh:Mesh = this.meshes[meshIndex];

            if (predicate != null) {
                if (!predicate(mesh)) {
                    continue;
                }
            } else if (!mesh.isEnabled() || !mesh.isVisible || !mesh.isPickable) {
                continue;
            }

            var world:Matrix = mesh.getWorldMatrix();
            var ray:Ray = rayFunction(world);

            var result:PickingInfo = mesh.intersects(ray, fastCheck);
            if (!result.hit)
                continue;

            if (!fastCheck && pickingInfo != null && result.distance >= pickingInfo.distance)
                continue;

            pickingInfo = result;

            if (fastCheck) {
                break;
            }
        }
        
        return pickingInfo == null ? new PickingInfo() : pickingInfo;
	}
	
	public function pick(x:Float, y:Float, predicate:Mesh->Bool, fastCheck:Bool, camera:Camera):PickingInfo {
        return this._internalPick(function(world:Matrix):Ray {
            return this.createPickingRay(x, y, world, camera);
        }, predicate, fastCheck);
    }
	
	public function pickWithRay(ray:Ray, predicate:Mesh->Bool, fastCheck:Bool):PickingInfo {
		function param(world:Matrix):Ray {
            if (this._pickWithRayInverseMatrix == null) {
                this._pickWithRayInverseMatrix = Matrix.Identity();
            }
            world.invertToRef(this._pickWithRayInverseMatrix);
            return Ray.Transform(ray, this._pickWithRayInverseMatrix);
        }
		
        return this._internalPick(param, predicate, fastCheck);
    }
	
	// TODO
	// Physics
    /*BABYLON.Scene.prototype.enablePhysics = function(gravity) {
        if (this._physicsEngine) {
            return true;
        }
        
        if (!BABYLON.PhysicsEngine.IsSupported()) {
            return false;
        }

        this._physicsEngine = new BABYLON.PhysicsEngine(gravity);

        return true;
    };

    BABYLON.Scene.prototype.disablePhysicsEngine = function() {
        if (!this._physicsEngine) {
            return;
        }

        this._physicsEngine.dispose();
        this._physicsEngine = undefined;
    };

    BABYLON.Scene.prototype.isPhysicsEnabled = function() {
        return this._physicsEngine !== undefined;
    };
    
    BABYLON.Scene.prototype.setGravity = function (gravity) {
        if (!this._physicsEngine) {
            return;
        }

        this._physicsEngine._setGravity(gravity);
    };*/
	
}