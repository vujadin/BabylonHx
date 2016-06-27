package com.babylonhx.lights;

import com.babylonhx.materials.Effect;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.mesh.AbstractMesh;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.SpotLight') class SpotLight extends Light implements IShadowLight {

	@serializeAsVector3()
	public var position:Vector3;

	@serializeAsVector3()
	public var direction:Vector3;

	@serialize()
	public var angle:Float;

	@serialize()
	public var exponent:Float;

	public var transformedPosition:Vector3;

	private var _transformedDirection:Vector3;
	private var _worldMatrix:Matrix;
	

	public function new(name:String, position:Vector3, direction:Vector3, angle:Float, exponent:Float, scene:Scene) {
		super(name, scene);
		
		this._type = "SPOTLIGHT";
		
		this.position = position;
		this.direction = direction;
		this.angle = angle;
		this.exponent = exponent;
	}

	override public function getAbsolutePosition():Vector3 {
		return this.transformedPosition != null ? this.transformedPosition : this.position;
	}

	public function setShadowProjectionMatrix(matrix:Matrix, viewMatrix:Matrix, renderList:Array<AbstractMesh>) {
		var activeCamera = this.getScene().activeCamera;
		Matrix.PerspectiveFovLHToRef(this.angle, 1.0, activeCamera.minZ, activeCamera.maxZ, matrix);
	}
	
	public function needCube():Bool {
		return false;
	}

	public function supportsVSM():Bool {
		return true;
	}

	public function needRefreshPerFrame():Bool {
		return false;
	}

	public function getShadowDirection(?faceIndex:Int):Vector3 {
		return this.direction;
	}
	
	public function setDirectionToTarget(target:Vector3):Vector3 {
		this.direction = Vector3.Normalize(target.subtract(this.position));
		
		return this.direction;
	}

	public function computeTransformedPosition():Bool {
		if (this.parent != null && this.parent.getWorldMatrix() != null) {
			if (this.transformedPosition == null) {
				this.transformedPosition = Vector3.Zero();
			}
			
			Vector3.TransformCoordinatesToRef(this.position, this.parent.getWorldMatrix(), this.transformedPosition);
			
			return true;
		}
		
		return false;
	}

	override public function transferToEffect(effect:Effect, ?positionUniformName:String, ?directionUniformName:String) {
		var normalizeDirection:Vector3 = null;
		
		if (this.parent != null && this.parent.getWorldMatrix() != null) {
			if (this._transformedDirection == null) {
				this._transformedDirection = Vector3.Zero();
			}
			
			this.computeTransformedPosition();
			
			Vector3.TransformNormalToRef(this.direction, this.parent.getWorldMatrix(), this._transformedDirection);
			
			effect.setFloat4(positionUniformName, this.transformedPosition.x, this.transformedPosition.y, this.transformedPosition.z, this.exponent);
			normalizeDirection = Vector3.Normalize(this._transformedDirection);
		} 
		else {
			effect.setFloat4(positionUniformName, this.position.x, this.position.y, this.position.z, this.exponent);
			normalizeDirection = Vector3.Normalize(this.direction);
		}
		
		effect.setFloat4(directionUniformName, normalizeDirection.x, normalizeDirection.y, normalizeDirection.z, Math.cos(this.angle * 0.5));
	}

	override public function _getWorldMatrix():Matrix {
		if (this._worldMatrix == null) {
			this._worldMatrix = Matrix.Identity();
		}
		
		Matrix.TranslationToRef(this.position.x, this.position.y, this.position.z, this._worldMatrix);
		
		return this._worldMatrix;
	}
	
}
