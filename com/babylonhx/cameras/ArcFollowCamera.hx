package com.babylonhx.cameras;

import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ArcFollowCamera extends TargetCamera {
	
	private var _cartesianCoordinates:Vector3 = Vector3.Zero();
	
	public var alpha:Float;
	public var beta:Float;
	public var radius:Float;
	public var target:AbstractMesh;
	

	public function new(name:String, alpha:Float, beta:Float, radius:Float, target:AbstractMesh, scene:Scene) {
		super(name, Vector3.Zero(), scene);
		
		this.alpha = alpha;
		this.beta = beta;
		this.radius = radius;
		this.target = target;
		
		this.follow();
	}
	
	private function follow() {
		this._cartesianCoordinates.x = this.radius * Math.cos(this.alpha) * Math.cos(this.beta);
		this._cartesianCoordinates.y = this.radius * Math.sin(this.beta);
		this._cartesianCoordinates.z = this.radius * Math.sin(this.alpha) * Math.cos(this.beta);
		
		this.position = this.target.position.add(this._cartesianCoordinates);
		this.setTarget(this.target.position);
	}

	override public function _checkInputs() {
		super._checkInputs();
		this.follow();
	}
	
}
