package com.babylonhx.lights;

import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.materials.Effect;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.PointLight') class PointLight extends Light implements IShadowLight {
	
	private var _worldMatrix:Matrix;
	public var transformedPosition:Vector3;
	
	public var position:Vector3;
	

	public function new(name:String, position:Vector3, scene:Scene) {
		super(name, scene);
		
		this._type = "POINTLIGHT";
		this.position = position;
	}
	
	override public function getAbsolutePosition():Vector3 {
		return this.transformedPosition != null ? this.transformedPosition : this.position;
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

	override public function transferToEffect(effect:Effect, ?positionUniformName:String, ?UNUSED_PARAM:String) {
		if (this.parent != null && this.parent.getWorldMatrix() != null) {
			this.computeTransformedPosition();
			
			effect.setFloat4(positionUniformName, this.transformedPosition.x, this.transformedPosition.y, this.transformedPosition.z, 0);
			
			return;
		}
		
		effect.setFloat4(positionUniformName, this.position.x, this.position.y, this.position.z, 0);
	}
	
	public function needCube():Bool {
		return true;
	}

	public function supportsVSM():Bool {
		return false;
	}
	
	public function needRefreshPerFrame():Bool {
		return false;
	}

	public function getShadowDirection(?faceIndex:Int):Vector3 {
		switch (faceIndex) {
			case 0:
				return new Vector3(1, 0, 0);
				
			case 1:
				return new Vector3(-1, 0, 0);
				
			case 2:
				return new Vector3(0, -1, 0);
				
			case 3:
				return new Vector3(0, 1, 0);
				
			case 4:
				return new Vector3(0, 0, 1);
				
			case 5:
				return new Vector3(0, 0, -1);				
		}
		
		return Vector3.Zero();
	}
	
	public function setShadowProjectionMatrix(matrix:Matrix, viewMatrix:Matrix, renderList:Array<AbstractMesh>) {
		var activeCamera = this.getScene().activeCamera;
		Matrix.PerspectiveFovLHToRef(Math.PI / 2, 1.0, activeCamera.minZ, activeCamera.maxZ, matrix);
	}

	override public function _getWorldMatrix():Matrix {
		if (this._worldMatrix == null) {
			this._worldMatrix = Matrix.Identity();
		}
		
		Matrix.TranslationToRef(this.position.x, this.position.y, this.position.z, this._worldMatrix);
		
		return this._worldMatrix;
	}
	
}
