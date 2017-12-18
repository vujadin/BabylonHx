package com.babylonhx.cameras;

import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Plane;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Viewport;
import com.babylonhx.math.Frustum;
import com.babylonhx.math.Tools;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.postprocess.PostProcess;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.tools.Observable;
import com.babylonhx.tools.Tags;
import com.babylonhx.tools.serialization.SerializationHelper;
import com.babylonhx.postprocess.AnaglyphPostProcess;
import com.babylonhx.postprocess.StereoscopicInterlacePostProcess;
import com.babylonhx.postprocess.VRDistortionCorrectionPostProcess;
import com.babylonhx.postprocess.PassPostProcess;
import com.babylonhx.materials.Effect;
import com.babylonhx.animations.IAnimatable;
import com.babylonhx.animations.Animation;
import com.babylonhx.culling.ICullable;
import com.babylonhx.culling.Ray;

/**
* ...
* @author Krtolica Vujadin
*/

@:expose('BABYLON.Camera') class Camera extends Node implements IAnimatable {
	
	public var inputs:CameraInputsManager;
	
	// Statics
	public static inline var PERSPECTIVE_CAMERA:Int = 0;
	public static inline var ORTHOGRAPHIC_CAMERA:Int = 1;
	
	public static inline var FOVMODE_VERTICAL_FIXED:Int = 0;
	public static inline var FOVMODE_HORIZONTAL_FIXED:Int = 1;
	
	public static inline var RIG_MODE_NONE:Int = 0;
	public static inline var RIG_MODE_STEREOSCOPIC_ANAGLYPH:Int = 10;
	public static inline var RIG_MODE_STEREOSCOPIC_SIDEBYSIDE_PARALLEL:Int = 11;
	public static inline var RIG_MODE_STEREOSCOPIC_SIDEBYSIDE_CROSSEYED:Int = 12;
	public static inline var RIG_MODE_STEREOSCOPIC_OVERUNDER:Int = 13;
	public static inline var RIG_MODE_VR:Int = 20;
	public static inline var RIG_MODE_WEBVR:Int = 21;
	
	public static var UseAlternateWebVRRendering:Bool = false;

	// Members
	@serializeAsVector3()
	public var position:Vector3 = Vector3.Zero();
	
	@serializeAsVector3()
	public var upVector:Vector3 = Vector3.Up();
	
	@serialize()
	public var orthoLeft:Null<Float> = null;
	
	@serialize()
    public var orthoRight:Null<Float> = null;
	
	@serialize()
    public var orthoBottom:Null<Float> = null;
	
	@serialize()
    public var orthoTop:Null<Float> = null;
	
	@serialize()
	public var fov:Float = 0.8;
	
	@serialize()
	public var minZ:Float = 1;
	
	@serialize()
	public var maxZ:Float = 10000.0;
	
	@serialize()
	public var inertia:Float = 0.9;
	
	@serialize()
	public var mode:Int = Camera.PERSPECTIVE_CAMERA;	
	public var isIntermediate:Bool = false;
	
	public var viewport:Viewport = new Viewport(0, 0, 1, 1);
		
	@serialize()
	public var layerMask:Int = 0xFFFFFFFF;
	
	@serialize()
	public var fovMode:Int = Camera.FOVMODE_VERTICAL_FIXED;
	
	// Camera rig members
	@serialize()
	public var cameraRigMode:Int = Camera.RIG_MODE_NONE;
	
	@serialize()
	public var interaxialDistance:Float;
	
	@serialize()
	public var isStereoscopicSideBySide:Bool;
	
	public var _cameraRigParams:Dynamic;
	private var _rigCameras:Array<Camera> = [];
	private var _rigPostProcess:PostProcess = null;
	private var _webvrViewMatrix:Matrix = Matrix.Identity();
    public var _skipRendering:Bool = false;
	public var _alternateCamera:Camera;
	
	public var customRenderTargets:Array<RenderTargetTexture> = [];
	
	// Observables
    public var onViewMatrixChangedObservable:Observable<Camera> = new Observable<Camera>();
    public var onProjectionMatrixChangedObservable:Observable<Camera> = new Observable<Camera>();
	public var onAfterCheckInputsObservable:Observable<Camera> = new Observable<Camera>();
	public var onRestoreStateObservable:Observable<Camera> = new Observable<Camera>();

	// Cache
	private var _computedViewMatrix:Matrix = Matrix.Identity();
	public var _projectionMatrix:Matrix = new Matrix();
	private var _doNotComputeProjectionMatrix:Bool = false;
	private var _worldMatrix:Matrix;
	public var _postProcesses:Array<PostProcess> = [];
	private var _transformMatrix:Matrix = Matrix.Zero();
	
	public var _activeMeshes:SmartArray<AbstractMesh> = new SmartArray<AbstractMesh>(256);
	
	private var _globalPosition:Vector3 = Vector3.Zero();
	private var _frustumPlanes:Array<Plane> = [];
	private var _refreshFrustumPlanes:Bool = true;
	
	// BHX: do not delete these !!!
	// BHX: these are rebinded in setCameraRigMode() method
	public var _getViewMatrix:Void->Matrix;
	public var getProjectionMatrix:Null<Bool>->Matrix;
	

	public function new(name:String, position:Vector3, scene:Scene) {
		super(name, scene);
		
		this.getScene().addCamera(this);
		
		if (this.getScene().activeCamera == null) {
			this.getScene().activeCamera = this;
		}
		
		this.getProjectionMatrix = getProjectionMatrix_default;
		this._getViewMatrix = _getViewMatrix_default;
		
		this.position = position;
	}
	
	private var _storedFov:Float;
	private var _stateStored:Bool;

	/**
	 * Store current camera state (fov, position, etc..)
	 */
	public function storeState():Camera {
		this._stateStored = true;
		this._storedFov = this.fov;
		
		return this;
	}

	/**
	 * Restores the camera state values if it has been stored. You must call storeState() first
	 */
	public function _restoreStateValues():Bool {
		if (!this._stateStored) {
			return false;
		}
		
		this.fov = this._storedFov;
		
		return true;
	}
	
	/**
     * Restored camera state. You must call storeState() first
     */
    public function restoreState():Bool {
        if (this._restoreStateValues()) {
            this.onRestoreStateObservable.notifyObservers(this);
            return true;
        }
		
        return false;
    }
	
	override public function getClassName():String {
		return 'Camera';
	}
	
	/**
	 * @param {boolean} fullDetails - support for multiple levels of logging within scene loading
	 */
	public function toString(fullDetails:Bool = false):String {
		var ret = "Name: " + this.name;
		ret += ", type: " + this.getClassName();
		if (this.animations != null) {
			for (i in 0...this.animations.length) {
				ret += ", animation[0]: " + this.animations[i].toString(fullDetails);
			}
		}
		if (fullDetails) {
			
		}
		return ret;
	}
	
	public var globalPosition(get, never):Vector3;
	private function get_globalPosition():Vector3 {
		return this._globalPosition;
	}	
	public function getActiveMeshes():SmartArray<AbstractMesh> {
        return this._activeMeshes;
    }

    public function isActiveMesh(mesh:Mesh):Bool {
        return (this._activeMeshes.indexOf(mesh) != -1);
    }

	//Cache
	override public function _initCache() {
		super._initCache();
		
		this._cache.position = new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
		this._cache.upVector = new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
		
		this._cache.mode = null;
		this._cache.minZ = null;
		this._cache.maxZ = null;
		
		this._cache.fov = null;
		this._cache.fovMode = null;
		this._cache.aspectRatio = null;
		
		this._cache.orthoLeft = null;
		this._cache.orthoRight = null;
		this._cache.orthoBottom = null;
		this._cache.orthoTop = null;
		this._cache.renderWidth = null;
		this._cache.renderHeight = null;
	}

	override public function _updateCache(ignoreParentClass:Bool = false) {
		if (!ignoreParentClass) {
			super._updateCache();
		}
		
		this._cache.position.copyFrom(this.position);
		this._cache.upVector.copyFrom(this.upVector);
	}

	// Synchronized	
	override public function _isSynchronized():Bool {
		return this._isSynchronizedViewMatrix() && this._isSynchronizedProjectionMatrix();
	}

	public function _isSynchronizedViewMatrix():Bool {
		if (!super._isSynchronized()) {
			return false;
		}
		
		return this._cache.position.equals(this.position)
			&& this._cache.upVector.equals(this.upVector)
			&& this.isSynchronizedWithParent();
	}

	public function _isSynchronizedProjectionMatrix():Bool {
		var check:Bool = this._cache.mode == this.mode
			&& this._cache.minZ == this.minZ
			&& this._cache.maxZ == this.maxZ;
			
		if (!check) {
			return false;
		}
		
		var engine = this.getEngine();
		
		if (this.mode == Camera.PERSPECTIVE_CAMERA) {
			check = this._cache.fov == this.fov
			&& this._cache.fovMode == this.fovMode
			&& this._cache.aspectRatio == engine.getAspectRatio(this);
		}
		else {
			check = this._cache.orthoLeft == this.orthoLeft
			&& this._cache.orthoRight == this.orthoRight
			&& this._cache.orthoBottom == this.orthoBottom
			&& this._cache.orthoTop == this.orthoTop
			&& this._cache.renderWidth == engine.getRenderWidth()
			&& this._cache.renderHeight == engine.getRenderHeight();
		}
		
		return check;
	}

	// Controls
	public function attachControl(useCtrlForPanning:Bool = true, enableKeyboard:Bool = true) {
		
	}

	public function detachControl() {
		
	}

	public function update() {
		this._checkInputs();
		if (this.cameraRigMode != Camera.RIG_MODE_NONE) {
			this._updateRigCameras();
		}
	}
	
	public function _checkInputs() {
		this.onAfterCheckInputsObservable.notifyObservers(this);
	}
	
	public var rigCameras(get, never):Array<Camera>;
	inline private function get_rigCameras():Array<Camera> {
		return this._rigCameras;
	}

	public var rigPostProcess(get, never):PostProcess;
	inline private function get_rigPostProcess():PostProcess {
		return this._rigPostProcess;
	}
	
	private function _cascadePostProcessesToRigCams() {
		// invalidate framebuffer
		if (this._postProcesses.length > 0) {
			this._postProcesses[0].markTextureDirty();
		}
		
		// glue the rigPostProcess to the end of the user postprocesses & assign to each sub-camera
		for (i in 0...this._rigCameras.length) {
			var cam = this._rigCameras[i];
			var rigPostProcess = cam._rigPostProcess;
			
			// for VR rig, there does not have to be a post process 
			if (rigPostProcess != null) {
				var isPass = Std.is(rigPostProcess, PassPostProcess);
				if (isPass) {
					// any rig which has a PassPostProcess for rig[0], cannot be isIntermediate when there are also user postProcesses
					cam.isIntermediate = this._postProcesses.length == 0;
				}   
				
				cam._postProcesses = this._postProcesses.slice(0).concat([rigPostProcess]);
				rigPostProcess.markTextureDirty();
			}
			else {
				cam._postProcesses = this._postProcesses.slice(0);
			}
		}
	}

	public function attachPostProcess(postProcess:PostProcess, insertAt:Int = -1):Int {
		if (!postProcess.isReusable() && this._postProcesses.indexOf(postProcess) > -1) {
			trace("You're trying to reuse a post process not defined as reusable.");
			return 0;
		}
		
		if (insertAt < 0) {
			this._postProcesses.push(postProcess);			
		}
		else {
			this._postProcesses.insert(insertAt, postProcess);
		}
		this._cascadePostProcessesToRigCams(); // also ensures framebuffer invalidated		
		return this._postProcesses.indexOf(postProcess);
	}

	public function detachPostProcess(postProcess:PostProcess, atIndices:Dynamic = null) {
		var idx = this._postProcesses.indexOf(postProcess);
		if (idx != -1) {
			this._postProcesses.splice(idx, 1);
		}
		this._cascadePostProcessesToRigCams(); // also ensures framebuffer invalidated
	}

	override public function getWorldMatrix():Matrix {
		if (this._worldMatrix == null) {
			this._worldMatrix = Matrix.Identity();
		}
		
		var viewMatrix = this.getViewMatrix();
		
		viewMatrix.invertToRef(this._worldMatrix);
		
		return this._worldMatrix;
	}

	public function _getViewMatrix_default():Matrix {
		return Matrix.Identity();
	}

	public function getViewMatrix(force:Bool = false):Matrix {
		if (!force && this._isSynchronizedViewMatrix()) {
			return this._computedViewMatrix;
		}
		
		this.updateCache();
		this._computedViewMatrix = this._getViewMatrix();
		this._currentRenderId = this.getScene().getRenderId();
		
		this._refreshFrustumPlanes = true;
		
		if (this.parent == null || this.parent.getWorldMatrix() == null) {
			this._globalPosition.copyFrom(this.position);
		} 
		else {
			if (this._worldMatrix == null) {
				this._worldMatrix = Matrix.Identity();
			}
			
			this._computedViewMatrix.invertToRef(this._worldMatrix);
			
			this._worldMatrix.multiplyToRef(this.parent.getWorldMatrix(), this._computedViewMatrix);
			this._globalPosition.copyFromFloats(this._computedViewMatrix.m[12], this._computedViewMatrix.m[13], this._computedViewMatrix.m[14]);
			
			this._computedViewMatrix.invert();
			
			this._markSyncedWithParent();
		}
		
		if (this._cameraRigParams != null && this._cameraRigParams.vrPreViewMatrix != null) {
			this._computedViewMatrix.multiplyToRef(this._cameraRigParams.vrPreViewMatrix, this._computedViewMatrix);
		}
		
		this.onViewMatrixChangedObservable.notifyObservers(this);
		
		return this._computedViewMatrix;
	}

	public function freezeProjectionMatrix(?projection:Matrix) {
		this._doNotComputeProjectionMatrix = true;
		if (projection != null) {
			this._projectionMatrix = projection;
		}
	}

	public function unfreezeProjectionMatrix() {
		this._doNotComputeProjectionMatrix = false;
	}

	public function getProjectionMatrix_default(force:Bool = false):Matrix {
		if (this._doNotComputeProjectionMatrix || (!force && this._isSynchronizedProjectionMatrix())) {
			return this._projectionMatrix;
		}
		
		// Cache
		this._cache.mode = this.mode;
		this._cache.minZ = this.minZ;
		this._cache.maxZ = this.maxZ;
		
		// Matrix
		this._refreshFrustumPlanes = true;
		
		var engine = this.getEngine();
		var scene = this.getScene();
		if (this.mode == Camera.PERSPECTIVE_CAMERA) {
			this._cache.fov = this.fov;
			this._cache.fovMode = this.fovMode;
			this._cache.aspectRatio = engine.getAspectRatio(this);
			
			if (this.minZ <= 0) {
				this.minZ = 0.1;
			}
			
			if (scene.useRightHandedSystem) {
				Matrix.PerspectiveFovRHToRef(this.fov,
					engine.getAspectRatio(this),
					this.minZ,
					this.maxZ,
					this._projectionMatrix,
					this.fovMode == Camera.FOVMODE_VERTICAL_FIXED);
			} 
			else {
				Matrix.PerspectiveFovLHToRef(this.fov,
					engine.getAspectRatio(this),
					this.minZ,
					this.maxZ,
					this._projectionMatrix,
					this.fovMode == Camera.FOVMODE_VERTICAL_FIXED);
			}
		} 
		else {
			var halfWidth = engine.getRenderWidth() / 2.0;
			var halfHeight = engine.getRenderHeight() / 2.0;
			if (scene.useRightHandedSystem) {
				Matrix.OrthoOffCenterRHToRef(this.orthoLeft != null ? this.orthoLeft : -halfWidth,
					this.orthoRight != null ? this.orthoRight : halfWidth,
					this.orthoBottom != null ? this.orthoBottom : -halfHeight,
					this.orthoTop != null ? this.orthoTop : halfHeight,
					this.minZ,
					this.maxZ,
					this._projectionMatrix);
			} 
			else {
				Matrix.OrthoOffCenterLHToRef(this.orthoLeft != null ? this.orthoLeft : -halfWidth,
					this.orthoRight != null ? this.orthoRight : halfWidth,
					this.orthoBottom != null ? this.orthoBottom : -halfHeight,
					this.orthoTop != null ? this.orthoTop : halfHeight,
					this.minZ,
					this.maxZ,
					this._projectionMatrix);
			}
			
			this._cache.orthoLeft = this.orthoLeft;
			this._cache.orthoRight = this.orthoRight;
			this._cache.orthoBottom = this.orthoBottom;
			this._cache.orthoTop = this.orthoTop;
			this._cache.renderWidth = engine.getRenderWidth();
			this._cache.renderHeight = engine.getRenderHeight();
		}
		
		this.onProjectionMatrixChangedObservable.notifyObservers(this);
		
		return this._projectionMatrix;
	}
	
	public function getTranformationMatrix():Matrix {
		this._computedViewMatrix.multiplyToRef(this._projectionMatrix, this._transformMatrix);
		return this._transformMatrix;
	}

	private function updateFrustumPlanes() {
		if (!this._refreshFrustumPlanes) {
			return;
		}
		
		this.getTranformationMatrix();
		
		if (this._frustumPlanes == null) {
			this._frustumPlanes = Frustum.GetPlanes(this._transformMatrix);
		} 
		else {
			Frustum.GetPlanesToRef(this._transformMatrix, this._frustumPlanes);
		}
		
		this._refreshFrustumPlanes = false;
	}

	public function isInFrustum(target:ICullable):Bool {
		this.updateFrustumPlanes();
		
		return target.isInFrustum(this._frustumPlanes);
	}

	public function isCompletelyInFrustum(target:ICullable):Bool {
		this.updateFrustumPlanes();
		
		return target.isCompletelyInFrustum(this._frustumPlanes);
	}

	public function getForwardRay(length:Float = 100, ?transform:Matrix, ?origin:Vector3):Ray {
		if (transform == null) {
			transform = this.getWorldMatrix();
		}
		
		if (origin == null) {
			origin = this.position;
		}
		var forward = new Vector3(0, 0, 1);
		var forwardWorld = Vector3.TransformNormal(forward, transform);
		
		var direction = Vector3.Normalize(forwardWorld);
		
		return new Ray(origin, direction, length);
	}
	
	override public function dispose(doNotRecurse:Bool = false) {
		// Observables
        this.onViewMatrixChangedObservable.clear();
        this.onProjectionMatrixChangedObservable.clear();
        this.onAfterCheckInputsObservable.clear();
		this.onRestoreStateObservable.clear();
		
		// Inputs
		if (this.inputs != null) {
			this.inputs.clear();
		}
		
		// Animations
        this.getScene().stopAnimation(this);
		
		// Remove from scene
		this.getScene().removeCamera(this);
		while (this._rigCameras.length > 0) {
			var camera = this._rigCameras.pop();
			if (camera != null) {
				camera.dispose();
			}
		}
		
		// Postprocesses
		if (this._rigPostProcess != null) {
			this._rigPostProcess.dispose(this);
			this._rigPostProcess = null;
			this._postProcesses = [];
		}
		else if (this.cameraRigMode != Camera.RIG_MODE_NONE) {
			this._rigPostProcess = null;
			this._postProcesses = [];
		} 
		else {
			var i = this._postProcesses.length;
			while (--i >= 0) {
				this._postProcesses[i].dispose(this);
			}
		}
		
		// Render targets
		var i = this.customRenderTargets.length;
		while (--i >= 0) {
			this.customRenderTargets[i].dispose();
		}
		this.customRenderTargets = [];
		
		// Active Meshes
		this._activeMeshes.dispose();
		
		super.dispose();
	}
	
	
	// ---- Camera rigs section ----
	public var leftCamera(get, never):FreeCamera;
	private function get_leftCamera():FreeCamera {
		if (this._rigCameras.length < 1) {
			return null;
		}
		return cast this._rigCameras[0];
	}

	public var rightCamera(get, never):FreeCamera;
	private function get_rightCamera():FreeCamera {
		if (this._rigCameras.length < 2) {
			return null;
		}            
		return cast this._rigCameras[1];
	}

	public function getLeftTarget():Vector3 {
		if (this._rigCameras.length < 1) {
			return null;
		}             
		return cast (this._rigCameras[0], TargetCamera).getTarget();
	}

	public function getRightTarget():Vector3 {
		if (this._rigCameras.length < 2) {
			return null;
		}             
		return cast (this._rigCameras[1], TargetCamera).getTarget();
	}

	public function setCameraRigMode(mode:Int, ?rigParams:Dynamic) {
		while (this._rigCameras.length > 0) {
			this._rigCameras.pop().dispose();
		}
		
		if (rigParams == null) {
			rigParams = { };
		}
		
		this.cameraRigMode = mode;
		this._cameraRigParams = {};
		
		//we have to implement stereo camera calcultating left and right viewpoints from interaxialDistance and target, 
		//not from a given angle as it is now, but until that complete code rewriting provisional stereoHalfAngle value is introduced
		this._cameraRigParams.interaxialDistance = rigParams.interaxialDistance != null ? rigParams.interaxialDistance : 0.0637;
		this._cameraRigParams.stereoHalfAngle = Tools.ToRadians(this._cameraRigParams.interaxialDistance / 0.0637);
		
		// create the rig cameras, unless none
		if (this.cameraRigMode != Camera.RIG_MODE_NONE) {
			var leftCamera = this.createRigCamera(this.name + "_L", 0);
			var rightCamera = this.createRigCamera(this.name + "_R", 1);
			if (leftCamera != null && rightCamera != null) {
				this._rigCameras.push(leftCamera);
				this._rigCameras.push(rightCamera);
			}
		}
		
		switch (this.cameraRigMode) {
			case Camera.RIG_MODE_STEREOSCOPIC_ANAGLYPH:
				this._rigCameras[0]._rigPostProcess = new PassPostProcess(this.name + "_passthru", 1.0, this._rigCameras[0]);
				this._rigCameras[1]._rigPostProcess = new AnaglyphPostProcess(this.name + "_anaglyph", 1.0, this._rigCameras);
				
			case Camera.RIG_MODE_STEREOSCOPIC_SIDEBYSIDE_PARALLEL, Camera.RIG_MODE_STEREOSCOPIC_SIDEBYSIDE_CROSSEYED, Camera.RIG_MODE_STEREOSCOPIC_OVERUNDER:
				var isStereoscopicHoriz = this.cameraRigMode == Camera.RIG_MODE_STEREOSCOPIC_SIDEBYSIDE_PARALLEL || this.cameraRigMode == Camera.RIG_MODE_STEREOSCOPIC_SIDEBYSIDE_CROSSEYED;
				
				this._rigCameras[0]._rigPostProcess = new PassPostProcess(this.name + "_passthru", 1.0, this._rigCameras[0]);
				this._rigCameras[1]._rigPostProcess = new StereoscopicInterlacePostProcess(this.name + "_stereoInterlace", this._rigCameras, isStereoscopicHoriz);
				
			case Camera.RIG_MODE_VR:
				var metrics = rigParams.vrCameraMetrics != null ? rigParams.vrCameraMetrics : VRCameraMetrics.GetDefault();
				
				this._rigCameras[0]._cameraRigParams.vrMetrics = metrics;
				this._rigCameras[0].viewport = new Viewport(0, 0, 0.5, 1.0);
				this._rigCameras[0]._cameraRigParams.vrWorkMatrix = new Matrix();
				this._rigCameras[0]._cameraRigParams.vrHMatrix = metrics.leftHMatrix;
				this._rigCameras[0]._cameraRigParams.vrPreViewMatrix = metrics.leftPreViewMatrix;
				this._rigCameras[0].getProjectionMatrix = this._rigCameras[0]._getVRProjectionMatrix;
				
				this._rigCameras[1]._cameraRigParams.vrMetrics = metrics;
				this._rigCameras[1].viewport = new Viewport(0.5, 0, 0.5, 1.0);
				this._rigCameras[1]._cameraRigParams.vrWorkMatrix = new Matrix();
				this._rigCameras[1]._cameraRigParams.vrHMatrix = metrics.rightHMatrix;
				this._rigCameras[1]._cameraRigParams.vrPreViewMatrix = metrics.rightPreViewMatrix;
				this._rigCameras[1].getProjectionMatrix = this._rigCameras[1]._getVRProjectionMatrix;
				
				if (metrics.compensateDistortion) {
					this._rigCameras[0]._rigPostProcess = new VRDistortionCorrectionPostProcess("VR_Distort_Compensation_Left", this._rigCameras[0], false, metrics);
					this._rigCameras[1]._rigPostProcess = new VRDistortionCorrectionPostProcess("VR_Distort_Compensation_Right", this._rigCameras[1], true, metrics);
				}
				
			case Camera.RIG_MODE_WEBVR:
				if (rigParams.vrDisplay != null) {
					var leftEye = rigParams.vrDisplay.getEyeParameters('left');
					var rightEye = rigParams.vrDisplay.getEyeParameters('right');
					
					//Left eye
					this._rigCameras[0].viewport = new Viewport(0, 0, 0.5, 1.0);
					this._rigCameras[0].setCameraRigParameter("left", true);
					this._rigCameras[0].setCameraRigParameter("specs", rigParams.specs);
					this._rigCameras[0].setCameraRigParameter("eyeParameters", leftEye);
					this._rigCameras[0].setCameraRigParameter("frameData", rigParams.frameData);
					this._rigCameras[0].setCameraRigParameter("parentCamera", rigParams.parentCamera);
					this._rigCameras[0]._cameraRigParams.vrWorkMatrix = new Matrix();
					this._rigCameras[0].getProjectionMatrix = this._getWebVRProjectionMatrix;
					this._rigCameras[0].parent = this;
					this._rigCameras[0]._getViewMatrix = this._getWebVRViewMatrix;
					
					//Right eye
					this._rigCameras[1].viewport = new Viewport(0.5, 0, 0.5, 1.0);
					this._rigCameras[1].setCameraRigParameter('eyeParameters', rightEye);
					this._rigCameras[1].setCameraRigParameter("specs", rigParams.specs);
					this._rigCameras[1].setCameraRigParameter("frameData", rigParams.frameData);
					this._rigCameras[1].setCameraRigParameter("parentCamera", rigParams.parentCamera);
					this._rigCameras[1]._cameraRigParams.vrWorkMatrix = new Matrix();
					this._rigCameras[1].getProjectionMatrix = this._getWebVRProjectionMatrix;
					this._rigCameras[1].parent = this;
					this._rigCameras[1]._getViewMatrix = this._getWebVRViewMatrix;
					
					if (Camera.UseAlternateWebVRRendering) {
						this._rigCameras[1]._skipRendering = true;
						this._rigCameras[0]._alternateCamera = this._rigCameras[1];
					}
				}
		}
		
		this._cascadePostProcessesToRigCams();
		this.update();
	}

	private function _getVRProjectionMatrix(?dummy:Bool):Matrix {
		Matrix.PerspectiveFovLHToRef(this._cameraRigParams.vrMetrics.aspectRatioFov, this._cameraRigParams.vrMetrics.aspectRatio, this.minZ, this.maxZ, this._cameraRigParams.vrWorkMatrix);
		this._cameraRigParams.vrWorkMatrix.multiplyToRef(this._cameraRigParams.vrHMatrix, this._projectionMatrix);
		return this._projectionMatrix;
	}

	private function _updateCameraRotationMatrix() {
		//Here for WebVR
	}

	private function _updateWebVRCameraRotationMatrix() {
		//Here for WebVR
	}

	/**
	 * This function MUST be overwritten by the different WebVR cameras available.
	 * The context in which it is running is the RIG camera. So 'this' is the TargetCamera, left or right.
	 */
	private function _getWebVRProjectionMatrix(?dummy:Bool):Matrix {
		return Matrix.Identity();
	}

	/**
	 * This function MUST be overwritten by the different WebVR cameras available.
	 * The context in which it is running is the RIG camera. So 'this' is the TargetCamera, left or right.
	 */
	private function _getWebVRViewMatrix():Matrix {
		return Matrix.Identity();
	}

	public function setCameraRigParameter(name:String, value:Dynamic) {
		if (this._cameraRigParams == null) {
			this._cameraRigParams = {};
		}
		Reflect.setField(this._cameraRigParams, name, value);
		//provisionnally:
		if (name == "interaxialDistance") {
			this._cameraRigParams.stereoHalfAngle = Tools.ToRadians(value / 0.0637);
		}
	}

	/**
	 * needs to be overridden by children so sub has required properties to be copied
	 */
	public function createRigCamera(name:String, cameraIndex:Int):Camera {
		return null;
	}

	/**
	 * May need to be overridden by children
	 */
	public function _updateRigCameras() {
		for (i in 0...this._rigCameras.length) {
			this._rigCameras[i].minZ = this.minZ;
			this._rigCameras[i].maxZ = this.maxZ;
			this._rigCameras[i].fov = this.fov;
		}
		
		// only update viewport when ANAGLYPH
		if (this.cameraRigMode == Camera.RIG_MODE_STEREOSCOPIC_ANAGLYPH) {
			this._rigCameras[0].viewport = this._rigCameras[1].viewport = this.viewport;
		}
	}

	public function _setupInputs() {
	}

	public function serialize():Dynamic {
		/*var serializationObject = SerializationHelper.Serialize(this);
		
		// Type
		serializationObject.type = this.getClassName();
		
		// Parent
		if (this.parent != null) {
			serializationObject.parentId = this.parent.id;
		}
		
		if (this.inputs != null) {
			this.inputs.serialize(serializationObject);
		}
		// Animations
		Animation.AppendSerializedAnimations(this, serializationObject);
		serializationObject.ranges = this.serializeAnimationRanges();
		
		return serializationObject;*/
		return null;
	}

	public function clone(name:String):Camera {
		return SerializationHelper.Clone(Camera.GetConstructorFromName(this.getClassName(), name, this.getScene(), this.interaxialDistance, this.isStereoscopicSideBySide), this);
	}

	public function getDirection(localAxis:Vector3):Vector3 {
		var result = Vector3.Zero();
		
		this.getDirectionToRef(localAxis, result);
		
		return result;
	}

	public function getDirectionToRef(localAxis:Vector3, result:Vector3) {
		Vector3.TransformNormalToRef(localAxis, this.getWorldMatrix(), result);
	}

	static public function GetConstructorFromName(type:String, name:String, scene:Scene, interaxial_distance:Float = 0, isStereoscopicSideBySide:Bool = true):Void->Camera {
		switch (type) {
			case "ArcRotateCamera":
				return function() { return new ArcRotateCamera(name, 0, 0, 1.0, Vector3.Zero(), scene); };
				
			/*case "DeviceOrientationCamera":
				return function() { return new DeviceOrientationCamera(name, Vector3.Zero(), scene); };*/
				
			case "FollowCamera":
				return function() { return new FollowCamera(name, Vector3.Zero(), scene); };
				
			case "ArcFollowCamera":
				return function() { return new ArcFollowCamera(name, 0, 0, 1.0, null, scene); };
				
			/*case "GamepadCamera":
				return function() { return new GamepadCamera(name, Vector3.Zero(), scene); };
				
			case "TouchCamera":
				return function() { return new TouchCamera(name, Vector3.Zero(), scene); };
				
			case "VirtualJoysticksCamera":
				return function() { return new VirtualJoysticksCamera(name, Vector3.Zero(), scene); };
				
			case "WebVRFreeCamera":
				return function() { return new WebVRFreeCamera(name, Vector3.Zero(), scene); };
				
			case "WebVRGamepadCamera":
				return function() { return new WebVRFreeCamera(name, Vector3.Zero(), scene); };
				
			case "VRDeviceOrientationFreeCamera":
				return function() { return new VRDeviceOrientationFreeCamera(name, Vector3.Zero(), scene); };
				
			case "VRDeviceOrientationGamepadCamera":
				return function() { return new VRDeviceOrientationGamepadCamera(name, Vector3.Zero(), scene); };
				
			case "AnaglyphArcRotateCamera":
				return function() { return new AnaglyphArcRotateCamera(name, 0, 0, 1.0, Vector3.Zero(), interaxial_distance, scene); };
				
			case "AnaglyphFreeCamera":
				return function() { return new AnaglyphFreeCamera(name, Vector3.Zero(), interaxial_distance, scene); };
				
			case "AnaglyphGamepadCamera":
				return function() { return new AnaglyphGamepadCamera(name, Vector3.Zero(), interaxial_distance, scene); };
				
			case "AnaglyphUniversalCamera":
				return function() { return new AnaglyphUniversalCamera(name, Vector3.Zero(), interaxial_distance, scene); };
				
			case "StereoscopicArcRotateCamera":
				return function() { return StereoscopicArcRotateCamera(name, 0, 0, 1.0, Vector3.Zero(), interaxial_distance, isStereoscopicSideBySide, scene); };
				
			case "StereoscopicFreeCamera":
				return function() { return new StereoscopicFreeCamera(name, Vector3.Zero(), interaxial_distance, isStereoscopicSideBySide, scene); };
				
			case "StereoscopicGamepadCamera":
				return function() { return new StereoscopicGamepadCamera(name, Vector3.Zero(), interaxial_distance, isStereoscopicSideBySide, scene); };
				
			case "StereoscopicUniversalCamera":
				return function() { return new StereoscopicUniversalCamera(name, Vector3.Zero(), interaxial_distance, isStereoscopicSideBySide, scene); };*/
				
			case "FreeCamera": // Forcing Universal here
				//return function() { return new UniversalCamera(name, Vector3.Zero(), scene); };
				return function() { return new FreeCamera(name, Vector3.Zero(), scene); };
				
			default: // Universal Camera is the default value
				return function() { return new UniversalCamera(name, Vector3.Zero(), scene); };
		}
	}
	
	override public function computeWorldMatrix(force:Bool = false):Matrix {
        return this.getWorldMatrix();
    }

	public static function Parse(parsedCamera:Dynamic, scene:Scene):Camera {
		var type = parsedCamera.type;
		var construct = Camera.GetConstructorFromName(type, parsedCamera.name, scene, parsedCamera.interaxial_distance, parsedCamera.isStereoscopicSideBySide);
		
		var camera = SerializationHelper.Parse(construct, parsedCamera, scene);
		
		// Parent
		/*iif (parsedCamera.parentId != null) {
			camera._waitingParentId = parsedCamera.parentId;
		}
		
		//If camera has an input manager, let it parse inputs settings
		if (camera.inputs != null) {
			camera.inputs.parse(parsedCamera);
			
			camera._setupInputs();
		}
		
		f ((<any>camera).setPosition) { // need to force position
			camera.position.copyFromFloats(0, 0, 0);
			(<any>camera).setPosition(Vector3.FromArray(parsedCamera.position));
		}

		// Target
		if (parsedCamera.target) {
			if ((<any>camera).setTarget) {
				(<any>camera).setTarget(Vector3.FromArray(parsedCamera.target));
			}
		}

		// Apply 3d rig, when found
		if (parsedCamera.cameraRigMode) {
			var rigParams = (parsedCamera.interaxial_distance) ? { interaxialDistance: parsedCamera.interaxial_distance } : {};
			camera.setCameraRigMode(parsedCamera.cameraRigMode, rigParams);
		}

		// Animations
		if (parsedCamera.animations) {
			for (var animationIndex = 0; animationIndex < parsedCamera.animations.length; animationIndex++) {
				var parsedAnimation = parsedCamera.animations[animationIndex];

				camera.animations.push(Animation.Parse(parsedAnimation));
			}
			Node.ParseAnimationRanges(camera, parsedCamera, scene);
		}

		if (parsedCamera.autoAnimate) {
			scene.beginAnimation(camera, parsedCamera.autoAnimateFrom, parsedCamera.autoAnimateTo, parsedCamera.autoAnimateLoop, parsedCamera.autoAnimateSpeed || 1.0);
		}*/

		return camera;
	}
	
	/*public function screenToWorld(x:Int, y:Int, depth:Float, position:Vector3) {
		this.plane.position.z = depth;
		var name = this.plane.name;
		var info = this.getScene().pick(x, y, function (mesh:Mesh) {
			return (mesh.name == name);
		}, true, this);
		position.copyFrom(info.hit ? info.pickedPoint : position);
	}*/
	
}
