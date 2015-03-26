package com.babylonhx.cameras;

import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Viewport;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.postprocess.PostProcess;
import com.babylonhx.tools.SmartArray;

/**
* ...
* @author Krtolica Vujadin
*/

@:expose('BABYLON.Camera') class Camera extends Node {
	
	// Statics
	public static inline var PERSPECTIVE_CAMERA:Int = 0;
	public static inline var ORTHOGRAPHIC_CAMERA:Int = 1;
	
	public static inline var FOVMODE_VERTICAL_FIXED:Int = 0;
	public static inline var FOVMODE_HORIZONTAL_FIXED:Int = 1;

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

	private var _computedViewMatrix = Matrix.Identity();
	public var _projectionMatrix = new Matrix();
	private var _worldMatrix:Matrix;
	public var _postProcesses:Array<PostProcess> = [];
	public var _postProcessesTakenIndices:Array<Int> = [];
	
	public var _activeMeshes = new SmartArray(256);
	
	private var _globalPosition:Vector3 = Vector3.Zero();
	public var globalPosition(get, never):Vector3;
	

	public function new(name:String, position:Vector3, scene:Scene) {
		super(name, scene);
		
		this.position = position;
		scene.addCamera(this);
		
		if (scene.activeCamera == null) {
			scene.activeCamera = this;
		}
	}
	
	private function get_globalPosition():Vector3 {
		return this._globalPosition;
	}
	
	public function getActiveMeshes():SmartArray {
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
	public function attachControl(?element:Dynamic, ?noPreventDefault:Bool) {
		
	}

	public function detachControl(?element:Dynamic) {
		
	}

	public function _update() {
		
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

	public function _getViewMatrix():Matrix {
		return Matrix.Identity();
	}

	public function getViewMatrix():Matrix {
		this._computedViewMatrix = this._computeViewMatrix();
		
		if (this.parent == null
			|| this.parent.getWorldMatrix() == null
			|| this.isSynchronized()) {				
			this._globalPosition.copyFrom(this.position);
			return this._computedViewMatrix;
		}
		
		if (this._worldMatrix == null) {
			this._worldMatrix = Matrix.Identity();
		}
		
		this._computedViewMatrix.invertToRef(this._worldMatrix);
		
		this._worldMatrix.multiplyToRef(this.parent.getWorldMatrix(), this._computedViewMatrix);
		
		this._computedViewMatrix.invert();
		
		this._currentRenderId = this.getScene().getRenderId();
		this._globalPosition.copyFromFloats(this._computedViewMatrix.m[12], this._computedViewMatrix.m[13], this._computedViewMatrix.m[14]);
		
		return this._computedViewMatrix;
	}

	public function _computeViewMatrix(force:Bool = false):Matrix {
		if (!force && this._isSynchronizedViewMatrix()) {
			return this._computedViewMatrix;
		}
		
		this._computedViewMatrix = this._getViewMatrix();
		if (this.parent == null || this.parent.getWorldMatrix() == null) {
			this._currentRenderId = this.getScene().getRenderId();
		}
		
		return this._computedViewMatrix;
	}

	public function getProjectionMatrix(force:Bool = false/*?force:Bool*/):Matrix {
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
		// Remove from scene
		this.getScene().removeCamera(this);
		
		// Postprocesses
		for (i in 0...this._postProcessesTakenIndices.length) {
			this._postProcesses[this._postProcessesTakenIndices[i]].dispose(this);
		}
	}
	
}
