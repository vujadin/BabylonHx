package com.babylonhx;

import com.babylonhx.actions.Action;
import com.babylonhx.actions.ActionManager;
import com.babylonhx.actions.ActionEvent;
import com.babylonhx.animations.Animatable;
import com.babylonhx.animations.Animation;
import com.babylonhx.animations.IAnimatable;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.bones.Bone;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.collisions.Collider;
import com.babylonhx.collisions.PickingInfo;
import com.babylonhx.culling.octrees.Octree;
import com.babylonhx.layer.Layer;
import com.babylonhx.lensflare.LensFlareSystem;
import com.babylonhx.lights.HemisphericLight;
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
import com.babylonhx.culling.Ray;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Frustum;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Geometry;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.collisions.ICollisionCoordinator;
import com.babylonhx.collisions.CollisionCoordinatorLegacy;
import com.babylonhx.mesh.simplification.SimplificationQueue;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.physics.PhysicsEngine;
import com.babylonhx.physics.IPhysicsEnginePlugin;
import com.babylonhx.physics.PhysicsBodyCreationOptions;
import com.babylonhx.postprocess.PostProcessManager;
import com.babylonhx.postprocess.renderpipeline.PostProcessRenderPipelineManager;
import com.babylonhx.probes.ReflectionProbe;
import com.babylonhx.rendering.BoundingBoxRenderer;
import com.babylonhx.rendering.DepthRenderer;
import com.babylonhx.rendering.OutlineRenderer;
import com.babylonhx.rendering.EdgesRenderer;
import com.babylonhx.rendering.RenderingManager;
import com.babylonhx.sprites.SpriteManager;
import com.babylonhx.sprites.Sprite;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.tools.Tools;
import com.babylonhx.tools.Observable;
import com.babylonhx.tools.Observer;
import com.babylonhx.tools.EventState;

#if (purejs || js)
import com.babylonhx.audio.*;
#end

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Scene') class Scene implements IAnimatable {
	
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
	
	public var forceWireframe:Bool = false;
	public var forcePointsCloud:Bool = false;
	public var forceShowBoundingBoxes:Bool = false;
	public var clipPlane:Plane;
	public var animationsEnabled:Bool = true;
	public var constantlyUpdateMeshUnderPointer:Bool = false;
	
	// Events

	/**
	* An event triggered when the scene is disposed.
	* @type {BABYLON.Observable}
	*/
	public var onDisposeObservable:Observable<Scene> = new Observable<Scene>();

	public var onDispose(never, set):Scene->Null<EventState>->Void;
	private var _onDisposeObserver:Observer<Scene>;
	private function set_onDispose(callback:Scene->Null<EventState>->Void):Scene->Null<EventState>->Void {
		if (this._onDisposeObserver != null) {
			this.onDisposeObservable.remove(this._onDisposeObserver);
		}
		
		this._onDisposeObserver = this.onDisposeObservable.add(callback);
		
		return callback;
	}

	/**
	* An event triggered before rendering the scene
	* @type {BABYLON.Observable}
	*/
	public var onBeforeRenderObservable:Observable<Scene> = new Observable<Scene>();
	
	public var beforeRender(never, set):Scene->Null<EventState>->Void;
	private var _onBeforeRenderObserver:Observer<Scene>;
	private function set_beforeRender(callback:Scene->Null<EventState>->Void):Scene->Null<EventState>->Void {
		if (this._onBeforeRenderObserver != null) {
			this.onBeforeRenderObservable.remove(this._onBeforeRenderObserver);
		}
		
		this._onBeforeRenderObserver = this.onBeforeRenderObservable.add(callback);
		
		return callback;
	}

	/**
	* An event triggered after rendering the scene
	* @type {BABYLON.Observable}
	*/
	public var onAfterRenderObservable:Observable<Scene> = new Observable<Scene>();

	public var afterRender(never, set):Scene->Null<EventState>->Void;
	private var _onAfterRenderObserver:Observer<Scene>;
	private function set_afterRender(callback:Scene->Null<EventState>->Void):Scene->Null<EventState>->Void {
		if (this._onAfterRenderObserver != null) {
			this.onAfterRenderObservable.remove(this._onAfterRenderObserver);
		}
		
		this._onAfterRenderObserver = this.onAfterRenderObservable.add(callback);
		
		return callback;
	}

	/**
	* An event triggered when the scene is ready
	* @type {BABYLON.Observable}
	*/
	public var onReadyObservable:Observable<Scene> = new Observable<Scene>();

	/**
	* An event triggered before rendering a camera
	* @type {BABYLON.Observable}
	*/
	public var onBeforeCameraRenderObservable:Observable<Camera> = new Observable<Camera>();

	public var beforeCameraRender(never, set):Camera->Null<EventState>->Void;
	private var _onBeforeCameraRenderObserver:Observer<Camera>;
	private function set_beforeCameraRender(callback:Camera->Null<EventState>->Void):Camera->Null<EventState>->Void {
		if (this._onBeforeCameraRenderObserver != null) {
			this.onBeforeCameraRenderObservable.remove(this._onBeforeCameraRenderObserver);
		}
		
		this._onBeforeCameraRenderObserver = this.onBeforeCameraRenderObservable.add(callback);
		
		return callback;
	}

	/**
	* An event triggered after rendering a camera
	* @type {BABYLON.Observable}
	*/
	public var onAfterCameraRenderObservable:Observable<Camera> = new Observable<Camera>();
	
	public var afterCameraRender(never, set):Camera->EventState->Void;
	private var _onAfterCameraRenderObserver:Observer<Camera>;
	private function set_afterCameraRender(callback:Camera->EventState->Void) {
		if (this._onAfterCameraRenderObserver != null) {
			this.onAfterCameraRenderObservable.remove(this._onAfterCameraRenderObserver);
		}
		
		this._onAfterCameraRenderObserver = this.onAfterCameraRenderObservable.add(callback);
		
		return callback;
	}

	/**
	* An event triggered when a camera is created
	* @type {BABYLON.Observable}
	*/
	public var onNewCameraAddedObservable:Observable<Camera> = new Observable<Camera>();

	/**
	* An event triggered when a camera is removed
	* @type {BABYLON.Observable}
	*/
	public var onCameraRemovedObservable:Observable<Camera> = new Observable<Camera>();

	/**
	* An event triggered when a light is created
	* @type {BABYLON.Observable}
	*/
	public var onNewLightAddedObservable:Observable<Light> = new Observable<Light>();

	/**
	* An event triggered when a light is removed
	* @type {BABYLON.Observable}
	*/
	public var onLightRemovedObservable:Observable<Light> = new Observable<Light>();

	/**
	* An event triggered when a geometry is created
	* @type {BABYLON.Observable}
	*/
	public var onNewGeometryAddedObservable:Observable<Geometry> = new Observable<Geometry>();

	/**
	* An event triggered when a geometry is removed
	* @type {BABYLON.Observable}
	*/
	public var onGeometryRemovedObservable:Observable<Geometry> = new Observable<Geometry>();

	/**
	* An event triggered when a mesh is created
	* @type {BABYLON.Observable}
	*/
	public var onNewMeshAddedObservable:Observable<AbstractMesh> = new Observable<AbstractMesh>();

	/**
	* An event triggered when a mesh is removed
	* @type {BABYLON.Observable}
	*/
	public var onMeshRemovedObservable:Observable<AbstractMesh> = new Observable<AbstractMesh>();
	
	// Animations
	public var animations:Array<Animation> = [];

	// Pointers
	public var pointerDownPredicate:AbstractMesh->Bool;
	public var pointerUpPredicate:AbstractMesh->Bool;
	public var pointerMovePredicate:AbstractMesh->Bool;
	private var _onPointerMove:Int->Int->Void;
	private var _onPointerDown:Int->Int->Int->Void;
	private var _onPointerUp:Int->Int->Int->Void;
	
	/**
	 * Observable event triggered each time an input event is received from the rendering canvas
	 */
	//public var onPointerObservable:Observable = new Observable();
	
	public var onPointerMove:Int->Int->PickingInfo->Void;
	public var onPointerDown:Int->Int->Int->PickingInfo->Void;
	public var onPointerUp:Int->Int->Int->PickingInfo->Void;
	public var onPointerPick:PickingInfo->Void;
	
	// Define this parameter if you are using multiple cameras and you want to 
	// specify which one should be used for pointer position
	public var cameraToUseForPointers:Camera = null; 
	private var _pointerX:Int;
	private var _pointerY:Int;
	private var _unTranslatedPointerX:Int;
	private var _unTranslatedPointerY:Int;
	private var _meshUnderPointer:AbstractMesh; 
	private var _startingPointerPosition:Vector2 = new Vector2(0, 0);
	private var _startingPointerTime:Float = 0;
	
	// Mirror
    public var _mirroredCameraPosition:Vector3;

	// Keyboard
	private var _onKeyDown:Dynamic;		// Event->Void
	private var _onKeyUp:Dynamic;		// Event->Void

	// Fog
	/**
	* is fog enabled on this scene.
	* @type {boolean}
	*/
	public var fogEnabled:Bool = true;
	public var fogMode:Int = Scene.FOGMODE_NONE;
	public var fogColor:Color3 = new Color3(0.2, 0.2, 0.3);
	public var fogDensity:Float = 0.1;
	public var fogStart:Float = 0;
	public var fogEnd:Float = 1000.0;

	// Lights
	/**
	* is shadow enabled on this scene.
	* @type {boolean}
	*/
	public var shadowsEnabled:Bool = true;
	/**
	* is light enabled on this scene.
	* @type {boolean}
	*/
	public var lightsEnabled:Bool = true;
	/**
	* All of the lights added to this scene.
	* @see BABYLON.Light
	* @type {BABYLON.Light[]}
	*/
	public var lights:Array<Light> = [];

	// Cameras
	/**
	* All of the cameras added to this scene.
	* @see BABYLON.Camera
	* @type {BABYLON.Camera[]}
	*/
	public var cameras:Array<Camera> = [];
	public var activeCameras:Array<Camera> = [];
	public var activeCamera:Camera;

	// Meshes
	/**
	* All of the (abstract) meshes added to this scene.
	* @see BABYLON.AbstractMesh
	* @type {BABYLON.AbstractMesh[]}
	*/
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
	public var spritesEnabled:Bool = true;
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
	private var _workerCollisions:Bool = false;
	public var workerCollisions(get, set):Bool;
	private function set_workerCollisions(enabled:Bool):Bool {		
		this._workerCollisions = enabled;
		if (this.collisionCoordinator != null) {
			this.collisionCoordinator.destroy();
		}
		
		//this.collisionCoordinator = enabled ? new CollisionCoordinatorWorker() : new CollisionCoordinatorLegacy();
		this.collisionCoordinator = new CollisionCoordinatorLegacy();  // for now ...
		
		this.collisionCoordinator.init(this);
		
		return enabled;
	}
	private function get_workerCollisions():Bool {
		return this._workerCollisions;
	}
	
	public var SelectionOctree(get, never):Octree<AbstractMesh>;
	private function get_SelectionOctree():Octree<AbstractMesh> {
		return this._selectionOctree;
	}
	
	public var collisionCoordinator:ICollisionCoordinator;
	public var gravity:Vector3 = new Vector3(0, -9.0, 0);

	// Postprocesses
	public var postProcessesEnabled:Bool = true;
	public var postProcessManager:PostProcessManager;
	public var postProcessRenderPipelineManager:PostProcessRenderPipelineManager;

	// Customs render targets
	public var renderTargetsEnabled:Bool = true;
	public var dumpNextRenderTargets:Bool = false;
	public var customRenderTargets:Array<RenderTargetTexture> = [];

	// Delay loading
	public var useDelayedTextureLoading:Bool = false;

	// Imported meshes
	public var importedMeshesFiles:Array<String> = [];
	
	// Probes
	public var probesEnabled:Bool = true;
	public var reflectionProbes:Array<ReflectionProbe> = [];

	// Database
	public var database:Dynamic; //ANY

	// Actions
	/**
	 * This scene's action manager
	 * @type {BABYLON.ActionManager}
	 */
	public var actionManager:ActionManager;
	public var _actionManagers:Array<ActionManager> = [];
	private var _meshesForIntersections:SmartArray<AbstractMesh> = new SmartArray<AbstractMesh>(256);

	// Procedural textures
	public var proceduralTexturesEnabled:Bool = true;
	public var _proceduralTextures:Array<ProceduralTexture> = [];
	
	#if (purejs || js)
	// Sound Tracks
	public var mainSoundTrack: SoundTrack;
    public var soundTracks = new Array<SoundTrack>();
	private var _audioEnabled:Bool = true;
	private var _headphone:Bool = false;
	#end
	
	//Simplification Queue
	public var simplificationQueue:SimplificationQueue;

	// Private
	private var _engine:Engine;
	private var _totalVertices:Int = 0;
	public var _activeIndices:Int = 0;
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
	private var _intermediateRendering:Bool = false;

	public var _toBeDisposed:SmartArray<IDisposable> = new SmartArray<IDisposable>(256);

	private var _pendingData:Array<Dynamic> = [];//ANY

	private var _activeMeshes:SmartArray<AbstractMesh> = new SmartArray<AbstractMesh>(256);				
	private var _processedMaterials:SmartArray<Material> = new SmartArray<Material>(256);		
	private var _renderTargets:SmartArray<RenderTargetTexture> = new SmartArray<RenderTargetTexture>(256);			
	public var _activeParticleSystems:SmartArray<ParticleSystem> = new SmartArray<ParticleSystem>(256);		
	private var _activeSkeletons:SmartArray<Skeleton> = new SmartArray<Skeleton>(32);			
	private var _softwareSkinnedMeshes:SmartArray<Mesh> = new SmartArray<Mesh>(32);	
	@:allow(com.babylonhx.bones.Skeleton) 
	private var _activeBones:Int = 0;

	private var _renderingManager:RenderingManager;
	private var _physicsEngine:PhysicsEngine;

	public var _activeAnimatables:Array<Animatable> = [];

	private var _transformMatrix:Matrix = Matrix.Zero();
	private var _pickWithRayInverseMatrix:Matrix;

	private var _scaledPosition:Vector3 = Vector3.Zero();
	private var _scaledVelocity:Vector3 = Vector3.Zero();

	private var _edgesRenderers:SmartArray<EdgesRenderer> = new SmartArray<EdgesRenderer>(16);
	private var _boundingBoxRenderer:BoundingBoxRenderer;
	private var _outlineRenderer:OutlineRenderer;

	private var _viewMatrix:Matrix;
	private var _projectionMatrix:Matrix;
	private var _frustumPlanes:Array<Plane>;

	public var _selectionOctree:Octree<AbstractMesh>;

	private var _pointerOverMesh:AbstractMesh;
	private var _pointerOverSprite:Sprite;
	
	//private var _debugLayer:DebugLayer;
	
	private var _depthRenderer:DepthRenderer;
	
	private var _uniqueIdCounter:Int = 0;
	
	private var _pickedDownMesh:AbstractMesh;
	private var _pickedDownSprite:Sprite;
	

	public function new(engine:Engine) {
		this._engine = engine;
		
		engine.scenes.push(this);
		
		this._renderingManager = new RenderingManager(this);
		
		this.postProcessManager = new PostProcessManager(this);
		
		this.postProcessRenderPipelineManager = new PostProcessRenderPipelineManager();
		
		this._boundingBoxRenderer = new BoundingBoxRenderer(this);
		this._outlineRenderer = new OutlineRenderer(this);
		
		this.attachControl();
		
		//this._debugLayer = new DebugLayer(this);
		
		#if (purejs || js)
		this.mainSoundTrack = new SoundTrack(this, { mainTrack: true });
		#end
		
		//simplification queue
		this.simplificationQueue = new SimplificationQueue();
		
		//collision coordinator initialization. For now legacy per default.
		this.workerCollisions = false;
		
		// TODO: macro ...
		#if purejs
		untyped __js__("Object.defineProperty(this, 'pointerX', { get: this.get_pointerX })");
		untyped __js__("Object.defineProperty(this, 'pointerY', { get: this.get_pointerY })");
		#end
		
		this.defaultMaterial = new StandardMaterial("default material", this);
	}

	// Properties
	/**
	 * The mesh that is currently under the pointer.
	 * @return {BABYLON.AbstractMesh} mesh under the pointer/mouse cursor or null if none.
	 */
	public var meshUnderPointer(get, never):AbstractMesh;
	private function get_meshUnderPointer():AbstractMesh {
		return this._meshUnderPointer;
	}

	/**
	 * Current on-screen X position of the pointer
	 * @return {number} X position of the pointer
	 */
	public var pointerX(get, never):Float;
	private function get_pointerX():Float {
		return this._pointerX;
	}

	/**
	 * Current on-screen Y position of the pointer
	 * @return {number} Y position of the pointer
	 */
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

	inline public function getEngine():Engine {
		return this._engine;
	}

	inline public function getTotalVertices():Int {
		return this._totalVertices;
	}

	inline public function getActiveVertices():Int {
		return this._activeIndices;
	}

	inline public function getActiveParticles():Int {
		return this._activeParticles;
	}
	
	inline public function getActiveBones():Int {
		return this._activeBones;
	}
	
    // Audio
    #if (purejs || js)
    private function _updateAudioParameters() {
		if (!this._audioEnabled || (this.mainSoundTrack.soundCollection.length == 0 && this.soundTracks.length == 1)) {
			return;
		}
		
		var listeningCamera: Camera;
		var audioEngine = this.getEngine().audioEngine;
		
		if (this.activeCameras.length > 0) {
			listeningCamera = this.activeCameras[0];
		} 
		else {
			listeningCamera = this.activeCamera;
		}
		
		if (listeningCamera != null && audioEngine.canUseWebAudio) {
			audioEngine.audioContext.listener.setPosition(listeningCamera.position.x, listeningCamera.position.y, listeningCamera.position.z);
			var mat = Matrix.Invert(listeningCamera.getViewMatrix());
			var cameraDirection = Vector3.TransformNormal(new Vector3(0, 0, -1), mat);
			cameraDirection.normalize();
			audioEngine.audioContext.listener.setOrientation(cameraDirection.x, cameraDirection.y, cameraDirection.z, 0, 1, 0);
			var i:Int;
			for (i in 0...this.mainSoundTrack.soundCollection.length) {
				var sound = this.mainSoundTrack.soundCollection[i];
				if (sound.useCustomAttenuation) {
					sound.updateDistanceFromListener();
				}
			}
			for (i in 0...this.soundTracks.length) {
				for (j in 0...this.soundTracks[i].soundCollection.length) {
					var sound = this.soundTracks[i].soundCollection[j];
					if (sound.useCustomAttenuation) {
						sound.updateDistanceFromListener();
					}
				}
			}
		}
	}

    public function get_audioEnabled(): Bool {
     	return this._audioEnabled;
    }

    public function set_audioEnabled(value: Bool) {
     	this._audioEnabled = value;
     	if (this._audioEnabled  ) {
     		if (this._audioEnabled) {
     			this._enableAudio();
     		}
     		else {
     			this._disableAudio();
     		}
     	}
    }

    private function _disableAudio() {
     	var i:Int;
     	for (i in 0...this.mainSoundTrack.soundCollection.length) {
     		this.mainSoundTrack.soundCollection[i].pause();
     	}
     	for (i in 0...this.soundTracks.length) {
     		for (j in 0...this.soundTracks[i].soundCollection.length) {
     			this.soundTracks[i].soundCollection[j].pause();
     		}
     	}
    }

    private function _enableAudio() {
     	var i:Int;
     	for (i in 0...this.mainSoundTrack.soundCollection.length) {
     		if (this.mainSoundTrack.soundCollection[i].isPaused) {
     			this.mainSoundTrack.soundCollection[i].play();
     		}
     	}
     	for (i in 0...this.soundTracks.length) {
     		for (j in 0...this.soundTracks[i].soundCollection.length) {
     			if (this.soundTracks[i].soundCollection[j].isPaused) {
     				this.soundTracks[i].soundCollection[j].play();
     			}
     		}
     	}
    }
	
    public function get_headphone(): Bool {
     	return this._headphone;
    }
	
    public function set_headphone(value: Bool) {
     	this._headphone = value;
     	if (this._audioEnabled) {
     		if (this._headphone) {
     			this._switchAudioModeForHeadphones();
     		}
     		else {
     			this._switchAudioModeForNormalSpeakers();
     		}
     	}
    }
	
    private function _switchAudioModeForHeadphones() {
     	this.mainSoundTrack.switchPanningModelToHRTF();
		
     	for (i in 0...this.soundTracks.length) {
     		this.soundTracks[i].switchPanningModelToHRTF();
     	}
    }

    private function _switchAudioModeForNormalSpeakers() {
     	this.mainSoundTrack.switchPanningModelToEqualPower();
		
     	for (i in 0...this.soundTracks.length) {
     		this.soundTracks[i].switchPanningModelToEqualPower();
     	}
    }
    #end

	// Stats
	inline public function getLastFrameDuration():Float {
		return this._lastFrameDuration;
	}

	inline public function getEvaluateActiveMeshesDuration():Float {
		return this._evaluateActiveMeshesDuration;
	}

	inline public function getActiveMeshes():SmartArray<AbstractMesh> {
		return this._activeMeshes;
	}

	inline public function getRenderTargetsDuration():Float {
		return this._renderTargetsDuration;
	}

	inline public function getRenderDuration():Float {
		return this._renderDuration;
	}

	inline public function getParticlesDuration():Float {
		return this._particlesDuration;
	}

	inline public function getSpritesDuration():Float {
		return this._spritesDuration;
	}

	inline public function getAnimationRatio():Float {
		return this._animationRatio;
	}

	inline public function getRenderId():Int {
		return this._renderId;
	}
	
	inline public function incrementRenderId() {
		this._renderId++;
	}

	inline public function _updatePointerPosition(x:Int, y:Int) {		
		this._pointerX = x;
		this._pointerY = y;
		
		this._unTranslatedPointerX = this._pointerX;
		this._unTranslatedPointerY = this._pointerY;
		
		if (this.cameraToUseForPointers != null) {
			this._pointerX = this._pointerX - Std.int(this.cameraToUseForPointers.viewport.x) * this._engine.getRenderWidth();
			this._pointerY = this._pointerY - Std.int(this.cameraToUseForPointers.viewport.y) * this._engine.getRenderHeight();
		}
	}

	// Pointers handling

	/**
	* Attach events to the canvas (To handle actionManagers triggers and raise onPointerMove, onPointerDown and onPointerUp
	* @param attachUp defines if you want to attach events to pointerup
	* @param attachDown defines if you want to attach events to pointerdown
	* @param attachMove defines if you want to attach events to pointermove
	*/
	public function attachControl() {		
		var spritePredicate = function(sprite:Sprite):Bool {
			return sprite.isPickable && sprite.actionManager != null && sprite.actionManager.hasPickTriggers;
		};
		 
		this._onPointerMove = function(x:Int, y:Int) {
			if (this.cameraToUseForPointers == null && this.activeCamera == null) {
                return;
            }
			
			//var canvas = this._engine.getRenderingCanvas();
			
			this._updatePointerPosition(x, y);
			
			if (this.pointerMovePredicate == null) {
				this.pointerMovePredicate = function(mesh:AbstractMesh):Bool { 
					return mesh.isPickable && mesh.isVisible && mesh.isReady() && (this.constantlyUpdateMeshUnderPointer || mesh.actionManager != null && mesh.actionManager != null); 					
				};
			}
			
			// Meshes
			var pickResult:PickingInfo = this.pick(this._unTranslatedPointerX, this._unTranslatedPointerY, pointerMovePredicate,
				false,
				this.cameraToUseForPointers);
				
			if (pickResult.hit && pickResult.pickedMesh != null) {
				this.setPointerOverSprite(null);
				
				this.setPointerOverMesh(pickResult.pickedMesh);
				
				/*if (this._pointerOverMesh.actionManager != null && this._pointerOverMesh.actionManager.hasPointerTriggers) {
					canvas.style.cursor = "pointer";
				} 
				else {
					canvas.style.cursor = "";
				}*/
			} 
			else {
				this.setPointerOverMesh(null);
				
				// Sprites				
				pickResult = this.pickSprite(this._unTranslatedPointerX, this._unTranslatedPointerY, spritePredicate, false, this.cameraToUseForPointers);
				
				if (pickResult.hit && pickResult.pickedSprite != null) {
					//canvas.style.cursor = "pointer";
					this.setPointerOverSprite(pickResult.pickedSprite);
				} 
				else {
					// Restore pointer
					this.setPointerOverSprite(null);
					//canvas.style.cursor = "";
				}
			}
			
			if (this.onPointerMove != null) {
				this.onPointerMove(x, y, pickResult);
			}
			
			/*if (this.onPointerObservable.hasObservers()) {
				let type = evt.type == "mousewheel" ? PointerEventTypes.POINTERWHEEL : PointerEventTypes.POINTERMOVE;
				let pi = new PointerInfo(type, evt, pickResult);
				this.onPointerObservable.notifyObservers(pi, type);
			}*/
		};
		
		this._onPointerDown = function(x:Int, y:Int, button:Int) {			
			if (this.cameraToUseForPointers == null && this.activeCamera == null) {
                return;
            }
			
			this._updatePointerPosition(x, y);
			this._startingPointerPosition.x = this._pointerX;
			this._startingPointerPosition.y = this._pointerY;
			this._startingPointerTime = Tools.Now();
			
			if (this.pointerDownPredicate == null) {
				this.pointerDownPredicate = function(mesh:AbstractMesh):Bool {
					return mesh.isPickable && mesh.isVisible && mesh.isReady() && (mesh.actionManager == null || mesh.actionManager.hasPointerTriggers);
				};
			}
			
			// Meshes
			this._pickedDownMesh = null;			
			var pickResult:PickingInfo = this.pick(this._pointerX, this._pointerY, this.pointerDownPredicate, false, this.cameraToUseForPointers);
			if (pickResult.hit && pickResult.pickedMesh != null) {				
				if (pickResult.pickedMesh.actionManager != null) {
					this._pickedDownMesh = pickResult.pickedMesh;
					
					if (pickResult.pickedMesh.actionManager.hasPickTriggers) {
						switch (button) {
							case 0:
								pickResult.pickedMesh.actionManager.processTrigger(ActionManager.OnLeftPickTrigger, ActionEvent.CreateNew(pickResult.pickedMesh));
								
							case 1:
								pickResult.pickedMesh.actionManager.processTrigger(ActionManager.OnCenterPickTrigger, ActionEvent.CreateNew(pickResult.pickedMesh));
								
							case 2:
								pickResult.pickedMesh.actionManager.processTrigger(ActionManager.OnRightPickTrigger, ActionEvent.CreateNew(pickResult.pickedMesh));
								
							default:	// mobile
								pickResult.pickedMesh.actionManager.processTrigger(ActionManager.OnLeftPickTrigger, ActionEvent.CreateNew(pickResult.pickedMesh));							
						}
						
						pickResult.pickedMesh.actionManager.processTrigger(ActionManager.OnPickTrigger, ActionEvent.CreateNew(pickResult.pickedMesh));
					}
					
					if (pickResult.pickedMesh.actionManager.hasSpecificTrigger(ActionManager.OnLongPressTrigger)) {				
						Tools.delay(function () {
							var pickResult = this.pick(this._unTranslatedPointerX, this._unTranslatedPointerY,
								function(mesh:AbstractMesh):Bool { return mesh.isPickable && mesh.isVisible && mesh.isReady() && mesh.actionManager != null && mesh.actionManager.hasSpecificTrigger(ActionManager.OnLongPressTrigger); },
								false, this.cameraToUseForPointers);
								
							if (pickResult.hit && pickResult.pickedMesh != null) {
								if (pickResult.pickedMesh.actionManager != null) {
									if (this._startingPointerTime != 0 && ((Tools.Now() - this._startingPointerTime) > ActionManager.LongPressDelay) && (Math.abs(this._startingPointerPosition.x - this._pointerX) < ActionManager.DragMovementThreshold && Math.abs(this._startingPointerPosition.y - this._pointerY) < ActionManager.DragMovementThreshold)) {
										this._startingPointerTime = 0;
										pickResult.pickedMesh.actionManager.processTrigger(ActionManager.OnLongPressTrigger, ActionEvent.CreateNew(pickResult.pickedMesh));
									}
								}
							}
						}, ActionManager.LongPressDelay);
					}
				}
			}
			
			if (this.onPointerDown != null) {
				this.onPointerDown(x, y, button, pickResult);
			}
			
			/*if (this.onPointerObservable.hasObservers()) {
				let type = PointerEventTypes.POINTERDOWN;
				let pi = new PointerInfo(type, evt, pickResult);
				this.onPointerObservable.notifyObservers(pi, type);
			}*/
			
			// Sprites
			this._pickedDownSprite = null;
			if (this.spriteManagers.length > 0) {
				pickResult = this.pickSprite(this._unTranslatedPointerX, this._unTranslatedPointerY, spritePredicate, false, this.cameraToUseForPointers);
				
				if (pickResult.hit && pickResult.pickedSprite != null) {
					if (pickResult.pickedSprite.actionManager != null) {
						this._pickedDownSprite = pickResult.pickedSprite;
						switch (button) {
							case 0:
								pickResult.pickedSprite.actionManager.processTrigger(ActionManager.OnLeftPickTrigger, ActionEvent.CreateNewFromSprite(pickResult.pickedSprite, this));
								
							case 1:
								pickResult.pickedSprite.actionManager.processTrigger(ActionManager.OnCenterPickTrigger, ActionEvent.CreateNewFromSprite(pickResult.pickedSprite, this));
								
							case 2:
								pickResult.pickedSprite.actionManager.processTrigger(ActionManager.OnRightPickTrigger, ActionEvent.CreateNewFromSprite(pickResult.pickedSprite, this));
								
							default:	// mobile
								pickResult.pickedSprite.actionManager.processTrigger(ActionManager.OnLeftPickTrigger, ActionEvent.CreateNewFromSprite(pickResult.pickedSprite, this));
							
						}
						pickResult.pickedSprite.actionManager.processTrigger(ActionManager.OnPickTrigger, ActionEvent.CreateNewFromSprite(pickResult.pickedSprite, this));
					}
				}
			}
		};
		
		this._onPointerUp = function(x:Int, y:Int, button:Int) {
			if (this.cameraToUseForPointers == null && this.activeCamera == null) {
                return;
            }
			
			this._updatePointerPosition(x, y);
			
			if (this.pointerUpPredicate == null) {
				this.pointerUpPredicate = function(mesh:AbstractMesh):Bool {
					return mesh.isPickable && mesh.isVisible && mesh.isReady() && (mesh.actionManager == null || (mesh.actionManager.hasPickTriggers || mesh.actionManager.hasSpecificTrigger(ActionManager.OnLongPressTrigger)));
				};
			}
			
			// Meshes
			var pickResult:PickingInfo = this.pick(this._unTranslatedPointerX, this._unTranslatedPointerY, this.pointerUpPredicate, false, this.cameraToUseForPointers);
			
			if (pickResult.hit && pickResult.pickedMesh != null) {
				if (this._pickedDownMesh != null && pickResult.pickedMesh == this._pickedDownMesh) {
					if (this.onPointerPick != null) {
						this.onPointerPick(pickResult);
					}
					/*if (this.onPointerObservable.hasObservers()) {
						let type = PointerEventTypes.POINTERPICK;
						let pi = new PointerInfo(type, evt, pickResult);
						this.onPointerObservable.notifyObservers(pi, type);
					}*/
				}
				if (pickResult.pickedMesh.actionManager != null) {
					pickResult.pickedMesh.actionManager.processTrigger(ActionManager.OnPickUpTrigger, ActionEvent.CreateNew(pickResult.pickedMesh, button));
					
					if (Math.abs(this._startingPointerPosition.x - this._pointerX) < ActionManager.DragMovementThreshold && Math.abs(this._startingPointerPosition.y - this._pointerY) < ActionManager.DragMovementThreshold) {
						pickResult.pickedMesh.actionManager.processTrigger(ActionManager.OnPickTrigger, ActionEvent.CreateNew(pickResult.pickedMesh, button));
					}
				}
			}
			if (this._pickedDownMesh != null && this._pickedDownMesh != pickResult.pickedMesh) {
				this._pickedDownMesh.actionManager.processTrigger(ActionManager.OnPickOutTrigger, ActionEvent.CreateNew(this._pickedDownMesh));
			}
			
			if (this.onPointerUp != null) {
				this.onPointerUp(x, y, button, pickResult);
			}
			
			/*if (this.onPointerObservable.hasObservers()) {
				let type = PointerEventTypes.POINTERUP;
				let pi = new PointerInfo(type, evt, pickResult);
				this.onPointerObservable.notifyObservers(pi, type);
			}*/
			
			this._startingPointerTime = 0;
			
			// Sprites
			if (this.spriteManagers.length > 0) {
				pickResult = this.pickSprite(this._unTranslatedPointerX, this._unTranslatedPointerY, spritePredicate, false, this.cameraToUseForPointers);
				
				if (pickResult.hit && pickResult.pickedSprite != null) {
					if (pickResult.pickedSprite.actionManager != null) {
						pickResult.pickedSprite.actionManager.processTrigger(ActionManager.OnPickUpTrigger, ActionEvent.CreateNewFromSprite(pickResult.pickedSprite, this));
						
						if (Math.abs(this._startingPointerPosition.x - this._pointerX) < ActionManager.DragMovementThreshold && Math.abs(this._startingPointerPosition.y - this._pointerY) < ActionManager.DragMovementThreshold) {
							pickResult.pickedSprite.actionManager.processTrigger(ActionManager.OnPickTrigger, ActionEvent.CreateNewFromSprite(pickResult.pickedSprite, this));
						}
					}
				}
				if (this._pickedDownSprite != null && this._pickedDownSprite != pickResult.pickedSprite) {
					this._pickedDownSprite.actionManager.processTrigger(ActionManager.OnPickOutTrigger, ActionEvent.CreateNewFromSprite(this._pickedDownSprite, this));
				}
			}
		};
		
		this._onKeyDown = function(keycode:Int) {
			if (this.actionManager != null) {
				this.actionManager.processTrigger(ActionManager.OnKeyDownTrigger, ActionEvent.CreateNewFromScene(this, keycode));
			}
		};
		
		this._onKeyUp = function(keycode:Int) {
			if (this.actionManager != null) {
				this.actionManager.processTrigger(ActionManager.OnKeyUpTrigger, ActionEvent.CreateNewFromScene(this, keycode));
			}
		};
		
		
		Engine.touchDown.push(this._onPointerDown);
		Engine.touchUp.push(this._onPointerUp);
		Engine.touchMove.push(this._onPointerMove);
		
		Engine.mouseDown.push(this._onPointerDown);
		Engine.mouseUp.push(this._onPointerUp);
		Engine.mouseMove.push(this._onPointerMove);
		
		Engine.keyDown.push(this._onKeyDown);
		Engine.keyUp.push(this._onKeyUp);
		
	}

	public function detachControl() {
		
		Engine.touchDown.remove(this._onPointerDown);
		Engine.touchUp.remove(this._onPointerUp);
		Engine.touchMove.remove(this._onPointerMove);
		
		Engine.mouseDown.remove(this._onPointerDown);
		Engine.mouseUp.remove(this._onPointerUp);
		Engine.mouseMove.remove(this._onPointerMove);
		
		Engine.keyDown.remove(this._onKeyDown);
		Engine.keyUp.remove(this._onKeyUp);
		
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

	inline public function resetCachedMaterial() {
        this._cachedMaterial = null;
    }
	
	public function registerBeforeRender(func:Scene->Null<EventState>->Void) {
		this.onBeforeRenderObservable.add(func);
	}

	public function unregisterBeforeRender(func:Scene->Null<EventState>->Void) {
		this.onBeforeRenderObservable.removeCallback(func);
	}
	
	public function registerAfterRender(func:Scene->Null<EventState>->Void) {
		this.onAfterRenderObservable.add(func);
    }
	
    public function unregisterAfterRender(func:Scene->Null<EventState>->Void) {
        this.onAfterRenderObservable.removeCallback(func);
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

	public function executeWhenReady(func:Scene->Null<EventState>->Void) {
		this.onReadyObservable.add(func);
		
		if (this._executeWhenReadyTimeoutId != -1) {
			return;
		}
		
		this._executeWhenReadyTimeoutId = 1;
		Tools.delay(this._checkIsReady, 150);
	}

	public function _checkIsReady() {
		if (this.isReady()) {
			this.onReadyObservable.notifyObservers(this);
			
			this.onReadyObservable.clear();
			this._executeWhenReadyTimeoutId = -1;
			
			return;
		}
		
		this._executeWhenReadyTimeoutId = 1; 
		Tools.delay(this._checkIsReady, 150);
	}

	// Animations
	/**
	 * Will start the animation sequence of a given target
	 * @param target - the target 
	 * @param {number} from - from which frame should animation start
	 * @param {number} to - till which frame should animation run.
	 * @param {boolean} [loop] - should the animation loop
	 * @param {number} [speedRatio] - the speed in which to run the animation
	 * @param {Function} [onAnimationEnd] function to be executed when the animation ended.
	 * @param {BABYLON.Animatable} [animatable] an animatable object. If not provided a new one will be created from the given params.
	 * @return {BABYLON.Animatable} the animatable object created for this animation
	 * @see BABYLON.Animatable
	 * @see http://doc.babylonjs.com/page.php?p=22081
	 */
	public function beginAnimation(target:Dynamic, from:Int, to:Int, loop:Bool = false, speedRatio:Float = 1.0, ?onAnimationEnd:Void->Void, ?animatable:Animatable):Animatable {
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
		
		animatable.reset();
		
		return animatable;
	}

	public function beginDirectAnimation(target:Dynamic, animations:Array<Animation>, from:Int, to:Int, loop:Bool = false, ?speedRatio:Float = 1.0, ?onAnimationEnd:Void->Void):Animatable {
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

	/**
	 * Will stop the animation of the given target
	 * @param target - the target 
	 * @see beginAnimation 
	 */
	public function stopAnimation(target:Dynamic) {
		var animatable = this.getAnimatableByTarget(target);
		
		if (animatable != null) {
			animatable.stop();
		}
	}
	
	private function _animate() {
		if (!this.animationsEnabled || this._activeAnimatables.length == 0) {
			return;
		}
		
		if (this._animationStartDate == -1) {
			if (this._pendingData.length > 0) {
                return;
            }
			
			this._animationStartDate = Tools.Now();
		}
		
		// Getting time
		var now = Tools.Now();
		var delay = now - this._animationStartDate;
		
		for (index in 0...this._activeAnimatables.length) {
			// VK TODO: inspect this, last item in array is null sometimes
			if(this._activeAnimatables[index] != null) {
				this._activeAnimatables[index]._animate(delay);
			}
		}
	}

	// Matrix
	inline public function getViewMatrix():Matrix {
		return this._viewMatrix;
	}

	inline public function getProjectionMatrix():Matrix {
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

	// Methods
	
	public function addMesh(newMesh:AbstractMesh) {
		newMesh.uniqueId = this._uniqueIdCounter++;
		var position = this.meshes.push(newMesh);
		
		//notify the collision coordinator
		this.collisionCoordinator.onMeshAdded(newMesh);
		
		this.onNewMeshAddedObservable.notifyObservers(newMesh);
	}

	public function removeMesh(toRemove:AbstractMesh):Int {
		var index = this.meshes.indexOf(toRemove);
		if (index != -1) {
			// Remove from the scene if mesh found 
			this.meshes.splice(index, 1);
		}
		
		//notify the collision coordinator
		this.collisionCoordinator.onMeshRemoved(toRemove);
		
		this.onMeshRemovedObservable.notifyObservers(toRemove);
		
		return index;
	}
	
	public function removeSkeleton(toRemove:Skeleton):Int {
		var index = this.skeletons.indexOf(toRemove);
		if (index != -1) {
			// Remove from the scene if mesh found 
			this.skeletons.splice(index, 1);
		}
		
		return index;
	}

	public function removeLight(toRemove:Light):Int {
		var index = this.lights.indexOf(toRemove);
		if (index != -1) {
			// Remove from the scene if mesh found 
			this.lights.splice(index, 1);
		}
		
		this.onLightRemovedObservable.notifyObservers(toRemove);
		
		return index;
	}

	public function removeCamera(toRemove:Camera):Int {
		var index = this.cameras.indexOf(toRemove);
		if (index != -1) {
			// Remove from the scene if mesh found 
			this.cameras.splice(index, 1);
		}
		
		// Remove from activeCameras
		index = this.activeCameras.indexOf(toRemove);
		if (index != -1) {
			// Remove from the scene if found
			this.activeCameras.splice(index, 1);
		}
		
		// Reset the activeCamera
		if (this.activeCamera == toRemove) {
			if (this.cameras.length > 0) {
                this.activeCamera = this.cameras[0];
            } 
			else {
                this.activeCamera = null;
            }
		}
		
		this.onCameraRemovedObservable.notifyObservers(toRemove);
		
		return index;
	}

	public function addLight(newLight:Light) {
		newLight.uniqueId = this._uniqueIdCounter++;
		var position = this.lights.push(newLight);
		this.onNewLightAddedObservable.notifyObservers(newLight);
	}

	public function addCamera(newCamera:Camera) {
		newCamera.uniqueId = this._uniqueIdCounter++;
		var position = this.cameras.push(newCamera);
		this.onNewCameraAddedObservable.notifyObservers(newCamera);
	}
	
	/**
	 * Swith the active camera of the scene
	 * @param {Camera} newCamera - the new camera
	 * @param {boolean} control - attachControl for the camera (default true)
	 */
	public function swithActiveCamera(newCamera:Camera, control:Bool = true) {				
		this.activeCamera.detachControl();			
		this.activeCamera = newCamera;			
		if (control) {
			newCamera.attachControl();
		}	
	}
	
	/**
	 * sets the active camera of the scene using its ID
	 * @param {string} id - the camera's ID
	 * @return {BABYLON.Camera|null} the new active camera or null if none found.
	 * @see activeCamera
	 */
	public function setActiveCameraByID(id:String):Camera {
		var camera = this.getCameraByID(id);
		
		if (camera != null) {
			this.activeCamera = camera;
			return camera;
		}
		
		return null;
	}

	/**
	 * sets the active camera of the scene using its name
	 * @param {string} name - the camera's name
	 * @return {BABYLON.Camera|null} the new active camera or null if none found.
	 * @see activeCamera
	 */
	public function setActiveCameraByName(name:String):Camera {
		var camera = this.getCameraByName(name);
		
		if (camera != null) {
			this.activeCamera = camera;
			return camera;
		}
		
		return null;
	}

	/**
	 * get a material using its id
	 * @param {string} the material's ID
	 * @return {BABYLON.Material|null} the material or null if none found.
	 */
	public function getMaterialByID(id:String):Material {
		for (index in 0...this.materials.length) {
			if (this.materials[index].id == id) {
				return this.materials[index];
			}
		}
		
		return null;
	}

	/**
	 * get a material using its name
	 * @param {string} the material's name
	 * @return {BABYLON.Material|null} the material or null if none found.
	 */
	public function getMaterialByName(name:String):Material {
		for (index in 0...this.materials.length) {
			if (this.materials[index].name == name) {
				return this.materials[index];
			}
		}
		
		return null;
	}
	
	public function getLensFlareSystemByName(name:String):LensFlareSystem {
		for (index in 0...this.lensFlareSystems.length) {
			if (this.lensFlareSystems[index].name == name) {
				return this.lensFlareSystems[index];
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
	
	public function getCameraByUniqueID(uniqueId:Int):Camera {
        for (index in 0...this.cameras.length) {
            if (this.cameras[index].uniqueId == uniqueId) {
                return this.cameras[index];
            }
        }
		
        return null;
    }

	/**
	 * get a camera using its name
	 * @param {string} the camera's name
	 * @return {BABYLON.Camera|null} the camera or null if none found.
	 */
	public function getCameraByName(name:String):Camera {
		for (index in 0...this.cameras.length) {
			if (this.cameras[index].name == name) {
				return this.cameras[index];
			}
		}
		
		return null;
	}
	
	/**
	 * get a bone using its id
	 * @param {string} the bone's id
	 * @return {BABYLON.Bone|null} the bone or null if not found
	 */
	public function getBoneByID(id:String):Bone {
		for (skeleton in this.skeletons) {
			for (bone in skeleton.bones) {
				if (bone.id == id) {
					return bone;
				}
			}
		}
		
		return null;
	}

	/**
	* get a bone using its id
	* @param {string} the bone's name
	* @return {BABYLON.Bone|null} the bone or null if not found
	*/
	public function getBoneByName(name:String):Bone {
		for (skeleton in this.skeletons) {
			for (bone in skeleton.bones) {
				if (bone.name == name) {
					return bone;
				}
			}
		}
		
		return null;
	}

	/**
	 * get a light node using its name
	 * @param {string} the light's name
	 * @return {BABYLON.Light|null} the light or null if none found.
	 */
	public function getLightByName(name:String):Light {
		for (index in 0...this.lights.length) {
			if (this.lights[index].name == name) {
				return this.lights[index];
			}
		}
		
		return null;
	}

	/**
	 * get a light node using its ID
	 * @param {string} the light's id
	 * @return {BABYLON.Light|null} the light or null if none found.
	 */
	public function getLightByID(id:String):Light {
		for (index in 0...this.lights.length) {
			if (this.lights[index].id == id) {
				return this.lights[index];
			}
		}
		
		return null;
	}
	
	/**
	 * get a light node using its scene-generated unique ID
	 * @param {number} the light's unique id
	 * @return {BABYLON.Light|null} the light or null if none found.
	 */
	public function getLightByUniqueID(uniqueId:Int):Light {
        for (index in 0...this.lights.length) {
            if (this.lights[index].uniqueId == uniqueId) {
                return this.lights[index];
            }
        }
		
        return null;
    }
	
	/**
	 * get a particle system by id
	 * @param id {number} the particle system id
	 * @return {BABYLON.ParticleSystem|null} the corresponding system or null if none found.
	 */
	public function getParticleSystemByID(id:String):ParticleSystem {
		for (index in 0...this.particleSystems.length) {
			if (this.particleSystems[index].id == id) {
				return this.particleSystems[index];
			}
		}
		
		return null;
	}

	/**
	 * get a geometry using its ID
	 * @param {string} the geometry's id
	 * @return {BABYLON.Geometry|null} the geometry or null if none found.
	 */
	public function getGeometryByID(id:String):Geometry {
		for (index in 0...this._geometries.length) {
			if (this._geometries[index].id == id) {
				return this._geometries[index];
			}
		}
		
		return null;
	}

	/**
	 * add a new geometry to this scene.
	 * @param {BABYLON.Geometry} geometry - the geometry to be added to the scene.
	 * @param {boolean} [force] - force addition, even if a geometry with this ID already exists
	 * @return {boolean} was the geometry added or not
	 */
	public function pushGeometry(geometry:Geometry, force:Bool = false):Bool {
		if (!force && this.getGeometryByID(geometry.id) != null) {
			return false;
		}
		
		this._geometries.push(geometry);
		
		//notify the collision coordinator
		this.collisionCoordinator.onGeometryAdded(geometry);
		
		this.onNewGeometryAddedObservable.notifyObservers(geometry);
		
		return true;
	}
	
	/**
	 * Removes an existing geometry
	 * @param {BABYLON.Geometry} geometry - the geometry to be removed from the scene.
	 * @return {boolean} was the geometry removed or not
	 */
	public function removeGeometry(geometry:Geometry):Bool {
		var index = this._geometries.indexOf(geometry);
		
		if (index > -1) {
			this._geometries.splice(index, 1);
			
			//notify the collision coordinator
			this.collisionCoordinator.onGeometryDeleted(geometry);
			
			this.onGeometryRemovedObservable.notifyObservers(geometry);
			
			return true;
		}
		
		return false;
	}

	public function getGeometries():Array<Geometry> {
		return this._geometries;
	}

	/**
	 * Get the first added mesh found of a given ID
	 * @param {string} id - the id to search for
	 * @return {BABYLON.AbstractMesh|null} the mesh found or null if not found at all.
	 */
	public function getMeshByID(id:String):AbstractMesh {
		for (index in 0...this.meshes.length) {
			if (this.meshes[index].id == id) {
				return this.meshes[index];
			}
		}
		
		return null;
	}
	
	public function getMeshesByID(id:String):Array<AbstractMesh> {
        return this.meshes.filter(function (m:AbstractMesh):Bool {
            return m.id == id;
        });
    }
	
	/**
	 * Get a mesh with its auto-generated unique id
	 * @param {number} uniqueId - the unique id to search for
	 * @return {BABYLON.AbstractMesh|null} the mesh found or null if not found at all.
	 */
	public function getMeshByUniqueID(uniqueId:Int):AbstractMesh {
        for (index in 0...this.meshes.length) {
            if (this.meshes[index].uniqueId == uniqueId) {
                return this.meshes[index];
            }
        }
		
        return null;
    }

	/**
	 * Get a the last added mesh found of a given ID
	 * @param {string} id - the id to search for
	 * @return {BABYLON.AbstractMesh|null} the mesh found or null if not found at all.
	 */
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

	/**
	 * Get a the last added node (Mesh, Camera, Light) found of a given ID
	 * @param {string} id - the id to search for
	 * @return {BABYLON.Node|null} the node found or null if not found at all.
	 */
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
	
	public function getNodeByID(id:String):Node {
		var mesh = this.getMeshByID(id);
		
		if (mesh != null) {
			return mesh;
		}
		
		var light = this.getLightByID(id);
		
		if (light != null) {
			return light;
		}
		
		var camera = this.getCameraByID(id);
		
		if (camera != null) {
			return camera;
		}
		
		var bone = this.getBoneByID(id);
		
		return bone;
	}
	
	public function getNodeByName(name:String):Node {
		var mesh = this.getMeshByName(name);
		
		if (mesh != null) {
			return mesh;
		}
		
		var light = this.getLightByName(name);
		
		if (light != null) {
			return light;
		}
		
		var camera = this.getCameraByName(name);
		
		if (camera != null) {
			return camera;
		}
		
		var bone = this.getBoneByName(name);
		
		return bone;
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

	inline public function isActiveMesh(mesh:Mesh):Bool {
		return (this._activeMeshes.indexOf(mesh) != -1);
	}

	static var _eSMMaterial:Material;
	inline private function _evaluateSubMesh(subMesh:SubMesh, mesh:AbstractMesh) {
		if (mesh.alwaysSelectAsActiveMesh || mesh.subMeshes.length == 1 || subMesh.isInFrustum(this._frustumPlanes)) {
			_eSMMaterial = subMesh.getMaterial();
			
			if (mesh.showSubMeshesBoundingBox) {
				this._boundingBoxRenderer.renderList.push(subMesh.getBoundingInfo().boundingBox);
			}
			
			if (_eSMMaterial != null) {
				// Render targets
				if (_eSMMaterial.getRenderTargetTextures != null) {
					if (this._processedMaterials.indexOf(_eSMMaterial) == -1) {
						this._processedMaterials.push(_eSMMaterial);
						
						this._renderTargets.concatSmartArrayWithNoDuplicate(_eSMMaterial.getRenderTargetTextures());
					}
				}
				
				// Dispatch
				this._activeIndices += subMesh.verticesCount;
				this._renderingManager.dispatch(subMesh);
			}
		}
	}
	
	public function _isInIntermediateRendering():Bool {
        return this._intermediateRendering;
    }

	private function _evaluateActiveMeshes() {
		this.activeCamera._activeMeshes.reset();
		this._activeMeshes.reset();
		this._renderingManager.reset();
		this._processedMaterials.reset();
		this._activeParticleSystems.reset();
		this._activeSkeletons.reset();
		this._softwareSkinnedMeshes.reset();
		this._boundingBoxRenderer.reset();
		this._edgesRenderers.reset();
		
		if (this._frustumPlanes == null) {
			this._frustumPlanes = Frustum.GetPlanes(this._transformMatrix);
		} 
		else {
			Frustum.GetPlanesToRef(this._transformMatrix, this._frustumPlanes);
		}
		
		// Meshes
		var meshes:Array<AbstractMesh> = [];
		var len:Int = 0;
		
		if (this._selectionOctree != null) { // Octree
			var selection = this._selectionOctree.select(this._frustumPlanes);
			meshes = selection.data;
			len = selection.length;
		} 
		else { // Full scene traversal
			len = this.meshes.length;
			meshes = this.meshes;
		}
		
		for (meshIndex in 0...len) {
			var mesh = meshes[meshIndex];
			
			if (mesh.isBlocked) {
				continue;
			}
			
			this._totalVertices += mesh.getTotalVertices();
			
			if (!mesh.isReady() || !mesh.isEnabled()) {
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
			
			if (mesh.alwaysSelectAsActiveMesh || mesh.isVisible && mesh.visibility > 0 && ((mesh.layerMask & this.activeCamera.layerMask) != 0) && mesh.isInFrustum(this._frustumPlanes)) {
				this._activeMeshes.push(mesh);
				this.activeCamera._activeMeshes.push(mesh);
				mesh._activate(this._renderId);
				
				this._activeMesh(meshLOD);
			}
		}
		
		// Particle systems
		var beforeParticlesDate = Tools.Now();
		if (this.particlesEnabled) {
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
		}
	}

	private function _activeMesh(mesh:AbstractMesh) {
		if (mesh.skeleton != null && this.skeletonsEnabled) {
			this._activeSkeletons.pushNoDuplicate(mesh.skeleton);
			
			if (!mesh.computeBonesUsingShaders) {
                this._softwareSkinnedMeshes.pushNoDuplicate(cast mesh);
            }
		}
		
		if (mesh.showBoundingBox || this.forceShowBoundingBoxes) {
			this._boundingBoxRenderer.renderList.push(mesh.getBoundingInfo().boundingBox);
		} 
		
		if (mesh._edgesRenderer != null) {
            this._edgesRenderers.push(mesh._edgesRenderer);
        }
        
		if (mesh != null && mesh.subMeshes != null) {
			// Submeshes Octrees
			var len:Int = -1;
			var subMeshes:Array<SubMesh> = null;
			
			if (mesh._submeshesOctree != null && mesh.useOctreeForRenderingSelection) {
				var intersections = mesh._submeshesOctree.select(this._frustumPlanes);
				
				len = intersections.length;
				subMeshes = cast intersections.data;
			} 
			else {
				subMeshes = mesh.subMeshes;
				len = subMeshes.length;
			}
			
			for (subIndex in 0...len) {
				var subMesh = subMeshes[subIndex];
				this._evaluateSubMesh(subMesh, mesh);
			}
		}
	}

	inline public function updateTransformMatrix(force:Bool = false) {
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
		this.resetCachedMaterial();
		this._renderId++;
		this.updateTransformMatrix();
		
		this.onBeforeCameraRenderObservable.notifyObservers(this.activeCamera);
		
		// Meshes
		var beforeEvaluateActiveMeshesDate = Tools.Now();
		//Tools.StartPerformanceCounter("Active meshes evaluation");
		this._evaluateActiveMeshes();
		this._evaluateActiveMeshesDuration += Tools.Now() - beforeEvaluateActiveMeshesDate;
		//Tools.EndPerformanceCounter("Active meshes evaluation");
		
		// Skeletons
		for (skeletonIndex in 0...this._activeSkeletons.length) {
			var skeleton:Skeleton = cast this._activeSkeletons.data[skeletonIndex];			
			
			skeleton.prepare();			
		}
		
		// Software skinning
        for (softwareSkinnedMeshIndex in 0...this._softwareSkinnedMeshes.length) {
            var mesh:Mesh = cast this._softwareSkinnedMeshes.data[softwareSkinnedMeshIndex];
			
            mesh.applySkeleton(mesh.skeleton);
        }
		
		// Render targets
		var beforeRenderTargetDate = Tools.Now();
		if (this.renderTargetsEnabled && this._renderTargets.length > 0) {
			this._intermediateRendering = true;
			//Tools.StartPerformanceCounter("Render targets", this._renderTargets.length > 0);
			for (renderIndex in 0...this._renderTargets.length) {
				var renderTarget:RenderTargetTexture = this._renderTargets.data[renderIndex];
				if (renderTarget._shouldRender()) {
					this._renderId++;
					var hasSpecialRenderTargetCamera = renderTarget.activeCamera != null && renderTarget.activeCamera != this.activeCamera;
					renderTarget.render(hasSpecialRenderTargetCamera);
				}
			}
			
			//Tools.EndPerformanceCounter("Render targets", this._renderTargets.length > 0);
			
			this._intermediateRendering = false;
			this._renderId++;
			
            engine.restoreDefaultFramebuffer();  // Restore back buffer
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
		
		// Edges
        for (edgesRendererIndex in 0...this._edgesRenderers.length) {
            this._edgesRenderers.data[edgesRendererIndex].render();
        }
		
		// Lens flares
		if (this.lensFlaresEnabled) {
			//Tools.StartPerformanceCounter("Lens flares", this.lensFlareSystems.length > 0);
			for (lensFlareSystemIndex in 0...this.lensFlareSystems.length) {
				var lensFlareSystem = this.lensFlareSystems[lensFlareSystemIndex];
				if ((camera.layerMask & lensFlareSystem.layerMask) != 0) {
					lensFlareSystem.render();
				}
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
		
		this.onAfterCameraRenderObservable.notifyObservers(this.activeCamera);
		
		//Tools.EndPerformanceCounter("Rendering camera " + this.activeCamera.name);
	}

	private function _processSubCameras(camera:Camera) {
		if (camera.subCameras.length == 0 && camera._rigCameras.length == 0) {
			this._renderForCamera(camera);
			return;
		}
		
		// rig cameras
        for (index in 0...camera._rigCameras.length) {
            this._renderForCamera(camera._rigCameras[index]);
        }
		
		this.activeCamera = camera;
		this.setTransformMatrix(this.activeCamera.getViewMatrix(), this.activeCamera.getProjectionMatrix(false));
		
		// Update camera
		this.activeCamera._updateFromScene();
	}

	private function _checkIntersections() {
		for (index in 0...this._meshesForIntersections.length) {
			var sourceMesh:AbstractMesh = cast this._meshesForIntersections.data[index];
			
			for (actionIndex in 0...sourceMesh.actionManager.actions.length) {
				var action:Action = sourceMesh.actionManager.actions[actionIndex];
				
				if (action.trigger == ActionManager.OnIntersectionEnterTrigger || action.trigger == ActionManager.OnIntersectionExitTrigger) {
					var parameters = action.getTriggerParameter();
					var otherMesh:AbstractMesh = Std.is(parameters, AbstractMesh) ? cast parameters : parameters.mesh;
					
					var areIntersecting = otherMesh.intersectsMesh(sourceMesh, parameters.usePreciseIntersection);
					var currentIntersectionInProgress = sourceMesh._intersectionsInProgress.indexOf(otherMesh);
					
					if (areIntersecting && currentIntersectionInProgress == -1) {
						if (action.trigger == ActionManager.OnIntersectionEnterTrigger) {
							action._executeCurrent(ActionEvent.CreateNew(sourceMesh, otherMesh));
							sourceMesh._intersectionsInProgress.push(otherMesh);
						} 
						else if (action.trigger == ActionManager.OnIntersectionExitTrigger) {
							sourceMesh._intersectionsInProgress.push(otherMesh);
						}
					} 
					else if (!areIntersecting && currentIntersectionInProgress > -1 && action.trigger == ActionManager.OnIntersectionExitTrigger) {
						//They intersected, and now they don't.
						
						//is this trigger an exit trigger? execute an event.
						if (action.trigger == ActionManager.OnIntersectionExitTrigger) {
							action._executeCurrent(ActionEvent.CreateNew(sourceMesh, otherMesh));
						}
						
						//if this is an exit trigger, or no exit trigger exists, remove the id from the intersection in progress array.
						if (!sourceMesh.actionManager.hasSpecificTrigger(ActionManager.OnIntersectionExitTrigger) || action.trigger == ActionManager.OnIntersectionExitTrigger) {
							sourceMesh._intersectionsInProgress.splice(currentIntersectionInProgress, 1);
						}
					}
				}
			}
		}
	}

	public function render() {
		//var startDate = Tools.Now();
		this._particlesDuration = 0;
		this._spritesDuration = 0;
		this._activeParticles = 0;
		this._renderDuration = 0;
		this._renderTargetsDuration = 0;
		this._evaluateActiveMeshesDuration = 0;
		this._totalVertices = 0;
		this._activeIndices = 0;
		this._activeBones = 0;
		this.getEngine().resetDrawCalls();
		this._meshesForIntersections.reset();
		this.resetCachedMaterial();
			
		//Tools.StartPerformanceCounter("Scene rendering");
		
		// Actions
		if (this.actionManager != null) {
			this.actionManager.processTrigger(ActionManager.OnEveryFrameTrigger, null);
		}
		
		//Simplification Queue
		if (!this.simplificationQueue.running) {
			this.simplificationQueue.executeNext();
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
		
		// Before render
		/*if (this.beforeRender != null) {
            this.beforeRender(this);
        }*/
		
		this.onBeforeRenderObservable.notifyObservers(this);
		
		// Customs render targets
		//var beforeRenderTargetDate = Tools.Now();
		var engine = this.getEngine();
		var currentActiveCamera = this.activeCamera;
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
					
					renderTarget.render(currentActiveCamera != this.activeCamera);
				}
			}
			//Tools.EndPerformanceCounter("Custom render targets", this.customRenderTargets.length > 0);
			
			this._renderId++;
		}
		
		if (this.customRenderTargets.length > 0) { // Restore back buffer
			engine.restoreDefaultFramebuffer();
		}
		//this._renderTargetsDuration += Tools.Now() - beforeRenderTargetDate;
		this.activeCamera = currentActiveCamera;
		
		// Procedural textures
		if (this.proceduralTexturesEnabled && this._proceduralTextures.length > 0) {
			//Tools.StartPerformanceCounter("Procedural textures", this._proceduralTextures.length > 0);
			for (proceduralTexture in this._proceduralTextures) {
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
		
		// Depth renderer
		if (this._depthRenderer != null) {
			this._renderTargets.push(this._depthRenderer.getDepthMap());
		}
		
		// RenderPipeline
		this.postProcessRenderPipelineManager.update();
		
		// Multi-cameras?
		if (this.activeCameras.length > 0) {
			var currentRenderId = this._renderId;
			for (cameraIndex in 0...this.activeCameras.length) {
				this._renderId = currentRenderId;
				if (cameraIndex > 0) {
                    this._engine.clear(0, false, true);
                }
				
				this._processSubCameras(this.activeCameras[cameraIndex]);
			}
		} 
		else {
			if (this.activeCamera == null) {
				throw("No camera defined");
			}
			
			this._processSubCameras(this.activeCamera);
		}
		
		// Intersection checks
		this._checkIntersections();
		
		// After render
		/*if (this.afterRender != null) {
			this.afterRender(this);
		}*/
		
		this.onAfterRenderObservable.notifyObservers(this);
		
		// Cleaning
		for (index in 0...this._toBeDisposed.length) {
			this._toBeDisposed.data[index].dispose();			
			this._toBeDisposed.data[index] = null;
			//this._toBeDisposed.data.splice(index, 1);
		}
		
		this._toBeDisposed.reset();
		
		if (this.dumpNextRenderTargets) {
			this.dumpNextRenderTargets = false;
		}
		
		//Tools.EndPerformanceCounter("Scene rendering");
		//this._lastFrameDuration = Tools.Now() - startDate;
	}
	
	public function enableDepthRenderer():DepthRenderer {
		if (this._depthRenderer != null) {
			return this._depthRenderer;
		}
		
		this._depthRenderer = new DepthRenderer(this);
		
		return this._depthRenderer;
	}

	public function disableDepthRenderer() {
		if (this._depthRenderer == null) {
			return;
		}
		
		this._depthRenderer.dispose();
		this._depthRenderer = null;
	}
	
	public function freezeMaterials() {
		for (i in 0...this.materials.length) {
			this.materials[i].freeze();
		}
	}

	public function unfreezeMaterials() {
		for (i in 0...this.materials.length) {
			this.materials[i].unfreeze();
		}
	}

	public function dispose() {
		this.beforeRender = null;
		this.afterRender = null;
		
		this.skeletons = [];
		
		this._boundingBoxRenderer.dispose();
		
		if (this._depthRenderer != null) {
			this._depthRenderer.dispose();
		}
		
		// Events
		/*if (this.onDispose != null) {
			this.onDispose(this);
		}*/
		this.onDisposeObservable.notifyObservers(this);
		
		this.detachControl();
		
		this.onDisposeObservable.clear();
		this.onBeforeRenderObservable.clear();
        this.onAfterRenderObservable.clear();
		
		// Detach cameras
		/*var canvas = this._engine.getRenderingCanvas();
		var index;*/
		for (index in 0...this.cameras.length) {
			this.cameras[index].detachControl(this);
		}
		
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
	public function getWorldExtends():Dynamic {
		var min = new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
		var max = new Vector3(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);
		for (index in 0...this.meshes.length) {
			var mesh = this.meshes[index];
			
			mesh.computeWorldMatrix(true);
			var minBox = mesh.getBoundingInfo().boundingBox.minimumWorld;
			var maxBox = mesh.getBoundingInfo().boundingBox.maximumWorld;
			
			com.babylonhx.math.Tools.CheckExtends(minBox, min, max);
			com.babylonhx.math.Tools.CheckExtends(maxBox, min, max);
		}
		
		return {
			min: min,
			max: max
		};
	}
		
	inline public function createOrUpdateSelectionOctree(maxCapacity:Int = 64, maxDepth:Int = 2):Octree<AbstractMesh> {
		if (this._selectionOctree == null) {
			this._selectionOctree = new Octree<AbstractMesh>(Octree.CreationFuncForMeshes, maxCapacity, maxDepth);
		}
		
		var worldExtends = this.getWorldExtends();
		
		// Update octree
		this._selectionOctree.update(worldExtends.min, worldExtends.max, this.meshes);
		
		return this._selectionOctree;
	}

	// Picking
	public function createPickingRay(x:Float, y:Float, world:Matrix, camera:Camera, cameraViewSpace:Bool = false):Ray {
		var engine = this._engine;
		
		if (camera == null) {
			if (this.activeCamera == null) {
				throw("Active camera not set");
			}
			
			camera = this.activeCamera;
		}
		
		var cameraViewport = camera.viewport;
		var viewport = cameraViewport.toGlobal(engine.getRenderWidth(), engine.getRenderHeight());
		
		// Moving coordinates to local viewport world
		x = x / this._engine.getHardwareScalingLevel() - viewport.x;
		y = y / this._engine.getHardwareScalingLevel() - (this._engine.getRenderHeight() - viewport.y - viewport.height);
		
		return Ray.CreateNew(x, y, viewport.width, viewport.height, world != null ? world : Matrix.Identity(), cameraViewSpace ? Matrix.Identity() : camera.getViewMatrix(), camera.getProjectionMatrix(false));
	}
	
	public function createPickingRayInCameraSpace(x:Float, y:Float, ?camera:Camera):Ray {
		var engine = this._engine;
		
		if (camera == null) {
			if (this.activeCamera == null) {
				throw "Active camera not set";
			}
			
			camera = this.activeCamera;
		}
		
		var cameraViewport = camera.viewport;
		var viewport = cameraViewport.toGlobal(engine.getRenderWidth(), engine.getRenderHeight());
		var identity = Matrix.Identity();
		
		// Moving coordinates to local viewport world
		x = x / this._engine.getHardwareScalingLevel() - viewport.x;
		y = y / this._engine.getHardwareScalingLevel() - (this._engine.getRenderHeight() - viewport.y - viewport.height);
		
		return Ray.CreateNew(x, y, viewport.width, viewport.height, identity, identity, camera.getProjectionMatrix(false));
	}

	private function _internalPick(rayFunction:Matrix->Ray, predicate:AbstractMesh->Bool, fastCheck:Bool = false):PickingInfo {
		var pickingInfo:PickingInfo = null;
		
		for (meshIndex in 0...this.meshes.length) {
			var mesh = this.meshes[meshIndex];
			
			if (predicate != null) {
				if (!predicate(mesh)) {
					continue;
				}
			} 
			else if (!mesh.isEnabled() || !mesh.isVisible || !mesh.isPickable) {
				continue;
			}
			
			var world = mesh.getWorldMatrix();
			var ray = rayFunction(world);
			
			var result = mesh.intersects(ray, fastCheck);
			if (result == null || !result.hit) {
				continue;
			}
			
			if (!fastCheck && pickingInfo != null && result.distance >= pickingInfo.distance) {
				continue;
			}
			
			pickingInfo = result;
			
			if (fastCheck) {
				break;
			}
		}
		
		return pickingInfo != null ? pickingInfo : new PickingInfo();
	}
	
	private function _internalPickSprites(ray:Ray, ?predicate:Sprite->Bool, fastCheck:Bool = false, ?camera:Camera):PickingInfo {
		var pickingInfo:PickingInfo = new PickingInfo();
		
		if (camera == null) {
			camera = this.activeCamera;
		}
		
		if (this.spriteManagers.length > 0) {
			for (spriteIndex in 0...this.spriteManagers.length) {
				var spriteManager = this.spriteManagers[spriteIndex];
				
				if (!spriteManager.isPickable) {
					continue;
				}
				
				var result = spriteManager.intersects(ray, camera, predicate, fastCheck);
				if (result == null || !result.hit) {
					continue;
				}
				
				if (!fastCheck && pickingInfo != null && result.distance >= pickingInfo.distance) {
					continue;
				}
				
				pickingInfo = result;
				
				if (fastCheck) {
					break;
				}
			}
		}
		
		return pickingInfo;
	}

	inline public function pick(x:Float, y:Float, ?predicate:AbstractMesh->Bool, fastCheck:Bool = false, ?camera:Camera):PickingInfo {
		/// <summary>Launch a ray to try to pick a mesh in the scene</summary>
		/// <param name="x">X position on screen</param>
		/// <param name="y">Y position on screen</param>
		/// <param name="predicate">Predicate function used to determine eligible meshes. Can be set to null. In this case, a mesh must be enabled, visible and with isPickable set to true</param>
		/// <param name="fastCheck">Launch a fast check only using the bounding boxes. Can be set to null.</param>
		/// <param name="camera">camera to use for computing the picking ray. Can be set to null. In this case, the scene.activeCamera will be used</param>
		return this._internalPick(function(world:Matrix):Ray { return this.createPickingRay(x, y, world, camera); }, predicate, fastCheck);
	}
	
	inline public function pickSprite(x:Float, y:Float, ?predicate:Sprite->Bool, fastCheck:Bool = false, ?camera:Camera):PickingInfo {
		/// <summary>Launch a ray to try to pick a mesh in the scene</summary>
		/// <param name="x">X position on screen</param>
		/// <param name="y">Y position on screen</param>
		/// <param name="predicate">Predicate function used to determine eligible sprites. Can be set to null. In this case, a sprite must have isPickable set to true</param>
		/// <param name="fastCheck">Launch a fast check only using the bounding boxes. Can be set to null.</param>
		/// <param name="camera">camera to use for computing the picking ray. Can be set to null. In this case, the scene.activeCamera will be used</param>
		return this._internalPickSprites(this.createPickingRayInCameraSpace(x, y, camera), predicate, fastCheck, camera);
	}

	public function pickWithRay(ray:Ray, predicate:Mesh->Bool, fastCheck:Bool = false):PickingInfo {
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

	inline public function getPointerOverMesh():AbstractMesh {
		return this._pointerOverMesh;
	}
	
	public function setPointerOverSprite(sprite:Sprite) {
		if (this._pointerOverSprite == sprite) {
			return;
		}
		
		if (this._pointerOverSprite != null && this._pointerOverSprite.actionManager != null) {
			this._pointerOverSprite.actionManager.processTrigger(ActionManager.OnPointerOutTrigger, ActionEvent.CreateNewFromSprite(this._pointerOverSprite, this));
		}
		
		this._pointerOverSprite = sprite;
		if (this._pointerOverSprite != null && this._pointerOverSprite.actionManager != null) {
			this._pointerOverSprite.actionManager.processTrigger(ActionManager.OnPointerOverTrigger, ActionEvent.CreateNewFromSprite(this._pointerOverSprite, this));
		}
	}
	
	public function getPointerOverSprite():Sprite {
		return this._pointerOverSprite;
	}

	// Physics
	inline public function getPhysicsEngine():PhysicsEngine {
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

	inline public function isPhysicsEnabled():Bool {
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
	
	// Misc.
	public function createDefaultCameraOrLight() {
		// Light
		if (this.lights.length == 0) {
			new HemisphericLight("default light", Vector3.Up(), this);
		}
		
		// Camera
		if (this.activeCamera == null) {
			var camera = new FreeCamera("default camera", Vector3.Zero(), this);
			
			// Compute position
			var worldExtends = this.getWorldExtends();
			var worldCenter:Vector3 = cast worldExtends.min.add(worldExtends.max.subtract(worldExtends.min).scale(0.5));
			
			camera.position = new Vector3(worldCenter.x, worldCenter.y, worldExtends.min.z - (worldExtends.max.z - worldExtends.min.z));
			camera.setTarget(worldCenter);
			
			this.activeCamera = camera;
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
