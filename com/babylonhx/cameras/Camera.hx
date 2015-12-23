package com.babylonhx.cameras;

import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Viewport;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.postprocess.PostProcess;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.tools.Tools;
import com.babylonhx.postprocess.AnaglyphPostProcess;
import com.babylonhx.postprocess.StereoscopicInterlacePostProcess;
import com.babylonhx.postprocess.VRDistortionCorrectionPostProcess;
import com.babylonhx.postprocess.PassPostProcess;
import com.babylonhx.materials.Effect;
import com.babylonhx.animations.IAnimatable;

/**
* ...
* @author Krtolica Vujadin
*/

@:expose('BABYLON.Camera') class Camera extends Node implements IAnimatable {
	
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

	// Members
	public var position:Vector3 = Vector3.Zero();
	public var upVector:Vector3 = Vector3.Up();
	public var orthoLeft:Null<Float> = null;
    public var orthoRight:Null<Float> = null;
    public var orthoBottom:Null<Float> = null;
    public var orthoTop:Null<Float> = null;
	public var fov:Float = 0.8;
	public var minZ:Float = 1.0;
	public var maxZ:Float = 10000.0;
	public var inertia:Float = 0.9;
	public var mode:Int = Camera.PERSPECTIVE_CAMERA;
	public var isIntermediate:Bool = false;
	public var viewport:Viewport = new Viewport(0, 0, 1, 1);
	public var subCameras:Array<Camera> = [];
	public var layerMask:Int = 0xFFFFFFFF;
	public var fovMode:Int = Camera.FOVMODE_VERTICAL_FIXED;
	
	// Camera rig members
	public var cameraRigMode:Int = Camera.RIG_MODE_NONE;
	public var _cameraRigParams:Dynamic;
	public var _rigCameras:Array<Camera> = [];

	// Cache
	private var _computedViewMatrix = Matrix.Identity();
	public var _projectionMatrix = new Matrix();
	private var _worldMatrix:Matrix;
	public var _postProcesses:Array<PostProcess> = [];
	public var _postProcessesTakenIndices:Array<Int> = [];
	
	public var _activeMeshes = new SmartArray<Mesh>(256);
	
	private var _globalPosition:Vector3 = Vector3.Zero();
	public var globalPosition(get, never):Vector3;
	
	// VK: do not delete these !!!
	public var _getViewMatrix:Void->Matrix;
	public var getProjectionMatrix:Bool->Matrix;
	
	
	#if purejs
	private var eventPrefix:String = "mouse";
	#end
	

	public function new(name:String, position:Vector3, scene:Scene) {
		super(name, scene);
		
		this.position = position;
		scene.addCamera(this);
		
		if (scene.activeCamera == null) {
			scene.activeCamera = this;
		}
		
		this.getProjectionMatrix = getProjectionMatrix_default;
		this._getViewMatrix = _getViewMatrix_default;
		
		#if purejs
		eventPrefix = Tools.GetPointerPrefix();
		#end
	}
	
	private function get_globalPosition():Vector3 {
		return this._globalPosition;
	}
	
	public function getActiveMeshes():SmartArray<Mesh> {
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
		
		var engine = this.getEngine();
		
		this._cache.position.copyFrom(this.position);
		this._cache.upVector.copyFrom(this.upVector);
		
		this._cache.mode = this.mode;
		this._cache.minZ = this.minZ;
		this._cache.maxZ = this.maxZ;
		
		this._cache.fov = this.fov;
		this._cache.aspectRatio = engine.getAspectRatio(this);
		
		this._cache.orthoLeft = this.orthoLeft;
		this._cache.orthoRight = this.orthoRight;
		this._cache.orthoBottom = this.orthoBottom;
		this._cache.orthoTop = this.orthoTop;
		this._cache.renderWidth = engine.getRenderWidth();
		this._cache.renderHeight = engine.getRenderHeight();
	}

	public function _updateFromScene() {
		this.updateCache();
		this._update();
	}

	// Synchronized	
	override public function _isSynchronized():Bool {
		return this._isSynchronizedViewMatrix() && this._isSynchronizedProjectionMatrix();
	}

	public function _isSynchronizedViewMatrix():Bool {
		if (!super._isSynchronized())
			return false;
			
		return this._cache.position.equals(this.position)
			&& this._cache.upVector.equals(this.upVector)
			&& this.isSynchronizedWithParent();
	}

	public function _isSynchronizedProjectionMatrix():Bool {
		var check = this._cache.mode == this.mode
			&& this._cache.minZ == this.minZ
			&& this._cache.maxZ == this.maxZ;
			
		if (!check) {
			return false;
		}
		
		var engine = this.getEngine();
		
		if (this.mode == Camera.PERSPECTIVE_CAMERA) {
			check = this._cache.fov == this.fov
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
	public function attachControl(?element:Dynamic, noPreventDefault:Bool = false, useCtrlForPanning:Bool = true) {
		
	}

	public function detachControl(?element:Dynamic) {
		
	}

	public function _update() {
		if (this.cameraRigMode != Camera.RIG_MODE_NONE) {
			this._updateRigCameras();
		}
		this._checkInputs();
	}
	
	public function _checkInputs() {
    
	}

	public function attachPostProcess(postProcess:PostProcess, ?insertAt:Int):Int {
		if (!postProcess.isReusable() && this._postProcesses.indexOf(postProcess) > -1) {
			trace("You're trying to reuse a post process not defined as reusable.");
			return 0;
		}
		

		if (insertAt == null || insertAt < 0) {
			this._postProcesses.push(postProcess);
			this._postProcessesTakenIndices.push(this._postProcesses.length - 1);
			
			return this._postProcesses.length - 1;
		}
		
		var add:Int = 0;
		
		if (this._postProcesses[insertAt] != null) {
			
			var start = this._postProcesses.length - 1;
			
			var i = start;
			while(i >= insertAt + 1) {
				this._postProcesses[i + 1] = this._postProcesses[i];
				--i;
			}
			
			add = 1;
		}
		
		for (i in 0...this._postProcessesTakenIndices.length) {
			if (this._postProcessesTakenIndices[i] < insertAt) {
				continue;
			}
			
			var start = this._postProcessesTakenIndices.length - 1;
			var j = start;
			while(j >= i) {
				this._postProcessesTakenIndices[j + 1] = this._postProcessesTakenIndices[j] + add;
				--j;
			}
			this._postProcessesTakenIndices[i] = insertAt;
			break;
		}
		
		if (add == 0 && this._postProcessesTakenIndices.indexOf(insertAt) == -1) {
			this._postProcessesTakenIndices.push(insertAt);
		}
		
		var result = insertAt + add;
		
		this._postProcesses[result] = postProcess;
		
		return result;
	}

	public function detachPostProcess(postProcess:PostProcess, atIndices:Dynamic = null):Array<Int> {
		var result:Array<Int> = [];
		
		if (atIndices == null) {
			
			for (i in 0...this._postProcesses.length) {
				
				if (this._postProcesses[i] != postProcess) {
					continue;
				}
				
				this._postProcesses.splice(i, 1);
				
				var index = this._postProcessesTakenIndices.indexOf(i);
				this._postProcessesTakenIndices.splice(index, 1);
			}
			
		}
		else {
			atIndices = Std.is(atIndices, Array) ? atIndices : [atIndices];
			for (i in 0...atIndices.length) {
				var foundPostProcess = this._postProcesses[atIndices[i]];
				
				if (foundPostProcess != postProcess) {
					result.push(i);
					continue;
				}
				
				this._postProcesses.splice(atIndices[i], 1);
				
				var index = this._postProcessesTakenIndices.indexOf(atIndices[i]);
				this._postProcessesTakenIndices.splice(index, 1);
			}
		}
		return result;
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
		this._computedViewMatrix = this._computeViewMatrix(force);
		
		if (!force && this._isSynchronizedViewMatrix()) {
			return this._computedViewMatrix;
		}
		
		if (this.parent == null || this.parent.getWorldMatrix == null) {
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
		
		this._currentRenderId = this.getScene().getRenderId();
		
		return this._computedViewMatrix;
	}

	public function _computeViewMatrix(force:Bool = false):Matrix {
		if (!force && this._isSynchronizedViewMatrix()) {
			return this._computedViewMatrix;
		}
		
		this._computedViewMatrix = this._getViewMatrix();		
		this._currentRenderId = this.getScene().getRenderId();
		
		return this._computedViewMatrix;
	}

	public function getProjectionMatrix_default(force:Bool = false):Matrix {

		if (!force && this._isSynchronizedProjectionMatrix()) {
			return this._projectionMatrix;
		}
		
		var engine = this.getEngine();
		if (this.mode == Camera.PERSPECTIVE_CAMERA) {
			if (this.minZ <= 0) {
				this.minZ = 0.1;
			}
			
			Matrix.PerspectiveFovLHToRef(this.fov, engine.getAspectRatio(this), this.minZ, this.maxZ, this._projectionMatrix, this.fovMode);
			return this._projectionMatrix;
		}
		
		var halfWidth = engine.getRenderWidth() / 2.0;
		var halfHeight = engine.getRenderHeight() / 2.0;
		Matrix.OrthoOffCenterLHToRef(this.orthoLeft == null ? -halfWidth : this.orthoLeft, this.orthoRight == null ? halfWidth : this.orthoRight, this.orthoBottom == null ? -halfHeight : this.orthoBottom, this.orthoTop == null ? halfHeight : this.orthoTop, this.minZ, this.maxZ, this._projectionMatrix);
		return this._projectionMatrix;
	}
	
	public function dispose() {
		// Animations
        this.getScene().stopAnimation(this);
		
		// Remove from scene
		this.getScene().removeCamera(this);
		while (this._rigCameras.length > 0) {
			this._rigCameras.pop().dispose();
		}
		
		// Postprocesses
		for (i in 0...this._postProcessesTakenIndices.length) {
			this._postProcesses[this._postProcessesTakenIndices[i]].dispose(this);
		}
	}
	
	// ---- Camera rigs section ----
	public function setCameraRigMode(mode:Int, rigParams:Dynamic) {
		while (this._rigCameras.length > 0) {
			this._rigCameras.pop().dispose();
		}
		this.cameraRigMode = mode;
		this._cameraRigParams = { };

		switch (this.cameraRigMode) {
			case Camera.RIG_MODE_STEREOSCOPIC_ANAGLYPH, 
				 Camera.RIG_MODE_STEREOSCOPIC_SIDEBYSIDE_PARALLEL, 
				 Camera.RIG_MODE_STEREOSCOPIC_SIDEBYSIDE_CROSSEYED, 
				 Camera.RIG_MODE_STEREOSCOPIC_OVERUNDER:
					 
				this._cameraRigParams.interaxialDistance = rigParams.interaxialDistance != null ? rigParams.interaxialDistance : 0.0637;
				//we have to implement stereo camera calcultating left and right viewpoints from interaxialDistance and target, 
				//not from a given angle as it is now, but until that complete code rewriting provisional stereoHalfAngle value is introduced
				this._cameraRigParams.stereoHalfAngle = Tools.ToRadians(this._cameraRigParams.interaxialDistance / 0.0637);
				
				this._rigCameras.push(this.createRigCamera(this.name + "_L", 0));
				this._rigCameras.push(this.createRigCamera(this.name + "_R", 1));
		}
		
		var postProcesses:Array<PostProcess> = [];
		
		switch (this.cameraRigMode) {
			case Camera.RIG_MODE_STEREOSCOPIC_ANAGLYPH:
				postProcesses.push(new PassPostProcess(this.name + "_passthru", 1.0, this._rigCameras[0]));
				this._rigCameras[0].isIntermediate = true;
				
				postProcesses.push(new AnaglyphPostProcess(this.name + "_anaglyph", 1.0, this._rigCameras[1]));
				postProcesses[1].onApply = function(effect:Effect) {
					effect.setTextureFromPostProcess("leftSampler", postProcesses[0]);
				};
				
			case Camera.RIG_MODE_STEREOSCOPIC_SIDEBYSIDE_PARALLEL,
				 Camera.RIG_MODE_STEREOSCOPIC_SIDEBYSIDE_CROSSEYED,
				 Camera.RIG_MODE_STEREOSCOPIC_OVERUNDER:
				var isStereoscopicHoriz = (this.cameraRigMode == Camera.RIG_MODE_STEREOSCOPIC_SIDEBYSIDE_PARALLEL || this.cameraRigMode == Camera.RIG_MODE_STEREOSCOPIC_SIDEBYSIDE_CROSSEYED);
				var firstCamIndex = (this.cameraRigMode == Camera.RIG_MODE_STEREOSCOPIC_SIDEBYSIDE_CROSSEYED) ? 1 : 0;
				var secondCamIndex = 1 - firstCamIndex;
				
				postProcesses.push(new PassPostProcess(this.name + "_passthru", 1.0, this._rigCameras[firstCamIndex]));
				this._rigCameras[firstCamIndex].isIntermediate = true;
				
				postProcesses.push(new StereoscopicInterlacePostProcess(this.name + "_stereoInterlace", this._rigCameras[secondCamIndex], postProcesses[0], isStereoscopicHoriz));	
				
			case Camera.RIG_MODE_VR:
				this._rigCameras.push(this.createRigCamera(this.name + "_L", 0));
				this._rigCameras.push(this.createRigCamera(this.name + "_R", 1));
				
				var metrics = rigParams.vrCameraMetrics != null ? rigParams.vrCameraMetrics : VRCameraMetrics.GetDefault();
				this._rigCameras[0]._cameraRigParams.vrMetrics = metrics;
				this._rigCameras[0].viewport = new Viewport(0, 0, 0.5, 1.0);
				this._rigCameras[0]._cameraRigParams.vrWorkMatrix = new Matrix();
				
				this._rigCameras[0]._cameraRigParams.vrHMatrix = metrics.leftHMatrix;
				this._rigCameras[0]._cameraRigParams.vrPreViewMatrix = metrics.leftPreViewMatrix;
				this._rigCameras[0].getProjectionMatrix = this._rigCameras[0]._getVRProjectionMatrix;
				
				if (metrics.compensateDistortion) {
					postProcesses.push(new VRDistortionCorrectionPostProcess("VR_Distort_Compensation_Left", this._rigCameras[0], false, metrics));
				}
				
				this._rigCameras[1]._cameraRigParams.vrMetrics = this._rigCameras[0]._cameraRigParams.vrMetrics;
				this._rigCameras[1].viewport = new Viewport(0.5, 0, 0.5, 1.0);
				this._rigCameras[1]._cameraRigParams.vrWorkMatrix = new Matrix();
				this._rigCameras[1]._cameraRigParams.vrHMatrix = metrics.rightHMatrix;
				this._rigCameras[1]._cameraRigParams.vrPreViewMatrix = metrics.rightPreViewMatrix;
				
				this._rigCameras[1].getProjectionMatrix = this._rigCameras[1]._getVRProjectionMatrix;
				
				if (metrics.compensateDistortion) {
					postProcesses.push(new VRDistortionCorrectionPostProcess("VR_Distort_Compensation_Right", this._rigCameras[1], true, metrics));
				}
		}
		
		this._update();
	}

	private function _getVRProjectionMatrix(force:Bool = false):Matrix {
        var vrMetrics:VRCameraMetrics = cast this._cameraRigParams.vrMetrics;
        Matrix.PerspectiveFovLHToRef(vrMetrics.aspectRatioFov, vrMetrics.aspectRatio, this.minZ, this.maxZ, this._cameraRigParams.vrWorkMatrix);
		this._cameraRigParams.vrWorkMatrix.multiplyToRef(this._cameraRigParams.vrHMatrix, this._projectionMatrix);
		return this._projectionMatrix;
	}

	public function setCameraRigParameter(name:String, value:Dynamic) {
		// VK TODO
		//this._cameraRigParams[name] = value;
		//provisionnally:
		if (name == "interaxialDistance") {
			this._cameraRigParams.stereoHalfAngle = Tools.ToRadians(value / 0.0637);
		}
	}
	
	/**
	 * Maybe needs to be overridden by children so sub has required properties to be copied
	 */
	public function createRigCamera(name:String, cameraIndex:Int):Camera {
		return null;
	}
	
	/**
	 * Maybe needs to be overridden by children
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
	
	/*public function screenToWorld(x:Int, y:Int, depth:Float, position:Vector3) {
		this.plane.position.z = depth;
		var name = this.plane.name;
		var info = this.getScene().pick(x, y, function (mesh:Mesh) {
			return (mesh.name == name);
		}, true, this);
		position.copyFrom(info.hit ? info.pickedPoint : position);
	}*/
	
}
