package com.gamestudiohx.babylonhx.cameras;

import com.gamestudiohx.babylonhx.Engine;
import com.gamestudiohx.babylonhx.Node;
import com.gamestudiohx.babylonhx.Scene;
import com.gamestudiohx.babylonhx.tools.math.Vector3;
import com.gamestudiohx.babylonhx.tools.math.Matrix;
import com.gamestudiohx.babylonhx.animations.Animation;
import com.gamestudiohx.babylonhx.postprocess.PostProcess;
import com.gamestudiohx.babylonhx.tools.math.Viewport;
import flash.display.DisplayObject;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

/*typedef BabylonCameraCache = {
	position: Null<Vector3>,
	upVector: Null<Vector3>,

	mode: Null<Int>,
	minZ: Null<Float>,
	maxZ: Null<Float>,

	fov: Null<Float>,
	aspectRatio: Null<Float>,

	orthoLeft: Null<Float>,
	orthoRight: Null<Float>,
	orthoBottom: Null<Float>,
	orthoTop: Null<Float>,
	renderWidth: Null<Int>,
	renderHeight: Null<Int>
}*/
 
class Camera extends Node{
	
	public static var PERSPECTIVE_CAMERA:Int = 0;
	public static var ORTHOGRAPHIC_CAMERA:Int = 1;

	public var upVector:Vector3;
		
	public var _worldMatrix:Matrix;
	public var _computedViewMatrix:Matrix;
	public var _projectionMatrix:Matrix;
	
	public var fov:Float = 0.8;
	public var orthoLeft:Null<Float> = null;
	public var orthoRight:Null<Float> = null;
	public var orthoBottom:Null<Float> = null;
	public var orthoTop:Null<Float> = null;
	public var minZ:Float = 0.1;
	public var maxZ:Float = 1000.0;
	public var inertia:Float = 0.9;
	public var mode:Int;
	
	public var viewport:Viewport;
	
	public var animations:Array<Animation>;		
	public var _postProcesses:Array<PostProcess>;	
	public var _postProcessesTakenIndices:Array<Int>;

	public function new(name:String, position:Vector3, scene:Scene) {
		super(scene);
		
		this.name = name;
        this.id = name;
        this.position = position;
        this.upVector = Vector3.Up();
        //this._childrenFlag = 1;
				
		this.mode = Camera.PERSPECTIVE_CAMERA;

        scene.cameras.push(this);

        if (scene.activeCamera == null) {
            scene.activeCamera = this;
        }

        this._computedViewMatrix = Matrix.Identity();
		this._projectionMatrix = Matrix.Identity();

        // Animations
        this.animations = [];

        // _postProcesses
        this._postProcesses = [];
		this._postProcessesTakenIndices = [];
        
        // Viewport
        this.viewport = new Viewport(0, 0, 1.0, 1.0);
		
		//this._initCache();
		this._cache = {
			parent: null,
			position: new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY),
			upVector: new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY),

			mode: null,
			minZ: null,
			maxZ: null,

			fov: null,
			aspectRatio: null,

			orthoLeft: null,
			orthoRight: null,
			orthoBottom: null,
			orthoTop: null,
			renderWidth: null,
			renderHeight: null
		};		
	}
	
	override public function _initCache() {
		this._cache = {
			position: new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY),
			upVector: new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY),

			mode: null,
			minZ: null,
			maxZ: null,

			fov: null,
			aspectRatio: null,

			orthoLeft: null,
			orthoRight: null,
			orthoBottom: null,
			orthoTop: null,
			renderWidth: null,
			renderHeight: null
		};
    }
	
	override public function _updateCache(ignoreParentClass:Bool = true) {
        if (!ignoreParentClass) {
			super._updateCache(ignoreParentClass);
        }

        var engine:Engine = this._scene.getEngine();

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

        var engine = this._scene.getEngine();

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
	
	public function getScene():Scene {
		return this._scene;
	}

	public function attachControl(canvas:DisplayObject, noPreventDefault:Bool = false) {
		
	}

	public function detachControl(canvas:DisplayObject) {
		
	}

	public function _update() {
		
	}
	
	public function attachPostProcess(postProcess:PostProcess, ?insertAt:Int):Int {
        if (!postProcess._reusable && Lambda.indexOf(this._postProcesses, postProcess) > -1) {
			trace("You're trying to reuse a post process not defined as reusable.");
            return -1;
        }

        if (insertAt == null || insertAt < 0) {
            this._postProcesses.push(postProcess);
            this._postProcessesTakenIndices.push(this._postProcesses.length - 1);

            return this._postProcesses.length - 1;
        }

        var add:Int = 0;
        if (this._postProcesses.length > insertAt) {
            var i = this._postProcesses.length - 1;
			while (i >= insertAt) {
				this._postProcesses[i + 1] = this._postProcesses[i];
				--i;
			}
            add = 1;
        }

        for (i in 0...this._postProcessesTakenIndices.length) {
            if (this._postProcessesTakenIndices[i] < insertAt) {
                continue;
            }

            var j = this._postProcessesTakenIndices.length - 1;
			while (j >= i) {
				this._postProcessesTakenIndices[j + 1] = this._postProcessesTakenIndices[j] + add;
				--j;
			}
            this._postProcessesTakenIndices[i] = insertAt;
            break;
        }

        if (add > 0 && Lambda.indexOf(this._postProcessesTakenIndices, insertAt) == -1) {
            this._postProcessesTakenIndices.push(insertAt);
        }

        var result = insertAt + add;

        this._postProcesses[result] = postProcess;

        return result;
    }
	
	public function detachPostProcess(postProcess:PostProcess, ?atIndices:Dynamic) {
        var result:Array<Int> = [];


        if (atIndices == null) {
            var length = this._postProcesses.length;

            for (i in 0...length) {
                if (this._postProcesses[i] != postProcess) {
                    continue;
                }

                this._postProcesses[i] = null;  // TODO: remove it from array ??

                var index = Lambda.indexOf(this._postProcessesTakenIndices, i);
                this._postProcessesTakenIndices.splice(index, 1);
            }

        }
        else {
            var _atIndices:Array<PostProcess> = Std.is(atIndices, Array) ? atIndices : [atIndices];
            for (i in 0..._atIndices.length) {
                var foundPostProcess = this._postProcesses[atIndices[i]];

                if (foundPostProcess != postProcess) {
                    result.push(i);
                    continue;
                }

                this._postProcesses[atIndices[i]] = null;		// TODO: remove it from array ??

                var index = Lambda.indexOf(this._postProcessesTakenIndices, atIndices[i]);
                this._postProcessesTakenIndices.splice(index, 1);
            }
        }
        return result;
    }
	
	override inline public function getWorldMatrix():Matrix {
        if (this._worldMatrix == null) {
            this._worldMatrix = Matrix.Identity();
        }

		var viewMatrix = this.getViewMatrix();
        viewMatrix.invertToRef(this._worldMatrix);

        return this._worldMatrix;
	}
	
	function _getViewMatrix():Matrix {
		return Matrix.Identity();
	}

	inline public function getViewMatrix():Matrix {
		this._computedViewMatrix = this._computeViewMatrix();

        if (!(this.parent == null
            || this.parent.getWorldMatrix() == null
            || (!this.hasNewParent() && this.parent.isSynchronized()))) {
            
			if (this._worldMatrix == null) {
				this._worldMatrix = Matrix.Identity();
			}
			
			this._computedViewMatrix.invertToRef(this._worldMatrix);
			this._worldMatrix.multiplyToRef(this.parent.getWorldMatrix(), this._computedViewMatrix);
			this._computedViewMatrix.invert();	
        }        

        return this._computedViewMatrix;
	}
	
	inline public function _computeViewMatrix(force:Bool = false):Matrix {
		if (!(!force && this._isSynchronizedViewMatrix())) {
            this._syncChildFlag();
			this._computedViewMatrix = this._getViewMatrix();
        }        
        return this._computedViewMatrix;
    }

	inline public function getProjectionMatrix(force:Bool = false): Matrix {
		if (!(!force && this._isSynchronizedProjectionMatrix())) {
            var engine = this._scene.getEngine();
			if (this.mode == Camera.PERSPECTIVE_CAMERA) {
				Matrix.PerspectiveFovLHToRef(this.fov, engine.getAspectRatio(this), this.minZ, this.maxZ, this._projectionMatrix);			
			} else {
				var halfWidth = engine.getRenderWidth() / 2.0;
				var halfHeight = engine.getRenderHeight() / 2.0;
				Matrix.OrthoOffCenterLHToRef(this.orthoLeft == null ? -halfWidth : this.orthoLeft, this.orthoRight == null ? halfWidth : this.orthoRight, this.orthoBottom == null ? -halfHeight : this.orthoBottom, this.orthoTop == null ? halfHeight : this.orthoTop, this.minZ, this.maxZ, this._projectionMatrix);
			}
        }
        
        return this._projectionMatrix;
	}
	
	public function dispose() {
		// Remove from scene
        var index = Lambda.indexOf(this._scene.cameras, this);
        this._scene.cameras.splice(index, 1);
        
        // _postProcesses
        for (i in 0...this._postProcessesTakenIndices.length) {
            this._postProcesses[this._postProcessesTakenIndices[i]].dispose(this);
        }
	}
	
}
