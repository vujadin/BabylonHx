package com.babylonhx.lights;

import com.babylonhx.materials.Effect;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.DirectionalLight') class DirectionalLight extends Light implements IShadowLight {
	
	public var position:Vector3;
	public var direction:Vector3;

	private var _transformedDirection:Vector3;
	public var transformedPosition:Vector3;
	private var _worldMatrix:Matrix;
	
	public var shadowOrthoScale:Float = 1.1;
	

	public function new(name:String, direction:Vector3, scene:Scene) {
		super(name, scene);
		
		this.direction = direction;
		this.position = direction.scale(-1);
	}
	
	override public function getAbsolutePosition():Vector3 {
		return this.transformedPosition != null ? this.transformedPosition : this.position;
	}

	public function setDirectionToTarget(target:Vector3):Vector3 {
		this.direction = Vector3.Normalize(target.subtract(this.position));
		return this.direction;
	}
	
	public function setShadowProjectionMatrix(matrix: Matrix, viewMatrix: Matrix, renderList: Array<AbstractMesh>, useVSM:Bool) {
		var orthoLeft = Math.POSITIVE_INFINITY;
		var orthoRight = Math.NEGATIVE_INFINITY;
		var orthoTop = Math.NEGATIVE_INFINITY;
		var orthoBottom = Math.POSITIVE_INFINITY;
		
		var tempVector3 = Vector3.Zero();
		
		var activeCamera = this.getScene().activeCamera;
		
		// Check extends
		for (meshIndex in 0...renderList.length) {
			var mesh = renderList[meshIndex];
			
			if (mesh == null) {
				continue;
			}
			
			var boundingInfo = mesh.getBoundingInfo();
			
			if (boundingInfo == null) {
				continue;
			}
			
			var boundingBox = boundingInfo.boundingBox;
			
			for (index in 0...boundingBox.vectorsWorld.length) {
				Vector3.TransformCoordinatesToRef(boundingBox.vectorsWorld[index], viewMatrix, tempVector3);
				
				if (tempVector3.x < orthoLeft) {
					orthoLeft = tempVector3.x;
				}
				if (tempVector3.y < orthoBottom) {
					orthoBottom = tempVector3.y;
				}
				
				if (tempVector3.x > orthoRight) {
					orthoRight = tempVector3.x;
				}
				if (tempVector3.y > orthoTop) {
					orthoTop = tempVector3.y;
				}
			}
		}
		
		var xOffset = orthoRight - orthoLeft;
		var yOffset = orthoTop - orthoBottom;
		
		Matrix.OrthoOffCenterLHToRef(orthoLeft - xOffset * this.shadowOrthoScale, orthoRight + xOffset * this.shadowOrthoScale,
                                     orthoBottom - yOffset * this.shadowOrthoScale, orthoTop + yOffset * this.shadowOrthoScale,
                                     -activeCamera.maxZ, activeCamera.maxZ, matrix);
	}

	public function supportsVSM():Bool {
		return true;
	}

	public function needRefreshPerFrame():Bool {
		return true;
	}

	public function computeTransformedPosition():Bool {
		if (this.parent != null && this.parent.getWorldMatrix != null) {
			if (this.transformedPosition == null) {
				this.transformedPosition = Vector3.Zero();
			}
			
			Vector3.TransformCoordinatesToRef(this.position, this.parent.getWorldMatrix(), this.transformedPosition);
			return true;
		}
		
		return false;
	}

	override public function transferToEffect(effect:Effect, ?directionUniformName:String, ?extra_UNUSED_PARAM:String):Void {
		if (this.parent != null && this.parent.getWorldMatrix != null) {
			if (this._transformedDirection == null) {
				this._transformedDirection = Vector3.Zero();
			}
			
			Vector3.TransformNormalToRef(this.direction, this.parent.getWorldMatrix(), this._transformedDirection);
			effect.setFloat4(directionUniformName, this._transformedDirection.x, this._transformedDirection.y, this._transformedDirection.z, 1);
			
			return;
		}
		
		effect.setFloat4(directionUniformName, this.direction.x, this.direction.y, this.direction.z, 1);
	}

	override public function _getWorldMatrix():Matrix {
		if (this._worldMatrix == null) {
			this._worldMatrix = Matrix.Identity();
		}
		
		Matrix.TranslationToRef(this.position.x, this.position.y, this.position.z, this._worldMatrix);
		
		return this._worldMatrix;
	}
	
}
