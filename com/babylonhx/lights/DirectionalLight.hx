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
	
	public var shadowOrthoScale:Float = 0.5;
	
	public var autoUpdateExtends:Bool = true;

    // Cache
    private var _orthoLeft:Float = Math.POSITIVE_INFINITY;
    private var _orthoRight:Float = Math.NEGATIVE_INFINITY;
    private var _orthoTop:Float = Math.NEGATIVE_INFINITY;
    private var _orthoBottom:Float = Math.POSITIVE_INFINITY;


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
	
	public function setShadowProjectionMatrix(matrix:Matrix, viewMatrix:Matrix, renderList:Array<AbstractMesh>) {
		var activeCamera = this.getScene().activeCamera;
		
		// Check extends
		if (this.autoUpdateExtends || this._orthoLeft == Math.POSITIVE_INFINITY) {
			var tempVector3 = Vector3.Zero();
			
			this._orthoLeft = Math.POSITIVE_INFINITY;
			this._orthoRight = Math.NEGATIVE_INFINITY;
			this._orthoTop = Math.NEGATIVE_INFINITY;
			this._orthoBottom = Math.POSITIVE_INFINITY;
			
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
					
					if (tempVector3.x < this._orthoLeft) {
						this._orthoLeft = tempVector3.x;
					}
					if (tempVector3.y < this._orthoBottom) {
						this._orthoBottom = tempVector3.y;
					}
					
					if (tempVector3.x > this._orthoRight) {
						this._orthoRight = tempVector3.x;
					}
					if (tempVector3.y > this._orthoTop) {
						this._orthoTop = tempVector3.y;
					}
				}
			}
		}
		
		var xOffset = this._orthoRight - this._orthoLeft;
		var yOffset = this._orthoTop - this._orthoBottom;
		
		Matrix.OrthoOffCenterLHToRef(this._orthoLeft - xOffset * this.shadowOrthoScale, this._orthoRight + xOffset * this.shadowOrthoScale, this._orthoBottom - yOffset * this.shadowOrthoScale, this._orthoTop + yOffset * this.shadowOrthoScale, -activeCamera.maxZ, activeCamera.maxZ, matrix);
	}

	public function supportsVSM():Bool {
		return true;
	}

	public function needRefreshPerFrame():Bool {
		return true;
	}
	
	public function needCube():Bool {
		return false;
	}
	
	public function getShadowDirection(?faceIndex:Int):Vector3 {
		return this.direction;
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
