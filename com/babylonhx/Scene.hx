package com.babylonhx;

import com.babylonhx.animations.AnimationGroup;
import com.babylonhx.engine.Engine;
import com.babylonhx.events.PointerEvent;
import com.babylonhx.events.PointerInfoPre;
import com.babylonhx.events.PointerInfo;
import com.babylonhx.events.PointerEventTypes;
import com.babylonhx.events.KeyboardInfo;
import com.babylonhx.events.KeyboardInfoPre;
import com.babylonhx.events.KeyboardEventTypes;
import com.babylonhx.actions.Action;
import com.babylonhx.actions.ActionManager;
import com.babylonhx.actions.ActionEvent;
import com.babylonhx.animations.Animatable;
import com.babylonhx.animations.Animation;
import com.babylonhx.animations.IAnimatable;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.bones.Bone;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.cameras.TargetCamera;
import com.babylonhx.collisions.Collider;
import com.babylonhx.collisions.PickingInfo;
import com.babylonhx.culling.octrees.Octree;
import com.babylonhx.layer.Layer;
import com.babylonhx.layer.HighlightLayer;
import com.babylonhx.lensflare.LensFlareSystem;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.Light;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.ImageProcessingConfiguration;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.MultiMaterial;
import com.babylonhx.materials.pbr.PBRMaterial;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.UniformBuffer;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.materials.textures.procedurals.ProceduralTexture;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.cameras.Camera;
import com.babylonhx.math.Tmp;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Plane;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Frustum;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Geometry;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.culling.Ray;
import com.babylonhx.collisions.ICollisionCoordinator;
import com.babylonhx.collisions.CollisionCoordinatorLegacy;
import com.babylonhx.mesh.TransformNode;
import com.babylonhx.morph.MorphTargetManager;
import com.babylonhx.mesh.simplification.SimplificationQueue;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.particles.IParticleSystem;
import com.babylonhx.physics.PhysicsEngine;
import com.babylonhx.physics.IPhysicsEnginePlugin;
import com.babylonhx.physics.PhysicsBodyCreationOptions;
import com.babylonhx.postprocess.PostProcess;
import com.babylonhx.postprocess.PostProcessManager;
import com.babylonhx.postprocess.renderpipeline.PostProcessRenderPipelineManager;
import com.babylonhx.probes.ReflectionProbe;
import com.babylonhx.rendering.BoundingBoxRenderer;
import com.babylonhx.rendering.DepthRenderer;
import com.babylonhx.rendering.GeometryBufferRenderer;
import com.babylonhx.rendering.OutlineRenderer;
import com.babylonhx.rendering.EdgesRenderer;
import com.babylonhx.rendering.RenderingManager;
import com.babylonhx.sprites.SpriteManager;
import com.babylonhx.sprites.Sprite;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.tools.SmartArrayNoDuplicate;
import com.babylonhx.tools.Tools;
import com.babylonhx.tools.Observable;
import com.babylonhx.tools.Observer;
import com.babylonhx.tools.EventState;
import com.babylonhx.tools.StringDictionary;
import com.babylonhx.tools.PerfCounter;
import haxe.Timer;

//import com.babylonhx.d2.display.Stage;

#if (purejs || js)
import com.babylonhx.audio.*;
#end

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Scene') 
@:external class Scene implements IAnimatable {
	
	// Statics
	public static var FOGMODE_NONE:Int = 0;
	public static var FOGMODE_EXP:Int = 1;
	public static var FOGMODE_EXP2:Int = 2;
	public static var FOGMODE_LINEAR:Int = 3;
	
	private static var _uniqueIdCounter:Int = 0;

	public static var MinDeltaTime:Float = 1.0;
	public static var MaxDeltaTime:Float = 1000.0;

	// Members
	public var autoClear:Bool = true;
	public var autoClearDepthAndStencil:Bool = true;
	public var clearColor:Color4 = new Color4(0.2, 0.2, 0.3, 1.0);
	public var ambientColor:Color3 = new Color3(0, 0, 0);
	
	public var _environmentBRDFTexture:BaseTexture;
	
	private var _environmentTexture:BaseTexture;
	public var environmentTexture(get, set):BaseTexture;
	/**
	 * Texture used in all pbr material as the reflection texture.
	 * As in the majority of the scene they are the same (exception for multi room and so on),
	 * this is easier to reference from here than from all the materials.
	 */
	private function get_environmentTexture():BaseTexture {
		return this._environmentTexture;
	}
	/**
	 * Texture used in all pbr material as the reflection texture.
	 * As in the majority of the scene they are the same (exception for multi room and so on),
	 * this is easier to set here than in all the materials.
	 */
	private function set_environmentTexture(value:BaseTexture):BaseTexture {
		if (this._environmentTexture == value) {
			return value;
		}
		this._environmentTexture = value;
		this.markAllMaterialsAsDirty(Material.TextureDirtyFlag);
		return value;
	}
	
	private var _imageProcessingConfiguration:ImageProcessingConfiguration;	
	public var imageProcessingConfiguration(get, never):ImageProcessingConfiguration;
	/**
	 * Default image processing configuration used either in the rendering
	 * Forward main pass or through the imageProcessingPostProcess if present.
	 * As in the majority of the scene they are the same (exception for multi camera),
	 * this is easier to reference from here than from all the materials and post process.
	 * 
	 * No setter as it is a shared configuration, you can set the values instead.
	 */
	inline private function get_imageProcessingConfiguration():ImageProcessingConfiguration {
		return this._imageProcessingConfiguration;
	}
	
	public var forceWireframe:Bool = false;
	private var _forcePointsCloud = false;
	public var forcePointsCloud(get, set):Bool;
	private function set_forcePointsCloud(value:Bool):Bool {
		if (this._forcePointsCloud == value) {
			return value;
		}
		this._forcePointsCloud = value;
		this.markAllMaterialsAsDirty(Material.MiscDirtyFlag);
		return value;
	}
	private inline function get_forcePointsCloud():Bool {
		return this._forcePointsCloud;
	} 
	
	public var forceShowBoundingBoxes:Bool = false;
	public var clipPlane:Plane;
	public var animationsEnabled:Bool = true;
	public var useConstantAnimationDeltaTime:Bool = false;
	public var constantlyUpdateMeshUnderPointer:Bool = false;
	
	public var hoverCursor:String = "pointer";
	public var defaultCursor:String = "";
	/**
     * This is used to call preventDefault() on pointer down
     * in order to block unwanted artifacts like system double clicks
     */
    public var preventDefaultOnPointerDown:Bool = true;
	
	// Metadata
	public var metadata:Dynamic = null;
	
	// Events
	
	private var _spritePredicate:Sprite->Bool;

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
	/** A function to be executed before rendering this scene */
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
	/** A function to be executed after rendering this scene */
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
	* An event triggered before animating the scene
	* @type {BABYLON.Observable}
	*/
	public var onBeforeAnimationsObservable:Observable<Scene> = new Observable<Scene>();

	/**
	* An event triggered after animations processing
	* @type {BABYLON.Observable}
	*/
	public var onAfterAnimationsObservable:Observable<Scene> = new Observable<Scene>();

	/**
	* An event triggered before draw calls are ready to be sent
	* @type {BABYLON.Observable}
	*/
	public var onBeforeDrawPhaseObservable:Observable<Scene> = new Observable<Scene>();

	/**
	* An event triggered after draw calls have been sent
	* @type {BABYLON.Observable}
	*/
	public var onAfterDrawPhaseObservable:Observable<Scene> = new Observable<Scene>();

	/**
	* An event triggered when physic simulation is about to be run
	* @type {BABYLON.Observable}
	*/
	public var onBeforePhysicsObservable:Observable<Scene> = new Observable<Scene>();

	/**
	* An event triggered when physic simulation has been done
	* @type {BABYLON.Observable}
	*/
	public var onAfterPhysicsObservable:Observable<Scene> = new Observable<Scene>();

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
	* An event triggered when active meshes evaluation is about to start
	* @type {BABYLON.Observable}
	*/
	public var onBeforeActiveMeshesEvaluationObservable:Observable<Scene> = new Observable<Scene>();

	/**
	* An event triggered when active meshes evaluation is done
	* @type {BABYLON.Observable}
	*/
	public var onAfterActiveMeshesEvaluationObservable:Observable<Scene> = new Observable<Scene>();

	/**
	* An event triggered when particles rendering is about to start
	* Note: This event can be trigger more than once per frame (because particles can be rendered by render target textures as well)
	* @type {BABYLON.Observable}
	*/
	public var onBeforeParticlesRenderingObservable:Observable<Scene> = new Observable<Scene>();

	/**
	* An event triggered when particles rendering is done
	* Note: This event can be trigger more than once per frame (because particles can be rendered by render target textures as well)
	* @type {BABYLON.Observable}
	*/
	public var onAfterParticlesRenderingObservable:Observable<Scene> = new Observable<Scene>();

	/**
	* An event triggered when sprites rendering is about to start
	* Note: This event can be trigger more than once per frame (because sprites can be rendered by render target textures as well)
	* @type {BABYLON.Observable}
	*/
	public var onBeforeSpritesRenderingObservable:Observable<Scene> = new Observable<Scene>();

	/**
	* An event triggered when sprites rendering is done
	* Note: This event can be trigger more than once per frame (because sprites can be rendered by render target textures as well)
	* @type {BABYLON.Observable}
	*/
	public var onAfterSpritesRenderingObservable:Observable<Scene> = new Observable<Scene>();

	/**
	* An event triggered when SceneLoader.Append or SceneLoader.Load or SceneLoader.ImportMesh were successfully executed
	* @type {BABYLON.Observable}
	*/
	public var onDataLoadedObservable:Observable<Scene> = new Observable<Scene>();

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
	* An event triggered when a transform node is created
	* @type {BABYLON.Observable}
	*/
	public var onNewTransformNodeAddedObservable:Observable<TransformNode> = new Observable<TransformNode>();

	/**
	* An event triggered when a transform node is removed
	* @type {BABYLON.Observable}
	*/
	public var onTransformNodeRemovedObservable:Observable<TransformNode> = new Observable<TransformNode>();

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
	
	/**
	* An event triggered when render targets are about to be rendered
	* Can happen multiple times per frame.
	* @type {BABYLON.Observable}
	*/
	public var OnBeforeRenderTargetsRenderObservable:Observable<Scene> = new Observable<Scene>();

	/**
	* An event triggered when render targets were rendered.
	* Can happen multiple times per frame.
	* @type {BABYLON.Observable}
	*/
	public var OnAfterRenderTargetsRenderObservable:Observable<Scene> = new Observable<Scene>();
	
	/**
     * An event triggered before calculating deterministic simulation step
     * @type {BABYLON.Observable}
     */
    public var onBeforeStepObservable:Observable<Scene> = new Observable<Scene>();
 
    /**
     * An event triggered after calculating deterministic simulation step
     * @type {BABYLON.Observable}
     */
    public var onAfterStepObservable:Observable<Scene> = new Observable<Scene>();
	
	/**
	 * This Observable will be triggered for each stage of each renderingGroup of each rendered camera.
	 * The RenderinGroupInfo class contains all the information about the context in which the observable is called
	 * If you wish to register an Observer only for a given set of renderingGroup, use the mask with a combination 
	 * of the renderingGroup index elevated to the power of two (1 for renderingGroup 0, 2 for renderingrOup1, 4 for 2 and 8 for 3)
	 */
	public var onRenderingGroupObservable:Observable<RenderingGroupInfo> = new Observable<RenderingGroupInfo>();
	
	// Animations
	public var animations:Array<Animation> = [];

	// Pointers
	public var pointerDownPredicate:AbstractMesh->Bool;
	public var pointerUpPredicate:AbstractMesh->Bool;
	public var pointerMovePredicate:AbstractMesh->Bool;
	private var _onPointerMove:PointerEvent->Void; // Int->Int->Void;
	private var _onPointerDown:PointerEvent->Void; // Int->Int->Int->Void;
	private var _onPointerUp:PointerEvent->Void; // Int->Int->Int->Void;
	
	public var onPointerMove:PointerEvent->PickingInfo->Void; //Int->Int->PickingInfo->Void;
	public var onPointerDown:PointerEvent->PickingInfo->Void; //Int->Int->Int->PickingInfo->Void;
	public var onPointerUp:PointerEvent->PickingInfo->Void;   //Int->Int->Int->PickingInfo->Void;
	public var onPointerPick:PointerEvent->PickingInfo->Void;
	
	// Gamepads
	// VK TODO:
	/*private var _gamepadManager:GamepadManager;
	public var gamepadManager(get, never):GamepadManager;
	inline private function get_gamepadManager():GamepadManager {
		if (this._gamepadManager == null) {
			this._gamepadManager = new GamepadManager();
		}
		
		return this._gamepadManager;
	}*/
	
	/**
     * This observable event is triggered when any mouse event registered during Scene.attach() is called 
	 * BEFORE the 3D engine to process anything (mesh/sprite picking for instance).
     * You have the possibility to skip the 3D Engine process and the call to onPointerObservable by setting 
	 * PointerInfoBase.skipOnPointerObservable to true
     */
    public var onPrePointerObservable:Observable<PointerInfoPre> = new Observable<PointerInfoPre>();
	
	/**
	 * Observable event triggered each time an input event is received from the rendering canvas
	 */
	public var onPointerObservable:Observable<PointerInfo> = new Observable<PointerInfo>();
	
	public var unTranslatedPointer(get, never):Vector2;
	private function get_unTranslatedPointer():Vector2 {
		return new Vector2(this._unTranslatedPointerX, this._unTranslatedPointerY);
	}
	
	/** The distance in pixel that you have to move to prevent some events */
	public static var DragMovementThreshold:Int = 10; 			// in pixels
	/** Time in milliseconds to wait to raise long press events if button is still pressed */
	public static var LongPressDelay:Int = 500; 				// in milliseconds
	/** Time in milliseconds with two consecutive clicks will be considered as a double click */
	public static var DoubleClickDelay:Int = 300; 				// in milliseconds
	/** If you need to check double click without raising a single click at first click, enable this flag */
	public static var ExclusiveDoubleClickMode:Bool = false;
	
	private var _initClickEvent:Observable<PointerInfoPre>->Observable<PointerInfo>->Dynamic->(ClickInfo->PickingInfo->Void)->Void;
	private var _initActionManager:ActionManager->ClickInfo->ActionManager;
	private var _delayedSimpleClick:Int->ClickInfo->(ClickInfo->PickingInfo->Void)->Void;
	private var _delayedSimpleClickTimeout:Float;
	private var _previousDelayedSimpleClickTimeout:Float;
	private var _meshPickProceed:Bool = false;

	private var _previousButtonPressed:Int;
	private var _previousHasSwiped:Bool = false;
	private var _currentPickResult:PickingInfo = null;
	private var _previousPickResult:PickingInfo = null;
	private var _totalPointersPressed:Int = 0;
	private var _doubleClickOccured:Bool = false;
	
	/** Define this parameter if you are using multiple cameras and you want to specify which one should be used for pointer position */
	public var cameraToUseForPointers:Camera = null; 
	private var _pointerX:Int;
	private var _pointerY:Int;
	private var _unTranslatedPointerX:Int;
	private var _unTranslatedPointerY:Int;
	private var _startingPointerPosition:Vector2 = new Vector2(0, 0);
	private var _previousStartingPointerPosition:Vector2 = new Vector2(0, 0); 
	private var _startingPointerTime:Float = 0;
	private var _previousStartingPointerTime:Float = 0;
	
	// Deterministic lockstep
    private var _timeAccumulator:Float = 0;
    private var _currentStepId:Int = 0;
    private var _currentInternalStep:Int = 0;
	
	// Mirror
    public var _mirroredCameraPosition:Vector3 = null;

	// Keyboard

	/**
	 * This observable event is triggered when any keyboard event si raised and registered during Scene.attachControl()
	 * You have the possibility to skip the process and the call to onKeyboardObservable by setting KeyboardInfoPre.skipOnPointerObservable to true
	 */
	public var onPreKeyboardObservable:Observable<KeyboardInfoPre> = new Observable<KeyboardInfoPre>();
	
	/**
	 * Observable event triggered each time an keyboard event is received from the hosting window
	 */
	public var onKeyboardObservable:Observable<KeyboardInfo> = new Observable<KeyboardInfo>();
	private var _onKeyDown:Dynamic;		// Event->Void
	private var _onKeyUp:Dynamic;		// Event->Void
	
	// Coordinate system
	/**
	* use right-handed coordinate system on this scene.
	* @type {boolean}
	*/
	private var _useRightHandedSystem:Bool = false;
	public var useRightHandedSystem(get, set):Bool;
	public function set_useRightHandedSystem(value:Bool):Bool {
		if (this._useRightHandedSystem == value) {
			return value;
		}
		this._useRightHandedSystem = value;
		this.markAllMaterialsAsDirty(Material.MiscDirtyFlag);
		return value;
	}
	private function get_useRightHandedSystem():Bool {
		return this._useRightHandedSystem;
	}
	
	public function setStepId(newStepId:Int) {
        this._currentStepId = newStepId;
    }

    public function getStepId():Int {
        return this._currentStepId;
    }

    public function getInternalStep():Int {
        return this._currentInternalStep;
    }

	// Fog
	/**
	* is fog enabled on this scene.
	* @type {boolean}
	*/
	private var _fogEnabled:Bool = true;
	public var fogEnabled(get, set):Bool;
	private function set_fogEnabled(value:Bool):Bool {
		if (this._fogEnabled == value) {
			return value;
		}
		this._fogEnabled = value;
		this.markAllMaterialsAsDirty(Material.MiscDirtyFlag);
		return value;
	}
	private function get_fogEnabled():Bool {
		return this._fogEnabled;
	}   

	private var _fogMode:Int = Scene.FOGMODE_NONE;
	public var fogMode(get, set):Int;
	private function set_fogMode(value:Int):Int {
		if (this._fogMode == value) {
			return value;
		}
		this._fogMode = value;
		this.markAllMaterialsAsDirty(Material.MiscDirtyFlag);
		return value;
	}
	private function get_fogMode():Int {
		return this._fogMode;
	}
		
	public var fogColor:Color3 = new Color3(0.2, 0.2, 0.3);
	public var fogDensity:Float = 0.1;
	public var fogStart:Float = 0;
	public var fogEnd:Float = 1000.0;
	
	// 2D
	/*private var _stage2D:Stage;
	public var stage2D(get, never):Stage;
	inline private function get_stage2D():Stage {
		return _stage2D;
	}*/

	// Lights
	/**
	* is shadow enabled on this scene.
	* @type {boolean}
	*/
	private var _shadowsEnabled:Bool = true;
	public var shadowsEnabled(get, set):Bool;
	private function set_shadowsEnabled(value:Bool):Bool {
		if (this._shadowsEnabled == value) {
			return value;
		}
		this._shadowsEnabled = value;
		this.markAllMaterialsAsDirty(Material.LightDirtyFlag);
		return value;
	}
	private function get_shadowsEnabled():Bool {
		return this._shadowsEnabled;
	}       

	/**
	* is light enabled on this scene.
	* @type {boolean}
	*/
	private var _lightsEnabled:Bool = true;
	public var lightsEnabled(get, set):Bool;
	private function set_lightsEnabled(value:Bool):Bool {
		if (this._lightsEnabled == value) {
			return value;
		}
		this._lightsEnabled = value;
		this.markAllMaterialsAsDirty(Material.LightDirtyFlag);
		return value;
	}
	private function get_lightsEnabled():Bool {
		return this._lightsEnabled;
	}
		
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
	* All of the tranform nodes added to this scene.
	* @see BABYLON.TransformNode
	* @type {BABYLON.TransformNode[]}
	*/
	public var transformNodes:Array<TransformNode> = [];
		
	/**
	* All of the (abstract) meshes added to this scene.
	* @see BABYLON.AbstractMesh
	* @type {BABYLON.AbstractMesh[]}
	*/
	public var meshes:Array<AbstractMesh> = [];
	
	/**
	* All of the animation groups added to this scene.
	* @see BABYLON.AnimationGroup
	* @type {BABYLON.AnimationGroup[]}
	*/
	public var animationGroups:Array<AnimationGroup> = [];

	// Geometries
	private var _geometries:Array<Geometry> = [];

	public var materials:Array<Material> = [];
	public var multiMaterials:Array<MultiMaterial> = [];
	private var _defaultMaterial:Material;
	public var defaultMaterial(get, set):Material;
	private function get_defaultMaterial():Material {
		if (this._defaultMaterial == null) {
			this._defaultMaterial = new StandardMaterial("default material", this);
		}
		
		return this._defaultMaterial;
	}
	private function set_defaultMaterial(value:Material):Material {
		return this._defaultMaterial = value;
	}

	// Textures
	private var _texturesEnabled:Bool = true;
	public var texturesEnabled(get, set):Bool;
	private function set_texturesEnabled(value:Bool):Bool {
		if (this._texturesEnabled == value) {
			return value;
		}
		this._texturesEnabled = value;
		this.markAllMaterialsAsDirty(Material.TextureDirtyFlag);
		return value;
	}
	private function get_texturesEnabled():Bool {
		return this._texturesEnabled;
	}
	
	public var textures:Array<BaseTexture> = [];

	// Particles
	public var particlesEnabled:Bool = true;
	public var particleSystems:Array<IParticleSystem> = [];

	// Sprites
	public var spritesEnabled:Bool = true;
	public var spriteManagers:Array<SpriteManager> = [];

	// Layers
	public var layers:Array<Layer> = [];
	public var highlightLayers:Array<HighlightLayer> = [];

	// Skeletons
	private var _skeletonsEnabled:Bool = true;
	public var skeletonsEnabled(get, set):Bool;
	private function set_skeletonsEnabled(value:Bool):Bool {
		if (this._skeletonsEnabled == value) {
			return value;
		}
		this._skeletonsEnabled = value;
		this.markAllMaterialsAsDirty(Material.AttributesDirtyFlag);
		return value;
	}
	private function get_skeletonsEnabled():Bool {
		return this._skeletonsEnabled;
	}
	
	public var skeletons:Array<Skeleton> = [];
	
	// Morph targets
	public var morphTargetManagers:Array<MorphTargetManager> = [];

	// Lens flares
	public var lensFlaresEnabled:Bool = true;
	public var lensFlareSystems:Array<LensFlareSystem> = [];
	
	// Collisions
	public var collisionsEnabled:Bool = true;	
	private var _workerCollisions:Bool = false;
	public var collisionCoordinator:ICollisionCoordinator;
	public var gravity:Vector3 = new Vector3(0, -9.0, 0);

	// Postprocesses
	public var postProcesses:Array<PostProcess> = [];
	public var postProcessesEnabled:Bool = true;
	public var postProcessManager:PostProcessManager;
	private var _postProcessRenderPipelineManager:PostProcessRenderPipelineManager;
	public var postProcessRenderPipelineManager(get, never):PostProcessRenderPipelineManager;
	public function get_postProcessRenderPipelineManager():PostProcessRenderPipelineManager {
		if (this._postProcessRenderPipelineManager == null) {
			this._postProcessRenderPipelineManager = new PostProcessRenderPipelineManager();
		}
		
		return this._postProcessRenderPipelineManager;
	}

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
	private var _meshesForIntersections:SmartArrayNoDuplicate<AbstractMesh> = new SmartArrayNoDuplicate<AbstractMesh>(256);

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
	
	// Performance counters
	private var _totalMeshesCounter:PerfCounter = new PerfCounter();
	private var _totalLightsCounter:PerfCounter = new PerfCounter();
	private var _totalMaterialsCounter:PerfCounter = new PerfCounter();
	private var _totalTexturesCounter:PerfCounter = new PerfCounter();
	private var _totalVertices:PerfCounter = new PerfCounter();
	public var _activeIndices:PerfCounter = new PerfCounter();
	public var _activeParticles:PerfCounter = new PerfCounter();
	private var _lastFrameDuration:PerfCounter = new PerfCounter();
	private var _evaluateActiveMeshesDuration:PerfCounter = new PerfCounter();
	private var _renderTargetsDuration:PerfCounter = new PerfCounter();
	public var _particlesDuration = new PerfCounter();
	private var _renderDuration:PerfCounter = new PerfCounter();
	public var _spritesDuration:PerfCounter = new PerfCounter();
	public var _activeBones:PerfCounter = new PerfCounter();
	
	private var _animationRatio:Float = 0;
	
	private var _animationTimeLast:Float = Math.NEGATIVE_INFINITY;
    private var _animationTime:Float = 0;
    public var animationTimeScale:Float = 1;
	
	public var _cachedMaterial:Material;
	public var _cachedEffect:Effect;
	public var _cachedVisibility:Float;

	private var _renderId:Int = 0;
	private var _executeWhenReadyTimeoutId:Int = -1;
	private var _intermediateRendering:Bool = false;
	
	private var _viewUpdateFlag:Int = -1;
	private var _projectionUpdateFlag:Int = -1;
	private var _alternateViewUpdateFlag:Int = -1;
	private var _alternateProjectionUpdateFlag:Int = -1;

	public var _toBeDisposed:SmartArray<ISmartArrayCompatible> = new SmartArray<ISmartArrayCompatible>(256);
	private var _pendingData:Array<Dynamic> = [];//ANY
	private var _isDisposed:Bool = false;

	public var dispatchAllSubMeshesOfActiveMeshes:Bool = false;
	private var _activeMeshes:SmartArray<AbstractMesh> = new SmartArray<AbstractMesh>(256);				
	private var _processedMaterials:SmartArray<Material> = new SmartArray<Material>(256);		
	private var _renderTargets:SmartArrayNoDuplicate<RenderTargetTexture> = new SmartArrayNoDuplicate<RenderTargetTexture>(256);			
	public var _activeParticleSystems:SmartArray<IParticleSystem> = new SmartArray<IParticleSystem>(256);		
	private var _activeSkeletons:SmartArrayNoDuplicate<Skeleton> = new SmartArrayNoDuplicate<Skeleton>(32);			
	private var _softwareSkinnedMeshes:SmartArrayNoDuplicate<Mesh> = new SmartArrayNoDuplicate<Mesh>(32);	

	private var _renderingManager:RenderingManager;
	private var _physicsEngine:PhysicsEngine;

	public var _activeAnimatables:Array<Animatable> = [];

	private var _transformMatrix:Matrix = Matrix.Zero();
	private var _sceneUbo:UniformBuffer;
	private var _alternateSceneUbo:UniformBuffer;
	
	private var _pickWithRayInverseMatrix:Matrix;

	private var _boundingBoxRenderer:BoundingBoxRenderer;
	private var _outlineRenderer:OutlineRenderer;

	private var _viewMatrix:Matrix;
	private var _projectionMatrix:Matrix;
	private var _alternateViewMatrix:Matrix;
	private var _alternateProjectionMatrix:Matrix;
	private var _alternateTransformMatrix:Matrix;
	private var _useAlternateCameraConfiguration:Bool = false;
	private var _alternateRendering:Bool = false;
	public var _forcedViewPosition:Vector3 = null;
	
	public var _isAlternateRenderingEnabled(get, never):Bool;
	inline private function get__isAlternateRenderingEnabled():Bool {
		return this._alternateRendering;
	}
	
	private var _frustumPlanes:Array<Plane>;
	public var frustumPlanes(get, never):Array<Plane>;
	public function get_frustumPlanes():Array<Plane> {
		return _frustumPlanes;
	}
	
	public var requireLightSorting:Bool = false;

	public var _selectionOctree:Octree<AbstractMesh>;

	private var _pointerOverMesh:AbstractMesh;
	private var _pointerOverSprite:Sprite;
	
	//private var _debugLayer:DebugLayer;
	
	private var _depthRenderer:DepthRenderer;
	private var _geometryBufferRenderer:GeometryBufferRenderer;
	
	private var _pickedDownMesh:AbstractMesh;
	private var _pickedUpMesh:AbstractMesh;
	private var _pickedDownSprite:Sprite;	
	private var _externalData:StringDictionary<Dynamic>;
    private var _uid:String;
	
	public var offscreenRenderTarget:RenderTargetTexture = null;
	

	public function new(?engine:Engine) {
		this._engine = engine != null ? engine : Engine.LastCreatedEngine;
		
		this._engine.scenes.push(this);
		this._uid = null;
		
		this._renderingManager = new RenderingManager(this);
		
		this.postProcessManager = new PostProcessManager(this);
		
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
		
		// Uniform Buffer
		this._createUbo();
		
		// Default Image processing definition.
		this._imageProcessingConfiguration = new ImageProcessingConfiguration();
	}

	// Properties
	public var workerCollisions(get, set):Bool;
	private function set_workerCollisions(enabled:Bool):Bool {
		/*enabled = (enabled && !!Worker);

		this._workerCollisions = enabled;
		if (this.collisionCoordinator) {
			this.collisionCoordinator.destroy();
		}

		this.collisionCoordinator = enabled ? new CollisionCoordinatorWorker() : new CollisionCoordinatorLegacy();

		this.collisionCoordinator.init(this);*/
		return enabled;
	}
	private function get_workerCollisions():Bool {
		return this._workerCollisions;
	}
	
	public var selectionOctree(get, never):Octree<AbstractMesh>;
	private function get_selectionOctree():Octree<AbstractMesh> {
		return this._selectionOctree;
	}
		
	/**
	 * The mesh that is currently under the pointer.
	 * @return {BABYLON.AbstractMesh} mesh under the pointer/mouse cursor or null if none.
	 */
	public var meshUnderPointer(get, never):AbstractMesh;
	private function get_meshUnderPointer():AbstractMesh {
		return this._pointerOverMesh;
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
	
	public function getCachedEffect():Effect {
		return this._cachedEffect;
	}

	public function getCachedVisibility():Float {
		return this._cachedVisibility;
	}

	public function isCachedMaterialInvalid(material:Material, effect:Effect, visibility:Float = 1) {
		return this._cachedEffect != effect || this._cachedMaterial != material || this._cachedVisibility != visibility;
	}

	public function getBoundingBoxRenderer():BoundingBoxRenderer {
		if (this._boundingBoxRenderer == null) {
			this._boundingBoxRenderer = new BoundingBoxRenderer(this);
		}
		
		return this._boundingBoxRenderer;
	}

	public function getOutlineRenderer():OutlineRenderer {
		return this._outlineRenderer;
	}

	inline public function getEngine():Engine {
		return this._engine;
	}

	inline public function getTotalVertices():Int {
		return this._totalVertices.current;
	}
	
	public var totalVerticesPerfCounter(get, never):PerfCounter;
	private function get_totalVerticesPerfCounter():PerfCounter {
		return this._totalVertices;
	}

	inline public function getActiveVertices():Int {
		return this._activeIndices.current;
	}
	
	public var totalActiveIndicesPerfCounter(get, never):PerfCounter;
	private function get_totalActiveIndicesPerfCounter():PerfCounter {
		return this._activeIndices;
	}

	inline public function getActiveParticles():Int {
		return this._activeParticles.current;
	}
	
	public var activeParticlesPerfCounter(get, never):PerfCounter;
	private function get_activeParticlesPerfCounter():PerfCounter {
		return this._activeParticles;
	}
	
	inline public function getActiveBones():Int {
		return this._activeBones.current;
	}
	
	public var activeBonesPerfCounter(get, never):PerfCounter;
	private function get_activeBonesPerfCounter():PerfCounter {
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
	
	/*public function init2D():Stage {
		if (this.activeCamera != null) {
			if (this._stage2D == null) {
				this._stage2D = new Stage(this);
			}
			
			#if mobile
			
			#else
			//_engine.mouseDown.push(stage2D._onMD);
			//_engine.mouseMove.push(stage2D._onMM);
			//_engine.mouseUp.push(stage2D._onMU);
			
			_engine.keyDown.push(stage2D._onKD);
			_engine.keyUp.push(stage2D._onKU);
			#end
			
			return this._stage2D;
		}
		else {
			trace("No active camera! You need to initialize your 3D stuff first.");
			return null;
		}
	}*/

	// Stats
	inline public function getLastFrameDuration():Float {
		return this._lastFrameDuration.current;
	}

	inline public function getEvaluateActiveMeshesDuration():Float {
		return this._evaluateActiveMeshesDuration.current;
	}

	inline public function getActiveMeshes():SmartArray<AbstractMesh> {
		return this._activeMeshes;
	}

	inline public function getRenderTargetsDuration():Float {
		return this._renderTargetsDuration.current;
	}

	inline public function getRenderDuration():Float {
		return this._renderDuration.current;
	}

	inline public function getParticlesDuration():Float {
		return this._particlesDuration.current;
	}

	inline public function getSpritesDuration():Float {
		return this._spritesDuration.current;
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

	inline public function _updatePointerPosition(evt:PointerEvent) {		
		this._pointerX = cast evt.x;
		this._pointerY = cast evt.y;
		
		this._unTranslatedPointerX = this._pointerX;
		this._unTranslatedPointerY = this._pointerY;
	}
	
	private function _createUbo() {
		this._sceneUbo = new UniformBuffer(this._engine, null, true);
		this._sceneUbo.addUniform("viewProjection", 16);
		this._sceneUbo.addUniform("view", 16);
	}
	
	private function _createAlternateUbo() {
		this._alternateSceneUbo = new UniformBuffer(this._engine, null, true);
		this._alternateSceneUbo.addUniform("viewProjection", 16);
		this._alternateSceneUbo.addUniform("view", 16);
	}

	// Pointers handling
	
	/**
	 * Use this method to simulate a pointer move on a mesh
	 * The pickResult parameter can be obtained from a scene.pick or scene.pickWithRay
	 */
	public function simulatePointerMove(pickResult:PickingInfo):Scene {
		var evt = new PointerEvent(0, 0, -1, PointerEventTypes.POINTERMOVE);
		
		return this._processPointerMove(pickResult, evt);
	}

	private function _processPointerMove(pickResult:PickingInfo, evt:PointerEvent):Scene {		
		if (pickResult != null && pickResult.hit && pickResult.pickedMesh != null) {
			this.setPointerOverSprite(null);
			
			this.setPointerOverMesh(pickResult.pickedMesh);
			
			// VK TODO:
			/*if (this._pointerOverMesh.actionManager != null && this._pointerOverMesh.actionManager.hasPointerTriggers) {
				if (this._pointerOverMesh.actionManager.hoverCursor) {
					canvas.style.cursor = this._pointerOverMesh.actionManager.hoverCursor;
				} 
				else {
					canvas.style.cursor = this.hoverCursor;
				}
			} 
			else {
				canvas.style.cursor = this.defaultCursor;
			}*/
		} 
		else {
			this.setPointerOverMesh(null);
			// Sprites
			pickResult = this.pickSprite(this._unTranslatedPointerX, this._unTranslatedPointerY, this._spritePredicate, false, this.cameraToUseForPointers);
			
			if (pickResult != null && pickResult.hit && pickResult.pickedSprite != null) {
				this.setPointerOverSprite(pickResult.pickedSprite);
				
				// VK TODO:
				/*if (this._pointerOverSprite.actionManager != null && this._pointerOverSprite.actionManager.hoverCursor != null) {
					canvas.style.cursor = this._pointerOverSprite.actionManager.hoverCursor;
				} 
				else {
					canvas.style.cursor = this.hoverCursor;
				}*/
			} 
			else {
				this.setPointerOverSprite(null);
				// Restore pointer
				
				// VK TODO:
				//canvas.style.cursor = this.defaultCursor;
			}
		}
		
		if (this.onPointerMove != null) {
			this.onPointerMove(evt, pickResult);
		}
		
		if (this.onPointerObservable.hasObservers()) {
			var type = evt.type; // === "mousewheel" || evt.type === "DOMMouseScroll" ? PointerEventTypes.POINTERWHEEL : PointerEventTypes.POINTERMOVE;
			var pi = new PointerInfo(type, evt, pickResult);
			this.onPointerObservable.notifyObservers(pi, type);
		}
		
		return this;            
	}

	/**
	 * Use this method to simulate a pointer down on a mesh
	 * The pickResult parameter can be obtained from a scene.pick or scene.pickWithRay
	 */
	public function simulatePointerDown(pickResult:PickingInfo):Scene {
		var evt = new PointerEvent(0, 0, -1, PointerEventTypes.POINTERDOWN);

		return this._processPointerDown(pickResult, evt);
	}        

	private function _processPointerDown(pickResult:PickingInfo, evt:PointerEvent):Scene {
		if (pickResult != null && pickResult.hit && pickResult.pickedMesh != null) {
			this._pickedDownMesh = pickResult.pickedMesh;
			var actionManager = pickResult.pickedMesh.actionManager;
			if (actionManager != null) {
				if (actionManager.hasPickTriggers) {
					actionManager.processTrigger(ActionManager.OnPickDownTrigger, ActionEvent.CreateNew(pickResult.pickedMesh, evt));
					switch (evt.button) {
						case 0:
							actionManager.processTrigger(ActionManager.OnLeftPickTrigger, ActionEvent.CreateNew(pickResult.pickedMesh, evt));
							
						case 1:
							actionManager.processTrigger(ActionManager.OnCenterPickTrigger, ActionEvent.CreateNew(pickResult.pickedMesh, evt));
							
						case 2:
							actionManager.processTrigger(ActionManager.OnRightPickTrigger, ActionEvent.CreateNew(pickResult.pickedMesh, evt));
							
					}
				}
				
				if (actionManager.hasSpecificTrigger(ActionManager.OnLongPressTrigger)) {
					Tools.delay(function () {
						var pickResult = this.pick(this._unTranslatedPointerX, this._unTranslatedPointerY, function(mesh:AbstractMesh):Bool { return mesh.isPickable && mesh.isVisible && mesh.isReady() && mesh.actionManager != null && mesh.actionManager.hasSpecificTrigger(ActionManager.OnLongPressTrigger) && mesh == this._pickedDownMesh; }, false, this.cameraToUseForPointers);
							
						if (pickResult != null && pickResult.hit && pickResult.pickedMesh != null) {
							if (this._totalPointersPressed != 0 &&
								((Tools.Now() - this._startingPointerTime) > Scene.LongPressDelay) &&
								(Math.abs(this._startingPointerPosition.x - this._pointerX) < Scene.DragMovementThreshold &&
									Math.abs(this._startingPointerPosition.y - this._pointerY) < Scene.DragMovementThreshold)) {
								this._startingPointerTime = 0;
								actionManager.processTrigger(ActionManager.OnLongPressTrigger, ActionEvent.CreateNew(pickResult.pickedMesh, evt));
							}
						}
					}, Scene.LongPressDelay);
				}
			}
		}
		
		if (this.onPointerDown != null) {
			this.onPointerDown(evt, pickResult);
		}
		
		if (this.onPointerObservable.hasObservers()) {
			var type = PointerEventTypes.POINTERDOWN;
			var pi = new PointerInfo(type, evt, pickResult);
			this.onPointerObservable.notifyObservers(pi, type);
		}
		
		return this;
	}

	/**
	 * Use this method to simulate a pointer up on a mesh
	 * The pickResult parameter can be obtained from a scene.pick or scene.pickWithRay
	 */
	public function simulatePointerUp(pickResult:PickingInfo):Scene {
		var evt = new PointerEvent(0, 0, -1, PointerEventTypes.POINTERUP);
		var clickInfo = new ClickInfo();
		clickInfo.singleClick = true;
		
		return this._processPointerUp(pickResult, evt, clickInfo);
	}    

	private function _processPointerUp(pickResult:PickingInfo, evt:PointerEvent, clickInfo:ClickInfo):Scene {            
		if (pickResult != null && pickResult.hit && pickResult.pickedMesh != null) {
			this._pickedUpMesh = pickResult.pickedMesh;
			if (this._pickedDownMesh == this._pickedUpMesh) {
				if (this.onPointerPick != null) {
					this.onPointerPick(evt, pickResult);
				}
				if (clickInfo.singleClick && !clickInfo.ignore && this.onPointerObservable.hasObservers()) {
					var type = PointerEventTypes.POINTERPICK;
					var pi = new PointerInfo(type, evt, pickResult);
					this.onPointerObservable.notifyObservers(pi, type);
				}
			}
			if (pickResult.pickedMesh.actionManager != null) {
				if (clickInfo.ignore) {
					pickResult.pickedMesh.actionManager.processTrigger(ActionManager.OnPickUpTrigger, ActionEvent.CreateNew(pickResult.pickedMesh, evt));
				}
				if (!clickInfo.hasSwiped && !clickInfo.ignore && clickInfo.singleClick) {
					pickResult.pickedMesh.actionManager.processTrigger(ActionManager.OnPickTrigger, ActionEvent.CreateNew(pickResult.pickedMesh, evt));
				}
				if (clickInfo.doubleClick && !clickInfo.ignore && pickResult.pickedMesh.actionManager.hasSpecificTrigger(ActionManager.OnDoublePickTrigger)) {
					pickResult.pickedMesh.actionManager.processTrigger(ActionManager.OnDoublePickTrigger, ActionEvent.CreateNew(pickResult.pickedMesh, evt));
				}
			}
		}
		if (this._pickedDownMesh != null &&
			this._pickedDownMesh.actionManager != null &&
			this._pickedDownMesh.actionManager.hasSpecificTrigger(ActionManager.OnPickOutTrigger) &&
			this._pickedDownMesh != this._pickedUpMesh) {
			this._pickedDownMesh.actionManager.processTrigger(ActionManager.OnPickOutTrigger, ActionEvent.CreateNew(this._pickedDownMesh, evt));
		}
		
		if (this.onPointerUp != null) {
			this.onPointerUp(evt, pickResult);
		}
		
		if (this.onPointerObservable.hasObservers()) {
			if (!clickInfo.ignore) {
				if (!clickInfo.hasSwiped) {
					if (clickInfo.singleClick && this.onPointerObservable.hasSpecificMask(PointerEventTypes.POINTERTAP)) {
						var type = PointerEventTypes.POINTERTAP;
						var pi = new PointerInfo(type, evt, pickResult);
						this.onPointerObservable.notifyObservers(pi, type);
					}
					if (clickInfo.doubleClick && this.onPointerObservable.hasSpecificMask(PointerEventTypes.POINTERDOUBLETAP)) {
						var type = PointerEventTypes.POINTERDOUBLETAP;
						var pi = new PointerInfo(type, evt, pickResult);
						this.onPointerObservable.notifyObservers(pi, type);
					}
				}
			}
			else {
				var type = PointerEventTypes.POINTERUP;
				var pi = new PointerInfo(type, evt, pickResult);
				this.onPointerObservable.notifyObservers(pi, type);
			}
		}
		
		return this;
	}

	/**
	* Attach events to the canvas (To handle actionManagers triggers and raise onPointerMove, onPointerDown and onPointerUp
	* @param attachUp defines if you want to attach events to pointerup
	* @param attachDown defines if you want to attach events to pointerdown
	* @param attachMove defines if you want to attach events to pointermove
	*/
	public function attachControl(attachUp:Bool = true, attachDown:Bool = true, attachMove:Bool = true) {		
		this._initActionManager = function(act:ActionManager, clickInfo:ClickInfo):ActionManager {
			if (!this._meshPickProceed) {
				var pickResult = this.pick(this._unTranslatedPointerX, this._unTranslatedPointerY, this.pointerDownPredicate, false, this.cameraToUseForPointers);
				this._currentPickResult = pickResult;
				if (pickResult != null) {
					act = (pickResult.hit && pickResult.pickedMesh != null) ? pickResult.pickedMesh.actionManager : null;
				}
				this._meshPickProceed = true;
			}
			return act;
		};
		
		this._delayedSimpleClick = function(btn:Int, clickInfo:ClickInfo, cb:ClickInfo->PickingInfo->Void) {
			// double click delay is over and that no double click has been raised since, or the 2 consecutive keys pressed are different
			if ((Tools.Now() - this._previousStartingPointerTime > Scene.DoubleClickDelay && !this._doubleClickOccured) || btn != this._previousButtonPressed) {
				this._doubleClickOccured = false;
				clickInfo.singleClick = true;
				clickInfo.ignore = false;
				cb(clickInfo, this._currentPickResult);
			}
		};
		
		this._initClickEvent = function(obs1:Observable<PointerInfoPre>, obs2:Observable<PointerInfo>, evt:Dynamic, cb:ClickInfo->PickingInfo->Void) {
				var clickInfo = new ClickInfo();
				this._currentPickResult = null;
				var act:ActionManager = null;
				
				var checkPicking:Bool = obs1.hasSpecificMask(PointerEventTypes.POINTERPICK) || obs2.hasSpecificMask(PointerEventTypes.POINTERPICK)
								|| obs1.hasSpecificMask(PointerEventTypes.POINTERTAP) || obs2.hasSpecificMask(PointerEventTypes.POINTERTAP)
								|| obs1.hasSpecificMask(PointerEventTypes.POINTERDOUBLETAP) || obs2.hasSpecificMask(PointerEventTypes.POINTERDOUBLETAP);
				if (!checkPicking && ActionManager.HasPickTriggers) {
					act = this._initActionManager(act, clickInfo);
					if (act != null) {
						checkPicking = act.hasPickTriggers;
					}
				}
				if (checkPicking) {
					var btn = evt.button;
					clickInfo.hasSwiped = Math.abs(this._startingPointerPosition.x - this._pointerX) > Scene.DragMovementThreshold ||
										  Math.abs(this._startingPointerPosition.y - this._pointerY) > Scene.DragMovementThreshold;
					
					if (!clickInfo.hasSwiped) {
						var checkSingleClickImmediately = !Scene.ExclusiveDoubleClickMode;
						
						if (!checkSingleClickImmediately) {
							checkSingleClickImmediately = !obs1.hasSpecificMask(PointerEventTypes.POINTERDOUBLETAP) &&
														  !obs2.hasSpecificMask(PointerEventTypes.POINTERDOUBLETAP);
							
							if (checkSingleClickImmediately && !ActionManager.HasSpecificTrigger(ActionManager.OnDoublePickTrigger)) {
								act = this._initActionManager(act, clickInfo);
								if (act != null) {
									checkSingleClickImmediately = !act.hasSpecificTrigger(ActionManager.OnDoublePickTrigger);
								}
							}
						}
						
						if (checkSingleClickImmediately) {
							// single click detected if double click delay is over or two different successive keys pressed without exclusive double click or no double click required
							if (Tools.Now() - this._previousStartingPointerTime > Scene.DoubleClickDelay || btn != this._previousButtonPressed) {
								clickInfo.singleClick = true;
								cb(clickInfo, this._currentPickResult);
							}
						}
						// at least one double click is required to be check and exclusive double click is enabled
						else {
							// wait that no double click has been raised during the double click delay
							this._previousDelayedSimpleClickTimeout = this._delayedSimpleClickTimeout;
							// VK TODO:
							//this._delayedSimpleClickTimeout = Timer.delay(this._delayedSimpleClick(btn, clickInfo, cb), Scene.DoubleClickDelay);
						}
						
						var checkDoubleClick = obs1.hasSpecificMask(PointerEventTypes.POINTERDOUBLETAP) ||
											   obs2.hasSpecificMask(PointerEventTypes.POINTERDOUBLETAP);
						if (!checkDoubleClick && ActionManager.HasSpecificTrigger(ActionManager.OnDoublePickTrigger)){
							act = this._initActionManager(act, clickInfo);
							if (act != null) {
								checkDoubleClick = act.hasSpecificTrigger(ActionManager.OnDoublePickTrigger);
							}
						}
						if (checkDoubleClick) {
							// two successive keys pressed are equal, double click delay is not over and double click has not just occurred
							if (btn == this._previousButtonPressed &&
								Tools.Now() - this._previousStartingPointerTime < Scene.DoubleClickDelay &&
								!this._doubleClickOccured
							) {
								// pointer has not moved for 2 clicks, it's a double click
								if (!clickInfo.hasSwiped &&
									Math.abs(this._previousStartingPointerPosition.x - this._startingPointerPosition.x) < Scene.DragMovementThreshold &&
									Math.abs(this._previousStartingPointerPosition.y - this._startingPointerPosition.y) < Scene.DragMovementThreshold) {
									this._previousStartingPointerTime = 0;
									this._doubleClickOccured = true;
									clickInfo.doubleClick = true;
									clickInfo.ignore = false;
									// VK TODO:
									//if (Scene.ExclusiveDoubleClickMode && this._previousDelayedSimpleClickTimeout && this._previousDelayedSimpleClickTimeout.clearTimeout) {
										//this._previousDelayedSimpleClickTimeout.clearTimeout();
									//}
									//this._previousDelayedSimpleClickTimeout = this._delayedSimpleClickTimeout;
									//cb(clickInfo, this._currentPickResult);
								}
								// if the two successive clicks are too far, it's just two simple clicks
								else {
									this._doubleClickOccured = false;
									this._previousStartingPointerTime = this._startingPointerTime;
									this._previousStartingPointerPosition.x = this._startingPointerPosition.x;
									this._previousStartingPointerPosition.y = this._startingPointerPosition.y;
									this._previousButtonPressed = btn;
									this._previousHasSwiped = clickInfo.hasSwiped;
									// VK TODO:
									/*if (Scene.ExclusiveDoubleClickMode){
										if (this._previousDelayedSimpleClickTimeout && this._previousDelayedSimpleClickTimeout.clearTimeout) {
											this._previousDelayedSimpleClickTimeout.clearTimeout();
										}
										this._previousDelayedSimpleClickTimeout = this._delayedSimpleClickTimeout;
										cb(clickInfo, this._previousPickResult);
									}
									else {
										cb(clickInfo, this._currentPickResult);
									}*/
								}
							}
							// just the first click of the double has been raised
							else {
								this._doubleClickOccured = false;
								this._previousStartingPointerTime = this._startingPointerTime;
								this._previousStartingPointerPosition.x = this._startingPointerPosition.x;
								this._previousStartingPointerPosition.y = this._startingPointerPosition.y;
								this._previousButtonPressed = btn;
								this._previousHasSwiped = clickInfo.hasSwiped;
							}
						}
					}
				}
				clickInfo.ignore = true;
				cb(clickInfo, this._currentPickResult);
		};	
		
		this._spritePredicate = function(sprite:Sprite):Bool {			
			return sprite.isPickable && sprite.actionManager != null && sprite.actionManager.hasPointerTriggers;
		};
		 
		this._onPointerMove = function(evt:PointerEvent) {
			this._updatePointerPosition(evt);
			
			// PreObservable support
            if (this.onPrePointerObservable.hasObservers()) {
                var type = evt.type;
                var pi = new PointerInfoPre(type, evt, this._unTranslatedPointerX, this._unTranslatedPointerY);
                this.onPrePointerObservable.notifyObservers(pi, type);
                if (pi.skipOnPointerObservable) {
                    return;
                }
            }
			
			if (this.cameraToUseForPointers == null && this.activeCamera == null) {
                return;
            }
			
			//var canvas = this._engine.getRenderingCanvas();
			
			if (this.pointerMovePredicate == null) {
				this.pointerMovePredicate = function(mesh:AbstractMesh):Bool { 
					return mesh.isPickable && mesh.isVisible && mesh.isReady() && (mesh.enablePointerMoveEvents || this.constantlyUpdateMeshUnderPointer || mesh.actionManager != null && mesh.actionManager != null); 					
				};
			}
			
			// Meshes
			var pickResult:PickingInfo = this.pick(
				this._unTranslatedPointerX, 
				this._unTranslatedPointerY, 
				this.pointerMovePredicate,
				false, 
				this.cameraToUseForPointers
			);
				
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
				pickResult = this.pickSprite(this._unTranslatedPointerX, this._unTranslatedPointerY, this._spritePredicate, false, this.cameraToUseForPointers);
				
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
				this.onPointerMove(evt, pickResult);
			}
			
			if (this.onPointerObservable.hasObservers()) {
				var type = evt.type;// PointerEventTypes.POINTERMOVE;
				var pi = new PointerInfo(type, evt, pickResult);
				this.onPointerObservable.notifyObservers(pi, type);
			}
		};
		
		this._onPointerDown = function(evt:PointerEvent) {
            this._totalPointersPressed++;
            this._pickedDownMesh = null;
            this._meshPickProceed = false;
			
			this._updatePointerPosition(evt);
			
			// PreObservable support
            if (this.onPrePointerObservable.hasObservers()) {
                var type = evt.type;
                var pi = new PointerInfoPre(type, evt, this._unTranslatedPointerX, this._unTranslatedPointerY);
                this.onPrePointerObservable.notifyObservers(pi, type);
                if (pi.skipOnPointerObservable) {
                    return;
                }
            }
			
			if (this.cameraToUseForPointers == null && this.activeCamera == null) {
                return;
            }
			
			this._startingPointerPosition.x = this._pointerX;
			this._startingPointerPosition.y = this._pointerY;
			this._startingPointerTime = Tools.Now();
			
			if (this.pointerDownPredicate == null) {
				this.pointerDownPredicate = function(mesh:AbstractMesh):Bool {
					return mesh.isPickable && mesh.isVisible && mesh.isReady();
				};
			}
			
			// Meshes
			this._pickedDownMesh = null;			
			var pickResult:PickingInfo = this.pick(this._unTranslatedPointerX, this._unTranslatedPointerY, this.pointerDownPredicate, false, this.cameraToUseForPointers);
			
			this._processPointerDown(pickResult, evt);
			
			if (pickResult.hit && pickResult.pickedMesh != null) {				
				if (pickResult.pickedMesh.actionManager != null) {
					this._pickedDownMesh = pickResult.pickedMesh;
					
					if (pickResult.pickedMesh.actionManager.hasPickTriggers) {
						switch (evt.button) {
							case 0:
								pickResult.pickedMesh.actionManager.processTrigger(ActionManager.OnLeftPickTrigger, ActionEvent.CreateNew(pickResult.pickedMesh));
								
							case 1:
								pickResult.pickedMesh.actionManager.processTrigger(ActionManager.OnCenterPickTrigger, ActionEvent.CreateNew(pickResult.pickedMesh));
								
							case 2:
								pickResult.pickedMesh.actionManager.processTrigger(ActionManager.OnRightPickTrigger, ActionEvent.CreateNew(pickResult.pickedMesh));
								
							default:	// mobile
								pickResult.pickedMesh.actionManager.processTrigger(ActionManager.OnLeftPickTrigger, ActionEvent.CreateNew(pickResult.pickedMesh));	
						}
						
						if (pickResult.pickedMesh.actionManager != null) {
							pickResult.pickedMesh.actionManager.processTrigger(ActionManager.OnPickTrigger, ActionEvent.CreateNew(pickResult.pickedMesh));
						}
					}
					
					if (pickResult.pickedMesh.actionManager != null && pickResult.pickedMesh.actionManager.hasSpecificTrigger(ActionManager.OnLongPressTrigger)) {
						Tools.delay(function () {
							var pickResult = this.pick(this._unTranslatedPointerX, this._unTranslatedPointerY,
								function(mesh:AbstractMesh):Bool { return mesh.isPickable && mesh.isVisible && mesh.isReady() && mesh.actionManager != null && mesh.actionManager.hasSpecificTrigger(ActionManager.OnLongPressTrigger); },
								false, this.cameraToUseForPointers);
								
							if (pickResult.hit && pickResult.pickedMesh != null) {
								if (pickResult.pickedMesh.actionManager != null) {
									if (this._startingPointerTime != 0 && ((Tools.Now() - this._startingPointerTime) > Scene.LongPressDelay) && (Math.abs(this._startingPointerPosition.x - this._pointerX) < Scene.DragMovementThreshold && Math.abs(this._startingPointerPosition.y - this._pointerY) < Scene.DragMovementThreshold)) {
										this._startingPointerTime = 0;
										pickResult.pickedMesh.actionManager.processTrigger(ActionManager.OnLongPressTrigger, ActionEvent.CreateNew(pickResult.pickedMesh));
									}
								}
							}
						}, Scene.LongPressDelay);
					}
				}
			}
			
			if (this.onPointerDown != null) {
				this.onPointerDown(evt, pickResult);
			}
			
			if (this.onPointerObservable.hasObservers()) {
				var type = PointerEventTypes.POINTERDOWN;
				var pi = new PointerInfo(type, evt, pickResult);
				this.onPointerObservable.notifyObservers(pi, type);
			}
			
			// Sprites
			this._pickedDownSprite = null;
			if (this.spriteManagers.length > 0) {
				pickResult = this.pickSprite(this._unTranslatedPointerX, this._unTranslatedPointerY, this._spritePredicate, false, this.cameraToUseForPointers);
				
				if (pickResult.hit && pickResult.pickedSprite != null) {
					if (pickResult.pickedSprite.actionManager != null) {
						this._pickedDownSprite = pickResult.pickedSprite;
						switch (evt.button) {
							case 0:
								pickResult.pickedSprite.actionManager.processTrigger(ActionManager.OnLeftPickTrigger, ActionEvent.CreateNewFromSprite(pickResult.pickedSprite, this));
								
							case 1:
								pickResult.pickedSprite.actionManager.processTrigger(ActionManager.OnCenterPickTrigger, ActionEvent.CreateNewFromSprite(pickResult.pickedSprite, this));
								
							case 2:
								pickResult.pickedSprite.actionManager.processTrigger(ActionManager.OnRightPickTrigger, ActionEvent.CreateNewFromSprite(pickResult.pickedSprite, this));
								
							default:	// mobile
								pickResult.pickedSprite.actionManager.processTrigger(ActionManager.OnLeftPickTrigger, ActionEvent.CreateNewFromSprite(pickResult.pickedSprite, this));
							
						}
						
						if (pickResult.pickedSprite.actionManager != null) {
							pickResult.pickedSprite.actionManager.processTrigger(ActionManager.OnPickTrigger, ActionEvent.CreateNewFromSprite(pickResult.pickedSprite, this));
						}
					}
				}
			}
		};
		
		this._onPointerUp = function(evt:PointerEvent) {
			this._updatePointerPosition(evt);
			
			// PreObservable support
            if (this.onPrePointerObservable.hasObservers()) {
                var type = evt.type;// PointerEventTypes.POINTERUP;
                var pi = new PointerInfoPre(type, evt, this._unTranslatedPointerX, this._unTranslatedPointerY);
                this.onPrePointerObservable.notifyObservers(pi, type);
                if (pi.skipOnPointerObservable) {
                    return;
                }
            }
			
			if (this.cameraToUseForPointers == null && this.activeCamera == null) {
                return;
            }
			
			if (this.pointerUpPredicate == null) {
				this.pointerUpPredicate = function(mesh:AbstractMesh):Bool {
					return mesh.isPickable && mesh.isVisible && mesh.isReady();
				};
			}
			
			// Meshes
			var pickResult:PickingInfo = this.pick(this._unTranslatedPointerX, this._unTranslatedPointerY, this.pointerUpPredicate, false, this.cameraToUseForPointers);
			
			if (pickResult.hit && pickResult.pickedMesh != null) {
				if (this._pickedDownMesh != null && pickResult.pickedMesh == this._pickedDownMesh) {
					if (this.onPointerPick != null) {
						this.onPointerPick(evt, pickResult);
					}
					if (this.onPointerObservable.hasObservers()) {
						var type = PointerEventTypes.POINTERPICK;
						var pi = new PointerInfo(type, evt, pickResult);
						this.onPointerObservable.notifyObservers(pi, type);
					}
				}
				if (pickResult.pickedMesh.actionManager != null) {
					pickResult.pickedMesh.actionManager.processTrigger(ActionManager.OnPickUpTrigger, ActionEvent.CreateNew(pickResult.pickedMesh, evt.button));
					if (pickResult.pickedMesh.actionManager != null) {
						if (Math.abs(this._startingPointerPosition.x - this._pointerX) < Scene.DragMovementThreshold && Math.abs(this._startingPointerPosition.y - this._pointerY) < Scene.DragMovementThreshold) {
							pickResult.pickedMesh.actionManager.processTrigger(ActionManager.OnPickTrigger, ActionEvent.CreateNew(pickResult.pickedMesh, evt.button));
						}
					}
				}
			}
			if (this._pickedDownMesh != null && this._pickedDownMesh.actionManager != null && this._pickedDownMesh != pickResult.pickedMesh) {
				this._pickedDownMesh.actionManager.processTrigger(ActionManager.OnPickOutTrigger, ActionEvent.CreateNew(this._pickedDownMesh));
			}
			
			if (this.onPointerUp != null) {
				this.onPointerUp(evt, pickResult);
			}
			
			if (this.onPointerObservable.hasObservers()) {
				var type = PointerEventTypes.POINTERUP;
				var pi = new PointerInfo(type, evt, pickResult);
				this.onPointerObservable.notifyObservers(pi, type);
			}
			
			this._startingPointerTime = 0;
			
			// Sprites
			if (this.spriteManagers.length > 0) {
				pickResult = this.pickSprite(this._unTranslatedPointerX, this._unTranslatedPointerY, this._spritePredicate, false, this.cameraToUseForPointers);
				
				if (pickResult.hit && pickResult.pickedSprite != null) {
					if (pickResult.pickedSprite.actionManager != null) {
						pickResult.pickedSprite.actionManager.processTrigger(ActionManager.OnPickUpTrigger, ActionEvent.CreateNewFromSprite(pickResult.pickedSprite, this));
						
						if (pickResult.pickedSprite.actionManager != null) {
							if (Math.abs(this._startingPointerPosition.x - this._pointerX) < Scene.DragMovementThreshold && Math.abs(this._startingPointerPosition.y - this._pointerY) < Scene.DragMovementThreshold) {
								pickResult.pickedSprite.actionManager.processTrigger(ActionManager.OnPickTrigger, ActionEvent.CreateNewFromSprite(pickResult.pickedSprite, this));
							}
						}
					}
				}
				if (this._pickedDownSprite != null && this._pickedDownSprite.actionManager != null && this._pickedDownSprite != pickResult.pickedSprite) {
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
		
		this.getEngine().touchDown.push(this._onPointerDown);
		this.getEngine().touchUp.push(this._onPointerUp);
		this.getEngine().touchMove.push(this._onPointerMove);
		
		this.getEngine().mouseDown.push(this._onPointerDown);
		this.getEngine().mouseUp.push(this._onPointerUp);
		this.getEngine().mouseMove.push(this._onPointerMove);
		
		this.getEngine().keyDown.push(this._onKeyDown);
		this.getEngine().keyUp.push(this._onKeyUp);		
	}

	public function detachControl() {
		this.getEngine().touchDown.remove(this._onPointerDown);
		this.getEngine().touchUp.remove(this._onPointerUp);
		this.getEngine().touchMove.remove(this._onPointerMove);
		
		this.getEngine().mouseDown.remove(this._onPointerDown);
		this.getEngine().mouseUp.remove(this._onPointerUp);
		this.getEngine().mouseMove.remove(this._onPointerMove);
		
		this.getEngine().keyDown.remove(this._onKeyDown);
		this.getEngine().keyUp.remove(this._onKeyUp);		
	}

	// Ready
	public function isReady():Bool {
		if (this._pendingData.length > 0) {
			return false;
		}
		
		// Geometries
		for (index in 0...this._geometries.length) {
			var geometry = this._geometries[index];
			
			if (geometry.delayLoadState == Engine.DELAYLOADSTATE_LOADING) {
				return false;
			}
		}
		
		// Meshes
		for (index in 0...this.meshes.length) {
			var mesh = this.meshes[index];
			
			if (!mesh.isEnabled()) {
				continue;
			}
			
			if (mesh.subMeshes == null || mesh.subMeshes.length == 0) {
				continue;
			}
			
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
		this._cachedEffect = null;
        this._cachedVisibility = 0;
    }
	
	public function registerBeforeRender(func:Null<Scene>->Null<EventState>->Void) {
		this.onBeforeRenderObservable.add(func);
	}

	public function unregisterBeforeRender(func:Null<Scene>->Null<EventState>->Void) {
		this.onBeforeRenderObservable.removeCallback(func);
	}
	
	public function registerAfterRender(func:Null<Scene>->Null<EventState>->Void) {
		this.onAfterRenderObservable.add(func);
    }
	
    public function unregisterAfterRender(func:Null<Scene>->Null<EventState>->Void) {
        this.onAfterRenderObservable.removeCallback(func);
    }
	
	var execFunc:Null<Scene>->Null<EventState>->Void;
	private function _executeOnceBeforeRender(func:Void->Void) {
		execFunc = function(_, _) {
			func();
			Tools.delay(function() {
				this.unregisterBeforeRender(execFunc);
			}, 0);
		};
		this.registerBeforeRender(execFunc);
	}

	/**
	 * The provided function will run before render once and will be disposed afterwards.
	 * A timeout delay can be provided so that the function will be executed in N ms.
	 * The timeout is using the browser's native setTimeout so time percision cannot be guaranteed.
	 * @param func The function to be executed.
	 * @param timeout optional delay in ms
	 */
	public function executeOnceBeforeRender(func:Void->Void, timeout:Int = -1) {
		if (timeout != -1) {
			Tools.delay(function() {
				this._executeOnceBeforeRender(func);
			}, timeout);
		} 
		else {
			this._executeOnceBeforeRender(func);
		}
	}

	public function _addPendingData(data:Dynamic) {
		this._pendingData.push(data);
	}

	public function _removePendingData(data:Dynamic) {
		var wasLoading = this.isLoading;
        var index = this._pendingData.indexOf(data);
		  
		if (index != -1) {
			this._pendingData.splice(index, 1);
		}
		
        if (wasLoading && !this.isLoading) {
            this.onDataLoadedObservable.notifyObservers(this);
        }
	}

	public function getWaitingItemsCount():Int {
		return this._pendingData.length;
	}
	
	public var isLoading(get, never):Bool;
	inline private function get_isLoading():Bool {
		return this._pendingData.length > 0;
	}

	/**
	 * Registers a function to be executed when the scene is ready.
	 * @param {Function} func - the function to be executed.
	 */
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
		if (from > to && speedRatio > 0) {
			speedRatio *= -1;
		}
		
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

	/**
     * Begin a new animation on a given node
     * @param {BABYLON.Node} node defines the root node where the animation will take place
     * @param {BABYLON.Animation[]} defines the list of animations to start
     * @param {number} from defines the initial value
     * @param {number} to defines the final value
     * @param {boolean} loop defines if you want animation to loop (off by default)
     * @param {number} speedRatio defines the speed ratio to apply to all animations
     * @param onAnimationEnd defines the callback to call when an animation ends (will be called once per node)
     * @returns the list of created animatables
     */
	public function beginDirectAnimation(target:Dynamic, animations:Array<Animation>, from:Int, to:Int, loop:Bool = false, ?speedRatio:Float = 1.0, ?onAnimationEnd:Void->Void):Animatable {
		var animatable = new Animatable(this, target, from, to, loop, speedRatio, onAnimationEnd, animations);
		
		return animatable;
	}
	
	/**
     * Begin a new animation on a given node and its hierarchy
     * @param {BABYLON.Node} node defines the root node where the animation will take place
     * @param {boolean} directDescendantsOnly if true only direct descendants will be used, if false direct and also indirect (children of children, an so on in a recursive manner) descendants will be used.
     * @param {BABYLON.Animation[]} defines the list of animations to start
     * @param {number} from defines the initial value
     * @param {number} to defines the final value
     * @param {boolean} loop defines if you want animation to loop (off by default)
     * @param {number} speedRatio defines the speed ratio to apply to all animations
     * @param onAnimationEnd defines the callback to call when an animation ends (will be called once per node)
     * @returns the list of animatables created for all nodes
     */
    public function beginDirectHierarchyAnimation(target:Node, directDescendantsOnly:Bool, animations:Array<Animation>, from:Int, to:Int, loop:Bool = false, ?speedRatio:Int, ?onAnimationEnd:Void->Void):Array<Animatable> {
        var children = target.getDescendants(directDescendantsOnly);
        var result:Array<Animatable> = [];
        for (child in children) {
            result.push(this.beginDirectAnimation(child, animations, from, to, loop, speedRatio, onAnimationEnd));
        }
		
        return result;
    }

	public function getAnimatableByTarget(target:Dynamic):Animatable {
		for (index in 0...this._activeAnimatables.length) {
			if (this._activeAnimatables[index].target == target) {
				return this._activeAnimatables[index];
			}
		}
		
		return null;
	}
	
	public var animatables(get, never):Array<Animatable>;
	private function get_animatables():Array<Animatable> {
		return this._activeAnimatables;
	}

	/**
	 * Will stop the animation of the given target
	 * @param target - the target 
	 * @see beginAnimation 
	 */
	public function stopAnimation(target:Dynamic, ?animationName:String) {
		var animatable = this.getAnimatableByTarget(target);
		
		if (animatable != null) {
			animatable.stop(animationName);
		}
	}
	
	private function _animate() {
		if (!this.animationsEnabled || this._activeAnimatables.length == 0) {
			return;
		}
		
		// Getting time
        var now = Tools.Now();
        if (this._animationTimeLast == Math.NEGATIVE_INFINITY) {
			if (this._pendingData.length > 0) {
                return;
            }
			this._animationTimeLast = now;
		}
		
		var deltaTime:Float = this.useConstantAnimationDeltaTime ? 16.0 : (now - this._animationTimeLast) * this.animationTimeScale;
        this._animationTime += deltaTime;
        this._animationTimeLast = now;
		for (index in 0...this._activeAnimatables.length) {
			// VK TODO: inspect this, last item in array is null sometimes
			if (this._activeAnimatables[index] != null) {
				this._activeAnimatables[index]._animate(this._animationTime);
			}
		}
	}

	// Matrix
	inline public function _switchToAlternateCameraConfiguration(active:Bool) {
		this._useAlternateCameraConfiguration = active;
	}
	
	inline public function getViewMatrix():Matrix {
		return this._useAlternateCameraConfiguration ? this._alternateViewMatrix : this._viewMatrix;
	}

	inline public function getProjectionMatrix():Matrix {
		return this._useAlternateCameraConfiguration ? this._alternateProjectionMatrix : this._projectionMatrix;
	}

	inline public function getTransformMatrix():Matrix {
		return this._useAlternateCameraConfiguration ? this._alternateTransformMatrix : this._transformMatrix;
	}

	public function setTransformMatrix(view:Matrix, projection:Matrix) {
		if (this._viewUpdateFlag == view.updateFlag && this._projectionUpdateFlag == projection.updateFlag) {
			return;
		}
		
		this._viewUpdateFlag = view.updateFlag;
		this._projectionUpdateFlag = projection.updateFlag;
		this._viewMatrix = view;
		this._projectionMatrix = projection;
		
		this._viewMatrix.multiplyToRef(this._projectionMatrix, this._transformMatrix);
		
		// Update frustum
		if (this._frustumPlanes == null) {
			this._frustumPlanes = Frustum.GetPlanes(this._transformMatrix);
		} 
		else {
			Frustum.GetPlanesToRef(this._transformMatrix, this._frustumPlanes);
		}
		
		if (this.activeCamera != null && this.activeCamera._alternateCamera != null) {
            var otherCamera = this.activeCamera._alternateCamera;
            otherCamera.getViewMatrix().multiplyToRef(otherCamera.getProjectionMatrix(null), Tmp.matrix[0]);
            Frustum.GetRightPlaneToRef(Tmp.matrix[0], this._frustumPlanes[3]); // Replace right plane by second camera right plane
        }
		
		if (this._sceneUbo.useUbo) {
			this._sceneUbo.updateMatrix("viewProjection", this._transformMatrix);
			this._sceneUbo.updateMatrix("view", this._viewMatrix);
			this._sceneUbo.update();
		}
	}
	
	public function _setAlternateTransformMatrix(view:Matrix, projection:Matrix) {
		if (this._alternateViewUpdateFlag == view.updateFlag && this._alternateProjectionUpdateFlag == projection.updateFlag) {
			return;
		}
		
		this._alternateViewUpdateFlag = view.updateFlag;
		this._alternateProjectionUpdateFlag = projection.updateFlag;
		this._alternateViewMatrix = view;
		this._alternateProjectionMatrix = projection;
		
		if (this._alternateTransformMatrix == null) {
			this._alternateTransformMatrix = Matrix.Zero();
		}
		
		this._alternateViewMatrix.multiplyToRef(this._alternateProjectionMatrix, this._alternateTransformMatrix);
		
		if (this._alternateSceneUbo == null) {
			this._createAlternateUbo();
		}
		
		if (this._alternateSceneUbo.useUbo) {
			this._alternateSceneUbo.updateMatrix("viewProjection", this._alternateTransformMatrix);
			this._alternateSceneUbo.updateMatrix("view", this._alternateViewMatrix);
			this._alternateSceneUbo.update();
		}
	}
	
	public function getSceneUniformBuffer():UniformBuffer {
		return this._useAlternateCameraConfiguration ? this._alternateSceneUbo : this._sceneUbo;
	}

	// Methods
	
	public function getUniqueId():Int {
		var result = Scene._uniqueIdCounter;
		Scene._uniqueIdCounter++;
		return result;
	}
	
	public function addMesh(newMesh:AbstractMesh) {
		var position = this.meshes.push(newMesh);
		
		//notify the collision coordinator
		if (this.collisionCoordinator != null) {
			this.collisionCoordinator.onMeshAdded(newMesh);
		}
		
		this.onNewMeshAddedObservable.notifyObservers(newMesh);
	}

	public function removeMesh(toRemove:AbstractMesh):Int {
		var index = this.meshes.indexOf(toRemove);
		if (index != -1) {
			// Remove from the scene if mesh found 
			this.meshes.splice(index, 1);
		}
		
		this.onMeshRemovedObservable.notifyObservers(toRemove);
		
		return index;
	}
	
	public function addTransformNode(newTransformNode:TransformNode) {
		this.transformNodes.push(newTransformNode);
		
		this.onNewTransformNodeAddedObservable.notifyObservers(newTransformNode);
	}

	public function removeTransformNode(toRemove:TransformNode):Int {
		var index = this.transformNodes.indexOf(toRemove);
		if (index != -1) {
			// Remove from the scene if found
			this.transformNodes.splice(index, 1);
		}
		
		this.onTransformNodeRemovedObservable.notifyObservers(toRemove);
		
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
	
	public function removeMorphTargetManager(toRemove:MorphTargetManager):Int {
		var index = this.morphTargetManagers.indexOf(toRemove);
		if (index != -1) {
			// Remove from the scene if found 
			this.morphTargetManagers.splice(index, 1);
		}
		
		return index;
	}

	public function removeLight(toRemove:Light):Int {
		var index = this.lights.indexOf(toRemove);
		if (index != -1) {
			// Remove from the scene if mesh found 
			this.lights.splice(index, 1);
			this.sortLightsByPriority();
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
		var index2 = this.activeCameras.indexOf(toRemove);
		if (index2 != -1) {
			// Remove from the scene if found
			this.activeCameras.splice(index2, 1);
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
		this.lights.push(newLight);
		this.sortLightsByPriority();
		
		// Add light to all meshes (To support if the light is removed and then readded)
        for (mesh in this.meshes) {
            if (mesh._lightSources.indexOf(newLight) == -1) {
                mesh._lightSources.push(newLight);
                mesh._resyncLightSources();
            }
        }
		
		this.onNewLightAddedObservable.notifyObservers(newLight);
	}
	
	public function sortLightsByPriority() {
		if(this.requireLightSorting) {
			this.lights.sort(Light.compareLightsPriority);
		}
	}

	public function addCamera(newCamera:Camera) {
		var position = this.cameras.push(newCamera);
		this.onNewCameraAddedObservable.notifyObservers(newCamera);
	}
	
	/**
	 * Swith the active camera of the scene
	 * @param {Camera} newCamera - the new camera
	 * @param {boolean} control - attachControl for the camera (default true)
	 */
	public function switchActiveCamera(newCamera:Camera, control:Bool = true) {				
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
	 * get an animation group using its name
	 * @param {string} the material's name
	 * @return {BABYLON.AnimationGroup|null} the animation group or null if none found.
	 */
	public function getAnimationGroupByName(name:String):AnimationGroup {
		for (index in 0...this.animationGroups.length) {
			if (this.animationGroups[index].name == name) {
				return this.animationGroups[index];
			}
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
	
	/**
	 * get a material using its id
	 * @param {string} the multiMaterials's ID
	 * @return {BABYLON.MultiMaterial|null} the multiMaterial or null if none found.
	 */
	public function getMultiMaterialByID(id:String):MultiMaterial {
		for (index in 0...this.multiMaterials.length) {
			if (this.multiMaterials[index].id == id) {
				return this.multiMaterials[index];
			}
		}
		
		return null;
	}

	/**
	 * get a material using its name
	 * @param {string} the multiMaterials's name
	 * @return {BABYLON.MultiMaterial|null} the multiMaterial or null if none found.
	 */
	public function getMultiMaterialByName(name:String):MultiMaterial {
		for (index in 0...this.multiMaterials.length) {
			if (this.multiMaterials[index].name == name) {
				return this.multiMaterials[index];
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
	
	public function getLensFlareSystemByID(id:String):LensFlareSystem {
		for (index in 0...this.lensFlareSystems.length) {
			if (this.lensFlareSystems[index].id == id) {
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
	public function getParticleSystemByID(id:String):IParticleSystem {
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
		if (this.collisionCoordinator != null) {
			this.collisionCoordinator.onGeometryAdded(geometry);
		}
		
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
			if (this.collisionCoordinator != null) {
				this.collisionCoordinator.onGeometryDeleted(geometry);
			}
			
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
	
	public function getMorphTargetManagerById(id:Int):MorphTargetManager {
		for (index in 0...this.morphTargetManagers.length) {
			if (this.morphTargetManagers[index].uniqueId == id) {
				return this.morphTargetManagers[index];
			}
		}
		
		return null;
	}

	inline public function isActiveMesh(mesh:Mesh):Bool {
		return (this._activeMeshes.indexOf(mesh) != -1);
	}
	
	/**
	 * Return a the first highlight layer of the scene with a given name.
	 * @param name The name of the highlight layer to look for.
	 * @return The highlight layer if found otherwise null.
	 */
	public function getHighlightLayerByName(name:String):HighlightLayer {
		for (index in 0...this.highlightLayers.length) {
			if (this.highlightLayers[index].name == name) {
				return this.highlightLayers[index];
			}
		}
		
		return null;
	}
	
	/**
	 * Return a unique id as a string which can serve as an identifier for the scene
	 */
	public var uid(get, never):String;
	private function get_uid():String {
		if (this._uid == null) {
			this._uid = Tools.uuid();
		}
		
		return this._uid;
	}

	/**
	 * Add an externaly attached data from its key.
	 * This method call will fail and return false, if such key already exists.
	 * If you don't care and just want to get the data no matter what, use the more convenient getOrAddExternalDataWithFactory() method.
	 * @param key the unique key that identifies the data
	 * @param data the data object to associate to the key for this Engine instance
	 * @return true if no such key were already present and the data was added successfully, false otherwise
	 */
	inline public function addExternalData<T>(key:String, data:T):Bool {
		return this._externalData.add(key, data);
	}

	/**
	 * Get an externaly attached data from its key
	 * @param key the unique key that identifies the data
	 * @return the associated data, if present (can be null), or undefined if not present
	 */
	inline public function getExternalData<T>(key:String):T {
		return this._externalData.get(key);
	}

	/**
	 * Get an externaly attached data from its key, create it using a factory if it's not already present
	 * @param key the unique key that identifies the data
	 * @param factory the factory that will be called to create the instance if and only if it doesn't exists
	 * @return the associated data, can be null if the factory returned null.
	 */
	inline public function getOrAddExternalDataWithFactory<T>(key:String, factory:String->T):T {
		if (this._externalData == null) {
			this._externalData = new StringDictionary<Dynamic>();
		}
		return this._externalData.getOrAddWithFactory(key, factory);
	}

	/**
	 * Remove an externaly attached data from the Engine instance
	 * @param key the unique key that identifies the data
	 * @return true if the data was successfully removed, false if it doesn't exist
	 */
	inline public function removeExternalData(key:String):Bool {
		return this._externalData.remove(key);
	}

	static var _eSMMaterial:Material;
	private function _evaluateSubMesh(subMesh:SubMesh, mesh:AbstractMesh) {
		if (this.dispatchAllSubMeshesOfActiveMeshes || mesh.alwaysSelectAsActiveMesh || mesh.subMeshes.length == 1 || subMesh.isInFrustum(this._frustumPlanes)) {
			if (mesh.showSubMeshesBoundingBox) {
				var boundingInfo = subMesh.getBoundingInfo();
				if (boundingInfo != null) {
					this.getBoundingBoxRenderer().renderList.push(boundingInfo.boundingBox);
				}
			}
			
			var material = subMesh.getMaterial();
			if (material != null) {
				// Render targets
				if (material.getRenderTargetTextures != null) {
					if (this._processedMaterials.indexOf(material) == -1) {
						this._processedMaterials.push(material);
						
						this._renderTargets.concatSmartArrayWithNoDuplicate(material.getRenderTargetTextures());
					}
				}
				
				// Dispatch
				this._activeIndices.addCount(subMesh.indexCount, false);
				this._renderingManager.dispatch(subMesh, mesh, material);
			}
		}
	}
	
	public function _isInIntermediateRendering():Bool {
        return this._intermediateRendering;
    }
	
	private var _activeMeshCandidateProvider:IActiveMeshCandidateProvider;
    public function setActiveMeshCandidateProvider(provider:IActiveMeshCandidateProvider) {
        this._activeMeshCandidateProvider = provider;
    }
    public function getActiveMeshCandidateProvider():IActiveMeshCandidateProvider {
        return this._activeMeshCandidateProvider;
    }
	
	private var _activeMeshesFrozen:Bool = false;

	/**
	 * Use this function to stop evaluating active meshes. The current list will be keep alive between frames
	 */
	public function freezeActiveMeshes():Scene {
		this._evaluateActiveMeshes();
		this._activeMeshesFrozen = true;
		return this;
	}
	
	/**
	 * Use this function to restart evaluating active meshes on every frame
	 */
	public function unfreezeActiveMeshes() {
		this._activeMeshesFrozen = false;
		return this;
	}

	private function _evaluateActiveMeshes() {
		if (this._activeMeshesFrozen && this._activeMeshes.length > 0) {
            return;
        }
		
        if (this.activeCamera == null) {
            return;
        }
		
        this.onBeforeActiveMeshesEvaluationObservable.notifyObservers(this);
		
		this.activeCamera._activeMeshes.reset();
		this._activeMeshes.reset();
		this._renderingManager.reset();
		this._processedMaterials.reset();
		this._activeParticleSystems.reset();
		this._activeSkeletons.reset();
		this._softwareSkinnedMeshes.reset();
		if (this._boundingBoxRenderer != null) {
			this._boundingBoxRenderer.reset();
		}
		
		// Meshes
		var meshes:Array<AbstractMesh> = [];
		var len:Int = 0;
		
		var checkIsEnabled = true;
		
        // Determine mesh candidates
        if (this._activeMeshCandidateProvider != null) {
            // Use _activeMeshCandidateProvider
            meshes = this._activeMeshCandidateProvider.getMeshes(this);
            checkIsEnabled = this._activeMeshCandidateProvider.checksIsEnabled == false;
            if (meshes != null) {
                len = meshes.length;
            } 
			else {
                len = 0;
            }
        } 
		else if (this._selectionOctree != null) {
            // Octree
			var selection = this._selectionOctree.select(this._frustumPlanes);
			meshes = selection.data;
			len = selection.length;
		} 
		else {
			// Full scene traversal
			len = this.meshes.length;
			meshes = this.meshes;
		}
		
		// Check each mesh
		var mesh:Mesh = null;
		var meshLOD:Mesh = null;
		for (meshIndex in 0...len) {
			mesh = cast meshes[meshIndex];
			
			if (mesh.isBlocked) {
				continue;
			}
			
			this._totalVertices.addCount(mesh.getTotalVertices(), false);
			
			if (!mesh.isReady() || (checkIsEnabled && !mesh.isEnabled())) {
				continue;
			}
			
			mesh.computeWorldMatrix();
			
			// Intersections
			if (mesh.actionManager != null && mesh.actionManager.hasSpecificTriggers([ActionManager.OnIntersectionEnterTrigger, ActionManager.OnIntersectionExitTrigger])) {
				this._meshesForIntersections.pushNoDuplicate(mesh);
			}
			
			// Switch to current LOD
			meshLOD = cast mesh.getLOD(this.activeCamera);
			
			if (meshLOD == null) {
				continue;
			}
			
			mesh._preActivate();
			
			if (mesh.alwaysSelectAsActiveMesh || mesh.isVisible && mesh.visibility > 0 && ((mesh.layerMask & this.activeCamera.layerMask) != 0) && mesh.isInFrustum(this._frustumPlanes)) {
				this._activeMeshes.push(mesh);
				this.activeCamera._activeMeshes.push(mesh);
				
				mesh._activate(this._renderId);
				if (meshLOD != mesh) {
                    meshLOD._activate(this._renderId);
                }
				
				this._activeMesh(mesh, meshLOD);
			}
		}
		
		// Particle systems
		this._particlesDuration.beginMonitoring();
		var beforeParticlesDate = Tools.Now();
		if (this.particlesEnabled) {
			for (particleIndex in 0...this.particleSystems.length) {
				var particleSystem = this.particleSystems[particleIndex];
				
				if (!particleSystem.isStarted() || particleSystem.emitter == null) {
					continue;
				}
				
				var emitter = particleSystem.emitter;
				if (emitter.position == null || emitter.isEnabled()) {
					this._activeParticleSystems.push(particleSystem);
					particleSystem.animate();
					this._renderingManager.dispatchParticles(particleSystem);
				}
			}
		}
		this._particlesDuration.endMonitoring(false);
	}

	private function _activeMesh(sourceMesh:AbstractMesh, mesh:AbstractMesh) {
		if (this.skeletonsEnabled && mesh.skeleton != null) {
			if (this._activeSkeletons.pushNoDuplicate(mesh.skeleton)) {
				mesh.skeleton.prepare();
			}
			
			if (!mesh.computeBonesUsingShaders) {
                this._softwareSkinnedMeshes.pushNoDuplicate(cast mesh);
            }
		}
		
		if (sourceMesh.showBoundingBox || this.forceShowBoundingBoxes) {
			var boundingInfo = sourceMesh.getBoundingInfo();
			
			this.getBoundingBoxRenderer().renderList.push(boundingInfo.boundingBox);
		}
        
		if (mesh != null && mesh.subMeshes != null && mesh.subMeshes.length > 0) {
			// Submeshes Octrees
			var len:Int = -1;
			var subMeshes:Array<SubMesh> = null;
			
			if (mesh.useOctreeForRenderingSelection && mesh._submeshesOctree != null) {
				var intersections = mesh._submeshesOctree.select(this._frustumPlanes);
				
				len = intersections.length;
				subMeshes = cast intersections.data;
			} 
			else {
				subMeshes = mesh.subMeshes;
				len = subMeshes.length;
			}
			
			for (subIndex in 0...len) {
				this._evaluateSubMesh(subMeshes[subIndex], mesh);
			}
		}
	}

	public function updateTransformMatrix(force:Bool = false) {
		if (this.activeCamera == null) {
			return;
		}
		this.setTransformMatrix(this.activeCamera.getViewMatrix(), this.activeCamera.getProjectionMatrix(force));
	}
	
	public function updateAlternateTransformMatrix(alternateCamera:Camera) {
		this._setAlternateTransformMatrix(alternateCamera.getViewMatrix(), alternateCamera.getProjectionMatrix(false));
	}

	private function _renderForCamera(camera:Camera) {
		if (camera != null && camera._skipRendering) {
			return;
		}
		
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
		this.activeCamera.update();
		this.updateTransformMatrix();
		
		if (camera._alternateCamera != null) {
			this.updateAlternateTransformMatrix(camera._alternateCamera);
			this._alternateRendering = true;
		}
		
		this.onBeforeCameraRenderObservable.notifyObservers(this.activeCamera);
		
		// Meshes
		this._evaluateActiveMeshes();
		
		// Software skinning
        for (softwareSkinnedMeshIndex in 0...this._softwareSkinnedMeshes.length) {
            var mesh:Mesh = cast this._softwareSkinnedMeshes.data[softwareSkinnedMeshIndex];
			
            mesh.applySkeleton(mesh.skeleton);
        }
		
		// Render targets
		this.OnBeforeRenderTargetsRenderObservable.notifyObservers(this);
		var needsRestoreFrameBuffer = false;
		
		var beforeRenderTargetDate = Tools.Now();
		
		if (camera.customRenderTargets != null && camera.customRenderTargets.length > 0) {
			this._renderTargets.concatArrayWithNoDuplicate(camera.customRenderTargets);
		}
		
		if (this.renderTargetsEnabled && this._renderTargets.length > 0) {
			this._intermediateRendering = true;
			//Tools.StartPerformanceCounter("Render targets", this._renderTargets.length > 0);
			for (renderIndex in 0...this._renderTargets.length) {
				var renderTarget:RenderTargetTexture = this._renderTargets.data[renderIndex];
				if (renderTarget._shouldRender()) {
					this._renderId++;
					var hasSpecialRenderTargetCamera:Bool = renderTarget.activeCamera != null && renderTarget.activeCamera != this.activeCamera;
					renderTarget.render(hasSpecialRenderTargetCamera);
				}
			}
			
			//Tools.EndPerformanceCounter("Render targets", this._renderTargets.length > 0);
			
			this._intermediateRendering = false;
			this._renderId++;
			
            needsRestoreFrameBuffer = true;  // Restore back buffer
        }
		
		// Render HighlightLayer Texture
		var stencilState = this._engine.getStencilBuffer();
		var renderhighlights = false;
		if (this.renderTargetsEnabled && this.highlightLayers != null && this.highlightLayers.length > 0) {
			this._intermediateRendering = true;
			for (i in 0...this.highlightLayers.length) {
				var highlightLayer:HighlightLayer = this.highlightLayers[i];
				
				if (highlightLayer.shouldRender() &&
					(highlightLayer.camera == null ||
						(highlightLayer.camera.cameraRigMode == Camera.RIG_MODE_NONE && camera == highlightLayer.camera) ||
						(highlightLayer.camera.cameraRigMode != Camera.RIG_MODE_NONE && highlightLayer.camera.rigCameras.indexOf(camera) > -1))) {
					
					renderhighlights = true;
					
					var renderTarget:RenderTargetTexture = cast highlightLayer._mainTexture;
					if (renderTarget._shouldRender()) {
						this._renderId++;
						renderTarget.render(false);
						needsRestoreFrameBuffer = true;
					}
				}
			}
			
			this._intermediateRendering = false;
			this._renderId++;
		}
		
		if (needsRestoreFrameBuffer) {
			engine.restoreDefaultFramebuffer(); // Restore back buffer
		}
		
		this.OnAfterRenderTargetsRenderObservable.notifyObservers(this);
		
		// Prepare Frame
		this.postProcessManager._prepareFrame();
		
		// Backgrounds
		if (this.layers.length > 0) {
			engine.setDepthBuffer(false);
			var layer:Layer = null;
			for (layerIndex in 0...this.layers.length) {
				layer = this.layers[layerIndex];
				if (layer.isBackground && ((layer.layerMask & this.activeCamera.layerMask) != 0)) {
					layer.render();
				}
			}
			engine.setDepthBuffer(true);
		}
		
		// Activate  HighlightLayer stencil
		if (renderhighlights) {
			this._engine.setStencilBuffer(true);
		}
		
		// Render
		this.onBeforeDrawPhaseObservable.notifyObservers(this);
		this._renderingManager.render(null, null, true, true);
		this.onAfterDrawPhaseObservable.notifyObservers(this);
		
		// Restore HighlightLayer stencil
		if (renderhighlights) {
			engine.setStencilBuffer(stencilState);
		}
		
		// Bounding boxes
		if (this._boundingBoxRenderer != null) {
			this._boundingBoxRenderer.render();
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
				if (!layer.isBackground && ((layer.layerMask & this.activeCamera.layerMask) != 0)) {
					layer.render();
				}
			}
			engine.setDepthBuffer(true);
		}
		
		// Highlight Layer
		if (renderhighlights) {
			engine.setDepthBuffer(false);
			for (i in 0...this.highlightLayers.length) {
				if (this.highlightLayers[i].shouldRender()) {
					this.highlightLayers[i].render();
				}
			}
			engine.setDepthBuffer(true);
		}
		
		// Finalize frame
		this.postProcessManager._finalizeFrame(camera.isIntermediate);
		
		// Reset some special arrays
		this._renderTargets.reset();
		
		this._alternateRendering = false;
		
		this.onAfterCameraRenderObservable.notifyObservers(this.activeCamera);
		
		//Tools.EndPerformanceCounter("Rendering camera " + this.activeCamera.name);
	}

	private function _processSubCameras(camera:Camera) {
		if (camera.cameraRigMode == Camera.RIG_MODE_NONE) {
			this._renderForCamera(camera);
			return;
		}
		
		// Update camera
		if (this.activeCamera != null) {
			this.activeCamera.update();
		}
		
		// rig cameras
        for (index in 0...camera.rigCameras.length) {
            this._renderForCamera(camera.rigCameras[index]);
        }
		
		this.activeCamera = camera;
		this.setTransformMatrix(this.activeCamera.getViewMatrix(), this.activeCamera.getProjectionMatrix(false));
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
		if (this.isDisposed) {
			return;
		}
		
		this._activeParticles.fetchNewFrame();
		this._totalVertices.fetchNewFrame();
		this._activeIndices.fetchNewFrame();
		this._activeBones.fetchNewFrame();
		this._meshesForIntersections.reset();
		this.resetCachedMaterial();
		
		this.onBeforeAnimationsObservable.notifyObservers(this);
		
		// Actions
		if (this.actionManager != null) {
			this.actionManager.processTrigger(ActionManager.OnEveryFrameTrigger, null);
		}
		
		//Simplification Queue
		if (!this.simplificationQueue.running) {
			this.simplificationQueue.executeNext();
		}		
		
		if (this._engine.isDeterministicLockStep()) {
			var deltaTime = Math.max(Scene.MinDeltaTime, Math.min(this._engine.getDeltaTime(), Scene.MaxDeltaTime)) + this._timeAccumulator;
			
			var defaultFPS = (60.0 / 1000.0);
			
			var defaultFrameTime = 1000 / 60; // frame time in MS
			if (this._physicsEngine != null) {
				defaultFrameTime = this._physicsEngine.getTimeStep() / 1000; //timestep in physics engine is in seconds
			}
			var stepsTaken = 0;
			
			var maxSubSteps = this._engine.getLockstepMaxSteps();
			
			var internalSteps = Math.floor(deltaTime / (1000 * defaultFPS));
			internalSteps = Std.int(Math.min(internalSteps, maxSubSteps));
			
			do {
				this.onBeforeStepObservable.notifyObservers(this);
				
				// Animations
				this._animationRatio = defaultFrameTime * defaultFPS;
				this._animate();
				this.onAfterAnimationsObservable.notifyObservers(this);
				
				// Physics
				if (this._physicsEngine != null) {
					this.onBeforePhysicsObservable.notifyObservers(this);
					// VK TODO:
					//this._physicsEngine._step(defaultFPS);
					this.onAfterPhysicsObservable.notifyObservers(this);
				}
				
				this.onAfterStepObservable.notifyObservers(this);
				this._currentStepId++;
				
				if ((internalSteps > 1) && (stepsTaken != internalSteps - 1)) {
					this._evaluateActiveMeshes();
				}
				
				stepsTaken++;
				deltaTime -= defaultFrameTime;
			} 
			while (deltaTime > 0 && stepsTaken < maxSubSteps);
			
			this._timeAccumulator = deltaTime;
		}
		else {
			// Animations
			var deltaTime = Math.max(Scene.MinDeltaTime, Math.min(this._engine.getDeltaTime(), Scene.MaxDeltaTime));
			this._animationRatio = deltaTime * (60.0 / 1000.0);
			this._animate();
			this.onAfterAnimationsObservable.notifyObservers(this);
			
			// Physics
			if (this._physicsEngine != null) {
				this.onBeforePhysicsObservable.notifyObservers(this);
				// VK TODO:
				//this._physicsEngine._step(deltaTime / 1000.0);
				this.onAfterPhysicsObservable.notifyObservers(this);
			}
		}
		
		// Before render
		this.onBeforeRenderObservable.notifyObservers(this);
		
		// Customs render targets
		this.OnBeforeRenderTargetsRenderObservable.notifyObservers(this);
		var engine = this.getEngine();
		var currentActiveCamera = this.activeCamera;
		if (this.renderTargetsEnabled) {
			//Tools.StartPerformanceCounter("Custom render targets", this.customRenderTargets.length > 0);
			this._intermediateRendering = true;
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
			
			this._intermediateRendering = false;
			this._renderId++;
		}
		
		// Restore back buffer
		if (this.customRenderTargets.length > 0) {
			engine.restoreDefaultFramebuffer();
		}
		
		this.OnAfterRenderTargetsRenderObservable.notifyObservers(this);
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
		if (this.autoClearDepthAndStencil || this.autoClear) {
			this._engine.clear(this.clearColor, this.autoClear || this.forceWireframe || this.forcePointsCloud, this.autoClearDepthAndStencil, this.autoClearDepthAndStencil);
		}
		
		// Shadows
		if (this.shadowsEnabled) {
			for (lightIndex in 0...this.lights.length) {
				var light = this.lights[lightIndex];
				var shadowGenerator = light.getShadowGenerator();
				
				if (light.isEnabled() && light.shadowEnabled && shadowGenerator != null) {
					var shadowMap = shadowGenerator.getShadowMap();
					if (this.textures.indexOf(shadowMap) != -1) {
						this._renderTargets.push(shadowMap);
					}
				}
			}
		}
		
		// Depth renderer
		if (this._depthRenderer != null) {
			this._renderTargets.push(this._depthRenderer.getDepthMap());
		}
		
		// Geometry renderer
		if (this._geometryBufferRenderer != null) {
			this._renderTargets.push(this._geometryBufferRenderer.getGBuffer());
		}
		
		// RenderPipeline
		if (this._postProcessRenderPipelineManager != null) {
			this._postProcessRenderPipelineManager.update();
		}
		
		// Multi-cameras?
		if (this.activeCameras.length > 0) {
			for (cameraIndex in 0...this.activeCameras.length) {
				if (cameraIndex > 0) {
                    this._engine.clear(null, false, true, true);
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
			this.afterRender(_, _);
		}*/
		
		this.onAfterRenderObservable.notifyObservers(this);
		
		// Cleaning
		for (index in 0...this._toBeDisposed.length) {
            untyped this._toBeDisposed.data[index].dispose();
			this._toBeDisposed.data[index] = null;
			//this._toBeDisposed.data.splice(index, 1);
		}
		
		this._toBeDisposed.reset();
		
		if (this.dumpNextRenderTargets) {
			this.dumpNextRenderTargets = false;
		}
		
		//Tools.EndPerformanceCounter("Scene rendering");
		/*this._lastFrameDuration.endMonitoring();
		this._totalMeshesCounter.addCount(this.meshes.length, true);
		this._totalLightsCounter.addCount(this.lights.length, true);
		this._totalMaterialsCounter.addCount(this.materials.length, true);
		this._totalTexturesCounter.addCount(this.textures.length, true);*/
		this._activeBones.addCount(0, true);
		this._activeIndices.addCount(0, true);
		this._activeParticles.addCount(0, true);
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
	
	public function enableGeometryBufferRenderer(ratio:Float = 1):GeometryBufferRenderer {
		if (this._geometryBufferRenderer != null) {
			return this._geometryBufferRenderer;
		}
		
		this._geometryBufferRenderer = new GeometryBufferRenderer(this, ratio);
		if (!this._geometryBufferRenderer.isSupported) {
			this._geometryBufferRenderer = null;
		}
		
		return this._geometryBufferRenderer;
	}

	public function disableGeometryBufferRenderer() {
		if (this._geometryBufferRenderer == null) {
			return;
		}
		
		this._geometryBufferRenderer.dispose();
		this._geometryBufferRenderer = null;
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
		this.morphTargetManagers = [];
		
		this.importedMeshesFiles = [];
		
		this.resetCachedMaterial();
		
		if (this._depthRenderer != null) {
			this._depthRenderer.dispose();
		}
		
		// Smart arrays            
		if (this.activeCamera != null) {
			this.activeCamera._activeMeshes.dispose();
			this.activeCamera = null;
		}
		this._activeMeshes.dispose();
		this._renderingManager.dispose();
		this._processedMaterials.dispose();
		this._activeParticleSystems.dispose();
		this._activeSkeletons.dispose();
		this._softwareSkinnedMeshes.dispose();
		this._renderTargets.dispose();
		
		if (this._boundingBoxRenderer != null) {
			this._boundingBoxRenderer.dispose();
		}
		this._meshesForIntersections.dispose();
		this._toBeDisposed.dispose();
		
		// Debug layer
		/*if (this._debugLayer != null) {
			this._debugLayer.hide();
		}*/
		
		// Events
		this.onDisposeObservable.notifyObservers(this);
		
		this.onDisposeObservable.clear();
		this.onBeforeRenderObservable.clear();
		this.onAfterRenderObservable.clear();
		this.OnBeforeRenderTargetsRenderObservable.clear();
		this.OnAfterRenderTargetsRenderObservable.clear();
		this.onAfterStepObservable.clear();
		this.onBeforeStepObservable.clear();
		this.onBeforeActiveMeshesEvaluationObservable.clear();
		this.onAfterActiveMeshesEvaluationObservable.clear();
		this.onBeforeParticlesRenderingObservable.clear();
		this.onAfterParticlesRenderingObservable.clear();
		this.onBeforeSpritesRenderingObservable.clear();
		this.onAfterSpritesRenderingObservable.clear();
		this.onBeforeDrawPhaseObservable.clear();
		this.onAfterDrawPhaseObservable.clear();
		this.onBeforePhysicsObservable.clear();
		this.onAfterPhysicsObservable.clear();
		this.onBeforeAnimationsObservable.clear();
		this.onAfterAnimationsObservable.clear();
		this.onDataLoadedObservable.clear();
		
		this.detachControl();
		
		// Release sounds & sounds tracks
		/*if (AudioEngine) {
			this.disposeSounds();
		}*/
		
		// Release animation groups
		while (this.animationGroups.length > 0) {
			this.animationGroups[0].dispose();
			this.animationGroups.shift();
		}
		
		// Release lights
		while (this.lights.length > 0) {
			this.lights[0].dispose();
			this.lights.shift();
		}
		
		// Release meshes
		while (this.meshes.length > 0) {
			this.meshes[0].dispose(true);
			this.meshes.shift();
		}
		
		// Release cameras
		while (this.cameras.length > 0) {
			this.cameras[0].dispose();
			this.cameras.shift();
		}
		
		// Release materials
		if (this.defaultMaterial != null) {
            this.defaultMaterial.dispose();
        }
        while (this.multiMaterials.length > 0) {
            this.multiMaterials[0].dispose();
			this.multiMaterials.shift();
        }
		while (this.materials.length > 0) {
			this.materials[0].dispose();
			this.materials.shift();
		}
		
		// Release particles
		while (this.particleSystems.length > 0) {
			this.particleSystems[0].dispose();
			this.particleSystems.shift();
		}
		
		// Release sprites
		while (this.spriteManagers.length > 0) {
			this.spriteManagers[0].dispose();
			this.spriteManagers.shift();
		}
		
		// Release postProcesses
        while (this.postProcesses.length > 0) {
            this.postProcesses[0].dispose();
			this.postProcesses.shift();
        }
		
		// Release layers
		while (this.layers.length > 0) {
			this.layers[0].dispose();
			this.layers.shift();
		}
		while (this.highlightLayers.length > 0) {
			this.highlightLayers[0].dispose();
			this.highlightLayers.shift();
		}
		
		// Release textures
		while (this.textures.length > 0) {
			this.textures[0].dispose();
			this.textures.shift();
		}
		
		// Release UBO
		this._sceneUbo.dispose();
		
		// Post-processes
		this.postProcessManager.dispose();
		
		if (this._postProcessRenderPipelineManager != null) {
            this._postProcessRenderPipelineManager.dispose();
        }
		
		// Physics
		if (this._physicsEngine != null) {
			this.disablePhysicsEngine();
		}
		
		// Remove from engine
		var index = this._engine.scenes.indexOf(this);
		
		if (index > -1) {
			this._engine.scenes.splice(index, 1);
		}
		
		this._engine.wipeCaches(true);
		this._isDisposed = true;
		
		this.defaultMaterial = null;
        this.multiMaterials = null;
        this.materials = null;
	}
	
	public var isDisposed(get, never):Bool;
	private function get_isDisposed():Bool {
		return this._isDisposed;
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
	
	public function createOrUpdateSelectionOctree(maxCapacity:Int = 64, maxDepth:Int = 2):Octree<AbstractMesh> {
		if (this._selectionOctree == null) {
			this._selectionOctree = new Octree<AbstractMesh>(Octree.CreationFuncForMeshes, maxCapacity, maxDepth);
		}
		
		var worldExtends = this.getWorldExtends();
		
		// Update octree
		this._selectionOctree.update(worldExtends.min, worldExtends.max, this.meshes);
		
		return this._selectionOctree;
	}

	// Picking
	public function createPickingRay(x:Float, y:Float, world:Matrix, camera:Camera = null, cameraViewSpace:Bool = false):Ray {
		var result = Ray.Zero();
		
		this.createPickingRayToRef(x, y, world, result, camera, cameraViewSpace);
		
		return result;
	}
		
	public function createPickingRayToRef(x:Float, y:Float, world:Matrix, result:Ray, camera:Camera = null, cameraViewSpace:Bool = false):Scene {
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
		
		result.update(x, y, viewport.width, viewport.height, world != null ? world : Matrix.Identity(), cameraViewSpace ? Matrix.Identity() : camera.getViewMatrix(), camera.getProjectionMatrix(false));
		return this;
	}
	
	public function createPickingRayInCameraSpace(x:Float, y:Float, ?camera:Camera):Ray {
		var result = Ray.Zero();
		
		this.createPickingRayInCameraSpaceToRef(x, y, result, camera);
		
		return result;
	}
	
	public function createPickingRayInCameraSpaceToRef(x:Float, y:Float, result:Ray, ?camera:Camera):Scene {
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
		
		result.update(x, y, viewport.width, viewport.height, identity, identity, camera.getProjectionMatrix(false));
		return this;
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
	
	private function _internalMultiPick(rayFunction:Matrix->Ray, predicate:AbstractMesh->Bool):Array<PickingInfo> {
		var pickingInfos:Array<PickingInfo> = [];
		
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
			
			var result = mesh.intersects(ray, false);
			if (result ==null || !result.hit) {
				continue;
			}
			
			pickingInfos.push(result);
		}
		
		return pickingInfos;
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
	
	private var _tempPickingRay:Ray = Ray.Zero();

	/** Launch a ray to try to pick a mesh in the scene
	 * @param x position on screen
	 * @param y position on screen
	 * @param predicate Predicate function used to determine eligible meshes. Can be set to null. In this case, a mesh must be enabled, visible and with isPickable set to true
	 * @param fastCheck Launch a fast check only using the bounding boxes. Can be set to null.
	 * @param camera to use for computing the picking ray. Can be set to null. In this case, the scene.activeCamera will be used
	 */
	inline public function pick(x:Float, y:Float, ?predicate:AbstractMesh->Bool, fastCheck:Bool = false, ?camera:Camera):PickingInfo {
		return this._internalPick(function(world:Matrix):Ray {
			this.createPickingRayToRef(x, y, world, this._tempPickingRay, camera);
			return _tempPickingRay;
		}, predicate, fastCheck);
	}
	
	/** Launch a ray to try to pick a sprite in the scene
	 * @param x position on screen
	 * @param y position on screen
	 * @param predicate Predicate function used to determine eligible sprites. Can be set to null. In this case, a sprite must have isPickable set to true
	 * @param fastCheck Launch a fast check only using the bounding boxes. Can be set to null.
	 * @param camera camera to use for computing the picking ray. Can be set to null. In this case, the scene.activeCamera will be used
	 */
	inline public function pickSprite(x:Float, y:Float, ?predicate:Sprite->Bool, fastCheck:Bool = false, ?camera:Camera):PickingInfo {
		this.createPickingRayInCameraSpaceToRef(x, y, this._tempPickingRay, camera);
		
		return this._internalPickSprites(this._tempPickingRay, predicate, fastCheck, camera);
	}
	
	private var _cachedRayForTransform:Ray;

	/** Use the given ray to pick a mesh in the scene
	 * @param ray The ray to use to pick meshes
	 * @param predicate Predicate function used to determine eligible sprites. Can be set to null. In this case, a sprite must have isPickable set to true
	 * @param fastCheck Launch a fast check only using the bounding boxes. Can be set to null.
	 */
	public function pickWithRay(ray:Ray, predicate:AbstractMesh->Bool, fastCheck:Bool = false):PickingInfo {
		return this._internalPick(function(world:Matrix):Ray {
			if (this._pickWithRayInverseMatrix == null) {
				this._pickWithRayInverseMatrix = Matrix.Identity();
			}
			world.invertToRef(this._pickWithRayInverseMatrix);
			
			if (this._cachedRayForTransform == null) {
                this._cachedRayForTransform = new Ray(Vector3.Zero(), Vector3.Zero());
            }
            
            Ray.TransformToRef(ray, this._pickWithRayInverseMatrix, this._cachedRayForTransform);
            return this._cachedRayForTransform;
		}, cast predicate, fastCheck);
	}
	
	/**
	 * Launch a ray to try to pick a mesh in the scene
	 * @param x X position on screen
	 * @param y Y position on screen
	 * @param predicate Predicate function used to determine eligible meshes. Can be set to null. In this case, a mesh must be enabled, visible and with isPickable set to true
	 * @param camera camera to use for computing the picking ray. Can be set to null. In this case, the scene.activeCamera will be used
	 */
	public function multiPick(x:Float, y:Float, ?predicate:AbstractMesh->Bool, ?camera:Camera):Array<PickingInfo> {
		return this._internalMultiPick(function(world:Matrix):Ray {
			return this.createPickingRay(x, y, world, camera);
		}, predicate);
	}

	/**
     * Launch a ray to try to pick a mesh in the scene
     * @param ray Ray to use
     * @param predicate Predicate function used to determine eligible meshes. Can be set to null. In this case, a mesh must be enabled, visible and with isPickable set to true
     */
	public function multiPickWithRay(ray:Ray, predicate:AbstractMesh->Bool):Array<PickingInfo> {
		return this._internalMultiPick(function(world:Matrix):Ray {
			if (this._pickWithRayInverseMatrix == null) {
				this._pickWithRayInverseMatrix = Matrix.Identity();
			}
			world.invertToRef(this._pickWithRayInverseMatrix);
			
			if (this._cachedRayForTransform == null) {
                this._cachedRayForTransform = new Ray(Vector3.Zero(), Vector3.Zero());
            }
            
            Ray.TransformToRef(ray, this._pickWithRayInverseMatrix, this._cachedRayForTransform);
            return this._cachedRayForTransform;
		}, predicate);
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
			// VK TODO:
			//mesh._physicImpostor = PhysicsEngine.NoImpostor;
			this._physicsEngine._unregisterMesh(mesh);
		}
	}
	
	// Misc.
	public function _rebuildGeometries() {
        for (geometry in this._geometries) {
            geometry._rebuild();
        }
		
		for (mesh in this.meshes) {
            mesh._rebuild();
        }
		
		if (this.postProcessManager != null) {
            this.postProcessManager._rebuild();
        }
		
		for (layer in this.layers) {
            layer._rebuild();
        }
		
		for (highlightLayer in this.highlightLayers) {
            highlightLayer._rebuild();
        }
		
        if (this._boundingBoxRenderer != null) {
            this._boundingBoxRenderer._rebuild();
        }
		
        for (system in this.particleSystems) {
            system.rebuild();
        }
		
        if (this._postProcessRenderPipelineManager != null) {
            this._postProcessRenderPipelineManager._rebuild();
        }
    }
	
	public function _rebuildTextures() {
        for (texture in this.textures) {
            texture._rebuild();
        }
    }
 
	public function createDefaultCameraOrLight(createArcRotateCamera:Bool = false, replace:Bool = false, attachCameraControls:Bool = false) {
		// Dispose existing camera or light in replace mode.
		if (replace) {
			if (this.activeCamera != null) {
				this.activeCamera.dispose();
				this.activeCamera = null;
			}
			
			if (this.lights != null) {
				for (i in 0...this.lights.length) {
					this.lights[i].dispose();
				}
			}
		}
		
		// Light
		if (this.lights.length == 0) {
			new HemisphericLight("default light", Vector3.Up(), this);
		}
		
		// Camera
		if (this.activeCamera == null) {
			var worldExtends = this.getWorldExtends();
			var worldSize = worldExtends.max.subtract(worldExtends.min);
			var worldCenter = worldExtends.min.add(worldSize.scale(0.5));
			
			var camera:TargetCamera;
			var radius = worldSize.length() * 1.5;
			if (createArcRotateCamera) {
				var arcRotateCamera = new ArcRotateCamera("default camera", -(Math.PI / 2), Math.PI / 2, radius, worldCenter, this);
				arcRotateCamera.lowerRadiusLimit = radius * 0.01;
				arcRotateCamera.wheelPrecision = 100 / radius;
				camera = arcRotateCamera;
			}
			else {
				var freeCamera = new FreeCamera("default camera", new Vector3(worldCenter.x, worldCenter.y, -radius), this);
				freeCamera.setTarget(cast (worldCenter, Vector3));
				camera = freeCamera;
			}
			camera.minZ = radius * 0.01;
			camera.maxZ = radius * 1000;
			camera.speed = radius * 0.2;
			this.activeCamera = camera;
			
			if (attachCameraControls) {
				camera.attachControl();
			}
		}
	}
	
	public function createDefaultSkybox(?environmentTexture:BaseTexture, pbr:Bool = false, scale:Float = 1000, blur:Float = 0):Mesh {
		if (environmentTexture != null) {
			this.environmentTexture = environmentTexture;
		}
		
		if (this.environmentTexture == null) {
			Tools.Warn("Can not create default skybox without environment texture.");
			return null;
		}
		
		// Skybox
		var hdrSkybox = Mesh.CreateBox("hdrSkyBox", scale, this);
		if (pbr) {
			var hdrSkyboxMaterial = new PBRMaterial("skyBox", this);
			hdrSkyboxMaterial.backFaceCulling = false;
			hdrSkyboxMaterial.reflectionTexture = this.environmentTexture.clone();
			hdrSkyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
			hdrSkyboxMaterial.microSurface = 1.0 - blur;
			hdrSkyboxMaterial.disableLighting = true;
			hdrSkyboxMaterial.twoSidedLighting = true;
			hdrSkybox.infiniteDistance = true;
			hdrSkybox.material = hdrSkyboxMaterial;
		}
		else {
			var skyboxMaterial = new StandardMaterial("skyBox", this);
			skyboxMaterial.backFaceCulling = false;
			skyboxMaterial.reflectionTexture = this.environmentTexture.clone();
			skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
			skyboxMaterial.disableLighting = true;
			hdrSkybox.infiniteDistance = true;
			hdrSkybox.material = skyboxMaterial;
		}
		
		return hdrSkybox;
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
	
	/**
	 * Overrides the default sort function applied in the renderging group to prepare the meshes.
	 * This allowed control for front to back rendering or reversly depending of the special needs.
	 * 
	 * @param renderingGroupId The rendering group id corresponding to its index
	 * @param opaqueSortCompareFn The opaque queue comparison function use to sort.
	 * @param alphaTestSortCompareFn The alpha test queue comparison function use to sort.
	 * @param transparentSortCompareFn The transparent queue comparison function use to sort.
	 */
	public function setRenderingOrder(renderingGroupId:Int,
		opaqueSortCompareFn:SubMesh->SubMesh->Int = null,
		alphaTestSortCompareFn:SubMesh->SubMesh->Int = null,
		transparentSortCompareFn:SubMesh->SubMesh->Int = null) {
		this._renderingManager.setRenderingOrder(renderingGroupId,
                opaqueSortCompareFn,
                alphaTestSortCompareFn,
                transparentSortCompareFn);
	}
	
	/**
	 * Specifies whether or not the stencil and depth buffer are cleared between two rendering groups.
	 *
	 * @param renderingGroupId The rendering group id corresponding to its index
	 * @param autoClearDepthStencil Automatically clears depth and stencil between groups if true.
	 * @param depth Automatically clears depth between groups if true and autoClear is true.
	 * @param stencil Automatically clears stencil between groups if true and autoClear is true.
	 */
	public function setRenderingAutoClearDepthStencil(renderingGroupId:Int, autoClearDepthStencil:Bool, depth:Bool = true, stencil:Bool = true) {
		this._renderingManager.setRenderingAutoClearDepthStencil(renderingGroupId, autoClearDepthStencil, depth, stencil);
	}

	/**
	 * Will flag all materials as dirty to trigger new shader compilation
	 * @param predicate If not null, it will be used to specifiy if a material has to be marked as dirty
	 */
	public function markAllMaterialsAsDirty(flag:Int, ?predicate:Material->Bool) {
		for (material in this.materials) {
			if (predicate != null && !predicate(material)) {
				continue;
			}
			material.markAsDirty(flag);
		}
	}
	
}
