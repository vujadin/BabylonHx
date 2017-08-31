package com.babylonhx.cameras;

import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Tools;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.AnaglyphFreeCamera') class AnaglyphFreeCamera extends FreeCamera {
	
	private var _eyeSpace:Float;
	private var _leftCamera:FreeCamera;
	private var _rightCamera:FreeCamera;
	//private var _transformMatrix:Matrix;

	
	public function new(name:String, position:Vector3, eyeSpace:Float, scene:Scene) {
		super(name, position, scene);
		
		this._eyeSpace = Tools.ToRadians(eyeSpace);
		this._transformMatrix = new Matrix();
		
		this._leftCamera = new FreeCamera(name + "_left", position.clone(), scene);
		this._rightCamera = new FreeCamera(name + "_right", position.clone(), scene);
		
		//AnaglyphArcRotateCamera.buildCamera(this, name);
	}

	public function _getSubCameraPosition(eyeSpace:Float, result:Vector3) {
		var target = this.getTarget();
		Matrix.Translation( -target.x, -target.y, -target.z).multiplyToRef(Matrix.RotationY(eyeSpace), this._transformMatrix);
		
		this._transformMatrix = this._transformMatrix.multiply(Matrix.Translation(target.x, target.y, target.z));
		
		Vector3.TransformCoordinatesToRef(this.position, this._transformMatrix, result);
	}

	/*override*/ public function _update() {
		this._getSubCameraPosition(-this._eyeSpace, this._leftCamera.position);
		this._getSubCameraPosition(this._eyeSpace, this._rightCamera.position);
		
		this._updateCamera(this._leftCamera);
		this._updateCamera(this._rightCamera);
		
		//super._update();
	}

	public function _updateCamera(camera:FreeCamera) {
		camera.minZ = this.minZ;
		camera.maxZ = this.maxZ;
		
		camera.fov = this.fov;
		
		camera.viewport = this.viewport;
		
		camera.setTarget(this.getTarget());
	}
	
}
