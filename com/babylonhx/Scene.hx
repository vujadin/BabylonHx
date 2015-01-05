package com.babylonhx;

import com.babylonhx.actions.Action;
import com.babylonhx.actions.ActionManager;
import com.babylonhx.actions.ActionEvent;
import com.babylonhx.animations.Animatable;
import com.babylonhx.animations.Animation;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.collisions.Collider;
import com.babylonhx.collisions.PickingInfo;
import com.babylonhx.culling.octrees.Octree;
import com.babylonhx.layer.Layer;
import com.babylonhx.lensflare.LensFlareSystem;
import com.babylonhx.lights.Light;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.MultiMaterial;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.materials.textures.procedurals.ProceduralTexture;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.math.Color3;
import com.babylonhx.cameras.Camera;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Plane;
import com.babylonhx.math.Ray;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Frustum;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Geometry;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.physics.PhysicsEngine;
import com.babylonhx.physics.IPhysicsEnginePlugin;
import com.babylonhx.physics.PhysicsBodyCreationOptions;
import com.babylonhx.postprocess.PostProcessManager;
import com.babylonhx.postprocess.renderpipeline.PostProcessRenderPipelineManager;
import com.babylonhx.rendering.BoundingBoxRenderer;
import com.babylonhx.rendering.OutlineRenderer;
import com.babylonhx.rendering.RenderingManager;
import com.babylonhx.sprites.SpriteManager;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.tools.Tools;
//import com.babylonhx.tools.Tags;
import haxe.Timer;

/**
 * ...
 * @author Krtolica Vujadin
 */

class Scene {
	
	// Statics
	public static var FOGMODE_NONE:Int = 0;
	public static var FOGMODE_EXP:Int = 1;
	public static var FOGMODE_EXP2:Int = 2;
	public static var FOGMODE_LINEAR:Int = 3;

	public static var MinDeltaTime:Float = 1.0;
	public static var MaxDeltaTime:Float = 1000.0;

	// Members
	public var autoClear:Bool = true;
	public var clearColor:Color3 = new Color3(0.2, 0.2, 0.3);
	public var ambientColor:Color3 = new Color3(0, 0, 0);
	public var beforeRender:Void->Void;
	public var afterRender:Void->Void;
	public var onDispose:Void->Void;
	public var beforeCameraRender:Camera->Void;
	public var afterCameraRender:Camera->Void;
	public var forceWireframe:Bool = false;
	public var forcePointsCloud:Bool = false;
	public var forceShowBoundingBoxes:Bool = false;
	public var clipPlane:Plane;
	public var animationsEnabled:Bool = true;

	// Pointers
	private var _onPointerMove:Dynamic->Void;	// MouseEvent->Void
	private var _onPointerDown:Dynamic->Void;	// MouseEvent->Void
	public var onPointerDown:Dynamic->PickingInfo->Void; // MouseEvent->PickingInfo->Void
	public var cameraToUseForPointers:Camera = null; // Define this parameter if you are using multiple cameras and you want to specify which one should be used for pointer position
	private var _pointerX:Int;
	private var _pointerY:Int;
	private var _meshUnderPointer:AbstractMesh; 

	// Keyboard
	private var _onKeyDown:Dynamic->Void;	// Event->Void
	private var _onKeyUp:Dynamic->Void;		// Event->Void

	// Fog
	public var fogEnabled:Bool = true;
	public var fogMode:Int = Scene.FOGMODE_NONE;
	public var fogColor:Color3 = new Color3(0.2, 0.2, 0.3);
	public var fogDensity:Float = 0.1;
	public var fogStart:Float = 0;
	public var fogEnd:Float = 1000.0;

	// Lights
	public var shadowsEnabled:Bool = true;
	public var lightsEnabled:Bool = true;
	public var lights:Array<Light> = [];

	// Cameras
	public var cameras:Array<Camera> = [];
	public var activeCameras:Array<Camera> = [];
	public var activeCamera:Camera;

	// Meshes
	public var meshes:Array<AbstractMesh> = [];

	// Geometries
	private var _geometries:Array<Geometry> = [];

	public var materials:Array<Material> = [];
	public var multiMaterials:Array<MultiMaterial> = [];
	public var defaultMaterial:StandardMaterial;

	// Textures
	public var texturesEnabled:Bool = true;
	public var textures:Array<BaseTexture> = [];

	// Particles
	public var particlesEnabled:Bool = true;
	public var particleSystems:Array<ParticleSystem> = [];

	// Sprites
	public var spriteManagers:Array<SpriteManager> = [];

	// Layers
	public var layers:Array<Layer> = [];

	// Skeletons
	public var skeletonsEnabled:Bool = true;
	public var skeletons:Array<Skeleton> = [];

	// Lens flares
	public var lensFlaresEnabled:Bool = true;
	public var lensFlareSystems:Array<LensFlareSystem> = [];
	
	// Collisions
	public var collisionsEnabled:Bool = true;
	public var gravity:Vector3 = new Vector3(0, -9.0, 0);

	// Postprocesses
	public var postProcessesEnabled:Bool = true;
	public var postProcessManager:PostProcessManager;
	public var postProcessRenderPipelineManager:PostProcessRenderPipelineManager;

	// Customs render targets
	public var renderTargetsEnabled:Bool = true;
	public var customRenderTargets:Array<RenderTargetTexture> = [];

	// Delay loading
	public var useDelayedTextureLoading:Bool;

	// Imported meshes
	public var importedMeshesFiles:Array<String> = [];

	// Database
	public var database:Dynamic; //ANY

	// Actions
	public var actionManager:ActionManager;
	public var _actionManagers:Array<ActionManager> = [];
	private var _meshesForIntersections:SmartArray = new SmartArray(256);// SmartArray<AbstractMesh> = new SmartArray<AbstractMesh>(256);

	// Procedural textures
	public var proceduralTexturesEnabled:Bool = true;
	public var _proceduralTextures:Array<ProceduralTexture> = [];

	// Private
	private var _engine:Engine;
	private var _totalVertices:Int = 0;
	public var _activeVertices:Int = 0;
	public var _activeParticles:Int = 0;
	private var _lastFrameDuration:Float = 0;
	private var _evaluateActiveMeshesDuration:Float = 0;
	private var _renderTargetsDuration:Float = 0;
	public var _particlesDuration:Float = 0;
	private var _renderDuration:Float = 0;
	public var _spritesDuration:Float = 0;
	private var _animationRatio:Float = 0;
	private var _animationStartDate:Float = -1;
	public var _cachedMaterial:Material;

	private var _renderId:Int = 0;
	private var _executeWhenReadyTimeoutId:Int = -1;

	public var _toBeDisposed:SmartArray = new SmartArray(256);// SmartArray<IDisposable> = new SmartArray<IDisposable>(256);

	private var _onReadyCallbacks:Array<Void->Void> = [];
	private var _pendingData:Array<Dynamic> = [];//ANY

	private var _onBeforeRenderCallbacks:Array<Void->Void> = [];
	private var _onAfterRenderCallbacks:Array<Void->Void> = [];

	private var _activeMeshes:SmartArray = new SmartArray(256);// SmartArray<Mesh> = new SmartArray<Mesh>(256);
	private var _processedMaterials:SmartArray = new SmartArray(256);// SmartArray<Material> = new SmartArray<Material>(256);
	private var _renderTargets:SmartArray = new SmartArray(256);// SmartArray<RenderTargetTexture> = new SmartArray<RenderTargetTexture>(256);
	public var _activeParticleSystems:SmartArray = new SmartArray(256);// SmartArray<ParticleSystem> = new SmartArray<ParticleSystem>(256);
	private var _activeSkeletons:SmartArray = new SmartArray(256);// SmartArray<Skeleton> = new SmartArray<Skeleton>(32);
	private var _activeBones:Int = 0;

	private var _renderingManager:RenderingManager;
	private var _physicsEngine:PhysicsEngine;

	public var _activeAnimatables:Array<Animatable> = [];

	private var _transformMatrix:Matrix = Matrix.Zero();
	private var _pickWithRayInverseMatrix:Matrix;

	private var _scaledPosition:Vector3 = Vector3.Zero();
	private var _scaledVelocity:Vector3 = Vector3.Zero();

	private var _boundingBoxRenderer:BoundingBoxRenderer;
	private var _outlineRenderer:OutlineRenderer;

	private var _viewMatrix:Matrix;
	private var _projectionMatrix:Matrix;
	private var _frustumPlanes:Array<Plane>;

	public var _selectionOctree:Octree<AbstractMesh>;

	private var _pointerOverMesh:AbstractMesh;
	
	//private var _debugLayer:DebugLayer;
	

	public function new(engine:Engine) {
		this._engine = engine;
		
		engine.scenes.push(this);
		
		this.defaultMaterial = new StandardMaterial("default material", this);
		
		this._renderingManager = new RenderingManager(this);
		
		this.postProcessManager = new PostProcessManager(this);
		
		this.postProcessRenderPipelineManager = new PostProcessRenderPipelineManager();
		
		this._boundingBoxRenderer = new BoundingBoxRenderer(this);
		this._outlineRenderer = new OutlineRenderer(this);
		
		this.attachControl();
		
		//this._debugLayer = new DebugLayer(this);
	}

	// Properties 
	public var meshUnderPointer(get, never):AbstractMesh;
	private function get_meshUnderPointer():AbstractMesh {
		return this._meshUnderPointer;
	}

	public var pointerX(get, never):Float;
	private function get_pointerX():Float {
		return this._pointerX;
	}

	public var pointerY(get, never):Float;
	private function get_pointerY():Float {
		return this._pointerY;
	}
	
	public function getCachedMaterial():Material {
        return this._cachedMaterial;
    }

	public function getBoundingBoxRenderer():BoundingBoxRenderer {
		return this._boundingBoxRenderer;
	}

	public function getOutlineRenderer():OutlineRenderer {
		return this._outlineRenderer;
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
	
	public function getActiveBones():Int {
        return this._activeBones;
    }

	// Stats
	public function getLastFrameDuration():Float {
		return this._lastFrameDuration;
	}

	public function getEvaluateActiveMeshesDuration():Float {
		return this._evaluateActiveMeshesDuration;
	}

	public function getActiveMeshes():SmartArray { //SmartArray<Mesh> {
		return this._activeMeshes;
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

	private function _updatePointerPosition(evt:Dynamic/*PointerEvent*/) {
		/*var canvasRect = this._engine.getRenderingCanvasClientRect();

		this._pointerX = evt.clientX - canvasRect.left;
		this._pointerY = evt.clientY - canvasRect.top;

		if (this.cameraToUseForPointers != null) {
			this._pointerX = this._pointerX - this.cameraToUseForPointers.viewport.x * this._engine.getRenderWidth();
			this._pointerY = this._pointerY - this.cameraToUseForPointers.viewport.y * this._engine.getRenderHeight();
		}*/
	}

	// Pointers handling
	public function attachControl() {
		/*this._onPointerMove = function(evt:Dynamic) {
			var canvas = this._engine.getRenderingCanvas();

			this._updatePointerPosition(evt);

			var pickResult = this.pick(this._pointerX, this._pointerY,
				function(mesh:AbstractMesh):Bool { return mesh.isPickable && mesh.isVisible && mesh.isReady() && mesh.actionManager && mesh.actionManager.hasPointerTriggers; },
				false,
				this.cameraToUseForPointers);

			if (pickResult.hit) {
				this._meshUnderPointer = pickResult.pickedMesh;

				this.setPointerOverMesh(pickResult.pickedMesh);
				//canvas.style.cursor = "pointer";
			} else {
				this.setPointerOverMesh(null);
				//canvas.style.cursor = "";
				this._meshUnderPointer = null;
			}
		};

		this._onPointerDown = function(evt:Dynamic) {

			var predicate = null;

			if (!this.onPointerDown) {
				predicate = function(mesh:AbstractMesh):Bool => {
					return mesh.isPickable && mesh.isVisible && mesh.isReady() && mesh.actionManager && mesh.actionManager.hasPickTriggers;
				};
			}

			this._updatePointerPosition(evt);

			var pickResult = this.pick(this._pointerX, this._pointerY, predicate, false, this.cameraToUseForPointers);

			if (pickResult.hit) {
				if (pickResult.pickedMesh.actionManager) {
					switch (evt.button) {
						case 0:
							pickResult.pickedMesh.actionManager.processTrigger(ActionManager.OnLeftPickTrigger, ActionEvent.CreateNew(pickResult.pickedMesh));
							break;
						case 1:
							pickResult.pickedMesh.actionManager.processTrigger(ActionManager.OnCenterPickTrigger, ActionEvent.CreateNew(pickResult.pickedMesh));
							break;
						case 2:
							pickResult.pickedMesh.actionManager.processTrigger(ActionManager.OnRightPickTrigger, ActionEvent.CreateNew(pickResult.pickedMesh));
							break;
					}
					pickResult.pickedMesh.actionManager.processTrigger(ActionManager.OnPickTrigger, ActionEvent.CreateNew(pickResult.pickedMesh));
				}
			}

			if (this.onPointerDown) {
				this.onPointerDown(evt, pickResult);
			}
		};

		this._onKeyDown = (evt:Event) => {
			if (this.actionManager) {
				this.actionManager.processTrigger(ActionManager.OnKeyDownTrigger, ActionEvent.CreateNewFromScene(this, evt));
			}
		};

		this._onKeyUp = (evt:Event) => {
			if (this.actionManager) {
				this.actionManager.processTrigger(ActionManager.OnKeyUpTrigger, ActionEvent.CreateNewFromScene(this, evt));
			}
		};


		var eventPrefix = Tools.GetPointerPrefix();
		this._engine.getRenderingCanvas().addEventListener(eventPrefix + "move", this._onPointerMove, false);
		this._engine.getRenderingCanvas().addEventListener(eventPrefix + "down", this._onPointerDown, false);

		window.addEventListener("keydown", this._onKeyDown, false);
		window.addEventListener("keyup", this._onKeyUp, false);*/
	}

	public function detachControl() {
		/*var eventPrefix = Tools.GetPointerPrefix();
		this._engine.getRenderingCanvas().removeEventListener(eventPrefix + "move", this._onPointerMove);
		this._engine.getRenderingCanvas().removeEventListener(eventPrefix + "down", this._onPointerDown);

		window.removeEventListener("keydown", this._onKeyDown);
		window.removeEventListener("keyup", this._onKeyUp);*/
	}

	// Ready
	public function isReady():Bool {
		if (this._pendingData.length > 0) {
			return false;
		}
		
		for (index in 0...this._geometries.length) {
			var geometry = this._geometries[index];
			
			if (geometry.delayLoadState == Engine.DELAYLOADSTATE_LOADING) {
				return false;
			}
		}
		
		for (index in 0...this.meshes.length) {
			var mesh = this.meshes[index];
			
			if (!mesh.isReady()) {
				return false;
			}
			
			var mat = mesh.material;
			if (mat != null) {
				if (!mat.isReady(mesh)) {
					return false;
				}
			}
			
		}
		
		return true;
	}

	public function resetCachedMaterial() {
        this._cachedMaterial = null;
    }
	
	public function registerBeforeRender(func:Void->Void) {
		this._onBeforeRenderCallbacks.push(func);
	}

	public function unregisterBeforeRender(func:Void->Void) {
		this._onBeforeRenderCallbacks.remove(func);
	}
	
	public function registerAfterRender(func:Void->Void) {
        this._onAfterRenderCallbacks.push(func);
    }
	
    public function unregisterAfterRender(func:Void->Void) {
        this._onAfterRenderCallbacks.remove(func);
    }

	public function _addPendingData(data:Dynamic) {
		this._pendingData.push(data);
	}

	public function _removePendingData(data:Dynamic) {
		this._pendingData.remove(data);
	}

	public function getWaitingItemsCount():Int {
		return this._pendingData.length;
	}

	public function executeWhenReady(func:Void->Void) {
		this._onReadyCallbacks.push(func);
		
		if (this._executeWhenReadyTimeoutId != -1) {
			return;
		}
		
		this._executeWhenReadyTimeoutId = 1;
		Timer.delay(this._checkIsReady, 150);
	}

	public function _checkIsReady() {
		if (this.isReady()) {
			for (func in this._onReadyCallbacks) {
				func();
			}
			
			this._onReadyCallbacks = [];
			this._executeWhenReadyTimeoutId = -1;
			return;
		}
		
		this._executeWhenReadyTimeoutId = 1; 
		Timer.delay(this._checkIsReady, 150);
	}

	// Animations
	public function beginAnimation(target:Dynamic, from:Int, to:Int, loop:Bool = false/*?loop:Bool*/, speedRatio:Float = 1.0, ?onAnimationEnd:Void->Void, ?animatable:Animatable):Animatable {
		this.stopAnimation(target);
		
		if (animatable == null) {
			animatable = new Animatable(this, target, from, to, loop, speedRatio, onAnimationEnd);
		}
		
		// Local animations
		if (target.animations != null) {
			animatable.appendAnimations(target, target.animations);
		}
		
		// Children animations
		if (target.getAnimatables != null) {
			var animatables:Array<Dynamic> = target.getAnimatables();
			for (index in 0...animatables.length) {
				this.beginAnimation(animatables[index], from, to, loop, speedRatio, onAnimationEnd, animatable);
			}
		}
		
		return animatable;
	}

	public function beginDirectAnimation(target:Dynamic, animations:Array<Animation>, from:Int, to:Int, loop:Bool = false/*?loop:Bool*/, ?speedRatio:Float, ?onAnimationEnd:Void->Void):Animatable {
		if (speedRatio == null) {
			speedRatio = 1.0;
		}
		
		var animatable = new Animatable(this, target, from, to, loop, speedRatio, onAnimationEnd, animations);
		
		return animatable;
	}

	public function getAnimatableByTarget(target:Dynamic):Animatable {
		for (index in 0...this._activeAnimatables.length) {
			if (this._activeAnimatables[index].target == target) {
				return this._activeAnimatables[index];
			}
		}
		
		return null;
	}

	public function stopAnimation(target:Dynamic) {
		var animatable = this.getAnimatableByTarget(target);
		
		if (animatable != null) {
			animatable.stop();
		}
	}
	
	private function _animate() {
		if (!this.animationsEnabled) {
			return;
		}
		
		if (this._animationStartDate == -1) {
			this._animationStartDate = Tools.Now();
		}
		
		// Getting time
		var now = Tools.Now();
		var delay = now - this._animationStartDate;
		
		var index:Int = 0;
		while(index < this._activeAnimatables.length) {
			if (!this._activeAnimatables[index]._animate(delay)) {
				this._activeAnimatables.splice(index, 1);
				--index;
			}
			++index;
		}
	}

	// Matrix
	public function getViewMatrix():Matrix {
		return this._viewMatrix;
	}

	public function getProjectionMatrix():Matrix {
		return this._projectionMatrix;
	}

	public function getTransformMatrix():Matrix {
		return this._transformMatrix;
	}

	public function setTransformMatrix(view:Matrix, projection:Matrix) {
		this._viewMatrix = view;
		this._projectionMatrix = projection;
		
		this._viewMatrix.multiplyToRef(this._projectionMatrix, this._transformMatrix);
	}

	// Methods
	public function setActiveCameraByID(id:String):Camera {
		var camera = this.getCameraByID(id);
		
		if (camera != null) {
			this.activeCamera = camera;
			return camera;
		}
		
		return null;
	}

	public function setActiveCameraByName(name:String):Camera {
		var camera = this.getCameraByName(name);
		
		if (camera != null) {
			this.activeCamera = camera;
			return camera;
		}
		
		return null;
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

	public function getCameraByID(id:String):Camera {
		for (index in 0...this.cameras.length) {
			if (this.cameras[index].id == id) {
				return this.cameras[index];
			}
		}
		
		return null;
	}

	public function getCameraByName(name:String):Camera {
		for (index in 0...this.cameras.length) {
			if (this.cameras[index].name == name) {
				return this.cameras[index];
			}
		}
		
		return null;
	}

	public function getLightByName(name:String):Light {
		for (index in 0...this.lights.length) {
			if (this.lights[index].name == name) {
				return this.lights[index];
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

	public function getGeometryByID(id:String):Geometry {
		for (index in 0...this._geometries.length) {
			if (this._geometries[index].id == id) {
				return this._geometries[index];
			}
		}
		
		return null;
	}

	public function pushGeometry(geometry:Geometry, force:Bool = false/*?force:Bool*/):Bool {
		if (!force && this.getGeometryByID(geometry.id) != null) {
			return false;
		}
		
		this._geometries.push(geometry);
		
		return true;
	}

	public function getGeometries():Array<Geometry> {
		return this._geometries;
	}

	public function getMeshByID(id:String):AbstractMesh {
		for (index in 0...this.meshes.length) {
			if (this.meshes[index].id == id) {
				return this.meshes[index];
			}
		}
		
		return null;
	}

	public function getLastMeshByID(id:String):AbstractMesh {
		var index:Int = this.meshes.length -1;
		while(index >= 0) {
			if (this.meshes[index].id == id) {
				return this.meshes[index];
			}
			--index;
		}
		
		return null;
	}

	public function getLastEntryByID(id:String):Node {
		var index:Int = this.meshes.length - 1;
		while(index >= 0) {
			if (this.meshes[index].id == id) {
				return this.meshes[index];
			}
			--index;
		}
		
		index = this.cameras.length - 1;
		while(index >= 0) {
			if (this.cameras[index].id == id) {
				return this.cameras[index];
			}
			--index;
		}
		
		index = this.lights.length - 1;
		while(index >= 0) {
			if (this.lights[index].id == id) {
				return this.lights[index];
			}
			--index;
		}
		
		return null;
	}

	public function getMeshByName(name:String):AbstractMesh {
		for (index in 0...this.meshes.length) {
			if (this.meshes[index].name == name) {
				return this.meshes[index];
			}
		}
		
		return null;
	}

	public function getLastSkeletonByID(id:String):Skeleton {
		var index:Int = this.skeletons.length - 1;
		while(index >= 0) {
			if (this.skeletons[index].id == id) {
				return this.skeletons[index];
			}
			--index;
		}
		
		return null;
	}

	public function getSkeletonById(id:String):Skeleton {
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

	public function isActiveMesh(mesh:Mesh):Bool {
		return (this._activeMeshes.indexOf(mesh) != -1);
	}

	private function _evaluateSubMesh(subMesh:SubMesh, mesh:AbstractMesh) {
		if (mesh.subMeshes.length == 1 || subMesh.isInFrustum(this._frustumPlanes)) {
			var material = subMesh.getMaterial();
			
			if (mesh.showSubMeshesBoundingBox) {
				this._boundingBoxRenderer.renderList.push(subMesh.getBoundingInfo().boundingBox);
			}
			
			if (material != null) {
				// Render targets
				if (material.getRenderTargetTextures != null) {
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

	private function _evaluateActiveMeshes() {
		this._activeMeshes.reset();
		this._renderingManager.reset();
		this._processedMaterials.reset();
		this._activeParticleSystems.reset();
		this._activeSkeletons.reset();
		this._boundingBoxRenderer.reset();
		
		if (this._frustumPlanes == null) {
			this._frustumPlanes = Frustum.GetPlanes(this._transformMatrix);
		} else {
			Frustum.GetPlanesToRef(this._transformMatrix, this._frustumPlanes);
		}
		
		// Meshes
		var meshes:Array<AbstractMesh> = null;
		var len:Int = -1;
		
		if (this._selectionOctree != null) { // Octree
			var selection = this._selectionOctree.select(this._frustumPlanes);
			meshes = cast selection.data;
			len = selection.length;
		} else { // Full scene traversal
			len = this.meshes.length;
			meshes = this.meshes;
		}
				
		for (meshIndex in 0...len) {
			var mesh = meshes[meshIndex];
			
			if (mesh.isBlocked) {
				continue;
			}
			
			this._totalVertices += mesh.getTotalVertices();
			
			if (!mesh.isReady()) {
				continue;
			}
			
			mesh.computeWorldMatrix();
			
			// Intersections
			if (mesh.actionManager != null && mesh.actionManager.hasSpecificTriggers([ActionManager.OnIntersectionEnterTrigger, ActionManager.OnIntersectionExitTrigger])) {
				this._meshesForIntersections.pushNoDuplicate(mesh);
			}
			
			// Switch to current LOD
			var meshLOD = mesh.getLOD(this.activeCamera);
			
			if (meshLOD == null) {
				continue;
			}
			
			mesh._preActivate();
			if (mesh.isEnabled() && mesh.isVisible && mesh.visibility > 0 && ((mesh.layerMask & this.activeCamera.layerMask) != 0) && mesh.isInFrustum(this._frustumPlanes)) {
				this._activeMeshes.push(mesh);
				mesh._activate(this._renderId);
								
				this._activeMesh(meshLOD);
			}
		}
		
		// Particle systems
		var beforeParticlesDate = Tools.Now();
		if (this.particlesEnabled) {
			//Tools.StartPerformanceCounter("Particles", this.particleSystems.length > 0);
			for (particleIndex in 0...this.particleSystems.length) {
				var particleSystem = this.particleSystems[particleIndex];
				
				if (!particleSystem.isStarted()) {
					continue;
				}
				
				if (particleSystem.emitter.position == null || (particleSystem.emitter != null && particleSystem.emitter.isEnabled())) {
					this._activeParticleSystems.push(particleSystem);
					particleSystem.animate();
				}
			}
			//Tools.EndPerformanceCounter("Particles", this.particleSystems.length > 0);
		}
		this._particlesDuration += Tools.Now() - beforeParticlesDate;
	}

	private function _activeMesh(mesh:AbstractMesh) {
		if (mesh.skeleton != null && this.skeletonsEnabled) {
			this._activeSkeletons.pushNoDuplicate(mesh.skeleton);
		}
		
		if (mesh.showBoundingBox || this.forceShowBoundingBoxes) {
			this._boundingBoxRenderer.renderList.push(mesh.getBoundingInfo().boundingBox);
		}   
        
		if (mesh != null && mesh.subMeshes != null) {
			// Submeshes Octrees
			var len:Int = -1;
			var subMeshes:Array<SubMesh> = null;
			
			if (mesh._submeshesOctree != null && mesh.useOctreeForRenderingSelection) {
				var intersections = mesh._submeshesOctree.select(this._frustumPlanes);
				
				len = intersections.length;
				subMeshes = cast intersections.data;
			} else {
				subMeshes = mesh.subMeshes;
				len = subMeshes.length;
			}
			
			for (subIndex in 0...len) {
				var subMesh = subMeshes[subIndex];
				this._evaluateSubMesh(subMesh, mesh);
			}
		}
	}

	public function updateTransformMatrix(force:Bool = false/*?force:Bool*/) {
		this.setTransformMatrix(this.activeCamera.getViewMatrix(), this.activeCamera.getProjectionMatrix(force));
	}

	private function _renderForCamera(camera:Camera) {
		var engine = this._engine;
		
		this.activeCamera = camera;
		
		if (this.activeCamera == null) {
			throw("Active camera not set");
		}
			
		//Tools.StartPerformanceCounter("Rendering camera " + this.activeCamera.name);
		// Viewport
		engine.setViewport(this.activeCamera.viewport);
		
		// Camera
		this._renderId++;
		this.updateTransformMatrix();
		
		if (this.beforeCameraRender != null) {
			this.beforeCameraRender(this.activeCamera);
		}
		
		// Meshes
		var beforeEvaluateActiveMeshesDate = Tools.Now();
		//Tools.StartPerformanceCounter("Active meshes evaluation");
		this._evaluateActiveMeshes();
		this._evaluateActiveMeshesDuration += Tools.Now() - beforeEvaluateActiveMeshesDate;
		//Tools.EndPerformanceCounter("Active meshes evaluation");
		
		// Skeletons
		for (skeletonIndex in 0...this._activeSkeletons.length) {
			var skeleton = this._activeSkeletons.data[skeletonIndex];			
			skeleton.prepare();			
			this._activeBones += skeleton.bones.length;
		}
		
		// Render targets
		var beforeRenderTargetDate = Tools.Now();
		if (this.renderTargetsEnabled) {
			//Tools.StartPerformanceCounter("Render targets", this._renderTargets.length > 0);
			for (renderIndex in 0...this._renderTargets.length) {
				var renderTarget = this._renderTargets.data[renderIndex];
				if (renderTarget._shouldRender()) {
					this._renderId++;
					renderTarget.render();
				}
			}
			//Tools.EndPerformanceCounter("Render targets", this._renderTargets.length > 0);
			this._renderId++;
		}
		
		if (this._renderTargets.length > 0) { // Restore back buffer
			engine.restoreDefaultFramebuffer();
		}
		this._renderTargetsDuration += Tools.Now() - beforeRenderTargetDate;
		
		// Prepare Frame
		this.postProcessManager._prepareFrame();
		
		var beforeRenderDate = Tools.Now();
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
		//Tools.StartPerformanceCounter("Main render");
		this._renderingManager.render(null, null, true, true);
		//Tools.EndPerformanceCounter("Main render");
		
		// Bounding boxes
		this._boundingBoxRenderer.render();
		
		// Lens flares
		if (this.lensFlaresEnabled) {
			//Tools.StartPerformanceCounter("Lens flares", this.lensFlareSystems.length > 0);
			for (lensFlareSystemIndex in 0...this.lensFlareSystems.length) {
				this.lensFlareSystems[lensFlareSystemIndex].render();
			}
			//Tools.EndPerformanceCounter("Lens flares", this.lensFlareSystems.length > 0);
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
		
		this._renderDuration += Tools.Now() - beforeRenderDate;
		
		// Finalize frame
		this.postProcessManager._finalizeFrame(camera.isIntermediate);
		
		// Update camera
		this.activeCamera._updateFromScene();
		
		// Reset some special arrays
		this._renderTargets.reset();
		
		if (this.afterCameraRender != null) {
			this.afterCameraRender(this.activeCamera);
		}
		
		//Tools.EndPerformanceCounter("Rendering camera " + this.activeCamera.name);
	}

	private function _processSubCameras(camera:Camera) {
		if (camera.subCameras.length == 0) {
			this._renderForCamera(camera);
			return;
		}
		
		// Sub-cameras
		for (index in 0...camera.subCameras.length) {
			this._renderForCamera(camera.subCameras[index]);
		}
		
		this.activeCamera = camera;
		this.setTransformMatrix(this.activeCamera.getViewMatrix(), this.activeCamera.getProjectionMatrix());
		
		// Update camera
		this.activeCamera._updateFromScene();
	}

	private function _checkIntersections() {
		for (index in 0...this._meshesForIntersections.length) {
			var sourceMesh:AbstractMesh = cast this._meshesForIntersections.data[index];
			
			for (actionIndex in 0...sourceMesh.actionManager.actions.length) {
				var action:Action = sourceMesh.actionManager.actions[actionIndex];
				
				if (action.trigger == ActionManager.OnIntersectionEnterTrigger || action.trigger == ActionManager.OnIntersectionExitTrigger) {
					var otherMesh:AbstractMesh = cast action.getTriggerParameter();
					
					var areIntersecting = otherMesh.intersectsMesh(sourceMesh, false);
					var currentIntersectionInProgress = sourceMesh._intersectionsInProgress.indexOf(otherMesh);
					
					if (areIntersecting && currentIntersectionInProgress == -1 && action.trigger == ActionManager.OnIntersectionEnterTrigger) {
						action._executeCurrent(ActionEvent.CreateNew(sourceMesh));
						sourceMesh._intersectionsInProgress.push(otherMesh);
						
					} else if (!areIntersecting && currentIntersectionInProgress > -1 && action.trigger == ActionManager.OnIntersectionExitTrigger) {
						action._executeCurrent(ActionEvent.CreateNew(sourceMesh));
						
						var indexOfOther = sourceMesh._intersectionsInProgress.indexOf(otherMesh);
						
						if (indexOfOther > -1) {
							sourceMesh._intersectionsInProgress.splice(indexOfOther, 1);
						}
					}
				}
			}
		}
	}

	public function render() {
		var startDate = Tools.Now();
		this._particlesDuration = 0;
		this._spritesDuration = 0;
		this._activeParticles = 0;
		this._renderDuration = 0;
		this._renderTargetsDuration = 0;
		this._evaluateActiveMeshesDuration = 0;
		this._totalVertices = 0;
		this._activeVertices = 0;
		this._activeBones = 0;
		this.getEngine().resetDrawCalls();
		this._meshesForIntersections.reset();
		this.resetCachedMaterial();
			
		//Tools.StartPerformanceCounter("Scene rendering");
		
		// Actions
		if (this.actionManager != null) {
			this.actionManager.processTrigger(ActionManager.OnEveryFrameTrigger, null);
		}
		
		// Before render
		if (this.beforeRender != null) {
			this.beforeRender();
		}
		
		for (callbackIndex in 0...this._onBeforeRenderCallbacks.length) {
			this._onBeforeRenderCallbacks[callbackIndex]();
		}
		
		// Animations
		var deltaTime = Math.max(Scene.MinDeltaTime, Math.min(this._engine.getDeltaTime(), Scene.MaxDeltaTime));
		this._animationRatio = deltaTime * (60.0 / 1000.0);
		this._animate();
		
		// Physics
		if (this._physicsEngine != null) {
			//Tools.StartPerformanceCounter("Physics");
			this._physicsEngine._runOneStep(deltaTime / 1000.0);
			//Tools.EndPerformanceCounter("Physics");
		}
		
		// Customs render targets
		var beforeRenderTargetDate = Tools.Now();
		var engine = this.getEngine();
		if (this.renderTargetsEnabled) {
			//Tools.StartPerformanceCounter("Custom render targets", this.customRenderTargets.length > 0);
			for (customIndex in 0...this.customRenderTargets.length) {
				var renderTarget = this.customRenderTargets[customIndex];
				if (renderTarget._shouldRender()) {
					this._renderId++;
					
					this.activeCamera = renderTarget.activeCamera != null ? renderTarget.activeCamera : this.activeCamera;
					
					if (this.activeCamera == null) {
						throw("Active camera not set");
					}
						
					// Viewport
					engine.setViewport(this.activeCamera.viewport);
					
					// Camera
					this.updateTransformMatrix();
					
					renderTarget.render();
				}
			}
			//Tools.EndPerformanceCounter("Custom render targets", this.customRenderTargets.length > 0);
			
			this._renderId++;
		}
		
		if (this.customRenderTargets.length > 0) { // Restore back buffer
			engine.restoreDefaultFramebuffer();
		}
		this._renderTargetsDuration += Tools.Now() - beforeRenderTargetDate;
		
		// Procedural textures
		if (this.proceduralTexturesEnabled) {
			//Tools.StartPerformanceCounter("Procedural textures", this._proceduralTextures.length > 0);
			// TODO
			for (proceduralIndex in 0...this._proceduralTextures.length) {
				var proceduralTexture = this._proceduralTextures[proceduralIndex];
				if (proceduralTexture._shouldRender()) {
					proceduralTexture.render();
				}
			}
			//Tools.EndPerformanceCounter("Procedural textures", this._proceduralTextures.length > 0);
		}
		
		// Clear
		this._engine.clear(this.clearColor, this.autoClear || this.forceWireframe || this.forcePointsCloud, true);
		
		// Shadows
		if (this.shadowsEnabled) {
			for (lightIndex in 0...this.lights.length) {
				var light = this.lights[lightIndex];
				var shadowGenerator = light.getShadowGenerator();
				
				if (light.isEnabled() && shadowGenerator != null && shadowGenerator.getShadowMap().getScene().textures.indexOf(shadowGenerator.getShadowMap()) != -1) {
					this._renderTargets.push(shadowGenerator.getShadowMap());
				}
			}
		}
		
		// RenderPipeline
		this.postProcessRenderPipelineManager.update();
		// Multi-cameras?
		if (this.activeCameras.length > 0) {
			var currentRenderId = this._renderId;
			for (cameraIndex in 0...this.activeCameras.length) {
				this._renderId = currentRenderId;
				this._processSubCameras(this.activeCameras[cameraIndex]);
			}
		} else {
			if (this.activeCamera == null) {
				throw("No camera defined");
			}
			
			this._processSubCameras(this.activeCamera);
		}
		
		// Intersection checks
		this._checkIntersections();
		
		// After render
		if (this.afterRender != null) {
			this.afterRender();
		}
		
		for (callback in this._onAfterRenderCallbacks) {
            callback();
        }
		
		// Cleaning
		for (index in 0...this._toBeDisposed.length) {
			this._toBeDisposed.data[index].dispose();
			// TODO
			this._toBeDisposed.data[index] = null;
			//this._toBeDisposed[index] = null;
			//this._toBeDisposed.data.splice(index, 1);
		}
		
		this._toBeDisposed.reset();
		
		//Tools.EndPerformanceCounter("Scene rendering");
		this._lastFrameDuration = Tools.Now() - startDate;
	}

	public function dispose() {
		this.beforeRender = null;
		this.afterRender = null;
		
		this.skeletons = [];
		
		this._boundingBoxRenderer.dispose();
		
		// Events
		if (this.onDispose != null) {
			this.onDispose();
		}
		
		this.detachControl();
		
		this._onBeforeRenderCallbacks = [];
		this._onAfterRenderCallbacks = [];
		
		// Detach cameras
		/*var canvas = this._engine.getRenderingCanvas();
		var index;
		for (index = 0; index < this.cameras.length; index++) {
			this.cameras[index].detachControl(canvas);
		}*/
		
		// Release lights
		while (this.lights.length > 0) {
			this.lights[0].dispose();
		}
		
		// Release meshes
		while (this.meshes.length > 0) {
			this.meshes[0].dispose(true);
		}
		
		// Release cameras
		while (this.cameras.length > 0) {
			this.cameras[0].dispose();
		}
		
		// Release materials
		while (this.materials.length > 0) {
			this.materials[0].dispose();
		}
		
		// Release particles
		while (this.particleSystems.length > 0) {
			this.particleSystems[0].dispose();
		}
		
		// Release sprites
		while (this.spriteManagers.length > 0) {
			this.spriteManagers[0].dispose();
		}
		
		// Release layers
		while (this.layers.length > 0) {
			this.layers[0].dispose();
		}
		
		// Release textures
		while (this.textures.length > 0) {
			this.textures[0].dispose();
		}
		
		// Post-processes
		this.postProcessManager.dispose();
		
		// Physics
		if (this._physicsEngine != null) {
			this.disablePhysicsEngine();
		}
		
		// Remove from engine
		this._engine.scenes.remove(this);
		
		this._engine.wipeCaches();
	}

	// Collisions
	public function _getNewPosition(position:Vector3, velocity:Vector3, collider:Collider, maximumRetry:Int, finalPosition:Vector3, excludedMesh:AbstractMesh = null) {
		position.divideToRef(collider.radius, this._scaledPosition);
		velocity.divideToRef(collider.radius, this._scaledVelocity);
		
		collider.retry = 0;
		collider.initialVelocity = this._scaledVelocity;
		collider.initialPosition = this._scaledPosition;
		this._collideWithWorld(this._scaledPosition, this._scaledVelocity, collider, maximumRetry, finalPosition, excludedMesh);
		
		finalPosition.multiplyInPlace(collider.radius);
	}

	private function _collideWithWorld(position:Vector3, velocity:Vector3, collider:Collider, maximumRetry:Int, finalPosition:Vector3, excludedMesh:AbstractMesh = null) {
		var closeDistance = Engine.CollisionsEpsilon * 10.0;
		
		if (collider.retry >= maximumRetry) {
			finalPosition.copyFrom(position);
			return;
		}
		
		collider._initialize(position, velocity, closeDistance);
		
		// Check all meshes
		for (index in 0...this.meshes.length) {
			var mesh = this.meshes[index];
			if (mesh.isEnabled() && mesh.checkCollisions && mesh.subMeshes != null && mesh != excludedMesh) {
				mesh._checkCollision(collider);
			}
		}
		
		if (!collider.collisionFound) {
			position.addToRef(velocity, finalPosition);
			return;
		}
		
		if (velocity.x != 0 || velocity.y != 0 || velocity.z != 0) {
			collider._getResponse(position, velocity);
		}
		
		if (velocity.length() <= closeDistance) {
			finalPosition.copyFrom(position);
			return;
		}
		
		collider.retry++;
		this._collideWithWorld(position, velocity, collider, maximumRetry, finalPosition, excludedMesh);
	}

	// Octrees
	public function createOrUpdateSelectionOctree(maxCapacity:Int = 64, maxDepth:Int = 2):Octree<AbstractMesh> {
		if (this._selectionOctree == null) {
			this._selectionOctree = new Octree<AbstractMesh>(Octree.CreationFuncForMeshes, maxCapacity, maxDepth);
		}
		
		var min = new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
		var max = new Vector3(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);
		for (index in 0...this.meshes.length) {
			var mesh = this.meshes[index];
			
			mesh.computeWorldMatrix(true);
			var minBox = mesh.getBoundingInfo().boundingBox.minimumWorld;
			var maxBox = mesh.getBoundingInfo().boundingBox.maximumWorld;
			
			Tools.CheckExtends(minBox, min, max);
			Tools.CheckExtends(maxBox, min, max);
		}
		
		// Update octree
		this._selectionOctree.update(min, max, this.meshes);
		
		return this._selectionOctree;
	}

	// Picking
	public function createPickingRay(x:Float, y:Float, world:Matrix, camera:Camera):Ray {
		var engine = this._engine;
		
		if (camera == null) {
			if (this.activeCamera == null) {
				throw("Active camera not set");
			}
			
			camera = this.activeCamera;
		}
		
		var cameraViewport = camera.viewport;
		var viewport = cameraViewport.toGlobal(engine);
		
		// Moving coordinates to local viewport world
		x = x / this._engine.getHardwareScalingLevel() - viewport.x;
		y = y / this._engine.getHardwareScalingLevel() - (this._engine.getRenderHeight() - viewport.y - viewport.height);
		return Ray.CreateNew(x, y, viewport.width, viewport.height, world != null ? world : Matrix.Identity(), camera.getViewMatrix(), camera.getProjectionMatrix());
		//       return Ray.CreateNew(x / window.devicePixelRatio, y / window.devicePixelRatio, viewport.width, viewport.height, world ? world :Matrix.Identity(), camera.getViewMatrix(), camera.getProjectionMatrix());
	}

	private function _internalPick(rayFunction:Matrix->Ray, predicate:AbstractMesh->Bool, fastCheck:Bool = false/*?fastCheck:Bool*/):PickingInfo {
		var pickingInfo:PickingInfo = null;
		
		for (meshIndex in 0...this.meshes.length) {
			var mesh = this.meshes[meshIndex];
			
			if (predicate != null) {
				if (!predicate(mesh)) {
					continue;
				}
			} else if (!mesh.isEnabled() || !mesh.isVisible || !mesh.isPickable) {
				continue;
			}
			
			var world = mesh.getWorldMatrix();
			var ray = rayFunction(world);
			
			var result = mesh.intersects(ray, fastCheck);
			if (result == null || !result.hit)
				continue;
				
			if (!fastCheck && pickingInfo != null && result.distance >= pickingInfo.distance)
				continue;
				
			pickingInfo = result;
			
			if (fastCheck) {
				break;
			}
		}
		
		return pickingInfo != null ? pickingInfo : new PickingInfo();
	}

	public function pick(x:Float, y:Float, ?predicate:AbstractMesh->Bool, fastCheck:Bool = false/*?fastCheck:Bool*/, ?camera:Camera):PickingInfo {
		/// <summary>Launch a ray to try to pick a mesh in the scene</summary>
		/// <param name="x">X position on screen</param>
		/// <param name="y">Y position on screen</param>
		/// <param name="predicate">Predicate function used to determine eligible meshes. Can be set to null. In this case, a mesh must be enabled, visible and with isPickable set to true</param>
		/// <param name="fastCheck">Launch a fast check only using the bounding boxes. Can be set to null.</param>
		/// <param name="camera">camera to use for computing the picking ray. Can be set to null. In this case, the scene.activeCamera will be used</param>
		return this._internalPick(function(world:Matrix):Ray { return this.createPickingRay(x, y, world, camera); }, predicate, fastCheck);
	}

	public function pickWithRay(ray:Ray, predicate:Mesh->Bool, fastCheck:Bool = false/*?fastCheck:Bool*/):PickingInfo {
		return this._internalPick(function(world:Matrix):Ray {
			if (this._pickWithRayInverseMatrix == null) {
				this._pickWithRayInverseMatrix = Matrix.Identity();
			}
			world.invertToRef(this._pickWithRayInverseMatrix);
			return Ray.Transform(ray, this._pickWithRayInverseMatrix);
		}, cast predicate, fastCheck);
	}

	public function setPointerOverMesh(mesh:AbstractMesh) {
		if (this._pointerOverMesh == mesh) {
			return;
		}
		
		if (this._pointerOverMesh != null && this._pointerOverMesh.actionManager != null) {
		this._pointerOverMesh.actionManager.processTrigger(ActionManager.OnPointerOutTrigger, ActionEvent.CreateNew(this._pointerOverMesh));
		}
		
		this._pointerOverMesh = mesh;
		if (this._pointerOverMesh != null && this._pointerOverMesh.actionManager != null) {
			this._pointerOverMesh.actionManager.processTrigger(ActionManager.OnPointerOverTrigger, ActionEvent.CreateNew(this._pointerOverMesh));
		}
	}

	public function getPointerOverMesh():AbstractMesh {
		return this._pointerOverMesh;
	}

	// Physics
	public function getPhysicsEngine():PhysicsEngine {
		return this._physicsEngine;
	}

	public function enablePhysics(?gravity:Vector3, ?plugin:IPhysicsEnginePlugin):Bool {
		if (this._physicsEngine != null) {
			return true;
		}
		
		this._physicsEngine = new PhysicsEngine(plugin);
		
		if (!this._physicsEngine.isSupported()) {
			this._physicsEngine = null;
			return false;
		}
		
		this._physicsEngine._initialize(gravity);
		
		return true;
	}

	public function disablePhysicsEngine() {
		if (this._physicsEngine == null) {
			return;
		}
		
		this._physicsEngine.dispose();
		this._physicsEngine = null;
	}

	public function isPhysicsEnabled():Bool {
		return this._physicsEngine != null;
	}

	public function setGravity(gravity:Vector3) {
		if (this._physicsEngine == null) {
			return;
		}
		
		this._physicsEngine._setGravity(gravity);
	}

	public function createCompoundImpostor(parts:Dynamic, options:PhysicsBodyCreationOptions):Dynamic {
		if (parts.parts != null) { // Old API
			options = parts;
			parts = parts.parts;
		}
		
		if (this._physicsEngine == null) {
			return null;
		}
		
		for (index in 0...parts.length) {
			var mesh = parts[index].mesh;
			
			mesh._physicImpostor = parts[index].impostor;
			mesh._physicsMass = options.mass / parts.length;
			mesh._physicsFriction = options.friction;
			mesh._physicRestitution = options.restitution;
		}
		
		return this._physicsEngine._registerMeshesAsCompound(parts, options);
	}

	//ANY
	public function deleteCompoundImpostor(compound:Dynamic) {
		for (index in 0...compound.parts.length) {
			var mesh:AbstractMesh = cast compound.parts[index].mesh;
			mesh._physicImpostor = PhysicsEngine.NoImpostor;
			this._physicsEngine._unregisterMesh(mesh);
		}
	}

	// Tags
	// TODO
	/*private function _getByTags(list:Array<Dynamic>, tagsQuery:String):Array<Dynamic> {
		if (tagsQuery == null) {
			// returns the complete list (could be done with Tags.MatchesQuery but no need to have a for-loop here)
			return list;
		}

		var listByTags:Array<Dynamic> = [];

		for (i in list) {
			var item = list[i];
			if (Tags.MatchesQuery(item, tagsQuery)) {
				listByTags.push(item);
			}
		}

		return listByTags;
	}

	public function getMeshesByTags(tagsQuery:String):Array<Mesh> {
		return cast this._getByTags(this.meshes, tagsQuery);
	}

	public function getCamerasByTags(tagsQuery:String):Array<Camera> {
		return cast this._getByTags(this.cameras, tagsQuery);
	}

	public function getLightsByTags(tagsQuery:String):Array<Light> {
		return cast this._getByTags(this.lights, tagsQuery);
	}

	public function getMaterialByTags(tagsQuery:String):Array<Material> {
		return cast this._getByTags(this.materials, tagsQuery).concat(this._getByTags(this.multiMaterials, tagsQuery));
	}*/
	
}
